Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%United States%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInflected
From PortfolioProject..CovidDeaths
where location like '%United States%'
and continent is not null
order by 1,2 


-- Looking at Countries with the Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInflected
From PortfolioProject..CovidDeaths
--where location like '%United States%'
where continent is not null
group by location, population
order by PercentPopulationInflected desc


-- Showimg Countries with Higest Death Count per Population 

Select location, Max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
-- where location like '%United States%'
where continent is not null
group by location
order by HighestDeathCount desc


-- LET'S BREAK DOWN THINGS BASED ON CONTINENT 

-- Continent's with Highest Death Count 

Select continent, Max(cast(total_deaths as int)) as DeathsPerContinent
From PortfolioProject..CovidDeaths
-- where location like '%United States%'
where continent is not null
group by continent
order by DeathsPerContinent desc

-- Continent's with Highest Infection Count

Select continent, Max(cast(total_cases as int)) as InfectionPerContinent
From PortfolioProject..CovidDeaths
-- where location like '%United States%'
where continent is not null
group by continent
order by InfectionPerContinent desc


-- GLOBAL NUMBERS 

Select date, Sum(new_cases) as total_cases, Sum(Cast(new_deaths as INT)) as total_deaths, Sum(Cast(new_deaths as INT))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- where location like '%United States%'
Where continent is not null
group by date
order by 1,2


Select Sum(new_cases) as total_cases, Sum(Cast(new_deaths as INT)) as total_deaths, Sum(Cast(new_deaths as INT))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- where location like '%United States%'
Where continent is not null
order by 1,2

-- Joining Both the Tables

-- Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/dea.population)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3


-- USE CTE


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
-- order by 2,3
) 
select *,(RollingPeopleVaccinated/Population)*100 as RollingPercentage
From PopvsVac


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population int,
New_Vaccinations float,
RollingPeopleVaccinated float,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null

-- Full Data

select *,(RollingPeopleVaccinated/Population)*100 as RollingPercentage
From #PercentPopulationVaccinated
where Continent is not null
order by Location,Date

-- Data With Value

select *,(RollingPeopleVaccinated/Population)*100 as RollingPercentage
From #PercentPopulationVaccinated
where Continent is not null
and New_Vaccinations is not null
and RollingPeopleVaccinated is not null
order by Location,Date


-- CREATING A VIEW
Use PortfolioProject

Drop View if exists PercentagePopulationVaccinated 

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
-- order by 2,3

Select * 
From PercentagePopulationVaccinated
order by location, date

