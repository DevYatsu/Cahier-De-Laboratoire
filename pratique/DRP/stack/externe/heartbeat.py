"""Heartbeat externe (dead man's switch).

Alertmanager envoie l'alerte Watchdog (toujours active) chaque minute sur POST /ping.
Si aucun ping n'arrive pendant SILENCE_MAX_S secondes, toute la chaîne d'alerte est
présumée en panne (Prometheus, Alertmanager ou le réseau) : on prévient l'astreinte.
Le silence est l'alerte : c'est le seul moyen de détecter que l'alerte elle-même ne marche plus.
"""
import os
import smtplib
import threading
import time
from email.message import EmailMessage
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

SILENCE_MAX_S = int(os.environ.get("SILENCE_MAX_S", "180"))
SMTP_HOST = os.environ.get("SMTP_HOST", "astreinte")
SMTP_PORT = int(os.environ.get("SMTP_PORT", "1025"))

state = {"last_ping": None, "alerting": False}
lock = threading.Lock()


def notify(subject: str, body: str) -> None:
    msg = EmailMessage()
    msg["From"] = "heartbeat@hors-stack.localhost"
    msg["To"] = "astreinte@drp.localhost"
    msg["Subject"] = subject
    msg.set_content(body)
    try:
        with smtplib.SMTP(SMTP_HOST, SMTP_PORT, timeout=5) as smtp:
            smtp.send_message(msg)
        print(f"notification envoyée : {subject}")
    except OSError as exc:  # l'astreinte injoignable ne doit pas tuer le heartbeat
        print(f"échec de notification ({exc}) : {subject}")


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):  # noqa: N802 (nom imposé par http.server)
        self.rfile.read(int(self.headers.get("Content-Length", 0)))
        with lock:
            recovered = state["alerting"]
            state["last_ping"] = time.time()
            state["alerting"] = False
        if recovered:
            notify("[RESOLVED] Heartbeat : signal revenu", "Le Watchdog d'Alertmanager arrive de nouveau.")
        self.send_response(200)
        self.end_headers()

    def do_GET(self):  # noqa: N802
        with lock:
            last = state["last_ping"]
        age = "jamais" if last is None else f"{int(time.time() - last)} s"
        self.send_response(200)
        self.end_headers()
        self.wfile.write(f"dernier ping : {age}\n".encode())

    def log_message(self, fmt, *args):
        print("%s %s" % (self.address_string(), fmt % args))


def watch() -> None:
    started = time.time()
    while True:
        time.sleep(15)
        with lock:
            last = state["last_ping"] or started
            silent = time.time() - last
            fire = silent > SILENCE_MAX_S and not state["alerting"]
            if fire:
                state["alerting"] = True
        if fire:
            notify(
                "[FIRING] Heartbeat : plus de signal du stack",
                f"Aucun Watchdog depuis {int(silent)} s. Prometheus, Alertmanager ou le réseau sont tombés : "
                "les alertes du stack ne partent plus.",
            )


if __name__ == "__main__":
    threading.Thread(target=watch, daemon=True).start()
    print(f"heartbeat : écoute sur :8080, silence max {SILENCE_MAX_S} s")
    ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
