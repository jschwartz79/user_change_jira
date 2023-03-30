## User change monitoring with Jira integration

This creates the necessary workflow which will identify IAM User creation, deletion and updates. Then it will create a Jira ticket with details about the change.

To do this we leverage AWS Config, EventBridge, SQS, Lambda, SSM and CloudTrail.
Workflow:
1. AWS Config monitors for AWS::IAM::User changes
2. EventBridge monitors for AWS Config events, filters based on CREATE, UPDATE, and DELETE. It then forwards those events to SQS
3. SQS delays the message by 2 mins to allow for the arrival of CloudTrail events which will be used to identify the user who made the change.
4. SQS triggers a Lambda job.
5. The Lambda job will inspect the event and query CloudTrail for related events. It then constructs some useful information for a Jira ticket and executes a SSM automation document (AWS-CreateJiraIssue).
6. The AWS-CreateJiraIssue automation document creates the Jira ticket in the specified project.

A Jira account and API token are required for this to work. Details on creating a Jira API token can be found at https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/