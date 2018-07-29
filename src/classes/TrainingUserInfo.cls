global with sharing class TrainingUserInfo 
{
    @AuraEnabled 
    public String email {get; set;}

    @AuraEnabled 
    public String firstname {get; set;}

    @AuraEnabled 
    public String initials {get; set;}

    @AuraEnabled 
    public String lastname {get; set;}

    @AuraEnabled      
    public Integer points {get; set;}  

    @AuraEnabled      
    public Integer badgeCount {get; set;}  
    
    @AuraEnabled      
    public List<UserBadge> badges {get; set;}  

    public TrainingUserInfo()
    {
        badges=new List<UserBadge>();
    }

    public class UserBadge
    {
        @AuraEnabled
        public String name {get; set;}

        @AuraEnabled
        public String description {get; set;}

        @AuraEnabled
        public DateTime whenEarned {get; set;}

        @AuraEnabled
        public Integer earnedCount {get; set;}
    }
}
