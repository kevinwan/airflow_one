import requests  

import pandas as pd 

from urllib.request import urlopen 

import numpy as np 

import re 

import zipfile 

import os 

import time 

import shutil 

import subprocess 

import psycopg2 

localpath = r'/opt/airflow/DV/Fire_process' 

path=os.chdir(localpath) 

#for file in os.scandir(path): 

    #os.remove(file.path)) 

filetypes = ['shp'] 

dir = r'/opt/airflow/DV/Fire_process' 

files = [[f for f in os.listdir(dir) if f.endswith(type_)] for type_ in filetypes] 

os.environ['PGHOST'] = 'oc2-analytics01.colo1.veros.com' 

os.environ['PGPORT'] = '5432' 

os.environ['PGUSER'] = 'postgres' 

os.environ['PGPASSWORD'] = 'veros110' 

os.environ['PGDATABASE'] = 'DVDEV' 

localpath = r'/usr/bin' 

os.chdir(localpath) 

cmd = 'shp2pgsql -s 0 "/opt/airflow/DV/Fire_process/'+files[0][0]+'" public.Perimeters | psql' 

subprocess.call(cmd, shell=True) 

##Postgres Process 

#establishing the connection 

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

cursor.execute("SELECT public.fire_step_Two()") 

print("Step to replace the FH_Perimeter to fire_shapefile_core table Done... ") 

 

#Condition to check if new fires or existing fire update came in 

if(cursor.execute("select public.fire_step_three()")!=0): 

    #Step to create buffer file 

    cursor.execute("SELECT public.fire_step_Four()") 

    print("Step to create buffer file Done... ") 

     

    #Step to create map core file 

    cursor.execute("SELECT public.fire_step_Five()") 

    print("Step to create map core file Done... ") 

     

    #Step to create map buffer file 

    cursor.execute("SELECT public.fire_step_Six()") 

    print("Step to create map buffer file Done... ") 

     

    #Step to create BKFS fire file 

    cursor.execute("SELECT public.fire_step_seven()") 

    print("Step to create final BKFS file created.. ") 

     

    #Step to create disaster list 

    cursor.execute("SELECT public.fire_step_eight()") 

    print("Step to create final disaster list load... ") 

     

    #Step to generate bkfs fire text file 

    cursor.execute("SELECT public.fire_step_nine()") 

    print("Step to generate fire file... ") 

     
#Commit your changes in the database 

conn.commit() 

#Closing the connection 

conn.close() 
