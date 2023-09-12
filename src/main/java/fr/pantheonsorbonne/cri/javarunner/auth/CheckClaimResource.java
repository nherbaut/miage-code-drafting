package fr.pantheonsorbonne.cri.javarunner.auth;

import jakarta.ws.rs.HEAD;
import jakarta.ws.rs.HeaderParam;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.core.Response;

@Path("claims-check")
public interface CheckClaimResource {

    
    @HEAD
    Response checkAuthorization(@HeaderParam("Authorization") String bearerToken);

}
