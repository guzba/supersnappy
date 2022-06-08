when defined(release):
  {.push checks: off.}

proc read32*(src: string, ip: uint): uint32 {.inline.} =
  when nimvm:
    result =
      (src[ip + 0].uint32 shl 0) or
      (src[ip + 1].uint32 shl 8) or
      (src[ip + 2].uint32 shl 16) or
      (src[ip + 3].uint32 shl 24)
  else:
    copyMem(result.addr, src[ip].unsafeAddr, 4)

proc read64*(src: string, ip: uint): uint64 {.inline.} =
  when nimvm:
    result =
      (src[ip + 0].uint64 shl 0) or
      (src[ip + 1].uint64 shl 8) or
      (src[ip + 2].uint64 shl 16) or
      (src[ip + 3].uint64 shl 24) or
      (src[ip + 4].uint64 shl 32) or
      (src[ip + 5].uint64 shl 40) or
      (src[ip + 6].uint64 shl 48) or
      (src[ip + 7].uint64 shl 56)
  else:
    copyMem(result.addr, src[ip].unsafeAddr, 8)

proc copy64*(dst: var string, src: string, op, ip: uint) {.inline.} =
  when nimvm:
    for i in 0.uint .. 7:
      dst[op + i] = src[ip + i]
  else:
    var v = read64(src, ip)
    copyMem(dst[op].addr, v.addr, 8)

proc copyMem*(dst: var string, src: string, op, ip, len: uint) {.inline.} =
  when nimvm:
    for i in 0.uint ..< len:
      dst[op + i] = src[ip + i]
  else:
    copyMem(dst[op].addr, src[ip].unsafeAddr, len)

func varint*(value: uint32): string =
  if value < 1 shl 7:
    result.setLen(1)
    result[0] = value.char
  elif value < 1 shl 14:
    result.setLen(2)
    result[0] = ((value or 128) and 255).char
    result[1] = ((value shr 7) and 255).char
  elif value < 1 shl 21:
    result.setLen(3)
    result[0] = ((value or 128) and 255).char
    result[1] = (((value shr 7) or 128) and 255).char
    result[2] = ((value shr 14) and 255).char
  elif value < 1 shl 28:
    result.setLen(4)
    result[0] = ((value or 128) and 255).char
    result[1] = (((value shr 7) or 128) and 255).char
    result[2] = (((value shr 14) or 128) and 255).char
    result[3] = ((value shr 21) and 255).char
  else:
    result.setLen(5)
    result[0] = ((value or 128) and 255).char
    result[1] = (((value shr 7) or 128) and 255).char
    result[2] = (((value shr 14) or 128) and 255).char
    result[3] = (((value shr 21) or 128) and 255).char
    result[4] = ((value shr 28) and 255).char

func varint*(buf: string): (uint32, int) =
  if buf.len == 0:
    return

  var b = cast[uint8](buf[0])
  result[0] = b and 127
  result[1] = 1
  if b < 128:
    return
  if buf.len == 1:
    return (0.uint32, 0)
  b = cast[uint8](buf[1])
  result[0] = result[0] or ((b and 127).uint32 shl 7)
  result[1] = 2
  if b < 128:
    return
  if buf.len == 2:
    return (0.uint32, 0)
  b = cast[uint8](buf[2])
  result[0] = result[0] or ((b and 127).uint32 shl 14)
  result[1] = 3
  if b < 128:
    return
  if buf.len == 3:
    return (0.uint32, 0)
  b = cast[uint8](buf[3])
  result[0] = result[0] or ((b and 127).uint32 shl 21)
  result[1] = 4
  if b < 128:
    return
  if buf.len == 4:
    return (0.uint32, 0)
  b = cast[uint8](buf[4])
  result[0] = result[0] or ((b and 127).uint32 shl 28)
  result[1] = 5
  if b < 16:
    return
  return (0.uint32, 0)

when defined(release):
  {.pop.}
