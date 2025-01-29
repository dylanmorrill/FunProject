# Case Connector

### tl;dr Create cases in Salesforce via OAuth 2.0 Client Credentials Flow

### Components

**Connected App**
- Connected app with "api" OAuth scope
- The "Client Credentials Flow" runs under a secure Integration user

**Apex Classes**
1. CaseConnectorApi
    a. doCreate(): handles post requests and inserts cases. Performs basic validation. Returns created case Id on success and Apex 500 server error on errors.
2. CaseConnectorApi
    a. Runs some simple tests

