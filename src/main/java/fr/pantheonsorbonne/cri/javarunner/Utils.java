package fr.pantheonsorbonne.cri.javarunner;

import com.github.javaparser.StaticJavaParser;
import com.github.javaparser.ast.body.TypeDeclaration;

import java.util.function.Supplier;

public class Utils {
    public static String inferFileNameFromCode(String code) throws NoParsableCodeException {
        TypeDeclaration td = StaticJavaParser.parse(code).getTypes().stream().findAny().orElseThrow((Supplier<NoParsableCodeException>) () -> new NoParsableCodeException(code));
        return td.getName().getIdentifier() + ".java";
    }
}
