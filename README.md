Supersnappy is a pure Nim implementation of [Google's Snappy](https://github.com/google/snappy) compression algorithm. The goal of this library is to be small, straightforward, dependency-free and highly performant.

Tests and benchmarks can be run comparing different Snappy implementations. My benchmarking shows this library performs significantly better in all cases than alterantives. Verify the performance yourself by running [tests/benchmark.nim](https://github.com/guzba/supersnappy/blob/master/tests/benchmark.nim).

This implementation was heavily influenced by [snappy-c](https://github.com/andikleen/snappy-c).
