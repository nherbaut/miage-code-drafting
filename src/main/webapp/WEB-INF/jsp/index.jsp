<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="color-scheme" content="light dark">
    <title>Miage Code Crafting</title>
    <script
            type="module"
            src="https://cdn.jsdelivr.net/gh/zerodevx/zero-md@2/dist/zero-md.min.js"
    ></script>

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


    <link href="${pageContext.request.contextPath}/resources/css/style.css" rel="stylesheet">


</head>
<body>
<div id="main-container" class="container-fluid">


    <div class="row">
        <div class="col-12">
            <span id="logo"></span>
            <a href="${pageContext.request.contextPath}/home?filter=L3"><h1 class="main">MIAGE Code Crafting</h1>
            </a>
            <span id="gist_title"></span></h1>
        </div>
    </div>
    <div class="row" id="editor-row">

        <div class="col-12" id="editor"><c:out value="${code}"/></div>
    </div>
    <div class="row">
        <div class="col-12">
            <div class="btn-group" role="group" aria-label="Button group with nested dropdown">
                <div class="btn-group" role="group">
                    <button class="btn btn-secondary dropdown-toggle" type="button"
                            data-bs-toggle="dropdown" aria-expanded="false">GitHub Actions
                    </button>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item btn btn-secondary" href="#" id="ghauth">authorize github</a>
                        </li>
                        <li>
                            <hr class="dropdown-divider">
                        </li>
                        <c:choose>
                            <c:when test="${empty gistId}">
                                <li><a class="dropdown-item btn btn-secondary" id="gistsave" disabled>Save as
                                    new Gist
                                </a></li>
                            </c:when>
                            <c:otherwise>
                                <li><a class="dropdown-item btn btn-secondary" id="gistupdate" hidden>Update
                                    Gist

                                </a></li>
                                <li>
                                    <a class="dropdown-item btn btn-secondary" id="gistshare" hidden>Open in new
                                        tab
                                    </a>
                                </li>
                                <li>
                                    <a class="dropdown-item btn btn-secondary" id="gisthtmlurl" hidden>Open
                                        original Gist
                                    </a>
                                </li>
                            </c:otherwise>
                        </c:choose>
                    </ul>
                </div>
                <button type="button" class="btn btn-sm btn-secondary" id="save-maven">Download as Maven
                </button>
                <button type="button" id="btn-instructions" class="btn btn-sm btn-info" type="submit"
                        data-bs-toggle="collapse" data-bs-target="#collapseInstructions" aria-expanded="false"
                        aria-controls="collapseInstructions" hidden>Get
                    Instructions
                </button>
                <button type="button" id="btn-run" class="btn btn-sm btn-primary" type="submit">Run (CTRL+ENTER)
                </button>


            </div>
        </div>

        <div hidden>
            <c:choose>
            <c:when test="${empty gistId}">
            <form id="theform" method="POST" enctype="multipart/form-data">
                </c:when>
                <c:otherwise>
                <form id="theform" method="POST" gistId="${gistId}" updated="true" enctype="multipart/form-data">
                    <input name="gistId" value="${gistId}" hidden>
                    </c:otherwise>
                    </c:choose>
                    <textarea name="code" id="code" hidden></textarea>
                </form>
        </div>

    </div>

    <div class="row row-cols-1 row-cols-md-2 g-4">
        <div class="col-12">
            <div class="card bg-warning text-dark collapse" style="width: 40rem;" id="collapseInstructions">
                <div class="card-header">Instructions</div>
                <div class="card-body">
                    <p class="card-text" id="instructions-text">
                        Some placeholder content for the collapse component. This panel is hidden by default but
                        revealed
                        when the user activates the relevant trigger.
                    </p>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-12">
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
        </div>


    </div>
    <div class="row" id="expected-output" hidden>

        <div class="col-12">
            <h2>Expected Output:</h2>
            <textarea readonly id="answers">${answers}</textarea>
            <textarea readonly class="answers" hidden name="answers"></textarea>
        </div>
    </div>


</div>


<script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.24.1/ace.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.24.1/mode-java.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.24.1/ext-language_tools.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.24.1/theme-textmate.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM"
        crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>

<span id="codeTooltip">issue here</span>
</body>


<script type="module">
    import {putBackCursorPosition} from "${pageContext.request.contextPath}/resources/js/cursor.js";

    ace.require("ace/ext/language_tools");
    export const editor = ace.edit("editor");
    editor.setTheme("ace/theme/textmate");
    editor.session.setMode("ace/mode/java");
    editor.setOptions({

        fontSize: "11pt",
        enableBasicAutocompletion: true
    });

    //editor.focus();
    putBackCursorPosition();

