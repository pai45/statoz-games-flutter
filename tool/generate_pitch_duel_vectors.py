"""Original monochrome football tactic art, tinted with Cyber tokens in Flutter."""
from pathlib import Path
import math
import re

ROOT = Path(__file__).resolve().parents[1] / 'assets' / 'pitch_duel'

def ball(x, y, r=7):
    return f'<circle cx="{x}" cy="{y}" r="{r}" fill="#fff"/><path d="M{x-3} {y-1}l3-3 4 3-2 4h-4z" fill="#000"/>'

def player(x, y):
    return f'<circle cx="{x}" cy="{y}" r="9"/><circle cx="{x}" cy="{y}" r="3" fill="#fff"/>'

def line(path, extra=''):
    return f'<path d="{path}" {extra}/>'

def arrow(path):
    # flutter_svg does not render SVG marker elements; author the head directly.
    values = [float(v) for v in re.findall(r'-?\d+(?:\.\d+)?', path)]
    if path.rsplit('H', 1)[-1].isdigit():
        px, py = values[:2]
        x, y = values[-1], py
    elif path.rsplit('V', 1)[-1].isdigit():
        px, py = values[:2]
        x, y = px, values[-1]
    else:
        x, y = values[-2:]
        px, py = values[-4:-2]
    a = math.atan2(y - py, x - px)
    bx, by = x - 9 * math.cos(a), y - 9 * math.sin(a)
    head = f'M{bx-4*math.sin(a):.2f} {by+4*math.cos(a):.2f}L{x} {y}L{bx+4*math.sin(a):.2f} {by-4*math.cos(a):.2f}'
    return line(path) + line(head)

def wrap(body):
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 160 100">'
      '<g fill="none" stroke="#fff" stroke-width="1" opacity=".12">'
      '<path d="M12 14H148V86H12Z M80 14V86"/><circle cx="80" cy="50" r="20"/>'
      '</g><g fill="none" stroke="#fff" stroke-width="3" '
      f'stroke-linecap="round" stroke-linejoin="round">{body}</g></svg>')

actions = {
 'act1': player(30,70)+player(115,25)+arrow('M42 65Q70 70 106 34')+line('M74 20v20 M74 60v20', 'opacity=".35"')+ball(55,62),
 'act2': line('M126 22h22v56h-22', 'opacity=".6"')+ball(60,62,13)+arrow('M78 55L133 35')+line('M29 64h16 M33 74h15'),
 'act3': player(40,70)+line('M75 25l15 15-15 15-15-15z', 'opacity=".35"')+arrow('M50 66C125 85 24 5 110 26')+ball(98,27),
 'act4': line('M20 17v65h120', 'opacity=".25"')+player(27,26)+arrow('M38 30L105 30Q129 30 99 70')+ball(99,70),
 'act5': line('M125 17h22v32h-22', 'opacity=".5"')+ball(31,78,11)+arrow('M48 69Q69 10 136 30')+line('M28 53L40 35 M45 74L69 68', 'opacity=".4"'),
 'act6': player(29,70)+player(127,29)+arrow('M45 63L110 34')+line('M58 76L110 49 M31 41L72 21', 'opacity=".35"')+ball(79,47),
 'act7': player(56,56)+ball(119,61)+line('M57 65L92 73L117 57 M43 67L75 83')+line('M46 22L57 40 M30 39L44 46', 'opacity=".35"'),
 'act8': player(35,30)+player(35,70)+player(79,50)+arrow('M46 30L69 42')+arrow('M46 70L69 58')+line('M112 18v64')+ball(118,50),
 'act9': line('M82 22v56 M70 22h24 M70 78h24', 'stroke-width="7"')+arrow('M20 50H60')+line('M102 26L130 50L102 74', 'opacity=".3"'),
 'act10': player(73,50)+player(101,50)+line('M76 25Q119 16 129 50Q119 84 76 75', 'stroke-dasharray="4 5"')+ball(43,50),
 'act11': line('M22 73L138 24', 'stroke-dasharray="4 5" opacity=".35"')+player(73,25)+arrow('M76 36L86 60')+ball(86,60),
 'act12': line('M122 17h25v65h-25', 'opacity=".4"')+ball(111,58)+player(47,69)+arrow('M61 67L99 58')+line('M37 36L65 38 M33 47H55', 'opacity=".35"'),
 'act13': line('M40 79L62 18L87 51L111 18L132 79Z')+ball(86,67,12)+line('M22 45L34 50 M143 45L132 50', 'opacity=".5"'),
 'act14': player(40,35)+player(121,65)+line('M52 36L70 47L58 67 M109 63L89 53L105 34')+ball(79,49)+line('M75 17v9 M80 77v9', 'opacity=".35"'),
 'act15': line('M25 50Q80 2 135 50Q80 98 25 50Z')+player(80,50)+line('M80 16v9 M80 75v9 M45 25L51 32 M114 68L120 75', 'opacity=".4"'),
 'act16': arrow('M117 33A40 33 0 1 0 119 67')+line('M80 33v34 M63 50h34', 'stroke-width="6"'),
}
scenarios = {
 'sc1': arrow('M28 75L76 50L127 24')+player(28,75)+ball(91,41)+line('M37 31L83 16 M74 82L128 64', 'opacity=".3"'),
 'sc2': player(58,50)+player(103,50)+ball(80,76)+line('M80 13v16 M80 37v26', 'opacity=".3"'),
 'sc3': ball(38,76,10)+arrow('M52 68Q78 3 132 35')+line('M124 22h22v28h-22 M78 58L94 58L94 73', 'opacity=".4"'),
 'sc4': line('M80 16A34 34 0 1 1 46 50 M80 24v28l20 12')+line('M31 30h25 M27 42h20')+ball(80,52,5),
 'sc5': line('M25 18h112v65H25Z M57 18v21h49V18', 'opacity=".4"')+player(54,55)+player(106,55)+player(80,72),
 'sc6': line('M24 14v72 M40 14v72', 'opacity=".3"')+arrow('M47 79L47 28Q47 17 113 28')+ball(119,29)+player(48,79),
 'sc7': player(44,35)+player(119,65)+ball(80,50,11)+arrow('M40 68L60 58')+arrow('M119 30L100 41')+line('M68 20L77 33 M83 71L92 84', 'opacity=".3"'),
}
affinities = {
 'finisher': line('M59 22h42v55H59Z M67 30h26v22H67', 'opacity=".5"')+ball(80,58,13),
 'creator': player(80,50)+arrow('M67 48L40 25')+arrow('M92 49L123 32')+arrow('M77 63L62 83'),
 'runner': line('M65 21L98 21L81 44H109L64 84L75 56H52Z')+line('M29 34h24 M24 50h20 M32 68h16', 'opacity=".35"'),
 'stopper': line('M80 15L111 27V51Q111 73 80 86Q49 73 49 51V27Z')+line('M66 41L94 69 M94 41L66 69'),
 'reader': line('M27 50Q80 8 133 50Q80 92 27 50Z')+player(80,50),
 'anchor': line('M80 27V75 M62 44H98 M43 59Q44 82 80 82Q116 82 117 59')+line('M37 65L43 57L51 64 M109 64L117 57L123 65')+player(80,21),
}
for directory, images in [('actions', actions), ('scenarios', scenarios), ('affinities', affinities)]:
    target = ROOT / directory
    target.mkdir(parents=True, exist_ok=True)
    for name, body in images.items():
        (target / f'{name}.svg').write_text(wrap(body), encoding='utf-8')
print('Created 16 action illustrations, 7 scenario emblems and 6 affinity glyphs.')
