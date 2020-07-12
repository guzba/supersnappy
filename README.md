# Supersnappy

Supersnappy is a pure Nim implementation of [Google's Snappy](https://github.com/google/snappy) compression algorithm. The goal of this library is to be small, straightforward, dependency-free and highly performant.

Supersnappy works well using Nim's relatively new `--gc:arc` and `--gc:orc` as well as the default garbage collector. This library also works using both `nim c` and `nim cpp`, in addition to `--cc:vcc` on Windows.

### Performance

Benchmarks can be run comparing different Snappy implementations. My benchmarking shows this library performs significantly better in all cases than alternatives. Check the performance yourself by running [tests/benchmark.nim](https://github.com/guzba/supersnappy/blob/master/tests/benchmark.nim).

`nim c --gc:arc -d:release -r .\tests\benchmark.nim ` (1000 compress-uncompress cycles, lower time is better)

**https://github.com/guzba/supersnappy** results:

File | Time
--- | ---:
alice29.txt | 0.6039s
asyoulik.txt | 0.5306s
fireworks.jpg | 0.0213s
geo.protodata | 0.1473s
html | 0.1594s
html_x_4 | 0.6427s
kppkn.gtb | 0.4949s
lcet10.txt | 1.6042s
paper-100k.pdf | 0.0656s
plrabn12.txt | 2.1893s
urls.10K | 1.8366s

https://github.com/jangko/snappy results:

File | Time
--- | ---:
alice29.txt | 2.1374s
asyoulik.txt | 1.8228s
fireworks.jpg | 0.0333s
geo.protodata | 0.6090s
html | 0.6099s
html_x_4 | 2.4634s
kppkn.gtb | 1.6288s
lcet10.txt | 5.6983s
paper-100k.pdf | 0.0905s
plrabn12.txt | 7.3254s
urls.10K | 7.9783s


https://github.com/NimCompression/nimsnappyc results:

File | Time
--- | ---:
alice29.txt | 0.7838s
asyoulik.txt | 0.6805s
fireworks.jpg | 0.0250s
geo.protodata | 0.2246s
html | 0.2408s
html_x_4 | 0.9641s
kppkn.gtb | 0.6498s
lcet10.txt | 2.1042s
paper-100k.pdf | 0.0879s
plrabn12.txt | 2.6987s
urls.10K | 2.5136s

### Testing
`nimble test`

### Credits

This implementation was heavily influenced by [snappy-c](https://github.com/andikleen/snappy-c).

# API: supersnappy

```nim
import supersnappy
```

## **type** SnappyException

Raised if an operation fails.

```nim
SnappyException = object of ValueError
```

## **func** uncompress

Uncompresses src into dst. This resizes dst as needed and starts writing at dst index 0.

```nim
func uncompress(src: openArray[uint8]; dst: var seq[uint8]) {.raises: [SnappyException].}
```

## **func** uncompress

Uncompresses src and returns the uncompressed data seq.

```nim
func uncompress(src: openArray[uint8]): seq[uint8] {.inline, raises: [SnappyException].}
```

## **func** compress

Compresses src into dst. This resizes dst as needed and starts writing at dst index 0.

```nim
func compress(src: openArray[uint8]; dst: var seq[uint8]) {.raises: [SnappyException], tags: [].}
```

## **func** compress

Compresses src and returns the compressed data seq.

```nim
func compress(src: openArray[uint8]): seq[uint8] {.inline, raises: [SnappyException], tags: [].}
```

## **template** uncompress


```nim
template uncompress(src: string): string
```

## **template** compress


```nim
template compress(src: string): string
```
