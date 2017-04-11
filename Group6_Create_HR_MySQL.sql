--
--
--  Create the user

create user group6 identified by '123456';
GRANT ALL PRIVILEGES ON hr.* To group6; 
GRANT ALL PRIVILEGES ON ap.* To group6; 
GRANT ALL PRIVILEGES ON ex.* To group6; 
GRANT ALL PRIVILEGES ON om.* To group6; 

--  The next command does not work -  Still researching
--  connect --user=ruiyanghe -password=123456;

-- create database
DROP DATABASE IF EXISTS hr;
CREATE DATABASE hr;

-- select database
USE hr;


-- ******  Creating REGIONS table ....

CREATE TABLE regions (
    region_id INT NOT NULL unique AUTO_INCREMENT,
    region_name VARCHAR(25)
);

ALTER TABLE regions
ADD CONSTRAINT reg_id_pk PRIMARY KEY (region_id);

-- REM ********************************************************************
-- REM Create the COUNTRIES table to hold country information for customers
-- REM and company locations. 
-- REM OE.CUSTOMERS table and HR.LOCATIONS have a foreign key to this table.

-- Prompt ******  Creating COUNTRIES table ....

CREATE TABLE countries (
    country_id CHAR(2) NOT NULL,
    country_name VARCHAR(40),
    region_id INT,
    CONSTRAINT country_c_id_pk PRIMARY KEY (country_id)
); 

ALTER TABLE countries
ADD CONSTRAINT countr_reg_fk FOREIGN KEY (region_id)
	REFERENCES regions(region_id);

-- REM ********************************************************************
-- REM Create the LOCATIONS table to hold address information for company departments.
-- REM HR.DEPARTMENTS has a foreign key to this table.

-- Prompt ******  Creating LOCATIONS table ....

CREATE TABLE locations (
    location_id INT(4) NOT NULL unique auto_increment,
    street_address VARCHAR(40),
    postal_code VARCHAR(12),
    city VARCHAR(30),
    state_province VARCHAR(25),
    country_id CHAR(2)
);

CREATE UNIQUE INDEX loc_id_pk
ON locations (location_id) ;

ALTER TABLE locations
ADD CONSTRAINT loc_id_pk PRIMARY KEY (location_id),
ADD CONSTRAINT loc_c_id_fk FOREIGN KEY (country_id)
	REFERENCES countries(country_id);

-- REM ********************************************************************
-- REM Create the DEPARTMENTS table to hold company department information.
-- REM HR.EMPLOYEES and HR.JOB_HISTORY have a foreign key to this table.

-- Prompt ******  Creating DEPARTMENTS table ....

CREATE TABLE departments (
    department_id INT(4) NOT NULL,
    department_name VARCHAR(30),
    manager_id INT(6),
    location_id INT(4)
);

CREATE UNIQUE INDEX dept_id_pk
ON departments (department_id) ;

ALTER TABLE departments
ADD CONSTRAINT dept_id_pk PRIMARY KEY (department_id),
ADD CONSTRAINT dept_loc_fk FOREIGN KEY (location_id)
	REFERENCES locations (location_id);

-- REM ********************************************************************
-- REM Create the JOBS table to hold the different names of job roles within the company.
-- REM HR.EMPLOYEES has a foreign key to this table.

-- Prompt ******  Creating JOBS table ....

CREATE TABLE jobs (
    job_id VARCHAR(10),
    job_title VARCHAR(35) NOT NULL,
    min_salary INT(6),
    max_salary INT(6)
);

CREATE UNIQUE INDEX job_id_pk 
ON jobs (job_id) ;

ALTER TABLE jobs
ADD CONSTRAINT job_id_pk PRIMARY KEY(job_id);

-- REM ********************************************************************
-- REM Create the JOB_GRADES table to hold the different names of job roles within the company.

-- Prompt ******  Creating JOB_GRADES table ....

CREATE TABLE job_grades (
    GRADE_LEVEL VARCHAR(3),
    lowest_sal INT(6),
    highest_sal INT(6)
);

CREATE UNIQUE INDEX job_grades_id_pk 
ON job_grades (GRADE_LEVEL) ;

ALTER TABLE job_grades
ADD CONSTRAINT job_grades_id_pk PRIMARY KEY(GRADE_LEVEL);

-- REM ********************************************************************
-- REM Create the EMPLOYEES table to hold the employee personnel 
-- REM information for the company.
-- REM HR.EMPLOYEES has a self referencing foreign key to this table.

-- Prompt ******  Creating EMPLOYEES table ....

CREATE TABLE employees (
    employee_id INT(6) unique AUTO_INCREMENT,
    first_name VARCHAR(20),
    last_name VARCHAR(25) NOT NULL,
    email VARCHAR(25) NOT NULL,
    phone_number VARCHAR(20),
    hire_date DATE NOT NULL,
    job_id VARCHAR(10) NOT NULL,
    salary DECIMAL(8 , 2 ),
    commission_pct DECIMAL(2 , 2 ),
    manager_id INT(6),
    department_id INT(4),
    CONSTRAINT emp_salary_min CHECK (salary > 0),
    CONSTRAINT emp_email_uk UNIQUE (email)
);

CREATE UNIQUE INDEX emp_emp_id_pk
ON employees (employee_id) ;

ALTER TABLE employees AUTO_INCREMENT=10;

ALTER TABLE employees
ADD CONSTRAINT emp_emp_id_pk PRIMARY KEY (employee_id),
ADD CONSTRAINT emp_dept_fk FOREIGN KEY (department_id)
	REFERENCES departments (department_id),
ADD CONSTRAINT emp_job_fk FOREIGN KEY (job_id)
	REFERENCES jobs (job_id),
ADD CONSTRAINT emp_manager_fk FOREIGN KEY (manager_id)
	REFERENCES employees (employee_id);

ALTER TABLE departments
ADD CONSTRAINT dept_mgr_fk FOREIGN KEY (manager_id)
	REFERENCES employees (employee_id);

-- REM ********************************************************************
-- REM Create the JOB_HISTORY table to hold the history of jobs that 
-- REM employees have held in the past.
-- REM HR.JOBS, HR_DEPARTMENTS, and HR.EMPLOYEES have a foreign key to this table.

-- Prompt ******  Creating JOB_HISTORY table ....

CREATE TABLE job_history (
    employee_id INT(6) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    job_id VARCHAR(10) NOT NULL,
    department_id INT(4),
    CONSTRAINT jhist_date_interval CHECK (end_date > start_date)
);

CREATE UNIQUE INDEX jhist_emp_id_st_date_pk 
ON job_history (employee_id, start_date) ;

ALTER TABLE job_history
ADD CONSTRAINT jhist_emp_id_st_date_pk PRIMARY KEY (employee_id, start_date),
ADD CONSTRAINT jhist_job_fk FOREIGN KEY (job_id)
	REFERENCES jobs (job_id),
ADD CONSTRAINT jhist_emp_fk FOREIGN KEY (employee_id)
	REFERENCES employees (employee_id), 
ADD CONSTRAINT jhist_dept_fk FOREIGN KEY (department_id)
	REFERENCES departments (department_id);

-- REM ********************************************************************
-- REM Create the EMP_DETAILS_VIEW that joins the employees, jobs, 
-- REM departments, jobs, countries, and locations table to provide details
-- REM about employees.

