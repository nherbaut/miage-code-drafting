package fr.pantheonsorbonne.cri.javarunner.servlet;

import com.github.javaparser.ParseProblemException;
import fr.pantheonsorbonne.cri.javarunner.EditorModel;
import fr.pantheonsorbonne.cri.javarunner.NoParsableCodeException;
import fr.pantheonsorbonne.cri.javarunner.Utils;
import fr.pantheonsorbonne.ufr27.miage.model.PayloadModel;
import fr.pantheonsorbonne.ufr27.miage.model.Result;
import fr.pantheonsorbonne.ufr27.miage.model.SourceFile;
import fr.pantheonsorbonne.ufr27.miage.service.BuilderAndCompiler;
import fr.pantheonsorbonne.ufr27.miage.service.impl.BuilderAndCompilerNative;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.stream.Collectors;


@WebServlet("")
@MultipartConfig
public class RunnerServlet extends HttpServlet {

    private static final Logger LOGGER = LoggerFactory.getLogger("RunnerServlet");
    private final String ghClientId;

    public RunnerServlet() {
        System.getenv().forEach((k, v) -> LOGGER.info("{}:{}", k, v));
        ghClientId = System.getenv("GH_CLIENT_ID");
        LOGGER.info("my client id is {} ", ghClientId);
    }

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
            request.setAttribute("client_id", ghClientId);
            if (gistId != null) {
                request.getRequestDispatcher("/WEB-INF/jsp/index.jsp?gistId=" + gistId).forward(request, response);
            } else {
                request.getRequestDispatcher("/WEB-INF/jsp/index.jsp").forward(request, response);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response) throws IOException, ServletException {
        String code = request.getParameter("code");
        request.setAttribute("client_id", ghClientId);

        EditorModel editorModel = new EditorModel();
        if (code != null) {

            editorModel.setCode(new String(java.util.Base64.getDecoder().decode(code)));
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
                        switch (part.getName()) {
                            case "gistId":
                                editorModel.setGistId(decodedLine);
                                break;
                            case "code":
                                editorModel.setCode(decodedLine);
                                break;
                            case "answers":
                                editorModel.setAnswsers(decodedLine);
                                break;
                            default:
                                throw new RuntimeException("unsupported part " + part.getName() + " content:" + decodedLine);
                        }
                    }
                }
            }
        }

        BuilderAndCompiler builderAndCompiler = null;
        try {

            PayloadModel model = new PayloadModel();
            String className = null;
            try {
                className = Utils.inferFileNameFromCode(editorModel.getCode());
            } catch (NoParsableCodeException | ParseProblemException e) {
                className = "dummy-" + System.currentTimeMillis() + ".java";
            }
            model.getSources().add(new SourceFile(className, editorModel.getCode()));
            builderAndCompiler = new BuilderAndCompilerNative();
            Result compilationAndExecutionResult = builderAndCompiler.buildAndCompile(model);

            if (compilationAndExecutionResult.getCompilationDiagnostic().size() == 0 && compilationAndExecutionResult.getRuntimeError().size() == 0) {


                if ((editorModel.getAnswser() == null) || editorModel.getAnswser().isBlank()) {
                    request.setAttribute("success", "true");
                    request.setAttribute("result", compilationAndExecutionResult.getStdout().get(0));
                } else if (editorModel.getAnswser().trim().equals(compilationAndExecutionResult.getStdout().get(0).trim())) {
                    request.setAttribute("success", "true");
                    request.setAttribute("result", "the execution of your code is compatible with the expected results:\n" + compilationAndExecutionResult.getStdout().get(0));
                } else {
                    request.setAttribute("success", "false");
                    request.setAttribute("result", "the execution of your code is NOT compatible with the expected results:\n" + compilationAndExecutionResult.getStdout().get(0));
                }

            } else {
                request.setAttribute("success", "false");

                StringBuilder sb = new StringBuilder("there is an issue processing your code:\n");
                sb.append("Compilation Problems:\n");
                sb.append("=====================\n");
                compilationAndExecutionResult.getCompilationDiagnostic().forEach(d -> sb.append(String.format("%s line: %d position_start:%d position_end:%d", d.getMessageEN(), d.getLineNumber(), d.getStartPosition(), d.getEndPosition())));
                sb.append("\n\nExecution Problems:\n");
                sb.append("=====================\n");
                compilationAndExecutionResult.getRuntimeError().forEach(rte -> sb.append(rte.toString()));
                request.setAttribute("result", "there is an issue processing your code:\n" + sb.toString());

            }


        } finally {
            if (builderAndCompiler != null) {
                builderAndCompiler.reboot();
            }
        }
        String dispatcher = "/WEB-INF/jsp/index.jsp";
        if (editorModel.getGistId() != null) {
            dispatcher = dispatcher += "?gistId=" + editorModel.getGistId();
        }
        request.getRequestDispatcher(dispatcher).
                forward(request, response);


    }

}
