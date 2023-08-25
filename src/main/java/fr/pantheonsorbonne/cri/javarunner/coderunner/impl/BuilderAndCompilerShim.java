package fr.pantheonsorbonne.cri.javarunner.coderunner.impl;

import fr.pantheonsorbonne.ufr27.miage.model.PayloadModel;
import fr.pantheonsorbonne.ufr27.miage.model.Result;
import fr.pantheonsorbonne.ufr27.miage.service.BuilderAndCompiler;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.UriBuilder;
import org.jboss.resteasy.client.jaxrs.ResteasyClient;
import org.jboss.resteasy.client.jaxrs.ResteasyWebTarget;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

public class BuilderAndCompilerShim implements BuilderAndCompiler {

    private final String url;


    public BuilderAndCompilerShim(String url) {
        this.url = url;
    }

    @Path("/")
    interface ServicesInterface {

        @POST

        @Produces({MediaType.APPLICATION_JSON})
        @Consumes({MediaType.APPLICATION_JSON})
        Result compileAndRun(PayloadModel model);


    }

    @Override
    public Result buildAndCompile(PayloadModel model, long delay, TimeUnit tu) throws IOException {
        UriBuilder FULL_PATH = UriBuilder.fromPath(url);
        ResteasyClient client = (ResteasyClient) ClientBuilder.newClient();
        ResteasyWebTarget target = client.target(FULL_PATH);
        ServicesInterface proxy = target.proxy(ServicesInterface.class);
        return proxy.compileAndRun(model);

    }

    @Override
    public void reboot() {

    }
}
