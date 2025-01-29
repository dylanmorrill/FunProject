public with sharing class FancyPlatformEventLoggingFramework {

  public FancyPlatformEventLoggingFramework() {
    
  }

  public void fireFailureEvent(Exception ex, String className, String methodName) {
    //Fire platform event to be handled in a trigger to log to salesforce or 3p tool
  }
}