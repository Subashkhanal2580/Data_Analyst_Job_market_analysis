CREATE TABLE data_analyst_job_market (
    source VARCHAR(50),
    job_title VARCHAR(100),
    company VARCHAR(100),
    location VARCHAR(100),
    country VARCHAR(50),
    post_date DATE,
    skill_1 VARCHAR(50),
    skill_2 VARCHAR(50),
    skill_3 VARCHAR(50),
    skill_4 VARCHAR(50),
    skill_5 VARCHAR(50),
    skill_6 VARCHAR(50),
    skill_7 VARCHAR(50),
    skill_8 VARCHAR(50),
    position VARCHAR(50)
);

COPY data_analyst_job_market
FROM 'C:\Users\PREODATOR HELIOS 300\Desktop\project_sql\linked_in_job_analysis\cleaning\cleaned_data_final.csv' 
DELIMITER ',' 
CSV HEADER;


select * from data_analyst_job_market;

-- Removing Duplicates
CREATE TABLE job_postings_unique AS
SELECT DISTINCT "job_title", "company", "location", "country", "post_date",
                "skill_1", "skill_2", "skill_3", "skill_4", "skill_5",
                "skill_6", "skill_7", "skill_8", "position"
FROM data_analyst_job_market;

-- Verifying

select * from job_postings_unique;

-- Finding the total number of job_titles in total offered

select distinct(job_title),count(*) as total_number_of_openings
from
job_postings_unique
Group by job_title
order by total_number_of_openings desc;

-- Finding the total number of job_titles based on country

select country,job_title,count(*) as total_number_of_openings
from
job_postings_unique
Group by country,job_title
order by total_number_of_openings desc;

-- Finding the total number of positions offered in different countries

select country,position,count(*) as total_offered
from
job_postings_unique
group by country,position
order by total_offered desc;

-- Data analyst job openings in this year in all the countries till now

select Extract(YEAR from "post_date") as job_posting_year,TO_CHAR("post_date",'Month') as month_name,
count(*) as total_jobs
from
job_postings_unique
group by job_posting_year,month_name
order by total_jobs desc;

-- Data analyst job opening trends per country

select country,Extract(YEAR from "post_date") as job_posting_year,TO_CHAR("post_date",'Month') as job_posted_month,
count(*) as total_jobs
from
job_postings_unique
group by country,job_posting_year,job_posted_month
order by total_jobs desc;


-- Find the total jobs offered for different positions per country,in different years and month

with pos_cte as
(
select country,extract(year from "post_date") as job_posted_year,
TO_CHAR("post_date",'Month') as job_posted_month,position,
count(*) as total_jobs_posted
from
job_postings_unique
Group by country,position,job_posted_year,job_posted_month
order by total_jobs_posted
)
select
country,position,job_posted_year,job_posted_month,total_jobs_posted
from
pos_cte
group by country,position,job_posted_year,job_posted_month,total_jobs_posted
order by total_jobs_posted desc;

-- Find the total number of openings made by the companies in the year 2025

SELECT Company,COUNT(*) AS total_openings_created
FROM job_postings_unique
WHERE 
EXTRACT(YEAR FROM "post_date") = 2025
GROUP BY Company
ORDER BY total_openings_created DESC;

-- Find the total number of openings made by the companies per location in different countries

select company,location,country,count(*) as total_openings_created
from job_postings_unique
where extract(Year from "post_date")=2025
group by company,location,country
order by total_openings_created desc;

-- Find the total number of openings made by companies within a single country and for positions
select company,country,position,count(*) as total_opening
	from
	job_postings_unique
	group by company,country,position
	order by total_opening desc;

-- Transforming skills from multiple columns to a single column for aggregation

