from datetime import datetime,timedelta
from os import path
from airflow import DAG
from airflow.operators.python import PythonOperator


default_args = {
    'owner': 'kwan',
    'retries': 5,
    'retry_delay': timedelta(minutes=5)
}

def get_name(ti):
    ti.xcom_push(key='first_name',value='Bella')
    ti.xcom_push(key='last_name',value='Chen')

def get_age(ti):
    ti.xcom_push(key='age',value=40)
    
def greet(ti,age): 
    first_name=ti.xcom_pull(task_ids='get_name',key='first_name')
    last_name=ti.xcom_pull(task_ids='get_name',key='last_name')
    age=ti.xcom_pull(task_ids='get_age',key='age')
    print(f"Hello! my name is {first_name} {last_name}, and i am {age} years old.")

with DAG(
    default_args=default_args,
    dag_id='our_dag_with_xcom_v6',
    description='our first dag using xcom',
    start_date=datetime(2023,8,12),
    schedule_interval='@daily'
) as dag:

    task1=PythonOperator(
        task_id='greet',
        python_callable=greet,
        op_kwargs={'age':20}
    )

    task2=PythonOperator(
        task_id='get_name',
        python_callable=get_name
    )

    task3=PythonOperator(
        task_id='get_age',
        python_callable=get_age
    )

    [task2,task3] >> task1


