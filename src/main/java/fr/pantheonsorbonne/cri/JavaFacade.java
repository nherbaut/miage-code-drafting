package fr.pantheonsorbonne.cri;

import com.google.common.io.MoreFiles;
import org.codehaus.commons.compiler.CompileException;
import org.codehaus.janino.SimpleCompiler;
import org.codehaus.janino.util.ClassFile;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicReference;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class JavaFacade implements AutoCloseable {
    public final Path tmpDir;

    private static final BlockingDeque<Integer> resources;
    private static final Semaphore semaphore;
    private static final int COUNT_CONCURRENT_COMPILATION = 15;

    static {
        resources = new LinkedBlockingDeque<Integer>(IntStream.range(0, 15).boxed().collect(Collectors.toSet()));

        semaphore = new Semaphore(10, true);
    }


    public JavaFacade() throws IOException {
        tmpDir = Files.createTempDirectory("compiledClasses");
    }

    public Map<String, String> buildAndRun(Map<String, String> payLoad) throws IOException, ProcessExecutionError, TimeoutException, CompileException, ServiceOverloadedException {

        Integer gid = 0;
        Map<String, String> res = null;
        try {
            semaphore.acquire();
            gid = resources.poll(15, TimeUnit.SECONDS);
            semaphore.release();
            ClassFile cf = this.compileCode(payLoad);
            if (gid == null) {
                throw new ServiceOverloadedException("waited too long to get the compilation/run token, please try again in a bit");
            }
            res = this.runCode(cf, gid);

        } catch (InterruptedException e) {
            throw new ServiceOverloadedException(e);
        } finally {
            resources.push(gid);


        }
        return res;


    }

    private ClassFile compileCode(Map<String, String> payLoad) throws IOException, CompileException {
        SimpleCompiler cookable = new SimpleCompiler();

        cookable.cook(new StringReader(payLoad.get("code")));

        var classFile = cookable.getClassFiles()[0];
        for (ClassFile myClassFile : cookable.getClassFiles()) {
            try (BufferedOutputStream os = new BufferedOutputStream(new FileOutputStream(Path.of(tmpDir.toString(), myClassFile.getThisClassName() + ".class").toFile()))) {
                os.write(myClassFile.toByteArray());
            }
        }
        return classFile;
    }

    private Map<String, String> runCode(ClassFile classFile, Integer gid) throws IOException, TimeoutException, ProcessExecutionError {
        Map<String, String> processResult = new HashMap<>();
        ProcessBuilder pb = new ProcessBuilder();
        pb.directory(tmpDir.toFile());
        String tomcatBase = System.getenv("CATALINA_HOME");

        String isolate = String.format("%s/webapps/javarunner/WEB-INF/classes/isolate.sh", tomcatBase);
        pb.command("/bin/bash", isolate, "" + gid, tmpDir.toAbsolutePath().toString(), classFile.getThisClassName());
        Process pr = pb.start();
        while (pr.isAlive()) {
            try {
                Thread.sleep(100, 0);
            } catch (InterruptedException e) {
                e.printStackTrace();

            }
        }

        processResult.put("out", getConsoleOutput(pr.getInputStream()));
        processResult.put("err", getConsoleOutput(pr.getErrorStream()));
        if (pr.exitValue() != 0) {
            throw new ProcessExecutionError("process exited with \n message:" + processResult.get("err") + "\n output:" + processResult.get("out"));
        }
        return processResult;
    }

    private String getConsoleOutput(InputStream inputStream) throws IOException {
        ExecutorService es = Executors.newSingleThreadExecutor();
        AtomicReference<String> executionStdout = new AtomicReference<>();
        es.submit(() -> {

            try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream))) {
                executionStdout.set(reader.lines().filter(l -> l != null).collect(Collectors.joining("\n")));
            } catch (IOException e) {
                throw new RuntimeException(e);
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

    @Override
    public void close() throws IOException {
        MoreFiles.deleteRecursively(this.tmpDir);
    }
}
