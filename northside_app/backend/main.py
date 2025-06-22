from flask import Flask, request, jsonify
from flask_cors import CORS
# from db import get_db
import threading
from dataUpdate import update_data

app = Flask(__name__)
CORS(app)

# @app.route('/api', methods=['GET'])
# def test():
#     d = {}
#     db = get_db()
#     user_names = db["users"].distinct("name")
#     d["users"] = user_names
#     return jsonify(d)

if __name__ == '__main__':
    tflask = threading.Thread(target=app.run(debug=True))
    tdataupdate = threading.Thread(target=update_data)

    tflask.start()
    tdataupdate.start()
