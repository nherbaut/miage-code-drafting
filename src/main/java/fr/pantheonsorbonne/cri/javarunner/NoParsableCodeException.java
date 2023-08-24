package fr.pantheonsorbonne.cri.javarunner;

public class NoParsableCodeException extends Exception{
    public NoParsableCodeException(String code) {
        super(code);
    }
}
