--  SELECT * from coviddeaths;
-- SELECT 
--    location,
--   date,
--    total_cases,
--    new_cases,
--    total_deaths,
--    population
-- FROM
--    coviddeaths
-- ORDER BY 1 , 2;


-- 1) Total Cases Vs Total Deaths (How many people that got the disease died)
 -- SELECT location,total_deaths,total_cases FROM coviddeaths WHERE location LIKE "Afgh%"; 
-- SELECT location,total_deaths,total_cases as fatalityRate FROM coviddeaths GROUP BY  location HAVING location LIKE "Afgh%";

-- 2) 
-- SELECT location,date,population,total_cases,100*(total_cases/population) AS PositivePercent FROM coviddeaths;

-- 3) Determining countries with the highest infection rate
-- SELECT location,MAX(total_cases) as MaxCase,MAX(population) as pop, 100*(MAX(total_cases)/MAX(population)) as PositivePercent from coviddeaths GROUP BY location ORDER BY PositivePercent DESC;


-- 4) Determining countries with the highest fatality rate
-- We add the where continent is not null (!= '')to exclude entries where the location is a continent. we already have sub locations within a continent for countries.
-- SELECT location,MAX(CAST(total_deaths AS UNSIGNED)) as MaxDeath,MAX(population) as pop, 100*(MAX(total_deaths)/MAX(population)) as FatalityPercent from coviddeaths WHERE continent != '' GROUP BY location ORDER BY FatalityPercent DESC;


-- 5) Determining the death count of the countries if we want continent statistics we can do continent =''
-- SELECT location,MAX(CAST(total_deaths AS UNSIGNED)) AS tdeaths FROM coviddeaths WHERE continent ='' GROUP BY location ORDER BY tdeaths DESC;

-- 6) Daily global numbers
-- SELECT date,SUM(new_cases) as totNew FROM coviddeaths GROUP BY DATE ORDER BY totNew DESC;

-- 7) percentage of people vaccinated
-- SELECT dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,SUM(CAST(vacc.new_vaccinations AS UNSIGNED)) OVER( PARTITION BY dea.location ORDER BY dea.date DESC) AS totalVacc FROM coviddeaths AS dea JOIN covidvacc1 AS vacc ON dea.location = vacc.location and dea.date = vacc.date WHERE dea.continent !='' ORDER BY dea.continent,dea.date DESC;
-- SELECT 
 --   dea.continent,
--    dea.location,
--    dea.date,
--    dea.population,
--   vacc.new_vaccinations,
--    SUM(CAST(vacc.new_vaccinations AS UNSIGNED)) OVER(PARTITION BY dea.location ORDER BY dea.date) AS totalCases
-- FROM
--    coviddeaths AS dea
--        JOIN
--    covidvacc1 AS vacc ON dea.date = vacc.date
--        AND dea.location = vacc.location
-- WHERE dea.continent != '';

-- 8) Now we want for each country the total percentage of people that tested positive when compared to the entire population.

SELECT 
	dea.location,
    dea.date,
    dea.population,
    SUM(CAST(vacc.new_vaccinations AS UNSIGNED)) OVER(PARTITION BY dea.location ORDER BY dea.date) AS totalVacc
FROM
    coviddeaths AS dea
        JOIN
    covidvacc1 AS vacc ON dea.date = vacc.date
        AND dea.location = vacc.location
	WHERE dea.continent != '';
    
WITH totalPos AS (
SELECT 
	dea.location,
    dea.date,
    CAST(dea.population AS UNSIGNED) AS population,
    SUM(CAST(vacc.new_vaccinations AS UNSIGNED)) OVER(PARTITION BY dea.location ORDER BY dea.date) AS totalVacc
FROM
    coviddeaths AS dea
        JOIN
    covidvacc1 AS vacc ON dea.date = vacc.date
        AND dea.location = vacc.location
	WHERE dea.continent != ''
    )
    SELECT location,totalVacc,population,100*totalVacc/population AS rollingPercent FROM totalPos ORDER BY location;
   -- SELECT dea.location,100*(MAX(totalPos.totalCases)/MAX(dea.population)) AS PosRate FROM coviddeaths AS dea LEFT JOIN totalPos ON dea.location = totalPos.location WHERE continent != '' GROUP BY dea.location AND dea.date ORDER BY PosRate DESC;

CREATE VIEW PERCENTPOPVACCINATED as
SELECT 
	dea.location,
    dea.date,
    dea.population,
    SUM(CAST(vacc.new_vaccinations AS UNSIGNED)) OVER(PARTITION BY dea.location ORDER BY dea.date) AS totalVacc
FROM
    coviddeaths AS dea
        JOIN
    covidvacc1 AS vacc ON dea.date = vacc.date
        AND dea.location = vacc.location
	WHERE dea.continent != '';


