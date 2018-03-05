@IsTest
private class TrainingServiceImpl_Test 
{
    @IsTest
    static void GetAllPathsTest()
    {
        Badge__c badge1=TrainingTestFixtures.GetBadge('Test 1');
        Training_Path__c path1=TrainingTestFixtures.GetTrainingPath('Unit Test 1', badge1.id);

        Badge__c badge2=TrainingTestFixtures.GetBadge('Test 2');
        Training_Path__c path2=TrainingTestFixtures.GetTrainingPath('Unit Test 2', badge2.id);

        Candidate_Restrictions__c cr1=TrainingTestFixtures.GetCandidateRestrictions('test.test',
                                                                                   'test@test.test', '');

        Training_Path_Candidate_Restriction__c tpcr1=
                new Training_Path_Candidate_Restriction__c(Training_Path__c=path1.id,
                                                           Candidate_Restriction__c=cr1.id);
        insert tpcr1;

        Candidate_Restrictions__c cr2=TrainingTestFixtures.GetCandidateRestrictions('test.test',
                                                                                   '', 'test@test.test');

        Training_Path_Candidate_Restriction__c tpcr2=
                new Training_Path_Candidate_Restriction__c(Training_Path__c=path2.id,
                                                           Candidate_Restriction__c=cr2.id);
        insert tpcr2;

        TrainingServiceImpl service=new TrainingServiceImpl();

        List<TrainingPath> allPaths=service.GetAllPaths('test@test.test');
        System.assertEquals(1, allPaths.size());
    }

    @IsTest
    static void GetPathTest()
    {
        Badge__c badge1=TrainingTestFixtures.GetBadge('Test 1');
        Training_Path__c tp1=TrainingTestFixtures.GetTrainingPath('Unit Test 1', badge1.id);

        TrainingServiceImpl service=new TrainingServiceImpl();

        TrainingPath path=service.GetPath(tp1.Id, 'test@test.test');
        System.assertNotEquals(null, path);
    }

    @IsTest
    static void GetStepTest()
    {
        Badge__c badge1=TrainingTestFixtures.GetBadge('Test 1');
        Training_Path__c tp1=TrainingTestFixtures.GetTrainingPath('Unit Test 1', badge1.id, 5);
        List<Training_Step__c> steps=[select id from Training_Step__c where Training_Path__c = :tp1.id];
        TrainingTestFixtures.GetTrainingQuestionWithAnswers(steps[2].Id, 'Unit Test', 10, 3);

        TrainingServiceImpl service=new TrainingServiceImpl();

        TrainingPath path=service.GetStep(tp1.Id, steps[2].Id, 'test@test.test');
        System.assertNotEquals(null, path);
        System.assertEquals(5, path.steps.size());
    }

    @IsTest
    static void PassStepTest()
    {
        Badge__c badge1=TrainingTestFixtures.GetBadge('Test 1');
        Training_Path__c tp1=TrainingTestFixtures.GetTrainingPath('Unit Test 1', badge1.id, 1);
        List<Training_Step__c> steps=[select id from Training_Step__c where Training_Path__c = :tp1.id];

        TrainingServiceImpl service=new TrainingServiceImpl();

        Boolean passed=service.PassStep(tp1.Id, steps[0].id, 'test@test.test');
        System.assertEquals(true, passed);
    }

    @IsTest
    static void FailStepAndWaitTest()
    {
        Badge__c badge1=TrainingTestFixtures.GetBadge('Test 1');
        Training_Path__c tp1=TrainingTestFixtures.GetTrainingPath('Unit Test 1', badge1.id, 1);
        tp1.Hours_Between_Attempts__c=2;
        update tp1;

        List<Training_Step__c> steps=[select id from Training_Step__c where Training_Path__c = :tp1.id];

        TrainingServiceImpl service=new TrainingServiceImpl();

        TrainingPath path=service.FailStepAndWait(tp1.Id, steps[0].id, 'test@test.test');

        System.assert(path.lastAttemptTimeMillis<=System.now().getTime());
    }


    @IsTest
    static void GetUserInfoTest()
    {
        Badge__c badge1=TrainingTestFixtures.GetBadge('Test 1');
        Candidate_Badge__c cb=TrainingTestFixtures.GetCandidateBadge(badge1.Id, 'test@test.test');

        TrainingServiceImpl service=new TrainingServiceImpl();

        TrainingUserInfo userInfo=service.GetUserInfo('test@test.test');

        System.assertEquals(userInfo.badgeCount, 1);
    }
}
