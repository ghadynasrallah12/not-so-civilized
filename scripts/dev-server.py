#!/usr/bin/env python3
"""Static dev server: listens on all interfaces (0.0.0.0) so phone/LAN IP works."""
from __future__ import annotations

import http.server
import socket
import socketserver
import sys


def _pick_port() -> int:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("0.0.0.0", 0))
    port = s.getsockname()[1]
    s.close()
    return port


def _lan_ip() -> str:
    try:
        z = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        z.connect(("10.254.254.254", 80))
        ip = z.getsockname()[0]
        z.close()
        return ip
    except OSError:
        return socket.gethostbyname(socket.gethostname())


def main() -> None:
    port = int(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].isdigit() else _pick_port()
    bind = "0.0.0.0"
    handler = http.server.SimpleHTTPRequestHandler

    with socketserver.TCPServer((bind, port), handler) as httpd:
        lan = _lan_ip()
        print(f"Local:   http://127.0.0.1:{port}/")
        print(f"Network: http://{lan}:{port}/   (use this from another device on Wi‑Fi)")
        print("Serving on 0.0.0.0 — bind OK for LAN. Press Ctrl+C to stop.\n")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print()


if __name__ == "__main__":
    main()
