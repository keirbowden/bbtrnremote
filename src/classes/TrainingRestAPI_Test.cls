@IsTest
private class TrainingRestAPI_Test 
{
    // coverage only - the underlying behaviour is tested by the test class for the 
    // underlying service implementation - e.g. TrainingServiceImpl_Test
    @IsTest
    static void RestAPITest()
    {
        RestResponse res = new RestResponse();

        RestContext.response = res;        
        
        Badge__c badge1=TrainingTestFixtures.GetBadge('Test 1');
        Training_Path__c path=TrainingTestFixtures.GetTrainingPath('Unit Test 1', badge1.id, 5);
        List<Training_Step__c> steps=[select id from Training_Step__c where Training_Path__c = :path.id];

        String email='test@test.test';
        TrainingRestAPI.TrainingRequest(TrainingRestAPI.GET_ALL_PATHS_METHOD, email, null, null);
        TrainingRestAPI.TrainingRequest(TrainingRestAPI.GET_PATH_METHOD, email, path.id, null);
        TrainingRestAPI.TrainingRequest(TrainingRestAPI.GET_STEP_METHOD, email, path.id, steps[0].id);
        TrainingRestAPI.TrainingRequest(TrainingRestAPI.PASS_STEP_METHOD, email, path.id, steps[0].id);
        TrainingRestAPI.TrainingRequest(TrainingRestAPI.FAIL_STEP_AND_WAIT_METHOD, email, path.id, steps[0].id);
        TrainingRestAPI.TrainingRequest(TrainingRestAPI.GET_USER_INFO_METHOD, email, null, null);
    }
}