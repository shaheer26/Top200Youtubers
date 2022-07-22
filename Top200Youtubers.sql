---CREATE TABLE FOR DATA CONSISTING OF TOP YOUTUBERS:

CREATE TABLE top_youtubers (
	country VARCHAR,
	channel_name VARCHAR,
	category VARCHAR,
	main_video_category VARCHAR,
	username VARCHAR,
	followers NUMERIC,
	main_topic VARCHAR,
	more_topic VARCHAR,
	likes NUMERIC,
	boost_index NUMERIC,
	engagement_rate NUMERIC,
	engagement_rate_60_days NUMERIC,
	total_views NUMERIC,
	views_avg NUMERIC,
	avg_1_day NUMERIC,
	avg_3_day NUMERIC,
	avg_7_day NUMERIC,
	avg_14_day NUMERIC,
	avg_30_day NUMERIC,
	avg_60_day NUMERIC,
	comments_avg NUMERIC,
	youtube_link VARCHAR
);


--- IMPORTING DATA FROM top_200_youtubers CSV FILE ----------------------------------------------------------------

COPY top_youtubers FROM 
'C:\Program Files\PostgreSQL\14\data\Data\top_200_youtubers.csv'
CSV HEADER;

--- FULL top_youtubers TABLE --------------------------------------------------------------------------------------

SELECT * FROM top_youtubers;

--- COUNTING NUMBER OF YOUTUBERS IN THE TABLE: --------------------------------------------------------------------

SELECT COUNT(*) FROM top_youtubers; ---857

--- COUNTING NUMBER OF UNIQUE YOUTUBERS IN THE TABLE: -------------------------------------------------------------

SELECT COUNT(DISTINCT(channel_name)) FROM top_youtubers; ---200

--- SUMMARIZED TABLE OF LIST OF TOP YOUTUBERS: --------------------------------------------------------------------

SELECT DISTINCT(channel_name) AS youtuber_name, * FROM top_youtubers;

--- CREATE A NEW TABLE CALLED top_200_youtubers: ------------------------------------------------------------------

CREATE TABLE top_200_youtubers
AS (SELECT DISTINCT(channel_name) AS youtuber_name, * FROM top_youtubers);

--- LIST OF TOP 200 YOUTUBERS -------------------------------------------------------------------------------------

SELECT * FROM top_200_youtubers;

--- REMOVE THE COLUMN youtuber_name BECAUSE IT IS THE SAME AS channel_name: ---------------------------------------

ALTER TABLE top_200_youtubers
DROP COLUMN youtuber_name;

--- CLEANER VERSION OF TOP 200 YOUTUBERS TABLE AFTER COLUMN youtuber_name IS DELETED: -----------------------------

SELECT * FROM top_200_youtubers

--- TOP 200 YOUTUBERS ORDERED BY SUBSCRIBER COUNT:  ---------------------------------------------------------------

SELECT * FROM top_200_youtubers
ORDER BY followers DESC;

--- ANALYSIS ON INDIVIDUAL YOUTUBERS, ACCORDING TO EACH RELEVANT COLUMN IN THE TABLE --------------------------------------

--- #1. YOUTUBER WITH THE HIGHEST NUMBER OF SUBSCRIBERS (FOLLOWERS):

SELECT channel_name, followers FROM top_200_youtubers
ORDER BY followers DESC LIMIT 1; --- T-SERIES with 220 MILLION SUBSCRIBERS

--- #2. YOUTUBER WITH THE HIGHEST TOTAL NUMBER OF VIEWS:

SELECT channel_name, total_views FROM top_200_youtubers
ORDER BY total_views DESC LIMIT 1; --- T-SERIES with 19.57 BILLION VIEWS

--- #3. YOUTUBER WITH THE HIGHEST BOOST INDEX:

SELECT channel_name, boost_index FROM top_200_youtubers
ORDER BY boost_index DESC LIMIT 1; --- PEWDIEPIE with Boost index = 88

--- #4. YOUTUBER WITH THE HIGHEST ENGAGEMENT RATE (NON-NULL VALUE):

SELECT channel_name, engagement_rate FROM top_200_youtubers
WHERE engagement_rate IS NOT NULL
ORDER BY engagement_rate DESC LIMIT 1; --- GALINHA PINTADINHA with ENGAGEMENT RATE = 10.584

--- #5. YOUTUBER WITH THE HIGHEST AVERAGE VIEW COUNT (NON-NULL VALUE):

