const https = require('https');
const fs = require('fs');

const mdiIcons = [
  'run', 'dumbbell', 'bike', 'swim', 'yoga', 'jump-rope', 'glass-water', 'food-apple', 'bed', 'pill', 'heart-pulse', 'scale-bathroom',
  'book-open-page-variant', 'book-education', 'pencil', 'school', 'brain', 'lightbulb-on', 'briefcase', 'laptop', 'code-tags', 'calculator', 'chart-bar', 'piggy-bank',
  'meditation', 'guitar-acoustic', 'palette', 'music', 'camera', 'controller-classic', 'cart', 'cash', 'broom', 'washing-machine', 'dog', 'white-balance-sunny',
  'emoticon-happy', 'emoticon-neutral', 'emoticon', 'emoticon-sad', 'emoticon-cry'
];

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

const getSvgBase64 = (pathData, color) => {
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24"><path d="${pathData}" fill="${color}"/></svg>`;
  return 'data:image/svg+xml;base64,' + btoaPolyfill(svg);
};

const fetchSvgPath = (icon) => {
  return new Promise((resolve, reject) => {
    https.get(`https://cdn.jsdelivr.net/npm/@mdi/svg@7.4.47/svg/${icon}.svg`, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        const match = data.match(/d="([^"]+)"/);
        if (match) {
          resolve(match[1]);
        } else {
          resolve('M0 0h24v24H0z');
        }
      });
    }).on('error', reject);
  });
};

async function build() {
  const whiteIcons = {};
  const grayIcons = {};
  const primaryIcons = {}; // For primary colored icons (e.g., mood)
  for (const icon of mdiIcons) {
    try {
      const pathData = await fetchSvgPath(icon);
      whiteIcons[icon] = getSvgBase64(pathData, '#ffffff');
      grayIcons[icon] = getSvgBase64(pathData, '#94A3B8');
      primaryIcons[icon] = getSvgBase64(pathData, '#4F46E5'); // Default primary color
      console.log('Processed ' + icon);
    } catch(e) {
      whiteIcons[icon] = getSvgBase64('M0 0h24v24H0z', '#ffffff');
      grayIcons[icon] = getSvgBase64('M0 0h24v24H0z', '#94A3B8');
      primaryIcons[icon] = getSvgBase64('M0 0h24v24H0z', '#4F46E5');
    }
  }
  
  // Filter out the mood icons from the general iconsList
  const habitIcons = mdiIcons.filter(i => !i.startsWith('emoticon'));
  
  const content = `// Auto-generated MDI Icons Base64
export const iconsWhite = ${JSON.stringify(whiteIcons, null, 2)};
export const iconsGray = ${JSON.stringify(grayIcons, null, 2)};
export const iconsPrimary = ${JSON.stringify(primaryIcons, null, 2)};
export const iconsList = ${JSON.stringify(habitIcons, null, 2)};
`;
  fs.writeFileSync('src/utils/icons.js', content);
  console.log('Saved to src/utils/icons.js');
}

build();
