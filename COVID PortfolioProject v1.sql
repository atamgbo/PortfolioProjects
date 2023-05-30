/* # Analysis-on-the-global-impact-of-COVID19-disease using SQL
Steps:
Step #1 Data Collection
-the data was collected online on kaggle
Step #2 Data Cleaning
-the data was cleaned in Excel
-treat missing & duplicate data
-look into the data type & values to fix data inconsistency
Step #3 Data Analysis
-likelihood of dying if someone contact covid in the US 
-percentage of population contacted covid in the US 
-countries with highest infection rates compared to population 
-countries with highest death count per population 
-continents with highest death count
-total deaths by date
-world total deaths
-total population vaccinated by location
-analysis using CTE
-Step #4 Data Vissualization
-the visualization can be found in my Tableau link (https://public.tableau.com/app/profile/atamgbo.ayuwu/viz/Covid-19Dashboard_16351836180290/Dashboard1)
Step #5 Conclusion
-in August 2021, Covid-19 population infection was forecasted to be on a continuous rise. As of August 2021, United States had the highest infection rate but United Kingdom was projected to have the highest infection cases by an average of 19.05% one year later.
-covid-19 has accounted for a total death rate of 4.9 million people which is 2.3% of the total cases reported globally between December 2019 and August 2021
-Europe, North America and South America were the most affected by Covid-19
*/
--BY LOCATION
Select*
From PortfolioP..COVID_Deaths$
Where continent is not null
order by 3,4

--Select*
--From PortfolioProject..COVID_Vaccinations
--order by 3,4

--Select first set of data to be used

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioP..COVID_Deaths$
Where continent is not null
order by 1,2

--Total cases vs Total deaths
--Shows the likelihood of dying if you contact covid in the US

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioP..COVID_Deaths$
Where Location like '%states%'
order by 1,2

--Total cases vs population
--Shows percentage of population contacted covid in the US

Select Location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
From PortfolioP..COVID_Deaths$
Where location like '%states%'
order by 1,2

--Countries with highest infection rates compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasePercentage
From PortfolioP..COVID_Deaths$
Where continent is not null
Group by Location, population
order by CasePercentage desc

--Countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioP..COVID_Deaths$
Where continent is not null
Group by Location
order by TotalDeathCount desc


--BY CONTINENT

--Continents with highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioP..COVID_Deaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Total deaths by date
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioP..COVID_Deaths$
Where continent is not null
Group by date
order by 1,2

--World total deaths 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioP..COVID_Deaths$
Where continent is not null
order by 1,2

Select*
From PortfolioP..COVID_Deaths$ dea
Join PortfolioP..COVID_Vaccinations$ vac
    On dea.location = vac.location
	and dea.date = vac.date

--Total population vaccinated by location

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioP..COVID_Deaths$ dea
Join PortfolioP..COVID_Vaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Using CTE

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioP..COVID_Deaths$ dea
Join PortfolioP..COVID_Vaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
)
Select*
From PopvsVac


--TEMP TABLE 

Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioP..COVID_Deaths$ dea
Join PortfolioP..COVID_Vaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null

Select*, (RollingPeopleVaccinated/Population)*100 as PercentageRollingPeopleVaccinated
From #PercentagePopulationVaccinated



--Creating View for vizualization purpose

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioP..COVID_Deaths$ dea
Join PortfolioP..COVID_Vaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

Select*
From PercentagePopulationVaccinated
