@RestResource(urlMapping='/TrainingPath/*')
global class TrainingPathREST 
{
    private static TrainingServiceIF trainingService=new TrainingServiceLocalImpl();

    @HttpPost 
    global static TrainingPath[] GetPaths(String pathIdStr, String email)
    {
        List<TrainingPath> result;
        if (String.IsBlank(pathIdStr))
        {
            result=trainingService.GetAllPaths(email);
        }
        else
        {
            result=new List<TrainingPath>{trainingService.GetPath(pathIdStr, email)};
        }

        return result;
    }
}