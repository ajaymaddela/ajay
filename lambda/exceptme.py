import boto3

iam = boto3.client('iam')

def lambda_handler(event, context):
    # List all IAM users, groups, and roles
    entities = []

    # Get IAM users
    users = iam.list_users()
    entities.extend(users['Users'])

    # Get IAM groups
    groups = iam.list_groups()
    for group in groups['Groups']:
        entities.append(group)

    # Get IAM roles
    roles = iam.list_roles()
    entities.extend(roles['Roles'])

    # Full admin policies (e.g., AdministratorAccess)
    full_admin_policies = ['arn:aws:iam::aws:policy/AdministratorAccess']
    
    # List of users to exclude from policy detachment
    exclude_users = ['ajay']

    # Iterate through users, groups, and roles to find attached policies
    for entity in entities:
        # Skip the users in the exclude list
        if 'UserName' in entity and entity['UserName'] in exclude_users:
            continue

        if 'UserName' in entity:
            attached_policies = iam.list_attached_user_policies(UserName=entity['UserName'])
        elif 'GroupName' in entity:
            attached_policies = iam.list_attached_group_policies(GroupName=entity['GroupName'])
        elif 'RoleName' in entity:
            attached_policies = iam.list_attached_role_policies(RoleName=entity['RoleName'])

        for policy in attached_policies.get('AttachedPolicies', []):
            policy_arn = policy['PolicyArn']

            # If the policy grants full admin access, detach it
            if policy_arn in full_admin_policies:
                print(f"Full admin policy found on {entity['UserName' if 'UserName' in entity else 'GroupName' if 'GroupName' in entity else 'RoleName']} ({policy_arn}), detaching...")

                # Detach the policy
                if 'UserName' in entity:
                    iam.detach_user_policy(UserName=entity['UserName'], PolicyArn=policy_arn)
                elif 'GroupName' in entity:
                    iam.detach_group_policy(GroupName=entity['GroupName'], PolicyArn=policy_arn)
                elif 'RoleName' in entity:
                    iam.detach_role_policy(RoleName=entity['RoleName'], PolicyArn=policy_arn)

    return {
        'statusCode': 200,
        'body': 'Successfully detached full admin policies, except for users in the exclude list.'
    }
