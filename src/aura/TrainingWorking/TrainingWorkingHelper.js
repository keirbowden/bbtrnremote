({
    handleWorking : function(cmp, ev) {
        var show=ev.getParam('show');
        var message=ev.getParam('message');
        var msg='Handling ' + (show?'show':'hide') + ' working event';
        console.log(msg);
        cmp.set('v.visible', show);
    }
})