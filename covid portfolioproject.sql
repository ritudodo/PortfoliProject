SELECT *
FROM CovidDeaths$
where continent is not null
ORDER BY 3,4;

--SELECT *
--FROM CovidVaccinations$
--ORDER BY 3,4;

--SELECT DATA THAT WILL BE USED

SELECT location, date, total_cases, new_cases,total_deaths,population
FROM CovidDeaths$
ORDER BY 1,2

--Total cases Vs total deaths
--shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths$
where location like '%india%'
ORDER BY 1,2;

----looking at total cases vs population
--Shows what percentage of population got covid

SELECT location, date,population, total_cases,(total_cases/population)*100 as InfectedPercentage
FROM CovidDeaths$
where location like '%india%'
ORDER BY 1,2;

--Looking at countries with highest infection rate compared to poupulation

SELECT location,population, MAX(total_cases) AS Highest_Infection_Count,MAX((total_cases/population))*100 as InfectedPercentage
FROM CovidDeaths$
Group by location,population
ORDER BY InfectedPercentage desc


--Showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths AS int)) AS total_death_count
FROM CovidDeaths$
where continent is not null
Group by location
ORDER BY total_death_count desc

--Breaking things down by continents
--showing the continents with the highest death count

SELECT continent, MAX(cast(total_deaths AS int)) AS total_death_count
FROM CovidDeaths$
where continent is not null
Group by continent
ORDER BY total_death_count desc

--global numbers


--New cases each day
SELECT SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
FROM CovidDeaths$
--where location like '%india%'
where continent is not null
--GROUP BY date
ORDER BY 1,2



--Looking at total population vs vaccination

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingpeopleVaccinated
from ProjectPortfolio..CovidDeaths$ dea
JOIN ProjectPortfolio..CovidVaccinations$ VAC
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE 

WITH PopVsVac (continent,location,date,population,new_vaccinationc,RollingpeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingpeopleVaccinated
from ProjectPortfolio..CovidDeaths$ dea
JOIN ProjectPortfolio..CovidVaccinations$ VAC
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, ( RollingpeopleVaccinated/population)*100
From PopVsVac


--temp table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingpeopleVaccinated
from ProjectPortfolio..CovidDeaths$ dea
JOIN ProjectPortfolio..CovidVaccinations$ VAC
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *, ( RollingpeopleVaccinated/population)*100
 From #PercentPopulationVaccinated


 --Creating view to store date for later visualization
 Create View PercentPopulationVaccinatedd as
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingpeopleVaccinated
from ProjectPortfolio..CovidDeaths$ dea
JOIN ProjectPortfolio..CovidVaccinations$ VAC
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null