public with sharing class AdminTrainingStepController {
    @AuraEnabled 
    public static Id CloneStep(String stepIdStr)
    {
        Training_Step__c stepToClone=DataAccessor.GetTrainingStep(stepIdStr);
        Map<Id, Training_Question__c> trainingQAndAToCloneById=new Map<Id, Training_Question__c>();
        trainingQAndAToCloneById.putAll(DataAccessor.GetTrainingStepQuestions(stepIdStr));
        
        Training_Step__c step=stepToClone.clone(false, true);
        insert step;

        List<Training_Question__c> questions=new List<Training_Question__c>();

        for (Training_Question__c questionToClone : trainingQAndAToCloneById.values())
        {
            Training_Question__c question=questionToClone.clone(false, true);
            question.Training_Step__c=step.id;
            questions.add(question);
        }

        insert questions;

        Integer idx=0;
        List<Training_Answer__c> answers=new List<Training_Answer__c>();

        for (Training_Question__c questionToClone : trainingQAndAToCloneById.values())
        {
           Training_Question__c question=questions[idx++];
            for (Training_Answer__c answerToClone : questionToClone.Training_Answers__r)
            {
                Training_Answer__c answer=answerToClone.clone(false, true);
                answer.Training_Question__c=question.Id;
                answers.add(answer);
            }
        }

        insert answers;

        return step.Id;
    }
}
