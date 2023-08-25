package fr.pantheonsorbonne.cri.javarunner.servlet;

import fr.pantheonsorbonne.cri.javarunner.ProblemWithCode;
import fr.pantheonsorbonne.ufr27.miage.model.MyDiagnostic;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class RunnerServletTest {

    @Test
    void getRangeFromDiagnostic() {
        final String code="public class A{\n" +
                "    public static void m ain(String ...args){\n" +
                "        System.out.println(\"salut\");\n" +
                "    }\n" +
                "}";
        MyDiagnostic diag = new MyDiagnostic();
        diag.setStartPosition(20L);
        diag.setEndPosition(41L);
        ProblemWithCode r = RunnerServlet.getRangeFromDiagnostic(diag,code,"compilation-error");
        assertEquals(1,r.startRow());
        assertEquals(1,r.endRow());
        assertEquals(4,r.startColumn());
        assertEquals(26,r.endColumn());

    }
}