-- Prompt ******  Creating EMP_DETAILS_VIEW view ...

CREATE OR REPLACE VIEW emp_details_view
  (employee_id,
   job_id,
   manager_id,
   department_id,
   location_id,
   country_id,
   first_name,
   last_name,
   salary,
   commission_pct,
   department_name,
   job_title,
   city,
   state_province,
   country_name,
   region_name)
AS SELECT
  e.employee_id, 
  e.job_id, 
  e.manager_id, 
  e.department_id,
  d.location_id,
  l.country_id,
  e.first_name,
  e.last_name,
  e.salary,
  e.commission_pct,
  d.department_name,
  j.job_title,
  l.city,
  l.state_province,
  c.country_name,
  r.region_name
FROM
  employees e,
  departments d,
  jobs j,
  locations l,
  countries c,
  regions r
WHERE e.department_id = d.department_id
  AND d.location_id = l.location_id
  AND l.country_id = c.country_id
  AND c.region_id = r.region_id
  AND j.job_id = e.job_id 
;

COMMIT;


-- SET VERIFY OFF
-- ALTER SESSION SET NLS_LANGUAGE=American; 

-- Prompt ******  Populating look up table JOB_GRADES

-- SET DEFINE OFF;
Insert into JOB_GRADES (GRADE_LEVEL,LOWEST_SAL,HIGHEST_SAL) 
values ('A',1000,2999);
Insert into JOB_GRADES (GRADE_LEVEL,LOWEST_SAL,HIGHEST_SAL) 
values ('B',3000,5999);
Insert into JOB_GRADES (GRADE_LEVEL,LOWEST_SAL,HIGHEST_SAL) 
values ('C',6000,9999);
Insert into JOB_GRADES (GRADE_LEVEL,LOWEST_SAL,HIGHEST_SAL) 
values ('D',10000,14999);
Insert into JOB_GRADES (GRADE_LEVEL,LOWEST_SAL,HIGHEST_SAL) 
values ('E',15000,24999);
Insert into JOB_GRADES (GRADE_LEVEL,LOWEST_SAL,HIGHEST_SAL) 
values ('F',25000,40000);

-- REM ***************************insert data into the REGIONS table

-- Prompt ******  Populating REGIONS table ....

INSERT INTO regions VALUES 
        ( null
        , 'Europe' 
        );

INSERT INTO regions VALUES 
        ( null
        , 'Americas' 
        );

INSERT INTO regions VALUES 
        ( null
        , 'Asia' 
        );

INSERT INTO regions VALUES 
        ( null
        , 'Middle East and Africa' 
        );

-- REM ***************************insert data into the COUNTRIES table

-- Prompt ******  Populating COUNTIRES table ....

INSERT INTO countries VALUES 
        ( 'IT'
        , 'Italy'
        , 1 
        );

INSERT INTO countries VALUES 
        ( 'JP'
        , 'Japan'
	, 3 
        );

INSERT INTO countries VALUES 
        ( 'US'
        , 'United States of America'
        , 2 
        );

INSERT INTO countries VALUES 
        ( 'CA'
        , 'Canada'
        , 2 
        );

INSERT INTO countries VALUES 
        ( 'CN'
        , 'China'
        , 3 
        );

INSERT INTO countries VALUES 
        ( 'IN'
        , 'India'
        , 3 
        );

INSERT INTO countries VALUES 
        ( 'AU'
        , 'Australia'
        , 3 
        );

INSERT INTO countries VALUES 
        ( 'ZW'
        , 'Zimbabwe'
        , 4 
        );

INSERT INTO countries VALUES 
        ( 'SG'
        , 'Singapore'
        , 3 
        );

INSERT INTO countries VALUES 
        ( 'UK'
        , 'United Kingdom'
        , 1 
        );

INSERT INTO countries VALUES 
        ( 'FR'
        , 'France'
        , 1 
        );

INSERT INTO countries VALUES 
        ( 'DE'
        , 'Germany'
        , 1 
        );

INSERT INTO countries VALUES 
        ( 'ZM'
        , 'Zambia'
        , 4 
        );

INSERT INTO countries VALUES 
        ( 'EG'
        , 'Egypt'
        , 4 
        );

INSERT INTO countries VALUES 
        ( 'BR'
        , 'Brazil'
        , 2 
        );

INSERT INTO countries VALUES 
        ( 'CH'
        , 'Switzerland'
        , 1 
        );

INSERT INTO countries VALUES 
        ( 'NL'
        , 'Netherlands'
        , 1 
        );

INSERT INTO countries VALUES 
        ( 'MX'
        , 'Mexico'
        , 2 
        );

INSERT INTO countries VALUES 
        ( 'KW'
        , 'Kuwait'
        , 4 
        );

INSERT INTO countries VALUES 
        ( 'IL'
        , 'Israel'
        , 4 
        );

INSERT INTO countries VALUES 
        ( 'DK'
        , 'Denmark'
        , 1 
        );

INSERT INTO countries VALUES 
        ( 'HK'
        , 'HongKong'
        , 3 
        );

INSERT INTO countries VALUES 
        ( 'NG'
        , 'Nigeria'
        , 4 
        );

INSERT INTO countries VALUES 
        ( 'AR'
        , 'Argentina'
        , 2 
        );

INSERT INTO countries VALUES 
        ( 'BE'
        , 'Belgium'
        , 1 
        );


-- REM ***************************insert data into the LOCATIONS table

-- Prompt ******  Populating LOCATIONS table ....

INSERT INTO locations VALUES 
        ( null 
        , '1297 Via Cola di Rie'
        , '00989'
        , 'Roma'
        , NULL
        , 'IT'
        );

INSERT INTO locations VALUES 
        ( null 
        , '93091 Calle della Testa'
        , '10934'
        , 'Venice'
        , NULL
        , 'IT'
        );

INSERT INTO locations VALUES 
        ( null 
        , '2017 Shinjuku-ku'
        , '1689'
        , 'Tokyo'
        , 'Tokyo Prefecture'
        , 'JP'
        );

INSERT INTO locations VALUES 
        ( null 
        , '9450 Kamiya-cho'
        , '6823'
        , 'Hiroshima'
        , NULL
        , 'JP'
        );

INSERT INTO locations VALUES 
        ( null 
        , '2014 Jabberwocky Rd'
        , '26192'
        , 'Southlake'
        , 'Texas'
        , 'US'
        );

INSERT INTO locations VALUES 
        ( null 
        , '2011 Interiors Blvd'
        , '99236'
        , 'South San Francisco'
        , 'California'
        , 'US'
        );

INSERT INTO locations VALUES 
        ( null 
        , '2007 Zagora St'
        , '50090'
        , 'South Brunswick'
        , 'New Jersey'
        , 'US'
        );

INSERT INTO locations VALUES 
        ( null 
        , '2004 Charade Rd'
        , '98199'
        , 'Seattle'
        , 'Washington'
        , 'US'
        );

INSERT INTO locations VALUES 
        ( null 
        , '147 Spadina Ave'
        , 'M5V 2L7'
        , 'Toronto'
        , 'Ontario'
        , 'CA'
        );

