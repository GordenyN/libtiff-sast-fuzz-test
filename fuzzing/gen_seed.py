import struct
def u16(v): return struct.pack('<H', v)
def u32(v): return struct.pack('<I', v)
header = b'II' + u16(42) + u32(8)
entries = [
    (256, 3, 1, 1),
    (257, 3, 1, 1),
    (258, 3, 1, 8),
    (259, 3, 1, 1),
    (262, 3, 1, 1),
    (278, 3, 1, 1),
    (279, 4, 1, 1),
    (273, 4, 1, 158),
]
ifd = u16(len(entries))
for tag, t, c, v in entries:
    ifd += u16(tag) + u16(t) + u32(c) + u32(v)
ifd += u32(0)
with open('/fuzz/seeds/minimal.tif', 'wb') as f:
    f.write(header + ifd + b'\x00')
print('Seed TIFF generated')
