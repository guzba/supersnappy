import supersnappy

const
  test1Path = "tests/data/alice29.txt"
  test1 = block:
    let
      original = readFile(test1Path)
      compressed = compress(original)
      uncompressed = uncompress(compressed)
    doAssert uncompressed == original
    compressed

  # test2Seq = @[0.uint8, 8, 8, 8, 3, 8, 3, 3, 1, 1]
  # test2 = block:
  #   let
  #     compressed = compress(test2Seq)
  #     uncompressed = uncompress(compressed)
  #   doAssert uncompressed == test2Seq
  #   compressed

doAssert uncompress(test1) == readFile(test1Path)
# doAssert uncompress(test2) == test2Seq