INSERT INTO locations VALUES 
        ( null 
        , '6092 Boxwood St'
        , 'YSW 9T2'
        , 'Whitehorse'
        , 'Yukon'
        , 'CA'
        );

INSERT INTO locations VALUES 
        ( null 
        , '40-5-12 Laogianggen'
        , '190518'
        , 'Beijing'
        , NULL
        , 'CN'
        );

INSERT INTO locations VALUES 
        ( null 
        , '1298 Vileparle (E)'
        , '490231'
        , 'Bombay'
        , 'Maharashtra'
        , 'IN'
        );

INSERT INTO locations VALUES 
        ( null 
        , '12-98 Victoria Street'
        , '2901'
        , 'Sydney'
        , 'New South Wales'
        , 'AU'
        );

INSERT INTO locations VALUES 
        ( null 
        , '198 Clementi North'
        , '540198'
        , 'Singapore'
        , NULL
        , 'SG'
        );

INSERT INTO locations VALUES 
        ( null 
        , '8204 Arthur St'
        , NULL
        , 'London'
        , NULL
        , 'UK'
        );

INSERT INTO locations VALUES 
        ( null 
        , 'Magdalen Centre, The Oxford Science Park'
        , 'OX9 9ZB'
        , 'Oxford'
        , 'Oxford'
        , 'UK'
        );

INSERT INTO locations VALUES 
        ( null 
        , '9702 Chester Road'
        , '09629850293'
        , 'Stretford'
        , 'Manchester'
        , 'UK'
        );

INSERT INTO locations VALUES 
        ( null 
        , 'Schwanthalerstr. 7031'
        , '80925'
        , 'Munich'
        , 'Bavaria'
        , 'DE'
        );

INSERT INTO locations VALUES 
        ( null 
        , 'Rua Frei Caneca 1360 '
        , '01307-002'
        , 'Sao Paulo'
        , 'Sao Paulo'
        , 'BR'
        );

INSERT INTO locations VALUES 
        ( null 
        , '20 Rue des Corps-Saints'
        , '1730'
        , 'Geneva'
        , 'Geneve'
        , 'CH'
        );

INSERT INTO locations VALUES 
        ( null 
        , 'Murtenstrasse 921'
        , '3095'
        , 'Bern'
        , 'BE'
        , 'CH'
        );

INSERT INTO locations VALUES 
        ( null 
        , 'Pieter Breughelstraat 837'
        , '3029SK'
        , 'Utrecht'
        , 'Utrecht'
        , 'NL'
        );

INSERT INTO locations VALUES 
        ( null 
        , 'Mariano Escobedo 9991'
        , '11932'
        , 'Mexico City'
        , 'Distrito Federal,'
        , 'MX'
        ); 

-- REM ****************************insert data into the DEPARTMENTS table

-- Prompt ******  Populating DEPARTMENTS table ....

-- REM disable integrity constraint to EMPLOYEES to load data

-- ALTER TABLE departments 
--   DISABLE FOREIGN KEY dept_mgr_fk;

SET foreign_key_checks = 0;

INSERT INTO departments VALUES 
        ( 10
        , 'Administration'
        , 200
        , 1700
        );

INSERT INTO departments VALUES 
        ( 20
        , 'Marketing'
        , 201
        , 1800
        );
                                
INSERT INTO departments VALUES 
        ( 30
        , 'Purchasing'
        , 114
        , 1700
	);
                
INSERT INTO departments VALUES 
        ( 40
        , 'Human Resources'
        , 203
        , 2400
        );

INSERT INTO departments VALUES 
        ( 50
        , 'Shipping'
        , 121
        , 1500
        );
                
INSERT INTO departments VALUES 
        ( 60 
        , 'IT'
        , 103
        , 1400
        );
                
INSERT INTO departments VALUES 
        ( 70 
        , 'Public Relations'
        , 204
        , 2700
        );
                
INSERT INTO departments VALUES 
        ( 80 
        , 'Sales'
        , 145
        , 2500
        );
                
INSERT INTO departments VALUES 
        ( 90 
        , 'Executive'
        , 100
        , 1700
        );

INSERT INTO departments VALUES 
        ( 100 
        , 'Finance'
        , 108
        , 1700
        );
                
INSERT INTO departments VALUES 
        ( 110 
        , 'Accounting'
        , 205
        , 1700
        );

INSERT INTO departments VALUES 
        ( 120 
        , 'Treasury'
        , NULL
        , 1700
        );

INSERT INTO departments VALUES 
        ( 130 
        , 'Corporate Tax'
        , NULL
        , 1700
        );

INSERT INTO departments VALUES 
        ( 140 
        , 'Control And Credit'
        , NULL
        , 1700
        );

INSERT INTO departments VALUES 
        ( 150 
        , 'Shareholder Services'
        , NULL
        , 1700
        );

INSERT INTO departments VALUES 
        ( 160 
        , 'Benefits'
        , NULL
        , 1700
        );

INSERT INTO departments VALUES 
        ( 170 
        , 'Manufacturing'
        , NULL
        , 1700
        );

INSERT INTO departments VALUES 
        ( 180 
        , 'Construction'
        , NULL
        , 1700
        );

INSERT INTO departments VALUES 
        ( 190 
        , 'Contracting'
        , NULL
        , 1700
        );

INSERT INTO departments VALUES 
        ( 200 
        , 'Operations'
        , NULL
        , 1700
        );

INSERT INTO departments VALUES 
        ( 210 
        , 'IT Support'
        , NULL
        , 1700
        );

INSERT INTO departments VALUES 
        ( 220 
        , 'NOC'
        , NULL
        , 1700
        );

INSERT INTO departments VALUES 
        ( 230 
        , 'IT Helpdesk'
        , NULL
        , 1700
        );

INSERT INTO departments VALUES 
        ( 240 
        , 'Government Sales'
        , NULL
        , 1700
        );

INSERT INTO departments VALUES 
        ( 250 
        , 'Retail Sales'
        , NULL
        , 1700
        );

INSERT INTO departments VALUES 
        ( 260 
        , 'Recruiting'
        , NULL
        , 1700
        );

INSERT INTO departments VALUES 
        ( 270 
        , 'Payroll'
        , NULL
        , 1700
        );


-- REM ***************************insert data into the JOBS table

-- Prompt ******  Populating JOBS table ....

INSERT INTO jobs VALUES 
        ( 'AD_PRES'
        , 'President'
        , 20000
        , 40000
        );
INSERT INTO jobs VALUES 
        ( 'AD_VP'
        , 'Administration Vice President'
        , 15000
        , 30000
        );

INSERT INTO jobs VALUES 
        ( 'AD_ASST'
        , 'Administration Assistant'
        , 3000
        , 6000
        );

INSERT INTO jobs VALUES 
        ( 'FI_MGR'
        , 'Finance Manager'
        , 8200
        , 16000
        );

INSERT INTO jobs VALUES 
        ( 'FI_ACCOUNT'
        , 'Accountant'
        , 4200
        , 9000
        );

INSERT INTO jobs VALUES 
        ( 'AC_MGR'
        , 'Accounting Manager'
        , 8200
        , 16000
        );

INSERT INTO jobs VALUES 
        ( 'AC_ACCOUNT'
        , 'Public Accountant'
        , 4200
        , 9000
        );
INSERT INTO jobs VALUES 
        ( 'SA_MAN'
        , 'Sales Manager'
        , 10000
        , 20000
        );

