export  function putBackCursorPosition() {

    if (localStorage.getItem("position-row") != null) {
        const row = localStorage.getItem("position-row");
        const column = localStorage.getItem("position-column");
        ace.edit("editor").moveCursorTo(row,column);
        ace.edit("editor").resize(true); // https://stackoverflow.com/questions/23748743/ace-editor-go-to-line
        ace.edit("editor").scrollToLine(row, true, true, function () {});
    }
}