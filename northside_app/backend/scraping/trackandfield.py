import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from bs4 import BeautifulSoup
import requests
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains
import time
from datetime import datetime
import pandas as pd

from mongoengine import connect
from dotenv import load_dotenv

sports = ['cross-country', 'track-and-field-outdoor', 'track-and-field-indoor']

def update_track_and_field_schedule():
    df = pd.DataFrame(columns=["name", "date", "time", "gender", "sport", "level", "opponent", "location", "home"])
    for sport in sports:
        for year in [2025, 2026]:
            names = []
            dates = []
            genders = []
            try:
                load_dotenv()
                connect(host=os.environ['MONGODB_URL'])
            except Exception as e:
                print(f"Error connecting to the database: {e}")
            url = f"https://www.athletic.net/team/19718/{sport}/{year}"

            chrome_options = Options()
            chrome_options.add_argument("--headless")
            chrome_options.add_argument("--no-sandbox")
            chrome_options.add_argument("--disable-dev-shm-usage")
            chrome_options.add_argument("--window-size=1920,1080")
            driver = webdriver.Chrome(options=chrome_options)
            driver.get(url)

            wait = WebDriverWait(driver, 20)
            
            print("Waiting for events to load...")
            time.sleep(10)
            
            selectors_to_try = [
                "div.px-2.w-100.d-flex.pointer",
                "div[class*='px-2'][class*='pointer']",
                "div.cal-item[class*='ng-tns']",
                "[class*='cal-item'][class*='ng-star-inserted']"
            ]
            
            clickable_events = []
            for selector in selectors_to_try:
                try:
                    elements = driver.find_elements(By.CSS_SELECTOR, selector)
                    if elements:
                        print(f"Found {len(elements)} elements with selector: {selector}")
                        clickable_events = elements
                        break
                except Exception as e:
                    print(f"Selector {selector} failed: {e}")
                    continue
            
            if not clickable_events:
                print("No clickable events found with any selector")
                driver.quit()
                continue

            soup = BeautifulSoup(driver.page_source, 'html.parser')
            events = soup.select('div.px-2.w-100.d-flex.pointer')
            for event in events:
                if event.find('span', class_="title"):
                    name = event.find('span', class_="title").get_text(strip=True)
                if event.find('small', class_="date"):
                    dates.append(event.find('small', class_="date").get_text(strip=True))
                boy_or_girl = event.find('img')
                if event.find('img'):
                    if 'Girls' in boy_or_girl.get('ngbtooltip'):
                        names.append(name + " - Girls")
                    elif 'Boys' in boy_or_girl.get('ngbtooltip'):
                        names.append(name + " - Boys")

            names = [event.find('span', class_="title").get_text(strip=True) for event in events if event.find('span', class_="title")]
            dates = [event.find('small', class_="date").get_text(strip=True) for event in events if event.find('small', class_="date")]

            locations = []
            print(f"Found {len(clickable_events)} clickable events")
            
            for i, clickable_event in enumerate(clickable_events):
                try:
                    print(f"Attempting to click event {i+1}")
                    
                    driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", clickable_event)
                    time.sleep(2)
                    
                    wait.until(EC.element_to_be_clickable(clickable_event))
                    
                    try:
                        clickable_event.click()
                    except Exception as click_error:
                        print(f"Regular click failed, trying JavaScript click: {click_error}")
                        driver.execute_script("arguments[0].click();", clickable_event)
                    
                    time.sleep(3)
                    
                    soup = BeautifulSoup(driver.page_source, 'html.parser')
                    
                    location_selectors = [
                        'div.cal-item.ng-tns-c342766986-3.ng-star-inserted.item-open',
                        'div[class*="item-open"]',
                        'div[class*="cal-item"][class*="item-open"]'
                    ]
                    
                    location_found = False
                    for loc_selector in location_selectors:
                        open_events = soup.select(loc_selector)
                        if open_events:
                            print(f"Found open event with selector: {loc_selector}")
                            for event in open_events:
                                location_link = event.find('meet-venue-link')
                                location_link = location_link.find('a')
                                if location_link:
                                    location = location_link.get_text(strip=True)
                                    locations.append(location)
                                    print(f"Found location: {location}")
                                    location_found = True
                            break
                    
                    if not location_found:
                        print("No location found for this event")
                        locations.append("Location not found")
                    
                    try:
                        driver.execute_script("document.body.click();")
                        time.sleep(1)
                    except:
                        pass

                except Exception as e:
                    print(f"Error clicking event {i+1}: {e}")
                    locations.append("Error retrieving location")

            # print(names)
            # print(dates)
            # print(locations)
            for name in names:
                if "girls" in name.lower():
                    new_row = pd.DataFrame({
                        "name": [name],
                        "date": [dates[names.index(name)]],
                        "time": ["All Day"],
                        "gender": ["Girls"],
                        "sport": [sport],
                        "level": ["varsity"],
                        "opponent": ["Multiple Schools"],
                        "location": [locations[names.index(name)]],
                        "home": [False],
                    })
                elif "boys" in name.lower():
                    new_row = pd.DataFrame({
                        "name": [name],
                        "date": [dates[names.index(name)]],
                        "time": ["All Day"],
                        "gender": ["Boys"],
                        "sport": [sport],
                        "level": ["varsity"],
                        "opponent": ["Multiple Schools"],
                        "location": [locations[names.index(name)]],
                        "home": [False],
                    })
                else:
                    new_row = pd.DataFrame({
                        "name": [name]*2,
                        "date": [dates[names.index(name)]]*2,
                        "time": ["All Day"]*2,
                        "gender": ["girls", "boys"],
                        "sport": [sport]*2,
                        "level": ["varsity"]*2,
                        "opponent": ["Multiple Schools"]*2,
                        "location": [locations[names.index(name)]]*2,
                        "home": [False]*2,
                    })
                
                df = pd.concat([df, new_row], ignore_index=True)

    return df

# update_track_and_field_schedule()

def update_track_and_field_roster():
    print("===Updating track and field roster===")
    try:
        load_dotenv()
        connect(host=os.environ['MONGODB_URL'])
    except Exception as e:
        print(f"Error connecting to the database: {e}")
        return
    
    for sport in sports:
        url = f"https://www.athletic.net/team/19718/{sport}"
        try:
            response = requests.get(url)
            html_content = response.text
            soup = BeautifulSoup(html_content, 'html.parser')
        except Exception as e:
            print(f"Error parsing HTML content: {e}")
            continue

        athletes = soup.find_all('span', class_='text-truncate')
        athletes = [athlete.get_text(strip=True) for athlete in athletes if athlete.get_text(strip=True)]
        print(athletes)        

# returned_df = update_track_and_field_schedule()

# print(returned_df.head(15))
# print(returned_df.tail(15))

update_track_and_field_roster()