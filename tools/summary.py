#!/usr/bin/env python3
"""Aggregate runs/*/metrics.json → markdown table per variant+model (median, min–max)."""
import json, glob, os, statistics as st, sys
runs = {}
for f in sorted(glob.glob(os.path.join(os.path.dirname(__file__), '..', 'runs', '*', 'metrics.json'))):
    m = json.load(open(f)); meta = dict(l.split('=', 1) for l in open(os.path.join(os.path.dirname(f), 'meta.txt')) if '=' in l)
    if 'error' in m: continue
    runs.setdefault((meta['variant'].strip(), m['model']), []).append(m)
def cell(v): return f"{st.median(v):g} ({min(v):g}–{max(v):g})"
print('| variant | model | runs | API turns | tool calls | wall s | output tok | input+cache tok |')
print('|---|---|---|---|---|---|---|---|')
for (v, model), ms in runs.items():
    print(f"| {v} | {model} | {len(ms)} | {cell([m['api_requests'] for m in ms])} | {cell([m['tool_calls'] for m in ms])} | "
          f"{cell([m['wall_s'] for m in ms])} | {cell([m['output_tokens'] for m in ms])} | "
          f"{cell([m['input_tokens']+m['cache_creation_tokens']+m['cache_read_tokens'] for m in ms])} |")
