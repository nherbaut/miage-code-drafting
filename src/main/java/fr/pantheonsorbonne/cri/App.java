package fr.pantheonsorbonne.cri;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.codehaus.commons.compiler.CompileException;
import org.codehaus.commons.compiler.ISimpleCompiler;
import org.codehaus.commons.compiler.util.reflect.ByteArrayClassLoader;
import org.codehaus.janino.SimpleCompiler;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.io.StringReader;
import java.lang.reflect.InvocationTargetException;


/**
 * Hello world!
 */
@WebServlet("/")
public class App extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/jsp/index.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                         HttpServletResponse response) throws IOException, ServletException {
        String code = request.getParameter("code");
        request.setAttribute("code",code);

        ISimpleCompiler cookable = new SimpleCompiler();
        try {
            cookable.cook(new StringReader(code));
            ByteArrayClassLoader cl = (ByteArrayClassLoader) cookable.getClassLoader();
            var res = cl.loadClass("A").getMethod("main", String[].class);

            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            PrintStream outPR = new PrintStream(bos);
            System.setOut(outPR);
            res.invoke(null, (Object) new String[0]);
            outPR.flush();
            request.setAttribute("result",new String(bos.toByteArray()));
            request.setAttribute("success","true");



        } catch (CompileException | ClassNotFoundException | NoSuchMethodException | IllegalAccessException | InvocationTargetException  e1) {
            request.setAttribute("success","false");
            request.setAttribute("result",e1.getLocalizedMessage());

        }

        request.getRequestDispatcher("/WEB-INF/jsp/index.jsp").forward(request, response);

        /**/


    }
}
