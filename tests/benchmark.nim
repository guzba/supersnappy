## nim c --gc:arc -d:release -r .\tests\benchmark.nim

import ../supersnappy, nimsnappyc, snappy, std/monotimes, strformat

const
  files = [
    "alice29.txt", "asyoulik.txt", "fireworks.jpg", "geo.protodata",
    "html", "html_x_4", "kppkn.gtb", "lcet10.txt", "paper-100k.pdf",
    "plrabn12.txt", "urls.10K"
  ]
  iterations = 1000

block jangko_snappy:
  echo "https://github.com/jangko/snappy"
  for file in files:
    let
      original = cast[seq[uint8]](readFile(&"tests/data/{file}"))
      start = getMonoTime().ticks
    var
      compressedLen = encode(original).len
      c: int
    for i in 0 ..< iterations:
      let
        compressed = encode(original)
        uncompressed = decode(compressed)
      inc(c, uncompressed.len)
    let
      delta = float64(getMonoTime().ticks - start) / 1000000000.0
      percent = 100 - ((compressedLen / original.len) * 100)
    echo &"  {file}: {delta:.4f}s (compressed to {compressedLen} bytes, {percent:.2f}% reduction) [{c}]"

block nimcompression_nimsnappyc:
  echo "https://github.com/NimCompression/nimsnappyc"
  for file in files:
    let
      original = cast[seq[uint8]](readFile(&"tests/data/{file}"))
      start = getMonoTime().ticks
    var
      compressedLen = snappyCompress(original).len
      c: int
    for i in 0 ..< iterations:
      let
        compressed = snappyCompress(original)
        uncompressed = snappyUncompress(compressed)
      inc(c, uncompressed.len)
    let
      delta = float64(getMonoTime().ticks - start) / 1000000000.0
      percent = 100 - ((compressedLen / original.len) * 100)
    echo &"  {file}: {delta:.4f}s (compressed to {compressedLen} bytes, {percent:.2f}% reduction) [{c}]"

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
    echo &"  {file}: {delta:.4f}s (compressed to {compressedLen} bytes, {percent:.2f}% reduction) [{c}]"

block guzba_supersnappy_reuse:
  echo "https://github.com/guzba/supersnappy [reuse]"
  var reuseCompress, reuseUncompress: seq[uint8]
  for file in files:
    let
      original = cast[seq[uint8]](readFile(&"tests/data/{file}"))
      start = getMonoTime().ticks
    var
      compressedLen = supersnappy.compress(original).len
      c: int
    for i in 0 ..< iterations:
      compress(original, reuseCompress)
      uncompress(reuseCompress, reuseUncompress)
      inc(c, reuseUncompress.len)
    let
      delta = float64(getMonoTime().ticks - start) / 1000000000.0
      percent = 100 - ((compressedLen / original.len) * 100)
    echo &"  {file}: {delta:.4f}s (compressed to {compressedLen} bytes, {percent:.2f}% reduction) [{c}]"
