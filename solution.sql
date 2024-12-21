--Netflix Project--
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix 
(
show_id VARCHAR(6),
type VARCHAR(10),
title VARCHAR(150),
director VARCHAR(208),
casts VARCHAR(1000),
country VARCHAR(150),
date_added VARCHAR(50),
release_year INT,
rating VARCHAR(10),
duration VARCHAR(15),
listed_in VARCHAR(100),
description VARCHAR(250)
);

SELECT * FROM netflix;

SELECT COUNT(*) AS total_content FROM netflix;

--15 BUISNESS PROBLEMS--

--1.COUNT NO OF MOVIES VS TV SHOWS --
SELECT type,COUNT(*) as total_content
FROM netflix
GROUP BY type;

--2.Find the most common rating for movies and tv shows --
SELECT type,rating FROM(
SELECT type,rating,
COUNT(*),
RANK()OVER(PARTITION BY type ORDER BY COUNT(*) DESC)AS ranking
FROM netflix
GROUP BY 1,2) AS t1
WHERE ranking=1;

--3.List all movies released in a specific year (e.g.2020)--
SELECT title FROM netflix  WHERE type='Movie' AND release_year=2020;

--4.Find the top 5 countries with the most content on netflix--
SELECT UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
COUNT(show_id)
FROM netflix
GROUP BY 1
ORDER BY 2 Desc LIMIT 5;

--5.Identify the longest movie--
SELECT *
FROM netflix
WHERE type='Movie' AND
duration=(SELECT MAX(duration) FROM netflix);

--6.Find the content added in last 5 years--

SELECT * FROM netflix
WHERE TO_DATE(date_added,'MONTH DD,YYYY')>=CURRENT_DATE - INTERVAL '5 years';

--7.Find all the movies/TV shows by director 'Rajiv Chilaka !'--
Select * FROM netflix 
where director ILIKE '%Rajiv Chilaka%'; 
--ILIKE use to deal with case sensitive characters--

--8.List all TV shows With more than 5 seasons --
Select * 
--split_part(duration,' ',1) as seasons--
from netflix
where type='TV Show' and
split_part(duration,' ',1)::numeric > 5 ; -- converted the text to numeric using ::numeric -- 

--9.Count the number of content items in each genre --
Select unnest(String_to_array(listed_in,',')) as genre,
count(show_id) as total_content
from netflix
group by genre;

--10.Find each year and the average numbers of content release by India on netflix --
--return top 5 year with highest avg content release --
Select 
EXTRACT(YEAR FROM to_date(date_added,'Month DD,YYYY'))AS year,
count(*) as yearly,
Round(COUNT(*)::numeric/(SELECT count(*) from netflix where country='India')::numeric*100,2) as avg_content
FROM netflix
where country='India'
group by year
;

--11.List all movies that are documentaries--
Select * from netflix
where listed_in ilike'%documentaries%' and type='Movie';

--12.Find all content without a director --
Select * from netflix
where director is null;

--13.Find how many movies actor 'Salman Khan' appeared in last 10 years! --
Select * from netflix
where type='Movie' and casts ilike '%Salman Khan%'
and release_year > EXTRACT(year from current_date)- 10;

--14.Find top 10 actors who have appeared in the highest number of movies produced in india.--
Select
unnest(string_to_array(casts,',')) as actors,
count(show_id) as total_content
from netflix 
where country ilike '%india%'
group by actors
order by 2 desc limit 10;

--15.categorise the content based on the presence of the keywords 'kill' and 'violence'in the description field.
--label content containing these keywords as 'bad' and all other content as 'good'. count how many items fall into
--each category --
WITH cte AS(
select *,case when description ilike '%kill%' or
description ilike '%violence%' then 'bad_content'
else 'good_content'
end  category
from netflix
)
select category,count(show_id)as total_content
from cte
group by category;

----------------------------------------------------------------------------------------------------------------------





