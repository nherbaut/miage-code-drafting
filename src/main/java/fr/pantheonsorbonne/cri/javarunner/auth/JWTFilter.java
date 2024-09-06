package fr.pantheonsorbonne.cri.javarunner.auth;

import com.google.common.collect.Streams;
import jakarta.servlet.*;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.UriBuilder;
import org.jboss.resteasy.client.jaxrs.ResteasyClient;
import org.jboss.resteasy.client.jaxrs.ResteasyWebTarget;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.Arrays;
import java.util.Objects;
import java.util.stream.Collectors;

public class JWTFilter implements Filter {
    String authServerURLInteral;
    String authServerURLExternal;

    private static final Logger LOGGER = LoggerFactory.getLogger(JWTFilter.class);

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        Filter.super.init(filterConfig);
        authServerURLInteral = System.getenv("AUTH_SERVER_URL_INTERNAL");
        authServerURLExternal = System.getenv("AUTH_SERVER_URL_EXTERNAL");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {


        if (response instanceof HttpServletResponse && request instanceof HttpServletRequest) {
            doFilter((HttpServletRequest) request, ((HttpServletResponse) response), chain);
        } else {
            chain.doFilter(request, response);
        }


    }

    private void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain chain) throws ServletException, IOException {

        //we may need host when storing the cookie or redirecting for auth
        String host = request.getHeader("host").split(":")[0];
        if (request.getHeader("x-forwarded-host") != null) {
            host = request.getHeader("x-forwarded-host");
        }

        //first check if the jwt token is in the headers
        String bearer = request.getHeader("Authorization");
        String jWTtoken = null;
        if (Objects.nonNull(bearer)) {
            jWTtoken = bearer;
        } else if (request.getParameterMap().containsKey("token")) {
            jWTtoken = request.getParameterMap().get("token")[0].toString();
        } else if (Objects.nonNull(request.getCookies()) && request.getCookies().length > 0) {
            jWTtoken = Arrays.stream(request.getCookies()).filter(c -> c.getName().equals("auth-token")).map(c -> c.getValue()).findAny().orElse(null);
        }


        if (jWTtoken != null) {
            ResteasyClient client = (ResteasyClient) ClientBuilder.newClient();

            ResteasyWebTarget target = client.target(this.authServerURLInteral);

            CheckClaimResource checkClaimResource = target.proxy(CheckClaimResource.class);
            Response resp = checkClaimResource.checkAuthorization("Bearer " + jWTtoken);

            if (resp.getStatus() == 200) {
                var cookie = new Cookie("auth-token", jWTtoken);
                cookie.setSecure(true);
                cookie.setMaxAge(Integer.MAX_VALUE);
                cookie.setDomain("miage.dev");

                response.addCookie(cookie);
                request.setAttribute("authToken", jWTtoken);
                request.getSession(true).setAttribute("authToken", jWTtoken);
                request.getSession(true).setAttribute("preferred_name", resp.getHeaderString("preferred_name"));
                //not used now, but may come handy
                //request.getSession(true).setAttribute("groups", resp.getHeaderString("groups"));
                chain.doFilter(request, response);
                return;
            }
        }

        //if we are here, we need a new token


        String protocol = "http";
        if (request.getHeader("x-forwarded-scheme") != null) {
            protocol = request.getHeader("x-forwarded-scheme");
        }

        Integer port = null;
        if (request.getHeader("x-forwarded-port") != null) {
            port = Integer.parseInt(request.getHeader("x-forwarded-port"));
        } else if (request.getHeader("host").split(":").length == 2) {
            port = Integer.parseInt(request.getHeader("host").split(":")[1]);
        } else {
            LOGGER.warn("failed to load port from host and from x-forwarded-port, defaulting to 8080");
            port = 8080;
        }


        UriBuilder builder = UriBuilder.newInstance().scheme(protocol).host(host).port(port).path(request.getRequestURI());
        request.getParameterMap().forEach((s, sa) -> builder.queryParam(s, sa));
        builder.replaceQueryParam("token", null);
        LOGGER.debug("callback url after filter: {}", builder.build().toASCIIString());
        UriBuilder authUriBuilder = UriBuilder.fromPath(this.authServerURLExternal).queryParam("callback", ((HttpServletResponse) response).encodeURL(builder.build().toASCIIString()));
        response.sendRedirect(response.encodeRedirectURL(authUriBuilder.build().toASCIIString()));


    }
}

