# scraper/main_scraper.py
import praw
import os
import json
from datetime import datetime

def scrape_reddit():
    reddit = praw.Reddit(
        client_id=os.getenv("REDDIT_CLIENT_ID"),
        client_secret=os.getenv("REDDIT_CLIENT_SECRET"),
        user_agent=os.getenv("REDDIT_USER_AGENT", "salarycheck scraper"),
    )
    results = []
    for submission in reddit.subreddit("cscareerquestions+antiwork+forhire").new(limit=50):
        text = (submission.selftext or "").lower()
        title = submission.title.lower()
        if any(kw in title or kw in text for kw in ['salary', 'offer', 'pay']):
            results.append({
                "title": submission.title,
                "text": text[:300],
                "subreddit": str(submission.subreddit),
                "url": f"https://reddit.com{submission.permalink}",
            })
    return results

def scrape_x():
    return []  # Skip for now

if __name__ == "__main__":
    print("🔄 Starting scraper...")
    data = {
        "updated_at": datetime.now().isoformat() + "Z",
        "sources": {
            "reddit": scrape_reddit(),
            "x": []
        }
    }

    os.makedirs('../data', exist_ok=True)
    with open('../data/salary_data.json', 'w') as f:
        json.dump(data, f, indent=2)

    print(f"✅ Saved {len(data['sources']['reddit'])} Reddit posts to ../data/salary_data.json")