SELECT channel_name, views_avg FROM top_200_youtubers
WHERE views_avg IS NOT NULL
ORDER BY views_avg DESC LIMIT 1; --- GALINHA PINTADINHA with AVERAGE VIEWS = 423.92 MILLION VIEWS

--- #6. YOUTUBER WITH THE MOST NUMBER OF LIKES:

SELECT channel_name, likes FROM top_200_youtubers
WHERE likes IS NOT NULL
ORDER BY likes DESC LIMIT 1; --- PEWDIEPIE with 2.19 BILLION LIKES

--- #7. YOUTUBER WITH THE HIGHEST AVERAGE NUMBER OF COMMENTS:

SELECT channel_name, comments_avg FROM top_200_youtubers
WHERE comments_avg IS NOT NULL
ORDER BY comments_avg DESC LIMIT 1; --- CARRYMINATI with AVERAGE OF 199523.47 COMMENTS

--- #8. SUBSCRIBER COUNT FOR EACH COUNTRY OF ORIGIN OF YOUTUBERS:

SELECT country, SUM(followers) AS "Accumulated Number of Subscribers"
FROM top_200_youtubers
WHERE country IS NOT NULL
GROUP BY country
ORDER BY "Accumulated Number of Subscribers" DESC;

--- #9. COUNTRIES VS VIEWS

SELECT country, SUM(total_views) AS "Accumulated Total Views"
FROM top_200_youtubers
WHERE country IS NOT NULL
GROUP BY country
ORDER BY "Accumulated Total Views" DESC;

--- ANALYZING TOP 10 YOUTUBERS -------------------------------------------------------------------------------------------

--- #1. TOP 10 YOUTUBERS, ORDERED BY SUBSCRIBER COUNT:

SELECT channel_name, followers FROM top_200_youtubers
ORDER BY followers DESC LIMIT 10;

--- #2. TOP 10 YOUTUBERS, ORDERED BY TOTAL VIEWS COUNT:

SELECT channel_name, total_views FROM top_200_youtubers
ORDER BY total_views DESC LIMIT 10;

--- #3. TOP 10 YOUTUBERS, ORDERED BY BOOST INDEX:

SELECT channel_name, boost_index FROM top_200_youtubers
ORDER BY boost_index DESC LIMIT 10;

--- #4. TOP 10 YOUTUBERS, ORDERED BY ENGAGEMENT RATE (NON-NULL VALUE):

SELECT channel_name, engagement_rate FROM top_200_youtubers
WHERE engagement_rate IS NOT NULL
ORDER BY engagement_rate DESC LIMIT 10;

--- #5. TOP 10 YOUTUBERS, ORDERED BY AVERAGE VIEW COUNT (NON-NULL VALUE):

SELECT channel_name, views_avg FROM top_200_youtubers
WHERE views_avg IS NOT NULL
ORDER BY views_avg DESC LIMIT 10;

--- #6. TOP 10 YOUTUBERS, ORDERED BY LIKES COUNT:

SELECT channel_name, likes FROM top_200_youtubers
WHERE likes IS NOT NULL
ORDER BY likes DESC LIMIT 10;

--- #7. TOP 10 YOUTUBERS ORDERED BY COMMENTS COUNT:

SELECT channel_name, comments_avg FROM top_200_youtubers
WHERE comments_avg IS NOT NULL
ORDER BY comments_avg DESC LIMIT 10;

--- OTHER ANALYSIS ------------------------------------------------------------------------------------------

--- #1. NUMBER OF YOUTUBERS, GROUPED AND ORDERED IN EACH CATEGORY:

SELECT category, COUNT(channel_name) AS "Number of channels" FROM top_200_youtubers
WHERE category IS NOT NULL
GROUP BY category
ORDER BY "Number of channels" DESC;

--- #2. RANK OF COUNTRIES WITH THE MOST YOUTUBERS IN THE TOP 200 YOUTUBERS LIST:

SELECT country, COUNT(channel_name) AS "Number of Channels" FROM top_200_youtubers
WHERE country IS NOT NULL
GROUP BY country
ORDER BY "Number of Channels" DESC;

--- #3. ANALYSIS BASED ON SUBSCRIBER COUNT

--- a. POPULARITY OF CATEGORIES WITH RESPECT TO SUBSCRIBER COUNT:

