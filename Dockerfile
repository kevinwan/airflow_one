FROM apache/airflow:2.6.3
USER root
RUN echo 'root:root_pwd' | chpasswd

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
         vim \
  && apt-get install -y openssh-server \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
  
RUN ssh-keygen -A
EXPOSE 22

RUN echo 'airflow:airflow_pwd' | chpasswd
RUN usermod -aG sudo airflow
RUN mkdir -p /home/airflow/.ssh

RUN chown -R airflow /home/airflow/.ssh \
  && chmod 700 /home/airflow/.ssh

USER airflow
COPY requirements.txt /requirements.txt
RUN pip install --user --upgrade pip
RUN pip install --no-cache-dir --user -r /requirements.txt
