const https = require('https');
const fs = require('fs');

const mdiIcons = [
  'run', 'dumbbell', 'bike', 'swim', 'yoga', 'jump-rope', 'glass-water', 'food-apple', 'bed', 'pill', 'heart-pulse', 'scale-bathroom',
  'book-open-page-variant', 'book-education', 'pencil', 'school', 'brain', 'lightbulb-on', 'briefcase', 'laptop', 'code-tags', 'calculator', 'chart-bar', 'piggy-bank',
  'meditation', 'guitar-acoustic', 'palette', 'music', 'camera', 'controller-classic', 'cart', 'cash', 'broom', 'washing-machine', 'dog', 'white-balance-sunny'
];

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
          resolve('M0 0h24v24H0z'); // fallback empty path
        }
      });
    }).on('error', reject);
  });
};

async function build() {
  const paths = {};
  for (const icon of mdiIcons) {
    try {
      paths[icon] = await fetchSvgPath(icon);
      console.log('Fetched ' + icon);
    } catch(e) {
      console.error(e);
      paths[icon] = 'M0 0h24v24H0z';
    }
  }
  
  const content = `// Auto-generated MDI Icons Path Data
export const iconPaths = ${JSON.stringify(paths, null, 2)};
export const iconsList = Object.keys(iconPaths);
`;
  fs.writeFileSync('src/utils/icons.js', content);
  console.log('Saved to src/utils/icons.js');
}

build();
