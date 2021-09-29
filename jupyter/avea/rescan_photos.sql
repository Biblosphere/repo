select * from `biblosphere-210106`.biblosphere.recognition_stats
where photo_id = 'ufOboNfwJD87mOyCab3K'
order by added
limit 100;


-------------
-- COMPARE TWO ALGORITHM
-------------
WITH rescan_photos AS (
    SELECT DISTINCT photo_id FROM `biblosphere-210106`.biblosphere.recognition_stats
    WHERE algorithm = 'Detectron build 1.0 (2021-08-26)'
),
second_algo AS (
    SELECT DISTINCT
        stats.photo_id AS photo_id,
        MAX(duration_microsec) AS duration,
        MAX(recognized_books) AS recognized,
        MAX(total_finded_books) AS total_finded,
        MAX(detectron_finded_books) AS detectron_finded
    FROM `biblosphere-210106`.biblosphere.recognition_stats AS stats
             JOIN rescan_photos AS photos ON stats.photo_id = photos.photo_id
    WHERE algorithm = 'Detectron build 1.0 (2021-08-26)'
    GROUP BY stats.photo_id
),
first_algo AS (
 SELECT DISTINCT
     stats.photo_id AS photo_id,
     MAX(recognized_books) AS recognized,
     MAX(total_finded_books) AS total_finded
 FROM `biblosphere-210106`.biblosphere.recognition_stats AS stats
          JOIN rescan_photos AS photos ON stats.photo_id = photos.photo_id
 WHERE algorithm = "Denis's baseline algorithm (not ml)"
 GROUP BY stats.photo_id
)
SELECT
    '1.baseline' AS algorithm,
    COUNT(photo_id) AS photos,
    SUM(recognized) AS recognized,
    SUM(total_finded) AS total_finded,
    NULL AS avg_duration,
    NULL AS detectron_finded,
    ROUND(SUM(recognized) / SUM(total_finded) * 100) AS percent
FROM first_algo
UNION ALL
SELECT
    '2.detectron' AS algorithm,
    COUNT(photo_id) AS photos,
    SUM(recognized) AS recognized,
    SUM(total_finded) AS total_finded,
    ROUND(AVG(duration) / 1000000),
    SUM(detectron_finded),
    ROUND(SUM(recognized) / SUM(total_finded) * 100)
FROM second_algo
ORDER BY algorithm;



--------------------
-- FIRST RESULT IS BETTER THAN SECOND ONE
--------------------
WITH rescan_photos AS (
    SELECT DISTINCT photo_id FROM `biblosphere-210106`.biblosphere.recognition_stats
    WHERE algorithm = 'Detectron build 1.0 (2021-08-26)'
),
     second_algo AS (
         SELECT DISTINCT
             stats.photo_id AS photo_id,
             MAX(duration_microsec) AS duration,
             MAX(recognized_books) AS recognized,
             MAX(total_finded_books) AS total_finded,
             MAX(detectron_finded_books) AS detectron_finded,
             photo_url AS url
         FROM `biblosphere-210106`.biblosphere.recognition_stats AS stats
                  JOIN rescan_photos AS photos ON stats.photo_id = photos.photo_id
         WHERE algorithm = 'Detectron build 1.0 (2021-08-26)'
         GROUP BY stats.photo_id, photo_url
     ),
     first_algo AS (
         SELECT DISTINCT
             stats.photo_id AS photo_id,
             MAX(recognized_books) AS recognized,
             MAX(total_finded_books) AS total_finded
         FROM `biblosphere-210106`.biblosphere.recognition_stats AS stats
                  JOIN rescan_photos AS photos ON stats.photo_id = photos.photo_id
         WHERE algorithm = "Denis's baseline algorithm (not ml)"
         GROUP BY stats.photo_id
     )

SELECT
    first.photo_id AS photo_id,
    first.recognized AS recognized_first,
    second.recognized AS recognized_second,
    first.total_finded AS total_first,
    second.total_finded AS total_second,
    second.url AS url
FROM first_algo first
    JOIN second_algo second ON first.photo_id = second.photo_id
WHERE first.recognized > second.recognized



--Detectron build 1.0 (2021-08-26)
--Denis's baseline algorithm (not ml)