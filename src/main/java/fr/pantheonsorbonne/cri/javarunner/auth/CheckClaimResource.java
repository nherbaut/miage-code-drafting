package fr.pantheonsorbonne.cri.javarunner.auth;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.Response;

@Path("claims-check")
public interface CheckClaimResource {

    
    @GET
    Response checkAuthorization(@HeaderParam("Authorization") String bearerToken);

}
