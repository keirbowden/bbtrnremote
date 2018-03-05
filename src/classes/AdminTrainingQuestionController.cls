public with sharing class AdminTrainingQuestionController 
{
    @AuraEnabled 
    public static Id CreateNewQuestionFromStep(String stepIdStr)
    {
        Training_Question__c question=new Training_Question__c(Training_Step__c=stepIdStr);
        insert question;

        return question.Id;
    }

    @AuraEnabled
    public static QuestionAndAnswers GetQuestionAndAnswers(String questionIdStr) 
    {
        Training_Question__c question=DataAccessor.GetQuestion(questionIdStr);
        List<Training_Answer__c> answers=DataAccessor.GetAnswers(question.id);
        System.debug('Answers = ' + answers);
        QuestionAndAnswers result=new QuestionAndAnswers();
        result.question=question;
        result.answers=answers;

        return result;
    }

    @AuraEnabled
    public static QuestionAndAnswers Save(String qandaJSON)
    {
        System.debug('QANDA JSON = ' + qandaJSON);

        QuestionAndAnswers qanda=(QuestionAndAnswers) JSON.deserialize(qandaJSON, QuestionAndAnswers.class);
        System.debug('QANDA = ' + qanda);
        if (null!=qanda.question.Id)
        {
            // figure out if any answers have been deleted

            List<Training_Answer__c> toDelete=new List<Training_Answer__c>();

            // put the new answers with ids into a map
            Map<Id, Training_Answer__c> answersById=new Map<Id, Training_Answer__c>();
            answersById.putAll(qanda.answers);
            System.debug('AnswersById = ' + answersById);

            // get the current answers from the database
            List<Training_Answer__c> answersFromDB=DataAccessor.GetAnswers(qanda.question.Id);
            for (Training_Answer__c answer : answersFromDB)
            {
                System.debug('Looking for answer with id ' + answer.id + ' in map');
                if (null==answersById.get(answer.id))
                {
                    toDelete.add(answer);
                }
            }

            delete toDelete;
        }
        
        // update/insert the question and answers
        upsert qanda.question;

        List<Training_Answer__c> answersToUpsert=new List<Training_Answer__c>();

        for (Training_Answer__c answer : qanda.answers)
        {
            if (null==answer.Id) {
                Training_Answer__c newAnswer=
                            new Training_Answer__c(Answer__c=answer.Answer__c,
                                                   Index__c=answer.Index__c,
                                                   Training_Question__c=qanda.question.id);
                answersToUpsert.add(newAnswer);
            }
            else {
                answersToUpsert.add(answer);
            }
        }

        upsert answersToUpsert;

        return GetQuestionAndAnswers(qanda.question.Id);
    }

    public class QuestionAndAnswers
    {
        @AuraEnabled
        public Training_Question__c question {get; set;}

        @AuraEnabled
        public List<Training_Answer__c> answers {get; set;}

        public QuestionAndAnswers()
        {
            answers=new List<Training_Answer__c>();
        }
    }
}
