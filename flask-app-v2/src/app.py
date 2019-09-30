from flask import Flask, request

app = Flask(__name__)

@app.route("/")
def hello():
    print(request.environ)
    return "Hello, World!"
