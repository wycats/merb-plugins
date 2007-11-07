/**
 * 
 */
 

/** 
This software is licensed under a MIT license.

Copyright (c) 2006-2007 Robert Egglestone <robert@cs.auckland.ac.nz>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
*/

package jerbivore;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.io.OutputStream;
import java.io.FileInputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Calendar;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.nio.channels.FileChannel;
import java.nio.ByteBuffer;

/**
 * This servlet returns a static file.
 *
 * @author Robert Egglestone
 */
public class FileServlet extends HttpServlet {

    private static final String METHOD_DELETE = "DELETE";
    private static final String METHOD_HEAD = "HEAD";
    private static final String METHOD_GET = "GET";
    private static final String METHOD_OPTIONS = "OPTIONS";
    private static final String METHOD_POST = "POST";
    private static final String METHOD_PUT = "PUT";
    private static final String METHOD_TRACE = "TRACE";
    public static final String FALLBACK_SERVLET_PROPERTY = "files.default";
    private static final String[] DEFAULT_WELCOME_FILES = {"index.html", "index.htm"};
    public final static String CACHE_CONTROL_HEADER = "Cache-Control";
    public final static String EXPIRES_HEADER = "Expires";
    public final static String DATE_HEADER = "Date";
    private int bufferSize = 1024;
    private File root;
    private String prefix;
    private boolean setCacheHeaders;
    private int maxAge;
    /**
     * A servlet to pass control to if the file does not exist.
     */
    private String defaultServletDispatcherName;

    /**
     * Initialize the servlet, and determine the webapp root.
     */
    public void init() throws ServletException {
        prefix = findPrefix();
        root = findRoot();

        // determine the cache values
        setCacheHeaders = getServletConfig().getInitParameter("maxAge") != null;
        if (setCacheHeaders) {
            maxAge = Integer.parseInt(getServletConfig().getInitParameter("maxAge"));
        }

        // check for default fallback servlet
        ServletContext context = getServletContext();
        String defaultServletName = getServletConfig().getInitParameter("defaultServlet");
        if (defaultServletName == null) {
            defaultServletName = context.getInitParameter(FileServlet.FALLBACK_SERVLET_PROPERTY);
        }
        if (defaultServletName != null && defaultServletName.length() != 0) {
            defaultServletDispatcherName = defaultServletName;
        }
    }

    /**
     * A prefix to prepend on the path when translating from URL to file location, typically "/public".
     */
    protected String findPrefix() {
        String prefix = getServletContext().getInitParameter("files.prefix");
        if (prefix == null) {
            prefix = "/public";
        }
        // prefix must start with a slash if it's specified
        if (prefix.length() > 0 && !prefix.startsWith("/")) {
            prefix = "/" + prefix;
        }
        return prefix;
    }

    /**
     * Root of the webapp, may be null in which case it is determined from the servlet api.
     * The root should be an absolute path that refers to a directory.
     */
    protected File findRoot() throws ServletException {
        String rootPath = getServletContext().getInitParameter("files.root");
        if (rootPath == null) {
            rootPath = getPath(getServletContext(), "/");
        }

        File root = new File(rootPath);
        if (!root.isDirectory()) {
            throw new ServletException("Webapp root does not point to a directory");
        }

        return root;
    }

    public String[] getWelcomeFiles() {
        String[] welcomeFiles;

        String welcomeFilesString = getServletContext().getInitParameter("files.welcome");
        if (welcomeFilesString != null) {
            welcomeFiles = parseCommaList(welcomeFilesString);
        } else {
            welcomeFiles = DEFAULT_WELCOME_FILES;
        }

        return welcomeFiles;
    }

    private String[] parseCommaList(String commaList) {
        String[] parts = commaList.split(",");
        for (int i = 0; i < parts.length; i++) {
            parts[i] = parts[i].trim();
        }
        return parts;
    }

    /**
     * Look for a file matching the request.
     */
    protected File getFile(HttpServletRequest request) {
        // find the location of the file
        String contextPath = request.getContextPath();
        String relativePath = request.getRequestURI().substring(contextPath.length());

        // normalize the path
        relativePath = relativePath.replaceAll("\\\\", "/").replaceAll("//", "/");

        // determine the file path to check for
        String filePath;
        if (root == null) {
            filePath = prefix + relativePath;
        } else {
            filePath = root.getAbsolutePath() + prefix + relativePath;
        }

        return getFile(filePath);
    }

    /**
     * Look for a file matching the specified path.
     * This should also check default extensions, and for index files in the case of a directory.
     */
    protected File getFile(String filePath) {
        // try the exact match
        File fileLocation = getExactFile(filePath);
        if (fileLocation != null) {
            return fileLocation;
        }

        // try default extension
        fileLocation = getExactFile(filePath + ".html");
        if (fileLocation != null) {
            return fileLocation;
        }

        // try welcome files
        String[] welcomeFiles = getWelcomeFiles();
        for (int i = 0; i < welcomeFiles.length; i++) {

            fileLocation = getExactFile(filePath + "/" + welcomeFiles[i]);
            if (fileLocation != null) {
                return fileLocation;
            }
        }

        // no match was found
        return null;
    }

