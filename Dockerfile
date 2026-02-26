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

# Copy startup script and post-deploy commands
COPY start-payara-micro.sh /opt/payara/start-payara-micro.sh
COPY post-deploy-commands.asadmin /opt/payara/config/post-deploy-commands.asadmin

# Convert line endings (Windows CRLF to Unix LF) and make executable
RUN sed -i 's/\r$//' /opt/payara/start-payara-micro.sh && chmod +x /opt/payara/start-payara-micro.sh

# Set ownership of all payara files to payara user
RUN chown -R payara:payara /opt/payara

# Switch back to payara user for runtime
USER payara

# Expose the application port
EXPOSE 8080

# Use ENTRYPOINT (not CMD) to ensure the script runs
ENTRYPOINT ["/opt/payara/start-payara-micro.sh"]