 DROP TABLE actors;
 CREATE TABLE actors (
 	actor_id SERIAL PRIMARY KEY,
	 first_name VARCHAR(150),
	 last_name VARCHAR(150) NOT NULL,
	 gender CHAR(1),
	 date_of_birth DATE,
	 add_date DATE,
	 update_date DATE
 );
 
 DROP TABLE directors;
 CREATE TABLE directors (
 	director_id SERIAL PRIMARY KEY,
	 first_name VARCHAR(150),
	 last_name VARCHAR(150) NOT NULL,
	 date_of_birth DATE,
	 nationality VARCHAR(20),
	 add_date DATE,
	 update_date DATE
 );
 
 DROP TABLE movies;
 CREATE TABLE movies (
 	movie_id SERIAL PRIMARY KEY,
	 movie_name VARCHAR(100) NOT NULL,
	 movie_length INT,
	 movie_lang VARCHAR(20),
	 age_certificate VARCHAR(10),
	 release_date DATE,
	 director_id INT REFERENCES directors (director_id)
 );
 
 DROP TABLE movies_revenues;
 CREATE TABLE movies_revenues (
 	revenue_id SERIAL PRIMARY KEY,
	 movie_id INT REFERENCES movies (movie_id),
	 revenue_domestic NUMERIC (10,2),
	 revenue_international NUMERIC (10,2) 
 );
 
 DROP TABLE movies_actors;
 CREATE TABLE movies_actors  (
	 movie_id INT REFERENCES movies (movie_id),
	 actor_id INT REFERENCES actors (actor_id),
 	PRIMARY KEY (movie_id,actor_id)
 );
 
 DROP TABLE customers;
 CREATE TABLE customers (
 	customer_id SERIAL PRIMARY KEY,
	 first_name VARCHAR(50),
	 last_name VARCHAR(50),
	 email VARCHAR(150),
	 age INT
 );
 
 SELECT * FROM customers;
 
 INSERT INTO customers (first_name, last_name, email, age)
 VALUES ('Ton','Tran','a@b.com',33);
 
 INSERT INTO customers (first_name, last_name)
 VALUES
 ('A','A'),
 ('B','B');
 
  INSERT INTO customers (first_name, email)
 VALUES ('A','b@b.com');
 
 INSERT INTO customers (first_name)
 VALUES ('Bi''s Store');
 
 INSERT INTO customers (first_name)
 VALUES ('Thanh') RETURNING *;
 
 INSERT INTO customers (first_name)
 VALUES ('Lisa') RETURNING customer_id;
 
 UPDATE customers
 SET first_name = 'TonUpdated'
 WHERE customer_id = 1;
 
 UPDATE customers
 SET first_name = 'Aupdated', age = 20
 WHERE customer_id = 2
 RETURNING *;
 
 UPDATE customers
 SET is_enable = 'Y';
 
 DELETE FROM customers
 WHERE customer_id = '3';
 
 CREATE TABLE t_tags (
 	tag_id SERIAL PRIMARY KEY,
	 tag TEXT UNIQUE,
	 update_date TIMESTAMP DEFAULT NOW()
 );
 
 INSERT INTO t_tags (tag)
 VALUES ('A'),('B');
 
 -- UPSERT, update row nếu đã tồn tại, insert nếu chưa
 -- insert data vào, nếu đã tồn tại thì ko làm gì
 INSERT INTO t_tags (tag)
 VALUES ('A')
 ON CONFLICT (tag)
 DO 
 	NOTHING;
	
 -- add data vào, nếu data đã tồn tại thì update
 INSERT INTO t_tags (tag)
 VALUES ('B')
 ON CONFLICT (tag)
 DO 
 	UPDATE SET 
		tag = EXCLUDED.tag,
		update_date = NOW();
		
 -- add data vào, nếu data đã tồn tại thì update
 INSERT INTO t_tags (tag)
 VALUES ('B')
 ON CONFLICT (tag)
 DO 
 	UPDATE SET 
		tag = EXCLUDED.tag || '1',
		update_date = NOW();
		
