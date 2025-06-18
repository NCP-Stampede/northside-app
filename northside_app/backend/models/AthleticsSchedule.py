from mongoengine import Document, StringField, DateTimeField, BooleanField
from datetime import datetime
import pytz

class AthleticsSchedule(Document):
    date = DateTimeField(required=True)
    sport = StringField(required=True)
    team = StringField(required=True)
    location = StringField(required=True)
    home = BooleanField(required=True)
    createdAt = DateTimeField(required=True, default=datetime.now)    

    meta = {
        'collection': 'athletics_schedule',
        'indexes': [
            {'fields': ['date', 'sport', 'team', 'location', 'home', 'createdAt'], 'unique': True}
        ]
    }