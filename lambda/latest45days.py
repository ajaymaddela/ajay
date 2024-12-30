import boto3
from datetime import datetime, timedelta, timezone

# Create IAM client
iam = boto3.client('iam')

def lambda_handler(event, context):
    # Get the current UTC time and make it timezone-aware
    utc_now = datetime.utcnow().replace(tzinfo=timezone.utc)

    # Get the list of IAM users
    response = iam.list_users()

    for user in response['Users']:
        user_name = user['UserName']

        # Get the list of access keys for each user
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

            # Check if the key has not been used for 45 days
            if last_used_date < (utc_now - timedelta(days=45)):
                # Disable the access key if it's not already inactive
                if status != 'Inactive':
                    iam.update_access_key(UserName=user_name, AccessKeyId=access_key_id, Status='Inactive')
                    print(f"Disabled access key {access_key_id} for user {user_name} due to inactivity.")

                # Delete the access key
                iam.delete_access_key(UserName=user_name, AccessKeyId=access_key_id)
                print(f"Deleted access key {access_key_id} for user {user_name} due to 45 days of inactivity.")
            else:
                print(f"Access key {access_key_id} for user {user_name} is still active.")

    return {
        'statusCode': 200,
        'body': 'Finished processing access keys based on last usage.'
    }
