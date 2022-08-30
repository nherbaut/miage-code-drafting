<%--
  Created by IntelliJ IDEA.
  User: nherbaut
  Date: 30/08/2022
  Time: 02:07
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet"
          integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">

    <style>
        #editor {
            width: 500px;
            height: 300px;
        }
    </style>

    <style>
        textarea {
            width: 500px;
            height: 300px;
        }
    </style>
</head>
<body>
<form method="POST" action="./">
    <div class="container px-4">
        <div class="row gx-5">
            <h1 class="display-1">MIAGE Code Drafting</h1>
        </div>
        <div class="row gx-5">
            <div id="editor">${code}</div>
        </div>

        <div class="row gx-5">
            <input type="submit" onclick="onSubmit()"/>
        </div>
        <div class="row gx-5">

            <textarea name="code" id="code" hidden></textarea>
            <textarea name="result">${result}</textarea>


        </div>




    </div>
</form>

<script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/ace.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/ext-beautify.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/mode-java.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/ext-language_tools.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.9.6/theme-github.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM"
        crossorigin="anonymous"></script>

</body>
<script>

    var editor = ace.edit("editor");
    editor.setTheme("ace/theme/github");
    editor.session.setMode("ace/mode/java");


    function onSubmit() {
        var code = ace.edit("editor").getValue();
        document.querySelector("#code").value = code;
        submit();
    }

</script>
</html>
