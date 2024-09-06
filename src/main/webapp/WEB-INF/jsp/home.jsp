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

<div class="container my-5">
    <h1 class="text-center">Exercices d'application JAVA MIAGE Sorbonne</h1>
    <div id="results" class="accordion" id="accordionExample">
        <!-- Dynamic content will be inserted here -->
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>
<script type="module">

    import {setupEventChannel, logEvent} from "${eventSinkServer}/js/feedback.js";

    <c:if test="${authToken!=null}">
    setupEventChannel("${eventSinkWsAddress}", "${authToken}", "javarunner", function () {
        let payload = {"url": window.location};
        logEvent("java-runner-home-loaded", payload);
    })
    </c:if>

    function overlayOn(icon) {
        var overlay = document.getElementById("overlay");

        var elClone = overlay.cloneNode(true);

        overlay.parentNode.replaceChild(elClone, overlay);
        elClone.style.display = "block";

        for (let choice of elClone.querySelectorAll(".assessment")) {
            choice.logged("java-runner-home-assess-exercice", {
                    "assessment": choice.getAttribute("feddback-type"),
                    "exerciseId": icon.id
                },
                "click", function (event) {
                    overlayOff(icon);
                    icon.classList.remove("hithere");
                });
        }

    }

    function overlayOff(icon) {
        document.getElementById("overlay").style.display = "none";
    }

    function cliked_not_started_icon(icon) {
        logEvent("java-runner-home-started-exercice", {"exerciceID": icon.id});
        icon.classList.toggle("bi-hourglass-top");
        localStorage.setItem(icon.id, "started");
        icon.classList.add("bi-hourglass-split");
    }

    //when clicking on the icon, rotate the status
    function setupExercices() {
        for (const icon of document.querySelectorAll("i.exercise")) {

            icon.addEventListener("click", function () {


                if (icon.classList.contains("bi-hourglass-top")) {
                    cliked_not_started_icon(icon);
                } else if (icon.classList.contains("bi-hourglass-split")) {
                    icon.classList.toggle("bi-hourglass-split");
                    localStorage.setItem(icon.id, "done");
                    icon.classList.add("bi-emoji-smile-fill");
                    icon.classList.add("hithere");

                } else if (icon.classList.contains("bi-emoji-smile-fill") && icon.classList.contains("hithere")) {
                    overlayOn(icon);
                } else if (icon.classList.contains("bi-emoji-smile-fill") && !icon.classList.contains("hithere")) {
                    if (confirm('Etes-vous sûr de vouloir passer l\'exercice à "non démarré?')) {
                        icon.classList.toggle("bi-emoji-smile-fill");
                        icon.classList.add("bi-hourglass-top");
                        localStorage.setItem(icon.id, "not started");
                    }
                }
                logEvent("java-runner-home-exercice-status-changed", {
                    "exerciceID": icon.id,
                    "status": localStorage.getItem(icon.id)
                });
                ;


            });
            icon.previousElementSibling.addEventListener("click", function () {
                if (icon.classList.contains("bi-hourglass-top")) {
                    cliked_not_started_icon(icon);

                }
                window.open(icon.previousElementSibling.getAttribute("href"), '_blank').focus();
            }, false);

            //get the icon status from the local storage, and update their classes
            var status = localStorage.getItem(icon.id);
            switch (status) {
                case "not started":
                    icon.classList.add("bi-hourglass-top");
                    break;
                case "started":
                    icon.classList.add("bi-hourglass-split");
                    break;
                case "feedback needed":
                    icon.classList.add("bi-emoji-smile-fill");
                    icon.classList.add("hithere");
                    break;
                case "done":
                    icon.classList.add("bi-emoji-smile-fill");
                    icon.classList.remove("hithere");
                    break;
                default:
                    localStorage.setItem(icon.id, "not started");
                    icon.classList.add("bi-hourglass-top");
            }
        }
    };

    // Replace with the actual API URL
    const API_URL = '${codeSnippetAPIURL}/snippet/all';

    // Fetch snippets from the API
    fetch(API_URL, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    })
        .then(response => response.json())
        .then(data => {
            const snippets = data;

            // Sort snippets by promo, then course, then section
            snippets.sort((a, b) => {
                const promoA = a.metas.find(meta => meta.key === 'promo')?.value || '';
                const promoB = b.metas.find(meta => meta.key === 'promo')?.value || '';
                const courseA = a.metas.find(meta => meta.key === 'course')?.value || '';
                const courseB = b.metas.find(meta => meta.key === 'course')?.value || '';
                const sectionA = a.metas.find(meta => meta.key === 'section')?.value || '';
                const sectionB = b.metas.find(meta => meta.key === 'section')?.value || '';

                return promoA.localeCompare(promoB) || courseA.localeCompare(courseB) || sectionA.localeCompare(sectionB);
            });

            // Group snippets by promo, course, and section
            const groupedSnippets = {};
            snippets.forEach(snippet => {
                const promo = snippet.metas.find(meta => meta.key === 'promo')?.value || '';
                const course = snippet.metas.find(meta => meta.key === 'course')?.value || '';
                const section = snippet.metas.find(meta => meta.key === 'section')?.value || '';

                if (!groupedSnippets[promo]) {
                    groupedSnippets[promo] = {};
                }
                if (!groupedSnippets[promo][course]) {
                    groupedSnippets[promo][course] = {};
                }
                if (!groupedSnippets[promo][course][section]) {
                    groupedSnippets[promo][course][section] = [];
                }
                groupedSnippets[promo][course][section].push(snippet);
            });

            // Render the HTML structure
            const resultsDiv = document.getElementById('results');
            let html = '';

            Object.keys(groupedSnippets).forEach(promo => {
                if (promo !== "") {
                    html += `
          <div class="accordion-item">
            <h2 class="accordion-header" id="heading-\${promo}">
              <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapse-\${promo}" aria-expanded="true" aria-controls="collapse-\${promo}">
                Promo: \${promo}
              </button>
            </h2>
            <div id="collapse-\${promo}" class="accordion-collapse collapse" aria-labelledby="heading-\${promo}" data-bs-parent="#accordionExample">
              <div class="accordion-body">
        `;
                }

                Object.keys(groupedSnippets[promo]).forEach(course => {
                    if (course !== "") {
                        html += `
            <div class="mb-3">
                <h5 class="text-primary border-bottom pb-2">Course: \${course}</h5>
            </div>
          `;
                    }

                    Object.keys(groupedSnippets[promo][course]).forEach(section => {
                        if (section !== "") {
                            html += `
                <div class="mb-2">
                    <h6 class="text-secondary">Section: \${section}</h6>
                    <ul class="list-group">
            `;

                            groupedSnippets[promo][course][section].forEach(snippet => {
                                html += `
 <li class="list-group-item d-flex justify-content-between align-items-center">
                    <button class="btn btn-outline-secondary"
                            href="${pageContext.request.contextPath}/?snipId=\${snippet.id}">\${snippet.title}</button>
                    <i id="snip-\${snippet.id}" class="exercise bi bi-hourglass-top"></i>
                </li>`;
                            });

                            html += `
                    </ul>
                </div>
            `;
                        }
                    });

                    html += `
          `;
                });

                html += `
              </div>
            </div>
          </div>
        `;
            });

            resultsDiv.innerHTML = html;
            setupExercices();
        })
        .catch(error => console.error('Error fetching snippets:', error));
</script>

</div>

<div id="overlay" style="display: none">
    <div class="overlay-content"><p>Comment était l'exercice?</p>
        <p class="container">

        <div class="row overlay-icons">
            <div class="col assessment" feddback-type="hard">
                <i class="bi bi-person-exclamation"></i>
                <div class="col">
                    Difficile
                </div>
            </div>
            <div class="col assessment" feddback-type="ok">
                <i class="bi bi-person"></i>
                <div class="col text-center">
                    Ça va
                </div>
            </div>
            <div class="col assessment" feddback-type="easy">
                <i class="bi bi-person-fill-check"></i>
                <div class="col text-center">
                    Facile
                </div>
            </div>
        </div>


        </p>
    </div>

</div>
</body>


</html>
