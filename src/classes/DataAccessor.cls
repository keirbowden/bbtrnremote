public with sharing class DataAccessor {
    public static Training_Path__c GetTrainingPath(String pathIdStr) 
    {
        return GetTrainingPaths(new List<Id> {(Id) pathIdStr})[0];
    }

    public static List<Training_Path__c> GetTrainingPaths(List<Id> pathIds) 
    {
        List<Training_Path__c> paths=[select id, Name, Description__c, Badge__c,
                                      (select id, Name, Description__c from Training_Steps__r)
                                      from Training_Path__c
                                      where id IN :pathIds];
        return paths;
    }

    public static Candidate_Path__c GetOrCreateCandidatePath(Id pathId, String email)
    {
        Training_Path__c path=GetTrainingPath(pathId);
        return GetOrCreateCandidatePath(path, email);
    }

    public static Candidate_Path__c GetOrCreateCandidatePath(Training_Path__c path, String email)
    {
        Candidate_Path__c result=null;
        List<Candidate_Path__c> cps=[select id, Complete__c,
                                     (select id, Complete__c, Training_Step__r.Index__c,
                                     Training_Step__r.Name, Training_Step__r.Description__c
                                      from Candidate_Steps__r
                                      order by Training_Step__r.Index__c asc)
                                     from Candidate_Path__c
                                     where Training_Path__c=:path.Id
                                     and Candidate_Email__c=:email];
        if (cps.IsEmpty())
        {
            Candidate_Path__c cp=new Candidate_Path__c(Training_Path__c=path.Id,
                                                       Candidate_Email__c=email);
            insert cp;
            List<Candidate_Step__c> cSteps=new List<Candidate_Step__c>();
            for (Training_Step__c step : path.Training_Steps__r)
            {
                Candidate_Step__c cStep=new Candidate_Step__c(Candidate_Path__c=cp.Id,
                                                             Training_Step__c=step.Id);
                cSteps.add(cStep);
            }

            insert cSteps;
            // call this function again to query out the new records.
            result=GetOrCreateCandidatePath(path, email);
        }
        else 
        {
            result=cps[0];
        }

        return result;
    }

    public static Training_Step__c GetTrainingStep(String stepIdStr)
    {
        Training_Step__c step=[select id, Name, Description__c, 
                                    Heading_1__c, Content_1__c,
                                    Heading_2__c, Content_2__c,
                                    Heading_3__c, Content_3__c,
                                    Heading_4__c, Content_4__c,
                                    Heading_5__c, Content_5__c
                               from Training_Step__c
                               where id=:stepIdStr
                               ];

        return step;
    }

    public static Candidate_Step__c GetCandidateStep(String stepIdStr, String email)
    {
        Candidate_Step__c step=[select id, Complete__c 
                                from Candidate_Step__c
                                where Training_Step__c=:stepIdStr
                                  and Candidate_Path__r.Candidate_Email__c=:email];

        return step;
    }

    public static List<Training_Question__c> GetTrainingStepQuestions(String stepIdStr) 
    {
        List<Training_Question__c> questions=[select id, Index__c,
                                                Question__c, Correct_Answer_Index__c,
                                              (select Answer__c, Index__c
                                               from Training_Answers__r
                                               order by Index__c asc) 
                                              from Training_Question__c
                                              where Training_Step__c=:stepIdStr 
                                              order by Index__c asc];

        return questions;
    }
    
    public static List<Candidate_Badge__c> GetUserBadges(String email)
    {
        return [select Id, Name, Badge__r.Name
                from Candidate_Badge__c 
                where Candidate_Email__c=:email];
    }
}
