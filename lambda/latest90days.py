import boto3
import json
from datetime import datetime, timedelta, timezone

# Initialize STS client in the management account
sts_client = boto3.client('sts')

def lambda_handler(event, context):
    # Log the start of the function execution
    print("Lambda function started")
    
    # Get the current UTC time
    utc_now = datetime.utcnow().replace(tzinfo=timezone.utc)
    
    # Set the 5-minute threshold for testing
    rotation_threshold = utc_now - timedelta(minutes=5)
    
    # Management account ID
    management_account_id = "684206014294"  # Replace with your management account ID
    management_role_arn = f"arn:aws:iam::{management_account_id}:role/support-for-lambda"  # Replace with the role ARN in your management account

    # Get the list of all accounts in the AWS Organization
    org_client = boto3.client('organizations')
    accounts = org_client.list_accounts()['Accounts']
    print(f"Retrieved accounts from AWS Organization: {accounts}")
    
    for account in accounts:
        account_id = account['Id']
        account_name = account['Name']
        
        # Determine the role ARN to use
        if account_id == management_account_id:
            role_arn = management_role_arn  # Use management account role
        else:
            role_arn = f"arn:aws:iam::{account_id}:role/ajay-child"  # Use child account role
        
        try:
            # Assume the role in the target account
            assumed_role = sts_client.assume_role(
                RoleArn=role_arn,
                RoleSessionName='RotateAccessKeysSession'
            )
            credentials = assumed_role['Credentials']
            
            # Use temporary credentials to access the target account
            iam = boto3.client(
                'iam',
                aws_access_key_id=credentials['AccessKeyId'],
                aws_secret_access_key=credentials['SecretAccessKey'],
                aws_session_token=credentials['SessionToken']
            )
            secrets_manager = boto3.client(
                'secretsmanager',
                aws_access_key_id=credentials['AccessKeyId'],
                aws_secret_access_key=credentials['SecretAccessKey'],
                aws_session_token=credentials['SessionToken']
            )
            
            # Get the list of IAM users in the account
            users = iam.list_users()
            print(f"Retrieved IAM users for account {account_name}: {users['Users']}")
            
            for user in users['Users']:
                user_name = user['UserName']
                
                # List access keys for the user
                keys = iam.list_access_keys(UserName=user_name)
                print(f"Retrieved access keys for user {user_name} in account {account_name}: {keys['AccessKeyMetadata']}")
                
                # Flag to check if a valid key already exists
                valid_key_found = False
                
                for key in keys['AccessKeyMetadata']:
                    access_key_id = key['AccessKeyId']
                    create_date = key['CreateDate']
                    status = key['Status']
                    
                    # Log key details
                    print(f"Checking access key {access_key_id} for user {user_name} in account {account_name}")
                    
                    # If an active key is not older than 5 minutes, skip key creation
                    if create_date >= rotation_threshold and status == 'Active':
                        print(f"Access key {access_key_id} for user {user_name} in account {account_name} is valid and not older than 5 minutes. Skipping new key creation.")
                        valid_key_found = True
                        break
                
                # If no valid key is found, create a new key and rotate
                if not valid_key_found:
                    try:
                        # Create a new access key for the user
                        new_key = iam.create_access_key(UserName=user_name)
                        new_access_key_id = new_key['AccessKey']['AccessKeyId']
                        new_secret_key = new_key['AccessKey']['SecretAccessKey']
                        
                        # Log the creation of the new access key
                        print(f"Created new access key {new_access_key_id} for user {user_name} in account {account_name}")
                        
                        # Store the new access key in the account's Secrets Manager
                        secret_name = f"{account_id}-access-key-secret-{user_name}"
                        secret_value = {
                            'AccessKeyId': new_access_key_id,
                            'SecretAccessKey': new_secret_key
                        }
                        
                        # Store or update the secret
                        try:
                            secrets_manager.create_secret(
                                Name=secret_name,
                                SecretString=json.dumps(secret_value)
                            )
                            print(f"Stored new secret for user {user_name} in account {account_name}'s Secrets Manager.")
                        except secrets_manager.exceptions.ResourceExistsException:
                            secrets_manager.put_secret_value(
                                SecretId=secret_name,
                                SecretString=json.dumps(secret_value)
                            )
                            print(f"Updated secret for user {user_name} in account {account_name}'s Secrets Manager.")
                        
                        # Deactivate and delete the old key
                        for key in keys['AccessKeyMetadata']:
                            old_access_key_id = key['AccessKeyId']
                            iam.update_access_key(UserName=user_name, AccessKeyId=old_access_key_id, Status='Inactive')
                            iam.delete_access_key(UserName=user_name, AccessKeyId=old_access_key_id)
                            print(f"Disabled and deleted old access key {old_access_key_id} for user {user_name} in account {account_name}")
                    except Exception as e:
                        print(f"Error rotating access key for user {user_name} in account {account_name}: {str(e)}")
        
        except Exception as e:
            print(f"Error processing account {account_id} ({account_name}): {str(e)}")
    
    # Log the end of the function
    print("Lambda function completed")
    
    return {
        'statusCode': 200,
        'body': 'Finished processing access keys for all accounts in the organization.'
    }
