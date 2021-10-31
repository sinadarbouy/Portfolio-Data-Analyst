/*
Covid Data Exploration 
*/


--How many continent we have
Select location from CovidPortfolioProject..CovidDeaths
	where continent is null
		group by location
			order by location

-- What Data we need in Covid Deaths
Select Location, date, total_cases, new_cases, total_deaths, population
	From CovidPortfolioProject..CovidDeaths
		Where continent is not null 
			order by 1,2


-- Death VS Cases
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	From CovidPortfolioProject..CovidDeaths
		Where location = 'iran' -- like '%%'
		and continent is not null  -- for explore just country
			order by 1,2  -- order  by location,Date



-- Total Cases VS Population
Select Location, date, [Population], total_cases,  (total_cases/[Population])*100 as PercentPopulationInfected
	From CovidPortfolioProject..CovidDeaths
		Where location = 'iran' -- like '%%'
			order by 1,2


-- Highest Infection in world
Select Location, [Population], MaX(total_cases) as Highest_Cases,  Max(total_cases/[Population])*100 as PercentPopulationInfected
	From CovidPortfolioProject..CovidDeaths
		Where continent is not null 
			Group by Location, Population
				order by 4 desc



--Highest Deaths in World Base Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount, MAX(( cast(Total_deaths as int)/population)*100) as DeathPercentageBasePopulation
	From CovidPortfolioProject..CovidDeaths
		Where continent is not null 
			Group by Location
				order by DeathPercentageBasePopulation desc


-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
	From CovidPortfolioProject..CovidDeaths
		where continent is not null 
			order by 1,2



-- Total Population vs Vaccinations

Select d.continent, d.[location], d.[date], d.[population], vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by d.[location] Order by d.[location], d.[date]) as RollingPeopleVaccinated
	From CovidPortfolioProject..CovidDeaths d
	Join CovidPortfolioProject..CovidVaccinations vac
		On d.[location] = vac.[location]
		and d.[date] = vac.[date]
			where d.continent is not null 
				order by 2,3


-- Using CTE to use temp column

With T (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
	Select d.continent, d.[location], d.[date], d.[population], vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by d.[location] Order by d.[location], d.[date]) as RollingPeopleVaccinated
		From CovidPortfolioProject..CovidDeaths d
		Join CovidPortfolioProject..CovidVaccinations vac
			On d.[location] = vac.[location]
			and d.[date] = vac.[date]
				where d.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From T


-- Using Temp Table V1  in previous query


DROP Table if exists #PeopleVaccinated

	Select d.continent, d.[location], d.[date], d.[population], vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by d.[location] Order by d.[location], d.[date]) as RollingPeopleVaccinated
	into #PeopleVaccinated
		From CovidPortfolioProject..CovidDeaths d
		Join CovidPortfolioProject..CovidVaccinations vac
			On d.[location] = vac.[location]
			and d.[date] = vac.[date]
				where d.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100
From #PeopleVaccinated






-- Using Temp Table V2  in previous query

DROP Table if exists #PeopleVaccinated
Create Table #PeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population int,
New_vaccinations int,
RollingPeopleVaccinated int
)

Insert into #PeopleVaccinated
	Select d.continent, d.[location], d.[date], d.[population], vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by d.[location] Order by d.[location], d.[date]) as RollingPeopleVaccinated
		From CovidPortfolioProject..CovidDeaths d
		Join CovidPortfolioProject..CovidVaccinations vac
			On d.[location] = vac.[location]
			and d.[date] = vac.[date]
				where d.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100
From #PeopleVaccinated


-- create View for later visualizations


use CovidPortfolioProject

Create View PercentPopulationVaccinated as
(
	Select d.continent, d.[location], d.[date], d.[population], vac.new_vaccinations
		, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by d.[location] Order by d.[location], d.[date]) as RollingPeopleVaccinated
			From CovidPortfolioProject..CovidDeaths d
			Join CovidPortfolioProject..CovidVaccinations vac
				On d.[location] = vac.[location]
				and d.[date] = vac.[date]
					where d.continent is not null 
)
 

Create view Total_Cases as (

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
	From CovidPortfolioProject..CovidDeaths
		where continent is not null 
)




Create view TotalDeathCount as (
	Select location,SUM(cast(new_deaths as int)) as TotalDeathCount
	from CovidPortfolioProject..CovidDeaths
	where continent is not null
		and location not in ('World', 'European Union', 'International')
		group by location
)




Create view Infection As (
	Select Location, [Population], MaX(total_cases) as Highest_Cases,  Max(total_cases/[Population])*100 as PercentPopulationInfected
		From CovidPortfolioProject..CovidDeaths
			Where continent is not null 
				Group by Location, Population
)



Create view Infection_WithDate as (
	Select Location, [Population],date, MaX(total_cases) as Highest_Cases,  Max(total_cases/[Population])*100 as PercentPopulationInfected
		From CovidPortfolioProject..CovidDeaths
			Where continent is not null 
				Group by Location, Population,date
)