</script>


<script type="module">
    import {putBackCursorPosition} from "${pageContext.request.contextPath}/resources/js/cursor.js";
    import {Octokit, App} from "https://esm.sh/octokit";


    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    const gistId = urlParams.get('gistId')
    const updated = urlParams.get('updated')

    const octokit = new Octokit({});


    if (gistId != null) {
        const gist = await octokit.request('GET /gists/{gist_id}', {
            gist_id: gistId
        });
        document.getElementById("btn-instructions").hidden = false;


        var comments = Object.entries(gist.data.files).find(entry => entry[1].filename == "Comments.md");
        if (comments !== undefined && comments.length > 0) {
            comments = comments[1].content;
            if (comments != null && comments != "") {
                document.getElementById("instructions-text").innerHTML = marked.parse(comments);


            }
        }

        document.getElementById("btn-instructions").setAttribute("href", gist.data.html_url + "#file-comments-md");
        document.getElementById("btn-instructions").setAttribute("title", gist.data.html_url + "#file-comments-md");
        if ((updated == null || updated == false)) {

            ace.edit("editor").getSession().setValue(Object.entries(gist.data.files).find(entry => entry[1].language == "Java")[1].content);
            document.querySelector("span#gist_title").innerHTML = gist.data.description;

            var expectedOutput = Object.entries(gist.data.files).find(entry => entry[1].filename == "answers.txt");
            if (expectedOutput !== undefined && expectedOutput.length > 0) {
                expectedOutput = expectedOutput[1].content;
                if (expectedOutput != null && expectedOutput != "") {
                    document.querySelector('#answers').value = expectedOutput;
                    document.querySelector("#expected-output").hidden = false;
                }
            }
        }

        putBackCursorPosition();
    }

    if (updated == "true" && document.querySelector("#answers").value != "") {
        document.querySelector("#expected-output").hidden = false;
    }


    putBackCursorPosition();
</script>

