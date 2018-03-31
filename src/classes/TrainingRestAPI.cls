@RestResource(urlMapping='/TrainAPI/*')
global class TrainingRestAPI 
{
    public static final String GET_ALL_PATHS_METHOD='GetPaths';
    public static final String GET_PATH_METHOD='GetPath';
    public static final String GET_STEP_METHOD='GetStep';
    public static final String PASS_STEP_METHOD='PassStep';
    public static final String FAIL_STEP_AND_WAIT_METHOD='FailStepAndWait';
    public static final String GET_USER_INFO_METHOD='GetUserInfo';

    @TestVisible
    private static final Decimal MY_VERSION=1.0;

    private static TrainingServiceIF trainingService=new TrainingServiceImpl();

    @HttpPost 
    global static void TrainingRequest(String method, String email, Decimal version, 
                                        String pathIdStr, String stepIdStr)
    {
        String result;

        Integer supportedMajor=(Integer) MY_VERSION;
        Integer desiredMajor=(Integer) version;
        if (supportedMajor!=desiredMajor)
        {
            CalloutException ce = new CalloutException();
            String message='';
            if ( (null==desiredMajor) || (supportedMajor > desiredMajor) )
            {
                message='This endpoint requires an updated client - please install a V' + 
                        supportedMajor + '.x client from https://github.com/keirbowden/bbtrn';
            }
            else 
            {
                message='This endpoint is out of date for your client version - please as the admin to update to V' + 
                        desiredMajor + '.x version from https://github.com/keirbowden/bbtrnremote';
            }
            ce.setMessage(message);

            throw ce;
        }

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
            TrainingResult trResult=trainingService.PassStep(pathIdStr, stepIdStr, email);
            result=JSON.serialize(trResult);
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