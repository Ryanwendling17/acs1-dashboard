# %%
import os
from datetime import datetime
import mysql.connector
from sqlalchemy import create_engine
from modules.census_fetch import *
from modules.tools import *

# Read in user inputs config file
user_inputs = read_config('config/user_inputs.yaml')

#%% Fetch user defined acs1 variables
# Set census api parameters
api_key = os.environ.get('census_api_key')
variables_to_fetch = user_inputs['variables_to_fetch']
geographic_level = "state:*"

# Get all years starting from user defined start year up to the current year
current_year = datetime.now().year
years_to_fetch = list(range(user_inputs['acs_start_year'], current_year + 1))

# Fetch data and metadata which contains definitions of the variable codes
result_data, variable_metadata = get_acs1_data(api_key, variables_to_fetch, geographic_level, years_to_fetch)


# %% Wrte the data to MySQL
#Set MySQL Connection Parameters
host = 'localhost'
user = 'root'
password = os.environ.get('mysql_root_pwd')
database = 'acs1_dashboard'

# Create a MySQL connection using sqlalchemy
engine = create_engine(f'mysql+mysqlconnector://{user}:{password}@{host}/{database}')


# Write the dfs to MySQL
result_data.to_sql(name='acs1_api_results', con=engine, if_exists='replace', index=False)
variable_metadata.to_sql(name='acs1_api_results_metadata', con=engine, if_exists='replace', index=False)

# %%