SELECT * FROM customers;
SELECT * FROM actors;
SELECT first_name FROM actors;
SELECT first_name, last_name FROM actors;
SELECT first_name AS firstName FROM actors;
SELECT first_name AS "firstName" FROM actors;
SELECT first_name AS "First Name" FROM actors;
SELECT 
	movie_name AS "Movie Name", 
	movie_lang AS "Language" 
FROM movies;
SELECT 
	movie_name "Movie Name", 
	movie_lang "Language" 
FROM movies;
SELECT first_name || last_name "Full Name" FROM actors;
SELECT first_name || ' ' || last_name "Full Name" FROM actors;
SELECT 2*10;
SELECT 2/0;
SELECT 10/3;

SELECT * FROM movies
ORDER BY release_date ASC;

SELECT * FROM movies
ORDER BY release_date;

SELECT * FROM movies
ORDER BY release_date DESC;

-- 1 FROM, 2 SELECT, 3 ORDER BY
SELECT * FROM movies
ORDER BY 
	release_date DESC,
	movie_name ASC;

SELECT 
	first_name,
	last_name AS surname
FROM actors
ORDER BY last_name DESC;

SELECT 
	first_name,
	last_name AS surname
FROM actors
ORDER BY surname;

SELECT 
	first_name,
	LENGTH(first_name) AS len
FROM actors
ORDER BY len DESC;

SELECT 
	*
FROM actors
ORDER BY 
	first_name,
	date_of_birth DESC;
	
SELECT 
	first_name,
	date_of_birth
FROM actors
ORDER BY 
	1,
	2 DESC;
	
SELECT * FROM demo_sorting
ORDER BY num DESC NULLS LAST;

SELECT * FROM demo_sorting
ORDER BY num NULLS FIRST;

SELECT movie_lang FROM movies;
SELECT DISTINCT movie_lang FROM movies;

SELECT * FROM movies WHERE movie_lang = 'English' AND age_certificate = '18';
SELECT * FROM movies WHERE movie_lang = 'English' OR movie_lang = 'Chinese' ORDER BY movie_lang;
SELECT * FROM movies WHERE movie_lang = 'English' AND director_id = 8;
SELECT * FROM movies WHERE movie_length > 100 ORDER BY movie_length;
SELECT * FROM movies WHERE movie_length >= 100 ORDER BY movie_length;
SELECT * FROM movies WHERE movie_length < 100 ORDER BY movie_length;
SELECT * FROM movies WHERE release_date > '2000-12-31' ORDER BY release_date;
SELECT * FROM movies WHERE movie_lang > 'English' ORDER BY movie_lang;

SELECT * FROM movies WHERE movie_lang = 'English' OR movie_lang = 'Chinese' OR movie_lang = 'Japanese' ORDER BY movie_lang;
SELECT * FROM movies WHERE movie_lang IN ('English','Chinese','Japanese') ORDER BY movie_lang;
SELECT * FROM movies WHERE age_certificate = '12' OR age_certificate = 'PG' ORDER BY age_certificate;
SELECT * FROM movies WHERE age_certificate IN ('12','PG') ORDER BY age_certificate;
SELECT * FROM movies WHERE director_id NOT IN (10,13) ORDER BY director_id;
SELECT * FROM actors WHERE actor_id NOT IN (1,2,3,4);

SELECT * FROM actors WHERE date_of_birth BETWEEN '1991-01-01' AND '1995-12-31' ORDER BY date_of_birth;
SELECT * FROM movies WHERE release_date BETWEEN '1998-01-01' AND '2002-12-31' ORDER BY release_date;
SELECT * FROM movies_revenues WHERE revenue_domestic BETWEEN '100' AND '300' ORDER BY revenue_domestic;
SELECT * FROM movies WHERE movie_length NOT BETWEEN 100 AND 200 ORDER BY movie_length;

SELECT 'hello' LIKE 'hello';
SELECT 'hello' LIKE 'h%';
SELECT 'hello' LIKE '%e%';
SELECT 'hello' LIKE 'hell%';
SELECT 'hello' LIKE '%ll';
SELECT 'hello' LIKE '_ello';
SELECT 'hello' LIKE '%ll_';

