package fr.pantheonsorbonne.cri.javarunner.servlet;

import fr.pantheonsorbonne.cri.javarunner.JavaFacade;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import org.codehaus.commons.compiler.CompileException;
import org.codehaus.commons.compiler.InternalCompilerException;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeoutException;
import java.util.stream.Collectors;



@WebServlet("")
@MultipartConfig
public class RunnerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
        String run = request.getParameter("run");
        String gistId = request.getParameter("gistId");
        if (gistId != null) {
            request.setAttribute("gistId", gistId);
        }
        //dHJ1ZQ== is shorthand for true in base64
        if ("dHJ1ZQ==".equals(run)) {
            doPost(request, response);
        } else {
            String code = request.getParameter("code");
            if (code != null) {
                code = new String(java.util.Base64.getDecoder().decode(code));
            }
            request.setAttribute("code", code);
            request.setAttribute("client_id", System.getenv("GH_CLIENT_ID"));
            if(gistId!=null) {
                request.getRequestDispatcher("/WEB-INF/jsp/index.jsp?gistId="+gistId).forward(request, response);
            }
            else{
                request.getRequestDispatcher("/WEB-INF/jsp/index.jsp").forward(request, response);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response) throws IOException, ServletException {
        String code = request.getParameter("code");
        request.setAttribute("client_id", System.getenv("GH_CLIENT_ID"));
        Map<String, String> payLoad = new HashMap<>();
        if (code != null) {

            payLoad.put("code", new String(java.util.Base64.getDecoder().decode(code)));
        }
        if (request.getContentType() != null && !request.getContentType().isBlank() && request.getContentType().contains("multipart/form-data")) {
            for (Part part : request.getParts()) {
                try (InputStream is = part.getInputStream()) {
                    try (BufferedReader r = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                        String decodedLine;
                        if (!part.getName().equals("gistId")) {
                            decodedLine = new String(java.util.Base64.getDecoder().decode(r.lines().collect(Collectors.joining("\n"))));
                        } else {
                            decodedLine = new String(r.lines().collect(Collectors.joining("\n")));
                        }
                        request.setAttribute(part.getName(), decodedLine);
                        payLoad.put(part.getName(), decodedLine);
                    }
                }
            }
        }


        try {
            Map<String, String> processResult;
            try (JavaFacade facade = new JavaFacade()) {
                processResult = facade.buildAndRun(payLoad);
            }
            if ((!payLoad.containsKey("answers")) || payLoad.get("answers").isBlank() || payLoad.get("answers").trim().equals(processResult.get("out").trim())) {
                request.setAttribute("success", "true");
                request.setAttribute("result", processResult.get("out"));
            } else {
                request.setAttribute("success", "false");
                request.setAttribute("result", "Your code output doesn't match the expected output \n" + processResult.get("out"));
            }


        } catch (TimeoutException e) {
            e.printStackTrace();
            request.setAttribute("success", "false");
            request.setAttribute("result", "Your program took too long to complete (more that the timeout threshold), execution canceled. Watch out for infinite loops\n" + e.getLocalizedMessage());
        } catch (CompileException | InternalCompilerException e) {
            e.printStackTrace();
            request.setAttribute("success", "false");
            request.setAttribute("result", "Your program failed to compile:\n" + e.getLocalizedMessage());
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("success", "false");
            request.setAttribute("result", e.getLocalizedMessage());


        }
        String dispatcher = "/WEB-INF/jsp/index.jsp";
        if (payLoad.containsKey("gistId")) {
            dispatcher = dispatcher += "?gistId=" + payLoad.get("gistId");
        }
        request.getRequestDispatcher(dispatcher).
                forward(request, response);


    }

}
