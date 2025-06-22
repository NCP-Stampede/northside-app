from mongoengine import Document, StringField, DateTimeField, BooleanField
from datetime import datetime

class GeneralEvent(Document):
    date = StringField(required=True)
    time = StringField(required=True)
    name = StringField(required=True)
    description = StringField(required=False)
    location = StringField(required=False)
    createdBy = StringField(required=True)
    createdAt = DateTimeField(required=True, default=datetime.now)    

    meta = {
        'collection': 'general_events',
        'indexes': [
            {'fields': ['date', 'time', 'name', 'description', 'location', 'createdBy', 'createdAt'], 'unique': True}
        ]
    }