#!/bin/bash
set -e

# ============================================
# Payara Micro Startup Script for Render.com
# ============================================
# This script generates datasource configuration at RUNTIME
# because Render injects environment variables at container start,
# not during Docker build.
# ============================================

echo "============================================"
echo "Starting Payara Micro Configuration..."
echo "============================================"

# --------------------------------------------
# Validate required environment variables
# --------------------------------------------
REQUIRED_VARS="DB_HOST DB_PORT DB_NAME DB_USER DB_PASSWORD DB_SSL_MODE"

for var in $REQUIRED_VARS; do
    if [ -z "${!var}" ]; then
        echo "ERROR: Required environment variable $var is not set!"
        exit 1
    fi
done

echo "All required environment variables are set."
echo "  DB_HOST: $DB_HOST"
echo "  DB_PORT: $DB_PORT"
echo "  DB_NAME: $DB_NAME"
echo "  DB_USER: $DB_USER"
echo "  DB_SSL_MODE: $DB_SSL_MODE"
echo "  DB_PASSWORD: [HIDDEN]"

# --------------------------------------------
# Generate post-boot asadmin commands at runtime
# --------------------------------------------
# IMPORTANT: We use postboot (not preboot) because
# preboot runs before the JDBC driver is loaded.
# --------------------------------------------

CONFIG_FILE="/opt/payara/config/post-boot-generated.asadmin"

echo "Generating datasource configuration: $CONFIG_FILE"

cat > "$CONFIG_FILE" << EOF
# Auto-generated at runtime - DO NOT EDIT
# Generated on: $(date)

# Create JDBC Connection Pool for PostgreSQL
create-jdbc-connection-pool --datasourceclassname=org.postgresql.ds.PGSimpleDataSource --restype=javax.sql.DataSource --property="" PostgresPool

# Set each pool property individually to avoid Payara parsing bugs
set resources.jdbc-connection-pool.PostgresPool.property.user=$DB_USER
set resources.jdbc-connection-pool.PostgresPool.property.password=$DB_PASSWORD
set resources.jdbc-connection-pool.PostgresPool.property.serverName=$DB_HOST
set resources.jdbc-connection-pool.PostgresPool.property.portNumber=$DB_PORT
set resources.jdbc-connection-pool.PostgresPool.property.databaseName=$DB_NAME
set resources.jdbc-connection-pool.PostgresPool.property.sslmode=$DB_SSL_MODE

# Create JDBC Resource with JNDI name that matches persistence.xml
create-jdbc-resource --connectionpoolid=PostgresPool jdbc/bd1DS
EOF

echo "Datasource configuration generated successfully."
echo ""
echo "============================================"
echo "Starting Payara Micro Server..."
echo "============================================"

# --------------------------------------------
# Start Payara Micro with all required flags
# --------------------------------------------
exec java -jar /opt/payara/payara-micro.jar \
    --noCluster \
    --port 8080 \
    --addlibs /opt/payara/libs/postgresql.jar \
    --postbootcommandfile /opt/payara/config/post-boot-generated.asadmin \
    --postdeploycommandfile /opt/payara/config/post-deploy-commands.asadmin \
    --deploy /opt/payara/deployments/ROOT.war \
    --contextroot /