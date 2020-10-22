antenna-data
===

Notes and configuration files to docment how data and databases are handled for the antenna-analysis project.

## Amazon RDS
Temporary note as png before better documenting my MariaDB settings

## AWS Installation
- Migrating to AWS after running into a few compatibility issues and poor community support. DataJoint also currently supports s3 stores and the latency is dramatically lower.
- original [s3 sync](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/s3/sync.html) from ephys rig backup:
  - `aws s3 sync D:\antenna-fs\ s3://antenna-fs`
- using `rclone sync` [command](https://rclone.org/commands/rclone_sync/) with a profile `antenna-aws` set up with aws credentials:
  - From s3 to local `rclone sync antenna-aws:antenna-fs ~/data/antenna-fs -P --exclude-from sync_exclude.txt`
  - From local to s3 `rclone sync ~/data/antenna-fs antenna-aws:antenna-fs -P --exclude-from sync_exclude.txt`
- always use `--dry-run` first
- deleting files with rclone etc., is required if they get caught outside of the filtering rules in `--exclude-from`

Two ways that I have used to make the SQL database for the `antenna-analysis` [datajoint](https://github.com/datajoint/datajoint-python) based analysis pipeline. 

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
- In the Google Cloud Console select "SQL" and then create an instance named `antenna-db-##`.
- Choose MySQL, and pick the Region and Zone where the cloud storage container is located
    - This Region and Zone also need to be used for Notebooks and Compute Engine VMs so they can access without further configuration.
- Advanced configuration options can mostly be changed later.

Set these database flags through the console or with the `gcloud` utility and `--database-flags`
```
max_allowed_packet=1073741824
innodb_log_file_size=4294967296
innodb_file_per_table=1
innodb_stats_on_metadata=0
wait_timeout=172800
interactive_timeout=172800
net_read_timeout=7200
net_write_timeout=7200
lock_wait_timeout=3600
innodb_lock_wait_timeout=3600
```
    
### Connect with Public IP Address (for temporary testing):
- To allow VMs to access this database, their IP address needs to be added as an Authorized Network.
- The Compute Engine VM Public IP Adress is visible on the VM instances page of the Cloud Console under `External IP` (once it is running)
- To add the VM as an Authorized Network, go to the [Cloud SQL Dashboard](https://console.cloud.google.com/sql/) for the SQL database under "Connection" then "Add Network" under Authorized Networks.
- Locally this can be accessed with the MySQL client `mysql --host=[INSTANCE_IP] --user=root --password`
- Other ways to connect are listed in [these instructions](https://cloud.google.com/sql/docs/mysql/connect-compute-engine).
- To connect with a Private IP Address, reserve an external Static IP address and then add this again using the Cloud SQL Dashboard for `antenna-db-##` "Connection" menu under "Private IP"

## TODO:
- Make a simple `cloudbuild.yaml` method for setting up this server as a backup solution.
