import requests  

import pandas as pd 

from urllib.request import urlopen 

import numpy as np 

import re 

import zipfile 

import os, sys, tarfile 

import time 

import shutil 

import subprocess 

import psycopg2 

#localpath = r'E:\DV\Flood_Auto_process' 
localpath = r'/opt/airflow/DV/Flood_Auto_process' 

path=os.chdir(localpath) 

for file in os.scandir(path): 

    os.remove(file.path) 

def download(url: str, dest_folder: str): 

    if not os.path.exists(dest_folder): 

        os.makedirs(dest_folder)  # create folder if it does not exist 

    filename = 'national_shapefile_obs.tgz'  # be careful with file names 

    file_path = os.path.join(dest_folder, filename) 

    r = requests.get(url, stream=True) 

    if r.ok: 

        print("saving to", os.path.abspath(file_path)) 

        with open(file_path, 'wb') as f: 

            for chunk in r.iter_content(chunk_size=1024 * 8): 

                if chunk: 

                    f.write(chunk) 

                    f.flush() 

                    os.fsync(f.fileno()) 

    else:  # HTTP status code 4XX/5XX 

        print("Download failed: status code {}\n{}".format(r.status_code, r.text)) 

# data source: https://water.weather.gov/ahps/download.php

download('https://water.weather.gov/ahps/download.php?data=tgz_obs', dest_folder=localpath) 

os.chdir(localpath) 

arr = os.listdir(path) 

varc ='Flood_Shape_file_'+time.strftime('%Y%m%d')+'.tgz' 

print(varc) 

#dest = shutil.move(source, destination, copy_function = shutil.copytree) 

# open file 

file = tarfile.open('national_shapefile_obs.tgz')  

# extracting file 

file.extractall('.')   

file.close() 

#os.environ['PGHOST'] = 'localhost' 
os.environ['PGHOST'] = 'oc2-analytics01.colo1.veros.com' 

os.environ['PGPORT'] = '5432' 

os.environ['PGUSER'] = 'postgres' 

os.environ['PGPASSWORD'] = 'veros110' 

#os.environ['PGDATABASE'] = 'Disaster_Vision_DB' 
os.environ['PGDATABASE'] = 'DVDEV' 

# wont need postgres\bin under linux postgres container 
#localpath = r'C:\Program Files\PostgreSQL\9.6\bin' 

os.chdir(localpath) 

#cmd = 'shp2pgsql -s 0 "E:/DV/Flood_Auto_process/national_shapefile_obs.shp" public.national_shapefile_obs | psql' 

cmd = 'shp2pgsql -s 0 "/opt/airflow/DV/Flood_Auto_process/national_shapefile_obs.shp" public.national_shapefile_obs | psql' 

subprocess.call(cmd, shell=True) 

##Postgres Process 

#establishing the connection 

# shutil.move('E:/DV/Flood_Auto_process/national_shapefile_obs.tgz', 'E:/DV/Flood_archive/'+varc,copy_function = shutil.copytree) 
# shutil.move('/opt/airflow/DV/Flood_Auto_process/national_shapefile_obs.tgz', '/opt/airflow/DV/Flood_archive/'+varc,copy_function = shutil.copytree) 

conn = psycopg2.connect( 

    host="oc2-analytics01.colo1.veros.com",

    database="DVDEV", 

    user="postgres", 

    password="veros110",port= '5432') 

#Setting auto commit false 

conn.autocommit = True 

#Creating a cursor object using the cursor() method 

cursor = conn.cursor() 

#Step to load fire_shapefile_core_historic table 

#cursor.execute("SELECT public.fire_step_One()") 

#print("Step to load fire_shapefile_core_historic table Done... ") 

#Step to replace the FH_Perimeter to fire_shapefile_core table 

cursor.execute("SELECT public.flood_core_process_step()") 

if(cursor.execute("select public.flood_step_three()")!=0): 

    #Step to process core file 

    cursor.execute("SELECT public.flood_map_core()") 

    print("Step to process code file Done... ") 

    #Step to create final BKFS file 

    cursor.execute("SELECT public.flood_bkfs_file()") 

    print("Step to create final BKFS file Done... ") 

else:cursor.execute("SELECT public.flood_bkfs_file_next()") 

cursor.execute("SELECT public.flood_bkfs_file_extract()") 

print("Step to create bkfs flood file extract... ") 

#Commit your changes in the database 

conn.commit() 

#Closing the connection 

conn.close() 