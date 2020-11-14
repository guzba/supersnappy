import strformat, supersnappy, supersnappy/common

block varint:
  doAssert varint(0) == ([0.uint8, 0, 0, 0, 0], 1)
  doAssert varint(64) == ([0x40.uint8, 0, 0, 0, 0], 1)
  doAssert varint(2097150) == ([0xFE.uint8, 0xFF, 0x7F, 0, 0], 3)
  doAssert varint(high(uint32)) == ([0xFF.uint8, 0xFF, 0xFF, 0xFF, 0x0F], 5)
  doAssert varint(0xFF.uint8) == ([0xFF.uint8, 0x01, 0, 0, 0], 2)

  doAssert varint(varint(0)[0]) == (0.uint32, 1)
  doAssert varint(varint(64)[0]) == (64.uint32, 1)
  doAssert varint(varint(2097150)[0]) == (2097150.uint32, 3)
  doAssert varint(varint(high(uint32))[0]) == (high(uint32), 5)
  doAssert varint(varint(0xFF.uint8)[0]) == (255.uint32, 2)

  doAssert varint([0xFF.uint8, 0xFF, 0xFF, 0xFF, 0xFF]) == (0.uint32, 0) # Overflows
  doAssert varint([0xFF.uint8]) == (0.uint32, 0) # Invalid encoding
  doAssert varint([]) == (0.uint32, 0) # Invalid encoding

block baddata:
  for i in 1 .. 3:
    try:
      discard uncompress(readFile(&"tests/data/baddata{i}.snappy"))
      quit("Should fail on bad data")
    except:
      discard

const files = [
  "alice29.txt",
  "asyoulik.txt",
  "fireworks.jpg",
  "geo.protodata",
  "html",
  "html_x_4",
  "kppkn.gtb",
  "lcet10.txt",
  "paper-100k.pdf",
  "plrabn12.txt",
  "urls.10K",
  "tor-list.gold"
]

for file in files:
  let
    original = readFile(&"tests/data/{file}")
    compressed = compress(original)
    uncompressed = uncompress(compressed)
  doAssert uncompressed == original, &"Uncompressed != original for {file}"

var reuseCompressed, reuseUncompressed: seq[uint8]
for file in files:
  let original = cast[seq[uint8]](readFile(&"tests/data/{file}"))
  compress(original, reuseCompressed)
  uncompress(reuseCompressed, reuseUncompressed)
  doAssert reuseUncompressed == original, &"Uncompressed != original for {file}"
