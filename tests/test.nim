import strformat, supersnappy, supersnappy/internal

block:
  var dst: string
  dst.addVarint(0)
  doAssert dst == "\0"
  doAssert varint(dst.toOpenArrayByte(0, dst.high)) == (0.uint32, 1)

block:
  var dst: string
  dst.addVarint(64)
  doAssert dst == &"{0x40.char}"
  doAssert varint(dst.toOpenArrayByte(0, dst.high)) == (64.uint32, 1)

block:
  var dst: string
  dst.addVarint(2097150)
  doAssert dst == &"{0xFE.char}{0xFF.char}{0x7F.char}"
  doAssert varint(dst.toOpenArrayByte(0, dst.high)) == (2097150.uint32, 3)

block:
  var dst: string
  dst.addVarint(uint32.high)
  doAssert dst == &"{0xFF.char}{0xFF.char}{0xFF.char}{0xFF.char}{0x0F.char}"
  doAssert varint(dst.toOpenArrayByte(0, dst.high)) == (uint32.high, 5)

block:
  var dst: string
  dst.addVarint(0xFF.uint8)
  doAssert dst == &"{0xFF.char}{0x01.char}"
  doAssert varint(dst.toOpenArrayByte(0, dst.high)) == (255.uint32, 2)

block:
  let src = &"{0xFF.char}{0xFF.char}{0xFF.char}{0xFF.char}{0xFF.char}"
  doAssert varint(src.toOpenArrayByte(0, src.high)) == (0.uint32, 0) # Overflows

block:
  let src = &"{0xFF.char}"
  doAssert varint(src.toOpenArrayByte(0, src.high)) == (0.uint32, 0) # Invalid encoding

block:
  let src = ""
  doAssert varint(src.toOpenArrayByte(0, src.high)) == (0.uint32, 0) # Invalid encoding

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
