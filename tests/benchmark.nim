# To run: nim c --gc:arc -d:release -r .\tests\benchmark.nim
# You may need to install first: nimble install snappy, nimsnappyc

import ../supersnappy, nimsnappyc, snappy, std/monotimes, strformat

const
  files = [
    "alice29.txt", "asyoulik.txt", "fireworks.jpg", "geo.protodata",
    "html", "html_x_4", "kppkn.gtb", "lcet10.txt", "paper-100k.pdf",
    "plrabn12.txt", "urls.10K"
  ]
  iterations = 1000

block guzba_supersnappy:
  echo "https://github.com/guzba/supersnappy"
  for file in files:
    let
      original = cast[seq[uint8]](readFile(&"tests/data/{file}"))
      start = getMonoTime().ticks
    var
      compressedLen = supersnappy.compress(original).len
      c: int
    for i in 0 ..< iterations:
      let
        compressed = supersnappy.compress(original)
        uncompressed = supersnappy.uncompress(compressed)
      inc(c, uncompressed.len)
    let
      delta = float64(getMonoTime().ticks - start) / 1000000000.0
      percent = 100 - ((compressedLen / original.len) * 100)
    echo &"  {file}: {delta:.4f}s {percent:.2f}% reduction [{c}]"

# import nimsnappy # Requires libsnappy.dll
# block dfdeshom_nimsnappy:
#   echo "https://github.com/dfdeshom/nimsnappy"
#   for file in files:
#     let
#       original = readFile(&"tests/data/{file}")
#       start = getMonoTime().ticks
#     var
#       compressedLen = nimsnappy.compress(original).len
#       c: int
#     for i in 0 ..< iterations:
#       let
#         compressed = nimsnappy.compress(original)
#         uncompressed = nimsnappy.uncompress(compressed)
#       inc(c, uncompressed.len)
#     let
#       delta = float64(getMonoTime().ticks - start) / 1000000000.0
#       percent = 100 - ((compressedLen / original.len) * 100)
#     echo &"  {file}: {delta:.4f}s {percent:.2f}% reduction [{c}]"

block nimcompression_nimsnappyc:
  echo "https://github.com/NimCompression/nimsnappyc"
  for file in files:
    let
      original = cast[seq[uint8]](readFile(&"tests/data/{file}"))
      start = getMonoTime().ticks
    var
      compressedLen = nimsnappyc.snappyCompress(original).len
      c: int
    for i in 0 ..< iterations:
      let
        compressed = nimsnappyc.snappyCompress(original)
        uncompressed = nimsnappyc.snappyUncompress(compressed)
      inc(c, uncompressed.len)
    let
      delta = float64(getMonoTime().ticks - start) / 1000000000.0
      percent = 100 - ((compressedLen / original.len) * 100)
    echo &"  {file}: {delta:.4f}s {percent:.2f}% reduction [{c}]"

block jangko_snappy:
  echo "https://github.com/jangko/snappy"
  for file in files:
    let
      original = cast[seq[uint8]](readFile(&"tests/data/{file}"))
      start = getMonoTime().ticks
    var
      compressedLen = snappy.encode(original).len
      c: int
    for i in 0 ..< iterations:
      let
        compressed = snappy.encode(original)
        uncompressed = snappy.decode(compressed)
      inc(c, uncompressed.len)
    let
      delta = float64(getMonoTime().ticks - start) / 1000000000.0
      percent = 100 - ((compressedLen / original.len) * 100)
    echo &"  {file}: {delta:.4f}s {percent:.2f}% reduction [{c}]"
