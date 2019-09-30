from flask import Flask, request

application = Flask(__name__)

@application.route("/")
def hello():
    print(request.environ)
    return "Hello, World!"

if __name__ == "__main__":
    application.run(host="0.0.0.0", port=8080)
