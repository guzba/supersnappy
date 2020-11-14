# Supersnappy

`nimble install supersnappy`

Supersnappy is a pure Nim implementation of [Google's Snappy](https://github.com/google/snappy) compression algorithm. The goal of this library is to be small, straightforward, dependency-free and highly performant.

Supersnappy can be used at compile time too. This is great for baking assets into executables in compressed form. [Check out an example here](https://github.com/guzba/supersnappy/blob/master/examples/compiletime.nim).

To ensure Supersnappy is compatible with other Snappy implementations, `tests/validate.nim` can be run. This script verifies that data compressed by Supersnappy can be uncompressed by other implementations (and that other implementations can uncompress data compressed by Supersnappy).

Supersnappy works well using Nim's relatively new `--gc:arc` and `--gc:orc` as well as the default garbage collector. This library also works using both `nim c` and `nim cpp`, in addition to `--cc:vcc` on Windows.

I have also verified that Supersnappy builds with `--experimental:strictFuncs` on Nim 1.4.0.

## Performance

Benchmarks can be run comparing different Snappy implementations. My benchmarking shows this library performs significantly better in all cases than alternatives. Check the performance yourself by running [tests/benchmark.nim](https://github.com/guzba/supersnappy/blob/master/tests/benchmark.nim).

`nim c --gc:arc -d:release -r .\tests\benchmark.nim` (1000 compress-uncompress cycles, lower time is better)

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
urls.10K | 1.8146s

https://github.com/dfdeshom/nimsnappy (Google snappy wrapper) results:

File | Time
--- | ---:
alice29.txt | 0.7470s
asyoulik.txt | 0.6887s
fireworks.jpg | 0.0166s
geo.protodata | 0.1743s
html | 0.1909s
html_x_4 | 0.7702s
kppkn.gtb | 0.6481s
lcet10.txt | 1.9751s
paper-100k.pdf | 0.0258s
plrabn12.txt | 2.7316s
urls.10K | 2.3412s

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

https://github.com/jangko/snappy results:

File | Time
--- | ---:
alice29.txt | 1.3289s
asyoulik.txt | 1.1349s
fireworks.jpg | 0.0211s
geo.protodata | 0.4063s
html | 0.4076s
html_x_4 | 1.6339s
kppkn.gtb | 1.0701s
lcet10.txt | 3.5841s
paper-100k.pdf | 0.0638s
plrabn12.txt | 4.5476s
urls.10K | 4.4155s

## Testing
`nimble test`

To prevent Supersnappy from causing a crash or otherwise misbehaving on bad input data, a fuzzer has been run against it. You can do run the fuzzer any time by running `nim c -r tests/fuzz.nim`

## Credits

This implementation was heavily influenced by [snappy-c](https://github.com/andikleen/snappy-c).

# API: supersnappy

```nim
import supersnappy
```

## **type** SnappyError

Raised if an operation fails.

```nim
SnappyError = object of ValueError
```

## **func** uncompress

Uncompresses src into dst. This resizes dst as needed and starts writing at dst index 0.

```nim
func uncompress(src: openArray[uint8]; dst: var seq[uint8]) {.raises: [SnappyError].}
```

## **func** uncompress

Uncompresses src and returns the uncompressed data seq.

```nim
func uncompress(src: openArray[uint8]): seq[uint8] {.inline, raises: [SnappyError].}
```

## **func** compress

Compresses src into dst. This resizes dst as needed and starts writing at dst index 0.

```nim
func compress(src: openArray[uint8]; dst: var seq[uint8]) {.raises: [SnappyError].}
```

## **func** compress

Compresses src and returns the compressed data.

```nim
func compress(src: openArray[uint8]): seq[uint8] {.inline, raises: [SnappyError].}
```

## **template** uncompress


```nim
template uncompress(src: string): string
```

## **template** compress


```nim
template compress(src: string): string
```
