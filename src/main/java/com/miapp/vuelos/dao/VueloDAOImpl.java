package com.miapp.vuelos.dao;

import com.miapp.vuelos.model.Vuelo;
import jakarta.enterprise.context.RequestScoped;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;

@RequestScoped
public class VueloDAOImpl implements VueloDAO {

    @PersistenceContext(unitName = "contactosPU")
    private EntityManager em;

    @Override
    public List<Vuelo> findAll() {
        return em.createQuery("SELECT v FROM Vuelo v " +
                "LEFT JOIN FETCH v.origen " +
                "LEFT JOIN FETCH v.destino " +
                "LEFT JOIN FETCH v.avion a " +
                "LEFT JOIN FETCH a.aerolinea " +
                "LEFT JOIN FETCH v.puerta p " +
                "LEFT JOIN FETCH p.terminal", Vuelo.class)
                .getResultList();
    }

    @Override
    public Vuelo findById(Integer id) {
        try {
            return em.createQuery("SELECT v FROM Vuelo v " +
                    "LEFT JOIN FETCH v.origen " +
                    "LEFT JOIN FETCH v.destino " +
                    "LEFT JOIN FETCH v.avion a " +
                    "LEFT JOIN FETCH a.aerolinea " +
                    "LEFT JOIN FETCH v.puerta p " +
                    "LEFT JOIN FETCH p.terminal " +
                    "WHERE v.id = :id", Vuelo.class)
                    .setParameter("id", id)
                    .getSingleResult();
        } catch (Exception e) {
            return null;
        }
    }
}