SELECT category, SUM(followers) AS "Number of subscribers" FROM top_200_youtubers
WHERE category IS NOT NULL
GROUP BY category
ORDER BY "Number of subscribers" DESC;

--- b. POPULARITY OF YOUTUBERS UNDER THE MOST POPULAR CATEGORY, ACCORDING TO SUBSCRIBER COUNT:

SELECT channel_name, followers FROM top_200_youtubers
WHERE category IN
(
	SELECT category FROM top_200_youtubers
	GROUP BY category
	HAVING SUM(followers) =
	(
		SELECT SUM(followers) AS "Number of subscribers" FROM top_200_youtubers
		WHERE category IS NOT NULL
		GROUP BY category
		ORDER BY "Number of subscribers" DESC LIMIT 1
	)
)
ORDER BY followers DESC;

--- #c. MOST SUBSCRIBED YOUTUBERS FOR EACH CATEGORY:

;WITH CTE
AS
(
	SELECT channel_name, category, followers,
	ROW_NUMBER() OVER (PARTITION BY category ORDER BY followers DESC) AS "Sno#"
	FROM top_200_youtubers
	WHERE category IS NOT NULL
)
SELECT * FROM CTE WHERE "Sno#" < 2 ORDER BY followers DESC;

--- #d. POPULARITY OF MAIN VIDEO CATEGORIES, ACCORDING TO SUBSCRIBER COUNT:

SELECT main_video_category, SUM(followers) AS "Number of subscribers" FROM top_200_youtubers
WHERE main_video_category IS NOT NULL
GROUP BY main_video_category
ORDER BY "Number of subscribers" DESC;

--- #e. POPULARITY OF YOUTUBERS UNDER THE MOST POPULAR MAIN VIDEO CATEGORY, WITH RESPECT TO SUBSCRIBER COUNT:

SELECT channel_name, main_video_category,followers FROM top_200_youtubers
WHERE main_video_category IN
(
	SELECT main_video_category FROM top_200_youtubers
	GROUP BY main_video_category
	HAVING SUM(followers) =
	(
		SELECT SUM(followers) AS "Number of subscribers" FROM top_200_youtubers
		WHERE main_video_category IS NOT NULL
		GROUP BY main_video_category
		ORDER BY "Number of subscribers" DESC LIMIT 1
	)
)
ORDER BY followers DESC;

--- #f. MOST SUBSCRIBED YOUTUBERS FOR EACH MAIN VIDEO CATEGORY:

;WITH CTE
AS
(
	SELECT channel_name, main_video_category, followers,
	ROW_NUMBER() OVER (PARTITION BY main_video_category ORDER BY followers DESC) AS "Sno#"
	FROM top_200_youtubers
	WHERE main_video_category IS NOT NULL
)
SELECT * FROM CTE WHERE "Sno#" < 2 ORDER BY followers DESC;

--- 4. ANALYSIS BASED ON VIEWS COUNT

--- #a. POPULARITY OF CATEGORIES WITH RESPECT TO VIEWS COUNT:

SELECT category, SUM(total_views) AS "Total views" FROM top_200_youtubers
WHERE category IS NOT NULL
GROUP BY category
ORDER BY "Total views" DESC;

--- #b. POPULARITY OF YOUTUBERS UNDER THE MOST POPULAR CATEGORY, ACCORDING TO VIEWS COUNT:

SELECT channel_name, total_views FROM top_200_youtubers
WHERE category IN
(
	SELECT category FROM top_200_youtubers
	GROUP BY category
	HAVING SUM(total_views) =
	(
		SELECT SUM(total_views) AS "Total views" FROM top_200_youtubers
		WHERE category IS NOT NULL
		GROUP BY category
		ORDER BY "Total views" DESC LIMIT 1
	)
)
ORDER BY total_views DESC;

--- #c. MOST VIEWED YOUTUBERS FOR EACH CATEGORY

;WITH CTE
AS
(
	SELECT channel_name, category, total_views,
	ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_views DESC) AS "Sno#"
	FROM top_200_youtubers
	WHERE category IS NOT NULL
)
SELECT * FROM CTE WHERE "Sno#" < 2 ORDER BY total_views DESC;

--- #d. POPULARITY OF MAIN VIDEO CATEGORIES WITH RESPECT TO VIEWS COUNT:

SELECT main_video_category, SUM(total_views) AS "Total views" FROM top_200_youtubers
WHERE main_video_category IS NOT NULL
GROUP BY main_video_category
ORDER BY "Total views" DESC;

