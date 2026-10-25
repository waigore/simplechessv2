// Minimal PNG decoder (RGB/RGBA, 8-bit, non-interlaced) for measuring board geometry.
import zlib from 'node:zlib';
import fs from 'node:fs';
export function readPng(path) {
  const d = fs.readFileSync(path);
  let i = 8, w = 0, h = 0, ct = 0, idat = [];
  while (i < d.length) {
    const ln = d.readUInt32BE(i); const typ = d.toString('ascii', i + 4, i + 8);
    const data = d.subarray(i + 8, i + 8 + ln); i += 12 + ln;
    if (typ === 'IHDR') { w = data.readUInt32BE(0); h = data.readUInt32BE(4); ct = data[9]; }
    else if (typ === 'IDAT') idat.push(data);
    else if (typ === 'IEND') break;
  }
  const raw = zlib.inflateSync(Buffer.concat(idat));
  const ch = { 0: 1, 2: 3, 4: 2, 6: 4 }[ct]; const stride = w * ch;
  const out = Buffer.alloc(w * h * ch); let p = 0;
  for (let y = 0; y < h; y++) {
    const f = raw[p++]; const line = Buffer.from(raw.subarray(p, p + stride)); p += stride;
    const prev = y ? out.subarray((y - 1) * stride, y * stride) : Buffer.alloc(stride);
    for (let x = 0; x < stride; x++) {
      const a = x >= ch ? line[x - ch] : 0; const b = prev[x]; const c = x >= ch ? prev[x - ch] : 0;
      if (f === 1) line[x] = (line[x] + a) & 255;
      else if (f === 2) line[x] = (line[x] + b) & 255;
      else if (f === 3) line[x] = (line[x] + ((a + b) >> 1)) & 255;
      else if (f === 4) { const pp = a + b - c, pa = Math.abs(pp - a), pb = Math.abs(pp - b), pc = Math.abs(pp - c);
        line[x] = (line[x] + (pa <= pb && pa <= pc ? a : pb <= pc ? b : c)) & 255; }
    }
    line.copy(out, y * stride);
  }
  return { w, h, ch, px: out, at: (x, y) => { const o = (y * w + x) * ch; return [out[o], out[o + 1], out[o + 2]]; } };
}
// Board content rect: the darkest brown square colour is the anchor (first square a8..).
export function boardRect(img) {
  // Light-square colour measured from a shared-play capture. Near-white text is
  // excluded by the red ceiling, and the page bg differs on all three channels.
  const isBrown = ([r, g, b]) => Math.abs(r - 232) <= 3 && Math.abs(g - 213) <= 3 && Math.abs(b - 181) <= 3;
  let x0 = img.w, x1 = -1, y0 = img.h, y1 = -1;
  for (let y = 0; y < img.h; y += 2) for (let x = 0; x < img.w; x += 2) {
    if (isBrown(img.at(x, y))) { if (x < x0) x0 = x; if (x > x1) x1 = x; if (y < y0) y0 = y; if (y > y1) y1 = y; }
  }
  return { x0, y0, x1, y1, size: x1 - x0 + 1, height: y1 - y0 + 1 };
}
// CSS centre of a square for a white-bottom seat, given the device-pixel rect and scale.
export function squareCenterCss(rect, scale, name) {
  const file = name.charCodeAt(0) - 97, rank = Number(name[1]);
  const sq = rect.size / 8 / scale;
  return { x: rect.x0 / scale + sq * (file + 0.5), y: rect.y0 / scale + sq * (8 - rank + 0.5), squareCss: +sq.toFixed(2) };
}
