@RestResource(urlMapping='/TrainAPI/*')
global class TrainingRestAPI 
{
    private static TrainingServiceIF trainingService=new TrainingServiceLocalImpl();

    @HttpPost 
    global static void TrainingRequest(String method, String email, String pathIdStr, 
                                         String stepIdStr)
    {
        String result;

        System.debug('Method = ' + method);
        if (method=='GetPaths')
        {
            List<TrainingPath> paths=trainingService.GetAllPaths(email);
            result=JSON.serialize(paths);
        }
        else if (method=='GetPath')
        {
            TrainingPath path=trainingService.GetPath(pathIdStr, email); 
            result=JSON.serialize(path);
        }
        else if (method=='GetStep')
        {
            TrainingPath path=trainingService.GetStep(pathIdStr, stepIdStr, email); 
            result=JSON.serialize(path);
        }
        else if (method=='PassStep')
        {
            Boolean passedPath=trainingService.PassStep(pathIdStr, stepIdStr, email);
            result=JSON.serialize(passedPath);
        }
        else if (method=='GetUserInfo')
        {
            TrainingUserInfo info=trainingService.GetUserInfo(email);
            result=JSON.serialize(info);  
        }
        RestContext.response.responseBody = Blob.valueOf(result);
    }

}