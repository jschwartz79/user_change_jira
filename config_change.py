import boto3
import datetime
import json
import os

cloudtrail = boto3.client('cloudtrail')
ssm_client = boto3.client('ssm')


def lambda_handler(event, context):
    for record in event['Records']:
        body = json.loads(record['body'])
        resource_name = body['detail']['configurationItem']['resourceName']

        end_time = body['detail']['configurationItem']['configurationItemCaptureTime']
        start_time = (datetime.datetime.strptime(
            end_time, '%Y-%m-%dT%H:%M:%S.%fZ')) - datetime.timedelta(seconds=300)

        ct_events = cloudtrail.lookup_events(
            LookupAttributes=[
                {
                    'AttributeKey': "ResourceName",
                    'AttributeValue': resource_name

                }
            ],
            StartTime=start_time,
            EndTime=end_time
        )

        # Summarize all the events found within a certain time frame around the event.
        jira_description = ''
        for ct_event in ct_events['Events']:
            ct_event_body = json.loads(ct_event['CloudTrailEvent'])
            if not ct_event_body['userIdentity'].get('userName'):
                # Not currently handling cases where the change was not initiated by a user
                print("Not a change initiated by a user")
                continue
            action = ct_event_body['eventName']
            username = ct_event_body['userIdentity']['userName']
            jira_description += 'User: [%s] performed action [%s] on resource [%s]\\n' % (
                username,
                action,
                resource_name)

        # Send to jira
        jira_user = os.environ['JIRA_USER']
        jira_token_name = os.environ['JIRA_TOKEN_NAME']
        jira_project = os.environ['JIRA_PROJECT']
        jira_url = os.environ['JIRA_URL']
        ssm_client.start_automation_execution(
            DocumentName="AWS-CreateJiraIssue",
            Parameters={
                "JiraUsername": [jira_user],
                "SSMParameterName": [jira_token_name],
                "JiraURL": [jira_url],
                "ProjectKey": [jira_project],
                "IssueTypeName": ["Task"],
                "IssueSummary": ["Manual change made: %s" % action],
                "IssueDescription": [jira_description]
            }
        )
