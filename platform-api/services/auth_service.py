
import os
from datetime import datetime, timedelta, timezone

import jwt
from werkzeug.security import (
    generate_password_hash,
    check_password_hash,
)


def hash_password(password):
    return generate_password_hash(password)


def verify_password(password, password_hash):
    return check_password_hash(password_hash, password)


def create_access_token(user_id):
    secret_key = os.environ.get("JWT_SECRET_KEY")

    if not secret_key:
        raise RuntimeError("JWT_SECRET_KEY is not configured")

    now = datetime.now(timezone.utc)

    payload = {
        "sub": str(user_id),
        "iat": now,
        "exp": now + timedelta(minutes=30),
    }

    return jwt.encode(payload, secret_key, algorithm="HS256")


def decode_access_token(token):
    secret_key = os.environ.get("JWT_SECRET_KEY")

    if not secret_key:
        raise RuntimeError("JWT_SECRET_KEY is not configured")

    return jwt.decode(
        token,
        secret_key,
        algorithms=["HS256"],
        options={
            "require": ["sub", "iat", "exp"],
        },
    )




