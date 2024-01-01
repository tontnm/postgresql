-- Database: mydata

-- DROP DATABASE IF EXISTS mydata;

CREATE DATABASE mydata
    WITH
    OWNER = ton
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
	
CREATE TABLE persons(
	person_id SERIAL PRIMARY KEY,
	first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL
);

ALTER TABLE persons
ADD COLUMN age INT NOT NULL,
ADD COLUMN nationality VARCHAR(50) NOT NULL,
ADD COLUMN email VARCHAR(100) UNIQUE;

SELECT * FROM persons;
SELECT * FROM users;

ALTER TABLE persons
RENAME TO users;

ALTER TABLE users
RENAME COLUMN age TO u_age;

ALTER TABLE users
DROP COLUMN u_age;

ALTER TABLE users
ADD COLUMN age VARCHAR(10);

ALTER TABLE users
ALTER COLUMN age TYPE INT
USING age::integer;

ALTER TABLE users
ALTER COLUMN age TYPE VARCHAR(20);

ALTER TABLE users
ADD COLUMN is_enable BOOL;

ALTER TABLE users
ALTER COLUMN is_enable SET DEFAULT 'Y';

CREATE TABLE web_links(
	link_id SERIAL PRIMARY KEY,
	link_url VARCHAR(200) NOT NULL,
	link_target VARCHAR(50)
);
INSERT INTO web_links (link_url,link_target) VALUES
('http://google.com.vn','_blank');
SELECT * FROM web_links;
ALTER TABLE web_links
ADD CONSTRAINT unique_web_url UNIQUE (link_url);
ALTER TABLE web_links
ADD COLUMN is_enable BOOL;
INSERT INTO web_links (link_url,link_target,is_enable) VALUES
('http://amazon.com','_blank','Y');
ALTER TABLE web_links
ADD CHECK (is_enable IN ('Y','N'));
INSERT INTO web_links (link_url,link_target,is_enable) VALUES
('http://amazon.com','_blank','Q');
ALTER TABLE web_links
ADD COLUMN is_exist VARCHAR(10);
ALTER TABLE web_links
ADD CHECK (is_exist IN ('Y','N'));
INSERT INTO web_links (link_url,link_target,is_enable,is_exist) VALUES
('http://amazon.com','_blank','Y','Q');
UPDATE web_links
SET link_url = 'http://google.com.vn'
WHERE link_id = 5;
UPDATE web_links
SET is_exist = 'Q'
WHERE link_id = '1';