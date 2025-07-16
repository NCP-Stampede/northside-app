from bs4 import BeautifulSoup
import requests
    
url = "https://www.maxpreps.com/il/chicago/northside-mustangs/"
    
try:
        response = requests.get(url)
        html_content = response.text
        soup = BeautifulSoup(html_content, 'html.parser')
except Exception as e:
        print(f"Error parsing HTML content: {e}")
    
sports = soup.find_all('span', class_="sport-name")
sports = [sport.get_text(strip=True).replace("& ", "").replace(" ", "-").lower() for sport in sports]
sports = list(set(sports))

genders = ["girls", "boys"]
seasons = ["fall", "winter", "spring"]
level = "varsity"

sports_data = []

for sport in sports:
        for gender in genders:
            for season in seasons:
                    url = f"https://www.maxpreps.com/il/chicago/northside-mustangs/{sport}/{gender}/{level}/{season}/roster/"
                    # url = f"https://www.maxpreps.com/il/chicago/northside-mustangs/{sport}/{gender}/{level}/{season}/24-25/roster/"
                    try:
                        response = requests.get(url, timeout=(10, 30))
                        response.raise_for_status()
                    except requests.RequestException as e:
                        print(f"Error fetching {url}: {e}")
                        continue

                    sports_data.append({
                        "sport": sport,
                        "season": season,
                        "gender": gender
                    })

print(sports_data)

