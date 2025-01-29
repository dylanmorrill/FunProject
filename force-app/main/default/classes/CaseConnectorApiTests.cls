@isTest
public class CaseConnectorApiTests {

  private static final Case MODEL_CASE_CREATE = 
    new Case(Subject = 'Budget Crisis: The Human Fund Needs More Human Funds!"', 
      Description = 'George Costanza needs urgent help fixing budget issues  ' +
        'at the "Human Fund."', Status = 'New', Origin = 'web',
      SuppliedName = 'George Costanza', SuppliedPhone = '(555) 123-HUMN', 
      SuppliedEmail = 'GCostanza@TheHumanFund.com');

  @TestSetup
  private static void makeData(){
    Contact matchingContact = new Contact(LastName = 'Costanza', 
      FirstName = 'George', Email = 'GCostanza@TheHumanFund.com');
    insert matchingContact;
  }

  @isTest
  private static void createCaseWithContactMatch() {
    Test.setFixedSearchResults(new List<Id> { 
      [SELECT Id
       FROM Contact 
       LIMIT 1][0].Id });
    callDoCreate();
    Case createdCase = getCaseCreate();
    if (CaseConnectorApi.SHALL_MATCH_CONTACT_ON_CREATE) {
      Assert.isNotNull(createdCase.ContactId, 'Missing contact Id');
    } else {
      Assert.isNull(createdCase.ContactId, 
        'Contact matched despite switch being off');
    }
    Assert.isTrue(validateCaseCreate(createdCase), 
      'The created case did not have all values correctly set');
  }

  @isTest
  private static void createCaseWithoutContactMatch() {
    callDoCreate();
    Assert.isTrue(validateCaseCreate(getCaseCreate()), 
      'The created case did not have all values correctly set');
  }

  @isTest
  private static void createCaseBadOrigin() {
    Boolean exceptionHit;
    try {
      callDoCreate('pigeon', MODEL_CASE_CREATE.SuppliedEmail);
    } catch (CaseConnectorApi.CaseCreateException ex) {
      exceptionHit = true;
    }
    Assert.isTrue(exceptionHit, 
      'Create should have been blocked with a bad origin');
  }

  
  @isTest
  private static void createCaseBadEmaild() {
    Boolean exceptionHit;
    try {
      callDoCreate(MODEL_CASE_CREATE.Origin, 'test');
    } catch (Exception ex) {
      exceptionHit = true;
    }
    Assert.isTrue(exceptionHit);
  }


  private static void callDoCreate() {
    callDoCreate(MODEL_CASE_CREATE.Origin, MODEL_CASE_CREATE.SuppliedEmail);
  }

  private static void callDoCreate(String origin, String email) {
    CaseConnectorApi.doCreate(
      MODEL_CASE_CREATE.Subject, MODEL_CASE_CREATE.Description,
      MODEL_CASE_CREATE.Status, origin, MODEL_CASE_CREATE.SuppliedName, 
      MODEL_CASE_CREATE.SuppliedPhone, email);
  }

  private static Case getCaseCreate() {
    return [SELECT Id, ContactId, Description, Status, Subject, SuppliedEmail, 
                   SuppliedName, SuppliedPhone
            FROM Case
            LIMIT 1];
  }

  private static Boolean validateCaseCreate(Case createdCase) {
    return createdCase.Subject == MODEL_CASE_CREATE.Subject && 
      createdCase.Description == MODEL_CASE_CREATE.Description && 
      createdCase.Status == MODEL_CASE_CREATE.Status &&
      createdCase.SuppliedName == MODEL_CASE_CREATE.SuppliedName && 
      createdCase.SuppliedPhone == MODEL_CASE_CREATE.SuppliedPhone && 
      createdCase.SuppliedEmail == MODEL_CASE_CREATE.SuppliedEmail;
  }
}