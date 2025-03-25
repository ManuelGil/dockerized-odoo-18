# Dockerized Odoo 18

This repository contains a Dockerized setup for Odoo 18, configured to work with PostgreSQL and pgAdmin. The configuration is optimized for development and can be adapted for production by adjusting environment variables and resource limits.

## Project Overview

This project provides:

- A **Dockerfile** that builds a custom Odoo 18 image using a slim Python 3.11 base.
- A **docker-compose.yml** file that orchestrates three services:
  - **odoo:** The main Odoo application.
  - **db:** A PostgreSQL 15 database.
  - **pgadmin:** pgAdmin for database management.
- A **configuration template** (`config/odoo.conf.tpl`) used to generate the final Odoo configuration file at runtime.
- An **entrypoint script** (`entrypoint.sh`) that waits for the database to be ready and generates the Odoo configuration file from the template.
- A **.env** file that defines environment variables used by Docker Compose.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- Git (to clone the repository)

## Repository Structure

```
.
├── addons/                  # Custom Odoo modules (optional)
├── config/                  # Contains the Odoo configuration template (odoo.conf.tpl)
├── custom_addons/           # Additional custom addons (optional)
├── doc/                     # Documentation (if any)
├── entrypoint.sh            # Entry point script for the Odoo container
├── filestore/               # Volume for Odoo filestore data
├── logs/                    # Volume for Odoo log files
├── odoo/                   # Odoo source code and project files
├── postgresql/              # Directory for PostgreSQL persistent data
├── sessions/                # Volume for Odoo session data
├── docker-compose.yml       # Docker Compose file for the multi-container setup
├── Dockerfile               # Dockerfile to build the custom Odoo image
├── requirements.txt         # Python dependencies for Odoo
└── .env                   # Environment variables for Docker Compose
```

## Configuration

### Environment Variables

The project uses an `.env` file to load environment variables into Docker Compose. Here is an example:

```dotenv
ODOO_PORT=8069
ODOO_DB_HOST=db
ODOO_DB_PORT=5432
ODOO_DB_USER=odoo
ODOO_DB_PASSWORD=odoo
ODOO_DB_NAME=odoo
ODOO_ADDONS_PATH=/app/odoo/addons,/app/addons,/mnt/extra-addons
ODOO_LOGFILE=/var/log/odoo/odoo.log
ODOO_DEBUG_ASSETS=True
ODOO_DEV_MODE=assets
ODOO_LIST_DB=False
ADMIN_PASSWD=supersecret

PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_DEFAULT_PASSWORD=admin
ENVIRONMENT=development
```

Adjust these values as necessary for your environment.

### Odoo Configuration Template

The file `config/odoo.conf.tpl` is used as a template to generate the final configuration file at runtime. It uses environment variables to set Odoo options. For example:

```ini
; odoo.conf.tpl - Template configuration file for Odoo 18
[options]
; Addons paths
addons_path = ${ODOO_ADDONS_PATH}

; Database configuration
db_host = ${ODOO_DB_HOST}
db_port = ${ODOO_DB_PORT}
db_user = ${ODOO_DB_USER}
db_password = ${ODOO_DB_PASSWORD}
db_name = ${ODOO_DB_NAME}

; Log file location
logfile = ${ODOO_LOGFILE}

; Asset configuration for development mode
debug_assets = ${ODOO_DEBUG_ASSETS}
dev = ${ODOO_DEV_MODE}

; Production security settings
list_db = ${ODOO_LIST_DB}
admin_passwd = ${ADMIN_PASSWD}
```

## How It Works

1. **Dockerfile**
   - Installs necessary system and Python dependencies.
   - Downloads and places the `wait-for-it.sh` script in `/odoo`.
   - Copies the entire repository into `/odoo` inside the container.
   - Installs Python dependencies from `requirements.txt`.
   - Copies the entrypoint script (`entrypoint.sh`) and the configuration template.
   - Creates an `odoo` user and sets the correct permissions.
   - Sets the entrypoint to run `entrypoint.sh`, which generates the final configuration file and waits for the database before starting Odoo.

2. **docker-compose.yml**
   - Defines three services (odoo, db, pgadmin) with proper environment variable injection using `.env`.
   - Sets resource limits, logging options, and health checks.
   - Mounts volumes for source code, configuration, logs, and persistent data.

3. **entrypoint.sh**
   - Generates `/etc/odoo/odoo.conf` from the template using `envsubst` (if the file does not exist).
   - Waits for the PostgreSQL database to become available using the `wait-for-it.sh` script.
   - Executes the command provided as CMD in the Dockerfile.

## Running the Project

1. **Clone the Repository**

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Configure Environment Variables**

   Edit the `.env` file with your desired configuration.

3. **Build and Start the Containers**

   To build the images and start the containers in detached mode, run:

   ```bash
   docker-compose up --build -d
   ```

4. **Access the Services**

   - **Odoo:** Open your browser and navigate to [http://localhost:8069](http://localhost:8069)
   - **pgAdmin:** Open your browser and navigate to [http://localhost:5050](http://localhost:5050)

## Troubleshooting

- If you encounter issues with the database initialization, you may need to remove existing volumes:

  ```bash
  docker-compose down -v
  docker-compose up --build -d
  ```

- Ensure all environment variables are defined in `.env` and that the file paths in your volumes are correct.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please submit pull requests or open issues for improvements or bug fixes.
