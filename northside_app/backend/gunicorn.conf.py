import os

port = os.environ.get("PORT", "10000")
bind = f"0.0.0.0:{port}"
workers = 2
worker_class = "sync"
worker_connections = 1000
timeout = 30
keepalive = 2
max_requests = 1000
max_requests_jitter = 100
preload_app = True