INSERT INTO jobs VALUES 
        ( 'SA_REP'
        , 'Sales Representative'
        , 6000
        , 12000
        );

INSERT INTO jobs VALUES 
        ( 'PU_MAN'
        , 'Purchasing Manager'
        , 8000
        , 15000
        );

INSERT INTO jobs VALUES 
        ( 'PU_CLERK'
        , 'Purchasing Clerk'
        , 2500
        , 5500
        );

INSERT INTO jobs VALUES 
        ( 'ST_MAN'
        , 'Stock Manager'
        , 5500
        , 8500
        );
INSERT INTO jobs VALUES 
        ( 'ST_CLERK'
        , 'Stock Clerk'
        , 2000
        , 5000
        );

INSERT INTO jobs VALUES 
        ( 'SH_CLERK'
        , 'Shipping Clerk'
        , 2500
        , 5500
        );

INSERT INTO jobs VALUES 
        ( 'IT_PROG'
        , 'Programmer'
        , 4000
        , 10000
        );

INSERT INTO jobs VALUES 
        ( 'MK_MAN'
        , 'Marketing Manager'
        , 9000
        , 15000
        );

INSERT INTO jobs VALUES 
        ( 'MK_REP'
        , 'Marketing Representative'
        , 4000
        , 9000
        );

INSERT INTO jobs VALUES 
        ( 'HR_REP'
        , 'Human Resources Representative'
        , 4000
        , 9000
        );

INSERT INTO jobs VALUES 
        ( 'PR_REP'
        , 'Public Relations Representative'
        , 4500
        , 10500
        );


-- REM ***************************insert data into the EMPLOYEES table

-- Prompt ******  Populating EMPLOYEES table ....

INSERT INTO employees VALUES 
        ( null
        , 'Steven'
        , 'King'
        , 'SKING'
        , '515.123.4567'
        , str_to_date('17-JUN-1987', '%d-%b-%Y')
        , 'AD_PRES'
        , 24000
        , NULL
        , NULL
        , 90
        );

INSERT INTO employees VALUES 
        ( null
        , 'Neena'
        , 'Kochhar'
        , 'NKOCHHAR'
        , '515.123.4568'
        , str_to_date('21-SEP-1989', '%d-%b-%Y')
        , 'AD_VP'
        , 17000
        , NULL
        , 100
        , 90
        );

INSERT INTO employees VALUES 
        ( null
        , 'Lex'
        , 'De Haan'
        , 'LDEHAAN'
        , '515.123.4569'
        , str_to_date('13-JAN-1993', '%d-%b-%Y')
        , 'AD_VP'
        , 17000
        , NULL
        , 100
        , 90
        );

INSERT INTO employees VALUES 
        ( null
        , 'Alexander'
        , 'Hunold'
        , 'AHUNOLD'
        , '590.423.4567'
        , str_to_date('03-JAN-1990', '%d-%b-%Y')
        , 'IT_PROG'
        , 9000
        , NULL
        , 102
        , 60
        );

INSERT INTO employees VALUES 
        ( null
        , 'Bruce'
        , 'Ernst'
        , 'BERNST'
        , '590.423.4568'
        , str_to_date('21-MAY-1991', '%d-%b-%Y')
        , 'IT_PROG'
        , 6000
        , NULL
        , 103
        , 60
        );

INSERT INTO employees VALUES 
        ( null
        , 'David'
        , 'Austin'
        , 'DAUSTIN'
        , '590.423.4569'
        , str_to_date('25-JUN-1997', '%d-%b-%Y')
        , 'IT_PROG'
        , 4800
        , NULL
        , 103
        , 60
        );

INSERT INTO employees VALUES 
        ( null
        , 'Valli'
        , 'Pataballa'
        , 'VPATABAL'
        , '590.423.4560'
        , str_to_date('05-FEB-1998', '%d-%b-%Y')
        , 'IT_PROG'
        , 4800
        , NULL
        , 103
        , 60
        );

INSERT INTO employees VALUES 
        ( null
        , 'Diana'
        , 'Lorentz'
        , 'DLORENTZ'
        , '590.423.5567'
        , str_to_date('07-FEB-1999', '%d-%b-%Y')
        , 'IT_PROG'
        , 4200
        , NULL
        , 103
        , 60
        );

INSERT INTO employees VALUES 
        ( null
        , 'Nancy'
        , 'Greenberg'
        , 'NGREENBE'
        , '515.124.4569'
        , str_to_date('17-AUG-1994', '%d-%b-%Y')
        , 'FI_MGR'
        , 12000
        , NULL
        , 101
        , 100
        );

INSERT INTO employees VALUES 
        ( null
        , 'Daniel'
        , 'Faviet'
        , 'DFAVIET'
        , '515.124.4169'
        , str_to_date('16-AUG-1994', '%d-%b-%Y')
        , 'FI_ACCOUNT'
        , 9000
        , NULL
        , 108
        , 100
        );

INSERT INTO employees VALUES 
        ( null
        , 'John'
        , 'Chen'
        , 'JCHEN'
        , '515.124.4269'
        , str_to_date('28-SEP-1997', '%d-%b-%Y')
        , 'FI_ACCOUNT'
        , 8200
        , NULL
        , 108
        , 100
        );

INSERT INTO employees VALUES 
        ( null
        , 'Ismael'
        , 'Sciarra'
        , 'ISCIARRA'
        , '515.124.4369'
        , str_to_date('30-SEP-1997', '%d-%b-%Y')
        , 'FI_ACCOUNT'
        , 7700
        , NULL
        , 108
        , 100
        );

INSERT INTO employees VALUES 
        ( null
        , 'Jose Manuel'
        , 'Urman'
        , 'JMURMAN'
        , '515.124.4469'
        , str_to_date('07-MAR-1998', '%d-%b-%Y')
        , 'FI_ACCOUNT'
        , 7800
        , NULL
        , 108
        , 100
        );

INSERT INTO employees VALUES 
        ( null
        , 'Luis'
        , 'Popp'
        , 'LPOPP'
        , '515.124.4567'
        , str_to_date('07-DEC-1999', '%d-%b-%Y')
        , 'FI_ACCOUNT'
        , 6900
        , NULL
        , 108
        , 100
        );

INSERT INTO employees VALUES 
        ( null
        , 'Den'
        , 'Raphaely'
        , 'DRAPHEAL'
        , '515.127.4561'
        , str_to_date('07-DEC-1994', '%d-%b-%Y')
        , 'PU_MAN'
        , 11000
        , NULL
        , 100
        , 30
        );

INSERT INTO employees VALUES 
        ( null
        , 'Alexander'
        , 'Khoo'
        , 'AKHOO'
        , '515.127.4562'
        , str_to_date('18-MAY-1995', '%d-%b-%Y')
        , 'PU_CLERK'
        , 3100
        , NULL
        , 114
        , 30
        );

INSERT INTO employees VALUES 
        ( null
        , 'Shelli'
        , 'Baida'
        , 'SBAIDA'
        , '515.127.4563'
        , str_to_date('24-DEC-1997', '%d-%b-%Y')
        , 'PU_CLERK'
        , 2900
        , NULL
        , 114
        , 30
        );

