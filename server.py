#!/usr/bin/env python3
"""
Simple HTTP server for Flutter web application.
Serves files from docchat_flutter/build/web on port 5000.
"""

import http.server
import socketserver
import os
from pathlib import Path

PORT = 5000
HOST = "0.0.0.0"
DIRECTORY = "docchat_flutter/build/web"

class NoCacheHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """HTTP request handler with no-cache headers for Flutter app."""
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)
    
    def end_headers(self):
        # Add CORS headers to allow iframe embedding
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        
        # Disable caching for HTML and service worker
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
    # Ensure the build directory exists
    if not Path(DIRECTORY).exists():
        print(f"Error: Build directory '{DIRECTORY}' not found.")
        print("Please run 'cd docchat_flutter && flutter build web' first.")
        exit(1)
    
    with socketserver.TCPServer((HOST, PORT), NoCacheHTTPRequestHandler) as httpd:
        print(f"Serving Flutter app at http://{HOST}:{PORT}")
        print(f"Directory: {DIRECTORY}")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")
            httpd.shutdown()

if __name__ == "__main__":
    main()
