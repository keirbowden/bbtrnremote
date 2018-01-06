public with sharing class BadgeUtils {
    public static void AssignBadgeIfPathComplete(List<Candidate_Path__c> cPaths) 
    {
        Map<Id, List<Candidate_Path__c>> completedByTrainingPathId=new Map<Id, List<Candidate_Path__c>>();
        for (Candidate_Path__c cPath : cPaths)
        {
            if (cPath.Complete__c) 
            {
                List<Candidate_Path__c> cPathsForTr=completedByTrainingPathId.get(cPath.Training_Path__c);
                if (null==cPathsForTr)
                {
                    cPathsForTr=new List<Candidate_Path__c>();
                    completedByTrainingPathId.put(cPath.Training_Path__c, cPathsForTr);
                }
                cPathsForTr.add(cPath);
            }
        }

        List<Id> trPathIds=new List<Id>();
        trPathIds.addAll(completedByTrainingPathId.keySet());
        List<Training_Path__c> trPaths=DataAccessor.GetTrainingPaths(trPathIds);

        List<Candidate_Badge__c> cBadges=new List<Candidate_Badge__c>();
        for (Training_Path__c trPath : trPaths) 
        {
            List<Candidate_Path__c> cPathsForTr=completedByTrainingPathId.get(trPath.id);
            for (Candidate_Path__c cPath : cPathsForTr)
            {
                Candidate_Badge__c cBadge=new Candidate_Badge__c(Candidate_Email__c=cPath.Candidate_Email__c,
                                                                 Badge__c=trPath.Badge__c);
                cBadges.add(cBadge);
            }
        }

        insert cBadges;
    }
}
