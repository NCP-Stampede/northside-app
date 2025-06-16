from dotenv import load_dotenv
from pymongo import MongoClient
import os
from datetime import datetime

load_dotenv()

client = MongoClient(os.environ['MONGODB_URL'])

def get_db():
    return client[os.environ['MONGODB_DB']]

collection = get_db()["users"]

document = {"name": "John Doe", 
            "grade": 10, 
            "password": "password123", 
            "email": "jdoe@cps.edu", 
            "created_at": datetime.now()}
collection.insert_one(document)

