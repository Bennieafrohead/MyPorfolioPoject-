-- Showing My Already Imported CSV PortFolio Data 
SELECT *
FROM my_portfolio_database.coviddeaths
WHERE continent is not null
ORDER BY 3,4;
SELECT *
FROM my_portfolio_database.covidvaccination
WHERE continent is not null
ORDER BY 3,4;

-- Selecting the data to be used during this project
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM my_portfolio_database.coviddeaths
WHERE continent is not null
ORDER BY 1;

-- Looking Into The Total Cases Vs Total Deaths In Percentage (100)
SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
FROM my_portfolio_database.coviddeaths
WHERE location like '%Africa%'
ORDER BY 1;

-- Looking At The Percentage Of Total Cases Vs The Population In Africa
SELECT Location, date, population total_cases, new_cases, total_deaths, (total_cases/population)*100 as death_percent
FROM my_portfolio_database.coviddeaths
WHERE continent is not null AND location like '%Africa%'
ORDER BY 1;

-- Looikng At Countries With Highest Infection Rate Compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM my_portfolio_database.coviddeaths
WHERE continent is not null AND location LIKE '%Africa%'
ORDER BY 1;

-- Showing Countries with the higest deaths count
SELECT location, MAX(CAST(total_deaths as UNSIGNED)) as TotalDeathCount
FROM my_portfolio_database.coviddeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;

-- Showing Continents with the higest deaths count
SELECT continent, MAX(CAST(total_deaths as UNSIGNED)) as TotalDeathCount
FROM my_portfolio_database.coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount asc;

-- Aggregrate function & globally doing numbers
SELECT date, SUM(new_cases), SUM(new_deaths) -- total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM my_portfolio_database.coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 1,2;

-- death percentage globally 
SELECT location, date, SUM(new_cases) as total_new_cases, SUM(new_deaths) AS NewDeaths, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM my_portfolio_database.coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 1,2;


-- looking at the total population vs vaccinations by joining both tables 
SELECT *
FROM my_portfolio_database.coviddeaths dae
JOIN my_portfolio_database.covidvaccination vac
	 ON dae.location = vac.location
     AND dae.date = vac.date;

-- Looking at the total population VS newly vaccinated 
SELECT dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations
FROM my_portfolio_database.coviddeaths dae
JOIN my_portfolio_database.covidvaccination vac
	 ON dae.location = vac.location
     AND dae.date = vac.date
WHERE dae.continent is not null
ORDER BY 2,3;

-- newly vaccination per day roll up
SELECT dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dae.location ORDER BY dae.location,  dae.date) AS RollingNewPeopleVac
FROM my_portfolio_database.coviddeaths dae
JOIN my_portfolio_database.covidvaccination vac 
	 ON dae.location = vac.location
     AND dae.date = vac.date
WHERE dae.continent is not null
ORDER BY 1,2

-- USING CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingNewPeopleVac)
AS
(SELECT dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dae.location ORDER BY dae.location,  dae.date) AS RollingNewPeopleVac
FROM my_portfolio_database.coviddeaths dae
JOIN my_portfolio_database.covidvaccination vac 
	 ON dae.location = vac.location
     AND dae.date = vac.date
WHERE dae.continent is not null
ORDER BY 1,2)

SELECT *, (RollingNewPeopleVac/Population)*100
FROM PopvsVac

-- Creating view to store data for visualizing later
CREATE VIEW PercentPopulationVaccinations AS 
SELECT dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dae.location ORDER BY dae.location,  dae.date) AS RollingNewPeopleVac
FROM my_portfolio_database.coviddeaths dae
JOIN my_portfolio_database.covidvaccination vac 
	 ON dae.location = vac.location
     AND dae.date = vac.date
WHERE dae.continent is not null
-- ORDER BY 1,2)

