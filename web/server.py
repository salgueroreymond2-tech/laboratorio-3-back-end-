import http.server
import socketserver
import urllib.request
import json
import os
import uuid

PORT = 8080
DIRECTORY = os.path.dirname(os.path.abspath(__file__))
N8N_WEBHOOK_URL = "http://localhost:5678/webhook/aduana-lab3-chat-webhook/chat"

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

            # Asegurar que el payload tenga sessionId para el nodo Simple Memory de n8n
            try:
                body_json = json.loads(post_body.decode('utf-8'))
            except Exception:
                body_json = {}

            chat_input = body_json.get('chatInput', '').strip()
            session_id = body_json.get('sessionId') or f"session_{uuid.uuid4().hex[:8]}"
            body_json['chatInput'] = chat_input
            body_json['sessionId'] = session_id
            forward_body = json.dumps(body_json).encode('utf-8')

            print(f"[Aduana Server] Consulta recibida: \"{chat_input}\" (Session: {session_id})")

            success = False
            response_data = None

            # 1. Enviar directamente a n8n para que quede registrado en las ejecuciones de n8n
            try:
                req = urllib.request.Request(
                    N8N_WEBHOOK_URL,
                    data=forward_body,
                    headers={'Content-Type': 'application/json'},
                    method='POST'
                )
                with urllib.request.urlopen(req, timeout=90) as resp:
                    if resp.status == 200:
                        response_data = resp.read()
                        success = True
                        print(f"[Aduana Server] Ejecutado exitosamente en n8n.")
            except Exception as e:
                print(f"[Aduana Server] Error comunicando con webhook n8n: {e}")

            # 2. Respaldo directo en caso extremo de que n8n esté reiniciándose
            if not success:
                try:
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
        res = subprocess.run(['node', script, query], capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=60)
        if res.returncode == 0:
            return res.stdout.strip()
        else:
            return f"Consulta procesada con advertencia: {res.stderr.strip() or res.stdout.strip()}"

if __name__ == '__main__':
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), AduanaHandler) as httpd:
        print(f"Servidor Aduana IA escuchando en http://localhost:{PORT}")
        httpd.serve_forever()