SELECT * FROM actors WHERE first_name LIKE 'A%';
SELECT * FROM actors WHERE last_name LIKE '%a';
SELECT * FROM actors WHERE first_name LIKE '_____';
SELECT * FROM actors WHERE first_name LIKE '_l%';
SELECT * FROM actors WHERE first_name LIKE '%Tim%';
SELECT * FROM actors WHERE first_name LIKE '%tim%';

SELECT * FROM actors WHERE first_name ILIKE '%Tim%';
SELECT * FROM actors WHERE first_name ILIKE '%tim%';

SELECT * FROM movies_revenues WHERE revenue_domestic IS NULL ORDER BY revenue_domestic;
SELECT * FROM movies_revenues WHERE revenue_domestic IS NULL OR revenue_international IS NULL  ORDER BY revenue_domestic;
SELECT * FROM movies_revenues WHERE revenue_domestic IS NULL AND revenue_international IS NULL  ORDER BY revenue_domestic;
SELECT * FROM movies_revenues WHERE revenue_domestic IS NOT NULL ORDER BY revenue_domestic;
 
SELECT 'Hello' || 'World' AS new_string;
SELECT 'Hello' || ' ' || 'World' AS new_string;
SELECT CONCAT(first_name,' ',last_name) AS "Actor Name" FROM actors ORDER BY first_name;
SELECT CONCAT_WS(' | ',first_name,last_name,date_of_birth) AS "Actor Name Birthday" FROM actors ORDER BY first_name;
 
SELECT revenue_domestic, revenue_international, CONCAT(revenue_domestic,' | ' ,revenue_international) AS profits 
FROM movies_revenues;
SELECT revenue_domestic, revenue_international, CONCAT_WS(' | ',revenue_domestic, revenue_international) AS profits 
FROM movies_revenues;

-- TRUE: TRUE, 'true', 't', 'y', 'yes', '1'
-- FALSE: FALSE, 'false', 'f', 'n', 'no', '0'

CREATE TABLE table_boolean(
	product_id SERIAL PRIMARY KEY,
	is_available BOOLEAN NOT NULL
);

INSERT INTO table_boolean (is_available) VALUES (TRUE);
INSERT INTO table_boolean (is_available) VALUES (FALSE);
INSERT INTO table_boolean (is_available) VALUES ('true');
INSERT INTO table_boolean (is_available) VALUES ('false');
INSERT INTO table_boolean (is_available) VALUES ('t');
INSERT INTO table_boolean (is_available) VALUES ('f');
INSERT INTO table_boolean (is_available) VALUES ('y');
INSERT INTO table_boolean (is_available) VALUES ('n');
INSERT INTO table_boolean (is_available) VALUES ('yes');
INSERT INTO table_boolean (is_available) VALUES ('no');
INSERT INTO table_boolean (is_available) VALUES ('1');
INSERT INTO table_boolean (is_available) VALUES ('0');

SELECT * FROM table_boolean;
SELECT * FROM table_boolean WHERE is_available = TRUE;
SELECT * FROM table_boolean WHERE is_available = '1';
SELECT * FROM table_boolean WHERE is_available;

SELECT * FROM table_boolean WHERE is_available = 'n';
SELECT * FROM table_boolean WHERE is_available = 'f';
SELECT * FROM table_boolean WHERE NOT is_available;

ALTER TABLE table_boolean ALTER COLUMN is_available SET DEFAULT 'false';
ALTER TABLE table_boolean ALTER COLUMN is_available SET DEFAULT '0';

--CHARACTER(n), CHAR(n) fixed length, pad field with blanks
SELECT CAST('Ton' AS character(10)) AS "Name";
SELECT 'Ton'::char(10) AS "Name";

--CHARACTER VARYING(n), VARCHAR(n) variable-length with length limit, no pad field with blanks
SELECT 'Ton'::varchar(10) AS "Name";

--TEXT unlimited size (max approx 1gb)

