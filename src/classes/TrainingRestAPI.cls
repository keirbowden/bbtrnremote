@RestResource(urlMapping='/TrainAPI/*')
global class TrainingRestAPI 
{
    public static final String GET_ALL_PATHS_METHOD='GetPaths';
    public static final String GET_PATH_METHOD='GetPath';
    public static final String GET_STEP_METHOD='GetStep';
    public static final String PASS_STEP_METHOD='PassStep';
    public static final String FAIL_STEP_AND_WAIT_METHOD='FailStepAndWait';
    public static final String GET_USER_INFO_METHOD='GetUserInfo';

    private static TrainingServiceIF trainingService=new TrainingServiceImpl();

    @HttpPost 
    global static void TrainingRequest(String method, String email, String pathIdStr, 
                                         String stepIdStr)
    {
        String result;

        System.debug('Method = ' + method);
        if (method==GET_ALL_PATHS_METHOD)
        {
            List<TrainingPath> paths=trainingService.GetAllPaths(email);
            result=JSON.serialize(paths);
        }
        else if (method==GET_PATH_METHOD)
        {
            TrainingPath path=trainingService.GetPath(pathIdStr, email); 
            result=JSON.serialize(path);
        }
        else if (method==GET_STEP_METHOD)
        {
            TrainingPath path=trainingService.GetStep(pathIdStr, stepIdStr, email); 
            result=JSON.serialize(path);
        }
        else if (method==PASS_STEP_METHOD)
        {
            Boolean passedPath=trainingService.PassStep(pathIdStr, stepIdStr, email);
            result=JSON.serialize(passedPath);
        }
        else if (method==FAIL_STEP_AND_WAIT_METHOD)
        {
            TrainingPath path=trainingService.FailStepAndWait(pathIdStr, stepIdStr, email);
            result=JSON.serialize(path);
        }
        else if (method==GET_USER_INFO_METHOD)
        {
            TrainingUserInfo info=trainingService.GetUserInfo(email);
            result=JSON.serialize(info);  
        }
        RestContext.response.responseBody = Blob.valueOf(result);
    }

}