    /**
     * Look for a file with this exact path.
     */
    protected File getExactFile(String path) {
        // try to load the resource
        File filePath = new File(path);
        if (!filePath.isFile()) {
            return null;
        }
        return filePath;
    }

    private String formatDateForHeader(Date date) {
        String safari3OnlyAccessThisStyleDataFormat = "EEE, d MMM yyyy HH:mm:ss z";
        return new SimpleDateFormat(safari3OnlyAccessThisStyleDataFormat).format(date);
    }

    /**
     * Transfer the file.
     */
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // check the file and open it
            File fileLocation = getFile(request);
            if (fileLocation != null) {
            // file was found, all good
            } else if (defaultServletDispatcherName != null) {
                // forward request to the default servlet
                getServletContext().getNamedDispatcher(defaultServletDispatcherName).forward(request, response);
                return;
            } else {
                // file not found
                log("File not found: " + request.getRequestURI());
                throw new FileNotFoundException(request.getRequestURI());
            }

            // check for modifications
            long ifModifiedSince = request.getDateHeader("If-Modified-Since");
            long lastModified = fileLocation.lastModified();
            if (lastModified > 0) {
                response.setDateHeader("Last-Modified", lastModified);
                if (ifModifiedSince != -1 && lastModified <= ifModifiedSince) {
                    throw new NotModifiedException();
                }
            }

            // set cache headers
            if (setCacheHeaders) {
                response.setHeader(CACHE_CONTROL_HEADER, "max-age=" + maxAge);
                Calendar now = Calendar.getInstance();
                response.setHeader(DATE_HEADER, formatDateForHeader(now.getTime()));
                now.add(Calendar.SECOND, maxAge);
                response.setHeader(EXPIRES_HEADER, formatDateForHeader(now.getTime()));
            }

            // set the content type
            String contentType = guessContentTypeFromName(fileLocation.getName());
            response.setContentType(contentType);

            if (request.getMethod().equals(METHOD_HEAD)) {
            // head requests don't send the body
            } else if (request.getMethod().equals(METHOD_GET) || request.getMethod().equals(METHOD_POST)) {
                // transfer the content
                sendFile(fileLocation, response);
            } else {
                // anything else cannot be processed on the file
				// alternatively we could forward to rails, but this
				// approach is probably more consistent with other web servers
                response.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED);
            }

        } catch (NotModifiedException e) {
            response.setStatus(HttpServletResponse.SC_NOT_MODIFIED);
        } catch (FileNotFoundException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        } catch (IOException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    /**
     * Send the file, faster, but requires the file is accessible on the file system.
     */
    private void sendFile(File file, HttpServletResponse response) throws IOException {
        // setup IO streams
        ByteBuffer buffer = ByteBuffer.allocate(bufferSize);
        FileChannel in = null;
        try {
            in = new FileInputStream(file).getChannel();

            // start returning the response
            OutputStream out = response.getOutputStream();

            // read the bytes, returning them in the response
            while (in.read(buffer) != -1) {
                out.write(buffer.array(), 0, buffer.position());
                buffer.clear();
            }
            out.close();
        } finally {
            try {
                if (in != null) {
                    in.close();
                }
            } catch (IOException ignore) {
            }
        }
    }

    /**
     * Return the content-type the would be returned for this file name.
     */
    public String guessContentTypeFromName(String fileName) {
        // quick hack for types that are necessary, but not handled
        String lowerName = fileName.toLowerCase();
        if (lowerName.endsWith(".css")) {
            return "text/css";
        } else if (lowerName.endsWith(".js")) {
            return "text/js";
        }
        try {
            // everything else
            javax.activation.FileTypeMap typeMap =
                    javax.activation.FileTypeMap.getDefaultFileTypeMap();
            return typeMap.getContentType(fileName);
        } catch (Throwable t) {
            // allow activation.jar to be missing
            return "application/octet-stream";
        }
    }

    /**
     * Locate a relative webapp path on the file system.
     */
    public String getPath(ServletContext context, String path) throws ServletException {
        // the proper way of doing this
        String realPath = context.getRealPath(path);

        // WebLogic returns a file URL for getResource, but doesn't support getRealPath
        if (realPath == null) {
            try {
                URL resourcePath = context.getResource(path);
                if (resourcePath.getProtocol().equals("file")) {
                    realPath = resourcePath.getPath();
                }
            } catch (MalformedURLException e) {
            // fallback to other mechanisms
            }
        }

        // make a best effort attempt
        if (realPath == null) {
            // make an attempt, as this is a fatal error
            File realFile = new File("." + path);
            if (realFile.exists()) {
                realPath = realFile.getAbsolutePath();
            }
        }

        // fatal error
        if (realPath == null) {
            throw new ServletException("Cannot find the real path of this webapp, probably using a non-extracted WAR");
        }

        // normalize path
        if (realPath.endsWith("/")) {
            realPath = realPath.substring(0, realPath.length() - 1);
        }

        return realPath;
    }

    /**
     * An exception when the source object has not been modified. While this
     * condition is not a failure, it is a break from the normal flow of
     * execution.
     */
    private static class NotModifiedException extends IOException {

        public NotModifiedException() {
        }
    }
}
