CREATE DATABASE netflix_db;

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix (
	show_id			VARCHAR(5),
	type			VARCHAR(10),
	title			VARCHAR(250),
	director		VARCHAR(550),
	cast			VARCHAR(1050),
	country			VARCHAR(550),
	date_added		DATE,
	release_year	INT,
	rating			VARCHAR(15),
	duration		VARCHAR(15),
	listed_in		VARCHAR(250),
	description		VARCHAR(550)
);

-- staging table
SELECT * FROM [dbo].[staging_netflix];

INSERT INTO [dbo].[netflix]
SELECT *
FROM [dbo].[staging_netflix];

SELECT * FROM [dbo].[netflix];

-- Business Problems

-- 1. Count the Number of Movies vs TV Shows
SELECT
	type,
	COUNT(*) AS Total
FROM [dbo].[netflix]
GROUP BY type;

-- 2. Find the Most Common Rating for Movies and TV Shows
SELECT
	type,
	rating
FROM
(
SELECT
	type,
	rating,
	COUNT(*) AS Total_Rating,
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS Ranking
FROM [dbo].[netflix]
GROUP BY type,rating
)t
WHERE Ranking = 1;

-- 3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT title FROM [dbo].[netflix]
WHERE release_year = 2020 AND type = 'Movie';

-- 4. Find the Top 5 Countries with the Most Content on Netflix
SELECT TOP 5
	TRIM(s.value) AS country,
	COUNT(*) AS total_content
FROM [dbo].[netflix] n
CROSS APPLY STRING_SPLIT (n.country,',') s
WHERE s.value IS NOT NULL AND TRIM(s.value) <> ''
GROUP BY TRIM(s.value)
ORDER BY total_content DESC;

-- 5. Identify the Longest Movie
SELECT TOP 1
	*
FROM [dbo].[netflix]
WHERE type = 'Movie'
ORDER BY CAST (LEFT (TRIM(duration),CHARINDEX(' ',TRIM(duration)) -1) AS INT) DESC;

-- 6. Find Content Added in the Last 5 Years
SELECT 
	*
FROM [dbo].[netflix]
WHERE date_added > DATEADD(YEAR,-5,GETDATE())

-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT
	n.*
FROM [dbo].[netflix] n
CROSS APPLY string_split (n.director,',') s
WHERE TRIM(s.value) = 'Rajiv Chilaka';

-- 8. List All TV Shows with More Than 5 Seasons
SELECT * FROM [dbo].[netflix]
WHERE type = 'TV Show'
	  AND CAST(LEFT(TRIM(duration),CHARINDEX(' ',TRIM(duration))-1) AS INT) > 5;

-- 9. Count the Number of Content Items in Each Genre
SELECT 
	TRIM(s.value) AS Genre,
	COUNT(*) AS Total_Content
FROM [dbo].[netflix] n
CROSS APPLY string_split (TRIM(n.listed_in),',') s
WHERE s.value IS NOT NULL AND TRIM(s.value) <> ''
GROUP BY TRIM(s.value)
ORDER BY Genre;

-- 10.Find top 5 year with highest numbers of content release in India on netflix.
SELECT TOP 5
	TRIM(s.value) AS country,
	YEAR(n.date_added),
	COUNT(*) AS Total_Content
FROM [dbo].[netflix] n
CROSS APPLY string_split (TRIM(n.country),',') s
WHERE TRIM(s.value) = 'India'
GROUP BY TRIM(s.value),YEAR(n.date_added)
ORDER BY Total_Content DESC;

-- 11. List All Movies that are Documentaries
SELECT * FROM [dbo].[netflix]
WHERE type = 'Movie' AND listed_in LIKE '%Documentaries%'

-- 12. Find All Content Without a Director
SELECT * FROM [dbo].[netflix]
WHERE director IS NULL;

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT 
	TRIM(s.value) AS Cast,
	COUNT(*) AS Total_Movie
FROM [dbo].[netflix] n
CROSS APPLY string_split (TRIM(n.cast),',') s
WHERE s.value = 'Salman Khan' AND n.release_year > YEAR(GETDATE()) - 10
GROUP BY TRIM(s.value);

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT TOP 10
	TRIM(a.value) AS Actor,
	COUNT(*) AS Appearance
FROM [dbo].[netflix] n
CROSS APPLY string_split (TRIM(n.country),',') c
CROSS APPLY string_split (TRIM(n.cast),',') a
WHERE TRIM(c.value) = 'India'
GROUP BY TRIM(a.value)
ORDER BY Appearance DESC;

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT
	Category,
	COUNT(*) AS Total
FROM
(
SELECT 
	CASE
		WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
		ELSE 'Good'
	END AS Category
FROM [dbo].[netflix]
)t
GROUP BY Category;