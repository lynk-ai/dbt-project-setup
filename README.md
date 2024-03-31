# dbt-project-setup

## Prerequisites
- [Docker](https://docs.docker.com/get-docker/)
- [Git](https://git-scm.com/downloads)
- [GitHub Desktop](https://desktop.github.com/) (Optional)

### Snowflake Setup
- Create the following warehouses
  - Util_wh (ETL tool, BI tool / reverse ETL)
  - Dbt_wh
- If none, Create a demo db with schema and tables
- Create users
- Create roles
- Assign privileges to roles, Warehouse, Db, tables
- Assign roles to users
- Makes sure users can use Snowflake from Snowflake’s interface

### Github Setup
- Create a git repository (empty repo)
- Clone the repository
- Create the dbt project with our project template


### Dbt Core Setup
- Place profiles.yml and lynk-dbt.sh 
Recommendation: in the folder containing the git repo folder
  > Code > pontera > dbt , profiles.yml, lynk-dbt.sh

- Change the username and password in profiles.yml


## Running the script

Once you have cloned the repo and have your own profiles.yml and dbt project run the following command:

```bash
/bin/bash ./lynk-dbt.sh \ 
--project <DBT_PROJ_PATH> \
--profiles <PROFILES_FILE_PATH>
```

**Notes:** 
- Project: Path to your DBT project directory.
(default: current working directory)
- Profiles: Path to you profiles.yml file.
(default: profiles.yml in current directory)