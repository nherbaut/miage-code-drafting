package fr.pantheonsorbonne.cri.javarunner.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

public class GitHubAuthServlet extends HttpServlet {

    private static final Logger LOGGER = LoggerFactory.getLogger("GitHubAuthServlet");
    private final String ghClientId;
    private final String ghClientSecret;

    public GitHubAuthServlet() {

        System.getenv().forEach((k, v) -> LOGGER.info("{}:{}", k, v));
        ghClientId = System.getenv("GH_CLIENT_ID");
        ghClientSecret = System.getenv("GH_CLIENT_SECRET");
        LOGGER.info("my client id is {}" , ghClientId);
        LOGGER.info("my client secret is {}" , ghClientSecret);
    }

    class ParameterStringBuilder {
        public static String getParamsString(Map<String, String> params)
                throws UnsupportedEncodingException {
            StringBuilder result = new StringBuilder();

            for (Map.Entry<String, String> entry : params.entrySet()) {
                result.append(URLEncoder.encode(entry.getKey(), "UTF-8"));
                result.append("=");
                result.append(URLEncoder.encode(entry.getValue(), "UTF-8"));
                result.append("&");
            }

            String resultString = result.toString();
            return resultString.length() > 0
                    ? resultString.substring(0, resultString.length() - 1)
                    : resultString;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response) throws IOException, ServletException {
        String client_id = ghClientId;
        String code = request.getParameter("code");

        URL url = new URL("https://github.com/login/oauth/access_token");
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("POST");
        Map<String, String> parameters = new HashMap<>();
        parameters.put("client_id", client_id);
        parameters.put("code", code);
        parameters.put("client_secret", ghClientSecret);
        parameters.put("scope", "gist");
        con.setDoOutput(true);
        DataOutputStream out = new DataOutputStream(con.getOutputStream());
        out.writeBytes(ParameterStringBuilder.getParamsString(parameters));
        out.flush();
        out.close();

        int status = con.getResponseCode();
        BufferedReader in = new BufferedReader(
                new InputStreamReader(con.getInputStream()));
        String inputLine;
        StringBuffer content = new StringBuffer();
        while ((inputLine = in.readLine()) != null) {
            content.append(inputLine);
        }
        in.close();
        Map<String, String> responseParams = Arrays.stream(content.toString().split("&")).filter(s -> !s.isEmpty()).collect(Collectors.toMap(s -> {

            return s.split("=")[0];
        }, s -> {
            String[] param = s.split("=");
            if (param.length == 2) {
                return param[1];
            } else {
                return "";
            }
        }));

        for (Map.Entry<String, String> entry : responseParams.entrySet()) {
            request.setAttribute(entry.getKey(), entry.getValue());
        }
        request.getRequestDispatcher("/WEB-INF/jsp/github-callback.jsp").forward(request, response);
    }
}
