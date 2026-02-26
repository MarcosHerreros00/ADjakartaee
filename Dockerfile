# ============================================
# Stage 1: Build the WAR using Maven
# ============================================
FROM maven:3.9.9-eclipse-temurin-21 AS build

WORKDIR /app

# Copy pom.xml first for dependency caching
COPY pom.xml .

# Download dependencies (cached layer)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the WAR (skip tests for faster builds)
RUN mvn clean package -DskipTests -B

# ============================================
# Stage 2: Runtime with Payara Micro
# ============================================
FROM payara/micro:6.2024.6-jdk21

# Switch to root to set up directories and permissions
USER root

# Create directories for config, deployments, and libs
RUN mkdir -p /opt/payara/config /opt/payara/deployments /opt/payara/libs

# Download PostgreSQL JDBC driver
ADD --chmod=644 https://jdbc.postgresql.org/download/postgresql-42.7.2.jar /opt/payara/libs/postgresql.jar

# Copy the WAR from build stage as ROOT.war for root context deployment
COPY --from=build /app/target/marcosHerrerosADjakartaee.war /opt/payara/deployments/ROOT.war

# Copy post-deploy commands
COPY post-deploy-commands.asadmin /opt/payara/config/post-deploy-commands.asadmin

# Create startup script INLINE to avoid line ending issues
RUN printf '#!/bin/sh\n\
set -e\n\
echo "============================================"\n\
echo "Starting Payara Micro Configuration..."\n\
echo "============================================"\n\
\n\
# Validate required environment variables\n\
for var in DB_HOST DB_PORT DB_NAME DB_USER DB_PASSWORD DB_SSL_MODE; do\n\
  eval val=\\$${var}\n\
  if [ -z "$val" ]; then\n\
    echo "ERROR: Required environment variable $var is not set!"\n\
    exit 1\n\
  fi\n\
done\n\
\n\
echo "All required environment variables are set."\n\
echo "  DB_HOST: $DB_HOST"\n\
echo "  DB_PORT: $DB_PORT"\n\
echo "  DB_NAME: $DB_NAME"\n\
echo "  DB_USER: $DB_USER"\n\
echo "  DB_SSL_MODE: $DB_SSL_MODE"\n\
\n\
CONFIG_FILE="/opt/payara/config/post-boot-generated.asadmin"\n\
echo "Generating datasource configuration: $CONFIG_FILE"\n\
\n\
cat > "$CONFIG_FILE" << EOF\n\
create-jdbc-connection-pool --datasourceclassname=org.postgresql.ds.PGSimpleDataSource --restype=javax.sql.DataSource --property="" PostgresPool\n\
set resources.jdbc-connection-pool.PostgresPool.property.user=$DB_USER\n\
set resources.jdbc-connection-pool.PostgresPool.property.password=$DB_PASSWORD\n\
set resources.jdbc-connection-pool.PostgresPool.property.serverName=$DB_HOST\n\
set resources.jdbc-connection-pool.PostgresPool.property.portNumber=$DB_PORT\n\
set resources.jdbc-connection-pool.PostgresPool.property.databaseName=$DB_NAME\n\
set resources.jdbc-connection-pool.PostgresPool.property.sslmode=$DB_SSL_MODE\n\
create-jdbc-resource --connectionpoolid=PostgresPool jdbc/bd1DS\n\
EOF\n\
\n\
echo "Starting Payara Micro Server..."\n\
exec java -jar /opt/payara/payara-micro.jar \\\n\
    --noCluster \\\n\
    --port 8080 \\\n\
    --addlibs /opt/payara/libs/postgresql.jar \\\n\
    --postbootcommandfile /opt/payara/config/post-boot-generated.asadmin \\\n\
    --postdeploycommandfile /opt/payara/config/post-deploy-commands.asadmin \\\n\
    --deploy /opt/payara/deployments/ROOT.war \\\n\
    --contextroot /\n\
' > /opt/payara/start.sh && chmod +x /opt/payara/start.sh

# Set ownership of all payara files to payara user
RUN chown -R payara:payara /opt/payara

# Switch back to payara user for runtime
USER payara

# Expose the application port
EXPOSE 8080

# Use ENTRYPOINT to run the startup script
ENTRYPOINT ["/opt/payara/start.sh"]