# Supersnappy

Supersnappy is a pure Nim implementation of [Google's Snappy](https://github.com/google/snappy) compression algorithm. The goal of this library is to be small, straightforward, dependency-free and highly performant.

Supersnappy works well using Nim's relatively new `--gc:arc` and `--gc:orc` as well as the default garbage collector. This library also works using both `nim c` and `nim cpp`, in addition to `--cc:vcc` on Windows.

### Performance

Benchmarks can be run comparing different Snappy implementations. My benchmarking shows this library performs significantly better in all cases than alternatives. Check the performance yourself by running [tests/benchmark.nim](https://github.com/guzba/supersnappy/blob/master/tests/benchmark.nim).

`nim c --gc:arc -d:release -r .\tests\benchmark.nim ` (1000 compress-uncompress cycles, lower time is better)

**https://github.com/guzba/supersnappy**
```
  alice29.txt: 0.6039s (compressed to 88017 bytes, 42.13% reduction)
  asyoulik.txt: 0.5306s (compressed to 77525 bytes, 38.07% reduction)
  fireworks.jpg: 0.0213s (compressed to 123034 bytes, 0.05% reduction)
  geo.protodata: 0.1473s (compressed to 23295 bytes, 80.36% reduction)
  html: 0.1594s (compressed to 22842 bytes, 77.69% reduction)
  html_x_4: 0.6427s (compressed to 92221 bytes, 77.49% reduction)
  kppkn.gtb: 0.4949s (compressed to 69526 bytes, 62.28% reduction)
  lcet10.txt: 1.6042s (compressed to 234392 bytes, 45.08% reduction)
  paper-100k.pdf: 0.0656s (compressed to 83817 bytes, 18.15% reduction)
  plrabn12.txt: 2.1893s (compressed to 319097 bytes, 33.78% reduction)
  urls.10K: 1.8366s (compressed to 335387 bytes, 52.23% reduction)
```
https://github.com/jangko/snappy
```
  alice29.txt: 2.1374s (compressed to 88034 bytes, 42.12% reduction)
  asyoulik.txt: 1.8228s (compressed to 77503 bytes, 38.09% reduction)
  fireworks.jpg: 0.0333s (compressed to 123034 bytes, 0.05% reduction)
  geo.protodata: 0.6090s (compressed to 23335 bytes, 80.32% reduction)
  html: 0.6099s (compressed to 22843 bytes, 77.69% reduction)
  html_x_4: 2.4634s (compressed to 92234 bytes, 77.48% reduction)
  kppkn.gtb: 1.6288s (compressed to 69526 bytes, 62.28% reduction)
  lcet10.txt: 5.6983s (compressed to 234661 bytes, 45.01% reduction)
  paper-100k.pdf: 0.0905s (compressed to 85304 bytes, 16.70% reduction)
  plrabn12.txt: 7.3254s (compressed to 319267 bytes, 33.74% reduction)
  urls.10K: 7.9783s (compressed to 335492 bytes, 52.22% reduction)
```
https://github.com/NimCompression/nimsnappyc
```
  alice29.txt: 0.7838s (compressed to 88017 bytes, 42.13% reduction)
  asyoulik.txt: 0.6805s (compressed to 77525 bytes, 38.07% reduction)
  fireworks.jpg: 0.0250s (compressed to 123034 bytes, 0.05% reduction)
  geo.protodata: 0.2246s (compressed to 23295 bytes, 80.36% reduction)
  html: 0.2408s (compressed to 22842 bytes, 77.69% reduction)
  html_x_4: 0.9641s (compressed to 92221 bytes, 77.49% reduction)
  kppkn.gtb: 0.6498s (compressed to 69526 bytes, 62.28% reduction)
  lcet10.txt: 2.1042s (compressed to 234392 bytes, 45.08% reduction)
  paper-100k.pdf: 0.0879s (compressed to 83817 bytes, 18.15% reduction)
  plrabn12.txt: 2.6987s (compressed to 319097 bytes, 33.78% reduction)
  urls.10K: 2.5136s (compressed to 335387 bytes, 52.23% reduction)
```

### Testing
`nimble test`

### Credits

This implementation was heavily influenced by [snappy-c](https://github.com/andikleen/snappy-c).