INSERT INTO employees VALUES 
        ( null
        , 'Sigal'
        , 'Tobias'
        , 'STOBIAS'
        , '515.127.4564'
        , str_to_date('24-JUL-1997', '%d-%b-%Y')
        , 'PU_CLERK'
        , 2800
        , NULL
        , 114
        , 30
        );

INSERT INTO employees VALUES 
        ( null
        , 'Guy'
        , 'Himuro'
        , 'GHIMURO'
        , '515.127.4565'
        , str_to_date('15-NOV-1998', '%d-%b-%Y')
        , 'PU_CLERK'
        , 2600
        , NULL
        , 114
        , 30
        );

INSERT INTO employees VALUES 
        ( null
        , 'Karen'
        , 'Colmenares'
        , 'KCOLMENA'
        , '515.127.4566'
        , str_to_date('10-AUG-1999', '%d-%b-%Y')
        , 'PU_CLERK'
        , 2500
        , NULL
        , 114
        , 30
        );

INSERT INTO employees VALUES 
        ( null
        , 'Matthew'
        , 'Weiss'
        , 'MWEISS'
        , '650.123.1234'
        , str_to_date('18-JUL-1996', '%d-%b-%Y')
        , 'ST_MAN'
        , 8000
        , NULL
        , 100
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Adam'
        , 'Fripp'
        , 'AFRIPP'
        , '650.123.2234'
        , str_to_date('10-APR-1997', '%d-%b-%Y')
        , 'ST_MAN'
        , 8200
        , NULL
        , 100
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Payam'
        , 'Kaufling'
        , 'PKAUFLIN'
        , '650.123.3234'
        , str_to_date('01-MAY-1995', '%d-%b-%Y')
        , 'ST_MAN'
        , 7900
        , NULL
        , 100
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Shanta'
        , 'Vollman'
        , 'SVOLLMAN'
        , '650.123.4234'
        , str_to_date('10-OCT-1997', '%d-%b-%Y')
        , 'ST_MAN'
        , 6500
        , NULL
        , 100
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Kevin'
        , 'Mourgos'
        , 'KMOURGOS'
        , '650.123.5234'
        , str_to_date('16-NOV-1999', '%d-%b-%Y')
        , 'ST_MAN'
        , 5800
        , NULL
        , 100
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Julia'
        , 'Nayer'
        , 'JNAYER'
        , '650.124.1214'
        , str_to_date('16-JUL-1997', '%d-%b-%Y')
        , 'ST_CLERK'
        , 3200
        , NULL
        , 120
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Irene'
        , 'Mikkilineni'
        , 'IMIKKILI'
        , '650.124.1224'
        , str_to_date('28-SEP-1998', '%d-%b-%Y')
        , 'ST_CLERK'
        , 2700
        , NULL
        , 120
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'James'
        , 'Landry'
        , 'JLANDRY'
        , '650.124.1334'
        , str_to_date('14-JAN-1999', '%d-%b-%Y')
        , 'ST_CLERK'
        , 2400
        , NULL
        , 120
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Steven'
        , 'Markle'
        , 'SMARKLE'
        , '650.124.1434'
        , str_to_date('08-MAR-2000', '%d-%b-%Y')
        , 'ST_CLERK'
        , 2200
        , NULL
        , 120
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Laura'
        , 'Bissot'
        , 'LBISSOT'
        , '650.124.5234'
        , str_to_date('20-AUG-1997', '%d-%b-%Y')
        , 'ST_CLERK'
        , 3300
        , NULL
        , 121
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Mozhe'
        , 'Atkinson'
        , 'MATKINSO'
        , '650.124.6234'
        , str_to_date('30-OCT-1997', '%d-%b-%Y')
        , 'ST_CLERK'
        , 2800
        , NULL
        , 121
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'James'
        , 'Marlow'
        , 'JAMRLOW'
        , '650.124.7234'
        , str_to_date('16-FEB-1997', '%d-%b-%Y')
        , 'ST_CLERK'
        , 2500
        , NULL
        , 121
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'TJ'
        , 'Olson'
        , 'TJOLSON'
        , '650.124.8234'
        , str_to_date('10-APR-1999', '%d-%b-%Y')
        , 'ST_CLERK'
        , 2100
        , NULL
        , 121
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Jason'
        , 'Mallin'
        , 'JMALLIN'
        , '650.127.1934'
        , str_to_date('14-JUN-1996', '%d-%b-%Y')
        , 'ST_CLERK'
        , 3300
        , NULL
        , 122
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Michael'
        , 'Rogers'
        , 'MROGERS'
        , '650.127.1834'
        , str_to_date('26-AUG-1998', '%d-%b-%Y')
        , 'ST_CLERK'
        , 2900
        , NULL
        , 122
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Ki'
        , 'Gee'
        , 'KGEE'
        , '650.127.1734'
        , str_to_date('12-DEC-1999', '%d-%b-%Y')
        , 'ST_CLERK'
        , 2400
        , NULL
        , 122
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Hazel'
        , 'Philtanker'
        , 'HPHILTAN'
        , '650.127.1634'
        , str_to_date('06-FEB-2000', '%d-%b-%Y')
        , 'ST_CLERK'
        , 2200
        , NULL
        , 122
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Renske'
        , 'Ladwig'
        , 'RLADWIG'
        , '650.121.1234'
        , str_to_date('14-JUL-1995', '%d-%b-%Y')
        , 'ST_CLERK'
        , 3600
        , NULL
        , 123
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Stephen'
        , 'Stiles'
        , 'SSTILES'
        , '650.121.2034'
        , str_to_date('26-OCT-1997', '%d-%b-%Y')
        , 'ST_CLERK'
        , 3200
        , NULL
        , 123
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'John'
        , 'Seo'
        , 'JSEO'
        , '650.121.2019'
        , str_to_date('12-FEB-1998', '%d-%b-%Y')
        , 'ST_CLERK'
        , 2700
        , NULL
        , 123
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Joshua'
        , 'Patel'
        , 'JPATEL'
        , '650.121.1834'
        , str_to_date('06-APR-1998', '%d-%b-%Y')
        , 'ST_CLERK'
        , 2500
        , NULL
        , 123
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Trenna'
        , 'Rajs'
        , 'TRAJS'
        , '650.121.8009'
        , str_to_date('17-OCT-1995', '%d-%b-%Y')
        , 'ST_CLERK'
        , 3500
        , NULL
        , 124
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Curtis'
        , 'Davies'
        , 'CDAVIES'
        , '650.121.2994'
        , str_to_date('29-JAN-1997', '%d-%b-%Y')
        , 'ST_CLERK'
        , 3100
        , NULL
        , 124
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Randall'
        , 'Matos'
        , 'RMATOS'
        , '650.121.2874'
        , str_to_date('15-MAR-1998', '%d-%b-%Y')
        , 'ST_CLERK'
        , 2600
        , NULL
        , 124
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Peter'
        , 'Vargas'
        , 'PVARGAS'
        , '650.121.2004'
        , str_to_date('09-JUL-1998', '%d-%b-%Y')
        , 'ST_CLERK'
        , 2500
        , NULL
        , 124
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'John'
        , 'Russell'
        , 'JRUSSEL'
        , '011.44.1344.429268'
        , str_to_date('01-OCT-1996', '%d-%b-%Y')
        , 'SA_MAN'
        , 14000
        , .4
        , 100
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Karen'
        , 'Partners'
        , 'KPARTNER'
        , '011.44.1344.467268'
        , str_to_date('05-JAN-1997', '%d-%b-%Y')
        , 'SA_MAN'
        , 13500
        , .3
        , 100
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Alberto'
        , 'Errazuriz'
        , 'AERRAZUR'
        , '011.44.1344.429278'
        , str_to_date('10-MAR-1997', '%d-%b-%Y')
        , 'SA_MAN'
        , 12000
        , .3
        , 100
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Gerald'
        , 'Cambrault'
        , 'GCAMBRAU'
        , '011.44.1344.619268'
        , str_to_date('15-OCT-1999', '%d-%b-%Y')
        , 'SA_MAN'
        , 11000
        , .3
        , 100
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Eleni'
        , 'Zlotkey'
        , 'EZLOTKEY'
        , '011.44.1344.429018'
        , str_to_date('29-JAN-2000', '%d-%b-%Y')
        , 'SA_MAN'
        , 10500
        , .2
        , 100
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Peter'
        , 'Tucker'
        , 'PTUCKER'
        , '011.44.1344.129268'
        , str_to_date('30-JAN-1997', '%d-%b-%Y')
        , 'SA_REP'
        , 10000
        , .3
        , 145
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'David'
        , 'Bernstein'
        , 'DBERNSTE'
        , '011.44.1344.345268'
        , str_to_date('24-MAR-1997', '%d-%b-%Y')
        , 'SA_REP'
        , 9500
        , .25
        , 145
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Peter'
        , 'Hall'
        , 'PHALL'
        , '011.44.1344.478968'
        , str_to_date('20-AUG-1997', '%d-%b-%Y')
        , 'SA_REP'
        , 9000
        , .25
        , 145
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Christopher'
        , 'Olsen'
        , 'COLSEN'
        , '011.44.1344.498718'
        , str_to_date('30-MAR-1998', '%d-%b-%Y')
        , 'SA_REP'
        , 8000
        , .2
        , 145
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Nanette'
        , 'Cambrault'
        , 'NCAMBRAU'
        , '011.44.1344.987668'
        , str_to_date('09-DEC-1998', '%d-%b-%Y')
        , 'SA_REP'
        , 7500
        , .2
        , 145
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Oliver'
        , 'Tuvault'
        , 'OTUVAULT'
        , '011.44.1344.486508'
        , str_to_date('23-NOV-1999', '%d-%b-%Y')
        , 'SA_REP'
        , 7000
        , .15
        , 145
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Janette'
        , 'King'
        , 'JKING'
        , '011.44.1345.429268'
        , str_to_date('30-JAN-1996', '%d-%b-%Y')
        , 'SA_REP'
        , 10000
        , .35
        , 146
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Patrick'
        , 'Sully'
        , 'PSULLY'
        , '011.44.1345.929268'
        , str_to_date('04-MAR-1996', '%d-%b-%Y')
        , 'SA_REP'
        , 9500
        , .35
        , 146
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Allan'
        , 'McEwen'
        , 'AMCEWEN'
        , '011.44.1345.829268'
        , str_to_date('01-AUG-1996', '%d-%b-%Y')
        , 'SA_REP'
        , 9000
        , .35
        , 146
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Lindsey'
        , 'Smith'
        , 'LSMITH'
        , '011.44.1345.729268'
        , str_to_date('10-MAR-1997', '%d-%b-%Y')
        , 'SA_REP'
        , 8000
        , .3
        , 146
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Louise'
        , 'Doran'
        , 'LDORAN'
        , '011.44.1345.629268'
        , str_to_date('15-DEC-1997', '%d-%b-%Y')
        , 'SA_REP'
        , 7500
        , .3
        , 146
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Sarath'
        , 'Sewall'
        , 'SSEWALL'
        , '011.44.1345.529268'
        , str_to_date('03-NOV-1998', '%d-%b-%Y')
        , 'SA_REP'
        , 7000
        , .25
        , 146
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Clara'
        , 'Vishney'
        , 'CVISHNEY'
        , '011.44.1346.129268'
        , str_to_date('11-NOV-1997', '%d-%b-%Y')
        , 'SA_REP'
        , 10500
        , .25
        , 147
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Danielle'
        , 'Greene'
        , 'DGREENE'
        , '011.44.1346.229268'
        , str_to_date('19-MAR-1999', '%d-%b-%Y')
        , 'SA_REP'
        , 9500
        , .15
        , 147
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Mattea'
        , 'Marvins'
        , 'MMARVINS'
        , '011.44.1346.329268'
        , str_to_date('24-JAN-2000', '%d-%b-%Y')
        , 'SA_REP'
        , 7200
        , .10
        , 147
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'David'
        , 'Lee'
        , 'DLEE'
        , '011.44.1346.529268'
        , str_to_date('23-FEB-2000', '%d-%b-%Y')
        , 'SA_REP'
        , 6800
        , .1
        , 147
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Sundar'
        , 'Ande'
        , 'SANDE'
        , '011.44.1346.629268'
        , str_to_date('24-MAR-2000', '%d-%b-%Y')
        , 'SA_REP'
        , 6400
        , .10
        , 147
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Amit'
        , 'Banda'
        , 'ABANDA'
        , '011.44.1346.729268'
        , str_to_date('21-APR-2000', '%d-%b-%Y')
        , 'SA_REP'
        , 6200
        , .10
        , 147
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Lisa'
        , 'Ozer'
        , 'LOZER'
        , '011.44.1343.929268'
        , str_to_date('11-MAR-1997', '%d-%b-%Y')
        , 'SA_REP'
        , 11500
        , .25
        , 148
        , 80
        );

