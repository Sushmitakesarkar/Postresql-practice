Select job_posted_date
FROM job_postings_fact
LIMIT 50;

/* Change timestamp to only date
/* ::   used for converting data type  
*/
Select '2023-04-03'::DATE

Select 
    job_title as title,
    job_location as location,
    job_posted_date as date
FROM
    job_postings_fact
Limit 5;

/*Time zone */
Select 
    job_title as title,
    job_location as location,
    job_posted_date at Time zone 'UTC' at Time zone'EST' as date
FROM
    job_postings_fact
Limit 5;

/*Extract */
Select 
    job_title as title,
    job_location as location,

    EXTRACT(month From job_posted_date) as date_month,
    Extract(year From job_posted_date) as date_year
FROM
    job_postings_fact
Limit 5;


/*count job ids acc to month*/
Select 
    Count (job_id) as Total_jobs,
    EXTRACT(month From job_posted_date) as month
    
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    month
Order BY 
    month;


--Practice Problems
CREATE Table january_jobs AS
    Select *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH From job_posted_date) =1;

CREATE Table February_jobs AS
    Select *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH From job_posted_date) =2;

CREATE Table March_jobs AS
    Select *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH From job_posted_date) =3;



--CASE
Select 
    job_title_short,
    job_location,
    CASE
        WHEN job_location='Anywhere' THEN 'Remote'
        WHEN job_location='New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact;

--Count
Select
    COUNT(job_id) AS Number_of_jobs,
    CASE
        WHEN job_location='Anywhere' THEN 'Remote'
        WHEN job_location='New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact
GROUP BY location_category

--Subquery
    Select *
    FROM(
        Select *
        FROM job_postings_fact
        WHERE EXTRACT(MONTH From job_posted_date) =1)--Subquery ends here
        AS january_jobs;

--CTE A temporary result set we can refrence later 
--(Used for reusing this code and for readability usually with a 'with statement')

With january_jobs AS(
        Select *
        FROM job_postings_fact
        WHERE EXTRACT(MONTH From job_posted_date) =1)--CTE

Select*
From january_jobs;

-- companies hiring without a degree mandate
Select
    company_id,
    name AS company_name
FROM
    company_dim
WHERE company_id IN (
    Select
            company_id
    FROM
            job_postings_fact
    WHERE
            job_no_degree_mention= true
    ORDER BY   company_id
)

--Find companies thathave the most job openings
--Get the total no. of job_postings per company_id(jobs_postings_fact)
--Return the total no. of jobs with the company name(company_dim)
WITH company_job_count AS (
    Select
        company_id,
        COUNT(*) AS total_jobs
    FROM
        job_postings_fact
    GROUP BY company_id
)

Select 
    company_dim.name AS company_name,
    company_job_count.total_jobs
From company_dim
Left join company_job_count ON company_job_count.company_id=company_dim.company_id
ORDER BY 
    total_jobs DESC

--Find no. of remote job pstings per skill
-- Display the top 5 skills by their demand in remote jobs
--Include skilll ID,name and count of postings requiring the skill
with remote_job_skills AS (
    Select
        
        skill_id,
        Count(*) AS skill_count
    FROM
        skills_job_dim AS skills_to_job
    INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
    WHERE
        job_postings.job_work_from_home = true and 
        job_postings.job_title_short='Data Analyst'
    GROUP BY
        skill_id
)
Select 
    skills.skill_id,
    skills AS skill_name,
    skill_count
FROM remote_job_skills
Inner JOIN skills_dim AS skills ON skills.skill_id=remote_job_skills.skill_id
ORDER BY skill_count DESC

Limit 5;



--Union Operators
Select 
    job_title_short,
    company_id,
    job_location
FROM
    january_jobs
UNION

Select 
    job_title_short,
    company_id,
    job_location
FROM
    February_jobs
UNION
Select 
    job_title_short,
    company_id,
    job_location
FROM
    March_jobs

-- Find job postings from first quatermakihng
--more than 70 k
Select 
    quarter1_job_postings.job_title_short,
    quarter1_job_postings.job_location,
    quarter1_job_postings.job_via,
    quarter1_job_postings.job_posted_date::date,
    quarter1_job_postings.salary_year_avg
FROM(
    Select *
    FROM january_jobs
    UNION ALL
    Select *
    FROM February_jobs
    UNION ALl
    Select *
    From March_jobs
) AS quarter1_job_postings
WHERE
    quarter1_job_postings.salary_year_avg > 70000 and
    quarter1_job_postings.job_title_short = 'Data Analyst'
ORDER BY 
    quarter1_job_postings.salary_year_avg DESC



