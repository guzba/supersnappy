import random, strformat, supersnappy

randomize()

const files = [
  "alice29.txt", "asyoulik.txt", "fireworks.jpg", "geo.protodata",
  "html", "html_x_4", "kppkn.gtb", "lcet10.txt", "paper-100k.pdf",
  "plrabn12.txt", "urls.10K"
]

for i in 0 ..< 10_000:
  let file = files[rand(files.len - 1)]
  var compressed = readFile(&"tests/data/{file}.snappy")
  let
    pos = rand(compressed.len - 1)
    value = rand(255).char
  compressed[pos] = value
  echo &"{i} {file} {pos} {value.uint8}"
  try:
    doAssert uncompress(compressed).len > 0
  except SnappyError:
    discard
