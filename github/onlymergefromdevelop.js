/*
GitHub webhook, to be deployed on webtask.io, that fails if one tries to merge a
branch other than "develop" to "master".

Usage:

 - Create a Github API token with `repo` access from: https://github.com/settings/tokens/new
 - Generate the webhook url, substituting <YOUR_TOKEN> with the one from above: `wt create --name protectmaster --secret GITHUB_TOKEN=<YOUR_TOKEN> --prod onlymergefromdevelop.js
 - Install the webhook with the default settings on your repo (see https://developer.github.com/guides/building-a-ci-server/)
 - Optionally inspect any errors using the cli: `wt logs`
*/

var Request = require('request');

var API_URL = 'https://api.github.com';

module.exports = function (ctx, cb) {
    var payload = ctx.body.pull_request;
    console.log(payload);
    if (ctx.body.action !== "opened" || payload.base.ref !== "master") {
        console.log("Either not PR to master or not new PR: " +
                    ctx.body.action + ", " + payload.base.ref);
        cb(null, "All done, not a relevant PR.");
        return;
    }

    var ok = (payload.head.ref === "develop") ? "success" : "error";
    var headers = {"Authorization": "Bearer " + ctx.data.GITHUB_TOKEN,
                   "User-Agent": "develop->master merge enforcer"};
    var url = API_URL + '/repos/' + payload.base.repo.full_name + '/statuses/' + payload.head.sha;
    console.log("API URL: " + url);
    var options = {
        url: url,
        headers: headers,
        json: true,
        body: {
            "state": ok,
            "target_url": "http://webtask.io",
            "description": "Only develop can be merged into master.",
            "context": "webtask"
        }
    };
    Request.post(options, function (error, response, body) {
        console.log("Result from API request: ");
        console.log(error);
        console.log(response.statusCode);
        console.log(body);
        console.log("PR to master from " + payload.head.ref + " is a " + ok);
        cb(null, "All done, set PR status.");
    });
};
