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

--positive-numeric
CREATE DOMAIN positive_numeric INT NOT NULL CHECK (VALUE > 0);
CREATE TABLE sample(
	sample_id SERIAL PRIMARY KEY,
	value_num positive_numeric
);
INSERT INTO sample (value_num) VALUES (10);
INSERT INTO sample (value_num) VALUES (-1);
SELECT * FROM sample;

CREATE DOMAIN us_postal_code AS TEXT
CHECK (
	VALUE ~'^\d{5}$'
	OR VALUE ~'^\D{5}-\d{4}$'
);
CREATE TABLE addresses(
	address_id SERIAL PRIMARY KEY,
	postal_code us_postal_code
);
INSERT INTO addresses (postal_code) VALUES ('1000-100');
SELECT * FROM addresses;

CREATE DOMAIN proper_email VARCHAR(150)
CHECK (VALUE ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$');
CREATE TABLE client_names(
	client_id SERIAL PRIMARY KEY,
	email proper_email
);
INSERT INTO client_names (email) VALUES ('a@b.com');
SELECT * FROM client_names;

CREATE DOMAIN valid_color VARCHAR(10)
CHECK (VALUE IN ('red','green','blue'));
CREATE TABLE colors(
	color valid_color
);
INSERT INTO colors (color) VALUES ('red');
SELECT * FROM colors;

CREATE DOMAIN user_status VARCHAR(10)
CHECK (VALUE IN ('enable','disable'));
CREATE TABLE user_check(
	status user_status
);
INSERT INTO user_check (status) VALUES ('enable');

CREATE TYPE address AS(
	city VARCHAR(50),
	country VARCHAR(50)
);
CREATE TABLE companies(
	comp_id SERIAL PRIMARY KEY,
	address address
);
INSERT INTO companies (address) VALUES (ROW('LONDON','UK')),(ROW('NY','UK'));
SELECT (address).country FROM companies;
SELECT (companies.address).city FROM companies;

CREATE TYPE inventory_item AS(
	product_name VARCHAR(50),
	supplier_id INT,
	price NUMERIC
);
CREATE TABLE inventory(
	inventory_id SERIAL PRIMARY KEY,
	item inventory_item
);
SELECT * FROM inventory;
INSERT INTO inventory (item) VALUES (ROW('SHAMPOO',20,10.999));
INSERT INTO inventory (item) VALUES (ROW('SHAMPOO',5,10.999));
INSERT INTO inventory (item) VALUES (ROW('SHAMPOO',10,10.999));
SELECT inventory_id,(item).product_name FROM inventory WHERE (item).supplier_id < 10;

CREATE TYPE currency AS ENUM ('USA','VND','TH');
SELECT 'USD'::currency;
ALTER TYPE currency ADD VALUE 'JPN' AFTER 'VND';
CREATE TABLE stocks(
	stock_id SERIAL PRIMARY KEY,
	stock_currency currency
);
INSERT INTO stocks (stock_currency) VALUES ('USA');
INSERT INTO stocks (stock_currency) VALUES ('USD1');
SELECT * FROM stocks;
CREATE TYPE sample_type AS ENUM ('abc','123');
DROP TYPE sample_type;

CREATE TYPE myaddress AS(
	city VARCHAR(50),
	myname VARCHAR(50)
);
ALTER TYPE myaddress RENAME TO my_address;
ALTER TYPE my_address OWNER TO ton;
ALTER TYPE my_address SET SCHEMA test_scm;
ALTER TYPE test_scm.my_address ADD ATTRIBUTE street_address VARCHAR(50);

CREATE TYPE status_enum AS ENUM ('pending','pass','fail','done');
CREATE TABLE jobs(
	job_id SERIAL PRIMARY KEY,
	job_status status_enum
);
INSERT INTO jobs (job_status) VALUES ('pass');
INSERT INTO jobs (job_status) VALUES ('fail');
INSERT INTO jobs (job_status) VALUES ('no');
SELECT * FROM jobs;
UPDATE jobs SET job_status = 'done' WHERE job_status = 'fail';
ALTER TYPE status_enum RENAME TO status_enum_old;
CREATE TYPE status_enum AS ENUM ('pending','pass','done');
ALTER TABLE jobs ALTER COLUMN job_status TYPE status_enum USING job_status::text::status_enum;
DROP TYPE status_enum_old;

CREATE TYPE status AS ENUM ('pending','approve','reject');
CREATE TABLE cron_jobs(
	cron_job_id int,
	status status DEFAULT 'pending'
);
INSERT INTO cron_jobs (cron_job_id) VALUES (1);
SELECT * FROM cron_jobs;
INSERT INTO cron_jobs (cron_job_id,status) VALUES (2,'approve');

DO
$$
BEGIN
	IF NOT EXISTS (SELECT * 
				   FROM pg_type typ INNER JOIN pg_namespace nsp ON nsp.oid = typ.typnamespace 
				   WHERE nsp.nspname=current_schema() AND typ.typname='ai')
	THEN CREATE TYPE ai AS (a text,i integer);
	END IF;
END;
$$
LANGUAGE plpgsql;