<script type="module">
    import {updateGistContent, createNewGist} from "${pageContext.request.contextPath}/resources/js/gist.js";
    import {setupEventChannel, logEvent} from "${eventSinkServer}/js/feedback.js";




    setupEventChannel("${eventSinkWsAddress}", "${authToken}", "javarunner",function () {
        let payload = {"loadedCode": ace.edit("editor").getValue()};
        <c:choose>
        <c:when test="${not empty success}">
        payload.wasRun = true;
        payload.runRunResults = {
            "success":${success}
        };

        payload.runRunResults.compilationErrors = [];

        <c:forEach var="compilationError" items="${compilationErrors}">
        payload.runRunResults.compilationErrors.push({
            "message": "${compilationError.message()}",
            "kind": "${compilationError.kind()}"
        });
        </c:forEach>
        payload.runRunResults.runtimeErrors = [];

        <c:forEach var="runtimeError" items="${runtimeErrors}">
        payload.runRunResults.runtimeErrors.push({
            "message": "${runtimeError.message()}",
            "kind": "${runtimeError.kind()}"
        });

        </c:forEach>


        payload.runRunResults.stdout = "${stdout}";
        </c:when>


        </c:choose>

        logEvent("java-runner-loaded", payload);
    });


    function onSubmit() {

        let form = document.getElementById("theform");

        var code = ace.edit("editor").getValue();
        document.querySelector("#code").value = utf8_to_b64(code);
        if (document.querySelector('#answers')) {
            document.querySelector("textarea.answers").value = utf8_to_b64(document.querySelector('#answers').value)
        }
        const position = ace.edit("editor").getCursorPosition();
        localStorage.setItem("position-row", position.row);
        localStorage.setItem("position-column", position.column);


        const params = new Proxy(new URLSearchParams(window.location.search), {
            get: (searchParams, prop) => searchParams.get(prop),
        });
        var url = new URL(window.location);
        if (params.token != undefined) {
            url.searchParams.set("token", params.token);
        }
        url.searchParams.set("updated", true);
        form.setAttribute("action", url);
        logEvent("submit-code", {"code": code})
        document.querySelector("form").submit();
    }

    document.addEventListener('keyup', function (e) {
        if (e.ctrlKey && e.code == "Enter") {
            onSubmit();
        }

    }, false);

    document.querySelector("#btn-run").addEventListener('click', onSubmit, false);


    document.querySelector("#save-maven").addEventListener("click", function () {
        const code = ace.edit("editor").getValue();
        fetch("https://maven-project-factory.miage.dev",
            //fetch("http://localhost:8080/maven",
            {body: code, method: "POST"}).then(e => e.blob()).then(b => {
            var file = window.URL.createObjectURL(b);
            window.location.assign(file);
        });
    })


    window.addEventListener("load", function (e) {


        var tooltip = document.getElementById('codeTooltip');
        document.addEventListener('mousemove', function fn(e) {
            tooltip.style.left = e.pageX + 'px';
            tooltip.style.top = e.pageY + 'px';
        }, false);


        // update gist callback
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('hideanswers') == "true") {
            document.querySelector("#theform").setAttribute("action", document.querySelector("#theform").getAttribute("action") + "&hideanswers=true");
            document.querySelector("#expected-output").hidden = true;
        }


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

                    var f = function () {
                        if (localStorage.getItem("access_token")) {
                            location.reload();
                        } else {
                            setTimeout(f, 1000);
                        }
                    };
                    setTimeout(f, 1000);


                });

        }


        ace.edit("editor").on('change', e => {
            localStorage.setItem("code", ace.edit("editor").getValue());
            for (let m of Object.entries(ace.edit("editor").getSession().getMarkers(true))) {
                ace.edit("editor").getSession().removeMarker(m[0]);
            }
            logEvent("code-changed", {
                "newCode": {
                    "code": ace.edit("editor").getValue()
                }
            }, 500);
        });


        var Range = ace.require("ace/range").Range;
        var markerMessageMap = Map;
        var firstErrorLine = -1;
        <c:choose>
        <c:when test="${compilationErrors.size()>0}">
        <c:forEach var="compilationError" items="${compilationErrors}">

        {
            var range = new Range(${compilationError.startRow()}, ${compilationError.startColumn()}, ${compilationError.endRow() }, ${compilationError.endColumn()});
            firstErrorLine = range.start.row;
            var marker = ace.edit("editor").getSession().addMarker(range, "myCustomMouseOverHighlight-${compilationError.kind()}", "line", true);
            markerMessageMap[marker] = '${compilationError.message()}';
        }

        </c:forEach>
        </c:when>
        </c:choose>

        <c:choose>
        <c:when test="${runtimeErrors.size()>0}">
        <c:forEach var="runtimeError" items="${runtimeErrors}">

        {
            var range = new Range(${runtimeError.startRow()}, 0, ${runtimeError.endRow() }, 100);
            firstErrorLine = range.start.row;
            var marker = ace.edit("editor").getSession().addMarker(range, "myCustomMouseOverHighlight-${runtimeError.kind()}", "fullLine", true);
            markerMessageMap[marker] = '${runtimeError.message()}';
        }

        </c:forEach>
        </c:when>
        </c:choose>

        if (firstErrorLine != -1) {
            var editor = ace.edit('editor');
            editor.resize(true);

            editor.scrollToLine(firstErrorLine, true, true, function () {
            });

            editor.gotoLine(firstErrorLine);

        }


        ace.edit("editor").on("mousemove", function (e) {
            var atLeastOneVisible = false;
            tooltip.innerHTML = "";
            for (let m of Object.entries(ace.edit("editor").getSession().getMarkers(true))) {
                if (m[1].range) {
                    let id = m[0];
                    var curRow = e.getDocumentPosition().row;
                    var curCol = e.getDocumentPosition().column;
                    var mSRow = m[1].range.start.row;
                    var mERow = m[1].range.end.row;
                    var mSCol = m[1].range.start.column;
                    var mECol = m[1].range.end.column;
                    if (curRow >= mSRow && curRow <= mERow && curCol >= mSCol && curCol <= mECol) {
                        tooltip.innerHTML += markerMessageMap[id];
                        atLeastOneVisible = true;
                    }
                }
            }
            if (!atLeastOneVisible) {
                tooltip.classList.remove("visible");
            } else {
                tooltip.classList.add("visible");
            }

        });


        <c:choose>
        <c:when test="${not empty gistId}">

        document.querySelector("#gistupdate").hidden = false;
        document.querySelector("#gistshare").hidden = false;
        document.querySelector("#gisthtmlurl").hidden = false;

        document.querySelector("#gistshare").addEventListener("click", function () {
            window.open(new URL("?gistId=${gistId}", document.location).href, "_blank");


        });
        document.querySelector("#gisthtmlurl").addEventListener("click", function () {

            window.open("https://gist.github.com/${gistId}", "_blank");


        });

        </c:when>
        <c:otherwise>
        if (ace.edit("editor").getValue() == "" && localStorage.getItem("code") != null) {
            ace.edit("editor").getSession().setValue(localStorage.getItem("code"));
        }
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
