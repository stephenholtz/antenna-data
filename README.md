antenna-data
===

Notes and configuration files to document how data and databases are handled for the antenna-analysis project. Raw data is stored on an AWS s3 bucket and backed up as needed to a managed fileserver at Harvard Med School and a personal fileserver. Processing pipelines are provided via [datajoint](https://github.com/datajoint/), and the required SQL database is hosted on (currently) on Amazon via Amazon RDS. Some notes for previous setup using google cloud are below.

## Filestructure
```
.
├── antenna-fs
│   ├── db                  # folders used as cloud stores for datajoint database
│   │   ├── analysis        #
│   │   └── stimuli         #
│   ├── cull                # experiments that are not used in final analysis
│   │   └── exp_ephys_...   #
│   ├── raw                 # experiments that are/will be imported into database
│   │    └── exp_ephys_...  #
│   └── figures             # figures generated during analysis for sharing
```

## Syncing/adding experimental data with `rsync`
- The [rclone](https://rclone.org/) utility gives good multithreaded performance on an rsync-like command.
- Appropriate AWS credentials are required to configure a profile. Mine is named `antenna-aws`.
- `sync_exclude.txt` has standard filesystem-specific files to exclude (a la .gitignore) in addition to the database-managed folders.
- Deleting files with rclone etc., is required if they get caught outside of the filtering rules in `--exclude-from`
- NOTE: always use `--dry-run` first!

## Sync/backup with `rclone sync` [command](https://rclone.org/commands/rclone_sync/) or `rclone copy` [command](https://rclone.org/commands/rclone_copy/) and profile `antenna-aws`: 
- **FROM: s3; TO: local (macbook):**  e.g. for backup
    - `rclone sync antenna-aws:antenna-fs ~/data/antenna-fs -P --exclude-from sync_exclude.txt --dry-run`
- **FROM: local (macbook); TO: s3:**  e.g. post metadata fixes
    - `rclone sync ~/data/antenna-fs antenna-aws:antenna-fs -P --exclude-from sync_exclude.txt --dry-run`
- **FROM s3; TO: local windows backup:**
    - `rclone copy antenna-aws:antenna-fs D:\antenna-fs -P --exclude-from ..\antenna-data\sync_exclude.txt`
    - Then move over to the med school fileserver.

## Push data to cloud with `rclone copy`. Assumes running from the directory with the `rclone` executable.
  - `rclone copy F:\ephys_data\ antenna-aws:antenna-fs/raw -P --exclude-from ..\antenna-data\sync_exclude.txt --dry-run`
  - And move a copy to the med school fileserver.

## Mounting s3 or syncing for figure sharing:
- Using `s3fs` mount (via brew install s3fs)
    - NOTE: this is slow for normal browsing large numbers of files
    - `mkdir -p ~/figures/`
    - `s3fs antenna-fs:/figures ~/figures`
- Example rclone copy to local (e.g. to a shared dropbox folder)
    - This is much faster than s3fs mounting then `mv` etc.,
    - `rclone copy antenna-aws:antenna-fs/figures ~/Dropbox/`

## Amazon RDS configuration
Managed hosting on amazon to match the s3 store.
- Configuration settings easily set on in the console. Many of these values are comically large and perhaps failure prone.
    ```
    innodb_lock_wait_timeout=7200
    innodb_log_file_size=4294967296
    innodb_stats_on_metadata=0
    interactive_timeout=172800
    lock_wait_timeout=7200
    max_allowed_packet=1073741824
    net_read_timeout=14400
    net_write_timeout=144000
    wait_timeout=172800
    ```

## Google Cloud SQL
A very simple configuration where all the management (disk expansion, backups, etc.,) happens on Google's end.
- Set these database flags through the console or with the `gcloud` utility and `--database-flags`
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
- Connect with Public IP Address:
    - To allow VMs to access this database, their IP address needs to be added as an Authorized Network.
    - The Compute Engine VM Public IP Adress is visible on the VM instances page of the Cloud Console under `External IP` (once it is running)
    - To add the VM as an Authorized Network, go to the [Cloud SQL Dashboard](https://console.cloud.google.com/sql/) for the SQL database under "Connection" then "Add Network" under Authorized Networks.
    - Locally this can be accessed with the MySQL client `mysql --host=[INSTANCE_IP] --user=root --password`
    - Other ways to connect are listed in [these instructions](https://cloud.google.com/sql/docs/mysql/connect-compute-engine).
    - To connect with a Private IP Address, reserve an external Static IP address and then add this again using the Cloud SQL Dashboard for `antenna-db-##` "Connection" menu under "Private IP"
