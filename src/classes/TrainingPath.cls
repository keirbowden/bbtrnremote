global class TrainingPath
{
    @AuraEnabled 
    public String pathId {get; set;}

    @AuraEnabled 
    public String name {get; set;}

    @AuraEnabled 
    public String description {get; set;}

    @AuraEnabled 
    public Integer percentComplete {get; set;}

    @AuraEnabled
    public Boolean complete {get; set;}
    
    @AuraEnabled
    public TrainingStep[] steps {get; set;}

    global TrainingPath()
    {
        steps=new List<TrainingStep>();
    }

    global class TrainingStep
    {
        @AuraEnabled 
        public String id {get; set;}

        @AuraEnabled 
        public String name {get; set;}

        @AuraEnabled 
        public String description {get; set;}

        @AuraEnabled
        public Boolean complete {get; set;}
        
        @AuraEnabled
        public Boolean pass;
        
        @AuraEnabled
        public TrainingStepSection[] sections {get; set;}

        @AuraEnabled
        public TrainingStepQuestion[] questions {get;set;}

        public TrainingStep()
        {
            questions=new List<TrainingStepQuestion>();
            sections=new List<TrainingStepSection>();
        }
    }

    global class TrainingStepSection
    {
        @AuraEnabled
        public String heading;
        
        @AuraEnabled
        public String content;
    }

    global class TrainingStepQuestion
    {
        @AuraEnabled
        public Integer idx {get; set;}

        @AuraEnabled
        public String question {get; set;}
        
        @AuraEnabled
        public Integer correct;

        @AuraEnabled
        public String selectedAnswerId;

        @AuraEnabled
        public TrainingStepAnswer[] answers {get; set;}

        public TrainingStepQuestion()
        {
            answers=new List<TrainingStepAnswer>();
        }
    }

    global class TrainingStepAnswer
    {
        @AuraEnabled
        public Integer idx {get; set;}

        @AuraEnabled
        public String state {get; set;}

        @AuraEnabled
        public String answer {get; set;}
    }
}
