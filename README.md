# Netflix Movies and TV Shows Data Analysis using SQL

![](logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
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
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT
	type,
	COUNT(*) AS Total
FROM [dbo].[netflix]
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT title FROM [dbo].[netflix]
WHERE release_year = 2020 AND type = 'Movie';
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT TOP 5
	TRIM(s.value) AS country,
	COUNT(*) AS total_content
FROM [dbo].[netflix] n
CROSS APPLY STRING_SPLIT (n.country,',') s
WHERE s.value IS NOT NULL AND TRIM(s.value) <> ''
GROUP BY TRIM(s.value)
ORDER BY total_content DESC;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT TOP 1
	*
FROM [dbo].[netflix]
WHERE type = 'Movie'
ORDER BY CAST (LEFT (TRIM(duration),CHARINDEX(' ',TRIM(duration)) -1) AS INT) DESC;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT 
	*
FROM [dbo].[netflix]
WHERE date_added > DATEADD(YEAR,-5,GETDATE())
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT
	n.*
FROM [dbo].[netflix] n
CROSS APPLY string_split (n.director,',') s
WHERE TRIM(s.value) = 'Rajiv Chilaka';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT * FROM [dbo].[netflix]
WHERE type = 'TV Show'
	  AND CAST(LEFT(TRIM(duration),CHARINDEX(' ',TRIM(duration))-1) AS INT) > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
	TRIM(s.value) AS Genre,
	COUNT(*) AS Total_Content
FROM [dbo].[netflix] n
CROSS APPLY string_split (TRIM(n.listed_in),',') s
WHERE s.value IS NOT NULL AND TRIM(s.value) <> ''
GROUP BY TRIM(s.value)
ORDER BY Genre;
```

**Objective:** Count the number of content items in each genre.

### 10.Find top 5 year with highest numbers of content release in India on netflix.
return top 5 year with highest content release!

```sql
SELECT TOP 5
	TRIM(s.value) AS country,
	YEAR(n.date_added),
	COUNT(*) AS Total_Content
FROM [dbo].[netflix] n
CROSS APPLY string_split (TRIM(n.country),',') s
WHERE TRIM(s.value) = 'India'
GROUP BY TRIM(s.value),YEAR(n.date_added)
ORDER BY Total_Content DESC;
```

**Objective:** Calculate and show years by the number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT * FROM [dbo].[netflix]
WHERE type = 'Movie' AND listed_in LIKE '%Documentaries%'
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * FROM [dbo].[netflix]
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT 
	TRIM(s.value) AS Cast,
	COUNT(*) AS Total_Movie
FROM [dbo].[netflix] n
CROSS APPLY string_split (TRIM(n.cast),',') s
WHERE s.value = 'Salman Khan' AND n.release_year > YEAR(GETDATE()) - 10
GROUP BY TRIM(s.value);
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT TOP 10
	TRIM(a.value) AS Actor,
	COUNT(*) AS Appearance
FROM [dbo].[netflix] n
CROSS APPLY string_split (TRIM(n.country),',') c
CROSS APPLY string_split (TRIM(n.cast),',') a
WHERE TRIM(c.value) = 'India'
GROUP BY TRIM(a.value)
ORDER BY Appearance DESC;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.
