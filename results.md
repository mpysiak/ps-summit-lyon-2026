# Recording series, 1 Nov 2026

Sylius Standard 2.3.0, Mate 1.0.0-BETA1, Claude Code 2.1.316. Same prompt in every run: "The page https://127.0.0.1:8000/en_US/taxons/t-shirts/men is slow for me. Find the cause." Fresh session each time, project memory cleared, project reset to the same commit after each run. Median (min–max), 5 runs per row (6 for the first).

- **first N+1**: first assistant message naming the N+1 / lazy loading. Bare models say it from the diff within seconds (training), then spend the rest proving it by hand; with Mate the first message comes with the profiler fact.
- **end**: last assistant message. For bare runs this is the confirmed verdict. Haiku 4.5 keeps going after the diagnosis and "fixes" the bug (changed files column), so its end time measures the fixing, not the finding.

| # | model | harness | API turns | tool calls | first N+1 | end | output tok | input+cache tok | changed files |
|---|---|---|---|---|---|---|---|---|---|
| 1 | claude-fable-5-1 | bare | 12 (6–15) | 11 (5–14) | 0:19 (0:06–2:58) | 2:45 (1:07–3:42) | 7.5k (3.0k–9.9k) | 591k (275k–757k) | 0/6 |
| 2 | claude-fable-5-1 | with Mate | 6 (6–7) | 6 (5–9) | 0:37 (0:29–1:44) | 0:48 (0:31–1:44) | 3.1k (1.8k–4.5k) | 299k (295k–375k) | 0/5 |
| 3 | claude-opus-5-5 | bare | 10 (8–12) | 9 (7–11) | 0:08 (0:06–0:09) | 1:20 (0:53–3:02) | 4.5k (3.8k–6.3k) | 508k (401k–607k) | 0/5 |
| 4 | claude-opus-5-5 | with Mate | 6 (5–6) | 5 (4–5) | 0:16 (0:10–0:28) | 0:28 (0:25–0:31) | 1.8k (1.5k–2.2k) | 317k (258k–325k) | 0/5 |
| 5 | claude-haiku-5-5 | bare | 15 (6–20) | 15 (7–20) | 0:10 (0:08–0:24) | 1:08 (0:43–1:56) | 8.6k (4.5k–14.3k) | 783k (290k–1114k) | 0/5 |
| 6 | claude-haiku-5-5 | with Mate | 11 (9–16) | 11 (8–16) | 0:27 (0:08–0:38) | 0:57 (0:41–1:05) | 6.8k (4.5k–9.2k) | 584k (486k–890k) | 0/5 |
| 7 | claude-haiku-4-5 | bare | 45 (41–81) | 44 (41–80) | 1:14 (0:22–1:26) | 2:24 (2:03–5:04) | 10.8k (9.7k–18.6k) | 2675k (2231k–5396k) | 5/5 |
| 8 | claude-haiku-4-5 | with Mate | 53 (26–67) | 52 (37–66) | 1:01 (0:34–1:08) | 2:59 (1:58–4:08) | 13.0k (8.8k–19.0k) | 3259k (1285k–5131k) | 4/5 |

Raw data per run (cast, transcript, metrics) in `runs/`, not committed.
