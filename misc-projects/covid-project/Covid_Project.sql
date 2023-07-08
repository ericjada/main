/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


--Check the data types of the columns in the "Project..Covid_Deaths$" table

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Covid_Deaths$'

-- Modify the data type of the "total_cases" column to bigint

ALTER TABLE Covid_Deaths$
ALTER COLUMN total_cases bigint

-- Modify the data type of the "total_deaths" column to int

ALTER TABLE Covid_Deaths$
ALTER COLUMN total_deaths int

-- Modify the data type of the "new_cases" column to int

ALTER TABLE Covid_Deaths$
ALTER COLUMN new_cases int

-- Select all columns from the "Covid_Deaths$" table where "continent" is not null, and sort by date and total cases

Select *
From Project..Covid_Deaths$
Where continent is not null 
order by 3,4


-- Select location, date, total cases, new cases, total deaths, and population from the "Covid_Deaths$" table and sort by location and date

Select Location, date, total_cases, new_cases, total_deaths, population
From Project..Covid_Deaths$
Where continent is not null 
order by 1,2


-- Select location, date, total cases, total deaths, and death percentage from the "Covid_Deaths$" table and sort by location and date

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Project..Covid_Deaths$
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Project..Covid_Deaths$
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Project..Covid_Deaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Project..Covid_Deaths$
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Project..Covid_Deaths$
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Project..Covid_Deaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From Project..Covid_Deaths$ dea
--Join Project..Covid_Vacinations$ vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

-- The rolling sum of new vaccinations is calculated using the "SUM" function with the "OVER" clause. 
-- The "ROWS BETWEEN" clause limits the window frame to the 100 most recent rows, 
-- reducing the size of the frame to avoid an error related to the window frame size.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date ROWS BETWEEN 99 PRECEDING AND CURRENT ROW) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..Covid_Deaths$ dea
Join Project..Covid_Vacinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- calculates the rolling number of people vaccinated against COVID-19 per location, as well as the percentage of the population 
-- that has been vaccinated, using two tables containing data on COVID-19 deaths and vaccinations by location and date. 
-- The query first defines a Common Table Expression (CTE) that joins the two tables and calculates the rolling number of people vaccinated 
-- using a window function. It then selects all columns from the CTE and calculates the percentage of the population that has been 
-- vaccinated using the rolling number of people vaccinated and the population data from the deaths table.

--With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
--as
--(
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From Project..Covid_Deaths$ dea
--Join Project..Covid_Vacinations$ vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null 
----order by 2,3
--)
--Select *, (RollingPeopleVaccinated/Population)*100
--From PopvsVac



--WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
--  SELECT
--    dea.continent,
--    dea.location,
--    dea.date,
--    dea.population,
--    vac.new_vaccinations,
--    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
--  FROM 
--    Project..Covid_Deaths$ dea
--    JOIN Project..Covid_Vacinations$ vac
--      ON dea.location = vac.location AND dea.date = vac.date
--  WHERE 
--    dea.continent IS NOT NULL 
--)
--SELECT 
--  *,
--  (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
--FROM 
--  PopvsVac
--ORDER BY 
--  Location, 
--  Date;



-- Works after casting as bigint and window frame total size error
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (
            PARTITION BY dea.Location
            ORDER BY dea.date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RollingPeopleVaccinated
    FROM
        Project..Covid_Deaths$ dea
        JOIN Project..Covid_Vacinations$ vac
            ON dea.location = vac.location
            AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL 
)
SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100
FROM
    PopvsVac



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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as RollingPeopleVaccinated
From Project..Covid_Deaths$ dea
Join Project..Covid_Vacinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Create a view called PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated AS
-- Select the continent, location, date, population, new_vaccinations, and the rolling sum of new_vaccinations by location and date
-- and name it RollingPeopleVaccinated
-- Calculate the percentage of RollingPeopleVaccinated over the population and name it PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
    (SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) / dea.population) * 100 AS PercentPopulationVaccinated
FROM 
    Project..Covid_Deaths$ dea
    JOIN Project..Covid_Vacinations$ vac ON dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

