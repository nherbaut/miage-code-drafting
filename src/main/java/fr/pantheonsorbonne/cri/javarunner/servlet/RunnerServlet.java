package fr.pantheonsorbonne.cri.javarunner.servlet;

import com.github.javaparser.ParseProblemException;
import fr.pantheonsorbonne.cri.javarunner.EditorModel;
import fr.pantheonsorbonne.cri.javarunner.NoParsableCodeException;
import fr.pantheonsorbonne.cri.javarunner.ProblemWithCode;
import fr.pantheonsorbonne.cri.javarunner.Utils;
import fr.pantheonsorbonne.cri.javarunner.coderunner.BuilderAndCompilerFactory;
import fr.pantheonsorbonne.ufr27.miage.model.*;
import fr.pantheonsorbonne.ufr27.miage.service.BuilderAndCompiler;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import org.apache.commons.text.StringEscapeUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.function.Supplier;
import java.util.stream.Collectors;
import java.util.stream.Stream;


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
        request.setAttribute("eventSinkWsAddress", System.getenv("EVENT_SINK_SERVER_WS"));
        request.setAttribute("eventSinkServer", System.getenv("EVENT_SINK_SERVER"));
        request.setAttribute("codeSnippetAPIURL", System.getenv("CODE_SNIPPET_API_URL"));
        request.setAttribute("preferred_name", request.getSession().getAttribute("preferred_name"));
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
        String base64Code = request.getParameter("code");
        request.setAttribute("client_id", ghClientId);
        request.setAttribute("eventSinkWsAddress", System.getenv("EVENT_SINK_SERVER_WS"));
        request.setAttribute("eventSinkServer", System.getenv("EVENT_SINK_SERVER"));
        request.setAttribute("codeSnippetAPIURL", System.getenv("CODE_SNIPPET_API_URL"));
        request.setAttribute("preferred_name", request.getSession().getAttribute("preferred_name"));
        EditorModel editorModel = new EditorModel();
        if (base64Code != null) {

            editorModel.setCode(new String(java.util.Base64.getDecoder().decode(base64Code)));
        }
        if (request.getContentType() != null && !request.getContentType().isBlank() && request.getContentType().contains("multipart/form-data")) {
            for (Part part : request.getParts()) {
                try (InputStream is = part.getInputStream()) {
                    try (BufferedReader r = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                        String decodedLine;
                        if (!part.getName().equals("gistId")) {
                            decodedLine = new String(java.util.Base64.getDecoder().decode(r.lines().collect(Collectors.joining("\n"))));
                        } else {
                            decodedLine = r.lines().collect(Collectors.joining("\n"));
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
            builderAndCompiler = BuilderAndCompilerFactory.getDefault();
            Result compilationAndExecutionResult = builderAndCompiler.buildAndCompile(model, 10, TimeUnit.SECONDS);
            Collection<ProblemWithCode> compilationErrors = new ArrayList<>();
            Collection<ProblemWithCode> runtimeErrors = new ArrayList<>();
            request.setAttribute("stdout", StringEscapeUtils.escapeEcmaScript(compilationAndExecutionResult.getStdout()));
            if (compilationAndExecutionResult.getCompilationDiagnostic().isEmpty() && compilationAndExecutionResult.getRuntimeError().isEmpty()) {


                if ((editorModel.getAnswser() == null) || editorModel.getAnswser().isBlank()) {
                    request.setAttribute("success", "true");
                    request.setAttribute("result", compilationAndExecutionResult.getStdout());

                } else if (editorModel.getAnswser().trim().equals(compilationAndExecutionResult.getStdout().trim())) {
                    request.setAttribute("success", "true");
                    request.setAttribute("result", "the execution of your code is compatible with the expected results:\n" + compilationAndExecutionResult.getStdout());
                } else {
                    request.setAttribute("success", "false");
                    request.setAttribute("result", "the execution of your code is NOT compatible with the expected results:\n" + compilationAndExecutionResult.getStdout());
                }

            } else {
                request.setAttribute("success", "false");

                StringBuilder sb = new StringBuilder("there is an issue processing your code:\n");
                if (!compilationAndExecutionResult.getCompilationDiagnostic().isEmpty()) {
                    sb.append("Compilation Problems:\n");
                    sb.append("=====================\n");
                    compilationAndExecutionResult.getCompilationDiagnostic().forEach(d -> sb.append(getRangeFromDiagnostic(d, editorModel.getCode(), "compilation error")));
                }
                if (!compilationAndExecutionResult.getRuntimeError().isEmpty()) {
                    sb.append("\n\nExecution Problems:\n");
                    sb.append("=====================\n");
                    compilationAndExecutionResult.getRuntimeError().forEach(rte -> sb.append(rte.toString()));

                }

                sb.append("\n\nStandard Output\n");
                sb.append("===============\n");

                if (!compilationAndExecutionResult.getStdout().isEmpty()) {
                    sb.append(compilationAndExecutionResult.getStdout());
                } else {
                    sb.append("<<no standard output>>");
                }
                request.setAttribute("result", sb.toString());


                compilationErrors.addAll(compilationAndExecutionResult.getCompilationDiagnostic().stream()
                        .map(d -> getRangeFromDiagnostic(d, editorModel.getCode(), "compilation-error")
                        )
                        .toList());

                runtimeErrors.addAll(compilationAndExecutionResult.getRuntimeError().stream()
                        .flatMap(RunnerServlet::getRuntimeErrorsStream
                        ).toList());


            }
            request.setAttribute("compilationErrors", compilationErrors);
            request.setAttribute("runtimeErrors", runtimeErrors);


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

    private static Stream<ProblemWithCode> getRuntimeErrorsStream(RuntimeError r) {
        if (r.getStackTraceElements().isEmpty()) {
            return Stream.of(new ProblemWithCode(StringEscapeUtils.escapeEcmaScript(r.getMessage()), "no stack trace provided", 0, 0, 0, 0));
        }
        return r.getStackTraceElements()
                .stream()
                .map(ste -> new ProblemWithCode(StringEscapeUtils.escapeEcmaScript(r.getMessage()), "execution-error", ste.lineNumber() - 1, 0, ste.lineNumber() - 1, 99));
    }


    protected static ProblemWithCode getRangeFromDiagnostic(MyDiagnostic d, String code, String kind) {
        Supplier<String> emptyStringSupplier = () -> "";
        long startColumn = code.substring(0, d.getStartPosition().intValue()).lines().reduce((l1, l2) -> l2).orElseGet(emptyStringSupplier).length();
        long endColumn = code.substring(0, d.getEndPosition().intValue()).lines().reduce((l1, l2) -> l2).orElseGet(emptyStringSupplier).length() + 1;
        long startRow = code.substring(0, d.getStartPosition().intValue()).lines().count() - 1;
        long endRow = code.substring(0, d.getEndPosition().intValue()).lines().count() - 1;
        startRow = startRow == -1 ? 0 : startRow;
        endRow = endRow == -1 ? 0 : endRow;


        return new ProblemWithCode(
                StringEscapeUtils.escapeEcmaScript(d.getMessageFR()),
                kind,
                startRow,
                startColumn,
                endRow,
                endColumn
        );
    }

}
