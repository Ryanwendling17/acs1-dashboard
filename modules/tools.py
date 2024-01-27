import yaml

def read_config(config_path):
    read = open(config_path, 'r')
    data = read.read()
    config_data = yaml.safe_load(data)
    return config_data