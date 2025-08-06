from datetime import datetime

def tenevents(announcements, events, athletics):
    now = datetime.now()

    carousel = []

    announcement_dates = [{"date":announcement['end_date'], "index": index, "type": "Announcement"} for index, announcement in enumerate(announcements)]
    event_dates = [{"date":event['date'], "index": index, "type": "Event"} for index, event in enumerate(events)]
    athletics_dates = [{"date":schedule['date'], "index": index, "type": "Athletics"} for index, schedule in enumerate(athletics)]

    # Athletics schedule in MMM DD YYYY, convert it to MM/DD/YYYY format
    for date in athletics_dates:
        try:
            date['date'] = datetime.strptime(date['date'], '%b %d %Y').strftime('%m/%d/%Y')
        except ValueError:
            if '-' in date['date']:
                date['date'] = date["date"].split('-')[0].strip()
            date['date'] = datetime.strptime(date['date'], '%a, %b %d').replace(year=athletics[date['index']]["createdAt"].year).strftime('%m/%d/%Y')

    all_dates = announcement_dates + event_dates + athletics_dates
    all_dates.sort(key=lambda x: datetime.strptime(x['date'], '%m/%d/%Y'))
    
    for date in all_dates:
        if datetime.strptime(date['date'], '%m/%d/%Y') >= now:
            i = all_dates.index(date)
            all_dates = all_dates[i:i+10]
            break

    for date in all_dates[-10:]:
        if date["type"] == "Announcement":
            carousel.append(announcements[date["index"]])
        elif date["type"] == "Event":
            carousel.append(events[date["index"]])
        elif date["type"] == "Athletics":
            carousel.append(athletics[date["index"]])

    return carousel
