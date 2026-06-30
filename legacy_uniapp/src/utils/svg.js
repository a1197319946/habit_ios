const b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
const btoaPolyfill = function(str) {
  let out = '', i = 0, len = str.length;
  while (i < len) {
    let c1 = str.charCodeAt(i++) & 0xff;
    if (i == len) { out += b64chars.charAt(c1 >> 2) + b64chars.charAt((c1 & 0x3) << 4) + '=='; break; }
    let c2 = str.charCodeAt(i++);
    if (i == len) { out += b64chars.charAt(c1 >> 2) + b64chars.charAt(((c1 & 0x3) << 4) | ((c2 & 0xf0) >> 4)) + b64chars.charAt((c2 & 0xf) << 2) + '='; break; }
    let c3 = str.charCodeAt(i++);
    out += b64chars.charAt(c1 >> 2) + b64chars.charAt(((c1 & 0x3) << 4) | ((c2 & 0xf0) >> 4)) + b64chars.charAt(((c2 & 0xf) << 2) | ((c3 & 0xc0) >> 6)) + b64chars.charAt(c3 & 0x3f);
  }
  return out;
};

export const getSvgDataUri = (pathData, colorHex) => {
  if (!pathData) pathData = 'M0 0h24v24H0z';
  let color = colorHex || '#ffffff';
  if (!color.startsWith('#')) {
    color = '#' + color;
  }
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24"><path d="${pathData}" fill="${color}"/></svg>`;
  
  let base64 = '';
  try {
    base64 = typeof window !== 'undefined' && window.btoa ? window.btoa(svg) : btoaPolyfill(svg);
  } catch(e) {
    base64 = btoaPolyfill(svg);
  }
  
  return 'data:image/svg+xml;base64,' + base64;
};
