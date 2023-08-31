package fr.pantheonsorbonne.cri.javarunner.auth;

import jakarta.annotation.security.RolesAllowed;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.HeaderParam;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.SecurityContext;

@Path("claims-check")
public interface CheckClaimResource {

    @Path("recaptcha-cleared")
    @POST
    Response checkRecaptcha(@HeaderParam("Authorization") String bearerToken);

}