--- #e. POPULARITY OF YOUTUBERS UNDER THE MOST POPULAR MAIN VIDEO CATEGORY, ACCORDING TO VIEWS COUNT:

SELECT channel_name, main_video_category, total_views FROM top_200_youtubers
WHERE main_video_category IN
(
	SELECT main_video_category FROM top_200_youtubers
	GROUP BY main_video_category
	HAVING SUM(total_views) =
	(
		SELECT SUM(total_views) AS "Total views" FROM top_200_youtubers
		WHERE main_video_category IS NOT NULL
		GROUP BY main_video_category
		ORDER BY "Total views" DESC LIMIT 1
	)
)
ORDER BY total_views DESC;

--- #f. MOST VIEWED YOUTUBERS FOR EACH MAIN VIDEO CATEGORY:

;WITH CTE
AS
(
	SELECT channel_name, main_video_category, total_views,
	ROW_NUMBER() OVER (PARTITION BY main_video_category ORDER BY total_views DESC) AS "Sno#"
	FROM top_200_youtubers
	WHERE main_video_category IS NOT NULL
)
SELECT * FROM CTE WHERE "Sno#" < 2 ORDER BY total_views DESC;


--- 4. ANALYSIS BASED ON BOOST INDEX

--- #a. POPULARITY OF CATEGORIES, ORDERED BY BOOST INDEX AVERAGE

SELECT category, AVG(boost_index) AS "Average Boost Index" FROM top_200_youtubers
WHERE category IS NOT NULL
GROUP BY category
ORDER BY "Average Boost Index" DESC;

--- #b. POPULARITY OF YOUTUBERS UNDER THE CATEGORY WITH THE HIGHEST BOOST INDEX AVERAGE:

SELECT channel_name, category, boost_index FROM top_200_youtubers
WHERE category IN
(
	SELECT category FROM top_200_youtubers
	GROUP BY category
	HAVING AVG(boost_index) =
	(
		SELECT AVG(boost_index) AS "Average Boost Index" FROM top_200_youtubers
		WHERE category IS NOT NULL
		GROUP BY category
		ORDER BY "Average Boost Index" DESC LIMIT 1
	)
)
ORDER BY boost_index DESC;

--- #c. YOUTUBERS WITH HIGHEST BOOST INDEX, FOR EACH CATEGORY

;WITH CTE
AS
(
	SELECT channel_name, category, boost_index,
	ROW_NUMBER() OVER (PARTITION BY category ORDER BY boost_index DESC) AS "Sno#"
	FROM top_200_youtubers
	WHERE category IS NOT NULL
)
SELECT * FROM CTE WHERE "Sno#" < 2 ORDER BY boost_index DESC;

--- #d. POPULARITY OF MAIN VIDEO CATEGORIES, ORDERED BY AVERAGE BOOST INDEX:

SELECT main_video_category, AVG(boost_index) AS "Average Boost Index" FROM top_200_youtubers
WHERE main_video_category IS NOT NULL
GROUP BY main_video_category
ORDER BY "Average Boost Index" DESC;

--- #e. POPULARITY OF YOUTUBERS YOUTUBERS UNDER THE MAIN VIDEO CATEGORY WITH THE HIGHEST BOOST INDEX AVERAGE:

SELECT channel_name, main_video_category, boost_index FROM top_200_youtubers
WHERE main_video_category IN
(
	SELECT main_video_category FROM top_200_youtubers
	GROUP BY main_video_category
	HAVING AVG(boost_index) =
	(
		SELECT AVG(boost_index) AS "Average Boost Index" FROM top_200_youtubers
		WHERE main_video_category IS NOT NULL
		GROUP BY main_video_category
		ORDER BY "Average Boost Index" DESC LIMIT 1
	)
)
ORDER BY boost_index DESC;

--- #f. YOUTUBERS WITH HIGHEST BOOST INDEX, FOR EACH MAIN VIDEO CATEGORY:

;WITH CTE
AS
(
	SELECT channel_name, main_video_category, boost_index,
	ROW_NUMBER() OVER (PARTITION BY main_video_category ORDER BY boost_index DESC) AS "Sno#"
	FROM top_200_youtubers
	WHERE main_video_category IS NOT NULL
)
SELECT * FROM CTE WHERE "Sno#" < 2 ORDER BY boost_index DESC;

