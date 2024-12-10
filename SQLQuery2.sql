select *
from CovidDeaths
--where continent is not null
order by 3, 4

--select *
--from CovidVaccinations
--order by 3, 4

--select data that we are going to using

select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio_project..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
-- shows liklihood of dying if you contract covid in INDIA
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_project..CovidDeaths
where location like '%India%'
order by 1,2

--loooking at total cases vs population
--shows what % of population got covid

select Location, date,population, total_cases,  (total_cases/population)*100 as InfectedPercentage
from Portfolio_project..CovidDeaths
where location like '%India%'
order by 1,2

--looking at countries with highest infection rate compared to population

select Location, population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as InfectedPercentage
from Portfolio_project..CovidDeaths
--where location like '%India%'
where continent is not null
group by location, population
order by InfectedPercentage desc

--showing countries with highest death count per population in country

select location, max(cast(total_deaths as int)) as totaldeaths
from Portfolio_project..CovidDeaths
where continent is not null
group by location
order by totaldeaths desc

-- lets break things down in continent

-- showing the continents with highest death count per population

select location, max(cast(total_deaths as int)) as totaldeaths
from Portfolio_project..CovidDeaths
where continent is null
group by location
order by totaldeaths desc

--TRIAL
select continent, max(cast(total_deaths as int)) as totaldeaths
from Portfolio_project..CovidDeaths
--where continent is null
group by continent
order by totaldeaths desc
 
 --GLOBAL NUMBERS

select date, sum(new_cases)as global_new_cases,sum(cast(new_deaths as int)) as global_new_cases,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Portfolio_project..CovidDeaths
--where location like '%India%' and
where continent is not null
group by date
order by 1,2 

select sum(new_cases)as global_new_cases,sum(cast(new_deaths as int)) as global_new_cases,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Portfolio_project..CovidDeaths
--where location like '%India%' and
where continent is not null
--group by date
order by 1,2 

--joining two table death and vaccination

select *
from Portfolio_project..CovidDeaths dea
JOIN Portfolio_project..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date

-- looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Portfolio_project..CovidDeaths dea
JOIN Portfolio_project..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--using cte creating a rolling sum and percentage of vaccination per population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingcountvaccinations
from Portfolio_project..CovidDeaths dea
JOIN Portfolio_project..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--using cte

with popVsvac (continent, location, date, population, vaccinations, rollingcountvac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingcountvaccinations
from Portfolio_project..CovidDeaths dea
JOIN Portfolio_project..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
)
select*, (rollingcountvac/population)*100 as rollingPercentVaccinated
from popVsvac
where location like '%India%'



-- creating view to store data for later vizualisation

create view PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingcountvaccinations
from Portfolio_project..CovidDeaths dea
JOIN Portfolio_project..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPeopleVaccinated