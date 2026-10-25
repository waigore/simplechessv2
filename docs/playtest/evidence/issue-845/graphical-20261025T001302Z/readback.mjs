import { decodePng } from './png.mjs';
import { boardRect } from './board.mjs';

const FILES = 'abcdefgh';
const INK = [253, 253, 252];

function centre(grid, square) {
  const file = FILES.indexOf(square[0]);
  const rank = Number(square[1]);
  return {
    x: grid.left + (file + 0.5) * grid.square,
    y: grid.bottom - (rank - 0.5) * grid.square,
  };
}

function isInk(image, dpr, x, y) {
  const px = image.at(Math.round(x * dpr), Math.round(y * dpr));
  return Math.abs(px[0] - INK[0]) <= 2 && Math.abs(px[1] - INK[1]) <= 2 && Math.abs(px[2] - INK[2]) <= 2;
}

export function pieceSquares(file, dpr = 2) {
  const image = decodePng(file);
  const grid = boardRect(image, dpr);
  const hits = [];
  for (const f of FILES) {
    for (let rank = 1; rank <= 8; rank++) {
      const sq = `${f}${rank}`;
      const at = centre(grid, sq);
      let ink = 0;
      for (const dx of [-0.2, 0, 0.2]) {
        for (const dy of [-0.2, 0, 0.2]) {
          if (isInk(image, dpr, at.x + dx * grid.square, at.y + dy * grid.square)) ink++;
        }
      }
      if (ink >= 3) hits.push(sq);
    }
  }
  return hits;
}

export function headerSide(file, dpr = 2) {
  const image = decodePng(file);
  let minX = Infinity;
  for (let y = 9 * dpr; y < 30 * dpr; y++) {
    for (let x = 0; x < image.width; x++) {
      const px = image.at(x, y);
      if (px[0] < 120 && px[1] < 120 && px[2] < 120 && x < minX) minX = x;
    }
  }
  return minX === Infinity ? '' : minX / dpr < 121 ? 'white' : 'black';
}
