@RestResource(urlMapping='/CaseConnector/*')
global without sharing class CaseConnectorApi {

  @TestVisible
  private static final Boolean SHALL_MATCH_CONTACT_ON_CREATE = 
    Label.ShallMatchContactOnCreate == 'Y';
  private static final String CLASS_NAME = 'CaseConnectorApi';
  private static final String EXCEPTION_NAME_CREATE = 
    'CaseConnectorApi.CaseCreateException';
  private static final Set<String> VALID_ORIGINS = new Set<String> { 
    'WEB', 'MOBILE' };

  @HttpPost
  global static String doCreate(String subject, String description, 
    String status, String origin, String name, String phone, String email) {

    try {
      return createCase(subject, description, origin, name, phone, 
        email);
    } catch (Exception ex) {
      new FancyPlatformEventLoggingFramework().fireFailureEvent(ex, CLASS_NAME, 
        'doCreate');
      throw new CaseCreateException(ex.getMessage());
    }
  }

  private static String createCase(String subject, String description, 
    String origin, String name, String phone, String email) {

    String defaultStatus = 'New';
    Case newCase = new Case(Subject = subject, Description = description, 
      Status = defaultStatus, Origin = origin, SuppliedName = name, 
      SuppliedPhone = phone, SuppliedEmail = email);
    List<String> validationHits = validateOnCreate(newCase);
    if (!validationHits.isEmpty()) {
      RestResponse res = RestContext.response;
      res.statusCode = 400;
      return JSON.serialize(validationHits);
    }
    if (SHALL_MATCH_CONTACT_ON_CREATE) {
      List<Contact> matchingContacts = 
        [SELECT Id
         FROM Contact
         WHERE Email = :email
         ORDER BY CreatedDate DESC
         LIMIT 1];
      if (!matchingContacts.isEmpty()) {
        newCase.ContactId = matchingContacts[0].Id;
      }
    }
    insert newCase;
    return newCase.Id;
  }

  private static List<String> validateOnCreate(Case newCase) {
    String invalidOriginMessage = 'Case origin must be mobile or web';
    Set<String> validationHits = new Set<String>();
    if (!VALID_ORIGINS.contains(newCase.Origin.toUpperCase())) {
      validationHits.add(invalidOriginMessage);
    }
    return new List<String>(validationHits);
  }

  public class CaseCreateException extends Exception {}
}