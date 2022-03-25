public with sharing class CK_ConfigsController {

    @AuraEnabled(cacheable=true)
    public static Wrapper getAvailableConfigs(){
        try {
            List<Config__c> lstConfigs = [SELECT Id, Label__c, Amount__c, Type__c FROM Config__c ORDER BY Name];
            Integer count = [SELECT Count() FROM Config__c];
            return new Wrapper(count, lstConfigs);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class Wrapper {
        @AuraEnabled
        public Integer count;
        @AuraEnabled
        public List<Config__c> lstConfigs = new List<Config__c>();

        public Wrapper(Integer count, List<Config__c> lstConfigs){
            this.count = count;
            this.lstConfigs = lstConfigs;
        }
    }

    @AuraEnabled
    public static DataTransferObjects.OperationResult createCaseConfigs(String caseId, List<Config__c> lstSelectedConfigs){
        List<String> lstValidations = new List<String>();
        try {
            List<Case_Config__c> lstCaseConfigs = new List<Case_Config__c>();
            for(Config__c eachConfig : lstSelectedConfigs){
                Case_Config__c eachCaseConfig = new Case_Config__c();
                eachCaseConfig.Label__c = eachConfig.Label__c;
                eachCaseConfig.Type__c = eachConfig.Type__c;
                eachCaseConfig.Amount__c = eachConfig.Amount__c;
                eachCaseConfig.Case__c = caseId;
                lstCaseConfigs.add(eachCaseConfig);
            }

            if(!lstCaseConfigs.isEmpty()){
                Database.SaveResult[] srList = Database.insert(lstCaseConfigs, false);
                Integer count = 0;
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        count++;
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            lstValidations.add(err.getMessage());
                        }
                    }
                }
                if(count == 0){
                    return new DataTransferObjects.OperationResult(false,lstValidations);
                }
                return new DataTransferObjects.OperationResult(true);
            }
            lstValidations.add('Something failed. Please contact your System Admin!');
            return new DataTransferObjects.OperationResult(false,lstValidations);
        } catch (Exception exc) {
            lstValidations.add(exc.getMessage());
            return new DataTransferObjects.OperationResult(false,lstValidations);
        }
    }


    @AuraEnabled(cacheable=true)
    public static List<Case_Config__c> getCaseConfigs(String caseId){
        try {
            List<Case_Config__c> lstCaseConfigs = [SELECT Id, Label__c, Amount__c, Type__c FROM Case_Config__c WHERE Case__c = :caseId ORDER BY Name];
            return lstCaseConfigs;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static DataTransferObjects.OperationResult sendRequest(String caseId, String payload){
        List<String> lstValidations = new List<String>();
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:RequestCatcherClark');
            request.setMethod('POST');     
            request.setBody(payload);
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                String resBody = response.getbody();
                String jsonStr = resBody.replaceAll( '\\s+', ''); //Before parsing the JSON string, I have removed the space.
                system.debug('resBody '+resBody);

                Case eachCase = new Case();
                eachCase.Id = caseId;
                eachCase.Status = 'Closed';
                update eachCase;

                return new DataTransferObjects.OperationResult(true);
            }
            else {
                lstValidations.add('Information could not be posted to the server. Please contact your System Admin.');
                return new DataTransferObjects.OperationResult(false,lstValidations);
            }
        } catch (Exception exc) {
            lstValidations.add(exc.getMessage());
            return new DataTransferObjects.OperationResult(false,lstValidations);
        }
    }
}