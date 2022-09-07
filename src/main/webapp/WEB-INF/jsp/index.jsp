<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
<head>
    <meta charset="utf-8">
    <meta name="color-scheme" content="light dark">
    <title>Miage Code Crafting</title>


    <script>
        if (window.matchMedia("(prefers-color-scheme: dark)").media === "not all") {
            document.documentElement.style.display = "none";
            document.head.insertAdjacentHTML(
                "beforeend",
                "<link href=\"https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css\" rel=\"stylesheet\" integrity=\"sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC\" crossorigin=\"anonymous\">"
            );
        }
    </script>

    <!-- Load the alternate CSS first ...
         in this case the Bootstrap-Dark Variant CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-dark-5@1.1.3/dist/css/bootstrap-night.min.css" rel="stylesheet"
          media="(prefers-color-scheme: dark)">
    <!-- and then the primary CSS last ...
         in this case the (original) Bootstrap Variant CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-dark-5@1.1.3/dist/css/bootstrap.min.css" rel="stylesheet"
          media="(prefers-color-scheme: light)">


    <link href="./resources/css/style.css" rel="stylesheet">


</head>
<body>
<c:choose>
<c:when test="${empty gistId}">
<form method="POST" action="./" enctype="multipart/form-data">
    </c:when>
    <c:otherwise>
    <form method="POST" action="./?gistId=${gistId}&updated=true" enctype="multipart/form-data">
        <input name="gistId" value="${gistId}" hidden>
        </c:otherwise>
        </c:choose>

        <div id="main-container" class="container">
            <div class="row">
                <h1 class="main">MIAGE Code Crafting</h1>
            </div>

            <div class="row">
                <div class="col col-code">
                    <div id="editor" style="width: 100%; height: 500px"><c:out value="${code}"/></div>
                    <button type="button" class="btn btn-sm btn-success" id="ghauth">authorize github</button>


                    <c:choose>
                        <c:when test="${empty gistId}">
                            <button type="button" class="btn btn-sm btn-primary" id="gistsave" disabled>save</button>
                        </c:when>
                        <c:otherwise>
                            <button type="button" class="btn btn-sm btn-primary" id="gistupdate" hidden>update on github
                            </button>
                            <button type="button" class="btn btn-sm btn-primary" id="gistshare" hidden>copy link
                            </button>
                            <button type="button" class="btn btn-sm btn-primary" id="gisthtmlurl" hidden>see on github
                            </button>
                        </c:otherwise>
                    </c:choose>


                </div>
                <div class="col col-res">
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
                    <button id="btn-run" class="btn btn-primary " type="submit">Run (CTRL+ENTER)</button>
                </div>
                <textarea name="code" id="code" hidden></textarea>


            </div>


            <div id="expected-output" hidden>
                <h2>Expected Output:</h2>
                <textarea readonly id="answers">${answers}</textarea>
                <textarea readonly class="answers" hidden name="answers"></textarea>
            </div>


        </div>
    </form>


    <script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/ace.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-java.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/ext-language_tools.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/theme-monokai.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"
            integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM"
            crossorigin="anonymous"></script>

</body>


</script>
<script type="module">
    import {putBackCursorPosition} from "./resources/js/cursor.js";

    ace.require("ace/ext/language_tools");
    export const editor = ace.edit("editor");
    editor.setTheme("ace/theme/monokai");
    editor.session.setMode("ace/mode/java");
    editor.setOptions({

        fontSize: "12pt",
        enableBasicAutocompletion: true
    });

    //editor.focus();
    putBackCursorPosition();

</script>


<script type="module">
    import {putBackCursorPosition} from "./resources/js/cursor.js";
    import {Octokit, App} from "https://cdn.skypack.dev/octokit";


    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    const gistId = urlParams.get('gistId')
    const updated = urlParams.get('updated')
    const octokit = new Octokit({});


    if (gistId != null && (updated == null || updated == false)) {
        const gist = await octokit.request('GET /gists/{gist_id}', {
            gist_id: gistId
        });
        ace.edit("editor").getSession().setValue(Object.entries(gist.data.files).find(entry => entry[1].language == "Java")[1].content);
        const expectedOutput = Object.entries(gist.data.files).find(entry => entry[1].filename == "answers.txt")[1].content;
        if (expectedOutput != null && expectedOutput != "") {
            document.querySelector('#answers').value = expectedOutput;
            document.querySelector("#expected-output").hidden = false;
        }
        putBackCursorPosition();
    }
    if(updated=="true" && document.querySelector("#answers").value!=""){
        document.querySelector("#expected-output").hidden = false;
    }

    putBackCursorPosition();
</script>

<script type="module">
    import {updateGistContent, createNewGist} from "./resources/js/gist.js";


    function onSubmit() {
        var code = ace.edit("editor").getValue();
        document.querySelector("#code").value = utf8_to_b64(code);
        if (document.querySelector('#answers')) {
            document.querySelector("textarea.answers").value = utf8_to_b64(document.querySelector('#answers').value)
        }
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

    document.querySelector("#btn-run").addEventListener('click', onSubmit, false);


    window.addEventListener("load", function (e) {

        // update gist callback


        // enable save if github is authorized
        if (localStorage.getItem("access_token") != null) {


            document.querySelectorAll("#gistupdate").forEach(e => e.addEventListener("click",
                function onGistUpdateClicked() {
                    updateGistContent(ace.edit("editor").getValue(), localStorage.getItem("access_token"), "${gistId}");
                }
            ));

            document.querySelectorAll("#gistsave").forEach(e => e.addEventListener("click",
                function onGistSaveClicked() {
                    createNewGist(ace.edit("editor").getValue(), localStorage.getItem("access_token"));
                }
            ));
            document.querySelector("#ghauth").innerHTML = "github log out";

            document.querySelector("#ghauth").addEventListener("click", function () {
                localStorage.removeItem("access_token");
                location.reload();
            }, true);
        } else {
            document.querySelector("#ghauth").addEventListener("click",
                function () {
                    window.open("https://github.com/login/oauth/authorize?client_id=${client_id}&scope=gist");
                    alert("refresh page once github auth is complete");
                });

        }


        if (ace.edit("editor").getValue() == "" && localStorage.getItem("code") != null) {
            ace.edit("editor").getSession().setValue(localStorage.getItem("code"));
        }
        ace.edit("editor").on('change', e => {
            localStorage.setItem("code", ace.edit("editor").getValue());
        });
        <c:choose>
        <c:when test="${not empty gistId}">

        document.querySelector("#gistupdate").hidden = false;
        document.querySelector("#gistshare").hidden = false;
        document.querySelector("#gisthtmlurl").hidden = false;

        document.querySelector("#gistshare").addEventListener("click", function () {
            navigator.clipboard.writeText(new URL("?gistId=${gistId}", document.location).href);
            const previousValue = document.querySelector("#gistshare").innerHTML;
            document.querySelector("#gistshare").innerHTML = "copied!"
            setTimeout(function () {
                document.querySelector("#gistshare").innerHTML = previousValue
            }, 2000);

        });
        document.querySelector("#gisthtmlurl").addEventListener("click", function () {

            window.open("https://gist.github.com/${gistId}", "_blank");


        });

        </c:when>
        <c:otherwise>
        document.querySelector("#gistsave").disabled = false;
        </c:otherwise>
        </c:choose>
    });

    function utf8_to_b64(str) {
        return window.btoa(unescape(encodeURIComponent(str)));
    }

    function b64_to_utf8(str) {
        return decodeURIComponent(escape(window.atob(str)));
    }

</script>
</html>
