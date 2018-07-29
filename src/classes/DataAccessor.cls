public with sharing class DataAccessor {
    public static List<Training_Path__c> GetUserAccessibleTrainingPaths(List<Training_Path__c> paths,
                                                                        String email)
    {
        List<Training_Path__c> results=new List<Training_Path__c>();

        String domain=email.split('@')[1];
        List<Training_Path_Candidate_Restriction__c> tpcrs=
                        [select id, Candidate_Restriction__r.Include_Emails__c, 
                                    Candidate_Restriction__r.Exclude_Emails__c,
                                    Candidate_Restriction__r.Domain__c,
                                    Training_Path__c
                         from Training_Path_Candidate_Restriction__c
                         where Training_Path__c in :paths];

        // only one Training_Path_Candidate_Restriction__c per domain
        Map<Id, List<Training_Path_Candidate_Restriction__c>> tpcrsByPathId=new 
                    Map<Id, List<Training_Path_Candidate_Restriction__c>>();

        for (Training_Path_Candidate_Restriction__c tpcr : tpcrs)
        {
            List<Training_Path_Candidate_Restriction__c> tpcrsForPath=tpcrsByPathId.get(tpcr.Training_Path__c);
            if (null==tpcrsForPath)
            {
                tpcrsForPath=new List<Training_Path_Candidate_Restriction__c>();
                tpcrsByPathId.put(tpcr.Training_Path__c, tpcrsForPath);
            }
            tpcrsForPath.add(tpcr);
        }

        for (Training_Path__c path : paths)
        {
            // default is allow access unless there is a restriction
            Boolean emailOkay=true;
            List<Training_Path_Candidate_Restriction__c> tpcrsForPath=tpcrsByPathId.get(path.id);
            if (null!=tpcrsForPath)
            {
                // we have at least one restriction - assume the user isn't allowed access
                for (Training_Path_Candidate_Restriction__c tpcr : tpcrsForPath)
                {
                    emailOkay=false;

                    // if the domains are the same, check further. If not, no access
                    if (tpcr.Candidate_Restriction__r.Domain__c==domain)
                    {
                        if ( (null==tpcr.Candidate_Restriction__r.Include_Emails__c) && 
                             (null==tpcr.Candidate_Restriction__r.Exclude_Emails__c) )
                        {
                            // no restriction, everyone from this domain is allowed access
                            emailOkay=true;
                        }
                        else if (null!=tpcr.Candidate_Restriction__r.Include_Emails__c) 
                        {
                            // don't allow unless named
                            emailOkay=false;
                            List<String> includes=tpcr.Candidate_Restriction__r.Include_Emails__c.split(',');
                            Set<String> includesSet=new Set<String>();
                            includesSet.addAll(includes);
                            if (includesSet.contains(email))
                            {
                                emailOkay=true;
                            }
                        }
                        else if (null!=tpcr.Candidate_Restriction__r.Exclude_Emails__c) 
                        {
                            // allow unless named
                            emailOkay=true;
                            List<String> excludes=tpcr.Candidate_Restriction__r.Exclude_Emails__c.split(',');
                            Set<String> excludesSet=new Set<String>();
                            excludesSet.addAll(excludes);
                            if (excludesSet.contains(email))
                            {
                                emailOkay=false;
                            }
                        }   

                        // If the user has been allowwd access via a restriction, exit the process here.
                        // Otherwise we may inadvertently remove access due to another domain
                        if (emailOkay)
                        {
                            break;
                        }
                    }
                }
            }

            if (emailOkay)
            {
                results.add(path);
            }
        }

        return results;
    }

    public static Training_Path__c GetTrainingPath(String pathIdStr) 
    {
        return GetTrainingPaths(new List<Id> {(Id) pathIdStr})[0];
    }

    public static List<Training_Path__c> GetTrainingPaths(List<Id> pathIds) 
    {
        List<Training_Path__c> paths=[select id, Name, Summary__c, Description__c, Namespace__c, Badge__c, Topics__c,
                                        Hours_Between_Attempts__c, Multi_Complete__c, Pass_Message__c,                           
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
        List<Candidate_Path__c> cps=[select id, Complete__c, Last_Attempt_Time__c,
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
                                    Admin_Mark__c,
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
        return [select Id, Earned_Count__c, Name, Badge__r.Name, Badge__r.Description__c,
                        CreatedDate
                from Candidate_Badge__c 
                where Candidate_Email__c=:email];
    }

    public static List<Candidate_Badge__c> GetCandidateBadges(Set<Id> badgeIdsSet)
    {
        List<Id> badgeIds=new List<Id>();
        badgeIds.addAll(badgeIdsSet);
        return GetCandidateBadges(badgeIds);
    }

    public static List<Candidate_Badge__c> GetCandidateBadges(List<Id> badgeIds)
    {
        return [select Id, Name, Badge__c, Earned_Count__c, Candidate_Email__c,
                        CreatedDate
                from Candidate_Badge__c 
                where Badge__c in :badgeIds];
    }

    // Methods question/answer access methods
    public static Training_Question__c GetQuestion(String questionIdStr) 
    {
        return [select id, Name, Question__c, Index__c, Correct_Answer_Index__c,
                Training_Step__r.Id 
                from Training_Question__c
                where id=:questionIdStr];
    }

    public static List<Training_Answer__c> GetAnswers(Id questionId)
    {
        System.debug('Querying answers for question ' + questionId);
        return [select Id, Name, Answer__c, Index__c
                from Training_Answer__c 
                where Training_Question__c=:questionId];
    }
    
}
