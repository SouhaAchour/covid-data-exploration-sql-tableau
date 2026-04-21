/*
    Queries Used for Tableau COVID Project
*/

-- 1. Global Cases, Deaths, and Death Percentage
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS int)) AS total_deaths,
    SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM ProjectCovid..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Double-check against world totals
-- The values are very close, so we keep the first query
-- The second query includes "International"

-- SELECT 
--     SUM(new_cases) AS total_cases,
--     SUM(CAST(new_deaths AS int)) AS total_deaths,
--     SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
-- FROM ProjectCovid..CovidDeaths
-- WHERE location = 'World'
-- ORDER BY 1, 2;


-- 2. Total Death Count by Location
-- Excluding World, European Union, and International for consistency
SELECT 
    location,
    SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM ProjectCovid..CovidDeaths
WHERE continent IS NULL
  AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- 3. Highest Infection Rate Compared to Population
SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM ProjectCovid..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- 4. Infection Rate by Location and Date
SELECT 
    location,
    population,
    date,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM ProjectCovid..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC;


-------------------------------------------------------------------
-- Additional Queries
-- These were part of the original SQL exploration
-- but were not all included in the Tableau video
-------------------------------------------------------------------

-- 5. Total Vaccinations by Location and Date
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    MAX(vac.total_vaccinations) AS RollingPeopleVaccinated
FROM ProjectCovid..CovidDeaths dea
JOIN ProjectCovid..CovidVaccinations vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.location, dea.date, dea.population
ORDER BY 1, 2, 3;


-- 6. Global Cases, Deaths, and Death Percentage
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS int)) AS total_deaths,
    SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM ProjectCovid..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Double-check using world totals
-- SELECT 
--     SUM(new_cases) AS total_cases,
--     SUM(CAST(new_deaths AS int)) AS total_deaths,
--     SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
-- FROM ProjectCovid..CovidDeaths
-- WHERE location = 'World'
-- ORDER BY 1, 2;


-- 7. Total Death Count by Location
SELECT 
    location,
    SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM ProjectCovid..CovidDeaths
WHERE continent IS NULL
  AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- 8. Highest Infection Rate Compared to Population
SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM ProjectCovid..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- 9. Cases, Deaths, and Population by Location and Date
SELECT 
    location,
    date,
    population,
    total_cases,
    total_deaths
FROM ProjectCovid..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;


-- 10. Vaccination Progress Using CTE
WITH PopvsVac (
    Continent,
    Location,
    Date,
    Population,
    New_Vaccinations,
    RollingPeopleVaccinated
) AS
(
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(int, vac.new_vaccinations)) 
            OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM ProjectCovid..CovidDeaths dea
    JOIN ProjectCovid..CovidVaccinations vac
        ON dea.location = vac.location
       AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *,
       (RollingPeopleVaccinated / Population) * 100 AS PercentPeopleVaccinated
FROM PopvsVac;


-- 11. Infection Rate by Location and Date
SELECT 
    location,
    population,
    date,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM ProjectCovid..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC;
