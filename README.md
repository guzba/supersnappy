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
alice29.txt ........................ 5.058 ms      5.080 ms    ±0.013   x983
asyoulik.txt ....................... 4.480 ms      4.498 ms    ±0.009  x1000
fireworks.jpg ...................... 0.167 ms      0.169 ms    ±0.003  x1000
geo.protodata ...................... 1.013 ms      1.027 ms    ±0.008  x1000
html ............................... 1.195 ms      1.213 ms    ±0.006  x1000
html_x_4 ........................... 5.205 ms      5.227 ms    ±0.010   x957
kppkn.gtb .......................... 4.149 ms      4.161 ms    ±0.008  x1000
lcet10.txt ........................ 13.581 ms     13.605 ms    ±0.015   x368
paper-100k.pdf ..................... 0.426 ms      0.429 ms    ±0.002  x1000
plrabn12.txt ...................... 18.778 ms     18.807 ms    ±0.032   x266
urls.10K .......................... 15.561 ms     15.614 ms    ±0.030   x321
https://github.com/dfdeshom/nimsnappy
alice29.txt ........................ 5.958 ms      5.984 ms    ±0.018   x835
asyoulik.txt ....................... 5.298 ms      5.327 ms    ±0.019   x938
fireworks.jpg ...................... 0.139 ms      0.141 ms    ±0.002  x1000
geo.protodata ...................... 1.024 ms      1.037 ms    ±0.009  x1000
html ............................... 1.188 ms      1.204 ms    ±0.011  x1000
html_x_4 ........................... 5.569 ms      5.598 ms    ±0.019   x893
kppkn.gtb .......................... 5.193 ms      5.213 ms    ±0.012   x959
lcet10.txt ........................ 15.961 ms     15.996 ms    ±0.018   x313
paper-100k.pdf ..................... 0.198 ms      0.201 ms    ±0.002  x1000
plrabn12.txt ...................... 22.291 ms     22.355 ms    ±0.069   x224
urls.10K .......................... 18.388 ms     18.433 ms    ±0.037   x272
https://github.com/NimCompression/nimsnappyc
alice29.txt ........................ 6.099 ms      6.137 ms    ±0.030   x813
asyoulik.txt ....................... 5.182 ms      5.214 ms    ±0.015   x959
fireworks.jpg ...................... 0.176 ms      0.178 ms    ±0.002  x1000
geo.protodata ...................... 1.480 ms      1.529 ms    ±0.019  x1000
html ............................... 1.715 ms      1.771 ms    ±0.018  x1000
html_x_4 ........................... 7.073 ms      7.159 ms    ±0.031   x698
kppkn.gtb .......................... 5.154 ms      5.194 ms    ±0.033   x961
lcet10.txt ........................ 16.633 ms     16.661 ms    ±0.011   x301
paper-100k.pdf ..................... 0.510 ms      0.515 ms    ±0.005  x1000
plrabn12.txt ...................... 20.793 ms     20.868 ms    ±0.076   x240
urls.10K .......................... 18.896 ms     18.984 ms    ±0.057   x264
https://github.com/jangko/snappy
alice29.txt ........................ 9.903 ms      9.947 ms    ±0.027   x502
asyoulik.txt ....................... 8.466 ms      8.502 ms    ±0.026   x588
fireworks.jpg ...................... 0.238 ms      0.245 ms    ±0.006  x1000
geo.protodata ...................... 2.888 ms      2.916 ms    ±0.035  x1000
html ............................... 2.992 ms      3.015 ms    ±0.031  x1000
html_x_4 .......................... 12.076 ms     12.108 ms    ±0.025   x413
kppkn.gtb .......................... 8.191 ms      8.222 ms    ±0.017   x608
lcet10.txt ........................ 26.579 ms     26.652 ms    ±0.068   x188
paper-100k.pdf ..................... 0.511 ms      0.529 ms    ±0.006  x1000
plrabn12.txt ...................... 33.952 ms     34.043 ms    ±0.076   x147
urls.10K .......................... 31.260 ms     31.366 ms    ±0.185   x160
```

## Testing
`nimble test`

To prevent Supersnappy from causing a crash or otherwise misbehaving on bad input data, a fuzzer has been run against it. You can do run the fuzzer any time by running `nim c -r tests/fuzz.nim`

## Credits

This implementation was heavily influenced by [snappy-c](https://github.com/andikleen/snappy-c).
