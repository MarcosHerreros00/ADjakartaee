-- Create database if not exists
CREATE DATABASE IF NOT EXISTS vuelos_db;
USE vuelos_db;

-- Table: aerolineas
CREATE TABLE IF NOT EXISTS aerolineas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo_iata VARCHAR(3) UNIQUE NOT NULL
);

-- Table: aviones
CREATE TABLE IF NOT EXISTS aviones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    modelo VARCHAR(50) NOT NULL,
    capacidad INT NOT NULL,
    aerolinea_id INT,
    FOREIGN KEY (aerolinea_id) REFERENCES aerolineas(id)
);

-- Table: aeropuertos
CREATE TABLE IF NOT EXISTS aeropuertos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    codigo_iata VARCHAR(3) UNIQUE NOT NULL
);

-- Table: terminales
CREATE TABLE IF NOT EXISTS terminales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    aeropuerto_id INT,
    FOREIGN KEY (aeropuerto_id) REFERENCES aeropuertos(id)
);

-- Table: puertas
CREATE TABLE IF NOT EXISTS puertas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL,
    terminal_id INT,
    FOREIGN KEY (terminal_id) REFERENCES terminales(id)
);

-- Table: vuelos
CREATE TABLE IF NOT EXISTS vuelos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_vuelo VARCHAR(10) UNIQUE NOT NULL,
    origen_id INT,
    destino_id INT,
    avion_id INT,
    puerta_id INT,
    hora_salida DATETIME NOT NULL,
    hora_llegada DATETIME NOT NULL,
    FOREIGN KEY (origen_id) REFERENCES aeropuertos(id),
    FOREIGN KEY (destino_id) REFERENCES aeropuertos(id),
    FOREIGN KEY (avion_id) REFERENCES aviones(id),
    FOREIGN KEY (puerta_id) REFERENCES puertas(id)
);

-- Sample data
INSERT INTO aerolineas (nombre, codigo_iata) VALUES ('Iberia', 'IBE'), ('Vueling', 'VLG');
INSERT INTO aviones (modelo, capacidad, aerolinea_id) VALUES ('Airbus A320', 180, 1), ('Boeing 737', 160, 2);
INSERT INTO aeropuertos (nombre, ciudad, codigo_iata) VALUES ('Adolfo Suárez Madrid-Barajas', 'Madrid', 'MAD'), ('El Prat', 'Barcelona', 'BCN');
INSERT INTO terminales (nombre, aeropuerto_id) VALUES ('T4', 1), ('T1', 2);
INSERT INTO puertas (nombre, terminal_id) VALUES ('J52', 1), ('A12', 2);
INSERT INTO vuelos (numero_vuelo, origen_id, destino_id, avion_id, puerta_id, hora_salida, hora_llegada) 
VALUES ('IB1234', 1, 2, 1, 1, '2024-03-01 10:00:00', '2024-03-01 11:30:00');
