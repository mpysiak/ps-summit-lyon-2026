#!/usr/bin/env python3
"""Pinned runs → the timeline rows on slide 9 (HTML snippet). Each tick = one tool call,
○ = first N+1 named without evidence (bare run), ● = N+1 named with the profiler fact, or proven.

  tools/timeline.py 20261101-115924 20261101-122826 20261101-141908 > /dev/stdout
"""
import glob, json, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
SCALE = 165.0   # seconds across the full bar; the longest run (bare Fable, 2:41) nearly fills it
ROWS = [  # stamp, model label, harness label, hot, median turns, median end, kind of first N+1 mention
    ('20261101-115924', 'Fable 5.1', 'bare',      False, '12 turns', 'median of 6 runs · 2:45', 'guess'),
    ('20261101-122826', 'Fable 5.1', 'with Mate', True,  '6 turns',  'median of 5 runs · 0:37', 'fact'),
    ('20261101-141908', 'Haiku 5.5', 'with Mate', False, '11 turns', 'median of 5 runs · 0:27', 'fact'),
]
def mmss(s): s = round(s); return f'{s // 60}:{s % 60:02d}'
def pct(s): return f'{s / SCALE * 100:.1f}%'

out = ['<div class="tl">']
for n, (stamp, model, harness, hot, turns, med, kind) in enumerate(ROWS, 1):
    d = glob.glob(os.path.join(HERE, '..', 'runs', stamp + '-*'))[0]
    m = json.load(open(os.path.join(d, 'metrics.json')))
    end, diag = m['wall_s'], m['diagnosis_s']
    ticks = ''.join(f'<i class="tick" style="left:{pct(t["t"])}"></i>' for t in m['tools'])
    marks = f'<i class="mk {kind}" style="left:{pct(diag)}"><span>{mmss(diag)} {kind}</span></i>'
    if kind == 'guess':
        marks += f'<i class="mk fact edge" style="left:{pct(end)}"><span>{mmss(end)} proven</span></i>'
    else:
        marks += f'<em class="end" style="left:{pct(end)}">{mmss(end)}</em>'
    out.append(f'''      <div class="tl-row{' hot' if hot else ''}">
        <div class="tl-who"><span class="n">{n}</span><b>{model}</b><span class="h">{harness}</span></div>
        <div class="tl-bar"><i class="run" style="width:{pct(end)}"></i>{ticks}{marks}</div>
        <div class="tl-stat"><b>{turns}</b><span>{med}</span></div>
      </div>''')
axis = ''.join(f'<span style="left:{pct(s)}">{mmss(s)}</span>' for s in (0, 60, 120))
out.append(f'      <div class="tl-axis">{axis}</div>')
out.append('      <div class="tl-legend"><span><i class="tick"></i> tool call (one API turn may hold several)</span><span><i class="mk guess"></i> N+1 named, no evidence yet</span><span><i class="mk fact"></i> N+1 with the profiler fact</span></div>')
out.append('    </div>')
print('\n'.join(out))
