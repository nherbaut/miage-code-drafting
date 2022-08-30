package fr.pantheonsorbonne.cri;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import org.codehaus.commons.compiler.CompileException;
import org.codehaus.commons.compiler.util.reflect.ByteArrayClassLoader;
import org.codehaus.janino.SimpleCompiler;

import java.io.*;
import java.lang.reflect.InvocationTargetException;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.concurrent.*;
import java.util.stream.Collectors;


/**
 * Hello world!
 */
@WebServlet("/")
@MultipartConfig
public class App extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
        String run = request.getParameter("run");
        //dHJ1ZQ== is shorthand for true in base64
        if ("dHJ1ZQ==".equals(run)) {
            doPost(request, response);
        } else {
            request.getRequestDispatcher("/WEB-INF/jsp/index.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response) throws IOException, ServletException {
        String code = request.getParameter("code");

        Map<String, String> payLoad = new HashMap<>();
        if (code != null) {
            payLoad.put("code", new String(Base64.getDecoder().decode(code)));
        }
        for (Part part : request.getParts()) {
            try (InputStream is = part.getInputStream()) {
                try (BufferedReader r = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                    String decodedLine = new String(Base64.getDecoder().decode(r.lines().collect(Collectors.joining("\n"))));
                    payLoad.put(part.getName(), decodedLine);
                }
            }
        }
        code = payLoad.get("code");
        request.setAttribute("code", code);

        SimpleCompiler cookable = new SimpleCompiler();
        try {
            cookable.cook(new StringReader(code));
            var classFile = cookable.getClassFiles()[0];
            ClassLoader cl = (ByteArrayClassLoader) cookable.getClassLoader();
            try {
                var res = cl.loadClass(classFile.getThisClassName()).getMethod("main", String[].class);
                ByteArrayOutputStream bos = new ByteArrayOutputStream();
                PrintStream outPR = new PrintStream(bos);
                System.setOut(outPR);

                ExecutorService executor = Executors.newSingleThreadExecutor();
                Future future = executor.submit(() -> res.invoke(null, (Object) new String[0]));
                try{
                    future.get(10, TimeUnit.SECONDS);
                }
                catch (TimeoutException e){
                    future.cancel(true);
                    throw e;
                }

                finally {
                    executor.shutdown();
                }


                outPR.flush();
                request.setAttribute("result", new String(bos.toByteArray()));
                request.setAttribute("success", "true");

            } catch (NoSuchMethodException e) {
                request.setAttribute("success", "false");
                request.setAttribute("result", "Make sure you add a public static void main(String ...args) method to your class");
            }
            catch (TimeoutException e){
                request.setAttribute("success", "false");
                request.setAttribute("result", "Your program took too long to complete (more that the timeout threshold), execution canceled. Watch out for infinite loops");
            }


        } catch (Exception e1) {
            request.setAttribute("success", "false");
            request.setAttribute("result", e1.getLocalizedMessage());

        }

        request.getRequestDispatcher("/WEB-INF/jsp/index.jsp").forward(request, response);

        /**/


    }
}
