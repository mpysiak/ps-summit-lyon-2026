# Script · PS Summit Lyon · 5 Nov 2026

What to say on every slide, in full sentences, as spoken. Budgets are the ones from `run-sheet.md`
(34:00 target, 36:00 with the optional bits). `[→]` = press the arrow. Lines in **bold** are the ones
that must land word for word. Everything in *italics* is a stage direction, not spoken.

Pace: ~125 words per minute. That is slower than you talk in Polish. Keep it.

---

## 1 · Title · 0:30

*Wait for the room to settle. Look up, not at the laptop. First sentence slow.*

Good afternoon. My name is Michał, I work at Sylius, and I want to start with a question.

Your AI knows PHP. It knows Symfony. It has read more Symfony code than anyone in this room ever will.
But does it know *your* project? Your hooks, your pricing rules, the query that is slow on your product page?

In the next thirty-five minutes I want to convince you of one thing. The next step for most of us is not a
better model. It is what the model gets at the moment it needs it. And I will show it with a clock running.

---

## 2 · About me · 1:00

Very quickly, who I am. I'm a senior backend developer at Sylius.

On the product side I work on the B2B Suite and on Sylius core.

On the project side I do e-commerce audits, architecture advice, and I sit on pre-sales calls with clients.
That is where I hear "the page is slow" most often. You will hear it again in about five minutes.

And the third tile is why I'm here: developer experience. I maintain the Sylius Mate extension, which is open
source, and that is what this talk is about.

---

## 3 · How it went for us · 2:00

Let me tell you how it went for us at Sylius, in three steps. I think most of you will recognise at least two of them.

Step one: the bare prompt. You open the agent, you ask, it answers. Where does the knowledge come from? Training
data. What does it know about your project? Nothing. So it guesses. Not because it is bad, but because it has to
answer something.

Step two: our reaction. We wrote it down. AGENTS.md, CLAUDE.md, whatever your agent reads.

*Optional, only if on time:* Quick hands up: who has an AGENTS.md or a CLAUDE.md in the repo? *Look around, nod.*
Right, most of us.

Ours is around two thousand lines and growing. How to name things, which directory, don't override the template,
use a hook. It helps. But it is prose about the application, written by a human, and it goes stale the day after
you write it.

Step three is this talk. Instead of describing the application to the agent, let the agent ask the application.
Facts, not prose. Asked, not described.

Remember this slide. We will come back to it, because step two has a name later in the talk. It is called
"skills only", and I have numbers for it.

---

## 4 · The word for it · 2:00

There is a word for everything around the model. Harness.

A climbing harness does not climb for you. You climb. The harness decides what a fall costs. It is the same with
an agent: the model climbs, the harness catches.

What is in it? Three things.

Context. What gets into the model, and when. Not everything at once. The right thing at the right moment.

Tools. Facts from the application, on demand. Not "I think there are many queries". "There are 112."

Checks. Things that know rather than guess. Tests, static analysis, the profiler.

And one sentence I want you to take home. I will say it again at the very end.

**The model is replaceable. The harness is yours.**

Models change every three months. The harness you build stays with your project.

---

## 5 · A simple example · 2:00

Let me make it concrete.

A clean Sylius Standard 2.3. Nine products, five variants each. Nothing special.

One ticket: show the variants and their stock on the product card in the listing.

A developer did it by the book. A template hook, not an override. Conventions are correct, code review would pass
it. And the bug is in the data path: a loop in the template over a relation. The classic N+1.

The result: 112 queries on one listing page. 45 of them are the same SELECT, with a different id each time.

*Do not give the baseline number. If someone asks later: "part of it is Sylius itself, our ~40 is one template."*

The Symfony profiler sees all of this. It is sitting right there in var/cache, it has the number, it has every
query. The question for the next five minutes is simple: will the agent ask it?

---

## 6 · Recording 1 · bare agent · 3:30

*Click once on the deck before pressing anything. Narrate each block; the video jumps and stops by itself.*

Run one. Claude Fable 5.1, the current top model. Bare. No Mate, nothing in the project except the code and the
bug. The recording is sped up three times, the timestamps on the left are real.

