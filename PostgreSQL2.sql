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

/*
	Constraints
	- controls kind of data, rule enforced on data column, prevent invalid data, ensure accurary and reliability, be on Table or Column
	- types: NOT NULL, UNIQUE, DEFAULT, PRIMARY KEY, FOREIGN KEY, CHECK
	
	NOT NULL: = unknow or information missing, # '' or 0, use IS NULL or IS NOT NULL
*/
CREATE TABLE table_nn(
	table_nn_id SERIAL PRIMARY KEY,
	tag TEXT NOT NULL
);
INSERT INTO table_nn (tag) VALUES('ADAM');
INSERT INTO table_nn (tag) VALUES('');
INSERT INTO table_nn (tag) VALUES(NULL);
SELECT * FROM table_nn;

CREATE TABLE table_nn2(
	table_nn_id SERIAL PRIMARY KEY,
	tag2 TEXT
);
ALTER TABLE table_nn2
ALTER COLUMN tag2 SET NOT NULL;

--UNIQUE: value stored in a column or group of column are unique, insert, update
CREATE TABLE table_email(
	table_email_id SERIAL PRIMARY KEY,
	email TEXT UNIQUE
);
INSERT INTO table_email (email) VALUES ('A@A.COM');
SELECT * FROM table_email;

CREATE TABLE table_products(
	id SERIAL PRIMARY KEY,
	product_code VARCHAR(10),
	product_name TEXT
);
ALTER TABLE table_products
ADD CONSTRAINT unique_product_code UNIQUE (product_code,product_name);
INSERT INTO table_products (product_code,product_name) VALUES ('A','APPLE');
INSERT INTO table_products (product_code,product_name) VALUES ('a','apple');
SELECT * FROM table_products;

--DEFAULT
CREATE TABLE employees(
	employee_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	is_enable VARCHAR(2) DEFAULT 'Y'
);
INSERT INTO employees (first_name,last_name) VALUES ('R','R');
SELECT * FROM employees;
ALTER TABLE employees
ALTER COLUMN is_enable SET DEFAULT 'N';
ALTER TABLE employees
ALTER COLUMN is_enable DROP DEFAULT;

--PRIMARY KEY
CREATE TABLE table_items(
	item_id SERIAL PRIMARY KEY,
	item_name VARCHAR(100) NOT NULL
);
SELECT * FROM table_items;
ALTER TABLE table_items
DROP CONSTRAINT table_items_pkey;
ALTER TABLE table_items
ADD PRIMARY KEY (item_id);

--COMPOSITE PRIMARY KEY
CREATE TABLE t_grades(
	course_id VARCHAR(100) NOT NULL,
	student_id VARCHAR(100) NOT NULL,
	grade INT NOT NULL,
	PRIMARY KEY (course_id,student_id)
);
INSERT INTO t_grades (course_id,student_id,grade) VALUES ('1','A1',10),('2','A2',29),('3','A3',50);
SELECT * FROM t_grades;
DROP TABLE t_grades;
ALTER TABLE t_grades
ADD CONSTRAINT t_grades_course_id_student_id_pkey
PRIMARY KEY (course_id,student_id);

--FOREIGN KEY
CREATE TABLE t_products(
	product_id INT PRIMARY KEY,
	product_name VARCHAR(50),
	supplier_id INT
);
CREATE TABLE t_suppliers(
	supplier_id INT PRIMARY KEY,
	supplier_name VARCHAR(100) NOT NULL
);
INSERT INTO t_suppliers(supplier_id,supplier_name) VALUES (1,'a'),(2,'b');
SELECT * FROM t_suppliers;
INSERT INTO t_products(product_id,product_name,supplier_id) VALUES (1,'aa',1),(2,'bb',2);
INSERT INTO t_products(product_id,product_name,supplier_id) VALUES (3,'aa',100),(4,'bb',200); --can add invalid data
SELECT * FROM t_products;
DROP TABLE t_products;
DROP TABLE t_suppliers;

CREATE TABLE t_products(
	product_id INT PRIMARY KEY,
	product_name VARCHAR(50),
	supplier_id INT,
	FOREIGN KEY (supplier_id) REFERENCES t_suppliers(supplier_id)
);
CREATE TABLE t_suppliers(
	supplier_id INT PRIMARY KEY,
	supplier_name VARCHAR(100) NOT NULL
);
INSERT INTO t_suppliers(supplier_id,supplier_name) VALUES (1,'a'),(2,'b');
SELECT * FROM t_suppliers;
INSERT INTO t_products(product_id,product_name,supplier_id) VALUES (1,'aa',1),(2,'bb',2);
INSERT INTO t_products(product_id,product_name,supplier_id) VALUES (3,'aa',100),(4,'bb',200); --cannot add invalid data
DELETE FROM t_suppliers WHERE supplier_id = 1;
DELETE FROM t_products WHERE product_id = 1;
UPDATE t_products
SET supplier_id = 100
WHERE product_id = 1;

