SELECT *
FROM Portfolio..CovidDeaths
Where continent is not null
ORDER BY 3, 4

--SELECT *
--FROM Portfolio..CovidVaccinations
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..CovidDeaths
Where continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths


Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage

From Portfolio..CovidDeaths
Where continent is not null
ORDER BY 1,2



Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage

From Portfolio..CovidDeaths
WHERE location like '%states%' AND continent is not null
ORDER BY 1,2


-- Shows probabillity of dying in Poland if you contract covid 

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage

From Portfolio..CovidDeaths
WHERE location like '%POLAND%' 
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases,(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected

From Portfolio..CovidDeaths
WHERE location like '%POLAND%' 
ORDER BY 1,2



-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected

From Portfolio..CovidDeaths
Where continent is not null
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population


Select Location, MAX(CONVERT(float,total_deaths)) as TotalDeathCount
FROM Portfolio..CovidDeaths
Where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Break Things Down By Continent

select continent,  sum(convert(float,new_deaths)) as TotalDeathCount

from Portfolio..CovidDeaths

where continent!=''

group by continent

order by TotalDeathCount desc


-- Global Numbers

SELECT SUM(Convert(float,new_cases)) as total_cases, SUM(CONVERT(FLOAT,new_deaths)) as total_deaths, SUM(convert(float,new_deaths))/SUM(convert(float,new_cases))*100 as DeathPercentage
FROM Portfolio..CovidDeaths
WHERE continent IS NOT NULL
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location, dea.Date) as RollingPeopleVaccinated

From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location, dea.Date) as RollingPeopleVaccinated

From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location, dea.Date) as RollingPeopleVaccinated

From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


