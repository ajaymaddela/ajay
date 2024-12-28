import boto3
from datetime import datetime, timedelta, timezone

# Create IAM client
iam = boto3.client('iam')
#cron(0 0 1,16 */2 ? *)

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
            
            # Check if the access key is older than 23 hours
            if create_date < (utc_now - timedelta(hours=23)):
                # If the access key is not already inactive, disable it
                if status != 'Inactive':
                    iam.update_access_key(UserName=user_name, AccessKeyId=access_key_id, Status='Inactive')
                    print(f"Disabled access key {access_key_id} for user {user_name}")
                else:
                    print(f"Access key {access_key_id} for user {user_name} is already inactive.")
                
    return {
        'statusCode': 200,
        'body': 'Finished processing inactive access keys.'
    }
