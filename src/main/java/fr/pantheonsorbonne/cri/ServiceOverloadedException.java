package fr.pantheonsorbonne.cri;

public class ServiceOverloadedException extends Exception{
    public ServiceOverloadedException(Throwable cause){
        super(cause);
    }
    public ServiceOverloadedException(String cause){
        super(cause);
    }
}
