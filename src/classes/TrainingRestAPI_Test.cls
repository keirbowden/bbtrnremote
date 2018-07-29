@IsTest
private class TrainingRestAPI_Test 
{
    // coverage only - the underlying behaviour is tested by the test class for the 
    // underlying service implementation - e.g. TrainingServiceImpl_Test
    @IsTest
    static void RestAPITest()
    {
        Decimal version=TrainingRestAPI.MY_VERSION;

        RestResponse res = new RestResponse();

        RestContext.response = res;        
        
        Badge__c badge1=TrainingTestFixtures.GetBadge('Test 1');
        Training_Path__c path=TrainingTestFixtures.GetTrainingPath('Unit Test 1', badge1.id, 5);
        List<Training_Step__c> steps=[select id from Training_Step__c where Training_Path__c = :path.id];

        String email='test@test.test';
        TrainingRestAPI.TrainingRequest(TrainingRestAPI.GET_ALL_PATHS_METHOD, email, version, null, null, null);
        TrainingRestAPI.TrainingRequest(TrainingRestAPI.GET_PATH_METHOD, email, version, path.id, null, null);
        TrainingRestAPI.TrainingRequest(TrainingRestAPI.GET_STEP_METHOD, email, version, path.id, steps[0].id, null);
        TrainingRestAPI.TrainingRequest(TrainingRestAPI.PASS_STEP_METHOD, email, version, path.id, steps[0].id, null);
        TrainingRestAPI.TrainingRequest(TrainingRestAPI.FAIL_STEP_AND_WAIT_METHOD, email, version, path.id, steps[0].id, null);
        TrainingRestAPI.TrainingRequest(TrainingRestAPI.GET_USER_INFO_METHOD, email, version, null, null, null);
        TrainingRestAPI.TrainingRequest(TrainingRestAPI.SEARCH_PATHS_FREE_METHOD, email, version, null, null, 'terms');
        TrainingRestAPI.TrainingRequest(TrainingRestAPI.SEARCH_PATHS_TOPICS_METHOD, email, version, null, null, 'terms');

        try 
        {
            TrainingRestAPI.TrainingRequest(TrainingRestAPI.SEARCH_PATHS_TOPICS_METHOD, email, 99.9999, null, null, 'terms');
            System.assert(false, 'Should throw exception');
        }
        catch (System.CalloutException e)
        {
            // expected
        }
    }
}
