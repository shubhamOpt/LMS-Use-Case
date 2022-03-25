@isTest
public class ConfigMockingServiceFail implements HttpCalloutMock{
	public HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('callout:RequestCatcherClark', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"caseId":"5005j00000LOyCxAAL","status":"Closed","caseConfigs":[{"label":"Config1","type":"1","amount":250.5},{"label":"Config3","type":"3","amount":600},{"label":"Config8","type":"8","amount":700},{"label":"Config2","type":"2","amount":500}]}');
        res.setStatusCode(400);
        return res;
    }
}