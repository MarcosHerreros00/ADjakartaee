# CRUD Contactos Jakarta EE + MySQL

Proyecto de ejemplo para un CRUD de contactos usando Jakarta EE 10, JPA, JAX-RS y MySQL.

## Requisitos

- JDK 17+
- Maven
- Servidor Jakarta EE 10 compatible (Payara, GlassFish, WildFly, etc.)
- MySQL con la BD `bd1`

## Pasos

1. Ejecuta el script `bd1.sql` en tu servidor MySQL para crear la BD y la tabla.

2. En tu servidor de aplicaciones, crea un **DataSource JTA** llamado:

   `jdbc/bd1DS`

   Apuntando a:
   - URL: `jdbc:mysql://localhost:3306/bd1`
   - Usuario: `root` (o el que corresponda)
   - Password: (la que corresponda)
   - Driver: `com.mysql.cj.jdbc.Driver`

3. Compila el proyecto:

   ```bash
   mvn clean package
   ```

4. Despliega el WAR generado `target/contactos-crud-jakartaee.war`
   en tu servidor Jakarta EE.

5. Accede desde el navegador a:

   ```
   http://localhost:8080/contactos-crud-jakartaee/contactos/index.html
   ```

   (ajusta el contexto y el puerto según tu servidor).

Los endpoints REST estarán disponibles bajo:

- `GET    /contactos-crud-jakartaee/api/contactos`
- `GET    /contactos-crud-jakartaee/api/contactos/{id}`
- `POST   /contactos-crud-jakartaee/api/contactos`
- `PUT    /contactos-crud-jakartaee/api/contactos/{id}`
- `DELETE /contactos-crud-jakartaee/api/contactos/{id}`
