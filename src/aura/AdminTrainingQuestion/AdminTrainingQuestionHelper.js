({
    init : function(cmp, ev) {
        var recordId=cmp.get('v.recordId');
        if (null==recordId) {
            cmp.set('v.question', {});
            cmp.set('v.answers', [{Index__c:1, answer:''}]);
        }
        else {
            var action=cmp.get('c.GetQuestionAndAnswers');
            action.setParams({questionIdStr: recordId});
            var helper=this;
            action.setCallback(helper, function(response) {
                helper.actionResponseHandler(response, cmp, helper, helper.gotQuestionAndAnswers);
            });
            $A.enqueueAction(action);
            this.showWorking(cmp);
        }
    },
    gotQuestionAndAnswers : function(cmp, helper, result) {
        delete result.question.Training_Answers__r;
        cmp.set('v.question', result.question);
        if (0===result.answers.length) {
            cmp.set('v.answers', [{Index__c:1, answer:''}]);
            cmp.set('v.answerCount', 1);
        } 
        else {
            for (var idx=0, len=result.answers.length; idx<len; idx++) {
                var answer=result.answers[idx];
                if (answer.Index__c==result.question.Correct_Answer_Index__c){
                    answer.Correct__c=true;
                }
                else {
                    answer.Correct__c=false;
                }
                result.answers[idx].Index__c=idx+1;
            }
            cmp.set('v.answers', result.answers);
            cmp.set('v.answerCount', result.answers.length);
        }
        helper.hideWorking(cmp);
    },
    addAnswer: function(cmp, ev) {
        var answers=cmp.get('v.answers');
        cmp.set('v.answers', []);
        var answerCount=cmp.get('v.answerCount');
        answerCount++;
        answers.push({Index__c: answerCount, answer:''});
        cmp.set('v.answerCount', answerCount);

        cmp.set('v.answers', answers);
        this.setUnsavedChanges(cmp);
    },
    setUnsavedChanges : function(cmp) {
        cmp.set('v.unsavedChanges', true);
        console.log('Adding event listener');
        window.addEventListener('beforeunload', this.confirmLeave);
        console.log('Added event listener');
    },
    confirmLeave : function(event) {
        event.returnValue = "You have unsaved changes";
    },
    clearUnsavedChanges : function(cmp, helper) {
        window.removeEventListener('beforeunload', helper.confirmLeave);
        cmp.set('v.unsavedChanges', false);
    },
    deleteAnswer : function(cmp, ev) {
        var answers=cmp.get('v.answers');
        var answerCount=cmp.get('v.answerCount');
        var eleName=ev.getSource().get('v.name');
        console.log('Element name = ' + eleName);

        // https://success.salesforce.com/issues_view?id=a1p3A000000ep3yQAA
        cmp.set('v.answers', []);
        var eleIdx=eleName.split('-')[1];
        console.log('deleting answer ' + eleIdx);
        console.log('length = ' + answers.length);
        var removed=answers.splice(eleIdx-1, 1);
        console.log('Removed = ' + JSON.stringify(removed, null, 4));
        console.log('length after = ' + answers.length);
        answerCount--;

        var newAnswers=this.reindexAnswers(answers);
        console.log('New Answers = ' + JSON.stringify(newAnswers, null, 4));
        cmp.set('v.answers', newAnswers);

        cmp.set('v.answerCount', answerCount);
        this.setUnsavedChanges(cmp);
    },
    reindexAnswers : function(answers) {
        // put into a new array, otherwise we get a phantom entry at the end
        // when rendering.
        var newAnswers=[];
        for (var idx=1, len=answers.length; idx<=len; idx++) {
            console.log('Setting ' + (idx - 1) + ' index to ' + idx);
            newAnswers.push(answers[idx-1]);
            newAnswers[idx-1].Index__c=idx;
        }

        return newAnswers;
    },
    moveAnswer : function(cmp, ev) {
        var answers=cmp.get('v.answers');
        var eleName=ev.getSource().get('v.name');
        var eleEles=eleName.split('-');
        var eleOp=eleEles[0];
        var eleIdx=eleEles[1]-1;

        var targetIdx=0;
        switch (eleOp)
        {
            case 'top':
                targetIdx=0;
                break;
            case 'bottom':
                targetIdx=answers.length;
                break;
            case 'up':
                targetIdx=eleIdx-1;
                break;
            case 'down':
                targetIdx=eleIdx+1;
                break;
        }

        console.log('Before = ' + JSON.stringify(answers, null, 4));
        console.log('Moving ' + eleIdx + ' to ' + targetIdx);
        var eleArr=answers.splice(eleIdx, 1);
        answers.splice(targetIdx, 0, eleArr[0]);
        var newAnswers=this.reindexAnswers(answers);
        console.log('After = ' + JSON.stringify(newAnswers, null, 4));
        cmp.set('v.answers', newAnswers);
        this.setUnsavedChanges(cmp);
    },
    save : function(cmp, ev) {
        var question=cmp.get('v.question');
        var answers=cmp.get('v.answers');
        question.sobjectType='Training_Question__c';
        var correctCount=0;
        for (var idx=0, len=answers.length; idx<len; idx++) {
            answers[idx].sobjectType='Training_Answer__c';
            if (answers[idx].Correct__c) {
                question.Correct_Answer_Index__c=answers[idx].Index__c;
                correctCount++;
            }
        }
        if (1!=correctCount) {
            this.showToast('error', 'One answer must be marked as correct');
        }
        else {
            var qanda={question: question,
                       answers : answers};

            var action=cmp.get('c.Save');
            var qandaJSON=JSON.stringify(qanda);
            action.setParams({qandaJSON: qandaJSON});
            var helper=this;
            action.setCallback(helper, function(response) {
                helper.actionResponseHandler(response, cmp, helper, helper.saved);
            });
            $A.enqueueAction(action);
            this.showWorking(cmp);
        }
    },
    gotoStep : function(cmp, ev) {
        if (cmp.get('v.unsavedChanges')) {
            alert('You have unsaved changes');
        }
        else {
            var question=cmp.get('v.question');
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": question.Training_Step__r.Id,
                "slideDevName": "details"
            });
            navEvt.fire();
        }
    },
    saved : function(cmp, helper, result) {
        helper.hideWorking(cmp);
        helper.showToast('info', 'Saved question');
        helper.clearUnsavedChanges(cmp, helper);
        helper.gotQuestionAndAnswers(cmp, helper, result);
    }
})