ALTER TABLE t_products
DROP CONSTRAINT t_products_supplier_id_fkey;
ALTER TABLE t_products
ADD CONSTRAINT t_products_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES t_suppliers (supplier_id);

--CHECK
CREATE TABLE staff(
	staff_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	birth_date DATE CHECK (birth_date > '1900-01-01'),
	joined_date DATE CHECK (joined_date > birth_date),
	salary numeric CHECK (salary > 0)
);
SELECT * FROM staff;
INSERT INTO staff (first_name, last_name, birth_date, joined_date, salary) VALUES 
('adam','king','1999-01-01','2002-01-01',100);
INSERT INTO staff (first_name, last_name, birth_date, joined_date, salary) VALUES 
('adam','king','1800-01-01','2002-01-01',10);
UPDATE staff
SET birth_date = '1800-01-01'
WHERE staff_id = 1;

CREATE TABLE prices(
	price_id SERIAL PRIMARY KEY,
	product_id INT NOT NULL,
	price NUMERIC NOT NULL,
	discount NUMERIC NOT NULL,
	valid_from DATE NOT NULL
);
ALTER TABLE prices
ADD CONSTRAINT price_check
CHECK(
	price > 0 AND discount >= 0 AND price > discount
);
INSERT INTO prices (product_id,price,discount,valid_from) VALUES ('1',200,120,'2020-10-01');
SELECT * FROM prices;
ALTER TABLE prices
RENAME CONSTRAINT price_check TO price_discount_check;
ALTER TABLE prices
DROP CONSTRAINT  price_discounts_check;

--SEQUENCE
CREATE SEQUENCE IF NOT EXISTS test_seq;
SELECT nextval('test_seq');
SELECT currval('test_seq');
SELECT setval('test_seq',100);
SELECT setval('test_seq',200,false);
CREATE SEQUENCE IF NOT EXISTS test_seq2 START WITH 100;
ALTER SEQUENCE test_seq RESTART WITH 100;
ALTER SEQUENCE test_seq RENAME TO my_sequence;

CREATE SEQUENCE IF NOT EXISTS test_seq3
INCREMENT 50
MINVALUE 40
MAXVALUE 6000
START WITH 500;
SELECT nextval('test_seq3');

CREATE SEQUENCE IF NOT EXISTS test_seq_smallint AS SMALLINT;
CREATE SEQUENCE IF NOT EXISTS test_seq_smallint AS INT;
CREATE SEQUENCE IF NOT EXISTS test_seq4;

DROP SEQUENCE test_seq1;

--include sequence into table
CREATE TABLE users(
	user_id SERIAL PRIMARY KEY, -- SERIAL will include sequence
	user_name VARCHAR(50)
);
INSERT INTO users (user_name) VALUES ('ADAM');
SELECT * FROM users;
ALTER SEQUENCE users_user_id_seq RESTART WITH 100;

--attach sequence to table
CREATE TABLE users2(
	user2_id INT PRIMARY KEY, -- INT will NOT include sequence
	user2_name VARCHAR(50)
);
CREATE SEQUENCE users2_user2_id_seq
START WITH 100 OWNED BY users2.user2_id;
ALTER TABLE users2
ALTER COLUMN user2_id SET DEFAULT nextval('users2_user2_id_seq');
INSERT INTO users2 (user2_name) VALUES ('ADAM');
SELECT * FROM users2;

--list all sequences
SELECT relname sequence_name
FROM pg_class
WHERE relkind = 'S';

--share sequence among tables
CREATE SEQUENCE common_fruits_seq START WITH 100;
CREATE TABLE apples(
	fruit_id INT DEFAULT nextval('common_fruits_seq') NOT NULL,
	fruit_name VARCHAR(50)
);
INSERT INTO apples (fruit_name) VALUES ('big apple');
SELECT * FROM apples;
CREATE TABLE mangoes(
	fruit_id INT DEFAULT nextval('common_fruits_seq') NOT NULL,
	fruit_name VARCHAR(50)
);
INSERT INTO mangoes (fruit_name) VALUES ('big mango');
SELECT * FROM mangoes;

