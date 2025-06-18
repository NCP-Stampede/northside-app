from bs4 import BeautifulSoup
import requests

url = "https://www.northsideprepathletics.com/schedule?year=2025-2026"
response = requests.get(url)
html_content = response.text

soup = BeautifulSoup(html_content, 'html.parser')

repeated_dates = soup.find_all('h3', class_='uppercase')
exact_dates = [h3 for h3 in repeated_dates if h3.get('class') == ['uppercase']]
dates = [h3.get_text(strip=True) for h3 in exact_dates]
# print(dates)

times = soup.select('p.text-base.font-bold[data-testid*="time"]')
times = [p.get_text(strip=True) for p in times]
# print(times)

sports = soup.select("p.text-base.font-bold[data-testid*='activity-name']")
sports = [p.get_text(strip=True) for p in sports]
# print(sports)

locations = soup.select("p.text-sm.font-medium[data-testid*='venue']")
locations = [p.get_text(strip=True) for p in locations]
# print(locations)

teams = soup.select("div.text-sm.font-medium.text-core-contrast.text-opacity-80.xl\\:text-base[data-testid*='gender-level']")
teams = [p.get_text(strip=True) for p in teams]
# print(teams)

home = soup.select("div.inline-flex.items-center.gap-1")
home = [div.get_text(strip=True) for div in home]
home = [item == "Home" for item in home]
# print(home)

length = len(dates)
schedule = []
for i in range(length):
    schedule.append({
        "date": dates[i],
        "time": times[i],
        "sport": sports[i],
        "team": teams[i],
        "location": locations[i],
        "home": home[i]
    })

print(schedule)

