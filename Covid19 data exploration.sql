-- select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from MyProject..CovidDeaths
order by 1, 2

-- Total Cases vs Total Deaths
-- Percentage of people who were infected resulted in death (U.S)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from MyProject..CovidDeaths
where location like '%states%'
order by 1, 2

-- Total cases vs population
-- percentage of people infected by Covid (U.S)
select location, date, total_cases, population, (total_cases/population)* 100 as infectedPercentage
from MyProject..CovidDeaths
where location like '%states%'
order by 1, 2

-- Countries with highest Infection rate compared to its population
select location, MAX(total_cases)as HighestInfectionCount, population, 
MAX((total_cases/population))* 100 as PercentPopulationInfected
from MyProject..CovidDeaths
group by location, population
order by PercentPopulationInfected DESC

-- Countries with highest Death Count per Population
select location, Max(CAST(total_deaths as int)) as TotalDeathCount
from MyProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount DESC

-- Death counts by continents
select continent, Max(CAST(total_deaths as int)) as TotalDeathCount
from MyProject..CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount DESC

-- Global Numbers (death percentage)

select  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
from MyProject..CovidDeaths
where continent is not null
order by 1, 2

-- Covid Vaccinations 
select *
from MyProject..CovidVaccinations

-- Total population vaccinated globally
--Create Temp Table
Drop table if exists #RollingPercentVaccinated
Create table #RollingPercentVaccinated
(continent nvarchar(255), location nvarchar(255), date datetime,
population numeric, new_vaccinations numeric , RollingCountVaccinated numeric
)


Insert into #RollingPercentVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingCountVaccinated
from MyProject..CovidDeaths dea join
MyProject..CovidVaccinations vac  on 
dea.location = vac.location and
dea.date = vac.date

select *, (RollingCountVaccinated/population)*100
from #RollingPercentVaccinated

-- Create view to store data for visualizations
drop view if exists RollingPercentVaccinated

create view RollingPercentVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingCountVaccinated
from MyProject..CovidDeaths dea join
MyProject..CovidVaccinations vac  on 
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null

select * from RollingPercentVaccinated