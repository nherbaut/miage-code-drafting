package fr.pantheonsorbonne.cri.javarunner.coderunner;

import fr.pantheonsorbonne.cri.javarunner.coderunner.impl.BuilderAndCompilerShim;
import fr.pantheonsorbonne.ufr27.miage.service.BuilderAndCompiler;
import fr.pantheonsorbonne.ufr27.miage.service.impl.BuilderAndCompilerNative;

public class BuilderAndCompilerFactory {
    public static BuilderAndCompiler getDefault(){
        String functionUrl = System.getenv("JAVA_CODE_RUNNER_FUNCTION_URL");
        if(functionUrl==null){
            return new BuilderAndCompilerNative();
        }
        else{
            return new BuilderAndCompilerShim(functionUrl);
        }
    }
}
