({
    actionResponseHandler : function (response, component, helper, cb, cbData) {
        try
        {
            console.log('In actionResponseHandler : component = ' + component + ', helper = ' + helper);
            var state = response.getState();
            console.log('State = ' + state);
            if (state === "SUCCESS") {
                var retVal=response.getReturnValue();
                console.log('Result = ' + JSON.stringify(retVal));
                console.log('About to call ' + cb);
                cb(component, helper, retVal, cbData);
                console.log('Done with callback');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    console.log("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        this.showToast('error', 'Error in remote action : ' + errors[0].message, 5000);
                    }
                } 
                else {
                    alert("Unknown error");
                }
            }
        }
        catch (e) {
            alert('Exception in actionResponseHandler: ' + e + '\n' + e.stack);
        }
    },
    showToast: function(severity, message, duration) {
    	var title;
    	var mode="dismissable";
    	switch (severity) {
            case 'error':
                title = 'Error';
                mode="sticky";
                break;
           case 'warning':
                title = 'Warning';
                break;
           case 'info':
                title = 'Info';
                break;
           case 'success':
                title = 'Title';
                break;
    	}
    	
        var toastEvent=$A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                "type":severity,
                "title":title,
                "message":message,
                "duration":duration,
                "mode":mode
            });
        
            toastEvent.fire();
        }
        else {
            alert(severity + ' : ' + message);
        }
    },
    showWorking : function(cmp, message) {
        this.fireWorking(cmp, true, message);
    },
    hideWorking : function(cmp) {
        this.fireWorking(cmp, false);
    },
    fireWorking : function(cmp, show, message) {
        var showWorkingEvent=$A.get("e.c:TrainingWorkingEvt");
        showWorkingEvent.setParams({'show':show,
                                    'message':message});
        showWorkingEvent.fire();
    },
})