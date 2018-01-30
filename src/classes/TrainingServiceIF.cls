public interface TrainingServiceIF {
    // Gets all the paths even if the user has completed them
    List<TrainingPath> GetAllPaths(String email);

    // Gets the details of a single path, including a high level
    // view of the steps
    TrainingPath GetPath(String pathIdStr, String email);

    // Gets the details of a step, including the questions
    // and answers
    TrainingPath GetStep(String pathIdStr, String stepIdStr, String email);

    // Marks a user as having passed a step. If this means that
    // the user has passed the path, returns true
    Boolean PassStep(String pathIdStr, String stepIdStr, String email);

    // Marks a user as having failed a step which neans they have to wait to try again
    TrainingPath FailStepAndWait(String pathIdStr, String stepIdStr, String email);
        
    // Gets the user infomation, such as badges, points etc
    TrainingUserInfo GetUserInfo(String email);
}
