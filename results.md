# Recording series, 1 Nov 2026

Sylius Standard 2.3.0, Mate 1.0.0-BETA1, Claude Code 2.1.316. Same prompt in every run: "The page https://127.0.0.1:8000/en_US/taxons/t-shirts/men is slow for me. Find the cause." Fresh session each time, project memory cleared, project reset to the same commit after each run. Median (min–max).

"to N+1 (confirmed)": bare = end of the session (the model names the N+1 from the diff within seconds, then proves it by hand); with Mate = the first message naming the N+1, which comes with the profiler fact. "end" = last assistant message.

| # | model | harness | API turns | tool calls | to N+1 (confirmed) | end | output tok | input+cache tok | changed files | runs |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | claude-fable-5-1 | bare | 12 (6–15) | 11 (5–14) | 2:45 (1:07–3:42) | 2:45 (1:07–3:42) | 7.5k (3.0k–9.9k) | 591k (275k–757k) | 0/6 | 6 |
| 2 | claude-fable-5-1 | with Mate | 6 (6–7) | 6 (5–9) | 0:37 (0:29–1:44) | 0:48 (0:31–1:44) | 3.1k (1.8k–4.5k) | 299k (295k–375k) | 0/5 | 5 |
| 3 | claude-opus-5-5 | bare | 10 (8–12) | 9 (7–11) | 1:20 (0:53–3:02) | 1:20 (0:53–3:02) | 4.5k (3.8k–6.3k) | 508k (401k–607k) | 0/5 | 5 |
| 4 | claude-opus-5-5 | with Mate | 6 (5–6) | 5 (4–5) | 0:16 (0:10–0:28) | 0:28 (0:25–0:31) | 1.8k (1.5k–2.2k) | 317k (258k–325k) | 0/5 | 5 |
| 5 | claude-haiku-4-5 | with Mate | 53 (26–67) | 52 (37–66) | 1:01 (0:34–1:08) | 2:59 (1:58–4:08) | 13.0k (8.8k–19.0k) | 3259k (1285k–5131k) | 4/5 | 5 |

Raw data per run (cast, transcript, metrics) in `runs/`, not committed.
