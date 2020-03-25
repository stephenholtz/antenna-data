antenna-db
===

Two ways that I have used to make the SQL database for the `antenna-analysis` [datajoint](https://github.com/datajoint/datajoint-python] based) based analysis pipeline. 

1. Dockerized on a local machine
2. Google Cloud SQL

## Local Use: Docker Desktop

A dockerized MySQL 8.0 database based on the one nicely provided by datajoint (https://github.com/datajoint/mysql-docker/).

Clone the repo

`git clone https://github.com/stephenholtz/antenna-db`

`cd antenna-db`

Create the container using docker-compose

`sudo docker-compose up -d`

In the future, start container with:

`docker start antenna_db`

## Cloud Use: Google Cloud SQL
This is a dead simple configuration where all the management (disk expansion, backups, etc.,) happens on Google's end. Note: If this becomes costly (small servers are $15/mo), it is simple to [spin up a VM running a MySQL server](https://cloud.google.com/solutions/setup-mysql).

### Create MySQL Database:
- In the Google Cloud Console select "SQL" and then create an instance named `antenna-db`.
- Choose MySQL, and pick the Region and Zone where the cloud storage container is located
    - This Region and Zone also need to be used for Notebooks and Compute Engine VMs so they can access without further configuration.
- Advanced configuration options can mostly be changed later.
    
### Connect with Public IP Address (for temporary testing):
- Once the instance spins up, the Public IP Adress visible in the Cloud Console can now be used.
- To allow VMs to access this database, their IP address needs to be added as an Authorized Network.
    - This is done in the [Cloud SQL Dashboard](https://console.cloud.google.com/sql/) for `antenna-db` under "Connection" then "Add Network" under Authorized Networks.
- Locally this can be accessed with the MySQL client `mysql --host=[INSTANCE_IP] --user=root --password`
- Other ways to connect are listed in [these instructions](https://cloud.google.com/sql/docs/mysql/connect-compute-engine).
- To connect with a Private IP Address, reserve an external Static IP address and then add this again using the Cloud SQL Dashboard for `antenna-db` "Connection" menu under "Private IP"


## TODO:
- Make a simple `cloudbuild.yaml` method for setting up this server as a backup solution.