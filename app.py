from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/")
def index():
    return "Hello from Flask app behind ALB in a private subnet!"

@app.route("/health")
def health():
    return jsonify(status="ok")
