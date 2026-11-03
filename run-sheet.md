# Run sheet · PS Summit Lyon · 5 Nov 2026 · 15:20–16:00

Target: **34:00 of talk, 6:00 of Q&A**, hard stop 16:00. Clock = time since the first word.
Say column = the one line the slide must land, not a script. Cue column = what to press.

## Before going on

- Laptop on HDMI, `deck.html` open in Chrome, full screen, slide 1 showing. Phone timer visible.
- Click once on the deck (video autoplay needs a user gesture). Press `→` once on slide 6 and `←` back to confirm both videos seek.
- Volume irrelevant: recordings are silent.
- Chrome: no other tabs, notifications off, "Do not disturb" on the Mac.
- Water. Clicker paired. Slide 21 QR tested on the phone.

## Timeline

| clock | # | slide | min | say | cue |
|---|---|---|---|---|---|
| 0:00 | 1 | Title | 0:30 | The model knows PHP. Does it know *your* project? It is not about the next model, it is about what the model gets at the moment of need. | |
| 0:30 | 2 | About me | 1:00 | One sentence per tile. Third tile is the bridge: Developer experience, the Mate extension. | |
| 1:30 | 3 | Getting project knowledge in | 2:00 | Era 1 guess, era 2 instructions (2,000 lines of AGENTS.md), era 3 facts from the app, asked, not described. "Remember this slide." | Optional hands up: who has an AGENTS.md or CLAUDE.md in the repo? |
| 3:30 | 4 | Harness | 2:00 | A harness does not climb for you, it decides what a fall costs. Context, tools, checks. **"The model is replaceable. The harness is yours."** (say it exactly, it comes back on 20) | |
| 5:30 | 5 | Simple example | 2:00 | Sylius Standard 2.3, one correct-looking customization, 112 queries, 45 times the same SELECT. "The profiler sees it. Will the agent ask?" | Do not give the baseline number. |
| 7:30 | 6 | Recording 1, bare | 3:30 | Narrate the blocks: diff, the guess at 0:16 (training), then two and a half minutes of proving it by hand, regex over profiler HTML, hook off for a baseline. Verdict 2:41, 10 turns. | `→` per block, video jumps and stops by itself. Space = pause. |
| 11:00 | 7 | Installation | 1:30 | Three commands, no network, seconds. "Between recording 1 and 2 this is the only thing that changes." Point at what init left: AGENTS.md block, mate/src, skills. | |
| 12:30 | 8 | Recording 2, with Mate | 2:30 | Same prompt. Skill tells it to ask the profiler, `resources:read …/db`, 112 queries in the output, git show. Verdict 0:48, 7 turns. | `→` per block. |
| 15:00 | 9 | Comparison | 3:00 | Four bars, two models, each bare and with Mate. Each tick a tool call, right column median tokens. Both bare runs name N+1 almost at once, that is training. Mate does not improve the guess, it shortens the road from guess to fact and halves the tokens. Opus with Mate: 0:28, fastest of all. **Question to the room: how much do you pay for the model, and how much for the harness?** | Optional before revealing: "guess the tokens". |
| 18:00 | 10 | Pyramid | 2:30 | What the model doesn't know, it guesses. Bottom of the pyramid: things that don't guess, they know: profiler, container, logs. The bare agent scraped the bottom by hand and spent its time one floor up. "Mate is exactly access to the bottom." | `→` ×4 lights the layers. |
| 20:30 | 11 | What Mate is | 2:00 | Walk the diagram top down: agent calls a CLI, Mate has its own container, boots the app, reads profiler, container, routes. Nothing in the kernel, nothing in production. "The rest of symfony/ai: your app uses AI. Mate: AI uses your app." | |
| 22:30 | 12 | Where the tools come from | 1:30 | Bottom up: engine, Symfony layer (what run 2 used), Sylius layer, and on top, your project. "The packages know Symfony and Sylius. Only you know your project." | |
| 24:00 | 13 | Your own tool 1/2 | 2:00 | B2B pricing: the final price exists in no file, so no instruction can hold it. A method, an attribute, typed parameters are the schema. DI works because Mate has its own container. | |
| 26:00 | 14 | Your own tool 2/2 | 1:30 | `mate discover`, no config. Then the support question: gold group sees 79 instead of 99. One call, the answer carries the price list and the rule that won. "Same move as the profiler, only this fact is yours." | |
| 27:30 | 15 | Your own skill | 2:00 | The tool says how it is, the skill says when to ask. A directory with SKILL.md, one line in composer.json. "Works in other projects too? Make it a Composer package." | |
| 29:30 | 16 | Synergy | 2:00 | Skills alone keep guessing. Tools alone sit in vendor unused: 0/10, 0/10; MCP 3/10, 2/10. Together 10/10, 5/10. Visibility decides. One sentence on MCP: Mate removed the server after this, "kill the transport, not the capability". That is why the skill ships with the tools. | `→` ×3 lights the cards. |
| 31:30 | 17 | Our case | 1:30 | 27 tools, 6 skills, one package. sylius-dev is the entry, sylius-verify the definition of done. "Nothing here you couldn't write yourself." One line: `composer require --dev sylius/sylius-ai-dev-tools`. | |
| 33:00 | 18 | Ecosystem | 0:45 | Same pattern, many domains: official bridges, MatesOfMate, products. Start from extension-template. | Cut to one sentence if behind. |
| 33:45 | 19 | Any PHP | 1:00 | Your app needs no Symfony. PrestaShop, Laravel, legacy: same mechanism, a Composer package with mate/src and mate/skills. Versioned with the code, not in a CLAUDE.md per person. | Do not frame as "Sylius has it, Presta does not". |
| 34:45 | 20 | Monday | 1:15 | Start Monday: one tool for the most frequent guess, one skill that says when, measure whether the agent uses it. Context, tools, checks, same three as slide 4. **"The model is replaceable. The harness is yours."** | |
| 36:00 | 21 | Thank you | – | Repo, deck, QR. Stays on screen. | Q&A until 40:00. |

