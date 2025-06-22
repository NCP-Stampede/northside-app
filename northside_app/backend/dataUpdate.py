from scraping.athletics_schedule import update_athletics_schedule
from scraping.athletics_roster import update_athletics_roster
from datetime import datetime

def update_data():
    while True:
        if datetime.now().day == 1:
            print("Updating athletics schedule...")
            update_athletics_roster()
            print("Athletics schedule update completed.")
        if datetime.now().strftime("%H:%M") == "12:00":
            print("Updating athletics schedule...")
            update_athletics_schedule()
            print("Athletics schedule update completed.")