INSERT INTO employees VALUES 
        ( null  
        , 'Harrison'
        , 'Bloom'
        , 'HBLOOM'
        , '011.44.1343.829268'
        , str_to_date('23-MAR-1998', '%d-%b-%Y')
        , 'SA_REP'
        , 10000
        , .20
        , 148
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Tayler'
        , 'Fox'
        , 'TFOX'
        , '011.44.1343.729268'
        , str_to_date('24-JAN-1998', '%d-%b-%Y')
        , 'SA_REP'
        , 9600
        , .20
        , 148
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'William'
        , 'Smith'
        , 'WSMITH'
        , '011.44.1343.629268'
        , str_to_date('23-FEB-1999', '%d-%b-%Y')
        , 'SA_REP'
        , 7400
        , .15
        , 148
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Elizabeth'
        , 'Bates'
        , 'EBATES'
        , '011.44.1343.529268'
        , str_to_date('24-MAR-1999', '%d-%b-%Y')
        , 'SA_REP'
        , 7300
        , .15
        , 148
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Sundita'
        , 'Kumar'
        , 'SKUMAR'
        , '011.44.1343.329268'
        , str_to_date('21-APR-2000', '%d-%b-%Y')
        , 'SA_REP'
        , 6100
        , .10
        , 148
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Ellen'
        , 'Abel'
        , 'EABEL'
        , '011.44.1644.429267'
        , str_to_date('11-MAY-1996', '%d-%b-%Y')
        , 'SA_REP'
        , 11000
        , .30
        , 149
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Alyssa'
        , 'Hutton'
        , 'AHUTTON'
        , '011.44.1644.429266'
        , str_to_date('19-MAR-1997', '%d-%b-%Y')
        , 'SA_REP'
        , 8800
        , .25
        , 149
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Jonathon'
        , 'Taylor'
        , 'JTAYLOR'
        , '011.44.1644.429265'
        , str_to_date('24-MAR-1998', '%d-%b-%Y')
        , 'SA_REP'
        , 8600
        , .20
        , 149
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Jack'
        , 'Livingston'
        , 'JLIVINGS'
        , '011.44.1644.429264'
        , str_to_date('23-APR-1998', '%d-%b-%Y')
        , 'SA_REP'
        , 8400
        , .20
        , 149
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Kimberely'
        , 'Grant'
        , 'KGRANT'
        , '011.44.1644.429263'
        , str_to_date('24-MAY-1999', '%d-%b-%Y')
        , 'SA_REP'
        , 7000
        , .15
        , 149
        , NULL
        );

