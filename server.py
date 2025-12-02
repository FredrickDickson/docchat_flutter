#!/usr/bin/env python3
"""
Simple HTTP server for Flutter web application with SPA routing support.
Serves files from docchat_flutter/build/web on port 5000.
"""

import http.server
import socketserver
import os
import socket
from pathlib import Path

PORT = 5000
HOST = "0.0.0.0"
DIRECTORY = "docchat_flutter/build/web"

class ReuseAddrTCPServer(socketserver.TCPServer):
    """TCP Server with address reuse enabled."""
    allow_reuse_address = True
    
    def server_bind(self):
        self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        super().server_bind()

class SPAHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """HTTP request handler with SPA fallback and no-cache headers."""
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)
    
    def do_GET(self):
        """Handle GET requests with SPA fallback."""
        path = self.path.split('?')[0]
        
        if path == '/':
            path = '/index.html'
        
        file_path = Path(DIRECTORY) / path.lstrip('/')
        
        if file_path.exists() and file_path.is_file():
            super().do_GET()
        else:
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            
            index_path = Path(DIRECTORY) / 'index.html'
            with open(index_path, 'rb') as f:
                self.wfile.write(f.read())
    
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        
        if self.path.endswith('.html') or self.path.endswith('.js') or self.path == '/':
            self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
            self.send_header('Pragma', 'no-cache')
            self.send_header('Expires', '0')
        
        super().end_headers()
    
    def do_OPTIONS(self):
        """Handle OPTIONS requests for CORS preflight."""
        self.send_response(200)
        self.end_headers()

def main():
    if not Path(DIRECTORY).exists():
        print(f"Error: Build directory '{DIRECTORY}' not found.")
        print("Please run 'cd docchat_flutter && flutter build web' first.")
        exit(1)
    
    with ReuseAddrTCPServer((HOST, PORT), SPAHTTPRequestHandler) as httpd:
        print(f"Serving Flutter app at http://{HOST}:{PORT}")
        print(f"Directory: {DIRECTORY}")
        print("SPA routing enabled - all routes will serve index.html")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")
            httpd.shutdown()

if __name__ == "__main__":
    main()
