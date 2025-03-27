SELECT *
FROM projeto_portifolio..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM projeto_portifolio..CovidVaccinations
--order by 3,4

-- Selecionando os dados que vamos usar

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM projeto_portifolio..CovidDeaths
order by 1,2

-- Olhando para Total Cases vs Total Deaths
-- Mostra a possibilidade de morte caso você contraia COVID no seu país

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM projeto_portifolio..CovidDeaths
WHERE location like '%brazil%' and continent is not null
order by 1,2

-- Olhando para Total Cases vs Population
-- Mostra qual a porcentagem da população contraiu COVID
SELECT Location, date, Population, total_cases, (total_cases/population)*100 as infection_percentage
FROM projeto_portifolio..CovidDeaths
WHERE location like '%brazil%' and continent is not null
order by Location, Date --mesma coisa que colocar order by 1,2

-- Vendo os países com as maiores taxas de infecção comparado a população

SELECT Location, Population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as infection_percentage
FROM projeto_portifolio..CovidDeaths
WHERE continent is not null
Group by Location, Population
order by infection_percentage DESC

-- VAMOS DIVIDIR AGORA POR CONTINENTE

-- Mostrando os continentes com as maiores taxas de morte por população

SELECT continent, MAX(cast(total_deaths as int)) as total_death_count
FROM projeto_portifolio..CovidDeaths
WHERE continent is not null
Group by continent
order by total_death_count DESC

-- NÚMEROS GLOBAIS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage

FROM projeto_portifolio..CovidDeaths
--WHERE location like '%brazil%' 
WHERE continent is not null
--Group by date
order by 1,2

-- Vendo o total de população vs vacinação

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM projeto_portifolio..CovidDeaths dea JOIN projeto_portifolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- Usar CTE

With PopvsVac (Continent, location, date, population, New_Vaccinations, rolling_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM projeto_portifolio..CovidDeaths dea JOIN projeto_portifolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM PopvsVac
order by 2,3

--TEMP TABLE

DROP Table if exists #percentage_population_vaccinated
Create table #percentage_population_vaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
rolling_people_vaccinated numeric 
)

Insert into #percentage_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM projeto_portifolio..CovidDeaths dea JOIN projeto_portifolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (rolling_people_vaccinated/population)*100
FROM #percentage_population_vaccinated
order by 2,3

-- CRIANDO ALGUMAS EXIBIÇÕES PARA GUARDAR DADOS E VISUALIZAR DEPOIS


USE projeto_portifolio;
GO
Create View rolling_population_vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM projeto_portifolio..CovidDeaths dea JOIN projeto_portifolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


-- Mostra qual a porcentagem da população contraiu COVID
USE projeto_portifolio;
GO

Create View infection_percentage_brazil as
SELECT Location, date, Population, total_cases, (total_cases/population)*100 as infection_percentage
FROM projeto_portifolio..CovidDeaths
WHERE location like '%brazil%' and continent is not null
--order by Location, Date --mesma coisa que colocar order by 1,2


-- Mostrando os continentes com as maiores taxas de morte por população
USE projeto_portifolio;
GO

Create View total_death_count as
SELECT continent, MAX(cast(total_deaths as int)) as total_death_count
FROM projeto_portifolio..CovidDeaths
WHERE continent is not null
Group by continent
--order by total_death_count DESC

-- Vendo os países com as maiores taxas de infecção comparado a população
USE projeto_portifolio;
GO

Create View infection_percentage as
SELECT Location, Population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as infection_percentage
FROM projeto_portifolio..CovidDeaths
WHERE continent is not null
Group by Location, Population
--order by infection_percentage DESC