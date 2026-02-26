package com.miapp.vuelos.web;

import jakarta.ws.rs.ApplicationPath;
import jakarta.ws.rs.core.Application;

@ApplicationPath("/api")
public class JAXRSConfig extends Application {
    // Vacío, Jakarta escanea automáticamente los recursos @Path
}
