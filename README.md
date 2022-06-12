# Supersnappy

![Github Actions](https://github.com/guzba/supersnappy/workflows/Github%20Actions/badge.svg)

`nimble install supersnappy`

Supersnappy is a pure Nim implementation of [Google's Snappy](https://github.com/google/snappy) compression algorithm. The goal of this library is to be small, straightforward, dependency-free and highly performant.

Supersnappy can be used at compile time too. This is great for baking assets into executables in compressed form. [Check out an example here](https://github.com/guzba/supersnappy/blob/master/examples/compiletime.nim).

To ensure Supersnappy is compatible with other Snappy implementations, `tests/validate.nim` can be run. This script verifies that data compressed by Supersnappy can be uncompressed by other implementations (and that other implementations can uncompress data compressed by Supersnappy).

Supersnappy works well using Nim's relatively new `--gc:arc` and `--gc:orc` as well as the default garbage collector. This library also works using both `nim c` and `nim cpp`, in addition to `--cc:vcc` on Windows.

I have also verified that Supersnappy builds with `--experimental:strictFuncs` on Nim 1.4.0.

## Docs

https://nimdocs.com/guzba/supersnappy/supersnappy.html

## Performance

Benchmarks can be run comparing different Snappy implementations. My benchmarking shows this library performs significantly better in all cases than alternatives. Check the performance yourself by running [tests/benchmark.nim](https://github.com/guzba/supersnappy/blob/master/tests/benchmark.nim).

`nim c --gc:arc -d:release -r .\tests\benchmark.nim` (100 compress-uncompress cycles, lower time is better)

```
https://github.com/guzba/supersnappy
name ............................... min time      avg time    std dv   runs
alice29.txt ........................ 0.504 ms      0.513 ms    ±0.020  x1000
asyoulik.txt ....................... 0.447 ms      0.451 ms    ±0.006  x1000
fireworks.jpg ...................... 0.013 ms      0.015 ms    ±0.001  x1000
geo.protodata ...................... 0.100 ms      0.106 ms    ±0.008  x1000
html ............................... 0.120 ms      0.128 ms    ±0.013  x1000
html_x_4 ........................... 0.524 ms      0.534 ms    ±0.014  x1000
kppkn.gtb .......................... 0.422 ms      0.435 ms    ±0.028  x1000
lcet10.txt ......................... 1.362 ms      1.380 ms    ±0.028  x1000
paper-100k.pdf ..................... 0.040 ms      0.041 ms    ±0.002  x1000
plrabn12.txt ....................... 1.885 ms      1.898 ms    ±0.020  x1000
urls.10K ........................... 1.565 ms      1.574 ms    ±0.009  x1000
https://github.com/dfdeshom/nimsnappy
alice29.txt ........................ 0.590 ms      0.599 ms    ±0.017  x1000
asyoulik.txt ....................... 0.525 ms      0.529 ms    ±0.005  x1000
fireworks.jpg ...................... 0.011 ms      0.011 ms    ±0.000  x1000
geo.protodata ...................... 0.100 ms      0.101 ms    ±0.002  x1000
html ............................... 0.118 ms      0.127 ms    ±0.017  x1000
html_x_4 ........................... 0.553 ms      0.559 ms    ±0.006  x1000
kppkn.gtb .......................... 0.517 ms      0.523 ms    ±0.009  x1000
lcet10.txt ......................... 1.585 ms      1.599 ms    ±0.018  x1000
paper-100k.pdf ..................... 0.017 ms      0.017 ms    ±0.000  x1000
plrabn12.txt ....................... 2.224 ms      2.237 ms    ±0.017  x1000
urls.10K ........................... 1.826 ms      1.842 ms    ±0.021  x1000
https://github.com/NimCompression/nimsnappyc
alice29.txt ........................ 0.605 ms      0.609 ms    ±0.004  x1000
asyoulik.txt ....................... 0.513 ms      0.518 ms    ±0.005  x1000
fireworks.jpg ...................... 0.014 ms      0.020 ms    ±0.004  x1000
geo.protodata ...................... 0.144 ms      0.150 ms    ±0.010  x1000
html ............................... 0.169 ms      0.172 ms    ±0.004  x1000
html_x_4 ........................... 0.701 ms      0.712 ms    ±0.009  x1000
kppkn.gtb .......................... 0.510 ms      0.515 ms    ±0.005  x1000
lcet10.txt ......................... 1.653 ms      1.666 ms    ±0.022  x1000
paper-100k.pdf ..................... 0.047 ms      0.049 ms    ±0.003  x1000
plrabn12.txt ....................... 2.073 ms      2.092 ms    ±0.024  x1000
urls.10K ........................... 1.873 ms      1.899 ms    ±0.028  x1000
https://github.com/status-im/nim-snappy
alice29.txt ........................ 0.609 ms      0.615 ms    ±0.005  x1000
asyoulik.txt ....................... 0.529 ms      0.536 ms    ±0.015  x1000
fireworks.jpg ...................... 0.010 ms      0.011 ms    ±0.001  x1000
geo.protodata ...................... 0.131 ms      0.135 ms    ±0.004  x1000
html ............................... 0.151 ms      0.156 ms    ±0.004  x1000
html_x_4 ........................... 0.647 ms      0.657 ms    ±0.016  x1000
kppkn.gtb .......................... 0.519 ms      0.523 ms    ±0.006  x1000
lcet10.txt ......................... 1.640 ms      1.650 ms    ±0.010  x1000
paper-100k.pdf ..................... 0.019 ms      0.020 ms    ±0.001  x1000
plrabn12.txt ....................... 2.232 ms      2.243 ms    ±0.011  x1000
urls.10K ........................... 1.796 ms      1.810 ms    ±0.023  x1000
```

## Testing
`nimble test`

To prevent Supersnappy from causing a crash or otherwise misbehaving on bad input data, a fuzzer has been run against it. You can do run the fuzzer any time by running `nim c -r tests/fuzz.nim`

## Credits

This implementation was heavily influenced by [snappy-c](https://github.com/andikleen/snappy-c).
