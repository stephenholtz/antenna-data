# antenna-db
A dockerized MySQL 8.0 database based on the one nicely provided by datajoint (https://github.com/datajoint/mysql-docker/).

This container houses the databases (schema in datajoint parlance) for both stimuli (https://github.com/datajoint/antenna-stimuli/) and experimental data (https://github.com/stephenholtz/antenna-analysis/). Code to generate the schema are in those repositories. 

Create the container using docker-compose while in the repository top level directory.

`sudo docker-compose up -d`

Start container with:

`docker start antenna_db`

TODO:
- change password configuration
- change volume management