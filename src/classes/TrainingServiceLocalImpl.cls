public with sharing class TrainingServiceLocalImpl implements TrainingServiceIF 
{ 
    // Gets all the paths even if the user has completed them
    public List<TrainingPath> GetAllPaths(String email)
    {
        List<Training_Path__c> paths=[select id, Name 
                                     from Training_Path__c
                                     order by CreatedDate];

        List<Candidate_Path__c> userPaths=[select id, Percent_Complete__c, Training_Path__c
                                           from Candidate_Path__c
                                           where Candidate_Email__c=:email];


        Map<Id, Candidate_Path__c> cpsByTPId=new Map<Id, Candidate_Path__c>();
        for (Candidate_Path__c cp : userPaths)
        {
            cpsByTPId.put(cp.Training_Path__c, cp);
        }

        List<TrainingPath> result=new List<TrainingPath>();
        for (Training_Path__c tp : paths)
        {
            TrainingPath path=new TrainingPath();
            path.name=tp.Name;
            Decimal percentComplete=0;
            Candidate_Path__c cp=cpsByTPId.get(tp.Id);
            if (null!=cp)
            {
                percentComplete=cp.Percent_Complete__c;
            }

            path.pathId=tp.Id;
            path.percentComplete=percentComplete.intValue();

            result.add(path);
        }

        return result;
    }

    // Gets the details of a single path, including a high level
    // view of the steps
    public TrainingPath GetPath(String pathIdStr, String email)
    {
        Training_Path__c trPath=DataAccessor.GetTrainingPath(pathIdStr);
        Candidate_Path__c userPath=DataAccessor.GetOrCreateCandidatePath(trPath, email);

        TrainingPath path=new TrainingPath();
        path.pathId=trPath.Id;
        path.Name=trPath.Name;
        for (Candidate_Step__c cs : userPath.Candidate_Steps__r)
        {
            TrainingPath.TrainingStep step=new TrainingPath.TrainingStep();
            step.id=cs.Training_Step__c;
            step.name=cs.Training_Step__r.Name;
            step.description=cs.Training_Step__r.Description__c;
            step.complete=cs.Complete__c;
            path.steps.add(step);
        }

        return path;
    }

    // Gets the details of a step, including the questions
    // and answers
    public TrainingPath GetStep(String pathIdStr, String stepIdStr, String email)
    {
        System.debug('Step id = ' + stepIdStr);
        Training_Path__c trPath=DataAccessor.GetTrainingPath(pathIdStr);

        Training_Step__c trStep=DataAccessor.GetTrainingStep(stepIdStr);

        Candidate_Step__c cStep=DataAccessor.GetCandidateStep(stepIdStr, email);

        TrainingPath path=new TrainingPath();
        path.name=trPath.Name;

        TrainingPath.TrainingStep step=new TrainingPath.TrainingStep();
        step.name=trStep.name;
        step.complete=cStep.Complete__c;

        for (Integer idx=1; idx<=5; idx++)
        {
            String heading=(String) trStep.get('Heading_' + idx + '__c');
            if (null!=heading)
            {
                TrainingPath.TrainingStepSection section=new TrainingPath.TrainingStepSection();
                section.heading=heading;
                section.content=(String) trStep.get('Content_' + idx + '__c');
                step.sections.add(section);
            }
            path.steps.add(step);
        }

        List<Training_Question__c> trQuestions=DataAccessor.GetTrainingStepQuestions(stepIdStr);

        for (Training_Question__c trQuestion : trQuestions)
        {
            TrainingPath.TrainingStepQuestion question=new TrainingPath.TrainingStepQuestion();
            question.question=trQuestion.Question__c;
            question.idx=trQuestion.Index__c.intValue();
            question.correct=trQuestion.Correct_Answer_Index__c.intValue();
            for (Training_Answer__c trAnswer : trQuestion.Training_Answers__r)
            {
                TrainingPath.TrainingStepAnswer answer=new TrainingPath.TrainingStepAnswer();
                answer.idx=trAnswer.Index__c.intValue();
                answer.answer=trAnswer.Answer__c;

                question.answers.add(answer);
            }
            step.questions.add(question);
        }

        return path;
    }

    // Marks a user as having passed a step. If this means that
    // the user has passed the path, returns true
    public Boolean PassStep(String pathIdStr, String stepIdStr, String email)
    {
        Candidate_Path__c cPath=DataAccessor.GetOrCreateCandidatePath(pathIdStr, email);

        Candidate_Step__c cStep=DataAccessor.GetCandidateStep(stepIdStr, email);

        cStep.Complete__c=true;

        update cStep;

        cPath=DataAccessor.GetOrCreateCandidatePath(pathIdStr, email);
        
        return cPath.Complete__c;
    }
    
    // Gets the user infomation, such as badges, points etc
    public TrainingUserInfo GetUserInfo(String email)
    {
        TrainingUserInfo info=new TrainingUserInfo();
        info.email=email;
        info.points=12000;
        info.badges=DataAccessor.getUserBadges(email).size();

        return info;
    }
}
