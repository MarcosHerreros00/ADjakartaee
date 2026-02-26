package com.miapp.vuelos.service;

import com.miapp.vuelos.dao.VueloDAO;
import com.miapp.vuelos.dto.VueloDTO;
import com.miapp.vuelos.model.Vuelo;
import jakarta.enterprise.context.RequestScoped;
import jakarta.inject.Inject;

import java.util.List;
import java.util.stream.Collectors;

@RequestScoped
public class VueloService {

    @Inject
    private VueloDAO vueloDAO;

    public List<VueloDTO> listarTodos() {
        return vueloDAO.findAll()
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    public VueloDTO buscarPorId(Integer id) {
        Vuelo v = vueloDAO.findById(id);
        return v != null ? toDTO(v) : null;
    }

    private VueloDTO toDTO(Vuelo v) {
        VueloDTO dto = new VueloDTO();
        dto.setId(v.getId());
        dto.setNumeroVuelo(v.getNumeroVuelo());

        dto.setOrigen(
                v.getOrigen() != null ? v.getOrigen().getNombre() + " (" + v.getOrigen().getCodigoIata() + ")" : "N/A");

        dto.setDestino(v.getDestino() != null ? v.getDestino().getNombre() + " (" + v.getDestino().getCodigoIata() + ")"
                : "N/A");

        dto.setAerolinea(
                v.getAvion() != null && v.getAvion().getAerolinea() != null ? v.getAvion().getAerolinea().getNombre()
                        : "N/A");

        dto.setAvion(v.getAvion() != null ? v.getAvion().getModelo() : "N/A");

        dto.setTerminal(
                v.getPuerta() != null && v.getPuerta().getTerminal() != null ? v.getPuerta().getTerminal().getNombre()
                        : "N/A");

        dto.setPuerta(v.getPuerta() != null ? v.getPuerta().getNombre() : "N/A");

        dto.setHoraSalida(v.getHoraSalida());
        dto.setHoraLlegada(v.getHoraLlegada());
        return dto;
    }
}
