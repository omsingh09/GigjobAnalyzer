import requests
from bs4 import BeautifulSoup
import json
from elasticsearch import Elasticsearch

# Elasticsearch connection
es = Elasticsearch("http://localhost:9200")

# Scrape job listings
def scrape_jobs():
    url = "https://remoteok.io/remote-dev-jobs"
    headers = {"User-Agent": "Mozilla/5.0"}
    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        soup = BeautifulSoup(response.text, "html.parser")
        job_listings = []

        for job_card in soup.find_all("tr", class_="job"):
            title = job_card.find("h2").text.strip() if job_card.find("h2") else "N/A"
            company = job_card.find("h3").text.strip() if job_card.find("h3") else "N/A"
            location = job_card.find("div", class_="location").text.strip() if job_card.find("div", class_="location") else "Remote"
            job_type = job_card.find("div", class_="tags").text.strip() if job_card.find("div", class_="tags") else "N/A"

            job_listings.append({
                "title": title,
                "company": company,
                "location": location,
                "type": job_type
            })

        # Save to JSON file
        with open("data/scraped_jobs.json", "w") as file:
            json.dump(job_listings, file, indent=4)

        print(f"{len(job_listings)} jobs scraped successfully.")
        return job_listings
    else:
        print("Failed to fetch job listings.")
        return []

# Load data into Elasticsearch
def load_into_elasticsearch():
    with open("data/scraped_jobs.json", "r") as file:
        jobs = json.load(file)

    for i, job in enumerate(jobs):
        es.index(index="gig-jobs", id=i, document=job)

    print("Data indexed into Elasticsearch.")

if __name__ == "__main__":
    jobs = scrape_jobs()
    load_into_elasticsearch()
