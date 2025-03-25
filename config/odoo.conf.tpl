; odoo.conf.tpl - Template configuration file for Odoo 18
[options]
; Addons paths (set via the ODOO_ADDONS_PATH environment variable)
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
