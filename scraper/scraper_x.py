import snscrape.modules.twitter as sntwitter
import pandas as pd

def scrape_x_salary_posts(query="frontend developer salary", limit=50):
    results = []
    for i, tweet in enumerate(sntwitter.TwitterSearchScraper(query).get_items()):
        if i >= limit:
            break
        if any(word in tweet.content.lower() for word in ['offer', 'salary', 'pay', 'comp', 'making $']):
            results.append({
                "user": tweet.user.username,
                "content": tweet.content,
                "date": str(tweet.date),
                "url": f"https://twitter.com/user/status/{tweet.id}",
            })
    return results