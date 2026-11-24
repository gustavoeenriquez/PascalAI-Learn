"""El chat del arnés en el navegador.

Sirve chat.html en http://127.0.0.1:8090 (o CHAT_PORT) y le pasa al arnés (http://127.0.0.1:8080) los pedidos a /chat y /buzon,
para que la página y el arnés estén en el mismo origen. Antes, en la carpeta del arnés:

    PAI_HUMAN=file pai run Arnes.pas          (Linux)
    $env:PAI_HUMAN = "file"; pai run Arnes.pas  (Windows, PowerShell)

y después:  python chat/chat.py   (y abre http://127.0.0.1:8090)
"""
import http.server, os, urllib.request

ARNES = os.environ.get("ARNES", "http://127.0.0.1:8080")
PUERTO = int(os.environ.get("CHAT_PORT", "8090"))
PAGINA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "chat.html")
# En el navegador, el panel de la derecha muestra lo que viaja por HTTP entre el chat y el arnés.
EXTRA = "<script>window.http = true; setPanel('HTTP', 'lo que viaja entre el chat y el arnés', '');</script>".encode("utf-8")


class Chat(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        html = open(PAGINA, "rb").read().replace(b"</body>", EXTRA + b"</body>")
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(html)

    def do_POST(self):
        if not (self.path.startswith("/chat/") or self.path.startswith("/buzon/")):
            self.send_error(404)
            return
        cuerpo = self.rfile.read(int(self.headers.get("Content-Length", 0)))
        pedido = urllib.request.Request(ARNES + self.path, data=cuerpo, headers={"Content-Type": "application/json"})
        try:
            with urllib.request.urlopen(pedido, timeout=300) as r:
                datos, codigo = r.read(), r.status
        except urllib.error.HTTPError as e:
            datos, codigo = e.read(), e.code
        self.send_response(codigo)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.end_headers()
        self.wfile.write(datos)

    def log_message(self, *a):
        pass


if __name__ == "__main__":
    try:
        servidor = http.server.ThreadingHTTPServer(("127.0.0.1", PUERTO), Chat)
    except OSError:
        raise SystemExit(f"El puerto {PUERTO} está ocupado: elige otro con la variable CHAT_PORT.")
    print(f"El chat del arnés: http://127.0.0.1:{PUERTO}  (el arnés tiene que estar corriendo en {ARNES})")
    servidor.serve_forever()
