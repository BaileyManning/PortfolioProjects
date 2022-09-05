select * 
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

--Looking at Total cases vs Total Deaths.
--Shows likelihood of dying if you contracted covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths$
where location like 'United States'
order by 1,2


--Looking at total cases vs population
--Shows percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like 'United States'
order by 1,2

--Looking at countries with highest infection rates compared to population
select location, MAX(total_cases) AS HighestInfectionCount, population,Max((total_cases/population))*100 AS PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like 'United States'
Group by location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
select location, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject.. CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

--Let's break things down by continent

select location,Max(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject.. CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc


-- Showing continents with highest death count per population
select continent, Max(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers
select  Sum(new_cases) AS total_cases, Sum(cast(new_deaths as int)) AS total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like 'United States'
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View for later visualization
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Create View HighestDeathCountPerPopulation as
select continent, Max(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
--order by TotalDeathCount desc