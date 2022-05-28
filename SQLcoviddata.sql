--Select Data that we are going to be using. 

Select location,date,total_cases,new_cases,total_deaths,population
from portfolioproject..coviddeaths
order by 1,2

-- Total Cases versus Total Deaths United States

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from portfolioproject..coviddeaths
where location like '%states%'
order by 1,2

--looking at total cases versus population.
--Shows what percentage of population got covid in United States

Select location,date,population,total_cases,(total_cases/population)*100 as Poppercwithcovid
from portfolioproject..coviddeaths
where location like '%states%'
order by 1,2

-- Looking at countries with highest percentage infection rate

Select location,population,MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as highestpercentagecount
from portfolioproject..coviddeaths
Group by location,population
Order by highestpercentagecount desc

--Countries with highest death count per population

Select location,population,MAX(total_deaths) as highestdeathcount, MAX((total_deaths/population))*100 as highestpercentagedeath
from portfolioproject..coviddeaths
Group by location,population
Order by highestpercentagedeath desc

--Countries with highest total deaths

Select location,MAX(cast(total_deaths as INT)) as totaldeathcount
from portfolioproject..coviddeaths
Where continent is not null
Group by location
Order by totaldeathcount desc

-- Highest death count by continent

Select continent,MAX(cast(total_deaths as INT)) as totaldeathcount
from portfolioproject..coviddeaths
Where continent is not null
Group by continent
Order by totaldeathcount desc


-- Global Number per date

Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as INT)) as total_deaths,SUM(cast(new_deaths as INT))/Sum(new_cases)*100 as death_percentage
from portfolioproject..coviddeaths
Where continent is not null
group by date
order by 1,2

-- Global numbers total

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as INT)) as total_deaths,SUM(cast(new_deaths as INT))/Sum(new_cases)*100 as death_percentage
from portfolioproject..coviddeaths
Where continent is not null
order by 1,2

-- Total amount population versus vaccination

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as rollingtotalvaccinations
From portfolioproject..coviddeaths dea
Join portfolioproject..covidvax vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Use CTE

WITH popvsvac (continent, location, date, population,new_vaccinations,rollingtotalvaccinations)
AS
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as rollingtotalvaccinations
From portfolioproject..coviddeaths dea
Join portfolioproject..covidvax vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (rollingtotalvaccinations/population)*100 as rollingpercentagevac
FROM popvsvac


-- Temp Table

DROP table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rollingtotalvaccinations numeric)

INSERT INTO  #percentpopulationvaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as rollingtotalvaccinations
From portfolioproject..coviddeaths dea
Join portfolioproject..covidvax vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
Order by 2,3

Select *, (rollingtotalvaccinations/population)*100 as rollingpercentagevac
FROM #percentpopulationvaccinated

--Creating view for table. 

create view percpopvac as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as rollingtotalvaccinations
From portfolioproject..coviddeaths dea
Join portfolioproject..covidvax vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

select * from percpopvac