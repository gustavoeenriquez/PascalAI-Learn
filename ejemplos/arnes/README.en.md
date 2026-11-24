# A harness like OpenClaw, in PascalAI

[Español](LEEME.md) · **English**

A language model alone answers questions. A **harness** is the program around it that turns it into an
assistant: it receives messages, remembers, uses tools, works on its own and asks for permission. OpenClaw,
Claude Code and others are harnesses. This is a complete one in about 250 lines of PascalAI: the assistant of
Marta, owner of Café La Montaña (fictional company, people and data). The code and its comments are in Spanish.

It is the project of the video series «Un arnés como OpenClaw» (H01-H07).

## The pieces

| Piece | Where | What it does |
|---|---|---|
| Channel | `Arnes.pas` (`TCanal`, `[Expose('/chat')]`) | Messages come in over HTTP: `POST /chat/Enviar {"Texto": "..."}` |
| Memory | `Memoria.pas`, `memoria/` | `MEMORY.md` (what always holds) and one note per day, in Markdown, read at start-up |
| Skills | `skills/cafe/SKILL.md` | What the assistant knows about the business |
| Tools | `tools auto` and `[auto]` in `pai.package` | Searches, installs and uses registry packages, within the allow list |
| Mail | `correo/Correo.pas` | A **simulated** MCP server written in PascalAI (folders `correo/entrada` and `correo/enviados`) |
| Heartbeat | `Arnes.pas` (`[Every('30s')] Latido`) | Checks the mail by itself and announces what is new |
| Permissions | `Acciones.pas`, `Buzon.pas` | Sending mail, refunding money or installing a package needs a yes; what was done goes to the day's note |

## Try it

You need `pai` 0.1.3 or later and an Anthropic key in `ANTHROPIC_API_KEY` (or change `[providers]` and the
`primary` in `Arnes.pas`).

```bash
PAI_HUMAN=file pai run Arnes.pas            # Linux; on Windows: $env:PAI_HUMAN = "file"; pai run Arnes.pas
python chat/chat.py                         # another console; open http://127.0.0.1:8090
```

To start over, delete `memoria/*.md`, `memoria/vistos.txt` and `correo/enviados/*.md`.
