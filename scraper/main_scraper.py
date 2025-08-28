# scraper/main.py
import praw
import snscrape.modules.twitter as sntwitter
import json
from datetime import datetime

# --- CONFIG (YOU FILL THESE) ---
REDDIT_CLIENT_ID = "INSERT_YOUR_CLIENT_ID"
REDDIT_CLIENT_SECRET = "INSERT_YOUR_SECRET"
REDDIT_USER_AGENT = "salarycheck-scraper-v1"

# --- SCRAPER FUNCTIONS ---
def scrape_reddit():
    reddit = praw.Reddit(
        client_id=REDDIT_CLIENT_ID,
        client_secret=REDDIT_CLIENT_SECRET,
        user_agent=REDDIT_USER_AGENT
    )
    results = []
    for sub in reddit.subreddit("cscareerquestions+antiwork+forhire").new(limit=100):
        text = (sub.selftext or "")[:300]
        if any(kw in (sub.title + text).lower() for kw in ['salary', 'offer', 'pay', 'comp']):
            results.append({
                "title": sub.title,
                "text": text,
                "subreddit": str(sub.subreddit),
                "url": f"https://reddit.com{sub.permalink}",
                "created": sub.created_utc
            })
    return results

def scrape_x():
    results = []
    for tweet in sntwitter.TwitterSearchScraper("salary OR offer OR compensation").get_items():
        if len(results) >= 50:
            break
        if any(kw in tweet.content.lower() for kw in ['salary', 'offer', 'pay']):
            results.append({
                "user": tweet.user.username,
                "text": tweet.content,
                "url": f"https://twitter.com/user/status/{tweet.id}",
                "created": tweet.date.isoformat()
            })
    return results

# --- RUN ---
if __name__ == "__main__":
    print("🔄 Starting scraper...")
    data = {
        "updated_at": datetime.utcnow().isoformat(),
        "sources": {
            "reddit": scrape_reddit(),
            "x": scrape_x()
        }
    }

    # Save to ../data/salary_data.json
    with open('../data/salary_data.json', 'w') as f:
        json.dump(data, f, indent=2)

    print(f"✅ Saved {len(data['sources']['reddit'])} Reddit + {len(data['sources']['x'])} X posts")