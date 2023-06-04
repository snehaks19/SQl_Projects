use censusIndia;

select * from censusIndia.dbo.Data1$;

select count(*) from Data1
select count(*) from Data2

--Population of India

select SUM(Population)as population from Data2;

--Average growth 

select state,AVG(Growth)*100 as avg_growth from Data1 group by state

-- avg sex ratio

select state,round(AVG(sex_ratio),0)as avg_sex_ratio from Data1 group by state order by avg_sex_ratio desc

-- avg literacy rate

select state,round(AVG(Literacy),0)as avg_literacy from Data1 group by state having round(AVG(Literacy),0)>90 order by avg_literacy desc

--3 state which has highest average growth rate

select top 3 state,AVG(Growth)*100 as avg_growth from Data1 group by state order by avg_growth desc 

--bottom 3 states showing lowest sex ratio

select top 3 state,round(AVG(sex_ratio),0)as avg_sex_ratio from Data1 group by state order by avg_sex_ratio asc

--top 3 and bottom 3 states showing literacy rate

drop table if exists #topstates;

create table #topstates(states varchar(200),topstates float)

insert into #topstates select state,round(AVG(Literacy),0)as avg_literacy from Data1 group by state order by avg_literacy desc

select top 3 * from #topstates order by topstates desc


drop table if exists #bottomstates

create table #bottomstates(states varchar(200),bottomstates float)

insert into #bottomstates select state,round(AVG(Literacy),0)as avg_literacy from Data1 group by state order by avg_literacy asc

select top 3 * from #bottomstates order by #bottomstates.bottomstates asc

--union operator

select * from 
(select top 3 * from #topstates order by #topstates.topstates desc) a 
union 
select * from 
(select top 3 * from #bottomstates order by #bottomstates.bottomstates asc) b

--states starting with letter a or b

select distinct state from Data1 where LOWER(state) like 'a%' or LOWER(state) like 'b%'

--states ending with letter a

select distinct state from Data1 where LOWER(state) like '%a' 

--joining two tables

select a.district,a.state,a.Sex_Ratio,b.Population from Data1 a inner join Data2 b on a.District=b.District