[→] The prompt. One sentence, no hints. "The page is slow for me. Find the cause." The same sentence you would
type on a Monday morning.

[→] Seven seconds in, first move: git. What changed recently? Good instinct, that is what I would do.

[→] Sixteen seconds. It reads the diff and says: this is a classic N+1. Correct. It knows this from training, it
has seen ten thousand of these. Keep that number in your head: sixteen seconds. Now it has to prove it.

[→] And here the road gets long. It knows the profiler exists. It knows where the files are. So it writes raw PHP
to unserialize the profile dump. Then it curls the profiler page and parses the HTML with regular expressions.
*Pause, let them read the command.* The knowledge is all there. It is just doing it by hand.

[→] A minute twenty. It has the 112. Now it wants a baseline, so it turns the hook off, runs cache:clear, which
wipes the profile, and measures again.

[→] Two forty-one, ten turns: verdict. The N+1 comes from the product card template added in the last commit.
Correct. Proven. The long way.

Two numbers to keep. The guess at zero sixteen. The proof at two forty-one. The knowledge was there the whole
time. The path was missing.

---

## 7 · Installation · 1:30

Now the only thing I change. Three commands.

composer require, as a dev dependency: Mate itself and the Symfony extension. mate init. And mate tools:list, to
see what you got.

After composer there is no network, init takes a couple of seconds.

What init leaves behind. *Point at the list.* A mate directory with config and a src folder, for your own tools,
we will use it later. A block in AGENTS.md, so the agent knows Mate exists and how to call it. CLAUDE.md pointing
at AGENTS.md. And a set of skills in .agents/skills: profiler-debugging, request-triage, service-inspection and a
few more.

Between recording one and recording two, this is the only difference. Same model, same project, same prompt, a
new session. What each of these pieces is, I will explain after you have seen it work.

---

## 8 · Recording 2 · with Mate · 2:30

*This one is real time, not sped up. Say it.*

Run two. Real time, no speed-up.

[→] The same prompt, word for word. New session, no memory of run one.

[→] Three seconds. First line: "I'll use the Mate profiler tooling, loading the profiler skill." No git, no
guessing. The skill told it where to look first.

[→] Six seconds. It lists the profiles and reads the database collector. Two commands. JSON comes back.

[→] Twenty-six seconds: query_count 112, 45 times one SELECT. That is the fact, and it got it before forming an
opinion. Only now it asks what changed, and git show gives the commit.

[→] Forty-eight seconds, seven turns: the N+1 comes from the product card customization, not from Sylius core.
Same verdict as run one. Same confidence. The difference is that the number came first and the story came after.

---

## 9 · Comparison · 3:00

*Give them five seconds to read the slide before you speak.*

Two models, each twice. Bare, and with Mate. Everything on one clock, each tick is a tool call, and on the right the
tokens. All medians of five runs.

Row one, Fable bare. The open dot at sixteen seconds is the N+1 named, no evidence. Then two and a half minutes
of ticks until the proof. Seven and a half thousand output tokens.

Row two, Fable with Mate. The first mention of N+1 arrives at thirty seconds, and it arrives together with the
profiler number. Done at forty-eight. Three thousand output tokens. Less than half.

*Optional, only if clock ≤ 15:00 on arrival:* Before I showed this, how many tokens would you have guessed for the
bare one? *Take one or two answers.*

Rows three and four, the same experiment with Opus 5.5, one tier below. Bare: guess at nine seconds, proof at one
twenty. With Mate: fact at sixteen seconds, done at twenty-eight. The fastest row on the slide. And again the
tokens: four and a half thousand down to under two thousand.

Look at where the guess happens. Both bare runs name the N+1 within seconds. That is training. Mate did not make
the guess better. It shortened the road from guess to fact, and it halved the bill. Twice, with two models.

*If asked why Opus bare is faster than Fable bare: Fable proved more, it did the baseline with the hook off and
the cache:clear detour. The point is the gap inside each pair, not between the models.*

So the question I want to leave you with on this slide. How much of your budget goes to the model, and how much
to the harness? Because rows two and four did not change the model.

---

## 10 · The pyramid · 2:30

Why did it take two and a half minutes? Dave Liddament showed this pyramid at SymfonyLive Berlin this year, and I think it
explains it.

