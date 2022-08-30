<%--
  Created by IntelliJ IDEA.
  User: nherbaut
  Date: 30/08/2022
  Time: 02:07
  To change this template use File | Settings | File Templates.
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
<head>
    <meta charset="utf-8">
    <title>Title</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet"
          integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">

    <style>


    </style>

    <style>
        textarea {
            width: 100%;
            height: 426px;
        }

        #answers {
            height: 150px;
        }

        #btn-run {
            margin-top: 5px;
            width: 100%;
        }


    </style>
</head>
<body>
<form method="POST" action="./" enctype="multipart/form-data">
    <div class="container container-fluid">
        <div class="row">
            <h1 class="display-1">MIAGE Code Crafting</h1>
        </div>

        <div class="row">
            <div class="col">
                <div id="editor" style="width: 100%; height: 500px"><c:out value="${code}"/></div>
            </div>
            <div class="col">
                <c:choose>
                    <c:when test="${empty success}">
                        <div class="alert alert-secondary" role="alert">
                            Ready to code!
                        </div>
                    </c:when>
                    <c:when test="${success==false}">
                        <div class="alert alert-danger" role="alert">
                            Something went wrong
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="alert alert-success" role="alert">
                            Execution successful
                        </div>
                    </c:otherwise>
                </c:choose>


                <textarea readonly>${result}</textarea>
                <input id="btn-run" class="btn btn-primary" type="submit" onclick="onSubmit()" value="Run (CTRL+ENTER)">
            </div>
            <textarea name="code" id="code" hidden></textarea>


        </div>


        <div
                <c:if test="${empty fn:trim(answers)}">

                    hidden
                </c:if>
                id="expected-output">
            <h2>Expected Output:</h2>
            <textarea readonly id="answers">${answers}</textarea>
            <textarea readonly class="answers" hidden name="answers"></textarea>

        </div>


    </div>
</form>
<script src="https://cdnjs.cloudflare.com/ajax/libs/js-beautify/1.6.8/beautify.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/ace.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/ext-beautify.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-java.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/ext-language_tools.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/theme-github.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM"
        crossorigin="anonymous"></script>

</body>

<script type="module">
    import {putBackCursorPosition} from "./resources/js/cursor.js";

    ace.require("ace/ext/language_tools");
    export const editor = ace.edit("editor");
    editor.setTheme("ace/theme/tomorrow_night");
    editor.session.setMode("ace/mode/java");
    editor.setOptions({
        enableBasicAutocompletion: true,
        fontSize: "14pt"
    });

    editor.focus();
    putBackCursorPosition();
</script>
<script type="module">
    import {putBackCursorPosition} from "./resources/js/cursor.js";
    import {Octokit, App} from "https://cdn.skypack.dev/octokit";


    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    const gistId = urlParams.get('gistId')
    const octokit = new Octokit({});


    if (gistId != null) {
        const gist = await octokit.request('GET /gists/{gist_id}', {
            gist_id: gistId
        });
        ace.edit("editor").setValue(Object.entries(gist.data.files).find(entry => entry[1].language == "Java")[1].content, -1);
        const expectedOutput = Object.entries(gist.data.files).find(entry => entry[1].filename == "answers.txt")[1].content;
        if (expectedOutput != null) {
            document.querySelector('#answers').value =
                expectedOutput;
            document.querySelector("#expected-output").hidden = false;
        }
        putBackCursorPosition();

    }

    ace.edit("editor").setValue(js_beautify(ace.edit("editor").getValue(), {        indent_size: 2    }));
</script>
<script>


    // load gist if any


    function onSubmit() {
        var code = ace.edit("editor").getValue();
        document.querySelector("#code").value = utf8_to_b64(code);
        document.querySelector("textarea.answers").value = utf8_to_b64(document.querySelector('#answers').value);
        const position = ace.edit("editor").getCursorPosition();
        localStorage.setItem("position-row", position.row);
        localStorage.setItem("position-column", position.column);
        document.querySelector("form").submit();
    }

    document.addEventListener('keyup', function (e) {
        if (e.ctrlKey && e.code == "Enter") {
            onSubmit();
        }
    }, false);

    function utf8_to_b64(str) {
        return window.btoa(unescape(encodeURIComponent(str)));
    }

    function b64_to_utf8(str) {
        return decodeURIComponent(escape(window.atob(str)));
    }

</script>
</html>
