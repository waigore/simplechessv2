/**
 * Dependency-free PNG reader: decode a Chrome screenshot to RGB(A) rows.
 *
 * Supports the 8-bit truecolour / truecolour-alpha PNGs Chrome emits.
 * Written for #845's capture so the run can read a selection ring's square
 * from pixels instead of by eye.
 */
import fs from 'node:fs';
import zlib from 'node:zlib';

export function decodePng(file) {
  const buffer = fs.readFileSync(file);
  let position = 8;
  let width = 0;
  let height = 0;
  let bitDepth = 0;
  let colorType = 0;
  const chunks = [];
  while (position < buffer.length) {
    const length = buffer.readUInt32BE(position);
    const type = buffer.toString('ascii', position + 4, position + 8);
    const data = buffer.subarray(position + 8, position + 8 + length);
    if (type === 'IHDR') {
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
      bitDepth = data[8];
      colorType = data[9];
    } else if (type === 'IDAT') {
      chunks.push(data);
    }
    position += 12 + length;
  }
  if (bitDepth !== 8 || (colorType !== 6 && colorType !== 2)) {
    throw new Error(`unsupported png ${bitDepth}/${colorType}`);
  }
  const bytesPerPixel = colorType === 6 ? 4 : 3;
  const raw = zlib.inflateSync(Buffer.concat(chunks));
  const stride = width * bytesPerPixel;
  const out = Buffer.alloc(height * stride);
  let previous = Buffer.alloc(stride);
  for (let y = 0; y < height; y++) {
    const filter = raw[y * (stride + 1)];
    const line = raw.subarray(y * (stride + 1) + 1, (y + 1) * (stride + 1));
    const current = Buffer.from(line);
    for (let i = 0; i < stride; i++) {
      const a = i >= bytesPerPixel ? current[i - bytesPerPixel] : 0;
      const b = previous[i];
      const c = i >= bytesPerPixel ? previous[i - bytesPerPixel] : 0;
      if (filter === 1) current[i] = (current[i] + a) & 255;
      else if (filter === 2) current[i] = (current[i] + b) & 255;
      else if (filter === 3) current[i] = (current[i] + ((a + b) >> 1)) & 255;
      else if (filter === 4) {
        const p = a + b - c;
        const pa = Math.abs(p - a);
        const pb = Math.abs(p - b);
        const pc = Math.abs(p - c);
        current[i] = (current[i] + (pa <= pb && pa <= pc ? a : pb <= pc ? b : c)) & 255;
      }
    }
    current.copy(out, y * stride);
    previous = current;
  }
  const at = (x, y) => {
    const offset = (y * width + x) * bytesPerPixel;
    return [out[offset], out[offset + 1], out[offset + 2]];
  };
  return { width, height, at };
}
