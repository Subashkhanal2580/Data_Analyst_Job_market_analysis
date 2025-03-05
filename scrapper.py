import requests
from bs4 import BeautifulSoup
import pandas as pd
import time
import random

# Generic headers to mimic a browser
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

# Function to scrape LinkedIn jobs
def scrape_linkedin_jobs(keywords="data analyst", locations=["United States"], max_pages=10):
    base_url = "https://www.linkedin.com/jobs/search/"
    all_job_data = []
    for location in locations:
        print(f"\nScraping LinkedIn jobs for location: {location}")
        for page in range(max_pages):
            url = f"{base_url}?keywords={keywords}&location={location}&start={page * 25}"
            print(f"Scraping page {page + 1}: {url}")
            response = requests.get(url, headers=headers)
            if response.status_code != 200:
                print(f"Failed to retrieve page {page + 1}. Status code: {response.status_code}")
                break
            soup = BeautifulSoup(response.text, 'html.parser')
            job_cards = soup.find_all('div', class_='base-card')
            for job in job_cards:
                try:
                    title = job.find('h3', class_='base-search-card__title')
                    title = title.text.strip() if title else "N/A"
                    company = job.find('h4', class_='base-search-card__subtitle')
                    company = company.text.strip() if company else "N/A"
                    loc = job.find('span', class_='job-search-card__location')
                    loc = loc.text.strip() if loc else location
                    post_date = job.find('time', class_='job-search-card__listdate')
                    post_date = post_date['datetime'] if post_date else "N/A"
                    job_link = job.find('a', class_='base-card__full-link')
                    job_link = job_link['href'] if job_link else None

                    if job_link:
                        job_response = requests.get(job_link, headers=headers)
                        if job_response.status_code != 200:
                            print(f"Failed to retrieve job page: {job_link}")
                            continue
                        job_soup = BeautifulSoup(job_response.text, 'html.parser')
                        job_type = job_soup.find('span', class_='job-criteria__text--criteria')
                        job_type = job_type.text.strip() if job_type else "N/A"
                        experience = job_soup.find('span', string='Seniority level')
                        experience = experience.find_next('span').text.strip() if experience else "N/A"
                        skills_section = job_soup.find('div', class_='description__text')
                        skills = skills_section.text.strip() if skills_section else "N/A"
                        common_skills = ['Python', 'SQL', 'Excel', 'Tableau', 'Power BI', 'R', 'Statistics', 'Machine Learning']
                        skills_found = [skill for skill in common_skills if skill.lower() in skills.lower()]
                        skills_required = ", ".join(skills_found) if skills_found else "N/A"
                        salary = job_soup.find('span', class_='job-criteria__text--criteria', string='Compensation')
                        salary = salary.find_next('span').text.strip() if salary else "N/A (Not Listed)"
                        industry = job_soup.find('span', string='Industries')
                        industry = industry.find_next('span').text.strip() if industry else "N/A"
                        company_size = job_soup.find('span', string='Company size')
                        company_size = company_size.find_next('span').text.strip() if company_size else "N/A"
                        desc_summary = skills[:100].strip() if skills != "N/A" else "N/A"
                    else:
                        job_type = experience = skills_required = salary = industry = company_size = desc_summary = "N/A"
                        salary = "N/A (Not Listed)"

                    all_job_data.append({
                        "Source": "LinkedIn",
                        "Job Title": title,
                        "Company": company,
                        "Location": loc,
                        "Country": location,
                        "Job Type": job_type,
                        "Experience Required": experience,
                        "Skills Required": skills_required,
                        "Salary": salary,
                        "Post Date": post_date,
                        "Industry": industry,
                        "Company Size": company_size,
                        "Description Summary": desc_summary,
                        "Job URL": job_link
                    })
                except Exception as e:
                    print(f"Error parsing LinkedIn job: {e}")
            time.sleep(random.uniform(2, 5))
    return all_job_data

# Function to scrape Indeed jobs
def scrape_indeed_jobs(keywords="data analyst", locations=["United States"], max_pages=10):
    base_url = "https://www.indeed.com/jobs"
    all_job_data = []
    for location in locations:
        print(f"\nScraping Indeed jobs for location: {location}")
        for page in range(max_pages):
            url = f"{base_url}?q={keywords}&l={location}&start={page * 10}"
            print(f"Scraping page {page + 1}: {url}")
            response = requests.get(url, headers=headers)
            if response.status_code != 200:
                print(f"Failed to retrieve page {page + 1}. Status code: {response.status_code}")
                break
            soup = BeautifulSoup(response.text, 'html.parser')
            job_cards = soup.find_all('div', class_='job_seen_beacon')
            for job in job_cards:
                try:
                    title = job.find('h2', class_='jobTitle')
                    title = title.text.strip() if title else "N/A"
                    company = job.find('span', class_='companyName')
                    company = company.text.strip() if company else "N/A"
                    loc = job.find('div', class_='companyLocation')
                    loc = loc.text.strip() if loc else location
                    post_date = job.find('span', class_='date')
                    post_date = post_date.text.strip() if post_date else "N/A"
                    job_link = job.find('a', class_='jcs-JobTitle')
                    job_link = "https://www.indeed.com" + job_link['href'] if job_link else None

                    if job_link:
                        job_response = requests.get(job_link, headers=headers)
                        if job_response.status_code != 200:
                            print(f"Failed to retrieve job page: {job_link}")
                            continue
                        job_soup = BeautifulSoup(job_response.text, 'html.parser')
                        desc = job_soup.find('div', class_='jobsearch-jobDescriptionText')
                        desc_text = desc.text.strip() if desc else "N/A"
                        common_skills = ['Python', 'SQL', 'Excel', 'Tableau', 'Power BI', 'R', 'Statistics', 'Machine Learning']
                        skills_found = [skill for skill in common_skills if skill.lower() in desc_text.lower()]
                        skills_required = ", ".join(skills_found) if skills_found else "N/A"
                        desc_summary = desc_text[:100].strip() if desc_text != "N/A" else "N/A"
                        salary = job_soup.find('div', class_='jobsearch-JobMetadataHeader-item')
                        salary = salary.text.strip() if salary else "N/A (Not Listed)"
                    else:
                        skills_required = desc_summary = "N/A"
                        salary = "N/A (Not Listed)"

                    all_job_data.append({
                        "Source": "Indeed",
                        "Job Title": title,
                        "Company": company,
                        "Location": loc,
                        "Country": location,
                        "Job Type": "N/A",
                        "Experience Required": "N/A",
                        "Skills Required": skills_required,
                        "Salary": salary,
                        "Post Date": post_date,
                        "Industry": "N/A",
                        "Company Size": "N/A",
                        "Description Summary": desc_summary,
                        "Job URL": job_link
                    })
                except Exception as e:
                    print(f"Error parsing Indeed job: {e}")
            time.sleep(random.uniform(2, 5))
    return all_job_data

