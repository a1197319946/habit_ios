const fs = require('fs');
const https = require('https');
const path = require('path');

const icons = [
  'running', 'dumbbell', 'cycling', 'swimming', 'yoga', 'jump-rope', 'water-glass', 'apple', 'sleeping-in-bed', 'pill', 'heart-with-pulse', 'scale',
  'book', 'reading', 'pencil', 'student-male', 'graduation-cap', 'idea', 'briefcase', 'macbook', 'code', 'calculator', 'combo-chart', 'money-bag',
  'meditation', 'guitar', 'paint-palette', 'music-record', 'camera', 'game-controller', 'shopping-cart', 'piggy-bank', 'broom', 'washing-machine', 'dog-walking', 'plant-under-sun'
];

const dir = path.join(__dirname, 'src', 'static', 'icons');
if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

const download = (url, dest) => {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      if (res.statusCode === 200) {
        const file = fs.createWriteStream(dest);
        res.pipe(file);
        file.on('finish', () => { file.close(); resolve(); });
      } else {
        reject(`Failed: ${res.statusCode} for ${url}`);
      }
    }).on('error', reject);
  });
};

async function run() {
  for (const icon of icons) {
    try {
      await download(`https://img.icons8.com/ios-filled/100/ffffff/${icon}.png`, path.join(dir, `${icon}_white.png`));
      await download(`https://img.icons8.com/ios-filled/100/94A3B8/${icon}.png`, path.join(dir, `${icon}_gray.png`));
      console.log(`Downloaded ${icon}`);
    } catch (e) {
      console.error(e);
    }
  }
}
run();
