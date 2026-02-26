# Usamos Payara con Java 17 porque es lo que tienes en el pom.xml
FROM payara/server-full:6.2023.10-jdk17

# Copiamos el archivo .war que NetBeans ya te generó con éxito
COPY target/marcosHerrerosADjakartaee.war $DEPLOY_DIR

# Exponemos el puerto para Render
EXPOSE 8080
