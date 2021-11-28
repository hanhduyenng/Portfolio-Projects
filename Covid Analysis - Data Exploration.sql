select * from dbo.covidvaccination
order by 3,4
select * from dbo.coviddeath
where continent is not null
order by 3,4 

select location, date, total_cases,new_cases, total_deaths, population
from dbo.coviddeath
order by 1,6

--The percentage of deaths for each country in Asia
select continent, location, date, total_cases, total_deaths, population, (total_deaths/total_cases*100) as death_ratio
from dbo.coviddeath
where continent = 'Asia' and continent is not null
order by 2,6

--Compare the ratio of total cases versus population
select continent, location, date, total_cases, population, (total_cases/population)*100 as covid_percentage
from dbo.coviddeath
where continent is not null
order by 2,5

--Rank countries from high to low infection rate
select location, population, max(total_cases) as highestinfection_countries, max((total_cases/population))*100 as infectedpopulation_percentage
from dbo.coviddeath
where continent is not null
group by location, population
order by infectedpopulation_percentage desc

--Countries with highest Deaths no.
select location, population, max(cast(total_deaths as int)) as highestdeaths_countries
from dbo.coviddeath
where continent is not null
group by location, population
order by highestdeaths_countries desc

--Continent with highest deaths no.
select continent, max(cast(total_deaths as int)) as highestdeaths_no
from dbo.coviddeath
where continent is not null
group by continent
order by highestdeaths_no desc

--Global figure of Covid situation.
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from dbo.coviddeath
where continent is not null
group by date


--Compare total vaccination status versus population
with vac_analysis( continent, location, date, population, new_vaccinations, total_vaccinations) as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(bigint, v.new_vaccinations)) over ( partition by d.location order by d.location, d.date) as total_vaccinations
from dbo.coviddeath as d
join dbo.covidvaccination as v
	on d.location =v.location
where d.continent is not null
	and d.date = v.date
)

select *, (total_vaccinations/population)*100 as perc_vaccinated
from vac_analysis

--Vaccination Analysis Table

create table vaccination(
continent nvarchar(250),
location nvarchar(250),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations numeric
)
insert into vaccination
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(bigint, v.new_vaccinations)) over ( partition by d.location order by d.location, d.date) as total_vaccinations
from dbo.coviddeath as d
join dbo.covidvaccination as v
	on d.location =v.location
where d.continent is not null
	and d.date = v.date

select *, (total_vaccinations/population)*100 as perc_vaccinated
from vaccination

--Create view

create view vaccination_breakdown as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(bigint, v.new_vaccinations)) over ( partition by d.location order by d.location, d.date) 
as total_vaccinations
from dbo.coviddeath as d
join dbo.covidvaccination as v
	on d.location =v.location
where d.continent is not null
	and d.date = v.date

select * from vaccination_breakdown