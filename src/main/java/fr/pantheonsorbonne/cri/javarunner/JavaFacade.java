package fr.pantheonsorbonne.cri.javarunner;

import fr.pantheonsorbonne.cri.javarunner.exceptions.ProcessExecutionError;
import fr.pantheonsorbonne.cri.javarunner.exceptions.ServiceOverloadedException;
import org.codehaus.commons.compiler.CompileException;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.TimeoutException;

public interface JavaFacade {
    /**
     *
     * @param payLoad a map which "code" key corresponds to the utf8 encoded code
     * @return
     * @throws IOException
     * @throws ProcessExecutionError
     * @throws TimeoutException
     * @throws CompileException
     * @throws ServiceOverloadedException
     */
    public Map<String, String> buildAndRun(EditorModel payLoad) throws IOException, ProcessExecutionError, TimeoutException, CompileException, ServiceOverloadedException;

}
