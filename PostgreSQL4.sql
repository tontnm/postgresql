--inner join get all data from 2 tables
SELECT * FROM movies m
INNER JOIN directors d ON m.director_id  = d.director_id;
SELECT * FROM movies m
INNER JOIN directors d using(director_id)
WHERE m.movie_lang = 'English';
SELECT m.movie_name,d.first_name,mr.revenue_domestic FROM movies m 
INNER JOIN directors d using(director_id)
INNER JOIN movies_revenues mr using(movie_id)
WHERE m.movie_lang in ('Japanese','English','Chinese') AND mr.revenue_domestic > 100
ORDER BY 3 DESC;
SELECT 
	m.movie_name,d.first_name,mr.revenue_domestic,mr.revenue_international,
	(mr.revenue_domestic+mr.revenue_international) AS "Total Revenues" 
FROM movies m 
INNER JOIN directors d using(director_id)
INNER JOIN movies_revenues mr using(movie_id)
WHERE m.movie_lang in ('Japanese','English','Chinese') AND mr.revenue_domestic > 100
ORDER BY 5 DESC NULLS LAST
LIMIT 10;
SELECT * FROM movies;
SELECT 
	m.movie_name,d.first_name,mr.revenue_domestic,mr.revenue_international,
	(mr.revenue_domestic+mr.revenue_international) AS "Total Revenues" 
FROM movies m 
INNER JOIN directors d using(director_id)
INNER JOIN movies_revenues mr using(movie_id)
WHERE m.release_date BETWEEN '2005-01-01' AND '2008-12-31'
ORDER BY 5 DESC NULLS LAST
LIMIT 10;

CREATE TABLE t1 (test int);
CREATE TABLE t2 (test varchar(100));
INSERT INTO t1 (test) VALUES (1),(2);
INSERT INTO t2 (test) VALUES ('1'),('2');
SELECT * FROM t1
INNER JOIN t2 ON CAST(t1.test AS varchar) = t2.test;

CREATE TABLE left_products(
	product_id serial PRIMARY KEY,
	proudct_name varchar(100)
);
CREATE TABLE right_products(
	product_id serial PRIMARY KEY,
	proudct_name varchar(100)
);
INSERT INTO left_products (product_id,proudct_name) VALUES 
(1,'Computers'),
(2,'Laptops'),
(3,'Monitors'),
(4,'Mics');
INSERT INTO right_products (product_id,proudct_name) VALUES 
(1,'Computers'),
(2,'Laptops'),
(3,'Monitors'),
(4,'Pen'),
(7,'Papers');
SELECT * FROM right_products;
SELECT * FROM left_products;

--left join get all data from left table and matched data from right table
SELECT * FROM left_products lp 
INNER JOIN right_products rp ON lp.product_id = rp.product_id;
SELECT * FROM left_products lp 
LEFT JOIN right_products rp ON lp.product_id = rp.product_id;

SELECT * FROM movies;
SELECT * FROM directors;
SELECT m.movie_name,d.first_name,d.last_name FROM movies m 
INNER JOIN directors d ON m.director_id = d.director_id ORDER BY d.first_name;
SELECT m.movie_name,d.first_name,d.last_name FROM directors d 
INNER JOIN movies m ON m.director_id = d.director_id ORDER BY d.first_name;
SELECT m.movie_name,d.first_name,d.last_name FROM movies m 
LEFT JOIN directors d ON m.director_id = d.director_id ORDER BY d.first_name;
INSERT INTO directors (first_name,last_name,date_of_birth,nationality) VALUES 
('James','David','2010-01-01','American');

SELECT d.first_name,d.last_name,m.movie_name,m.movie_lang
FROM directors d
LEFT JOIN movies m ON d.director_id  = m.director_id 
WHERE m.movie_lang IN ('English','Chinese')
ORDER BY d.director_id;

SELECT d.first_name,d.last_name,count(m.movie_name)
FROM directors d
LEFT JOIN movies m ON d.director_id  = m.director_id 
WHERE m.movie_lang IN ('English','Chinese')
GROUP BY d.first_name, d.last_name;

SELECT d.first_name,d.last_name,count(*) AS "total_movies"
FROM directors d
LEFT JOIN movies m ON d.director_id  = m.director_id 
WHERE m.movie_lang IN ('English','Chinese')
GROUP BY d.first_name, d.last_name
ORDER BY count(*) DESC;

SELECT d.first_name,d.last_name,m.movie_name,m.age_certificate
FROM directors d 
LEFT JOIN movies m ON m.director_id = d.director_id 
WHERE d.nationality IN ('American','Chinese','Japanese');

SELECT 
	m.movie_id,m.movie_name,d.first_name,d.last_name,
	sum(mr.revenue_domestic) AS "total_domestic",
	sum(mr.revenue_international) AS "total_international"
FROM directors d 
LEFT JOIN movies m ON d.director_id = m.director_id 
LEFT JOIN movies_revenues mr ON mr.movie_id = m.movie_id
GROUP BY m.movie_id,m.movie_name,d.first_name,d.last_name
ORDER BY 5 DESC NULLS LAST;