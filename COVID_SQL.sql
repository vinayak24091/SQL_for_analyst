select * 
from SQL..CovidDeaths$
where continent is not null
order by 3,4

select * 
from SQL..CovidVaccinations$
where continent is not null
order by 3,4

--select data that we are going to be using
select location,date,population,total_cases,new_cases,total_deaths
from SQL..CovidDeaths$
where continent is not null
order by 1,2


-- looking at total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DEATHPERCENTAGE
from SQL..CovidDeaths$
where location like '%india' and continent is not null
order by 1,2

-- looking at total cases vs population
select location,date,total_cases,population,(total_cases/population)*100 as INFECTED_PERCENTAGE
from SQL..CovidDeaths$
where continent is not null
order by 1,2

-- looking at which country has the highest infection rate 
select location, MAX(total_cases) as higestinfectioncount,population,MAX((total_cases/population))*100 as infection_rate
from SQL..CovidDeaths$
where continent is not null
group by population,location
order by infection_rate desc

-- looking at countries with highest death count
select location,MAX (CAST(total_deaths AS INT)) as TOTAL_DEATH_COUNT
from SQL..CovidDeaths$
where continent is not null
group by location
order by TOTAL_DEATH_COUNT desc

-- breaking up by CONTINENTS
select location,MAX (CAST(total_deaths AS INT)) as TOTAL_DEATH_COUNT
from SQL..CovidDeaths$
where continent is null
group by location
order by TOTAL_DEATH_COUNT desc

-- GLOBAL COVID NUMBERS

select SUM(new_cases)as TOTAL_CASES,SUM(cast(new_deaths as int))as TOTAL_DEATHS,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DEATH_PERCENTAGE
from SQL..CovidDeaths$
where continent is not null
order by 1,2


--looking at TOTAL POPULATION vs VACCINATION
 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as ROLLINGPEOPLEVACCINATED 
from SQL..CovidVaccinations$ vac
join SQL..CovidDeaths$ dea
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null 
 
 -- USE CTE
 with PopvsVac (continent,Location,date,population,New_vaccinations,ROLLINGPEOPLEVACCINATED)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as ROLLINGPEOPLEVACCINATED 
from SQL..CovidVaccinations$ vac
join SQL..CovidDeaths$ dea
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null 
 )
 select *,(ROLLINGPEOPLEVACCINATED/Population)*100 as _Percent
 from PopvsVac 

 -- Temp Table
 create table #PercentPopulationVaccinated
 (
 Continent nvarchar(225),
 Location nvarchar(225),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 ROLLINGPEOPLEVACCINATED numeric
 )


 Insert into #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as ROLLINGPEOPLEVACCINATED 
from SQL..CovidVaccinations$ vac
join SQL..CovidDeaths$ dea
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null

  select *,(ROLLINGPEOPLEVACCINATED/Population)*100 as _Percent
 from #PercentPopulationVaccinated
   