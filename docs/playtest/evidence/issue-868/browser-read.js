/**
 * PNG readback helpers for the #868 graphical runs, loaded by the browser.
 *
 * The run serves this file and the game export from the same origin and imports
 * it from an evaluated module, so PNG decoding uses the browser's own decoder
 * (`createImageBitmap`) instead of a hand-written zlib reader.
 *
 * Tile-colour and box-reading rules are unchanged from the previous run's
 * `png.mjs`, which is kept beside it as the record of the first attempt.
 */

// The painted checkerboard's two tile colours on this build: a warm light tile
// (beige) and a warm dark tile (brown). Both are matched by hue, not luminance,
// so the page's dark banner above and below the board is not counted.
export const isLightTile = (r, g, b) => r > 225 && g > 200 && g < 235 && b > 160 && b < 205;
export const isDarkTile = (r, g, b) => r > 75 && r < 130 && g > 45 && g < 95 && b > 30 && b < 80;

const px = (img, x, y) => {
  const d = (y * img.width + x) * 4;
  return [img.rgba[d], img.rgba[d + 1], img.rgba[d + 2]];
};

/** Tile-coloured bounds of the painted board, in CSS px. */
export function boardRect(img, dpr = 1) {
  let minX = Infinity; let maxX = -1; let minY = Infinity; let maxY = -1;
  for (let y = 0; y < img.height; y++) {
    for (let x = 0; x < img.width; x++) {
      const [r, g, b] = px(img, x, y);
      if (isLightTile(r, g, b) || isDarkTile(r, g, b)) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }
  if (maxX < 0) return null;
  const left = (minX + 0.5) / dpr;
  const right = (maxX + 0.5) / dpr;
  const top = (minY + 0.5) / dpr;
  const bottom = (maxY + 0.5) / dpr;
  return { left, right, top, bottom, square: (right - left) / 8, lightFirst: true, dpr };
}

/** Mean colour of a small box, in CSS px. */
export function meanColour(img, dpr, cx, cy, cssRadius) {
  const r = Math.round(cssRadius * dpr);
  const sx = Math.round(cx * dpr);
  const sy = Math.round(cy * dpr);
  const acc = [0, 0, 0];
  let n = 0;
  for (let y = sy - r; y <= sy + r; y++) {
    for (let x = sx - r; x <= sx + r; x++) {
      if (x < 0 || y < 0 || x >= img.width || y >= img.height) continue;
      const [rr, gg, bb] = px(img, x, y);
      acc[0] += rr; acc[1] += gg; acc[2] += bb;
      n += 1;
    }
  }
  return n ? acc.map((value) => Math.round(value / n)) : null;
}

/**
 * Ink profile of a box: the share of pixels that are neither tile colour, the
 * mean brightness of that ink (white roles are bright, black roles are near
 * black), and whether any ink is present. A square with a piece has ink; an
 * empty square of the right colour has none.
 */
export function inkInBox(img, dpr, cx, cy, cssRadius) {
  const r = Math.round(cssRadius * dpr);
  const sx = Math.round(cx * dpr);
  const sy = Math.round(cy * dpr);
  let ink = 0;
  let n = 0;
  let sum = 0;
  for (let y = sy - r; y <= sy + r; y++) {
    for (let x = sx - r; x <= sx + r; x++) {
      if (x < 0 || y < 0 || x >= img.width || y >= img.height) continue;
      n += 1;
      const [rr, gg, bb] = px(img, x, y);
      if (isLightTile(rr, gg, bb) || isDarkTile(rr, gg, bb)) continue;
      ink += 1;
      sum += 0.299 * rr + 0.587 * gg + 0.114 * bb;
    }
  }
  return {
    inkShare: n ? Number((ink / n).toFixed(3)) : 0,
    inkBrightness: ink ? Math.round(sum / ink) : 0,
    inked: ink / Math.max(n, 1) > 0.12,
  };
}