# Function to scrape Glassdoor jobs
def scrape_glassdoor_jobs(keywords="data analyst", locations=["United States"], max_pages=10):
    base_url = "https://www.glassdoor.com/Job/jobs.htm"
    all_job_data = []
    for location in locations:
        print(f"\nScraping Glassdoor jobs for location: {location}")
        for page in range(max_pages):
            url = f"{base_url}?suggestCount=0&suggestChosen=false&clickSource=searchBtn&typedKeyword={keywords}&locT=C&locName={location}&jobType=&fromAge=&radius=50&pgc={page + 1}"
            print(f"Scraping page {page + 1}: {url}")
            response = requests.get(url, headers=headers)
            if response.status_code != 200:
                print(f"Failed to retrieve page {page + 1}. Status code: {response.status_code}")
                break
            soup = BeautifulSoup(response.text, 'html.parser')
            job_cards = soup.find_all('li', class_='react-job-listing')
            for job in job_cards:
                try:
                    title = job.find('a', class_='jobLink')
                    title = title.text.strip() if title else "N/A"
                    company = job.find('div', class_='jobEmpRating')
                    company = company.find_previous_sibling('a').text.strip() if company else "N/A"
                    loc = job.find('span', class_='loc')
                    loc = loc.text.strip() if loc else location
                    post_date = job.find('span', class_='datePosted')
                    post_date = post_date.text.strip() if post_date else "N/A"
                    job_link = job.find('a', class_='jobLink')
                    job_link = "https://www.glassdoor.com" + job_link['href'] if job_link else None

                    if job_link:
                        job_response = requests.get(job_link, headers=headers)
                        if job_response.status_code != 200:
                            print(f"Failed to retrieve job page: {job_link}")
                            continue
                        job_soup = BeautifulSoup(job_response.text, 'html.parser')
                        desc = job_soup.find('div', class_='jobDescriptionContent')
                        desc_text = desc.text.strip() if desc else "N/A"
                        common_skills = ['Python', 'SQL', 'Excel', 'Tableau', 'Power BI', 'R', 'Statistics', 'Machine Learning']
                        skills_found = [skill for skill in common_skills if skill.lower() in desc_text.lower()]
                        skills_required = ", ".join(skills_found) if skills_found else "N/A"
                        desc_summary = desc_text[:100].strip() if desc_text != "N/A" else "N/A"
                        salary = job_soup.find('span', class_='salary-estimate')
                        salary = salary.text.strip() if salary else "N/A (Not Listed)"
                    else:
                        skills_required = desc_summary = "N/A"
                        salary = "N/A (Not Listed)"

                    all_job_data.append({
                        "Source": "Glassdoor",
                        "Job Title": title,
                        "Company": company,
                        "Location": loc,
                        "Country": location,
                        "Job Type": "N/A",
                        "Experience Required": "N/A",
                        "Skills Required": skills_required,
                        "Salary": salary,
                        "Post Date": post_date,
                        "Industry": "N/A",
                        "Company Size": "N/A",
                        "Description Summary": desc_summary,
                        "Job URL": job_link
                    })
                except Exception as e:
                    print(f"Error parsing Glassdoor job: {e}")
            time.sleep(random.uniform(2, 5))
    return all_job_data

# Main function to scrape from all platforms
def scrape_all_platforms(keywords="data analyst", locations=["United States"], max_pages=10):
    all_jobs = []
    all_jobs.extend(scrape_linkedin_jobs(keywords, locations, max_pages))
    all_jobs.extend(scrape_indeed_jobs(keywords, locations, max_pages))
    all_jobs.extend(scrape_glassdoor_jobs(keywords, locations, max_pages))
    return all_jobs

# List of target locations
locations = ["United States", "Australia", "Canada", "India", "Singapore"]

# Execute the scraper for all platforms
jobs = scrape_all_platforms(keywords="data analyst", locations=locations, max_pages=10)

# Save to CSV
df = pd.DataFrame(jobs)
df.to_csv("data_analyst_jobs_multiplatform.csv", index=False)
print("Data saved to data_analyst_jobs_multiplatform.csv")