[→] At the bottom, deterministic checks. Tests, static analysis. Johannes Wachter, the author of Mate, added the
profiler and the container down here. These things do not guess. They know. This floor is the harness. It
enforces.

[→] One floor up: instructions, skills, agents. Enforced by the model. It reads them and does its best.

[→] Plan mode. [→] And at the top, review. A human.

Everything above works only because the base is solid. What the model does not know, it guesses, and the higher
up you are, the more guessing.

Now the two and a half minutes. The answer lived at the bottom, in the profiler. The bare agent knew the bottom existed, it
scraped it by hand with regex. But it spent most of its time one floor up, inferring from code.

Mate is exactly access to the bottom of this pyramid.

---

## 11 · What Symfony Mate is · 2:00

Let's walk the diagram top down.

The agent. Claude Code, Codex, Copilot, Cursor, JetBrains. Anything that reads AGENTS.md and can run a shell
command. It calls vendor/bin/mate tools:call and gets JSON back. That is the whole protocol.

Mate. A dev dependency with its own dependency injection container. It holds three kinds of things: tools, skills
and resources. It boots your application in the background and reads the profiler, the container, the routes.

And your application at the bottom. Nothing is added to your kernel. Nothing ships to production.

Two more facts. Mate started life as an MCP server. The server is gone, Mate is a CLI now. I will tell you why
on slide sixteen, with numbers. And it is extensible: your own tools and skills live in the project, and you
share them as a regular Composer package.

One sentence to place it inside symfony/ai. The rest of symfony/ai lets your application use AI. Mate is the
opposite. **AI uses your application.**

---

## 12 · Four layers · 1:30

Where the tools come from, bottom up.

symfony/ai-mate is the engine. Discovery, the CLI, the skills installer. It ships no tools of its own.

The Symfony extension: profiler, container, services, routes, dotenv. That is what run two used.

The Sylius extension: resources, hooks, grids, mailer, plugins, and six skills. A PrestaShop extension would sit
in exactly this place.

And on top: your project. Your domain, the rules only you know. mate/src and mate/skills. No package needed.

**The packages know Symfony and Sylius. Only you know your project.** The next three slides are about that top
layer.

*If behind schedule: say only the bold line and move on.*

---

## 13 · Your own tool · 1 of 2 · 2:00

Here is an example from our world. A B2B shop. Price lists, customer groups, volume tiers, all configured in the
admin. The final price a customer sees exists in no file. So no AGENTS.md and no skill can hold it. It has to be
asked. That is what makes it a tool and not an instruction.

On the left, the whole tool. A class in mate/src.

Constructor: inject your own price resolver. The same service your application uses. Mate has its own container,
so dependency injection works the same way as in the app.

One attribute, MateTool. A name, and a description written for the model, not for you. This is the integration.
There is no interface to implement.

A public method with typed parameters: variant, channel, a nullable customer group with a default.

On the right, what the agent sees. The types became the input schema. The nullable one became optional, the other
two are required. Nothing to learn, no YAML, no registration.

---

## 14 · Your own tool · 2 of 2 · 1:30

vendor/bin/mate discover. One new tool. mate/src is on the scan list since init, so there is no config and no
service definition, and tools:list shows it next to the package tools.

Then a question support asks every week. "ACME, gold group, sees 79 instead of 99 for this t-shirt. Why?"

Without the tool the agent reads the calculator, reads the fixtures, and guesses. Or it asks you.

With the tool: one call. Price 7900, list B2B-GOLD, and the rule that won: the fifty-plus tier. Not a bug. ACME
is in the gold group, 99 is the retail list.

Same move as the profiler in run two. Only this fact is yours, not Symfony's.

---

## 15 · Your own skill · 2:00

The tool says how it is. The skill says when to ask.

A skill is a directory in mate/skills with a SKILL.md. Front matter: a name, and a description that tells the
agent when this applies. "Any question about a price a customer sees."

Then three lines of judgment. Call the tool before reading the calculator code. Price lists live in the admin,
never in config or fixtures. Unknown customer group: ask, do not assume retail.

That is the whole skill. One line in composer.json, extra.ai-mate.skills, and mate discover installs it into
.agents/skills next to the package skills. For every developer, for every agent.

