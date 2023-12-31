-- Using a CTE, find out the total number of films rented for each rating (like 'PG', 'G', etc.) in the year 2005. List the ratings that had more than 50 rentals.
WITH CTE_COUNT_RENTAL AS
	(SELECT SE_F.RATING,
			COUNT(SE_R.RENTAL_ID) AS TOTAL_RENTALS
		FROM FILM AS SE_F
		INNER JOIN INVENTORY AS SE_I ON SE_F.FILM_ID = SE_I.FILM_ID
		INNER JOIN RENTAL AS SE_R ON SE_I.INVENTORY_ID = SE_R.INVENTORY_ID
		WHERE EXTRACT(YEAR FROM SE_R.RENTAL_DATE) = 2005
		GROUP BY SE_F.RATING)
SELECT *
FROM CTE_COUNT_RENTAL
WHERE CTE_COUNT_RENTAL.TOTAL_RENTALS > 50;

--------------------------------------------------------------
-- Identify the categories of films that have an average rental duration greater than 5 days. Only consider films rated 'PG' or 'G'.

SELECT SE_C.NAME,
	ROUND(AVG(SE_F.RENTAL_DURATION),
		2) AS AVG_RENTAL_DURATION
FROM CATEGORY AS SE_C
INNER JOIN FILM_CATEGORY AS SE_FC ON SE_C.CATEGORY_ID = SE_FC.CATEGORY_ID
INNER JOIN FILM AS SE_F ON SE_FC.FILM_ID = SE_F.FILM_ID
WHERE SE_F.RATING IN ('PG','G')
GROUP BY SE_C.NAME
HAVING AVG(SE_F.RENTAL_DURATION) > 5;

------------------------------------------------------------------
--: Determine the total rental amount collected from each customer. List only those customers who have spent more than $100 in total.
SELECT SE_C.CUSTOMER_ID,
    SUM(SE_P.AMOUNT) AS AMOUNT_COLLECTED
FROM CUSTOMER AS SE_C
INNER JOIN PAYMENT AS SE_P ON SE_C.CUSTOMER_ID = SE_P.CUSTOMER_ID
GROUP BY SE_C.CUSTOMER_ID
HAVING SUM(SE_P.AMOUNT) > 100
ORDER BY AMOUNT_COLLECTED;


----------------------------------
--: Create a temporary table containing the names and email addresses of customers who have rented more than 10 films.

CREATE
TEMPORARY TABLE TEMP_RENTALS AS
SELECT CONCAT(SE_C.FIRST_NAME,' ',SE_C.LAST_NAME) AS FULL_NAME,
								SE_C.EMAIL,
	COUNT(SE_R.RENTAL_ID) AS NUMBER_OF_RENTALS
FROM CUSTOMER AS SE_C
INNER JOIN RENTAL AS SE_R ON SE_C.CUSTOMER_ID = SE_R.CUSTOMER_ID
GROUP BY CONCAT(SE_C.FIRST_NAME,' ',SE_C.LAST_NAME),SE_C.EMAIL
HAVING COUNT(SE_R.RENTAL_ID) > 10;


SELECT TEMP_RENTALS.FULL_NAME
FROM TEMP_RENTALS
WHERE TEMP_RENTALS.EMAIL ilike ('%@gmail.com');


DROP TABLE TEMP_RENTALS;

--------------------------------------------------------
--ex 6
WITH CTE_TOTAL_RENTAL AS
	(SELECT SE_CA.CATEGORY_ID,
			SE_CA.NAME,
			COUNT(SE_R.RENTAL_ID) AS TOTAL_RENTAL
		FROM RENTAL AS SE_R
		INNER JOIN INVENTORY AS SE_I ON SE_I.INVENTORY_ID = SE_R.INVENTORY_ID
		INNER JOIN FILM AS SE_FILM ON SE_FILM.FILM_ID = SE_I.FILM_ID
		INNER JOIN FILM_CATEGORY AS SE_FC ON SE_FC.FILM_ID = SE_FILM.FILM_ID
		INNER JOIN CATEGORY AS SE_CA ON SE_FC.CATEGORY_ID = SE_CA.CATEGORY_ID
		GROUP BY SE_CA.CATEGORY_ID,
			SE_CA.NAME
		ORDER BY COUNT(SE_R.RENTAL_ID) DESC)
