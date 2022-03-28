# Dev-Assessment-Approach
Since the ask is to create two different components, so creating these two components are the main two tasks that will be divided into further sub-tasks. 
Each functionality, be it displaying the records on initialisation, adding pagination logic, adding sorting logic will be treated as separate tasks and will have their own separate methods.
Adding Lightning messaging service enable cross-DOM communication between the components can be treated as a stand-alone task as well.

Link to the demo video - https://drive.google.com/file/d/1qQZ_NzL-NnjsHa2IjP1mc8R0UWyQkNEK/view?usp=sharing

# Pre-Requisites
Use the package.xml file to deploy the changes to the test environment.
Once the sfdx project is deployed to the org, make sure the included CK_Config_Objects_Access permission set is added to the user being used for testing. Use the Config tab to create sample Config__c records. 
On the Case record page, Case Record Page flexipage needs to be selected.

Create a NamedCredential with the below information in the environment -
Label - RequestCatcherClark
Endpoint - https://clarkassessment.requestcatcher.com/
protocol - NoAuthentication

# Feedback
