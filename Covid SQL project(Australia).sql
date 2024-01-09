/* 
Covid 19 Data exploration

Skills used: Joins, Temp Tables, windows functions,aggregate functions, coverting data types
*/

select *
from covid_deaths
where continent is not null
--select data we would be using
select  location,date,population,total_cases,new_cases,total_deaths
from PortfolioProject..covid_deaths
order by 1,2
-- Total Cases vs Total Deaths worldview
alter table covid_deaths
alter column population dec

select  location,date,population,total_cases,total_deaths,
(total_deaths/total_cases)*100 as Death_percentage
from covid_deaths
order by 1,2 desc


-- population with the highest infection rate compared to location
select location,population,max(total_cases) as highestinfectioncount 
from covid_deaths
where location not in 
('world','high income',
'North America','European Union',
'Asia','Upper middle income',
'Lower middle income','South America',
'europe'
)
group by location,population
order by highestinfectioncount desc


-- population with the highest amount of deathrate comapared to location
select location,max(total_deaths) as highestdeathcount
from covid_deaths
where location not in
('world','high income',
'North America','European Union',
'Asia','Upper middle income',
'Lower middle income','South America',
'europe'
)
group by location
order by highestdeathcount desc

-- BREAKING DOWN BY COUNTRY(AUSTRALIA)

-- probability of contacting covid in australia
select  location,date,population,total_cases,
(total_cases/population)*100 as covid_probability
from covid_deaths
where location = 'australia' 
order by 1,2

-- day with the highest amount of covid cases count in Australia
select location,date, new_cases 
from covid_deaths
where location = 'australia' and new_cases >= 588813

-- daily infection per capital in Australia
select population,date, (new_cases/population*100) as infected_per_capita
from covid_deaths
where location = 'australia'
order by 1,2

-- day with the highest amount of covid death count in Australia
select location,date,max(new_deaths) as highestdeathcount
from covid_deaths
where location = 'australia' and new_deaths >= 1161
group by location,date

--daily covid deaths per capita
select population,date, (new_deaths/population*100) as death_per_capita
from covid_deaths
where location = 'australia'
order by 1,2


-- total vaccine administered per daily case
select cd.date,cd.new_cases,CV.new_vaccinations,cd.total_cases
from covid_deaths CD join
covid_vaccination CV
on CD.location= CV.location and CD.date=CV.date
where cd.location= 'australia'
order by date 

-- total population vaccines in australia
select distinct CD.population, cd.location, 
sum(try_cast(CV.new_vaccinations as dec)) over (partition by cd.population) as total_vac_administered
from covid_deaths CD join
covid_vaccination CV
on CD.location= CV.location and CD.date=CV.date
where cd.location= 'australia'

-- using temp table 
CREATE TABLE #vaccinesforpeople
(
	date datetime,
    new_vaccination nvarchar(255),
    total_vac_administered decimal(18, 0),
	new_cases numeric
)
INSERT INTO #vaccinesforpeople (date, new_vaccination, total_vac_administered, new_cases)
select CD.date,CD.new_cases, CV.new_vaccinations,
    SUM(TRY_CAST(CV.new_vaccinations AS DECIMAL(18, 0))) OVER (PARTITION BY CD.population) AS total_vac_administered
from covid_deaths CD
join covid_vaccination CV 
on CD.location = CV.location AND CD.date = CV.date
WHERE CD.location = 'Australia'


select date,new_cases,total_vac_administered/new_cases*100 as people_per_vaccine
from #vaccinesforpeople