CREATE TABLE table_characters(
	col_char CHAR(10),
	col_varchar VARCHAR(10),
	col_text TEXT
);
SELECT * FROM table_characters;

-- prefer varchar(n), choose good character data types based on
-- database design, read/write/frequency and overall business logics

--Numbers: not NULL, interger (-1,1), decimal number = floating point (1.2)
-- smallint		2 bytes		-32768					to		+32768
-- interger		4 bytes		-2147483648				to		+2147483648
-- bigint		8 bytes		-9223372036854775808	to		+9223372036854775808

-- smallserial		2 bytes		1	to		32767
-- serial			4 bytes		1	to		2147483647
-- bigserial		8 bytes		1	to		9223372036854775807

CREATE TABLE table_serial(
	product_id SERIAL,
	product_name VARCHAR(100)
);
INSERT INTO table_serial (product_name) VALUES ('pen');
SELECT * FROM table_serial;

--Data type				Storage Size		Storage type		Range
--numberic, decimal		variable			fixed point			131072 precision, 16383 scale
--real					4 bytes				floating point		6 decimal digits precision
--double precision		8 bytes				floating point		15 decimal digits precision
CREATE TABLE table_numbers(
	col_numberic numeric(20,5),
	col_real real,
	col_double double precision
);
INSERT INTO table_numbers (col_numberic,col_real,col_double) VALUES 
	(.9,.9,.9),
	(3.13579,3.13579,3.13579),
	(4.1357987654,4.1357987654,4.1357987654);
SELECT * FROM table_numbers;

--Date/Time data types
-- Date: date only, 4 bytes, YYYY-MM-DD, CURRENT_DATE
CREATE TABLE table_dates(
	id SERIAL PRIMARY KEY,
	employee_name varchar(100) NOT NULL,
	hire_date DATE NOT NULL,
	add_date DATE DEFAULT CURRENT_DATE
);
INSERT INTO table_dates (employee_name,hire_date) VALUES ('TON','2012-03-01'),('TON1','2021-03-01');
SELECT * FROM table_dates;

--Time: time only, 8 bytes, HH:MM, HH:MM:SS, HHMMSS, HH:MM.pppppp, HH:MM:SS.pppppp, HHMMSS.pppppp
SELECT * FROM table_time;
SELECT CURRENT_TIME;
SELECT CURRENT_TIME(2);
SELECT CURRENT_TIME, LOCALTIME;
SELECT time '12:00' - time '04:00'  AS RESULT;
SELECT CURRENT_TIME, CURRENT_TIME - interval '-2 hours' AS RESULT;

--Timestamp(date and time), Timestamptz(date, time, timestamp)
CREATE TABLE table_time_tz(
	ts TIMESTAMP,
	tstz TIMESTAMPTZ
);
INSERT INTO table_time_tz (ts, tstz) VALUES ('2023-12-19 10:10:10-07','2023-12-19 10:10:10-07');
SELECT * FROM table_time_tz;
SHOW TIMEZONE;
SET TIMEZONE = 'America/New_York';
--SET TIMEZONE = 'est/UTC';
SELECT CURRENT_TIMESTAMP;
SELECT TIMEOFDAY();
SELECT timezone('Asia/Singapore','2023-12-19 00:00:00');

--UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
SELECT uuid_generate_v1();
SELECT uuid_generate_v4();
CREATE TABLE table_uuid(
	product_id UUID DEFAULT uuid_generate_v4(),
	product_name VARCHAR(100) NOT NULL
);
SELECT * FROM table_uuid;
INSERT INTO table_uuid (product_name) VALUES ('ABC');
ALTER TABLE table_uuid
ALTER COLUMN product_id
SET DEFAULT uuid_generate_v1();

--Array
CREATE TABLE table_array(
	array_id SERIAL PRIMARY KEY,
	name varchar(100),
	phone text [] -- our array
);
INSERT INTO table_array (name, phone) 
VALUES ('ADAM',ARRAY['123','456']),('LINDA',ARRAY['789','777']);
SELECT * FROM table_array;
SELECT name, phone[1] FROM table_array;
SELECT name FROM table_array WHERE phone[2]='777';