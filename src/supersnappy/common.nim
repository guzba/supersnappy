when defined(release):
  {.push checks: off.}

template read32*(s: openarray[uint8], pos: int): uint32 =
  when nimvm:
    (s[pos + 0].uint32 shl 0) or
    (s[pos + 1].uint32 shl 8) or
    (s[pos + 2].uint32 shl 16) or
    (s[pos + 3].uint32 shl 24)
  else:
    cast[ptr uint32](s[pos].unsafeAddr)[]

template read64*(s: openarray[uint8], pos: int): uint64 =
  when nimvm:
    (s[pos + 0].uint64 shl 0) or
    (s[pos + 1].uint64 shl 8) or
    (s[pos + 2].uint64 shl 16) or
    (s[pos + 3].uint64 shl 24) or
    (s[pos + 4].uint64 shl 32) or
    (s[pos + 5].uint64 shl 40) or
    (s[pos + 6].uint64 shl 48) or
    (s[pos + 7].uint64 shl 56)
  else:
    cast[ptr uint64](s[pos].unsafeAddr)[]

template copy64*(dst: var seq[uint8], src: openarray[uint8], op, ip: int) =
  when nimvm:
    for i in 0 .. 7:
      dst[op + i] = src[ip + i]
  else:
    cast[ptr uint64](dst[op].addr)[] = read64(src, ip)

func varint*(value: uint32): (array[5, uint8], int) =
  if value < 1 shl 7:
    result[1] = 1
    result[0][0] = value.uint8
  elif value < 1 shl 14:
    result[1] = 2
    result[0][0] = ((value or 128) and 255).uint8
    result[0][1] = ((value shr 7) and 255).uint8
  elif value < 1 shl 21:
    result[1] = 3
    result[0][0] = ((value or 128) and 255).uint8
    result[0][1] = (((value shr 7) or 128) and 255).uint8
    result[0][2] = ((value shr 14) and 255).uint8
  elif value < 1 shl 28:
    result[1] = 4
    result[0][0] = ((value or 128) and 255).uint8
    result[0][1] = (((value shr 7) or 128) and 255).uint8
    result[0][2] = (((value shr 14) or 128) and 255).uint8
    result[0][3] = ((value shr 21) and 255).uint8
  else:
    result[1] = 5
    result[0][0] = ((value or 128) and 255).uint8
    result[0][1] = (((value shr 7) or 128) and 255).uint8
    result[0][2] = (((value shr 14) or 128) and 255).uint8
    result[0][3] = (((value shr 21) or 128) and 255).uint8
    result[0][4] = ((value shr 28) and 255).uint8

func varint*(buf: openarray[uint8]): (uint32, int) =
  if buf.len == 0:
    return

  var b = buf[0]
  result[0] = b and 127
  result[1] = 1
  if b < 128:
    return
  if buf.len == 1:
    return (0.uint32, 0)
  b = buf[1]
  result[0] = result[0] or ((b and 127).uint32 shl 7)
  result[1] = 2
  if b < 128:
    return
  if buf.len == 2:
    return (0.uint32, 0)
  b = buf[2]
  result[0] = result[0] or ((b and 127).uint32 shl 14)
  result[1] = 3
  if b < 128:
    return
  if buf.len == 3:
    return (0.uint32, 0)
  b = buf[3]
  result[0] = result[0] or ((b and 127).uint32 shl 21)
  result[1] = 4
  if b < 128:
    return
  if buf.len == 4:
    return (0.uint32, 0)
  b = buf[4]
  result[0] = result[0] or ((b and 127).uint32 shl 28)
  result[1] = 5
  if b < 16:
    return
  return (0.uint32, 0)

func vmSeq2Str*(src: seq[uint8]): string =
  result = newStringOfCap(src.len)
  for i, c in src:
    result.add(c.char)

func vmStr2Seq*(src: string): seq[uint8] =
  result.setLen(src.len)
  for i, c in src:
    result[i] = c.uint8

when defined(release):
  {.pop.}
