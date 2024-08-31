create database project1;
use project1;

create table circuit 
(circuitid int primary key ,name varchar(100),
location varchar(100),country varchar(100));
show variables like "secure_file_priv";
load data infile 
"C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\circuits.csv"
into table circuit
columns terminated by ','
optionally enclosed by '"'
escaped by '"'
lines terminated
 by  '\r\n'
ignore 1 lines;
select * from circuit;

create table race 
(raceid int primary key,round int ,circuitid int 
,name varchar(100),rdate date,rtime time,
foreign key(circuitid) references circuit(circuitid));
load data infile 
"C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\races.csv"
into table race
columns terminated by ','
optionally enclosed by '"'
escaped by '"'
lines terminated by  '\r\n'
ignore 1 lines;
select * from race;

create table status 
(statusid int primary key,status varchar(100));
load data infile 
"C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\status (1).csv"
into table status
columns terminated by ','
optionally enclosed by '"'
escaped by '"'
lines terminated by  '\r\n'
ignore 1 lines;
select * from status;

create table driver
(driverid int primary key,forename varchar(100),
surname varchar(100),dob date,nationality varchar(100));
load data infile 
"C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\drivers.csv"
into table driver
columns terminated by ','
optionally enclosed by '"'
escaped by '"'
lines terminated by  '\r\n'
ignore 1 lines;
select * from driver;

create table driverstanding 
(raceid int ,driverid int ,points int ,position int,
wins int,foreign key(raceid) references race(raceid),
foreign key(driverid) references driver(driverid));
load data infile 
"C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\driver_standings.csv"
into table driverstanding
columns terminated by ','
optionally enclosed by '"'
escaped by '"'
lines terminated by  '\r\n'
ignore 1 lines;
select * from driverstanding ;

create table constructor
(constructorid int primary key,name varchar(100),
nationality varchar(100));
load data infile 
"C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\constructors.csv"
into table constructor
columns terminated by ','
optionally enclosed by '"'
escaped by '"'
lines terminated by  '\r\n'
ignore 1 lines;
select * from constructor;

create table constructorresult
(raceid int ,constructorid int,points int ,status varchar(2));
alter table constructorresult 
add foreign key(raceid) references race(raceid);
alter table constructorresult 
add foreign key(constructorid) references constructor(constructorid);
load data infile 
"C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\constructor_results.csv"
into table constructorresult
columns terminated by ','
optionally enclosed by '"'
escaped by '"'
lines terminated by  '\r\n'
ignore 1 lines;
select  * from constructorresult;

create table laptime
(raceid int ,driverid int ,laP int, position int ,
ltime time ,milisec int,foreign key(raceid) 
references race(raceid),foreign key(driverid) 
references driver(driverid));
load data infile 
"C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\laptime.csv"
into table laptime
columns terminated by ','
optionally enclosed by '"'
escaped by '"'
lines terminated by  '\r\n'
ignore 1 lines;

create table result
(resultid int primary key,raceid int,driverid int,
constructorid int,grid int,lap int,milisec bigint,
fastestlap int ,finalrank int,fastestlaptime time,
fastestlapspeed float,statusid int,
foreign key(raceid) references race(raceid),
foreign key(driverid) references driver(driverid),
foreign key(constructorid) references constructor(constructorid),
foreign key(statusid) references status(statusid));
drop table result;
load data infile 
"C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\result.csv"
into table result
columns terminated by ','
optionally enclosed by '"'
escaped by '"'
lines terminated by  '\r\n'
ignore 1 lines;


#######

#waq to find the total number of participating countries
select count(distinct nationality) "Total Participating Countries" from driver;
create view total_participating_countries as (select count(distinct nationality) 
"Total Participating Countries" from driver);

#waq to find the most used car in race
select name,count(raceid) from constructor c inner join constructorresult cr 
on c.constructorid=cr.constructorid group by 1 order by 2 desc limit 1;
create view popular_car as(select name,count(raceid) from constructor c inner join 
constructorresult cr on c.constructorid=cr.constructorid group by 1 order by 2 desc limit 1);

#what is the avg time to complete a race
select name,avg(milisec) avgtime,max(lap) maximumlap from race r inner join 
result rs on r.raceid=rs.raceid group by 1 order by 2 limit 1;
create view avg_time as (select name,avg(milisec) avgtime,max(lap) maximumlap 
from race r inner join result rs on r.raceid=rs.raceid group by 1 order by 2 limit 1);

#waq to find the most prefferd county for races
select country,count(raceid) as "TOTAL RACES" from circuit c inner join race r 
on c.circuitid=r.circuitid group by 1 order by 2 desc limit 1;
create view best_country as (select country,count(raceid) as "TOTAL RACES" 
from circuit c inner join race r on c.circuitid=r.circuitid group by 1 order by 2 desc limit 1);

