import http.server
import socketserver
import urllib.request
import json
import os
import ssl

PORT = 8080
DIRECTORY = os.path.dirname(os.path.abspath(__file__))
N8N_URL = "http://localhost:5678/webhook/aduana-lab3-chat-webhook/chat"
N8N_TEST_URL = "http://localhost:5678/webhook-test/aduana-lab3-chat-webhook/chat"

class AduanaHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.end_headers()

    def do_POST(self):
        if self.path.startswith('/webhook/') or self.path == '/api/chat':
            content_length = int(self.headers.get('Content-Length', 0))
            post_body = self.rfile.read(content_length)

            target_urls = [
                N8N_URL,
                N8N_TEST_URL,
                "http://localhost:5678/webhook/aduana-lab3-chat-webhook",
                "http://localhost:5678/webhook/VDPl5zFTlpR9jPJ9/chat"
            ]

            success = False
            response_data = None

            # 1. Intentar llamar a los webhooks de n8n
            for url in target_urls:
                try:
                    req = urllib.request.Request(
                        url,
                        data=post_body,
                        headers={'Content-Type': 'application/json'},
                        method='POST'
                    )
                    with urllib.request.urlopen(req, timeout=12) as resp:
                        if resp.status == 200:
                            response_data = resp.read()
                            success = True
                            break
                except Exception:
                    continue

            # 2. Si el webhook de n8n está en modo editor/canvas sin ejecutar, procesar directo con IA + PostgreSQL
            if not success:
                try:
                    req_json = json.loads(post_body.decode('utf-8'))
                    chat_input = req_json.get('chatInput', '')
                    answer = self.process_ai_query(chat_input)
                    response_data = json.dumps({'output': answer}).encode('utf-8')
                    success = True
                except Exception as e:
                    response_data = json.dumps({
                        'output': f"Error al procesar la consulta: {str(e)}"
                    }).encode('utf-8')

            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(response_data)
        else:
            self.send_error(404, "Endpoint no encontrado")

    def process_ai_query(self, query):
        import subprocess
        script = os.path.join(DIRECTORY, 'scratch', 'run_agent_query.js')
        if not os.path.exists(script):
            return "No se pudo cargar el agente de consultas."
        res = subprocess.run(['node', script, query], capture_output=True, text=True, timeout=40)
        if res.returncode == 0:
            return res.stdout.strip()
        else:
            return f"Consulta procesada con advertencia: {res.stderr.strip() or res.stdout.strip()}"

if __name__ == '__main__':
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), AduanaHandler) as httpd:
        print(f"Servidor Aduana IA escuchando en http://localhost:{PORT}")
        httpd.serve_forever()
