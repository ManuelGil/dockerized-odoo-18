# Use the official slim Python 3.11 image (Debian Bullseye-based)
FROM python:3.11-slim-bullseye

# Set non-interactive mode for apt-get installs
ENV DEBIAN_FRONTEND=noninteractive

# Install required system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    libffi-dev \
    libpq-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxrender1 \
    libfontconfig1 \
    libpng-dev \
    wget \
    nodejs \
    npm \
    dos2unix \
    gettext-base \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create base directory for Odoo and download wait-for-it script
RUN mkdir -p /odoo && \
    wget -O /wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && \
    chmod +x /wait-for-it.sh && \
    mv /wait-for-it.sh /odoo/wait-for-it.sh

# Copy the entire repository into /odoo (assumes your project root is the build context)
COPY . /odoo

# Install Python dependencies using requirements.txt (located in the repository root)
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && \
    pip install -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt

# Copy and prepare the entrypoint script
# Ensure that the script uses the correct path for wait-for-it.sh (/odoo/wait-for-it.sh)
COPY entrypoint.sh /odoo/entrypoint.sh
RUN dos2unix /odoo/entrypoint.sh && chmod +x /odoo/entrypoint.sh

# Copy the configuration template from config/odoo.conf.tpl to /config/odoo.conf.tpl
# This template will be processed at runtime using environment variables.
COPY config/odoo.conf.tpl /config/odoo.conf.tpl

# Create the "odoo" user, set up critical directories, and adjust permissions
RUN adduser --disabled-password --gecos "" odoo && \
    mkdir -p /etc/odoo /var/log/odoo && \
    chown -R odoo:odoo /odoo /etc/odoo /var/log/odoo && \
    find /odoo -type d -name '.git' -exec rm -rf {} +

# Set working directory
WORKDIR /odoo

# Expose port 8069 for Odoo
EXPOSE 8069

# Switch to the "odoo" user for better security
USER odoo

# Use the entrypoint script to wait for the DB and generate the config at runtime
ENTRYPOINT ["/odoo/entrypoint.sh"]
# Start Odoo using the configuration file generated at runtime
CMD ["python", "odoo-bin", "-i", "base", "-c", "/etc/odoo/odoo.conf"]