INSERT INTO employees VALUES 
        ( null
        , 'Charles'
        , 'Johnson'
        , 'CJOHNSON'
        , '011.44.1644.429262'
        , str_to_date('04-JAN-2000', '%d-%b-%Y')
        , 'SA_REP'
        , 6200
        , .10
        , 149
        , 80
        );

INSERT INTO employees VALUES 
        ( null
        , 'Winston'
        , 'Taylor'
        , 'WTAYLOR'
        , '650.507.9876'
        , str_to_date('24-JAN-1998', '%d-%b-%Y')
        , 'SH_CLERK'
        , 3200
        , NULL
        , 120
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Jean'
        , 'Fleaur'
        , 'JFLEAUR'
        , '650.507.9877'
        , str_to_date('23-FEB-1998', '%d-%b-%Y')
        , 'SH_CLERK'
        , 3100
        , NULL
        , 120
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Martha'
        , 'Sullivan'
        , 'MSULLIVA'
        , '650.507.9878'
        , str_to_date('21-JUN-1999', '%d-%b-%Y')
        , 'SH_CLERK'
        , 2500
        , NULL
        , 120
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Girard'
        , 'Geoni'
        , 'GGEONI'
        , '650.507.9879'
        , str_to_date('03-FEB-2000', '%d-%b-%Y')
        , 'SH_CLERK'
        , 2800
        , NULL
        , 120
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Nandita'
        , 'Sarchand'
        , 'NSARCHAN'
        , '650.509.1876'
        , str_to_date('27-JAN-1996', '%d-%b-%Y')
        , 'SH_CLERK'
        , 4200
        , NULL
        , 121
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Alexis'
        , 'Bull'
        , 'ABULL'
        , '650.509.2876'
        , str_to_date('20-FEB-1997', '%d-%b-%Y')
        , 'SH_CLERK'
        , 4100
        , NULL
        , 121
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Julia'
        , 'Dellinger'
        , 'JDELLING'
        , '650.509.3876'
        , str_to_date('24-JUN-1998', '%d-%b-%Y')
        , 'SH_CLERK'
        , 3400
        , NULL
        , 121
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Anthony'
        , 'Cabrio'
        , 'ACABRIO'
        , '650.509.4876'
        , str_to_date('07-FEB-1999', '%d-%b-%Y')
        , 'SH_CLERK'
        , 3000
        , NULL
        , 121
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Kelly'
        , 'Chung'
        , 'KCHUNG'
        , '650.505.1876'
        , str_to_date('14-JUN-1997', '%d-%b-%Y')
        , 'SH_CLERK'
        , 3800
        , NULL
        , 122
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Jennifer'
        , 'Dilly'
        , 'JDILLY'
        , '650.505.2876'
        , str_to_date('13-AUG-1997', '%d-%b-%Y')
        , 'SH_CLERK'
        , 3600
        , NULL
        , 122
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Timothy'
        , 'Gates'
        , 'TGATES'
        , '650.505.3876'
        , str_to_date('11-JUL-1998', '%d-%b-%Y')
        , 'SH_CLERK'
        , 2900
        , NULL
        , 122
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Randall'
        , 'Perkins'
        , 'RPERKINS'
        , '650.505.4876'
        , str_to_date('19-DEC-1999', '%d-%b-%Y')
        , 'SH_CLERK'
        , 2500
        , NULL
        , 122
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Sarah'
        , 'Bell'
        , 'SBELL'
        , '650.501.1876'
        , str_to_date('04-FEB-1996', '%d-%b-%Y')
        , 'SH_CLERK'
        , 4000
        , NULL
        , 123
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Britney'
        , 'Everett'
        , 'BEVERETT'
        , '650.501.2876'
        , str_to_date('03-MAR-1997', '%d-%b-%Y')
        , 'SH_CLERK'
        , 3900
        , NULL
        , 123
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Samuel'
        , 'McCain'
        , 'SMCCAIN'
        , '650.501.3876'
        , str_to_date('01-JUL-1998', '%d-%b-%Y')
        , 'SH_CLERK'
        , 3200
        , NULL
        , 123
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Vance'
        , 'Jones'
        , 'VJONES'
        , '650.501.4876'
        , str_to_date('17-MAR-1999', '%d-%b-%Y')
        , 'SH_CLERK'
        , 2800
        , NULL
        , 123
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Alana'
        , 'Walsh'
        , 'AWALSH'
        , '650.507.9811'
        , str_to_date('24-APR-1998', '%d-%b-%Y')
        , 'SH_CLERK'
        , 3100
        , NULL
        , 124
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Kevin'
        , 'Feeney'
        , 'KFEENEY'
        , '650.507.9822'
        , str_to_date('23-MAY-1998', '%d-%b-%Y')
        , 'SH_CLERK'
        , 3000
        , NULL
        , 124
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Donald'
        , 'OConnell'
        , 'DOCONNEL'
        , '650.507.9833'
        , str_to_date('21-JUN-1999', '%d-%b-%Y')
        , 'SH_CLERK'
        , 2600
        , NULL
        , 124
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Douglas'
        , 'Grant'
        , 'DGRANT'
        , '650.507.9844'
        , str_to_date('13-JAN-2000', '%d-%b-%Y')
        , 'SH_CLERK'
        , 2600
        , NULL
        , 124
        , 50
        );

INSERT INTO employees VALUES 
        ( null
        , 'Jennifer'
        , 'Whalen'
        , 'JWHALEN'
        , '515.123.4444'
        , str_to_date('17-SEP-1987', '%d-%b-%Y')
        , 'AD_ASST'
        , 4400
        , NULL
        , 101
        , 10
        );

INSERT INTO employees VALUES 
        ( null
        , 'Michael'
        , 'Hartstein'
        , 'MHARTSTE'
        , '515.123.5555'
        , str_to_date('17-FEB-1996', '%d-%b-%Y')
        , 'MK_MAN'
        , 13000
        , NULL
        , 100
        , 20
        );

INSERT INTO employees VALUES 
        ( null
        , 'Pat'
        , 'Fay'
        , 'PFAY'
        , '603.123.6666'
        , str_to_date('17-AUG-1997', '%d-%b-%Y')
        , 'MK_REP'
        , 6000
        , NULL
        , 201
        , 20
        );