Sum of the slide budgets is 36:00; the 34:00 target assumes the optional bits stay out. Everything after slide 17 is short on purpose, so a late start still lands the bracket on 20.

## Checkpoints

| at slide | on time if clock ≤ | if later |
|---|---|---|
| 9 Comparison (arriving) | 15:00 | no "guess the tokens" |
| 13 Your own tool (arriving) | 24:00 | slide 12 to one sentence, slide 15 without the package part |
| 17 Our case (arriving) | 31:30 | slide 18 to one sentence, slide 19 to the first card only |
| 20 Monday (arriving) | 36:00 | say the bracket sentence, straight to 21, shorter Q&A |

Never cut: 4, 6, 8, 9, 20. The talk is the two recordings and the bracket.

## Q&A, prepared

- **Memory or cache between the two runs?** None. Every run is a new session id, project memory wiped, project reset to the same commit, cache cleared, one curl for a fresh profile. The model does not learn between sessions; the prompt cache carries no content. The only difference is the init + discover commit. Caveat if pressed: my global Claude Code config was present in both variants, identical, nothing about profiling.
- **Why did Mate drop the MCP server?** Transport did not decide, visibility did (the Mate Lab numbers). Skills are files every agent reads anyway; CLI + files is cheaper: no process, no handshake. The capability stayed, the transport went.
- **How many queries is a clean Sylius listing?** "Part of it is Sylius itself, our ~40 is one template." Baseline is in the repo notes, not on the slides.
- **Tokens and cost?** Bare Fable median 7.5k output, 591k input incl. cache; with Mate 3.1k and 299k. Roughly 2× fewer turns, 2.5× less output, 3.4× faster. Full table: results.md.
- **Other models?** Haiku 5.5 bare 1:08, with Mate 0:57, 8.6k to 6.8k output tokens. Haiku 4.5 keeps fixing after the diagnosis, 45–53 turns, in both variants. Every model finishes faster and cheaper with Mate than the same model without.
- **Why is Opus bare faster than Fable bare?** Fable proved more: hook off for a baseline, cache:clear detour, re-measure. Opus bare did the hook-off too but in fewer turns. Both arrive at the same verdict; the point is the gap inside each pair, not between models.
- **Tokens: is input incl. cache a fair number?** Most of it is cache reads, the cheap part. Output is the honest "how much the model worked" number: 7.5k to 3.1k, 4.5k to 1.8k. Both halve with Mate.
- **Does this work with PrestaShop / Laravel / a legacy app?** Mate brings its own container and its own Symfony components in vendor; the app needs none. A Composer package with mate/src and mate/skills, with or without the Symfony bridge. Also works when the app does not boot: container from the dump, profiler and logs from disk.
- **Does it run in production?** No. Dev dependency, own container, nothing in the kernel.
- **Which agents?** Claude Code, Codex, Copilot, Cursor, JetBrains: anything that reads AGENTS.md and can run a CLI.
- **Is Mate Lab statistically solid?** Johannes himself: a pattern, not proof. Two tasks, ten runs each, Haiku. Our series: 41 runs, four models, same direction.
- **Where is the Sylius extension?** `composer require --dev sylius/sylius-ai-dev-tools`, 27 tools, 6 skills; boots the host kernel because hooks, grids and decorators cannot be read from the XML dump.
