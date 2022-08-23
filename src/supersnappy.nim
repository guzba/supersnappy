# This implementation has been heavily influenced by snappy-c
# See the snappy-c repo at https://github.com/andikleen/snappy-c for
# extensive comments explaining the implementation.

import bitops, supersnappy/internal

const
  uncompressLookup = [
    0x0001.uint16, 0x0804, 0x1001, 0x2001, 0x0002, 0x0805, 0x1002, 0x2002,
    0x0003, 0x0806, 0x1003, 0x2003, 0x0004, 0x0807, 0x1004, 0x2004,
    0x0005, 0x0808, 0x1005, 0x2005, 0x0006, 0x0809, 0x1006, 0x2006,
    0x0007, 0x080a, 0x1007, 0x2007, 0x0008, 0x080b, 0x1008, 0x2008,
    0x0009, 0x0904, 0x1009, 0x2009, 0x000a, 0x0905, 0x100a, 0x200a,
    0x000b, 0x0906, 0x100b, 0x200b, 0x000c, 0x0907, 0x100c, 0x200c,
    0x000d, 0x0908, 0x100d, 0x200d, 0x000e, 0x0909, 0x100e, 0x200e,
    0x000f, 0x090a, 0x100f, 0x200f, 0x0010, 0x090b, 0x1010, 0x2010,
    0x0011, 0x0a04, 0x1011, 0x2011, 0x0012, 0x0a05, 0x1012, 0x2012,
    0x0013, 0x0a06, 0x1013, 0x2013, 0x0014, 0x0a07, 0x1014, 0x2014,
    0x0015, 0x0a08, 0x1015, 0x2015, 0x0016, 0x0a09, 0x1016, 0x2016,
    0x0017, 0x0a0a, 0x1017, 0x2017, 0x0018, 0x0a0b, 0x1018, 0x2018,
    0x0019, 0x0b04, 0x1019, 0x2019, 0x001a, 0x0b05, 0x101a, 0x201a,
    0x001b, 0x0b06, 0x101b, 0x201b, 0x001c, 0x0b07, 0x101c, 0x201c,
    0x001d, 0x0b08, 0x101d, 0x201d, 0x001e, 0x0b09, 0x101e, 0x201e,
    0x001f, 0x0b0a, 0x101f, 0x201f, 0x0020, 0x0b0b, 0x1020, 0x2020,
    0x0021, 0x0c04, 0x1021, 0x2021, 0x0022, 0x0c05, 0x1022, 0x2022,
    0x0023, 0x0c06, 0x1023, 0x2023, 0x0024, 0x0c07, 0x1024, 0x2024,
    0x0025, 0x0c08, 0x1025, 0x2025, 0x0026, 0x0c09, 0x1026, 0x2026,
    0x0027, 0x0c0a, 0x1027, 0x2027, 0x0028, 0x0c0b, 0x1028, 0x2028,
    0x0029, 0x0d04, 0x1029, 0x2029, 0x002a, 0x0d05, 0x102a, 0x202a,
    0x002b, 0x0d06, 0x102b, 0x202b, 0x002c, 0x0d07, 0x102c, 0x202c,
    0x002d, 0x0d08, 0x102d, 0x202d, 0x002e, 0x0d09, 0x102e, 0x202e,
    0x002f, 0x0d0a, 0x102f, 0x202f, 0x0030, 0x0d0b, 0x1030, 0x2030,
    0x0031, 0x0e04, 0x1031, 0x2031, 0x0032, 0x0e05, 0x1032, 0x2032,
    0x0033, 0x0e06, 0x1033, 0x2033, 0x0034, 0x0e07, 0x1034, 0x2034,
    0x0035, 0x0e08, 0x1035, 0x2035, 0x0036, 0x0e09, 0x1036, 0x2036,
    0x0037, 0x0e0a, 0x1037, 0x2037, 0x0038, 0x0e0b, 0x1038, 0x2038,
    0x0039, 0x0f04, 0x1039, 0x2039, 0x003a, 0x0f05, 0x103a, 0x203a,
    0x003b, 0x0f06, 0x103b, 0x203b, 0x003c, 0x0f07, 0x103c, 0x203c,
    0x0801, 0x0f08, 0x103d, 0x203d, 0x1001, 0x0f09, 0x103e, 0x203e,
    0x1801, 0x0f0a, 0x103f, 0x203f, 0x2001, 0x0f0b, 0x1040, 0x2040
  ]
  lenWordMask = [0.uint32, 0xff, 0xffff, 0xffffff, 0xffffffff.uint32]
  maxBlockSize = 1 shl 16
  maxCompressTableSize = 1 shl 14