#waq to find the driver that won the most no. of times
select concat(forename," ",surname) drivername, count(resultid) wins 
from driver d inner join result r on d.driverid=r.driverid where 
finalrank=1 group by 1 order by  2  desc limit 1;
create view best_driver as(select concat(forename," ",surname) drivername, 
count(resultid) wins from driver d inner join result r on d.driverid=r.driverid 
where finalrank=1 group by 1 order by  2  desc limit 1);

#waq to find the total years of data avalible
select distinct count(distinct year(rdate)) as 
"years for which data is available" from race order by 1 ;
create view years as(select distinct count(distinct year(rdate)) as 
"years for which data is available" from race order by 1 );

#youngest driver to rank 1st
select concat(forename," ",surname),nationality from driver where 
dob=( select max(dob) from driver inner join result using (driverid) where finalrank=1 );
create view youngest_driver as (select concat(forename," ",surname),
nationality from driver where dob=( select max(dob) from driver inner join result 
using (driverid) where finalrank=1 ));

#TOTAL NUMBER OF INJURIES
select count(*) from result inner join status using 
(statusid) where status="accident";
create view TOTAL_ACCIDENTS as (select count(*)as "TOTAL ACCIDENTS" from 
result inner join status using (statusid) where status="accident");

#MOST CAR PRODUCING COUNTRY
select nationality from constructor group by nationality order by 
count(nationality) desc limit 1;
create view most_production as (select nationality from constructor 
group by nationality order by count(nationality) desc limit 1);

#############


#waq to find the maximum speed attained by each car
select dense_rank() over(order by max(fastestlapspeed)) as drank, 
name,max(fastestlapspeed) topspeed from constructor c inner join result r 
on c.constructorid=r.constructorid group by 2 having topspeed!= 0 
order by 3 desc;
create view maximum_speed_by_car1 as
(select dense_rank() over(order by max(fastestlapspeed)) as drank, name,max(fastestlapspeed) topspeed from constructor c inner join result r on c.constructorid=r.constructorid group by 2 having topspeed!= 0);
drop view maximum_speed_by_car;

#waq to compare the number of rounds yearwise
with cte as (select year(rdate),max(round) presentyearround,
lag(max(round),1,0) over(order by year(rdate)) as lastyearround from race group by 1)
select *,presentyearround-lastyearround as diff from cte;
create view rounds_yearwise as (with cte as (select year(rdate),max(round) presentyearround,lag(max(round),1,0) over(order by year(rdate)) as lastyearround from race group by 1)
select *,presentyearround-lastyearround as diff from cte);

#waq to find the cars that are not being used in races
select nationality,group_concat(name),count(name)from constructor c 
left join constructorresult cr on c.constructorid=cr.constructorid 
where cr.constructorid is null group by 1;
create view not_used_cars1 as (select nationality,group_concat(name),count(name)
 from constructor c left join constructorresult cr on c.constructorid=cr.constructorid where cr.constructorid is null group by 1);
drop view not_used_cars1;

#waq to find the relationship between the nationality of driver and constructor
select c.nationality "manufacturing countries",
count(distinct d.nationality) "count driver countries" ,
group_concat(distinct d.nationality) "driver countries" from driver d 
inner join result r  on d.driverid=r.driverid inner join constructor c on 
r.constructorid=c.constructorid group by c.nationality;
create view driver_constructor as (select c.nationality "manufacturing countries",count(distinct d.nationality) "count driver countries" ,group_concat(distinct d.nationality) "driver countries"
from driver d inner join result r  on d.driverid=r.driverid inner join constructor c on r.constructorid=c.constructorid group by c.nationality);

#waq to classify the years and monitor the participation
select case when year(rdate) between 1950 and 1959 then 1950 
when year(rdate) between 1960 and 1969 then 1960
when year(rdate) between 1970 and 1979 then 1970
when year(rdate) between 1980 and 1989 then 1980
when year(rdate) between 1990 and 1999 then 1990
when year(rdate) between 2000 and 2009 then 2000
when year(rdate) between 2010 and 2021 then 2010
end as years,count(driverid) from race r inner join 
result rs on r.raceid=rs.raceid group by 1 order by 1;
create view decade_participation as (select case when year(rdate) between 1950 and 1959 then 1950 
when year(rdate) between 1960 and 1969 then 1960
when year(rdate) between 1970 and 1979 then 1970
when year(rdate) between 1980 and 1989 then 1980
when year(rdate) between 1990 and 1999 then 1990
when year(rdate) between 2000 and 2009 then 2000
when year(rdate) between 2010 and 2021 then 2010
end as years,count(driverid) from race r inner join result rs on r.raceid=rs.raceid group by 1 order by 1);


