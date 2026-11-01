#!/usr/bin/env python3
"""Claude Code transcript (.jsonl) → metrics JSON. `--done FILE` exits 0 when the turn is finished."""
import json, sys
from datetime import datetime

def load(path):
    rows = []
    for line in open(path, encoding='utf-8'):
        try: rows.append(json.loads(line))
        except ValueError: pass
    return rows

def ts(r): return datetime.fromisoformat(r['timestamp'].replace('Z', '+00:00'))

def done(rows):
    a = [r for r in rows if r.get('type') == 'assistant']
    if not a: return False
    last = a[-1]['message']
    if any(c.get('type') == 'tool_use' for c in last.get('content', [])): return False
    return last.get('stop_reason') in ('end_turn', 'stop_sequence', None) and not any(
        r.get('type') == 'user' and ts(r) > ts(a[-1]) and any(c.get('type') == 'tool_result' for c in (r['message'].get('content') or []) if isinstance(c, dict))
        for r in rows if r.get('type') == 'user' and 'timestamp' in r)

def metrics(rows):
    a = [r for r in rows if r.get('type') == 'assistant']
    users = [r for r in rows if r.get('type') == 'user' and 'timestamp' in r]
    if not a: return {'error': 'no assistant messages'}
    t0 = ts(users[0]) if users else ts(a[0])
    usage = {'input_tokens': 0, 'output_tokens': 0, 'cache_creation_tokens': 0, 'cache_read_tokens': 0}
    seen = set(); tools = []; final = ''; diagnosis = None; diag_turns = None
    DIAG = ('n+1', 'n + 1', 'one query per', 'query per variant', 'query per product', 'lazy')
    for r in a:
        m = r['message']; u = m.get('usage') or {}
        rid = r.get('requestId')
        if diagnosis is None:
            for c in m.get('content', []):
                if c.get('type') == 'text' and any(k in c.get('text', '').lower() for k in DIAG):
                    diagnosis = round((ts(r) - t0).total_seconds(), 1); diag_turns = len(seen) + (rid not in seen)
                    break
        if rid not in seen:          # usage repeats on every content block of one API request
            seen.add(rid)
            usage['input_tokens'] += u.get('input_tokens', 0)
            usage['output_tokens'] += u.get('output_tokens', 0)
            usage['cache_creation_tokens'] += u.get('cache_creation_input_tokens', 0)
            usage['cache_read_tokens'] += u.get('cache_read_input_tokens', 0)
        for c in m.get('content', []):
            if c.get('type') == 'tool_use':
                inp = c.get('input') or {}
                tools.append({'t': round((ts(r) - t0).total_seconds(), 1), 'tool': c.get('name'),
                              'arg': (inp.get('command') or inp.get('file_path') or inp.get('pattern') or json.dumps(inp))[:120]})
            if c.get('type') == 'text' and c.get('text', '').strip(): final = c['text']
    return {
        'model': a[0].get('requestedModel') or a[0]['message'].get('model'),
        'api_requests': len(seen), 'assistant_messages': len(a), 'tool_calls': len(tools),
        'wall_s': round((ts(a[-1]) - t0).total_seconds(), 1),
        'diagnosis_s': diagnosis, 'diagnosis_turns': diag_turns,   # first assistant text naming the N+1 / lazy loading
        **usage,
        'tools': tools,
        'final_answer': final[-1500:],
    }

if __name__ == '__main__':
    if sys.argv[1] == '--done':
        sys.exit(0 if done(load(sys.argv[2])) else 1)
    print(json.dumps(metrics(load(sys.argv[1])), indent=1, ensure_ascii=False))
