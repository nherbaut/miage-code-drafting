package fr.pantheonsorbonne.cri;

import com.google.common.io.MoreFiles;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import org.codehaus.commons.compiler.CompileException;
import org.codehaus.janino.SimpleCompiler;
import org.codehaus.janino.util.ClassFile;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.concurrent.atomic.AtomicReference;
import java.util.stream.Collectors;


/**
 * Hello world!
 */
@WebServlet("")
@MultipartConfig
public class App extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
        String run = request.getParameter("run");
        String gistId = request.getParameter("gistId");
        if(gistId!=null){
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
            request.setAttribute("client_id",System.getenv("GH_CLIENT_ID"));
            request.getRequestDispatcher("/WEB-INF/jsp/index.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response) throws IOException, ServletException {
        String code = request.getParameter("code");
        request.setAttribute("client_id",System.getenv("GH_CLIENT_ID"));
        Map<String, String> payLoad = new HashMap<>();
        if (code != null) {

            payLoad.put("code", new String(java.util.Base64.getDecoder().decode(code)));
        }
        if (request.getContentType() != null && !request.getContentType().isBlank() && request.getContentType().contains("multipart/form-data")) {
            for (Part part : request.getParts()) {
                try (InputStream is = part.getInputStream()) {
                    try (BufferedReader r = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                        String decodedLine = new String(java.util.Base64.getDecoder().decode(r.lines().collect(Collectors.joining("\n"))));
                        request.setAttribute(part.getName(), decodedLine);
                        payLoad.put(part.getName(), decodedLine);
                    }
                }
            }
        }


        SimpleCompiler cookable = new SimpleCompiler();
        Path tmpDir = Files.createTempDirectory("compiledClasses");
        try {
            cookable.cook(new StringReader(payLoad.get("code")));
            var classFile = cookable.getClassFiles()[0];


            try {
                for (ClassFile myClassFile : cookable.getClassFiles()) {
                    try (BufferedOutputStream os = new BufferedOutputStream(new FileOutputStream(Path.of(tmpDir.toString(), myClassFile.getThisClassName() + ".class").toFile()))) {
                        os.write(myClassFile.toByteArray());
                    }
                }
                ProcessBuilder pb = new ProcessBuilder();
                pb.directory(tmpDir.toFile());
                pb.command("java", "-cp", tmpDir.toAbsolutePath().toString(), classFile.getThisClassName());
                long deadline = System.currentTimeMillis() + 10 * 1000;
                Process pr = pb.start();
                String executionStdout;
                String executionStderr;
                while (pr.isAlive() && System.currentTimeMillis() < deadline) {
                    try {
                        Thread.sleep(100, 0);
                    } catch (InterruptedException e) {
                        e.printStackTrace();

                    }
                }

                if (pr.isAlive()) {

                    executionStdout = getConsoleOutput(pr.getInputStream());
                    pr.destroy();
                    throw new TimeoutException(executionStdout);
                }
                executionStdout = getConsoleOutput(pr.getInputStream());
                executionStderr = getConsoleOutput(pr.getErrorStream());

                if (pr.exitValue() != 0) {
                    throw new Exception("process exited with \n message:" + executionStderr + "\n output:" + executionStdout);
                }


                if ((!payLoad.containsKey("answers")) || payLoad.get("answers").isBlank() || payLoad.get("answers").trim().equals(executionStdout.trim())) {
                    request.setAttribute("success", "true");
                    request.setAttribute("result", executionStdout);
                } else {
                    request.setAttribute("success", "false");
                    request.setAttribute("result", "Your code output doesn't match the expected output \n" + executionStdout);
                }


            } catch (TimeoutException e) {
                request.setAttribute("success", "false");
                request.setAttribute("result", "Your program took too long to complete (more that the timeout threshold), execution canceled. Watch out for infinite loops\n" + e.getLocalizedMessage());
            } catch (
                    Exception e1) {
                request.setAttribute("success", "false");
                request.setAttribute("result", e1.getLocalizedMessage());

            }


        } catch (CompileException e) {
            request.setAttribute("success", "false");
            request.setAttribute("result", "Your program failed to compile:\n" + e.getLocalizedMessage());
        } finally {
            MoreFiles.deleteRecursively(tmpDir);
        }

        request.getRequestDispatcher("/WEB-INF/jsp/index.jsp").
                forward(request, response);


    }

    private String getConsoleOutput(InputStream inputStream) throws IOException {
        ExecutorService es = Executors.newSingleThreadExecutor();
        AtomicReference<String> executionStdout = new AtomicReference<>();
        es.submit(() -> {

            try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream))) {
                executionStdout.set(reader.lines().filter(l -> l != null).collect(Collectors.joining("\n")));
            } catch (IOException e) {
                e.printStackTrace();
            }
        });
        try {
            es.awaitTermination(100, TimeUnit.MILLISECONDS);
        } catch (InterruptedException e) {
            return "<<error: can't read inputstream";
        }
        es.shutdown();
        String res = executionStdout.get();
        return res != null ? res : "";
    }
}
