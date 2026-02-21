const fs = require('fs');
const csv = fs.readFileSync('初級1671 - コピー.csv', 'utf-8');
const lines = csv.trim().split(/\r?\n/).filter(l => l.trim());
const words = lines.map(l => {
  const idx = l.indexOf(',');
  return { ko: l.substring(0, idx), ja: l.substring(idx + 1) };
});

const groupSize = 40;
const groups = [];
for (let i = 0; i < words.length; i += groupSize) {
  const groupNum = Math.floor(i / groupSize) + 1;
  const chunk = words.slice(i, i + groupSize);
  groups.push({ id: groupNum, name: 'グループ' + groupNum + ' (' + chunk.length + '語)', words: chunk });
}

let js = '// 初級韓国語 全' + words.length + '語データ\n';
js += '// ' + groups.length + 'グループ（各' + groupSize + '語）\n';
js += 'const groupsData = [\n';
groups.forEach((g, gi) => {
  js += '  {\n';
  js += '    id: ' + g.id + ',\n';
  js += '    name: "' + g.name + '",\n';
  js += '    words: [\n';
  g.words.forEach((w, wi) => {
    const koEsc = w.ko.replace(/"/g, '\\"');
    const jaEsc = w.ja.replace(/"/g, '\\"');
    js += '      { ko: "' + koEsc + '", ja: "' + jaEsc + '" }' + (wi < g.words.length - 1 ? ',' : '') + '\n';
  });
  js += '    ]\n';
  js += '  }' + (gi < groups.length - 1 ? ',' : '') + '\n';
});
js += '];\n';

fs.writeFileSync('data.js', js, 'utf-8');
console.log('Generated data.js: ' + words.length + ' words, ' + groups.length + ' groups');
