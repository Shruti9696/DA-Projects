create database hr_project;
use hr_project;
select * from hr_data_sql;
show tables;

-- Data Cleaning --

rename table hr_data_sql to hr;
select * from hr;
describe hr;

-- birthdate column --

alter table hr change column ï»¿id emp_id varchar(20) null;

set sql_safe_updates = 0;

update hr set birthdate = case
	when birthdate like '%/%' then	date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
    when birthdate like '%-%' then	date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
    else null
end;

alter table hr modify column birthdate date;

-- Hire_date column --

desc hr;
select * from hr;
desc hr;

update hr set hire_date = case 
	when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
    when hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
    else null
end;

-- termdate column --

update hr set termdate =  date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
	where termdate <> null and termdate !=' ';
    
update hr set termdate = null where termdate = '';

-- Age group column --

alter table hr add column age int;
update hr set age = timestampdiff(year,birthdate,curdate());
select min(age) as min, max(age)as max from hr;

	-- Gender breakdown --
select gender, count(*) as gender_count from hr 
	where termdate is null  group by gender;
    
	-- Race Breakdown --
select race, count(*) as race_count from hr 
	where termdate is null group by race;
    
	-- Age Distribution --
select case 
	when age>=18 and age<=24 then '18-24'
    when age>=25 and age<=34 then '25-34'
    when age>=35 and age<=44 then '35-44'
    when age>=45 and age<=54 then '45-54'
    when age>=55 and age<=64 then '55-64'
    else '65+'
    end as age_group, count(*) as age_group_count from hr 
    where termdate is null group by age_group order by age_group;
    
    
-- how many emp work at HQ and Remote

select * from hr;
select location, count(*) as count_location from hr
	where termdate is null group by location;
    
-- Average length/ period of employment of emp --

select  round(avg(year(termdate)-year(hire_date)),0) as emp_length from hr 
	where termdate is not null and termdate <= curdate();

--  gender distribution according to department --

select department, gender, count(*) as count from hr 
	where termdate is not null group by department, gender order by department,gender;
    
select department, jobtitle, gender, count(*) as count from hr 
	where termdate is not null group by department, jobtitle, gender order by department, jobtitle, gender;
    
-- distribution of jobtitle across company, jottitle wise count --

select jobtitle, count(*) as count from hr 
	where termdate is null group by jobtitle;
    
-- highest termination rate --

select department, count(*),
	count(case when termdate is not null and termdate <= curdate() then 1
    end) as Terminate_count,
    round((count(case when termdate is not null and termdate <= curdate() then 1
    end)/count(*))*100,2) as Termination_rate
from hr
group by department
order by Terminate_count;

-- distribution of emp across location_state

select * from hr;
select location, count(*) from hr 
	where termdate is not null and termdate <= curdate() and location = 'Remote' group by location;
    
select location, count(*) from hr 
	where termdate is not null and termdate <= curdate() and location = 'Headquarters' group by location;
    


select location_city, count(*) from hr 
	where termdate is null group by location_city;
    
-- emp count chang --

select year, hire, termination, hire - termination as net_change, round((termination/hire)*100,2)as change_percent
from(
		select year(hire_date) as year, count(*) as hire,
        sum(case when termdate is not null and termdate <= curdate() then 1
        end) as termination 
        from hr
        
        group by year(hire_date)) as subquery
group by year
order by year;

-- Tenure distribution --

select department, round(avg(year(termdate)-year(hire_date)),0) as tenure from hr
	where termdate is not null and termdate <= curdate()
    group by department;
 
								 -- OR --
select department, round(avg(datediff(termdate, hire_date)/365),0)as tenure from hr
	where termdate is not null and termdate <= curdate()
    group by department;
    
-- Gender Wise termination --

select gender, total_hire, total_termination
from(
	select gender, count(*) as total_hire,
    count(case when termdate is not null and termdate <= curdate() then 1
          end) as total_termination
	from hr
    group by gender) as sub_query
group by gender;

-- Age Wise termination --

select age, total_hire, total_termination
from(
	select age, count(*) as total_hire,
    count(case when termdate is not null and termdate <= curdate() then 1
    end)as total_termination
    from hr
    group by age) as Sub_query
group by age;

select age, count(*) as total_hire,
    count(case when termdate is not null and termdate <= curdate() then 1
    end)as total_termination
    from hr
    group by age;

-- Overall Employee Count --

select count(emp_id) as Overall_emp from hr;

-- Active Employee Count --

select count(case when termdate is null then 1 
			end)as active_emp from hr;
            
-- Terminated Employee Count --

select count(case when termdate is not null and  termdate <= curdate() then 1
			end) as terminated_emp from hr;
            
-- Average age of emp --

select round(avg(age),0) as avg_age from hr;

select count(case when termdate is not null and  termdate <= curdate() then 1
			end) as terminated_emp;
            

 -- Termination rate --
select count(emp_id) as total_emp,
	sum(case when termdate is not null  and termdate <= curdate() then 1 
    end )as terminated_emp, concat(round(100* sum(case when termdate is not null  and termdate <= curdate() then 1
    end) / count(emp_id),0),'%') as Termination_rate
from hr;


	-- Location wise termination --
SELECT
    CASE WHEN location = 'Headquarters' THEN 'Headquarters'
         WHEN location = 'Remote' THEN 'Remote'
    END AS location,
    COUNT(*) AS terminated_count
FROM hr
WHERE termdate is not null and termdate <= curdate()
GROUP BY location;
 
									-- OR --
                                    
select location, count(*) as tr_cnt from hr
	where termdate is not null and termdate <= curdate()
    group by location;
    
    -- Age wise terination --
    select case 
	when age>=18 and age<=24 then '18-24'
    when age>=25 and age<=34 then '25-34'
    when age>=35 and age<=44 then '35-44'
    when age>=45 and age<=54 then '45-54'
    when age>=55 and age<=64 then '55-64'
    else '65+'
    end as age_group, count(*) as terminated_emp from hr 
    where termdate is not null and termdate <= curdate() group by age_group order by age_group;