--create alpha-numeric sequence
CREATE TABLE contacts(
	contact_id SERIAL PRIMARY KEY,
	contact_name VARCHAR(10)
);
INSERT INTO contacts (contact_name) VALUES ('admin');
SELECT * FROM contacts;

CREATE TABLE contacts(
	contact_id TEXT NOT NULL DEFAULT ('ID' || nextval('table_seq')),
	contact_name VARCHAR(10)
);

CREATE TABLE tbl_seq(
	contact_id TEXT NOT NULL DEFAULT ('ID' || nextval('table_seq')),
	contact_name VARCHAR(10)
);
INSERT INTO tbl_seq (contact_name) VALUES ('admin');
SELECT * FROM tbl_seq;
ALTER SEQUENCE tbl_seq OWNED BY contacts.contact_id;

--group data
SELECT * FROM movies;
SELECT movie_lang,COUNT(movie_lang) FROM movies GROUP BY movie_lang;
SELECT movie_lang,AVG(movie_length) FROM movies GROUP BY movie_lang ORDER BY movie_lang;
SELECT age_certificate,SUM(movie_length) FROM movies GROUP BY age_certificate ORDER BY age_certificate;
SELECT movie_lang,MIN(movie_length),MAX(movie_length) FROM movies GROUP BY movie_lang ORDER BY MAX(movie_length) DESC;
SELECT movie_lang,age_certificate,AVG(movie_length) FROM movies GROUP BY movie_lang, age_certificate ORDER BY movie_lang, 3 DESC;
SELECT movie_lang,age_certificate,AVG(movie_length) 
FROM movies 
WHERE movie_length > 100 
GROUP BY movie_lang, age_certificate,movie_length 
ORDER BY movie_length, 3 DESC;
SELECT age_certificate,AVG(movie_length) FROM movies WHERE age_certificate = 'PG' GROUP BY age_certificate;
SELECT * FROM age_certificate;

SELECT * FROM directors;
SELECT nationality,COUNT(director_id) AS "TOTAL DIRECTORS" FROM directors GROUP BY nationality ORDER BY 2 DESC;
SELECT movie_lang,age_certificate,SUM(movie_length) FROM movies GROUP BY movie_lang,age_certificate ORDER BY 3 DESC;

/*
FROM -> 
WHERE -> conditions
GROUP BY -> group sets
HAVING -> filter again
SELECT -> columns
DISTINCT -> unique columns if you use DISTINCT
ORDER BY -> 
LIMIT -> filter records
*/

SELECT * FROM movies;
SELECT movie_lang,SUM(movie_length) FROM movies GROUP BY movie_lang HAVING SUM(movie_length) > 200 ORDER BY SUM(movie_length);
SELECT movie_lang,SUM(movie_length) FROM movies GROUP BY movie_lang HAVING SUM(movie_length) > 200 ORDER BY SUM(movie_length);
SELECT * FROM directors;
SELECT * FROM movies;

SELECT movie_lang,SUM(movie_length) FROM movies GROUP BY movie_lang;
SELECT director_id, SUM(movie_length) FROM movies GROUP BY director_id HAVING SUM(movie_length) > 200 ORDER BY director_id;
SELECT director_id, SUM(movie_length) FROM movies GROUP BY director_id HAVING SUM(movie_length) > 200 ORDER BY 2 DESC;

/*
	HAVING VS WHERE
		- HAVING works on result group
		- WHERE works on SELECT columns and not on result group
*/
select movie_lang,sum(movie_length) from movies group by movie_lang having sum(movie_length) order by 2 desc;
select movie_lang,sum(movie_length) from movies where movie_length > 100 group by movie_lang order by 2 desc;

create table employee_test(
	employee_id SERIAL PRIMARY KEY,
	employee_name VARCHAR(100),
	deparment VARCHAR(100),
	salary INT
);
select * from employee_test;
insert into employee_test (employee_name,department,salary) values 
('john','finance',2500),
('MARY',NULL,2500),
('ADAM',NULL,2500),
('BRUCE','finance',2500),
('LINDA','IT',2500),
('MEGAN','IT',2500);
;
select deparment,count(salary) as total_employees from employee_test group by deparment order by deparment;
select coalesce(deparmentj,'* NO DEPARMENT *') as department,count(salary) as total_employees from employee_test group by deparment order by deparment;