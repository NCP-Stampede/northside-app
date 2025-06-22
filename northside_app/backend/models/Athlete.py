from mongoengine import Document, StringField, DateTimeField, BooleanField
from datetime import datetime

class Athlete(Document):
    name = StringField(required=True)
    sport = StringField(required=True)
    level = StringField(required=True, enum=['varsity', 'jv', 'freshman'])
    gender = StringField(required=True, enum=["girls", "boys"])
    grade = StringField(required=True, enum=["Fr.", "So.", "Jr.", "Sr."])
    position = StringField(required=True)
    createdAt = DateTimeField(required=True, default=datetime.now)

    meta = {
        'collection': 'athletes',
        'indexes': [
            {'fields': ['name', 'sport', 'level', 'gender', 'grade', 'position'], 'unique': True}
        ]
    }