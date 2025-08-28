import praw

# Reddit API Setup (get these from https://www.reddit.com/prefs/apps)
reddit = praw.Reddit(
    client_id="YOUR_CLIENT_ID",
    client_secret="YOUR_CLIENT_SECRET",
    user_agent="SalaryCheck Bot 1.0"
)

def scrape_reddit_salary_posts(limit=100):
    keywords = ["salary", "offer", "compensation", "pay", "making $"]
    results = []

    for submission in reddit.subreddit("cscareerquestions+antiwork+forhire").new(limit=limit):
        title = submission.title.lower()
        selftext = submission.selftext.lower()

        if any(kw in title or kw in selftext for kw in keywords):
            # Extract simple info
            results.append({
                "title": submission.title,
                "text": submission.selftext[:300] + "..." if len(submission.selftext) > 300 else submission.selftext,
                "subreddit": submission.subreddit.display_name,
                "url": f"https://reddit.com{submission.permalink}",
                "created": submission.created_utc,
            })

    return results