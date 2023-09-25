package fr.pantheonsorbonne.cri.javarunner.filter;

import jakarta.servlet.*;

import java.io.IOException;

public class EnvParamFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        request.setAttribute("eventSinkWsAddress", System.getenv("EVENT_SINK_SERVER_WS"));
        request.setAttribute("eventSinkServer", System.getenv("EVENT_SINK_SERVER"));
        request.setAttribute("codeSnippetAPIURL", System.getenv("CODE_SNIPPET_API_URL"));
        chain.doFilter(request, response);
    }
}
