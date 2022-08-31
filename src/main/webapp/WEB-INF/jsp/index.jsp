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
                <input type="button" value="auth" id="ghauth">


                <c:choose>
                    <c:when test="${empty gistId}">
                        <input type="button" value="save" id="gistsave">
                    </c:when>
                    <c:otherwise>
                        <input type="button" value="update" id="gistupdate">
                    </c:otherwise>
                </c:choose>
                <input type="button" value="link" id="gistshare" hidden>


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


<script type="module">
    import {Octokit, App} from "https://cdn.skypack.dev/octokit";

    export async function createNewGist(content) {
        const octokit = new Octokit({
            auth: localStorage.getItem("access_token")
        })

        octokit.request('POST /gists', {
            description: 'Created from MIAGE Code Crafting',
            'public': false,
            files: {
                'Main.java': {
                    content: content
                },
                'answers.txt': {
                    content: "tbd"
                },
                'Comments.md': {
                    content: "# Description \n## Teaching Goals\n## Hints"
                }
            }
        }).then(response => {
            window.open(response.data.html_url, "_blank");
            const gistUrl=new URL("?gistId=" + response.data.id, document.location).href;
            document.querySelector("#gistshare").setAttribute("share_link", gistUrl)
            document.querySelector("#gistshare").hidden = false;
            window.location=gistUrl;
        });
    };

    export async function updateGistContent(content) {
        const octokit = new Octokit({
            auth: localStorage.getItem("access_token")
        })

        await octokit.request('PATCH /gists/{gist_id}', {
            gist_id: "${gistId}",
            description: 'An update to a gist',
            'public': false,
            files: {
                'Main.java': {
                    content: content
                }

            }
        }).then(response => {
            alert("Your gist have been updated");
        });
    };

    document.querySelector("#ghauth").addEventListener("click",
        function githubAuth() {
            window.open("https://github.com/login/oauth/authorize?client_id=${client_id}=gist");
        });
    document.querySelectorAll("#gistsave").forEach(e => e.addEventListener("click",
        function onGistSaveClicked() {
            createNewGist(ace.edit("editor").getValue());
        }
    ));

    document.querySelectorAll("#gistupdate").forEach(e => e.addEventListener("click",
        function onGistUpdateClicked() {
            updateGistContent(ace.edit("editor").getValue());
        }
    ));

    document.querySelectorAll("#gistshare").forEach(e => e.addEventListener("click",
        function () {
            const imgURL = new URL("./resources/img/mcc-gist.png", document.location).href;
            const url = document.querySelector("#gistshare").getAttribute("share_link");
            const clip = url;
            navigator.clipboard.writeText(clip);
            const previousValue=document.querySelector("#gistshare").value;
            document.querySelector("#gistshare").value="copied!"
            setTimeout(function() { document.querySelector("#gistshare").value= previousValue}, 5000);
        }
    ));


</script>


<script src="https://cdnjs.cloudflare.com/ajax/libs/js-beautify/1.6.8/beautify.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/ace.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/ext-beautify.min.js"></script>
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
        ace.edit("editor").getSession().setValue(Object.entries(gist.data.files).find(entry => entry[1].language == "Java")[1].content);
        const expectedOutput = Object.entries(gist.data.files).find(entry => entry[1].filename == "answers.txt")[1].content;
        if (expectedOutput != null) {
            document.querySelector('#answers').value = expectedOutput;
            document.querySelector("#expected-output").hidden = false;
        }
        putBackCursorPosition();


    }

    ace.edit("editor").getSession().setValue(js_beautify(ace.edit("editor").getValue(), {indent_size: 2}));
    putBackCursorPosition();
</script>
<script>


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


    window.addEventListener("load", function (e) {
        if (ace.edit("editor").getValue() == "") {
            ace.edit("editor").getSession().setValue(localStorage.getItem("code"));
        }
        ace.edit("editor").on('change', e => {
            localStorage.setItem("code", ace.edit("editor").getValue());
        });
        <c:if test="${not empty gistId}">
        const gistUrl=new URL("?gistId=${gistId}", document.location).href;
        document.querySelector("#gistshare").setAttribute("share_link", gistUrl);
        document.querySelector("#gistshare").hidden=false;
        </c:if>
    });

    function utf8_to_b64(str) {
        return window.btoa(unescape(encodeURIComponent(str)));
    }

    function b64_to_utf8(str) {
        return decodeURIComponent(escape(window.atob(str)));
    }

</script>
</html>
