import strformat, supersnappy, supersnappy/internal

block varint:
  doAssert varint(0) == "\0"
  doAssert varint(64) == &"{0x40.char}"
  doAssert varint(2097150) == &"{0xFE.char}{0xFF.char}{0x7F.char}"
  doAssert varint(uint32.high) ==
    &"{0xFF.char}{0xFF.char}{0xFF.char}{0xFF.char}{0x0F.char}"
  doAssert varint(0xFF.uint8) == &"{0xFF.char}{0x01.char}"

  doAssert varint(varint(0)) == (0.uint32, 1)
  doAssert varint(varint(64)) == (64.uint32, 1)
  doAssert varint(varint(2097150)) == (2097150.uint32, 3)
  doAssert varint(varint(uint32.high)) == (uint32.high, 5)
  doAssert varint(varint(0xFF.uint8)) == (255.uint32, 2)

  doAssert varint(&"{0xFF.char}{0xFF.char}{0xFF.char}{0xFF.char}{0xFF.char}") ==
    (0.uint32, 0) # Overflows
  doAssert varint(&"{0xFF.char}") == (0.uint32, 0) # Invalid encoding
  doAssert varint("") == (0.uint32, 0) # Invalid encoding

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

var reuseCompressed, reuseUncompressed: string
for file in files:
  let original = readFile(&"tests/data/{file}")
  compress(reuseCompressed, original)
  uncompress(reuseUncompressed, reuseCompressed)
  doAssert reuseUncompressed == original, &"Uncompressed != original for {file}"
