Select *
From [Portfolio_Project_2022-11-06]..CovidDeaths
Where continent is not null
Order by 3,4


-- Looking at countries with percentage of deaths
-- Likelihood of dying if you had covid in USA
/*Select location, total_cases, total_deaths, date, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio_Project_2022-11-06]..CovidDeaths
Where location like '%states%'
Order by 1,2
*/

-- Looking at countries with the highest infection rate compared to population

/*Select location, total_cases, total_deaths, date, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio_Project_2022-11-06]..CovidDeaths
Where location like '%africa%'
Order by 1,2
*/

-- Looking at the total cases vs population
-- Shows what % of population got covid
/*Select location, date, total_cases, Population, (total_deaths/Population)*100 as DeathPercentage_out_of_Population
From [Portfolio_Project_2022-11-06]..CovidDeaths
Where location like '%states%'
Order by 1,2
*/

-- Countries with the highest infection rate with population
/*Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentagePopulationInfected
From [Portfolio_Project_2022-11-06]..CovidDeaths
--Where location like '%states%'

Group by location, population
Order by PercentagePopulationInfected desc

*/

-- Showing countries with Highest Death Count



Select Location, MAX(cast(total_deaths as int)) as TotalDeathsCount 
From [Portfolio_Project_2022-11-06]..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathsCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathsCount 
From [Portfolio_Project_2022-11-06]..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathsCount desc

Select location, MAX(cast(total_deaths as int)) as TotalDeathsCount 
From [Portfolio_Project_2022-11-06]..CovidDeaths
Where location is not null
Group by location
Order by TotalDeathsCount desc

--GLOBAL NUMBERS

Select date, SUM(cast(new_deaths as int)), SUM(new_cases)
From [Portfolio_Project_2022-11-06]..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

Select date, SUM(cast(new_deaths as int)) as total_deaths, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio_Project_2022-11-06]..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

Select SUM(cast(new_deaths as int)) as total_deaths, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio_Project_2022-11-06]..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2



--- JOINING TWO TABLES
Select *
From [Portfolio_Project_2022-11-06]..CovidDeaths dea
Join [Portfolio_Project_2022-11-06]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

--- LOOK AT TOAL POPULATION VS VACCINATION

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100   -- this throws an error so I need to make a temp table (explained later)
From [Portfolio_Project_2022-11-06]..CovidDeaths dea
Join [Portfolio_Project_2022-11-06]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3                           --------- DID NOT WORK FOR ME NEED TO TAKE A LOOK

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Portfolio_Project_2022-11-06]..CovidDeaths dea
Join [Portfolio_Project_2022-11-06]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--- CHARM OF THE SHOW (EMP TABLE)

--- USE CTE

With PopvsVac(Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100   -- this throws an error so I need to make a temp table (explained later)
From [Portfolio_Project_2022-11-06]..CovidDeaths dea
Join [Portfolio_Project_2022-11-06]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3  
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated  -- after changing a parameter it would throw an error so use this statement
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
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100   -- this throws an error so I need to make a temp table (explained later)
From [Portfolio_Project_2022-11-06]..CovidDeaths dea
Join [Portfolio_Project_2022-11-06]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3  


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for viz

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100   -- this throws an error so I need to make a temp table (explained later)
From [Portfolio_Project_2022-11-06]..CovidDeaths dea
Join [Portfolio_Project_2022-11-06]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3  
