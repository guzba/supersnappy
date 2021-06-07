import supersnappy, nimsnappyc, snappy, strformat

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

# import nimsnappy # Requires libsnappy.dll
# block dfdeshom_nimsnappy:
#   echo "https://github.com/dfdeshom/nimsnappy"
#   for file in files:
#     let original = readFile(&"tests/data/{file}")
#     doAssert nimsnappy.uncompress(supersnappy.compress(original)) == original
#     doassert supersnappy.uncompress(nimsnappy.compress(original)) == original
#   echo "pass!"

block nimcompression_nimsnappyc:
  echo "https://github.com/NimCompression/nimsnappyc"
  for file in files:
    let original = readFile(&"tests/data/{file}")
    doAssert nimsnappyc.snappyUncompress(
      supersnappy.compress(original)
    ) == original
    doassert supersnappy.uncompress(
      nimsnappyc.snappyCompress(original)
    ) == original
  echo "pass!"

block jangko_snappy:
  echo "https://github.com/jangko/snappy"
  for file in files:
    let original = cast[seq[uint8]](readFile(&"tests/data/{file}"))
    doAssert snappy.decode(supersnappy.compress(original)) == original
    doassert supersnappy.uncompress(snappy.encode(original)) == original
  echo "pass!"
