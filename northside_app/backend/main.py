from flask import Flask, request, jsonify
from flask_cors import CORS
import threading
from dataUpdate import update_data
from mongoengine import connect
import os
from dotenv import load_dotenv

from models.Athlete import Athlete

app = Flask(__name__)
CORS(app)

load_dotenv()
connect(host=os.environ.get('MONGODB_URL'))

@app.route('/api/roster', methods=['GET'])
def roster():
    try:
        sport = request.args.get('sport', 'all')
        gender = request.args.get('gender')
        level = request.args.get('level')

        query = {}
        if sport:
            query['sport'] = sport
        if gender:
            query['gender'] = gender
        if level:
            query['level'] = level
        
        athletes = Athlete.objects(**query).to_json()
        return athletes
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    tdataupdate = threading.Thread(target=update_data)
    tdataupdate.start()

    app.run(debug=True)
