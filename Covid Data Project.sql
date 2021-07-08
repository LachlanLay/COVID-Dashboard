SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4;

-- Select Data we are going to be using

Select  location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'DeathPercentage'
From PortfolioProject..CovidDeaths
where location like '%stralia%'
order by 1,2

-- Max death % in the world
select location, MAX((total_deaths/total_cases)*100)
from PortfolioProject..CovidDeaths
where location = 'World'
group by location

-- Looking at Total Cases vs Population
Select  location, date, population, total_cases, (total_cases/population)*100 as 'PercentPopulationInfected'
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select  location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as 'PercentPopulationInfected'
From PortfolioProject..CovidDeaths
GROUP BY  location, population
order by PercentPopulationInfected desc

-- Show Countries with Highest Death Rate compared to Population
Select  location, population, MAX(cast(total_deaths as int)) AS TotalDeathCount, MAX((total_deaths/population))*100 as 'PercentPopulationDead'
From PortfolioProject..CovidDeaths
GROUP BY  location, population
order by PercentPopulationDead desc

-- Show Countries with Highest Death Count per Population
Select  location, population, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
GROUP BY  location, population
order by TotalDeathCount desc

-- Break things down by Continent

-- Showing continents with the highest death count per population

Select  continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
GROUP BY  continent
order by TotalDeathCount desc

-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
-- group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 1,2

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2
)
Select *, (RollingPeopleVaccinated/Population)*100 as PopulationVaccinatedPercentage
From PopvsVac

-- TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2

Select *, (RollingPeopleVaccinated/Population)*100 as PopulationVaccinatedPercentage
From #PercentPopulationVaccinated


-- Creating View to store data for later visualisations 

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

Select * 
From PercentPopulationVaccinated