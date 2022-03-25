@isTest
public with sharing class CK_ConfigsControllerTest {
    @TestSetup
    static void makeData(){

        Integer intNumberOfRecords = 5; 

        List<Config__c> lstConfigs = new List<Config__c>();

        for(Integer i = 0; i < intNumberOfRecords; i++){
            Config__c eachConfig = new Config__c();
            eachConfig.Label__c = 'Config-'+i;
            eachConfig.Amount__c = i * 10;
            eachConfig.Type__c = String.valueOf(i);
            lstConfigs.add(eachConfig);
        }

        if(!lstConfigs.isEmpty()){
            insert lstConfigs;
        }

        Case eachCase = new Case();
        eachCase.Status = 'New';
        insert eachCase;
    }

    @isTest
    public static void testGetAvailableConfigs(){
        CK_ConfigsController.Wrapper eachWrap = CK_ConfigsController.getAvailableConfigs();
        system.debug('eachWrap '+eachWrap);
        System.assertEquals(5, eachWrap.count, '5 Config records retrieved successfully!');
        System.assertEquals('Config-0', eachWrap.lstConfigs[0].Label__c, 'Config records retrieved ordered by name!');
    }

    @isTest
    public static void testCreateCaseConfigs(){
        Case eachCase = [SELECT Id FROM Case LIMIT 1];
        List<Config__c> lstSelectedConfigs = [SELECT Id,Label__c, Type__c, Amount__c FROM Config__c LIMIT 3];

        Test.startTest();
        DataTransferObjects.OperationResult objResult = CK_ConfigsController.createCaseConfigs(eachCase.Id,lstSelectedConfigs);
        Test.stopTest();

        system.debug('objResult '+objResult);
        System.assertEquals(true, objResult.isSuccess, 'Case Configs Created Successfully!');
    }
    
    @isTest
    public static void testCreateCaseConfigsFail(){
        Case eachCase = [SELECT Id FROM Case LIMIT 1];
        
        Case_Config__c eachCaseConfig = new Case_Config__c();
        eachCaseConfig.Label__c = 'Config-0';
        eachCaseConfig.Amount__c = 10;
        eachCaseConfig.Type__c = '1';
        eachCaseConfig.Case__c = eachCase.Id;
        insert eachCaseConfig;
        
        List<Config__c> lstSelectedConfigs = [SELECT Id,Label__c, Type__c, Amount__c FROM Config__c WHERE Label__c = 'Config-0' LIMIT 1];

        Test.startTest();
        DataTransferObjects.OperationResult objResult = CK_ConfigsController.createCaseConfigs(eachCase.Id,lstSelectedConfigs);
        Test.stopTest();

        System.assertEquals(false, objResult.isSuccess, 'Case Configs Creation failed!');
    }
    
    @isTest
    public static void testCreateCaseConfigsFail2(){
        Case eachCase = [SELECT Id FROM Case LIMIT 1];
               
        List<Config__c> lstSelectedConfigs = new List<Config__c>();

        Test.startTest();
        DataTransferObjects.OperationResult objResult = CK_ConfigsController.createCaseConfigs(eachCase.Id,lstSelectedConfigs);
        Test.stopTest();

        System.assertEquals(false, objResult.isSuccess, 'Case Configs Creation failed!');
    }
    
    @isTest
    public static void testCreateCaseConfigsFail3(){
        Case eachCase = [SELECT Id FROM Case LIMIT 1];
        
        Case_Config__c eachCaseConfig = new Case_Config__c();
        eachCaseConfig.Label__c = 'Config-0';
        eachCaseConfig.Amount__c = 10;
        eachCaseConfig.Type__c = '1';
        eachCaseConfig.Case__c = eachCase.Id;
        insert eachCaseConfig;
        
        List<Config__c> lstSelectedConfigs = [SELECT Id FROM Config__c WHERE Label__c = 'Config-0' LIMIT 1];

        Test.startTest();
        DataTransferObjects.OperationResult objResult = CK_ConfigsController.createCaseConfigs(eachCase.Id,lstSelectedConfigs);
        Test.stopTest();

        System.assertEquals(false, objResult.isSuccess, 'Case Configs Creation failed!');
    }
    
    @isTest
    public static void testGetCaseConfigs(){
        
        Case eachCase = [SELECT Id FROM Case LIMIT 1];
        List<Case_Config__c> lstCaseConfigs = new List<Case_Config__c>();
        
        for(Integer i = 0; i < 2; i++){
            Case_Config__c eachCaseConfig = new Case_Config__c();
            eachCaseConfig.Label__c = 'Config-'+i;
            eachCaseConfig.Amount__c = i * 10;
            eachCaseConfig.Type__c = String.valueOf(i);
            eachCaseConfig.Case__c = eachCase.Id;
            lstCaseConfigs.add(eachCaseConfig);
        }
        
        if(!lstCaseConfigs.isEmpty()){
            insert lstCaseConfigs;
        }
        
        Test.startTest();
        List<Case_Config__c> lstCaseConfigsNew = CK_ConfigsController.getCaseConfigs(eachCase.Id);
        Test.stopTest();
        
        System.assertEquals(lstCaseConfigsNew.size(), 2, 'Two Case Configs retrieved successfully!');
    }
    
    @isTest
    public static void testSendRequest(){
        Case eachCase = [SELECT Id FROM Case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new ConfigMockingService());
        String payload = '';
        Test.startTest();
        DataTransferObjects.OperationResult objResult = CK_ConfigsController.sendRequest(eachCase.Id,payload);
        Test.stopTest();
        System.assertEquals(true, objResult.isSuccess, 'Case Configs posted successfully!');
    }
    
    @isTest
    public static void testSendRequestFail(){
        Case eachCase = [SELECT Id FROM Case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new ConfigMockingServiceFail());
        String payload = '';
        Test.startTest();
        DataTransferObjects.OperationResult objResult = CK_ConfigsController.sendRequest(eachCase.Id,payload);
        Test.stopTest();
        System.assertEquals(false, objResult.isSuccess, 'Case Configs callout failed!');
    }
        
}