# scraper/main_scraper.py
import praw
import os
import json
from datetime import datetime

def scrape_reddit():
    try:
        # Read environment variables
        reddit = praw.Reddit(
            client_id=os.getenv("REDDIT_CLIENT_ID"),
            client_secret=os.getenv("REDDIT_CLIENT_SECRET"),
            user_agent=os.getenv("REDDIT_USER_AGENT", "salarycheck scraper"),
        )
        
        print("✅ Connected to Reddit API")

        results = []
        subreddit = reddit.subreddit("cscareerquestions+antiwork+forhire")
        
        for submission in subreddit.new(limit=50):
            title = submission.title.lower()
            selftext = (submission.selftext or "").lower()
            
            if any(kw in title or kw in selftext for kw in ['salary', 'offer', 'pay', 'comp']):
                results.append({
                    "title": submission.title,
                    "text": submission.selftext[:300] + "..." if len(submission.selftext) > 300 else submission.selftext,
                    "subreddit": str(submission.subreddit),
                    "url": f"https://reddit.com{submission.permalink}",
                    "created_utc": submission.created_utc,
                })
        return results
    except Exception as e:
        print(f"❌ Reddit Error: {e}")
        return []