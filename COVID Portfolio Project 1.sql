Select * 
from PortfolioProject..CovidDeaths 
Where Continent is NOT Null   -- Because we have rows where "Location" is the actual Continent but not Country, having aggregated values for all respective countries, and Continent column for that row is "Null" for them
order by 3,4


Select * 
from PortfolioProject..CovidVaccinations 
Where Continent is NOT Null   
order by 3,4


-- Selecting the sdata that we are going to be using 
Select Location, Date, Total_cases, New_cases, Total_deaths, Population
From PortfolioProject..CovidDeaths
Where Continent is NOT Null   
Order by 1,2


-- Looking at Total Cases VS Total Deaths (Trying to Find % of Deaths out of Total Cases)
-- Showing the likelihood of dying if you contract COVID in your country 
Select Location, Date, Total_cases, Total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%STATES%' and Continent is NOT Null   
Order by 1,2


-- Total Cases VS Population (Trying to Find % of Cases out of Population)
-- Shows what percenatage of population contracted COVID 
Select Location, Date, Population, Total_cases, (total_cases/Population)*100 AS Percentage_of_Population_Affected
From PortfolioProject..CovidDeaths
Where Continent is NOT Null   
--WHERE LOCATION LIKE '%STATES%'
Order by 1,2


-- Countries with Highest Infection Rate compared to Population 
-- Will only look at the Maximum 
Select Location, Population, MAX(Total_cases), MAX(total_cases/Population)*100 AS Percentage_Population_Affected
From PortfolioProject..CovidDeaths
Where Continent is NOT Null   
--WHERE LOCATION LIKE '%STATES%'
Group By Location, Population
Order by Percentage_Population_Affected DESC


-- Continents with Highest Death Count per Population 
Select continent, max(cast(total_deaths as INT)) as Continent_Total_Deaths
From PortfolioProject..CovidDeaths
where continent is NOT Null
Group by continent
Order By Continent_Total_Deaths Desc


select continent, max(cast(total_deaths as int))
From PortfolioProject..CovidDeaths
where continent like '%North America%'
group by continent


select location, max(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
where continent is NUll
group by location
order by total_death_count desc


-- Countries with Highest Death count per Population 
Select Location, MAX(cast(Total_Deaths as int)) as Total_Death_Count   -- Have to CAST it becasue Datatype in TotalDeaths in not INT 
From PortfolioProject..CovidDeaths
Where Continent is NOT Null   
--WHERE LOCATION LIKE '%STATES%'
Group By Location
Order by Total_Death_Count DESC


-- Global Numbers- Toal Cases, Total Deaths, Percentage of Deaths 
Select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is NOT NUll
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------


-- Joining both tables - Deaths and Vaccinations
Select * 
from PortfolioProject..CovidDeaths as Deaths 
Join PortfolioProject..CovidVaccinations as Vaccinations
on  Deaths.location = Vaccinations.location 
AND Deaths.date= Vaccinations.date


-- Total Population VS New Vaccinations on daily basis VS Rolling Vaccination 
Select Deaths.Continent, Deaths.Location, Deaths.date, Deaths.Population, 
cast(Vaccinations.new_vaccinations as int) as Newly_Vaccinated,
Sum(cast(Vaccinations.new_vaccinations as int)) OVER(Partition By Deaths.location order by Deaths.Date) as Rolling_People_Vaccinated
from PortfolioProject..CovidDeaths as Deaths 
Join PortfolioProject..CovidVaccinations as Vaccinations
on  Deaths.location = Vaccinations.location 
AND Deaths.date= Vaccinations.date
where Deaths.continent is not null 
order by 2,3


-- Same as above, but using CTE to find percentage 
With PopulationVSVaccination (Continent, Location, date, Population, Newly_Vaccinated, Rolling_People_Vaccinated)
as
(
Select Deaths.Continent, Deaths.Location, Deaths.date, Deaths.Population, 
cast(Vaccinations.new_vaccinations as int) as Newly_Vaccinated,
Sum(cast(Vaccinations.new_vaccinations as int)) OVER(Partition By Deaths.location order by Deaths.Date) as Rolling_People_Vaccinated
from PortfolioProject..CovidDeaths as Deaths 
Join PortfolioProject..CovidVaccinations as Vaccinations
on  Deaths.location = Vaccinations.location 
AND Deaths.date= Vaccinations.date
where Deaths.continent is not null 
--order by 2,3
)
-- CTE has been created, Now Select all table, and 1 additional column (Percentage)
Select *,  (Rolling_People_Vaccinated/Population)*100 as Rolling_Percentage_People_Vaccinated
from PopulationVSVaccination 


-- Same as above, but using Temp tables instead of CTE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select Deaths.Continent, Deaths.Location, Deaths.date, Deaths.Population, 
cast(Vaccinations.new_vaccinations as int) as Newly_Vaccinated,
Sum(cast(Vaccinations.new_vaccinations as int)) OVER(Partition By Deaths.location order by Deaths.Date) as Rolling_People_Vaccinated
from PortfolioProject..CovidDeaths as Deaths 
Join PortfolioProject..CovidVaccinations as Vaccinations
on  Deaths.location = Vaccinations.location 
AND Deaths.date= Vaccinations.date
where Deaths.continent is not null 
-- Temporary table has been created, Now Select all table, and 1 additional column (Percentage)
Select *,  (Rolling_People_Vaccinated/Population)*100 as Rolling_Percentage_People_Vaccinated
from #PercentPopulationVaccinated 




--Creating View to store data from later visualization 
Create View view_PercentPopulationVaccinated as
Select Deaths.Continent, Deaths.Location, Deaths.date, Deaths.Population, 
cast(Vaccinations.new_vaccinations as int) as Newly_Vaccinated,
Sum(cast(Vaccinations.new_vaccinations as int)) OVER(Partition By Deaths.location order by Deaths.Date) as Rolling_People_Vaccinated
from PortfolioProject..CovidDeaths as Deaths 
Join PortfolioProject..CovidVaccinations as Vaccinations
on  Deaths.location = Vaccinations.location 
AND Deaths.date= Vaccinations.date
where Deaths.continent is not null 


select * from view_PercentPopulationVaccinated 