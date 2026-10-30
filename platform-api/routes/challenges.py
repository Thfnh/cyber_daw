
from flask import Blueprint, jsonify
from psycopg.rows import dict_row

from database import get_db_connection


challenges_bp = Blueprint(
    "challenges",
    __name__,
    url_prefix="/api/challenges"
)


@challenges_bp.get("")
def list_challenges():
    try:
        with get_db_connection() as connection:
            with connection.cursor(row_factory=dict_row) as cursor:
                cursor.execute("""
                    SELECT id, title, description, category, difficulty, points
                    FROM challenges
                    WHERE is_active = TRUE
                    ORDER BY id
                """)
                challenges = cursor.fetchall()

        return jsonify({"challenges": challenges}), 200

    except Exception:
        return jsonify({
            "error": "Unable to retrieve challenges"
        }), 500


@challenges_bp.get("/<int:challenge_id>")
def get_challenge(challenge_id):
    try:
        with get_db_connection() as connection:
            with connection.cursor(row_factory=dict_row) as cursor:
                cursor.execute("""
                    SELECT id, title, description, category, difficulty, points
                    FROM challenges
                    WHERE id = %s AND is_active = TRUE
                """, (challenge_id,))
                challenge = cursor.fetchone()

        if challenge is None:
            return jsonify({"error": "Challenge not found"}), 404

        return jsonify({"challenge": challenge}), 200
    
    except Exception:
        return jsonify({
            "error": "Unable to retrieve challenge"
        }), 500
