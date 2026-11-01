# Your AI Knows PHP. But Does It Know Your Sylius Project?

Symfony AI Mate in practice, on a Sylius project.
PS Summit 2026, Lyon, 5 November 2026 — Michał Pysiak (Sylius).

**Slides:** https://mpysiak.github.io/ps-summit-lyon-2026/deck.html
(keys: arrows, `n` = speaker notes, `f` = fullscreen, `space` = play/pause a demo)

## Demo recordings (`media/`)

Same prompt ("The page … is slow for me. Find the cause."), same project
(clean Sylius Standard 2.3 with one listing customization that introduces an N+1),
fresh Claude Code session every time. The deck shows one run per variant, picked
close to the median of 5 runs; the full series (four models, bare and with Mate,
turns, time, tokens) is in [`results.md`](results.md).

| file | model | harness | turns | to "it's an N+1" |
| --- | --- | --- | --- | --- |
| `demo-1-bare.webm` | Claude Fable 5.1 | bare, no Mate | 10 | 2:41, proven by hand (recording sped up ×3) |
| `demo-2-mate.webm` | Claude Fable 5.1 | Mate + Symfony bridge | 7 | 0:30, verdict at 0:48 |
| `demo-3-haiku-mate.webm` | Claude Haiku 5.5 | Mate + Symfony bridge | 11 | 0:38, verdict at 0:58 |

Between the bare and the Mate run the only change is what `vendor/bin/mate init`
leaves behind (the block in `AGENTS.md`, `mate/`, skills in `.agents/skills`).
Recorded with the scripts in `tools/` (asciinema in tmux, metrics from the session
transcript).

## Install Mate in a Symfony project (as in the demo)

```
composer require --dev symfony/ai-mate symfony/ai-symfony-mate-extension
vendor/bin/mate init
vendor/bin/mate tools:list
```

In a Sylius project use the pack instead: `composer require --dev sylius/sylius-ai-dev-tools`.

## Your own tool and skill (slides 13–15)

- A tool is a class in `mate/src` with a public method carrying `#[MateTool]`; typed parameters become the input schema. `vendor/bin/mate discover` picks it up, no registration.
- A skill is a directory with `SKILL.md` under `mate/skills`, declared once in `composer.json` under `extra.ai-mate.skills`; `mate discover` installs it into `.agents/skills`.
- To share both between projects, make a Composer package: start from https://github.com/MatesOfMate/extension-template.

## Links from the talk

- Symfony AI Mate docs: https://symfony.com/doc/current/ai/components/mate.html
- `sylius/sylius-ai-dev-tools`, the pack for Sylius: https://github.com/Sylius/sylius-ai-dev-tools
- `sylius/sylius-mate-extension`, 27 tools and 6 skills: https://github.com/Sylius/sylius-mate-extension
- Community extensions: https://github.com/MatesOfMate/awesome-mate
- Extension template: https://github.com/MatesOfMate/extension-template
- Johannes Wachter (author of Mate): https://johanneswachter.dev/blog
  - Mate Lab, measuring whether the agent reaches for the tools: https://johanneswachter.dev/blog/mate-lab
  - The hardest code to delete, why the MCP server went away: https://johanneswachter.dev/blog/the-hardest-code-to-delete
  - Kill the MCP: https://johanneswachter.dev/blog/kill-the-mcp
- Johannes's deck from SymfonyLive Berlin 2026: https://johanneswachter.dev/symfony-mate-berlin
- Dave Liddament's pyramid (slide 10) comes from the same SymfonyLive Berlin 2026.

## Credits

Harness photo on slide 4: Katya Wolf, Pexels.
