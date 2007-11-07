package jerbivore;

import junit.framework.TestCase;
import org.mortbay.jetty.testing.HttpTester;
import org.mortbay.jetty.testing.ServletTester;

/**
 *
 * @author dudley
 */
public class MerbServletTest extends TestCase {
    private static final String APP_ROOT = 
        "/Users/dudley/Code/Merb/jerbivore/spec/fixtures/fake-app/war";
    private static ServletTester tester;

    public MerbServletTest(String testName) {
        super(testName);
    }            

    @Override
    protected void setUp() throws Exception {
        super.setUp();
        tester = new ServletTester();
        tester.setContextPath("/");
        tester.setResourceBase(APP_ROOT);
        tester.addServlet(MerbServlet.class, "/");
        tester.start();
    }

    @Override
    protected void tearDown() throws Exception {
        super.tearDown();
        tester.stop();
        tester = null;
    }
    
    public void testHandlesARequest() {
        try {
            HttpTester request = new HttpTester();
            HttpTester response = new HttpTester();

            request.setMethod("GET");
            request.setVersion("HTTP/1.0");
            request.setHeader("Host", "tester");
            request.setURI("/fake-app/bar");
            response.parse(tester.getResponses(request.generate()));
        } catch (Exception e) {
            fail(e.getMessage());
        }
    }
}
