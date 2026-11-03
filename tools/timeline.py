#!/usr/bin/env python3
"""Pinned runs → the timeline rows on slide 9 (HTML snippet). Each tick = one tool call, right column = median tokens of the series,
○ = first N+1 named without evidence (bare run), ● = N+1 named with the profiler fact, or proven.

  tools/timeline.py > /dev/stdout
"""
import glob, json, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
SCALE = 165.0   # seconds across the full bar; the longest run (bare Fable, 2:41) nearly fills it
ROWS = [  # stamp, model label, harness label, hot, median tokens (output · input incl. cache), median end (5 runs, eyebrow says so), kind of first N+1 mention
    ('20261101-115924', 'Fable 5.1', 'bare',      False, '7.5k out · 591k in', 'ends 2:45', 'guess'),
    ('20261101-122826', 'Fable 5.1', 'with Mate', True,  '3.1k out · 299k in', 'ends 0:48', 'fact'),
    ('20261101-132107', 'Opus 5.5',  'bare',      False, '4.5k out · 508k in', 'ends 1:20', 'guess'),
    ('20261101-130946', 'Opus 5.5',  'with Mate', True,  '1.8k out · 317k in', 'ends 0:28', 'fact'),
]
def mmss(s): s = round(s); return f'{s // 60}:{s % 60:02d}'
def pct(s): return f'{s / SCALE * 100:.1f}%'

out = ['<div class="tl">']
for n, (stamp, model, harness, hot, tokens, med, kind) in enumerate(ROWS, 1):
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
        <div class="tl-stat"><b>{tokens}</b><span>{med}</span></div>
      </div>''')
axis = ''.join(f'<span style="left:{pct(s)}">{mmss(s)}</span>' for s in (0, 60, 120))
out.append(f'      <div class="tl-axis">{axis}</div>')
out.append('      <div class="tl-legend"><span><i class="tick"></i> tool call</span><span><i class="mk guess"></i> N+1 named, no evidence yet</span><span><i class="mk fact"></i> N+1 with the profiler fact</span></div>')
out.append('    </div>')
print('\n'.join(out))
