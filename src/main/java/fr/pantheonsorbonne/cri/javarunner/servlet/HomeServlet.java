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
        ghClientSecret = System.getenv("GH_CLIENT_SECRET");
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {

        String filter = request.getParameter("filter");

        Map<String, List<GHGist>> gistMap = (Map<String, List<GHGist>>) request.getServletContext().getAttribute("gistMap");
        Long gistMapTimeout = (Long) request.getServletContext().getAttribute("gistMapTimeout");
        if (gistMap == null || gistMapTimeout == null || gistMapTimeout < System.currentTimeMillis()) {


            GitHub github = new GitHubBuilder().withOAuthToken(ghClientSecret).build();
            PagedIterable<GHGist> gists = github.getUser("nherbaut").listGists();
            Predicate<GHGist> gistFilter;
            if (filter != null) {
                gistFilter = g -> g.getDescription().contains(filter);
            } else {
                gistFilter = Predicates.alwaysTrue();
            }

            gistMap = new TreeMap<>();
            gistMap.putAll(StreamSupport.stream(gists.spliterator(), false)
                    .filter(gistFilter)
                    .collect(
                            Collectors.groupingBy(
                                    g -> Arrays.stream(g.getDescription().split("\\.")).limit(3).collect(Collectors.joining(" ")))));
            gistMap.values().forEach(l -> l.sort(Comparator.comparing(GHGist::getDescription)));
            request.getServletContext().setAttribute("gistMap",gistMap);
            //1h timeout
            long timeout=System.currentTimeMillis()+1000L*60*60;
            request.getServletContext().setAttribute("gistMapTimeout",Long.valueOf(timeout));
        }

        request.setAttribute("filter", filter);
        request.setAttribute("gists", gistMap);


        request.getRequestDispatcher("/WEB-INF/jsp/home.jsp").forward(request, response);


    }

}
