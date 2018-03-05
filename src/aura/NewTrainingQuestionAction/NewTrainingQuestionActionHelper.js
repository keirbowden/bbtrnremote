({
	init : function(cmp, ev) {
	try
	{
        var action=cmp.get('c.CreateNewQuestionFromStep');
        action.setParams({
            stepIdStr: cmp.get('v.recordId')
        });
        
		var helper=this;
        action.setCallback(this, function(response) {
            helper.actionResponseHandler(response, cmp, helper, helper.questionCreated);
        });
        $A.enqueueAction(action);
    }
    catch (e)
    {
    	alert('Exception ' + e);
    }
        
	},
	questionCreated : function(cmp, helper, result) {
		var questionId=result;
	    var evt = $A.get("e.force:navigateToSObject");
    	if (evt) {
        	evt.setParams({
        		"recordId" : questionId
        	});
	        evt.fire();
    	}
	}
})