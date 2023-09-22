import {Octokit} from "https://esm.sh/octokit";


export async function createNewGist(content, access_token) {
    const octokit = new Octokit({
        auth: access_token
    })

    octokit.request('POST /gists', {
        description: 'Created from MIAGE Code Crafting',
        'public': true,
        files: {
            'Main.java': {
                content: content
            }

        }
    }).then(response => {
        window.open(response.data.html_url, "_blank");
        const gistUrl = new URL("?gistId=" + response.data.id, document.location).href;
        octokit.request('POST /gists/{gist_id}/comments', {
            gist_id: response.data.id,
            body: 'Run this gist on [' + gistUrl + "](" + gistUrl + ")"
        });
        window.location = gistUrl;
    });
};

export async function updateGistContent(content, access_token, gistId) {
    const octokit = new Octokit({
        auth: access_token
    })

    await octokit.request('PATCH /gists/{gist_id}', {
        gist_id: gistId,
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

