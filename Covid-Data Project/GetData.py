import pandas as pd
import pyodbc
from sqlalchemy import create_engine
import urllib

url = 'https://covid.ourworldindata.org/data/owid-covid-data.csv'


data = pd.read_csv('Covid-data Project\\owid-covid-data.csv')

CovidDeaths = data.loc[:, ['continent', 'location',
                           'date', 'population', 'total_cases', 'new_cases', 'new_deaths', 'total_deaths']]


CovidVaccinations = data.loc[:, ['continent', 'location',
                                 'date', 'new_tests', 'total_tests', 'new_vaccinations', 'total_vaccinations']]


# Sql Server Part
server = '.'
database = 'CovidPortfolioProject'


params = urllib.parse.quote_plus(
    r'DRIVER={SQL Server};SERVER=.;DATABASE=CovidPortfolioProject;Trusted_Connection=yes')

conn_str = 'mssql+pyodbc:///?odbc_connect={}'.format(params)
engine = create_engine(conn_str)


CovidDeaths.to_sql('CovidDeaths', con=engine, index=False, if_exists='replace')
CovidVaccinations.to_sql('CovidVaccinations', con=engine,
                         index=False, if_exists='replace')
