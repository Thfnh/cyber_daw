import os

import psycopg
from flask import Flask, jsonify
from routes.challenges import challenges_bp
app = Flask(__name__)

app.register_blueprint(challenges_bp)

def check_database():
    database_url = os.environ["DATABASE_URL"]

    with psycopg.connect(
        database_url,
        connect_timeout=3
    ) as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            return cursor.fetchone()[0] == 1


@app.get("/api/health")
def health():
    return jsonify({
        "status": "ok",
        "service": "webseclab-platform-api"
    }), 200


@app.get("/api/health/ready")
def readiness():
    try:
        if check_database():
            return jsonify({
                "status": "ready",
                "database": "connected"
            }), 200

    except Exception:
        app.logger.exception("Database readiness check failed")

    return jsonify({
        "status": "not_ready",
        "database": "unavailable"
    }), 503


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=False)
