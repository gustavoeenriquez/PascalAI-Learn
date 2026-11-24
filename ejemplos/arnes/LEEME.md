# Un arnés como OpenClaw, en PascalAI

**Español** · [English](README.en.md)

Un modelo de lenguaje, solo, contesta preguntas. Un **arnés** es el programa que lo envuelve y lo convierte
en un asistente: le llegan mensajes, recuerda, usa herramientas, trabaja solo y pide permiso.
OpenClaw, Claude Code y otros son arneses. Este es uno completo, en unas 250 líneas de PascalAI:
el asistente de Marta, dueña de Café La Montaña (empresa, personas y datos ficticios).

Es el proyecto de la serie de videos «Un arnés como OpenClaw» (H01-H07).

## Las piezas

| Pieza | Dónde | Qué hace |
|---|---|---|
| Canal | `Arnes.pas` (`TCanal`, `[Expose('/chat')]`) | Los mensajes entran por HTTP: `POST /chat/Enviar {"Texto": "..."}` |
| Memoria | `Memoria.pas`, `memoria/` | `MEMORY.md` (lo que vale siempre) y una nota por día, en Markdown. Se lee al empezar |
| Skills | `skills/cafe/SKILL.md` | Lo que el asistente sabe del negocio: devoluciones, envíos, precios, horario |
| Herramientas | `tools auto` y `[auto]` en `pai.package` | Busca, instala y usa paquetes del registro, dentro de la lista blanca |
| Correo | `correo/Correo.pas` | Un servidor MCP **simulado**, en PascalAI: lee `correo/entrada` y guarda en `correo/enviados` |
| Latido | `Arnes.pas` (`[Every('30s')] Latido`) | Revisa el correo solo y avisa lo nuevo, sin que le escriban |
| Permisos | `Acciones.pas`, `Buzon.pas` | Enviar un correo, devolver dinero o instalar un paquete pide un sí; lo hecho queda en la nota del día |

## Probarlo

Necesitas `pai` 0.1.3 o posterior (de las [descargas](https://github.com/gustavoeenriquez/PascalAI-Learn/releases/latest))
y una clave de Anthropic en la variable de entorno `ANTHROPIC_API_KEY`. Con otro proveedor, cambia `[providers]` en
`pai.package` y el `primary` de `Arnes.pas` (por ejemplo, un Ollama local que maneje herramientas).

1. En esta carpeta, arranca el arnés con las preguntas por archivo (así el chat puede contestarlas):

   ```bash
   PAI_HUMAN=file pai run Arnes.pas                    # Linux
   $env:PAI_HUMAN = "file"; pai run Arnes.pas          # Windows (PowerShell)
   ```

   Queda corriendo en `http://127.0.0.1:8080`.

2. En otra consola, el chat (necesita Python 3):

   ```bash
   python chat/chat.py
   ```

   y abre `http://127.0.0.1:8090`. A la derecha se ve lo que viaja por HTTP entre el chat y el arnés.

3. Prueba, por ejemplo:
   - «Hola, soy Marta. Recuerda que los martes no abrimos.» (mira `memoria/MEMORY.md`)
   - «¿Tengo correos nuevos?» y «Contéstale al hotel con una cotización.» (aprueba con **Sí**)
   - «Devuélvele el dinero del molino a Sofía.»
   - Espera unos segundos sin escribir: el latido avisa de los correos que no ha visto.
   - Reinicia el arnés y pregunta «¿Qué hicimos hoy?».

Para volver a empezar, borra `memoria/*.md`, `memoria/vistos.txt` y `correo/enviados/*.md`.

## Del ejemplo a tu negocio

- **Chat:** el de la demo es una página simulada. Para Telegram, un `[Webhook('/telegram')]` que reciba los mensajes
  y `mcp-telegram` del registro para responder.
- **Correo:** cambia el servidor simulado de `[mcp]` por `mcp-imap` (leer) y `mcp-smtp` (enviar), y la herramienta que
  llama `EnviarCorreo`.
- **Fuera de tu máquina:** `[server] token = $PAI_TOKEN`, y las claves siempre en variables de entorno, nunca en el código.

## Lo que conviene probar después

- Una herramienta `BorrarCorreo` que mueva el correo a una carpeta `papelera`, con permiso.
- Un `[Cron('0 7 * * 1-6')]` que mande el resumen del día a las 7:00.
- Una segunda skill, `barista`, con las recetas de la casa.
