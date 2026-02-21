import csv
import os

csv_path = os.path.join(os.path.dirname(__file__), '初級1671 - コピー.csv')
out_path = os.path.join(os.path.dirname(__file__), 'data.js')

words = []
with open(csv_path, 'r', encoding='utf-8') as f:
    reader = csv.reader(f)
    for row in reader:
        if len(row) >= 2 and row[0].strip():
            words.append((row[0].strip(), row[1].strip()))

group_size = 40
groups = []
for i in range(0, len(words), group_size):
    gnum = i // group_size + 1
    chunk = words[i:i+group_size]
    groups.append((gnum, chunk))

lines = []
lines.append(f'// 初級韓国語 全{len(words)}語データ')
lines.append(f'// {len(groups)}グループ（各{group_size}語）')
lines.append('const groupsData = [')

for gi, (gid, gwords) in enumerate(groups):
    lines.append('  {')
    lines.append(f'    id: {gid},')
    gname = f'グループ{gid} ({len(gwords)}語)'
    lines.append(f'    name: "{gname}",')
    lines.append('    words: [')
    for wi, (ko, ja) in enumerate(gwords):
        ko_esc = ko.replace('\\', '\\\\').replace('"', '\\"')
        ja_esc = ja.replace('\\', '\\\\').replace('"', '\\"')
        comma = ',' if wi < len(gwords) - 1 else ''
        lines.append(f'      {{ ko: "{ko_esc}", ja: "{ja_esc}" }}{comma}')
    lines.append('    ]')
    comma = ',' if gi < len(groups) - 1 else ''
    lines.append(f'  }}{comma}')

lines.append('];')
lines.append('')

with open(out_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))

print(f'Generated data.js: {len(words)} words, {len(groups)} groups')
