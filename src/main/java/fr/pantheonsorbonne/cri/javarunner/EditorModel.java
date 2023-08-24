package fr.pantheonsorbonne.cri.javarunner;

public class EditorModel {
    private String gistId;
    private String code;

    public String getGistId() {
        return gistId;
    }

    public void setGistId(String gistId) {
        this.gistId = gistId;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getAnswser() {
        return answsers;
    }

    public void setAnswsers(String answsers) {
        this.answsers = answsers;
    }

    private String answsers;
}
