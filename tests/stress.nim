import random, supersnappy, times

# Generate random blobs of data containing runs of random lengths. Ensure
# we can always compress this blob and that uncompressing the compressed
# data matches the original blob.

let seed = epochTime().int
var r = initRand(seed)

for i in 0 ..< 10000:
  echo "Test ", i, " (seed ", seed, ")"

  var
    data: string
    length = r.rand(100000)
    i: int
  data.setLen(length)
  while i < length:
    let
      v = r.rand(255).char
      runLength = min(r.rand(255), length - i)
    for j in 0 ..< runLength:
      data[i + j] = v
    inc(i, runLength)

  var shuffled = data # Copy
  r.shuffle(shuffled)

  template fuzz() =
    try:
      let
        pos = r.rand(compressed.len - 1)
        value = r.rand(255).char
      compressed[pos] = value
      doAssert uncompress(compressed).len > 0
    except SnappyError:
      discard

  block: # data
    var
      compressed = compress(data)
      uncompressed = uncompress(compressed)
    doAssert uncompressed == data
    fuzz()
  block: # shuffled
    var
      compressed = compress(shuffled)
      uncompressed = uncompress(compressed)
    doAssert uncompressed == shuffled
    fuzz()
