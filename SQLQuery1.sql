select * from PortfolioProject..CovidVaccinations where continent is not null order by 3,4 ;

--select * from PortfolioProject..CovidDeaths order by 3,4;

--select Data that we are going to be using -->

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2;

-- Looking at total cases vs total deaths
select location, date, total_cases, total_deaths, (Total_deaths / total_cases ) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'France'
order by 1,2;

--looking at the total cases  vs population 
--percentage or population who had Covid
select location, date, population, total_cases, (total_cases / population ) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'France'
order by 1,2;


-- looking at countries with highest infection rate compared to population
select location, population, Max(total_cases) as highestInfectionCount, Max((total_cases / population)) * 100 as percentOfPopulationAffected
from PortfolioProject..CovidDeaths
group by location, population
order by percentOfPopulationAffected desc;

--Showing the countries with the highest death count per population
select location, max( cast (total_deaths as int)) as totalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by totaldeathcount desc;

--Par continent

select location, max(cast(total_deaths as int)) as totalDeathCountByContinent
from PortfolioProject..CovidDeaths
where continent is  null
group by location
order by totalDeathCountByContinent desc;

--Montre els continents avec le plus de morts

select continent, max(cast(total_deaths as int)) as totalDeathCountByContinent
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by totalDeathCountByContinent desc;



-- global numbers

select  date, sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int)) / sum(New_Cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date 
order by 1,2;


--looking at total population vs vaccination
select * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..covidVaccinations vac
on dea.location = vac.location and dea.date = vac.date


--looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..covidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
order by 2,3;


-- utilisation de Common Table Expression

with PopvsVac(continent,location,date,population,new_vaccinations,rollingPeolpleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..covidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *, (rollingPeolpleVaccinated/ population)*100
from PopvsVac

--
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..covidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

--creating view to store data for later visualisations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..covidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated