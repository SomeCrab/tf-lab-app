from flask import Flask, jsonify
import os
import psycopg2

app = Flask(__name__)


DB_HOST = os.environ.get("DB_HOST")
DB_NAME = os.environ.get("DB_NAME")
DB_USER = os.environ.get("DB_USER")
DB_PASSWORD = os.environ.get("DB_PASSWORD")


def get_connection():
    return psycopg2.connect(
        host=DB_HOST,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
    )


@app.route("/")
def index():
    return "Hello from Flask app behind ALB in a private subnet!"


@app.route("/health")
def health():
    return jsonify(status="ok")


@app.route("/db-test")
def db_test():
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("SELECT current_database(), current_user")
        db_name, db_user = cur.fetchone()
        cur.close()
        conn.close()
        return jsonify(
            status="ok",
            db_name=db_name,
            db_user=db_user,
        )
    except Exception as e:
        return jsonify(status="error", error=str(e)), 500