INSERT INTO employees VALUES 
        ( null
        , 'Susan'
        , 'Mavris'
        , 'SMAVRIS'
        , '515.123.7777'
        , str_to_date('07-JUN-1994', '%d-%b-%Y')
        , 'HR_REP'
        , 6500
        , NULL
        , 101
        , 40
        );

INSERT INTO employees VALUES 
        ( null
        , 'Hermann'
        , 'Baer'
        , 'HBAER'
        , '515.123.8888'
        , str_to_date('07-JUN-1994', '%d-%b-%Y')
        , 'PR_REP'
        , 10000
        , NULL
        , 101
        , 70
        );

INSERT INTO employees VALUES 
        ( null
        , 'Shelley'
        , 'Higgins'
        , 'SHIGGINS'
        , '515.123.8080'
        , str_to_date('07-JUN-1994', '%d-%b-%Y')
        , 'AC_MGR'
        , 12000
        , NULL
        , 101
        , 110
        );

INSERT INTO employees VALUES 
        ( null
        , 'William'
        , 'Gietz'
        , 'WGIETZ'
        , '515.123.8181'
        , str_to_date('07-JUN-1994', '%d-%b-%Y')
        , 'AC_ACCOUNT'
        , 8300
        , NULL
        , 205
        , 110
        );
        
        


-- REM ********* insert data into the JOB_HISTORY table

-- Prompt ******  Populating JOB_HISTORY table ....


INSERT INTO job_history
VALUES (102
       , str_to_date('13-JAN-1993', '%d-%b-%Y')
       , str_to_date('24-JUL-1998', '%d-%b-%Y')
       , 'IT_PROG'
       , 60);

INSERT INTO job_history
VALUES (101
       , str_to_date('21-SEP-1989', '%d-%b-%Y')
       , str_to_date('27-OCT-1993', '%d-%b-%Y')
       , 'AC_ACCOUNT'
       , 110);

INSERT INTO job_history
VALUES (101
       , str_to_date('28-OCT-1993', '%d-%b-%Y')
       , str_to_date('15-MAR-1997', '%d-%b-%Y')
       , 'AC_MGR'
       , 110);

INSERT INTO job_history
VALUES (201
       , str_to_date('17-FEB-1996', '%d-%b-%Y')
       , str_to_date('19-DEC-1999', '%d-%b-%Y')
       , 'MK_REP'
       , 20);

INSERT INTO job_history
VALUES  (114
        , str_to_date('24-MAR-1998', '%d-%b-%Y')
        , str_to_date('31-DEC-1999', '%d-%b-%Y')
        , 'ST_CLERK'
        , 50
        );

INSERT INTO job_history
VALUES  (122
        , str_to_date('01-JAN-1999', '%d-%b-%Y')
        , str_to_date('31-DEC-1999', '%d-%b-%Y')
        , 'ST_CLERK'
        , 50
        );

INSERT INTO job_history
VALUES  (200
        , str_to_date('17-SEP-1987', '%d-%b-%Y')
        , str_to_date('17-JUN-1993', '%d-%b-%Y')
        , 'AD_ASST'
        , 90
        );

INSERT INTO job_history
VALUES  (176
        , str_to_date('24-MAR-1998', '%d-%b-%Y')
        , str_to_date('31-DEC-1998', '%d-%b-%Y')
        , 'SA_REP'
        , 80
        );

INSERT INTO job_history
VALUES  (176
        , str_to_date('01-JAN-1999', '%d-%b-%Y')
        , str_to_date('31-DEC-1999', '%d-%b-%Y')
        , 'SA_MAN'
        , 80
        );

INSERT INTO job_history
VALUES  (200
        , str_to_date('01-JUL-1994', '%d-%b-%Y')
        , str_to_date('31-DEC-1998', '%d-%b-%Y')
        , 'AC_ACCOUNT'
        , 90
        );

-- REM enable integrity constraint to DEPARTMENTS

-- ALTER TABLE departments 
--   ENABLE CONSTRAINT dept_mgr_fk;

SET foreign_key_checks = 1;

COMMIT;




CREATE INDEX emp_department_ix
       ON employees (department_id);

CREATE INDEX emp_job_ix
       ON employees (job_id);

CREATE INDEX emp_manager_ix
       ON employees (manager_id);

CREATE INDEX emp_name_ix
       ON employees (last_name, first_name);

CREATE INDEX dept_location_ix
       ON departments (location_id);

CREATE INDEX jhist_job_ix
       ON job_history (job_id);

CREATE INDEX jhist_employee_ix
       ON job_history (employee_id);

CREATE INDEX jhist_department_ix
       ON job_history (department_id);

CREATE INDEX loc_city_ix
       ON locations (city);

CREATE INDEX loc_state_province_ix	
       ON locations (state_province);

CREATE INDEX loc_country_ix
       ON locations (country_id);

COMMIT;

-- REM procedure and statement trigger to allow dmls during business hours:

-- UPDATE employees SET job_id='AC_MGR' WHERE employee_id = 206;


DELIMITER ||

DROP PROCEDURE IF EXISTS secure_dml|| 
CREATE PROCEDURE secure_dml()
BEGIN
  IF date_format (SYSDATE(), '%H:%i')
  NOT BETWEEN '08:00' AND '18:00'
  OR date_format (SYSDATE(), '%a') IN ('SAT', 'SUN') THEN
    SIGNAL SQLSTATE 'HY000'
    SET MESSAGE_TEXT = 'You may only make changes during normal office hours';  
  END IF;
END
||

DROP TRIGGER IF EXISTS secure_employees1|| 
CREATE TRIGGER secure_employees1
  BEFORE INSERT ON employees for each row
BEGIN
  call secure_dml();
END
||

DROP TRIGGER IF EXISTS secure_employees2|| 
CREATE TRIGGER secure_employees2
  BEFORE UPDATE ON employees for each row
BEGIN
  call secure_dml();
END
||

DROP TRIGGER IF EXISTS secure_employees3|| 
CREATE TRIGGER secure_employees3
  BEFORE DELETE ON employees for each row
BEGIN
  call secure_dml();
END
||

-- REM **************************************************************************
-- REM procedure to add a row to the JOB_HISTORY table and row trigger 
-- REM to call the procedure when data is updated in the job_id or 
-- REM department_id columns in the EMPLOYEES table:

DROP PROCEDURE IF EXISTS add_job_history|| 
CREATE PROCEDURE add_job_history
  (  IN p_emp_id          INT(6)
   , IN p_start_date      DATE
   , IN p_end_date        DATE
   , IN p_job_id          VARCHAR(10)
   , IN p_department_id   INT(4)
   )
BEGIN
  INSERT INTO job_history (employee_id, start_date, end_date, 
                           job_id, department_id)
    VALUES(p_emp_id, p_start_date, p_end_date, p_job_id, p_department_id);
END
||


DROP TRIGGER IF EXISTS update_job_history|| 
CREATE TRIGGER update_job_history
  AFTER UPDATE ON employees
  FOR EACH ROW
BEGIN
  IF OLD.job_id <> NEW.job_id OR OLD.department_id <> NEW.department_id THEN
    CALL add_job_history(new.employee_id, new.hire_date, sysdate(), 
                  new.job_id, new.department_id);
  END IF;  
END
||

DELIMITER ;

COMMIT;


-- spool off;
