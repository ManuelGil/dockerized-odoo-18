#!/bin/bash
set -e

# Generate the Odoo configuration file at runtime if it doesn't exist,
# using environment variables defined in the .env file.
if [ ! -f /etc/odoo/odoo.conf ]; then
  echo "Generating /etc/odoo/odoo.conf from /config/odoo.conf.tpl..."
  envsubst < /config/odoo.conf.tpl > /etc/odoo/odoo.conf
fi

# Wait for the database to become available
echo "Waiting for the database ${ODOO_DB_HOST}:${ODOO_DB_PORT} to become available..."
/odoo/wait-for-it.sh "${ODOO_DB_HOST}:${ODOO_DB_PORT}" -t 60

# Execute the CMD passed to the container
exec "$@"