--- #5. ANALYSIS BASED ON AVERAGE VIEWS:

--- #a. LIST OF YOUTUBERS WITH THE HIGHEST AVERAGE VIEW COUNT, FOR EACH CATEGORY:

;WITH CTE
AS
(
	SELECT channel_name, category, views_avg,
	ROW_NUMBER() OVER (PARTITION BY category ORDER BY views_avg DESC) AS "Sno#"
	FROM top_200_youtubers
	WHERE category IS NOT NULL
)
SELECT * FROM CTE WHERE "Sno#" < 2;

--- #b. LIST OF YOUTUBERS WITH THE HIGHEST AVERAGE VIEW COUNT, FOR EACH MAIN VIDEO CATEGORY:

;WITH CTE
AS
(
	SELECT channel_name, main_video_category, views_avg,
	ROW_NUMBER() OVER (PARTITION BY main_video_category ORDER BY views_avg DESC) AS "Sno#"
	FROM top_200_youtubers
	WHERE main_video_category IS NOT NULL
)
SELECT * FROM CTE WHERE "Sno#" < 2 ORDER BY views_avg DESC;

--- #6. ANALYSIS BASED ON ENGAGEMENT RATE

--- #a. POPULARITY OF CATEGORIES, ORDERED BY AVERAGE ENGAGEMENT RATE

SELECT category, AVG(engagement_rate) AS "Average Engagement Rate" FROM top_200_youtubers
WHERE category IS NOT NULL
GROUP BY category
ORDER BY "Average Engagement Rate" DESC;

--- #b. POPULARITY OF YOUTUBERS UNDER THE CATEGORY WITH THE HIGHEST AVERAGE ENGAGEMENT RATE:

SELECT channel_name, category, engagement_rate FROM top_200_youtubers
WHERE category IN
(
	SELECT category FROM top_200_youtubers
	GROUP BY category
	HAVING AVG(engagement_rate) =
	(
		SELECT AVG(engagement_rate) AS "Average Engagement Rate" FROM top_200_youtubers
		WHERE category IS NOT NULL
		GROUP BY category
		ORDER BY "Average Engagement Rate" DESC LIMIT 1
	)
)
ORDER BY engagement_rate DESC;

--- #c. YOUTUBERS WITH HIGHEST ENGAGEMENT RATE, FOR EACH CATEGORY

;WITH CTE
AS
(
	SELECT channel_name, category, engagement_rate,
	ROW_NUMBER() OVER (PARTITION BY category ORDER BY engagement_rate DESC) AS "Sno#"
	FROM top_200_youtubers
	WHERE category IS NOT NULL
)
SELECT * FROM CTE WHERE "Sno#" < 2 ORDER BY engagement_rate DESC;

--- #d. POPULARITY OF MAIN VIDEO CATEGORIES, ORDERED BY AVERAGE ENGAGEMENT RATE:

SELECT main_video_category, AVG(engagement_rate) AS "Average Engagement Rate" FROM top_200_youtubers
WHERE main_video_category IS NOT NULL
GROUP BY main_video_category
ORDER BY "Average Engagement Rate" DESC;

--- #e. POPULARITY OF YOUTUBERS UNDER THE MAIN VIDEO CATEGORY WITH THE HIGHEST AVERAGE ENGAGEMENT RATE:

SELECT channel_name, main_video_category, engagement_rate FROM top_200_youtubers
WHERE main_video_category IN
(
	SELECT main_video_category FROM top_200_youtubers
	GROUP BY main_video_category
	HAVING AVG(engagement_rate) =
	(
		SELECT AVG(engagement_rate) AS "Average Engagement Rate" FROM top_200_youtubers
		WHERE main_video_category IS NOT NULL
		GROUP BY main_video_category
		ORDER BY "Average Engagement Rate" DESC LIMIT 1
	)
)
ORDER BY engagement_rate DESC;

--- #f. YOUTUBERS WITH HIGHEST ENGAGEMENT RATE, FOR EACH MAIN VIDEO CATEGORY:

;WITH CTE
AS
(
	SELECT channel_name, main_video_category, engagement_rate,
	ROW_NUMBER() OVER (PARTITION BY main_video_category ORDER BY engagement_rate DESC) AS "Sno#"
	FROM top_200_youtubers
	WHERE main_video_category IS NOT NULL
)
SELECT * FROM CTE WHERE "Sno#" < 2 ORDER BY engagement_rate DESC;