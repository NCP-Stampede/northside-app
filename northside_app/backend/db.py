from dotenv import load_dotenv
from pymongo import MongoClient
import os
from datetime import datetime

load_dotenv()

client = MongoClient(os.environ['MONGODB_URL'])

def get_db():
    return client[os.environ['MONGODB_DB']]