In one sentence: the skill is what you know. The tool is what has to be checked.

Do you need it in another project too? Make it a Composer package. Start from the extension template, it is a
link on the last slide. That is exactly what the Sylius extension is.

*If behind schedule: drop the last paragraph.*

---

## 16 · Synergy · 2:00

Why ship both in one package? Because Johannes measured it. Mate Lab: two tasks, ten runs each, one metric. Did
the agent reach for Mate at all?

[→] Skills only. The model keeps guessing. That is slide three, the two thousand lines of AGENTS.md.

[→] Tools only. A binary sitting in vendor, nobody tells the agent it exists. Zero out of ten. Zero out of ten.
Through an MCP server, tools visible over the protocol but still no skills: three out of ten, two out of ten.

[→] Together, CLI plus skills. Ten out of ten, and five out of ten.

Visibility decides. Not transport. After this measurement Mate removed its MCP server. Johannes put it in one
line: kill the transport, not the capability.

That is why the skill ships in the same package as the tools. And that is what you saw in run two: profiler skill
plus profiler tool.

*If asked about MCP in Q&A: skills are files every agent reads anyway, CLI plus files is cheaper, no process, no
handshake. Do not go there from the stage.*

---

## 17 · Our case · 1:30

Our extension. 27 tools, 6 skills, one package.

The tools are facts from the booted kernel. What is this project, which plugins are installed, which hook renders
this template, does this Twig function exist. 23 more: resources, grids, routes, mailer, tests.

The skills say when to ask. sylius-dev is the entry point: Mate first, profile, plugins, hooks, before you create
the first file. sylius-verify is the definition of done.

One honest note. Our extension boots the host kernel, which is the opposite of Mate's core, because hooks, grids
and decorators cannot be read from an XML container dump.

Nothing here you could not write yourself with what you saw on the last three slides. One line to install.

---

## 18 · Ecosystem · 0:45

Same pattern, many domains.

Official, inside symfony/ai: Symfony, the one from recording two, and Monolog for logs. The community organisation
MatesOfMate: PHPStan, PHPUnit, Composer, Rector, plus the extension template and the awesome-mate list. And
products: Sylius, Sulu, Oro, OpenDXP, Softspring, each over its own domain.

If you build your own, start from the template.

*If behind schedule: "Same pattern, many domains. The list and the template are on the last slide."*

---

## 19 · Not just Sylius · 1:00

If you don't do Sylius, what is in it for you?

Your application needs no Symfony. Mate brings its own container and its own components in vendor. PrestaShop,
Laravel, a legacy app: same mechanism, a Composer package with mate/src and mate/skills.

*Do not frame it as "Sylius has it, Presta does not". The point is that the mechanism is framework-neutral.*

The whole team. composer install, done. Every developer and every agent gets the same tools and the same skills.

Nothing in production. A dev dependency, its own container, nothing in the kernel.

And yours in an afternoon. A method in mate/src, a directory in mate/skills.

Tools and skills in vendor. Versioned with the code, not in a CLAUDE.md that every person writes their own way.

*If behind schedule: first card only, then the last line.*

---

## 20 · Monday · 1:15

*Slow down. This is the close.*

Start Monday.

Find the most frequent guess in your project. The thing the agent gets wrong every week. Wrap it in one tool.

Write one skill that says when to call it.

And measure whether the agent actually uses it. Remember the zeros from the Mate Lab slide. Do not assume.

Context, tools, checks. The same three from the beginning of the talk.

**The model is replaceable. The harness is yours.**

---

## 21 · Thank you

Thank you. The slides, the links, the demo commands, the full results table: all in this repo, the QR code works.

I'm happy to take questions.

*Stays on screen. Q&A answers are in `run-sheet.md`.*

---

## If a demo breaks

- Video does not play: press space once, then `→` again. If still nothing, read the block captions aloud, they
  carry the whole story, and say "the recording is in the repo".
- Lost the place: `Esc` closes the recording-3 overlay; arrows move between blocks, not slides, while a video is
  active.
- Clock is gone past a checkpoint: the only sentences that cannot be cut are on slides 4, 6, 8, 9 and 20.
