--hstore
CREATE EXTENSION IF NOT EXISTS hstore;
CREATE TABLE table_hstore(
	book_id SERIAL PRIMARY KEY,
	title VARCHAR(100) NOT NULL,
	book_info hstore
);
INSERT INTO table_hstore (title,book_info) VALUES 
(
	'TITLE 1',
	'
		"publisher" => "abc publisher",
		"paper_cost" => "10.00",
		"e_cost" => "5.85"
	'
);
SELECT * FROM table_hstore;
SELECT
	book_info -> 'publisher' AS "publisher",
	book_info -> 'e_cost' AS "Electronic Cost"
FROM table_hstore;

--json
CREATE TABLE table_json(
	id SERIAL PRIMARY KEY,
	doc JSON
);
INSERT INTO table_json (doc) VALUES 
('[1,2,3,4,5,6]'),
('[2,3,4,5,6,7]'),
('{"key":"value","key1":"value1"}');
SELECT * FROM table_json;
SELECT doc FROM table_json WHERE doc @> '2';
ALTER TABLE table_json ALTER COLUMN doc TYPE JSONB;
SELECT doc FROM table_json WHERE doc @> '2';
CREATE INDEX ON table_json USING GIN (doc jsonb_path_ops);

--network address
CREATE TABLE table_network(
	id SERIAL PRIMARY KEY,
	ip INET
);
INSERT INTO table_network (ip) VALUES
('1.1.1.1'),
('1.1.1.2'),
('1.1.1.3');
SELECT * FROM table_network;
SELECT
	ip,
	set_masklen(ip,24) AS inet_24,
	set_masklen(ip::cidr,24) AS cidr_24,
	set_masklen(ip::cidr,27) AS cidr_27,
	set_masklen(ip::cidr,28) AS cidr_28
FROM table_network;

--type conversion
SELECT * FROM movies;
SELECT * FROM movies
WHERE movie_id = 1;
SELECT * FROM movies
WHERE movie_id = '1'; -- implicit = auto convert
SELECT * FROM movies
WHERE movie_id = integer '1'; -- explicit = conversion functions
SELECT CAST('10' AS integer);
SELECT CAST('10N' AS integer);
SELECT CAST('2020-01-01' AS DATE);
SELECT CAST('01-MAY-2020' AS DATE);
SELECT CAST('true' AS BOOLEAN),CAST('false' AS BOOLEAN),CAST('T' AS BOOLEAN),CAST('F' AS BOOLEAN),CAST('0' AS BOOLEAN),CAST('1' AS BOOLEAN);
SELECT CAST('14.7888' AS DOUBLE PRECISION);
SELECT '10'::INTEGER,'2020-01-01'::DATE,'01-01-2020'::DATE;
SELECT '2020-02-20 10:30:25.456'::TIMESTAMP;
SELECT '2020-02-20 10:30:25.456'::TIMESTAMPTZ;
SELECT '10 minute'::interval,'4 hour'::interval,'1 day'::interval,'2 week'::interval,'5 month'::interval;
SELECT 20 ! ;
SELECT 20 ! AS "result";
SELECT CAST(20 AS BIGINT) ! AS "result";
SELECT ROUND(10,4) AS "result";
SELECT ROUND(CAST(10 AS NUMERIC),4) AS "result";
SELECT SUBSTR('123456',4) AS "implicit", SUBSTR(CAST('123456' AS TEXT),4) AS "explicit";

CREATE TABLE ratings(
	rate_id SERIAL PRIMARY KEY,
	rating VARCHAR(1)
);
INSERT INTO ratings (rating) VALUES ('A'),('B'),('C'),('D');
SELECT * FROM ratings;
INSERT INTO ratings (rating) VALUES ('1'),('2'),('3'),('4');
SELECT 
	rate_id,
	CASE
		WHEN rating~E'^\\d+$' THEN
			CAST(rating AS INTEGER)
		ELSE
			0
	END AS rating
FROM ratings;

--numeric to string
SELECT TO_CHAR(100870,'9,99999');
SELECT 
	release_date,TO_CHAR(release_date,'DY-DD-MM-YYYY'), TO_CHAR(release_date,'DY, DD, MM, YYYY'), TO_CHAR(release_date,'DY'), 
	TO_CHAR(release_date,'DD'),  TO_CHAR(release_date,'MM'),  TO_CHAR(release_date,'YYYY')
FROM movies;
SELECT 
	update_date,TO_CHAR(update_date,'DY-DD-MM-YYYY'), TO_CHAR(update_date,'DY, DD, MM, YYYY'), TO_CHAR(update_date,'DY'), 
	TO_CHAR(update_date,'DD'),  TO_CHAR(update_date,'MM'),  TO_CHAR(update_date,'YYYY'), TO_CHAR(update_date,'HH24:MI:SS'),
	TO_CHAR(update_date,'HH24'), TO_CHAR(update_date,'MI'), TO_CHAR(update_date,'SS'), TO_CHAR(update_date,'AM')
FROM t_tags;
SELECT movie_id, revenue_domestic, TO_CHAR(revenue_domestic,'$99999D9999') FROM movies_revenues;

--string to numeric
SELECT 
	TO_NUMBER(
	'$1,978,299.78-',
	'L9G999G999D99S'),
	TO_NUMBER(
	'$299.78-',
	'L9G999G999D99S')
;
SELECT 
	TO_NUMBER(
	'$1,978,299.78-',
	'9999999D99S'),
	TO_NUMBER(
	'$299.78-',
	'L9G999G999D99S')
;

--string to date
SELECT TO_DATE('20231230','YYYYMMDD'),TO_DATE('2023/12/30','YYYY/MM/DD'),TO_DATE('123023','MMDDYY'),TO_DATE('March 07, 2019','Month DD, YYYY');
--ERROR HANDLING
SELECT TO_DATE('20230231','YYYYMMDD'); --ERROR HERE BECAUSE FEBUARY DON'T HAVE 31

--user-defined type
CREATE DOMAIN addr VARCHAR(100) NOT NULL;
CREATE TABLE locations(
	address addr
);
INSERT INTO locations (address) VALUES ('123 VN');
SELECT * FROM locations;