type
  SnappyError* = object of CatchableError ## Raised if an operation fails.

when defined(release):
  {.push checks: off.}

template failUncompress() =
  raise newException(
    SnappyError, "Invalid buffer, unable to uncompress"
  )

template failCompress() =
  raise newException(
    SnappyError, "Unable to compress buffer"
  )

func uncompress*(dst: var string, src: string) {.raises: [SnappyError].} =
  ## Uncompresses src into dst. This resizes dst as needed and starts writing
  ## at dst index 0.

  let (uncompressedLen, bytesRead) = varint(src)
  if bytesRead <= 0:
    failUncompress()

  dst.setLen(uncompressedLen)

  let
    srcLen = src.len.uint
    dstLen = dst.len.uint
  var
    ip = bytesRead.uint
    op = 0.uint
  while ip < srcLen:
    if (cast[uint8](src[ip]) and 3) == 0: # LITERAL
      var len = src[ip].uint shr 2 + 1
      inc ip

      if len <= 16 and srcLen > ip + 16 and dstLen > op + 16:
        copy64(dst, src, op + 0, ip + 0)
        copy64(dst, src, op + 8, ip + 8)
      else:
        if len >= 61.uint:
          let bytes = len - 60
          len = (read32(src, ip) and lenWordMask[bytes]) + 1
          ip += bytes

        if len <= 0 or ip + len > srcLen or op + len > dstLen:
          failUncompress()

        copyMem(dst, src, op, ip, len)

      ip += len
      op += len
    else: # COPY
      if ip + 1 >= srcLen:
        failUncompress()

      let
        entry = uncompressLookup[cast[uint8](src[ip])].uint
        trailer = read32(src, ip + 1) and lenWordMask[entry shr 11]
        len = (entry and 255)
        offset = (entry and 0x700) + trailer

      ip += (entry shr 11) + 1

      if dstLen - op < len or op <= offset - 1: # Catches offset == 0
        failUncompress()

      if len <= 16 and offset >= 8.uint and dstLen > op + 16:
        copy64(dst, dst, op, op - offset)
        copy64(dst, dst, op + 8, op - offset + 8)
        op += len
      elif dstLen - op >= len + 10:
        var
          src = op - offset
          pos = op
          remaining = len.int
        while pos - src < 8:
          copy64(dst, dst, pos, src)
          remaining -= (pos - src).int
          pos += pos - src
        while remaining > 0:
          copy64(dst, dst, pos, src)
          src += 8
          pos += 8
          remaining -= 8
        op += len
      else:
        for i in op ..< op + len:
          dst[op] = dst[op - offset]
          inc op

  if op != dstLen:
    failUncompress()

func uncompress*(src: string): string {.inline.} =
  ## Uncompresses src and returns the uncompressed data.
  uncompress(result, src)

func uncompress*(src: seq[uint8]): seq[uint8] {.inline.} =
  ## Uncompresses src and returns the uncompressed data.
  cast[seq[uint8]](uncompress(cast[string](src)))

func emitLiteral(
  dst: var string,
  src: string,
  op: var uint,
  ip, len: uint,
  fastPath: bool
) =
  var n = len - 1
  if n < 60:
    dst[op] = (n shl 2).char
    inc op
    if fastPath and len <= 16:
      copy64(dst, src, op + 0, ip + 0)
      copy64(dst, src, op + 8, ip + 8)
      op += len
      return
  else:
    var
      base = op
      count: uint
    inc op
    while n > 0.uint:
      dst[op] = (n and 255).char
      n = n shr 8
      inc op
      inc count
    dst[base] = ((59.uint + count) shl 2).char

  copyMem(dst, src, op, ip, len)
  op += len

func findMatchLength(src: string, s1, s2, limit: uint): uint {.inline.} =
  var
    s1 = s1
    s2 = s2
  while s2 <= limit - 8:
    let x = read64(src, s2) xor read64(src, s1 + result)
    if x != 0:
      let matchingBits = countTrailingZeroBits(x).uint
      result += (matchingBits shr 3)
      return
    s2 += 8
    result += 8
  while s2 < limit:
    if src[s2] != src[s1 + result]:
      return
    inc s2
    inc result

func emitCopy64Max(dst: var string, op: var uint, offset, len: uint) =
  if len < 12 and offset < 2048:
    dst[op] = (1.uint + (((len - 4.uint) shl 2) + ((offset shr 8) shl 5))).char
    inc op
    dst[op] = (offset and 255).char
    inc op
  else:
    dst[op] = (2.uint + ((len - 1.uint) shl 2)).char
    inc op
    when nimvm:
      let tmp = (offset and 0xffff).uint16
      dst[op + 0] = ((tmp shl 0) and 255).char
      dst[op + 1] = ((tmp shr 8) and 255).char
    else:
      var offset = offset.uint16
      copyMem(dst[op].addr, offset.addr, 2)
    op += 2

