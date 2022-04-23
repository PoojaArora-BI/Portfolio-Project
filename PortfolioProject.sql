-- Total_cases Vs Total_Deaths
--liklehood of dying if you contract covid in your country

SELECT location,date,population,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.[dbo].[Covid-deaths]
Where continent IS NOT NULL AND location='Singapore' 
ORDER BY 1,2 DESC

--Total_cases VS Population
--Shows what % of population got Covid
SELECT location,date,population,total_cases,total_deaths, (total_cases/population)*100 AS PopulationPercentagegotCovid
FROM PortfolioProject.[dbo].[Covid-deaths]
Where continent IS NOT NULL AND location='Singapore' 
ORDER BY 1,2 DESC

--Countries with Highest Infection rate Compared to Population
SELECT location,population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.[dbo].[Covid-deaths]
--Where continent IS NOT NULL AND location='Singapore' 
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

--Countries with highest Death Counts
SELECT location,MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.[dbo].[Covid-deaths]
Where continent IS NOT NULL --AND location='Singapore' 
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continents with Highest Death Count per Population
SELECT continent,MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.[dbo].[Covid-deaths]
Where continent IS NOT NULL --AND location='Singapore' 
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT date,SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS Death_Percentage
FROM PortfolioProject.[dbo].[Covid-deaths]
Where continent IS NOT NULL --AND location='Singapore' 
GROUP BY date
ORDER BY 1,2 

--Total Population VS Vaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(new_vaccinations AS bigint)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated

FROM PortfolioProject.[dbo].[Covid-deaths] AS dea
JOIN PortfolioProject.[dbo].[Covid-Vaccinations] AS vac
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-------  CTE
WITH PopVsVac(Continent,Location,date,Population,New_Vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(new_vaccinations AS bigint)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.[dbo].[Covid-deaths] AS dea
JOIN PortfolioProject.[dbo].[Covid-Vaccinations] AS vac
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent IS NOT NULL --AND dea.location='Singapore'
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100 AS PercentVaccinated 
FROM PopVsVac

---TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into  #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(new_vaccinations AS bigint)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.[dbo].[Covid-deaths] AS dea
JOIN PortfolioProject.[dbo].[Covid-Vaccinations] AS vac
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent IS NOT NULL --AND dea.location='Singapore'
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentVaccinated 
FROM #PercentPopulationVaccinated


--Creating View to store Data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(new_vaccinations AS bigint)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.[dbo].[Covid-deaths] AS dea
JOIN PortfolioProject.[dbo].[Covid-Vaccinations] AS vac
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent IS NOT NULL --AND dea.location='Singapore'


--Showing Continents with Highest Death Count per Population

CREATE VIEW HighestDeathCountVsPopulation AS
SELECT continent,MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.[dbo].[Covid-deaths]
Where continent IS NOT NULL --AND location='Singapore' 
GROUP BY continent
--ORDER BY TotalDeathCount DESC