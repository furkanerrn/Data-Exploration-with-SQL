select * 
from Portfolio_Project..Covid_Deaths$
where continent is not null
order by 3,4


-- Select that we are gonna be using
select location,date,total_cases,new_cases,total_deaths,population
from Portfolio_Project..Covid_Deaths$ 
where continent is not null
order by 1,2

-- Looking at Total Cases vs. Total Deaths
--Shows likelihood - Olasýlýk
select location,date,new_cases,total_cases,total_deaths,(total_deaths/total_cases)*100 [Death Percentage]
from Portfolio_Project..Covid_Deaths$ 
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid 
select location,date,total_cases,total_deaths,population,(total_cases/population)*100 Death_Percentage
from Portfolio_Project..Covid_Deaths$ 
where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection rate Compared to Population
select location,population,max(total_cases) [Highest Infection Count],max((total_cases/population))*100 as PercentPopulationInfected
from Portfolio_Project..Covid_Deaths$ 
where continent is not null --not to show the continent calculations
group by location,population
order by PercentPopulationInfected desc

-- Cast Issue
select max(cast(total_deaths as int))
from ..Covid_Deaths$
where location like ('%bosnia%')

select max(total_deaths )
from ..Covid_Deaths$
where location like ('%bosnia%')

-- Showing Countries with Highest Death Count per Population
select location,max(cast(total_deaths as int)) [Total Death Count] 
--total death data type is nvarchar.We need to read it as ..
-- --numeric because of aggregate expressions.So we need to convert it to int by using cast
from Portfolio_Project..Covid_Deaths$ 
where continent is not null
group by location
order by [Total Death Count] desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
select location,max(cast(total_deaths as int)) [Total Death Count] 
--total death data type is nvarchar.We need to read it as ..
-- --numeric because of aggregate expressions.So we need to convert it to int by using cast
from Portfolio_Project..Covid_Deaths$ 
where continent is  null
group by location
order by [Total Death Count] desc

--Removing income sections
select location,max(cast(total_deaths as int)) [Total Death Count] 
from Portfolio_Project..Covid_Deaths$ 
where continent is  null and location not in ('middle income','Lower middle income','Upper middle income','low income','high income')
group by location
order by [Total Death Count] desc

--Showing the Contintents with the highest death per population
select continent,max(cast(total_deaths as int)) [Total Death]
from ..Covid_Deaths$ 
where location not in ('middle income','Lower middle income','Upper middle income','low income','high income') and continent is not null
group by continent
order by [Total Death] desc

--GLOBAL NUMBERS
select date Date,sum(new_cases) as [New Cases],
sum(cast(new_deaths as int)) as [New Deaths],
sum(cast(new_deaths as int))/sum(new_cases)*100 [Death Percentage]
from ..Covid_Deaths$
where continent is not null 
group by date 
order by 1,2

-- TOTAL
SELECT sum(new_cases) as [New Cases],
sum(cast(new_deaths as int)) as [New Deaths],
sum(cast(new_deaths as int))/sum(new_cases)*100 [Death Percentage]
from ..Covid_Deaths$
where continent is not null 
order by 1,2


-- Vaccinations
select * 
from Portfolio_Project..Covid_Deaths$ dea
join Portfolio_Project..Covid_Vaccinations$ vac
on dea.date=vac.date 
and dea.location=vac.location


--Looking at Total Population vs Vaccinations
select dea.continent,dea.location,dea.date,vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) Total_Vaccination
--,(Total_Vaccination/population)/100
from Portfolio_Project..Covid_Deaths$ dea
join Portfolio_Project..Covid_Vaccinations$ vac
on dea.date=vac.date 
and dea.location=vac.location
where dea.continent is not null and dea.location='Turkey'
order by 2,3

--USING CTE
with popvsvac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) RollingPeopleVaccinated
from Portfolio_Project..Covid_Deaths$ dea
join Portfolio_Project..Covid_Vaccinations$ vac
on dea.location=vac.location
and  dea.date=vac.date 
where  dea.continent is not null and dea.location='France'
)
select *,(RollingPeopleVaccinated/population)*100 
from popvsvac
order by location,date

--USING TEMP TABLE
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) RollingPeopleVaccinated
from Portfolio_Project..Covid_Deaths$ dea
join Portfolio_Project..Covid_Vaccinations$ vac
on dea.location=vac.location
and  dea.date=vac.date 
where  dea.continent is not null and dea.location='France'

select *,(RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated
order by location,date


--USING VIEW
create view PercentPopulationVaccinated2
as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) RollingPeopleVaccinated
from Portfolio_Project..Covid_Deaths$ dea
join Portfolio_Project..Covid_Vaccinations$ vac
on dea.location=vac.location
and  dea.date=vac.date 
where  dea.continent is not null and dea.location='France'
       
select * from PercentPopulationVaccinated2
