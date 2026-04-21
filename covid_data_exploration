/*
    COVID-19 Data Exploration

    Skills demonstrated:
    - Joins
    - CTEs
    - Temp Tables
    - Window Functions
    - Aggregate Functions
    - Views
    - Data Type Conversion
*/

-- Preview the main dataset
SELECT *
FROM projetcovid..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;


-- Select the main fields used for exploration
SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM projetcovid..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;


-- Total Cases vs Total Deaths
-- Shows the likelihood of dying after contracting COVID in a specific country
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM projetcovid..CovidDeaths
WHERE location LIKE '%states%'
  AND continent IS NOT NULL
ORDER BY 1, 2;


-- Total Cases vs Population
-- Shows the percentage of the population infected with COVID
SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS PercentPopulationInfected
FROM projetcovid..CovidDeaths
ORDER BY 1, 2;


-- Countries with the highest infection rate compared to population
SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM projetcovid..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- Countries with the highest total death count
SELECT 
    location,
    MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM projetcovid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Death count by continent
SELECT 
    continent,
    MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM projetcovid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global numbers
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS int)) AS total_deaths,
    SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM projetcovid..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;


-- Total Population vs Vaccinations
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM projetcovid..CovidDeaths dea
JOIN projetcovid..CovidVaccinations vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


-- Using a CTE
WITH PopvsVac AS
(
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) 
            OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM projetcovid..CovidDeaths dea
    JOIN projetcovid..CovidVaccinations vac
        ON dea.location = vac.location
       AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *,
       (RollingPeopleVaccinated / population) * 100 AS PercentPeopleVaccinated
FROM PopvsVac;


-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM projetcovid..CovidDeaths dea
JOIN projetcovid..CovidVaccinations vac
    ON dea.location = vac.location
   AND dea.date = vac.date;

SELECT *,
       (RollingPeopleVaccinated / Population) * 100 AS PercentPeopleVaccinated
FROM #PercentPopulationVaccinated;


-- Create View
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM projetcovid..CovidDeaths dea
JOIN projetcovid..CovidVaccinations vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
