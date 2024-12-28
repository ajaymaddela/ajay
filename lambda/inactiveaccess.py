import boto3
import json
from datetime import datetime, timedelta, timezone

# Create IAM and Secrets Manager clients
iam = boto3.client('iam')
secrets_manager = boto3.client('secretsmanager')

def lambda_handler(event, context):
    # Start by logging the start of the function execution
    print("Lambda function started")
    
    # Get the current UTC time and make it timezone-aware
    utc_now = datetime.utcnow().replace(tzinfo=timezone.utc)
    
    # Get the list of IAM users
    response = iam.list_users()
    print(f"Retrieved IAM users: {response['Users']}")
    
    for user in response['Users']:
        user_name = user['UserName']
        
        # Get the list of access keys for each user
        keys = iam.list_access_keys(UserName=user_name)
        print(f"Retrieved access keys for user {user_name}: {keys['AccessKeyMetadata']}")
        
        for key in keys['AccessKeyMetadata']:
            access_key_id = key['AccessKeyId']
            create_date = key['CreateDate']
            status = key['Status']
            
            # Log the details of the access key
            print(f"Checking access key {access_key_id} for user {user_name}")
            
            # Check if the access key is inactive for 1 hour or older
            if status == 'Inactive' and (utc_now - create_date) >= timedelta(hours=1):
                try:
                    # Create a new access key for the user
                    new_key = iam.create_access_key(UserName=user_name)
                    new_access_key_id = new_key['AccessKey']['AccessKeyId']
                    new_secret_key = new_key['AccessKey']['SecretAccessKey']
                    
                    # Log the newly created access key
                    print(f"Created new access key {new_access_key_id} for user {user_name}")
                    
                    # Store the new secret access key in Secrets Manager
                    secret_name = f"access-key-secret-{user_name}"
                    secret_value = {
                        'AccessKeyId': new_access_key_id,
                        'SecretAccessKey': new_secret_key
                    }
                    
                    # Try to create the secret in Secrets Manager
                    try:
                        secrets_manager.create_secret(
                            Name=secret_name,
                            SecretString=json.dumps(secret_value)
                        )
                        print(f"Stored new secret for user {user_name} in Secrets Manager.")
                    except secrets_manager.exceptions.ResourceExistsException:
                        secrets_manager.put_secret_value(
                            SecretId=secret_name,
                            SecretString=json.dumps(secret_value)
                        )
                        print(f"Updated secret for user {user_name} in Secrets Manager.")
                    
                    # Deactivate and delete the old key
                    iam.update_access_key(UserName=user_name, AccessKeyId=access_key_id, Status='Inactive')
                    iam.delete_access_key(UserName=user_name, AccessKeyId=access_key_id)
                    print(f"Disabled and deleted old access key {access_key_id} for user {user_name}")
                except Exception as e:
                    print(f"Error creating or updating access key for user {user_name}: {str(e)}")
                
            else:
                print(f"Access key {access_key_id} for user {user_name} is not inactive for 1 hour yet, no action taken.")
                
    return {
        'statusCode': 200,
        'body': 'Finished processing access keys for rotation.'
    }