func emitCopy(dst: var string, op: var uint, offset, len: uint) =
  var len = len
  while len >= 68.uint:
    emitCopy64Max(dst, op, offset, 64)
    len -= 64

  if len > 64.uint:
    emitCopy64Max(dst, op, offset, 60)
    len -= 60

  emitCopy64Max(dst, op, offset, len)

func compressFragment(
  dst: var string,
  src: string,
  op: var uint,
  start: uint,
  len: uint,
  compressTable: var seq[uint16]
) =
  let ipEnd = start + len
  var
    ip = start
    nextEmit = ip
    tableSize = 256.uint
    shift = 24.uint

  while tableSize < maxCompressTableSize and tableSize < len:
    tableSize = tableSize shl 1
    dec shift

  when nimvm:
    for i in 0 ..< tableSize:
      compressTable[i] = 0
  else:
    zeroMem(compressTable[0].addr, tableSize * sizeof(uint16).uint)

  template hash(v: uint32): uint32 =
    (v * 0x1e35a7bd) shr shift

  template uint32AtOffset(v: uint64, shift: int): uint32 =
    ((v shr shift) and 0xffffffff.uint32).uint32

  template emitRemainder() =
    if nextEmit < ipEnd:
      emitLiteral(dst, src, op, nextEmit, ipEnd - nextEmit, false)

  if len >= 15.uint:
    let ipLimit = start + len - 15
    inc ip

    var nextHash = hash(read32(src, ip))
    while true:
      var
        skipBytes = 32.uint
        nextIp = ip
        candidate: uint
      while true:
        ip = nextIp
        var
          h = nextHash
          bytesBetweenHashLookups = skipBytes shr 5
        inc skipBytes
        nextIp = ip + bytesBetweenHashLookups
        if nextIp > ipLimit:
          emitRemainder()
          return
        nextHash = hash(read32(src, nextIp))
        candidate = start + compressTable[h]
        compressTable[h] = (ip - start).uint16

        if read32(src, ip) == read32(src, candidate):
          break

      emitLiteral(dst, src, op, nextEmit, ip - nextEmit, true)

      var
        inputBytes: uint64
        candidateBytes: uint32
      while true:
        let
          matched = 4.uint + findMatchLength(src, candidate + 4, ip + 4, ipEnd)
          offset = ip - candidate
        ip += matched
        emitCopy(dst, op, offset, matched)

        let insertTail = ip - 1
        nextEmit = ip
        if ip >= ipLimit:
          emitRemainder()
          return
        inputBytes = read64(src, insertTail)
        let
          prevHash = hash(uint32AtOffset(inputBytes, 0))
          curHash = hash(uint32AtOffset(inputBytes, 8))
        compressTable[prevHash] = (ip - start - 1).uint16
        candidate = start + compressTable[curHash]
        candidateBytes = read32(src, candidate)
        compressTable[curHash] = (ip - start).uint16

        if uint32AtOffset(inputBytes, 8) != candidateBytes:
          break

      nextHash = hash(uint32AtOffset(inputBytes, 16))
      inc ip

  emitRemainder()

func compress*(dst: var string, src: string) {.raises: [SnappyError].} =
  ## Compresses src into dst. This resizes dst as needed and starts writing
  ## at dst index 0.

  when sizeof(int) > 4:
    # Ensure varint32 prefix will work.
    if src.len > uint32.high.int:
      failCompress()

  dst.setLen(32 + src.len + (src.len div 6)) # Worst-case compressed length

  let varintBytes = varint(src.len.uint32)
  for i in 0 ..< varintBytes.len:
    dst[i] = varintBytes[i]

  var
    ip = 0.uint
    op = varintBytes.len.uint
    compressTable = newSeq[uint16](maxCompressTableSize)
  while ip < src.len.uint:
    let
      fragmentSize = src.len.uint - ip
      bytesToRead = min(fragmentSize, maxBlockSize)
    if bytesToRead <= 0:
      failCompress()

    compressFragment(dst, src, op, ip, bytesToRead, compressTable)
    ip += bytesToRead

  dst.setLen(op)

func compress*(src: string): string {.inline.} =
  ## Compresses src and returns the compressed data.
  compress(result, src)

func compress*(src: seq[uint8]): seq[uint8] {.inline.} =
  ## Compresses src and returns the compressed data.
  cast[seq[uint8]](compress(cast[string](src)))

when defined(release):
  {.pop.}