CREATE VIEW skills_unpivoted AS
SELECT "job_title", "company", "location", "country", "post_date", "position", "skill_1" AS skill
FROM job_postings_unique WHERE "skill_1" IS NOT NULL
UNION ALL
SELECT "job_title", "company", "location", "country", "post_date", "position", "skill_2"
FROM job_postings_unique WHERE "skill_2" IS NOT NULL
UNION ALL
SELECT "job_title", "company", "location", "country", "post_date", "position", "skill_3"
FROM job_postings_unique WHERE "skill_3" IS NOT NULL
UNION ALL
SELECT "job_title", "company", "location", "country", "post_date", "position", "skill_4"
FROM job_postings_unique WHERE "skill_4" IS NOT NULL
UNION ALL
SELECT "job_title", "company", "location", "country", "post_date", "position", "skill_5"
FROM job_postings_unique WHERE "skill_5" IS NOT NULL
UNION ALL
SELECT "job_title", "company", "location", "country", "post_date", "position", "skill_6"
FROM job_postings_unique WHERE "skill_6" IS NOT NULL
UNION ALL
SELECT "job_title", "company", "location", "country", "post_date", "position", "skill_7"
FROM job_postings_unique WHERE "skill_7" IS NOT NULL
UNION ALL
SELECT "job_title", "company", "location", "country", "post_date", "position", "skill_8"
FROM job_postings_unique WHERE "skill_8" IS NOT NULL;

-- Finding the most common skills
SELECT Skill,COUNT(*) AS frequency
FROM skills_unpivoted
GROUP BY Skill
ORDER BY frequency DESC;

--Most common skills based on the job title
select job_title,Skill,count(*) as frequency
from
skills_unpivoted
Group by job_title,Skill
order by frequency;

-- Most demanded skills for entry level position in different countries
select country,Skill,count(*) as frequency
from
skills_unpivoted
where position = 'Entry level'
Group by country,Skill
order by frequency desc;

-- Top skills by country

with ranked_cte as
(
select country,Skill,count(*) as frequency,
	ROW_NUMBER() over (partition by country order by count(*) desc) as rank
	from skills_unpivoted
	group by country,Skill
)
select country,skill,frequency
from
ranked_cte
order by country,frequency desc;

-- Top skills by position

with ranked_pos_cte as(
select position,Skill,count(*) as frequency,
	Row_number() over (partition by position order by count(*) desc) as rank
	from
	skills_unpivoted
	group by position,Skill
)
select position,skill,frequency
from
ranked_pos_cte
order by position,frequency desc;


-- Skills demand over time

SELECT Extract(YEAR from "post_date") as year,TO_CHAR("post_date",'Month') AS month, Skill, COUNT(*) AS frequency
FROM skills_unpivoted
GROUP BY year,month,Skill
ORDER BY  year,month,frequency DESC;

-- Top 5 locations with the most job postings

select location,count(*) as number_of_postings
from
job_postings_unique
Group by location
order by number_of_postings desc
Limit 5;

-- Total job postings where Python is listed in job postings
select count(*) as total_number_of_job_postings_With_python_as_requirement
from
job_postings_unique
where 'Python' In(skill_1,skill_2,skill_3,skill_4,skill_5,skill_6,skill_7,skill_8);

-- Total job postings where Python and SQLis listed in job postings

select count(*) as total_number_of_job_postings_With_python_as_requirement
from
job_postings_unique
where 'Python'In(skill_1,skill_2,skill_3,skill_4,skill_5,skill_6,skill_7,skill_8)
AND
'SQL'In(skill_1,skill_2,skill_3,skill_4,skill_5,skill_6,skill_7,skill_8);

-- Most commonly demanded first skill by companies based on position

with common_cte as(
select position,skill_1,count(skill_1) as total_count,
Row_number() over (partition by position order by count(skill_1) desc) as rank
from
job_postings_unique
where skill_1 is not null
group by position,skill_1
order by total_count desc
	)
select position,skill_1,total_count
from
common_cte
where rank=1;

-- Companies that have posted more than five openings

SELECT company, COUNT(*) AS total_openings_offered
FROM job_postings_unique
GROUP BY company
HAVING count(*) > 5
ORDER BY total_openings_offered DESC;

-- Companies that have posted more than 2 jobs for the same position

with same_pos_cte as(
select company,
position,count(position) as total_job_offered,
Row_number() over(partition by company order by count(position) desc) as rank
from
job_postings_unique
group by company,position
)
select
company,position,total_job_offered
from
same_pos_cte
where total_job_offered>=2
order by total_job_offered desc;

-- Find the most job openings holding month

with month_cte as (
select To_char(post_date,'Month') as month,count(*) as total_jobs
	from
	job_postings_unique
	group by To_char(post_date,'Month')
)
select month,total_jobs
from
month_cte
order by total_jobs desc
limit 1;

