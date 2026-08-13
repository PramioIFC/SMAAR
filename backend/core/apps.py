import os
import socket
import threading
from django.apps import AppConfig


def udp_discovery_server():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    # Enable broadcast receiving if necessary, though binding to 0.0.0.0 is usually enough
    try:
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    except Exception:
        pass
        
    sock.bind(('0.0.0.0', 8001))
    while True:
        try:
            data, addr = sock.recvfrom(1024)
            if data.decode('utf-8').strip() == 'DISCOVER_SMAAR':
                sock.sendto(b'SMAAR_SERVER', addr)
        except Exception:
            pass


class CoreConfig(AppConfig):
    name = 'core'

    def ready(self):
        # Evita que o servidor inicie duas vezes por causa do reloader do Django
        if os.environ.get('RUN_MAIN') == 'true':
            t = threading.Thread(target=udp_discovery_server, daemon=True)
            t.start()
