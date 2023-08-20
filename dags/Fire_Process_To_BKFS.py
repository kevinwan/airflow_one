from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.dummy import DummyOperator

PY_SCRIPT_PATH='/opt/airflow/DV/bkfs_dev/fireBKFS.py'

default_args = {
    'owner': 'kwan',
    'retries': 3,
    'retry_delay': timedelta(minutes=30)
}

with DAG(
    default_args=default_args,
    dag_id="Fire_Process_To_BKFS",
    start_date=datetime(2023, 8, 15),
    schedule_interval='0 17 * * Mon-Sun'
) as dag:
    
    task1 = DummyOperator(
        task_id='Download_NIFC_Shapefile'
        )
    
    task2 = BashOperator(
        task_id='Load_Shapefile_To_Postgres',
        bash_command= f"python {PY_SCRIPT_PATH}"
    )

    task3 = DummyOperator(
        task_id='Transfer_Shape_to_Geometry'
        )
    
    task4 = DummyOperator(
        task_id='Check_AVS_Address_tables'
        )
    
    task5 = DummyOperator(
        task_id='Join_Address_With_Geometry'
        )
    
    task6 = DummyOperator(
        task_id='Generate_Map_Core'
        )
    
    task7 = DummyOperator(
        task_id='Generate_Map_Buffer'
        )
    
    task8 = DummyOperator(
        task_id='Check_Disaster_List'
        )
    
    task9 = DummyOperator(
        task_id='Generate_BKFS_Text_File'
        )
    
    task10= DummyOperator(
        task_id='Mission_Complete'
        )
    
    task1 >> task2 >> [task3,task4] >> task5 >> task6 >> [task7, task8] >> task9 >> task10