-- List all the companies that posted job in 2025 in month of february

SELECT *
FROM job_postings_unique
WHERE TO_CHAR(post_date, 'YYYY-MM') LIKE '2025-02%';


-- List all the jobs offered in different countries in the month of febrauary in 2025

select country,count(country) as total_jobs_in_feb
from
job_postings_unique
where post_date>'2025-02-01'
And
post_date<'2025-03-01'
group by country
order by total_jobs_in_feb desc;

-- Total number of entry level jobs in 2024 and 2025

select extract(year from "post_date") as year,count(*) as total_jobs
from
job_postings_unique
where
position='Entry level'
group by extract(year from "post_date");

-- Company with the highest number of job posting in each country

with temp_cte as(
select company,country,count(*) as total_job_posted,
Dense_rank() over (partition by country order by count(*) desc) as rank
from
job_postings_unique
group by company,country
	)
select company,country,total_job_posted
from
temp_cte
where
rank=1
order by total_job_posted desc;

-- Average skills required per job

WITH skill_counts AS (
    SELECT
		country,position,
        (CASE WHEN skill_1 IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN skill_2 IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN skill_3 IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN skill_4 IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN skill_5 IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN skill_6 IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN skill_7 IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN skill_8 IS NOT NULL THEN 1 ELSE 0 END) AS skill_count
    FROM job_postings_unique
)
SELECT country,position,AVG(skill_count) AS avg_skills
FROM skill_counts
group by country,position;

-- Top 5 skills required

create view top_five_skill_required as
select Skill,count(*) as frequency
from
skills_unpivoted
group by Skill
order by frequency desc ;

-- The top 5 required skills
create view top_five_skill_required as
select Skill,count(*) as frequency
from
skills_unpivoted
group by Skill
order by frequency desc
limit 5;

-- Top 3 skills required per position
create view top_three_skill_required_per_position as
with pos_skill_cte as (
    select 
        position,
        Skill,
        count(*) as frequency,
        Row_number() over (partition by position order by count(*) desc) as rank
    from skills_unpivoted
    group by position, Skill
)
select 
    position,
    Skill,
    frequency
from pos_skill_cte
where rank <= 3
order by frequency desc;

-- Top 3 skills per country

create view top_three_skill_required_per_country as
with count_skill_cte as (
    select 
        country,
        Skill,
        count(*) as frequency,
        Row_number() over (partition by country order by count(*) desc) as rank
    from
        skills_unpivoted
    group by 
        country,
        Skill
)
select 
    country,
    Skill,
    frequency
from count_skill_cte
where rank <= 3
order by frequency desc;

-- Top trends per year and month on skills

create view time_trend_with_skill as
with time_skill_cte as(
select Extract(year from "post_date") as year,
	To_char("post_date",'Month') as month,
	Skill,
	count(*) as total_in_job_demand,
	Row_number() over (partition by Extract(year from "post_date"),To_char("post_date",'Month') order by count(*) desc) as rank
	from
	skills_unpivoted
	group by
	Extract(year from "post_date"),
	To_char("post_date",'Month'),
	Skill
)
select 
year,
month,
Skill,
total_in_job_demand
from
time_skill_cte
order by year,month,rank;


-- Top ten companies by job posting

create view company_with_most_opening_in_total as
select company,count(*) as total_jobs_offered
from
skills_unpivoted
group by company
order by total_jobs_offered desc
limit 10;

-- Top ten companies with most jobs offered in 2025

create view company_with_most_opening_in_2024 as
select company,count(*) as frequency
from
skills_unpivoted
where extract(year from "post_date")=2025
group by company
order by frequency desc
limit 10;

-- Top positions offered by companies

create view company_with_most_opening_for_diff_position as
with com_pos_cte as(
select company,position,count(*) as frequency,
row_number () over (partition by company,position order by count(*) desc)as rank
from
skills_unpivoted
group by company,position
order by frequency desc
)
select company,position,frequency
from
com_pos_cte
where
rank<=3;

-- Total number of openings for the positions based on the companies

create view total_positions_across_companies as
select position,count(*) as frequency
from
skills_unpivoted
group by position
order by frequency desc;



