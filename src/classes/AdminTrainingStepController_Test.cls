@isTest
private class AdminTrainingStepController_Test 
{
    @IsTest
    static void CloneStepTest()
    {
        Badge__c badge=TrainingTestFixtures.GetBadge('Test');
        Training_Path__c path=TrainingTestFixtures.GetTrainingPath('Unit Test', badge.id);

        Training_Step__c step=[select id, Training_Path__c from Training_Step__c where Training_Path__c=:path.id];

        Test.startTest();

        Id clonedStepId=AdminTrainingStepController.CloneStep(step.Id);

        Test.stopTest();

        Training_Step__c clonedStep=DataAccessor.GetTrainingStep(clonedStepId);
        System.assertNotEquals(clonedStep.Id, step.Id, 'Id of original and cloned step should be different');
        System.assertEquals(clonedStep.Training_Path__c, step.Training_Path__c, 
                            'Training path for original and cloned step should be identical');

        List<Training_Question__c> questions=DataAccessor.GetTrainingStepQuestions(step.Id);
        List<Training_Question__c> clonedQuestions=DataAccessor.GetTrainingStepQuestions(clonedStepId);

        System.assertEquals(clonedQuestions.size(), questions.size(), 'Should be the same number of questions and cloned questions');

        for (Integer idx=0; idx<questions.size(); idx++)
        {
            Training_Question__c question=questions[idx];
            Training_Question__c clonedQuestion=questions[idx];
            System.assertNotEquals(clonedQuestion.Id, question.Id, 'Question and cloned question ids should be different for index ' + idx);

            System.assertEquals(clonedQuestion.Training_Answers__r.size(), question.Training_Answers__r.size(),
                                'Answers and cloned answers size should be the same for question index ' + idx);

            for (Integer adx=0; adx<question.Training_Answers__r.size(); adx++)
            {
                System.assertNotEquals(clonedQuestion.Training_Answers__r[adx].Id, question.Training_Answers__r[adx].Id, 
                                'Answer and cloned answer ids should be different for index ' + adx);
            }
        }
    }
}
