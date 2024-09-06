package fr.pantheonsorbonne.cri.javarunner.servlet;

import com.google.common.base.Predicates;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.kohsuke.github.GHGist;
import org.kohsuke.github.GitHub;
import org.kohsuke.github.GitHubBuilder;
import org.kohsuke.github.PagedIterable;

import java.io.IOException;
import java.util.*;
import java.util.function.Predicate;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

public class HomeServlet extends HttpServlet {

    private final String ghClientSecret;

    public HomeServlet() {
        ghClientSecret = System.getenv("GH_ACCESS_TOKEN");
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {


//        request.getServletContext().setAttribute("gistMapTimeout", Long.valueOf(timeout));

        request.setAttribute("eventSinkWsAddress", System.getenv("EVENT_SINK_SERVER_WS"));
        request.setAttribute("eventSinkServer", System.getenv("EVENT_SINK_SERVER"));
        request.setAttribute("codeSnippetAPIURL", System.getenv("CODE_SNIPPET_API_URL"));
        request.getRequestDispatcher("/WEB-INF/jsp/home.jsp").forward(request, response);


    }

}
