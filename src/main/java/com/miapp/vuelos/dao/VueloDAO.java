package com.miapp.vuelos.dao;

import com.miapp.vuelos.model.Vuelo;
import java.util.List;

public interface VueloDAO {
    List<Vuelo> findAll();
    Vuelo findById(Integer id);
}
