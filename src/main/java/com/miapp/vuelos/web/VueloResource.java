package com.miapp.vuelos.web;

import com.miapp.vuelos.dto.VueloDTO;
import com.miapp.vuelos.service.VueloService;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;

import java.util.List;

@Path("/vuelos")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class VueloResource {

    @Inject
    private VueloService vueloService;

    @GET
    public List<VueloDTO> listar() {
        return vueloService.listarTodos();
    }

    @GET
    @Path("/{id}")
    public VueloDTO obtener(@PathParam("id") Integer id) {
        VueloDTO dto = vueloService.buscarPorId(id);
        if (dto == null) {
            throw new NotFoundException("Vuelo no encontrado");
        }
        return dto;
    }
}
