import os
import re

def parse_football():
    path = r'lib\models\cards.dart'
    if not os.path.exists(path): return {}
    content = open(path, 'r', encoding='utf-8').read()
    m = re.search(r'const Map<String, String> playerPortraitAssets = {(.*?)\n};', content, re.DOTALL)
    d = {}
    if m:
        for line in m.group(1).split('\n'):
            if ':' in line:
                k, v = line.split(':', 1)
                d[k.strip().strip("'")] = v.strip().strip(",").strip("'")
    return d

def parse_basketball():
    path = r'lib\data\basketball_portraits.dart'
    if not os.path.exists(path): return {}
    content = open(path, 'r', encoding='utf-8').read()
    m = re.search(r'const basketballPortraitAssets = <String, String>{(.*?)\n};', content, re.DOTALL)
    d = {}
    if m:
        for line in m.group(1).split('\n'):
            if ':' in line:
                k, v = line.split(':', 1)
                d[k.strip().strip("'")] = v.strip().strip(",").strip("'")
    return d

def parse_tennis():
    path = r'lib\data\tennis_portraits.dart'
    if not os.path.exists(path): return {}
    content = open(path, 'r', encoding='utf-8').read()
    m = re.search(r'const Map<String, String> tennisPortraitAssets = {(.*?)\n};', content, re.DOTALL)
    d = {}
    if m:
        for line in m.group(1).split('\n'):
            if ':' in line:
                k, v = line.split(':', 1)
                d[k.strip().strip("'")] = v.strip().strip(",").strip("'")
    return d

def parse_motorsport():
    path = r'lib\data\racing_portraits.dart'
    if not os.path.exists(path): return {}
    content = open(path, 'r', encoding='utf-8').read()
    m = re.search(r'const kRacingPortraitArtIds = {(.*?)\n};', content, re.DOTALL)
    d = {}
    if m:
        for line in m.group(1).split('\n'):
            line = line.strip().strip(',').strip("'")
            if line:
                d[line] = f'assets/racing_images/{line}.webp'
    return d

def parse_cricket(name):
    slug = name.strip().lower()
    slug = re.sub(r'[^a-z0-9]+', '_', slug)
    slug = re.sub(r'^_+|_+$', '', slug)
    return f'assets/cricketer_images/{slug}.webp'

def get_cards():
    audit_path = r'C:\Users\priya\.gemini\antigravity\brain\d212dc61-291d-4bc1-a88c-23f7f7b52223\player_image_audit.md'
    content = open(audit_path, 'r', encoding='utf-8').read()
    
    players = []
    current_sport = None
    for line in content.split('\n'):
        if line.startswith('### '):
            current_sport = line[4:].strip()
        elif line.startswith('- ') and '(' in line and current_sport:
            m = re.match(r'- ([\w-]+) \((.*)\)', line)
            if m:
                players.append((current_sport, m.group(1), m.group(2)))
    return players

def main():
    foot = parse_football()
    basket = parse_basketball()
    tennis = parse_tennis()
    motor = parse_motorsport()
    
    # map id -> shortName AND id -> inline portraitAsset
    id_to_shortname = {}
    id_to_inline_asset = {}
    
    cards_dart = open(r'lib\models\cards.dart', 'r', encoding='utf-8').read()
    for block in cards_dart.split('PlayerCard(')[1:]:
        m_id = re.search(r"id:\s*'([^']+)'", block)
        if not m_id: continue
        pid = m_id.group(1)
        
        m_sn = re.search(r"shortName:\s*'([^']+)'", block)
        if m_sn:
            id_to_shortname[pid] = m_sn.group(1)
            
        m_asset = re.search(r"portraitAsset:\s*'([^']+)'", block)
        if m_asset:
            id_to_inline_asset[pid] = m_asset.group(1)

    players = get_cards()
    
    withImages = {'Football': [], 'Cricket': [], 'Basketball': [], 'Tennis': [], 'Motorsport': []}
    withoutImages = {'Football': [], 'Cricket': [], 'Basketball': [], 'Tennis': [], 'Motorsport': []}
    
    withCount = 0
    withoutCount = 0

    for sport, pid, name in players:
        assetPath = None
        
        # 1. First check inline asset!
        if pid in id_to_inline_asset:
            assetPath = id_to_inline_asset[pid]
        else:
            if sport == 'Cricket':
                assetPath = parse_cricket(name)
            elif sport == 'Football':
                short_name = id_to_shortname.get(pid)
                if short_name in foot:
                    assetPath = foot[short_name]
            elif sport == 'Basketball':
                if pid in basket:
                    assetPath = basket[pid]
            elif sport == 'Tennis':
                if pid in tennis:
                    assetPath = tennis[pid]
            elif sport == 'Motorsport':
                if pid in motor:
                    assetPath = motor[pid]

        exists = False
        if assetPath:
            if os.path.exists(assetPath):
                exists = True
                
        if exists:
            withImages[sport].append(f'- {pid} ({name})')
            withCount += 1
        else:
            withoutImages[sport].append(f'- {pid} ({name})')
            withoutCount += 1

    sb = []
    sb.append('# Player Cards Images Audit\n')
    sb.append('We ran a script across the entire application\'s data sets for all sports (Football, Cricket, Basketball, Tennis, and Motorsport) to cross-reference the canonical portrait paths in the code with the files that actually exist in the `assets/` directory.\n')
    sb.append('The results are listed below by whether the artwork was found on disk.\n')
    
    sb.append('## Summary')
    sb.append(f'- **With Images:** {withCount} players')
    sb.append(f'- **Without Images:** {withoutCount} players\n')
    sb.append('---\n')
    
    sb.append(f'## 🎨 Players WITH Images ({withCount})\n')
    for sport in ['Football', 'Cricket', 'Basketball', 'Tennis', 'Motorsport']:
        if withImages[sport]:
            sb.append(f'### {sport}')
            for item in withImages[sport]:
                sb.append(item)
            sb.append('')
            
    sb.append('---\n')
    sb.append(f'## 🚫 Players WITHOUT Images ({withoutCount})\n')
    for sport in ['Football', 'Cricket', 'Basketball', 'Tennis', 'Motorsport']:
        if withoutImages[sport]:
            sb.append(f'### {sport}')
            for item in withoutImages[sport]:
                sb.append(item)
            sb.append('')

    out_path = r'C:\Users\priya\.gemini\antigravity\brain\d212dc61-291d-4bc1-a88c-23f7f7b52223\player_image_audit.md'
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sb))
        
    print(f"Artifact updated successfully. With: {withCount}, Without: {withoutCount}")

main()
