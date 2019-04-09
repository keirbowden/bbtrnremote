({
	init : function(cmp, ev) {
	try
	{
        var action=cmp.get('c.CloneStep');
        action.setParams({
            stepIdStr: cmp.get('v.recordId')
        });
        
		var helper=this;
        action.setCallback(this, function(response) {
            helper.actionResponseHandler(response, cmp, helper, helper.stepCloned);
        });
        $A.enqueueAction(action);
    }
    catch (e)
    {
    	alert('Exception ' + e);
    }
        
	},
	stepCloned : function(cmp, helper, result) {
		var clonedStepId=result;
	    var evt = $A.get("e.force:navigateToSObject");
    	if (evt) {
        	evt.setParams({
        		"recordId" : clonedStepId
        	});
	        evt.fire();
    	}
	}
})