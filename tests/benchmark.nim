# To run: nim c --gc:arc -d:release -r .\tests\benchmark.nim
# You may need to install first: nimble install snappy, nimsnappyc

import benchy, supersnappy, nimsnappyc, snappy, strformat

const
  files = [
    "alice29.txt", "asyoulik.txt", "fireworks.jpg", "geo.protodata",
    "html", "html_x_4", "kppkn.gtb", "lcet10.txt", "paper-100k.pdf",
    "plrabn12.txt", "urls.10K"
  ]
  iterations = 10

echo "https://github.com/guzba/supersnappy"
for file in files:
  timeIt file:
    let original = readFile(&"tests/data/{file}")
    for i in 0 ..< iterations:
      let
        compressed = supersnappy.compress(original)
        uncompressed = supersnappy.uncompress(compressed)
      keep(uncompressed)

import nimsnappy # Requires libsnappy.dll
echo "https://github.com/dfdeshom/nimsnappy"
for file in files:
  timeIt file:
    let original = readFile(&"tests/data/{file}")
    for i in 0 ..< iterations:
      let
        compressed = nimsnappy.compress(original)
        uncompressed = nimsnappy.uncompress(compressed)
      keep(uncompressed)

echo "https://github.com/NimCompression/nimsnappyc"
for file in files:
  timeIt file:
    let original = readFile(&"tests/data/{file}")
    for i in 0 ..< iterations:
      let
        compressed = nimsnappyc.snappyCompress(original)
        uncompressed = nimsnappyc.snappyUncompress(compressed)
      keep(uncompressed)

echo "https://github.com/jangko/snappy"
for file in files:
  timeIt file:
    let original = cast[seq[uint8]](readFile(&"tests/data/{file}"))
    for i in 0 ..< iterations:
      let
        compressed = snappy.encode(original)
        uncompressed = snappy.decode(compressed)
      keep(uncompressed)
