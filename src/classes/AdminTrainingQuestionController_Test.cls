@IsTest
private class AdminTrainingQuestionController_Test 
{
    @IsTest
    static void GetQuestionAndAnswersTest()
    {
        Badge__c badge=TrainingTestFixtures.GetBadge('Test');
        Training_Path__c path=TrainingTestFixtures.GetTrainingPath('Unit Test', badge.id);

        Training_Step__c step=[select id from Training_Step__c where Training_Path__c=:path.id];

        Training_Question__c question=
                TrainingTestFixtures.GetTrainingQuestionWithAnswers(step.Id, 
                                                                    'Test Question', 
                                                                    10, 
                                                                    3);

        AdminTrainingQuestionController.QuestionAndAnswers qanda=
                AdminTrainingQuestionController.GetQuestionAndAnswers(question.id);
        System.assertEquals('Test Question', qanda.question.Question__c);
        System.assertEquals(3, qanda.answers.size());
    }

    @IsTest
    static void SaveTest()
    {
        Badge__c badge=TrainingTestFixtures.GetBadge('Test');
        Training_Path__c path=TrainingTestFixtures.GetTrainingPath('Unit Test', badge.id);

        Training_Step__c step=[select id from Training_Step__c where Training_Path__c=:path.id];

        Training_Question__c question=
                TrainingTestFixtures.GetTrainingQuestionWithAnswers(step.Id, 
                                                                    'Test Question', 
                                                                    10, 
                                                                    3);

        AdminTrainingQuestionController.QuestionAndAnswers qanda=
                AdminTrainingQuestionController.GetQuestionAndAnswers(question.id);

        qanda.answers.add(new Training_Answer__c(Training_Question__c=qanda.question.id,
                                                 Index__c=4,
                                                 Answer__c='Test Answer 4'));

        String qaStr=JSON.serialize(qanda);

        AdminTrainingQuestionController.QuestionAndAnswers newQanda=
            AdminTrainingQuestionController.Save(qaStr);

        System.assertEquals(4, newQanda.answers.size());
    }

}
