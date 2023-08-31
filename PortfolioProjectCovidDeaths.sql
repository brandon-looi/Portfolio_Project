select * from PortfolioProject.dbo.CovidDeaths
where continent is not null

--select location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject.dbo.CovidDeaths

-- Total Cases vs Total Death
/* select location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/ CONVERT(float,total_cases))*100 as Death_Pecentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states'
and continent is not null
order by 1,2 */

-- Total Cases vs Population in Percentage
select location, date, population, total_cases, (CONVERT(float,total_cases)/ CONVERT(float,population))*100 as Percentage_CasesvsPopulation
from PortfolioProject.dbo.CovidDeaths
where location like '%states'
and continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population in Percentage
select location, population, max(total_cases) as Highest_Infection_Count, (max(total_cases)/max(population)) *100 as Percentage_Population_Infected
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location, population
order by Percentage_Population_Infected desc

-- Countries with Highest Death Count per Population
select location, population, max(convert(int, total_deaths )) as Total_Deaths_Count
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location, population
order by Total_Deaths_Count desc

-- By Continent
select continent, max(convert(int, total_deaths )) as Total_Deaths_Count
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by Total_Deaths_Count desc


-- Global Numbers
select  sum(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, (sum(new_deaths)/nullif(sum(new_cases),0))*100 as Death_Percentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, sum_new_vaccinations) as(
-- Total Populationi vs Vaccinations
select d.continent, d.location, d.date, population, v.new_vaccinations, SUM(cast(v.new_vaccinations as bigint)) over ( partition by d.location order by d.location, d.date) as sum_new_vaccinations
from PortfolioProject.dbo.CovidDeaths as D
join PortfolioProject.dbo.CovidVaccination as V on D.location = V.location
and D.date = V.date
where d.continent is not null
)
select *, (sum_new_vaccinations/population)*100
from PopvsVac


-- TEMP Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated (
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	sum_new_vaccinations numeric
)

insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, population, v.new_vaccinations, SUM(cast(v.new_vaccinations as bigint)) over ( partition by d.location order by d.location, d.date) as sum_new_vaccinations
from PortfolioProject.dbo.CovidDeaths as D
join PortfolioProject.dbo.CovidVaccination as V on D.location = V.location
and D.date = V.date
--where d.continent is not null

select *, (sum_new_vaccinations/population)*100
from #PercentPopulationVaccinated


-- Create view to store data for visualizations

use PortfolioProject
go
create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, population, v.new_vaccinations, SUM(cast(v.new_vaccinations as bigint)) over ( partition by d.location order by d.location, d.date) as sum_new_vaccinations
from PortfolioProject.dbo.CovidDeaths as D
join PortfolioProject.dbo.CovidVaccination as V on D.location = V.location
and D.date = V.date
where d.continent is not null