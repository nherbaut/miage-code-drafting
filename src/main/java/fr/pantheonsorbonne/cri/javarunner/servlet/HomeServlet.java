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

        String filter = request.getParameter("filter");
        request.setAttribute("eventSinkWsAddress", System.getenv("EVENT_SINK_SERVER_WS"));
        Object refresh = request.getParameter("refresh");


        Long gistTimeout = (Long) request.getServletContext().getAttribute("gistMapTimeout");
        List<GHGist> gistList = (List<GHGist>) request.getServletContext().getAttribute("gistList");
        if (gistList == null || gistTimeout < System.currentTimeMillis() || (refresh!=null && Boolean.parseBoolean(refresh.toString()))) {
            GitHub github = new GitHubBuilder().withOAuthToken(ghClientSecret).build();
            gistList = github.getUser("nherbaut").listGists().toList();
            request.getServletContext().setAttribute("gistList", gistList);

        }


        Predicate<GHGist> gistFilter;
        if (filter != null) {
            gistFilter = g -> g.getDescription().contains(filter);
        } else {
            gistFilter = Predicates.alwaysTrue();
        }

        Map<String, List<GHGist>> gistMap = new TreeMap<>();
        gistMap.putAll(StreamSupport.stream(gistList.spliterator(), false)
                .filter(gistFilter)
                .collect(
                        Collectors.groupingBy(
                                g -> Arrays.stream(g.getDescription().split("\\.")).limit(3).collect(Collectors.joining(" ")))));
        gistMap.values().forEach(l -> l.sort(Comparator.comparing(GHGist::getDescription)));
        request.getServletContext().setAttribute("gists", gistMap);
        //1h timeout
        long timeout = System.currentTimeMillis() + 1000L * 60 * 60;
        request.getServletContext().setAttribute("gistMapTimeout", Long.valueOf(timeout));


        request.getRequestDispatcher("/WEB-INF/jsp/home.jsp").forward(request, response);


    }

}
