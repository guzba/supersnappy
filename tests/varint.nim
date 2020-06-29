include ../simplesnappy

assert varint(0) == ([0.uint8, 0, 0, 0, 0], 1)
assert varint(64) == ([0x40.uint8, 0, 0, 0, 0], 1)
assert varint(2097150) == ([0xFE.uint8, 0xFF, 0x7F, 0, 0], 3)
assert varint(high(uint32)) == ([0xFF.uint8, 0xFF, 0xFF, 0xFF, 0x0F], 5)
assert varint(0xFF.uint8) == ([0xFF.uint8, 0x01, 0, 0, 0], 2)

assert varint(varint(0)[0]) == (0.uint32, 1)
assert varint(varint(64)[0]) == (64.uint32, 1)
assert varint(varint(2097150)[0]) == (2097150.uint32, 3)
assert varint(varint(high(uint32))[0]) == (high(uint32), 5)
assert varint(varint(0xFF.uint8)[0]) == (255.uint32, 2)

assert varint([0xFF.uint8, 0xFF, 0xFF, 0xFF, 0xFF]) == (0.uint32, 0) # Overflows
assert varint([0xFF.uint8]) == (0.uint32, 0) # Invalid encoding
assert varint([]) == (0.uint32, 0) # Invalid encoding
