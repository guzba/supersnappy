# To run: nim c --gc:arc -d:release -r .\tests\chunks.nim
# You may need to install first: nimble install snappy, nimsnappyc

import ../supersnappy, nimsnappyc, os, snappy, std/monotimes, strformat

const
  iterations = 100

var files: seq[string]
for file in walkFiles("tests/data/chunks/*"):
  files.add(file)

block jangko_snappy:
  echo "https://github.com/jangko/snappy"
  var
    totalUncompressed, totalCompressed: int
    totalDelta: float64
  for file in files:
    let
      original = cast[seq[uint8]](readFile(file))
      start = getMonoTime().ticks
    var
      compressedLen = encode(original).len
      c: int
    inc(totalUncompressed, original.len)
    inc(totalCompressed, compressedLen)
    for i in 0 ..< iterations:
      let
        compressed = encode(original)
        uncompressed = decode(compressed)
      inc(c, uncompressed.len)
    let delta = float64(getMonoTime().ticks - start) / 1000000000.0
    totalDelta = totalDelta + delta
  let percent = 100 - ((totalCompressed / totalUncompressed) * 100)
  echo &"  {totalDelta:.4f}s total, {percent:.2f}% compression"

block nimcompression_nimsnappyc:
  echo "https://github.com/NimCompression/nimsnappyc"
  var
    totalUncompressed, totalCompressed: int
    totalDelta: float64
  for file in files:
    let
      original = cast[seq[uint8]](readFile(file))
      start = getMonoTime().ticks
    var
      compressedLen = snappyCompress(original).len
      c: int
    inc(totalUncompressed, original.len)
    inc(totalCompressed, compressedLen)
    for i in 0 ..< iterations:
      let
        compressed = snappyCompress(original)
        uncompressed = snappyUncompress(compressed)
      inc(c, uncompressed.len)
    let delta = float64(getMonoTime().ticks - start) / 1000000000.0
    totalDelta = totalDelta + delta
  let percent = 100 - ((totalCompressed / totalUncompressed) * 100)
  echo &"  {totalDelta:.4f}s total, {percent:.2f}% compression"

block guzba_supersnappy:
  echo "https://github.com/guzba/supersnappy"
  var
    totalUncompressed, totalCompressed: int
    totalDelta: float64
  for file in files:
    let
      original = cast[seq[uint8]](readFile(file))
      start = getMonoTime().ticks
    var
      compressedLen = supersnappy.compress(original).len
      c: int
    inc(totalUncompressed, original.len)
    inc(totalCompressed, compressedLen)
    for i in 0 ..< iterations:
      let
        compressed = supersnappy.compress(original)
        uncompressed = supersnappy.uncompress(compressed)
      inc(c, uncompressed.len)
    let delta = float64(getMonoTime().ticks - start) / 1000000000.0
    totalDelta = totalDelta + delta
  let percent = 100 - ((totalCompressed / totalUncompressed) * 100)
  echo &"  {totalDelta:.4f}s total, {percent:.2f}% compression"

block guzba_supersnappy_reuse:
  echo "https://github.com/guzba/supersnappy [reuse]"
  var
    totalUncompressed, totalCompressed: int
    totalDelta: float64
    reuseCompress, reuseUncompress: seq[uint8]
  for file in files:
    let
      original = cast[seq[uint8]](readFile(file))
      start = getMonoTime().ticks
    var
      compressedLen = supersnappy.compress(original).len
      c: int
    inc(totalUncompressed, original.len)
    inc(totalCompressed, compressedLen)
    for i in 0 ..< iterations:
      compress(original, reuseCompress)
      uncompress(reuseCompress, reuseUncompress)
      inc(c, reuseUncompress.len)
    let delta = float64(getMonoTime().ticks - start) / 1000000000.0
    totalDelta = totalDelta + delta
  let percent = 100 - ((totalCompressed / totalUncompressed) * 100)
  echo &"  {totalDelta:.4f}s total, {percent:.2f}% compression"
