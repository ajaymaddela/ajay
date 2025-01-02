management account
create a role in management account with name ajay-role-for-admin using for lambda function execution role
select service as lambda
attach policy like iam fullaccess
organization readonlyaccess
lambdabasic execution role

attach policy to above created role (ajay-role-for-admin) with the rolename(testing) created with iam full access in child accounts
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::*:role/testing"
        }
    ]
}
```

verify the  trust policy for role name for ajay-role-for-admin in management account 
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

create another role in management account with name extra-role-for-ajay
service lambda with policy iam full access and trust policy pointing to above role
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::684206014294:role/ajay-role-for-admin"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

in management account create lambda function in management account use extra-role-for-ajay created for that role
```

import boto3
from datetime import datetime, timedelta, timezone

# Initialize STS client in the management account
sts_client = boto3.client('sts')

def lambda_handler(event, context):
    # Get the list of all accounts in the AWS Organization
    org_client = boto3.client('organizations')
    accounts = org_client.list_accounts()['Accounts']

    # Get the current UTC time
    utc_now = datetime.utcnow().replace(tzinfo=timezone.utc)

    # Set the inactivity threshold (5 minutes for testing purposes)
    inactivity_threshold = utc_now - timedelta(minutes=5)

    for account in accounts:
        account_id = account['Id']
        account_name = account['Name']

        # Use a custom role for the management account
        if account_id == "684206014294":  # Replace with your management account ID
            role_arn = "arn:aws:iam::684206014294:role/support-for-lambda"  # Replace with the new role ARN
        else:
            role_arn = f"arn:aws:iam::{account_id}:role/ajay-child"

        # Assume the role in each account
        try:
            assumed_role = sts_client.assume_role(
                RoleArn=role_arn,
                RoleSessionName='CheckUnusedKeysSession'
            )
            credentials = assumed_role['Credentials']

            # Use the temporary credentials to access the child/management account
            iam = boto3.client(
                'iam',
                aws_access_key_id=credentials['AccessKeyId'],
                aws_secret_access_key=credentials['SecretAccessKey'],
                aws_session_token=credentials['SessionToken']
            )

            # List all IAM users in the account
            response = iam.list_users()

            for user in response['Users']:
                user_name = user['UserName']

                # List access keys for each user
                keys = iam.list_access_keys(UserName=user_name)

                for key in keys['AccessKeyMetadata']:
                    access_key_id = key['AccessKeyId']
                    create_date = key['CreateDate']
                    status = key['Status']

                    # Check when the access key was last used
                    last_used_response = iam.get_access_key_last_used(AccessKeyId=access_key_id)
                    last_used_date = last_used_response.get('AccessKeyLastUsed', {}).get('LastUsedDate')

                    # If the access key was never used, set last_used_date to the create date
                    if not last_used_date:
                        last_used_date = create_date

                    # Check if the key has not been used for 5 minutes
                    if last_used_date < inactivity_threshold:
                        # Disable the access key if it's not already inactive
                        if status != 'Inactive':
                            iam.update_access_key(UserName=user_name, AccessKeyId=access_key_id, Status='Inactive')
                            print(f"Disabled access key {access_key_id} for user {user_name} in account {account_name}.")

                        # Optionally delete the access key (if required)
                        iam.delete_access_key(UserName=user_name, AccessKeyId=access_key_id)
                        print(f"Deleted access key {access_key_id} for user {user_name} in account {account_name} due to inactivity.")
                    else:
                        print(f"Access key {access_key_id} for user {user_name} in account {account_name} is still active.")
        except Exception as e:
            print(f"Error processing account {account_id} ({account_name}): {e}")

    return {
        'statusCode': 200,
        'body': 'Finished processing access keys for all accounts.'
    }
```

in child account create a role name testing and point to another aws account and mention organization account id and attach iam full access policy