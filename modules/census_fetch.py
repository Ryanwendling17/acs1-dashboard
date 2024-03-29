import requests
import pandas as pd
from concurrent.futures import ThreadPoolExecutor

def get_variable_metadata(api_key, variable_code, year):
    # Use the variable metadata endpoint to get variable metadata
    base_url = f"https://api.census.gov/data/{year}/acs/acs1/variables/{variable_code}.json"
    url = f"{base_url}?key={api_key}"

    response = requests.get(url)

    if response.status_code == 200:
        try:
            data = response.json()
            variable_metadata = {
                'variable_name': variable_code,
                'label': data['label'],
                'concept': data['concept'],
                'year': year
            }
            return variable_metadata
        except Exception as e:
            print(f"Error processing variable metadata for {variable_code} in {year}: {e}")
            return {'variable_name': variable_code}
    else:
        print(f"Error fetching variable metadata for {variable_code}: {response.status_code}")
        try:
            error_message = response.json()['message']
            print(f"Error message: {error_message}")
        except Exception as e:
            print(f"Error processing JSON for error message: {e}")
        return {'variable_name': variable_code}

def get_acs1_data(api_key, variables, level, years):
    # Generate metadata for each variable
    metadata_list = []

    for year in years:
        # Generate metadata for each variable
        metadata = [get_variable_metadata(api_key, variable, year) for variable in variables]
        metadata_list.extend(metadata)

    def fetch_data(year):
        base_url = f"https://api.census.gov/data/{year}/acs/acs1"

        params = {
            "get": ",".join(variables),
            "for": level,
            "key": api_key
        }

        response = requests.get(base_url, params=params)

        if response.status_code == 200:
            try:
                data = response.json()
                result = [dict(zip(variables, row)) for row in data[1:]]
                df = pd.DataFrame(result)
                df['Year'] = year  
                return df
            except Exception as e:
                print(f"Error processing JSON for {year}: {e}")
                return pd.DataFrame()
        else:
            print(f"Error fetching data for {year}: {response.status_code}")
            try:
                error_message = response.json()['message']
                print(f"Error message: {error_message}")
            except Exception as e:
                print(f"Error processing JSON for error message: {e}")
            return pd.DataFrame()

    dfs = []

    with ThreadPoolExecutor() as executor:
        # Use concurrent.futures.ThreadPoolExecutor to parallelize the data fetching
        futures = [executor.submit(fetch_data, year) for year in years]

        for future in futures:
            try:
                result_df = future.result()
                if not result_df.empty:
                    dfs.append(result_df)

            except Exception as e:
                print(f"Error processing future: {e}")

    if dfs:
        result_df = pd.concat(dfs, ignore_index=True)
    else:
        result_df = pd.DataFrame()  # Return an empty DataFrame

    metadata_df = pd.DataFrame(metadata_list)

    # Remove NAME (we know this one...) and years missing data
    metadata_df = metadata_df[(metadata_df['variable_name'] != 'NAME') & (metadata_df['year'].notnull())]
    

    return result_df, metadata_df