#waq to find the avg of age of drivers in race
with cte as(select  ds.raceid, year(dob) dobyear,year(rdate) raceyear 
from driver d inner join driverstanding ds on d.driverid=ds.driverid 
inner join race r on ds.raceid= r.raceid) 
select raceyear,avg(raceyear-dobyear) from cte c inner join result r 
on c.raceid=r.raceid where finalrank in (0,1,2,3,4,5) group by 1 order by 1;
create view avg_age as(with cte as(select  ds.raceid, year(dob) dobyear,year(rdate) raceyear 
from driver d inner join driverstanding ds on d.driverid=ds.driverid inner join race r on ds.raceid= r.raceid) 
select raceyear,avg(raceyear-dobyear) from cte c inner join result r on c.raceid=r.raceid where finalrank in (0,1,2,3,4,5) group by 1 order by 1);

#waq to see which driver uses which car
select concat(forename," ",surname) , group_concat(distinct name) constructorid,
count(distinct r2.constructorid) count from result r1 inner join result r2 on 
r1.resultid=r2.resultid inner join driver d on d.driverid=r1.driverid inner join 
constructor c on c.constructorid=r1.constructorid group by 1 having count>3;
create view driver_uses_car as (select concat(forename," ",surname) , group_concat(distinct name) constructorid,count(distinct r2.constructorid) count
from result r1 inner join result r2 on r1.resultid=r2.resultid inner join driver d on d.driverid=r1.driverid inner join constructor c on c.constructorid=r1.constructorid 
group by 1 having count>3);

#waq to find the most winning driver 
with cte as (select * from(select dense_rank() over(partition by year(rdate) 
order by (milisec/lap)) drank,year(rdate) rdate, 
concat(forename," ",surname) dname,nationality
from result rs inner join race r on rs.raceid=r.raceid inner join driver d 
on rs.driverid=d.driverid where milisec!=0 order by 2) as sub where drank=1) 
select dname , nationality,count(*) win,group_concat(rdate) from cte 
group by 1,2 having win>1 order by win desc;
create view most_winning_driver as (with cte as 
(select * from
(select dense_rank() over(partition by year(rdate) order by (milisec/lap)) drank,year(rdate) rdate, concat(forename," ",surname) dname,nationality
from result rs inner join race r on rs.raceid=r.raceid inner join driver d on rs.driverid=d.driverid where milisec!=0 order by 2) 
as sub where drank=1) 
select dname , nationality,count(*) win,group_concat(rdate) from cte group by 1,2 having win>1 order by win desc);


#waq to find the number racing tracks per country
create view trackes_per_country as 
(select count.ry ,group_concat(distinct name),count(*) count from 
circuit group by 1 having count>3 order by 3 desc) ;
select country ,group_concat(distinct name),count(*) count from circuit group by 1 having count>3 order by 3 desc;

#waq to find the points of each car
select name,sum(points) from constructorresult cr inner join 
constructor c  using (constructorid) group by 1 order by 2 desc;
create view points_per_car as (select name,sum(points) from constructorresult cr inner join constructor c  using (constructorid) group by 1 order by 2 desc);

#points by year
SELECT * FROM DRIVERSTANDING;
WITH CTE AS (SELECT  NAME,YEAR(RDATE) AS RYEAR,DRIVERID,POINTS,
ntile(20) OVER(partition by RACEID ORDER BY WINS DESC) FROM DRIVERSTANDING 
INNER JOIN RACE USING (RACEID) WHERE POINTS!=0)
SELECT NAME,RYEAR,SUM(POINTS) FROM CTE GROUP BY 1,2 ORDER BY 3 DESC ;

CREATE VIEW RACE_MOST_POINTS AS (WITH CTE AS (SELECT  NAME,YEAR(RDATE) AS RYEAR,DRIVERID,POINTS,ntile(20) OVER(partition by RACEID ORDER BY WINS DESC) 
FROM DRIVERSTANDING INNER JOIN RACE USING (RACEID) WHERE POINTS!=0)
SELECT NAME,RYEAR,SUM(POINTS) FROM CTE GROUP BY 1,2 ORDER BY 3 DESC) ;

#COMPARISION BETWEEN FINAL RANK TIME AND NATIONALITY
select finalrank,milisec,nationality from result inner join driver
using(driverid) where milisec!=0 and finalrank!=0;

create view ribbon as (select finalrank,milisec,nationality from result inner join driver  using(driverid) where milisec!=0 and finalrank!=0);

