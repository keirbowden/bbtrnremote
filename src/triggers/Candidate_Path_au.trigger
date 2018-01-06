trigger Candidate_Path_au on Candidate_Path__c (after update) {
    BadgeUtils.AssignBadgeIfPathComplete(Trigger.new);
}