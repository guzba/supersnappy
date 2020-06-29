import strutils, strformat, os

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

type
  SnappyException* = object of ValueError

{.push checks: off.}

func varint(value: uint32): (array[5, uint8], int) =
  if value < 1 shl 7:
    result[1] = 1
    result[0][0] = value.uint8
  elif value < 1 shl 14:
    result[1] = 2
    result[0][0] = (value or 0x80).uint8
    result[0][1] = (value shr 7).uint8
  elif value < 1 shl 21:
    result[1] = 3
    result[0][0] = (value or 0x80).uint8
    result[0][1] = ((value shr 7) or 0x80).uint8
    result[0][2] = (value shr 14).uint8
  elif value < 1 shl 28:
    result[1] = 4
    result[0][0] = (value or 0x80).uint8
    result[0][1] = ((value shr 7) or 0x80).uint8
    result[0][2] = ((value shr 14) or 0x80).uint8
    result[0][3] = (value shr 21).uint8
  else:
    result[1] = 5
    result[0][0] = (value or 0x80).uint8
    result[0][1] = ((value shr 7) or 0x80).uint8
    result[0][2] = ((value shr 14) or 0x80).uint8
    result[0][3] = ((value shr 21) or 0x80).uint8
    result[0][4] = (value shr 28).uint8

func varint(buf: openArray[uint8]): (uint32, int) =
  if buf.len == 0:
    return

  var b = buf[0]
  result[0] = b and 0x7F
  result[1] = 1
  if b < 0x80:
    return
  if buf.len == 1:
    return (0.uint32, 0)
  b = buf[1]
  result[0] = result[0] or ((b and 0x7F).uint32 shl 7)
  result[1] = 2
  if b < 0x80:
    return
  if buf.len == 2:
    return (0.uint32, 0)
  b = buf[2]
  result[0] = result[0] or ((b and 0x7F).uint32 shl 14)
  result[1] = 3
  if b < 0x80:
    return
  if buf.len == 3:
    return (0.uint32, 0)
  b = buf[3]
  result[0] = result[0] or ((b and 0x7F).uint32 shl 21)
  result[1] = 4
  if b < 0x80:
    return
  if buf.len == 4:
    return (0.uint32, 0)
  b = buf[4]
  result[0] = result[0] or ((b and 0x7F).uint32 shl 28)
  result[1] = 5
  if b < 0x10:
    return
  return (0.uint32, 0)

template copy64(dst, src: pointer) =
  cast[ptr uint64](dst)[] = cast[ptr uint64](src)[]

template read32(src: pointer): uint32 =
  cast[ptr uint32](src)[]

func uncompress*(src: openArray[uint8]): seq[uint8] =
  template fail() =
    raise newException(
      SnappyException, "Invalid buffer, unable to uncompress"
    )

  let (uncompressedLen, bytesRead) = varint(src)
  if bytesRead <= 0:
    fail()

  result.setLen(uncompressedLen)

  let
    srcLen = src.len
    resultLen = result.len
  var
    s = bytesRead
    d = 0
  while s < srcLen:
    if (src[s] and 0x03) == 0x00:
        var len = src[s].int shr 2 + 1
        inc s

        if len <= 16 and srcLen > s + 16 and resultLen > d + 16:
          copy64(result[d].addr, src[s].unsafeAddr)
          copy64(result[d + 8].addr, src[s + 8].unsafeAddr)
        else:
          if len > 60:
            let bytes = len - 60
            len = (read32(src[s].unsafeAddr) and lenWordMask[bytes]).int + 1
            inc(s, bytes)

          if len <= 0 or s + len > srcLen or d + len > resultLen:
            fail()
          copyMem(result[d].addr, src[s].unsafeAddr, len)

        inc(s, len)
        inc(d, len)
    else:
      let
        entry = uncompressLookup[src[s]]
        trailer = read32(src[s + 1].unsafeAddr) and lenWordMask[entry shr 11]
        len = (entry and 0xFF).int
        offset = (entry and 0x700).int + trailer.int

      inc(s, (entry shr 11).int + 1)

      if d + len > resultLen:
        fail()

      if d - offset >= len:
        if len <= 16 and resultLen > d + 16:
          copy64(result[d].addr, result[d - offset].unsafeAddr)
          copy64(result[d + 8].addr, result[d - offset + 8].unsafeAddr)
        else:
          copyMem(result[d].addr, result[d - offset].addr, len)

        inc(d, len)
      else:
        for i in countup(d, d + len - 1):
          result[d] = result[d - offset]
          inc d

  if d != resultLen:
    fail()

func compress*(src: openArray[uint8]): seq[uint8] =
  template fail() =
    raise newException(
      SnappyException, "Unable to compress buffer"
    )

  if src.len > high(uint32).int:
    fail()

  let (bytes, count) = varint(src.len.uint32)

  # copyMem(result[0].addr, bytes[0].unsafeAddr, count)

{.pop.}
