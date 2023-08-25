package fr.pantheonsorbonne.cri.javarunner;

public record ProblemWithCode(String message, String kind, long startRow, long startColumn, long endRow,
                              long endColumn) {
}
