<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="color-scheme" content="light dark">
    <title>Miage Code Crafting Home</title>


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


    <link href="./resources/css/home.css" rel="stylesheet">

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
</head>

<body>
<div class="container py-4">
    <div class="p-5 mb-4 bg-light rounded-3">
        <div class="container-fluid py-5">
            <h1 class="display-5 fw-bold">Exercices d'application <c:out value="${filter}"/> Université Paris 1 Panthéon-Sorbonne</h1>
            <p class="col-md-8 fs-4"></p>
        </div>
    </div>


    <c:forEach items="${gists.keySet()}" var="gistCategory">
        <h1>${gistCategory}</h1>
        <ul class="list-group">
            <c:forEach items="${gists.get(gistCategory)}" var="gist">
                <li class="list-group-item d-flex justify-content-between align-items-center<WN btn-group ">

                    <button class="btn btn-secondary" href="${pageContext.request.contextPath}/?gistId=${gist.getGistId()}"><c:out
                        value="${gist.description}"></c:out></button><i id="icon-${gist.getGistId()}"></i>
                </li>
            </c:forEach>
        </ul>
        </h1>

    </c:forEach>

</div>
</body>
<script>
    function cliked_not_started_icon(icon) {
        icon.classList.toggle("bi-hourglass-top");
        localStorage.setItem(icon.id, "started");
        icon.classList.add("bi-hourglass-split");
    }
    //when clicking on the icon, rotate the status
    for (const icon of document.querySelectorAll("i")) {

        icon.addEventListener("click", function () {


            if (icon.classList.contains("bi-hourglass-top")) {
                cliked_not_started_icon(icon);
            } else if (icon.classList.contains("bi-hourglass-split")) {
                icon.classList.toggle("bi-hourglass-split");
                localStorage.setItem(icon.id, "done");
                icon.classList.add("bi-emoji-smile-fill");
            } else if (icon.classList.contains("bi-emoji-smile-fill")) {
                icon.classList.toggle("bi-emoji-smile-fill");
                icon.classList.add("bi-hourglass-top");
                localStorage.setItem(icon.id, "not started");
            }
            ;


        });
        icon.previousSibling.addEventListener("click", function () {
            if (icon.classList.contains("bi-hourglass-top")) {
                cliked_not_started_icon(icon);

            }
            window.open(icon.previousSibling.getAttribute("href"), '_blank').focus();
        }, true);

        //get the icon status from the local storage, and update their classes
        var status = localStorage.getItem(icon.id);
        switch (status) {
            case "not started":
                icon.classList.add("bi-hourglass-top");
                break;
            case "started":
                icon.classList.add("bi-hourglass-split");
                break;
            case "done":
                icon.classList.add("bi-emoji-smile-fill");
                break;
            default:
                localStorage.setItem(icon.id, "not started");
                icon.classList.add("bi-hourglass-top");
        }
    }


</script>
</html>
