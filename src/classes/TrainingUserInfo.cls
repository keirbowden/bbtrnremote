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
    public Integer badges {get; set;}  
}
