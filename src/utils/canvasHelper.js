export function drawRoundRect(ctx, x, y, w, h, r) {
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.lineTo(x + w - r, y);
  ctx.arc(x + w - r, y + r, r, 1.5 * Math.PI, 2 * Math.PI);
  ctx.lineTo(x + w, y + h - r);
  ctx.arc(x + w - r, y + h - r, r, 0, 0.5 * Math.PI);
  ctx.lineTo(x + r, y + h);
  ctx.arc(x + r, y + h - r, r, 0.5 * Math.PI, 1 * Math.PI);
  ctx.lineTo(x, y + r);
  ctx.arc(x + r, y + r, r, 1 * Math.PI, 1.5 * Math.PI);
  ctx.closePath();
}
