import boto3
import os
import logging
from datetime import datetime, timedelta
from botocore.exceptions import ClientError
import botocore.exceptions

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    print ("Event received is : ", event)

    # Initializing the AWS SDK clients
    ssm_client = boto3.client('ssm')
    grafana_client = boto3.client('grafana', region_name=os.environ['AWS_REGION'])

    try:
        # Parse input arguments from the request event
        ssm_parameter_name = event['ssmparameter']
        interval_value = int(event['interval'])
        workspace_id = event['workspaceid']

        # Timestamp to be used for unique KeyName while creating Grafana Workspace API Key
        now = datetime.now()

        # Deleting hour-2 API key to deal with the limit of 100 keys per WorkSpace
        last_hour_date_time = now - timedelta(hours = 2)
        current_api_key_name = 'observability-accelerator-'+now.strftime("%Y%m%d-%H")
        old_api_key_name = 'observability-accelerator-'+last_hour_date_time.strftime('%Y%m%d-%H')

        # Create a new API key in Amazon Managed Grafana
        response = grafana_client.create_workspace_api_key(
            workspaceId=workspace_id,
            keyRole='ADMIN',
            keyName=current_api_key_name,
            secondsToLive=interval_value
        )
        new_api_key = '{\"GF_SECURITY_ADMIN_APIKEY\":\"'+response['key']+'\"}'
        logger.info(f'New API Key Name : {current_api_key_name}')

        # Updating SSM Parameter value with new Key
        response = ssm_client.put_parameter(
            Name=ssm_parameter_name,
            Value=new_api_key,
            Type='SecureString',
            Overwrite=True
        )
        new_parameter_version = response['Version']
        logger.info(f'API Key updated in SSM parameter successfully. New Parameter Version is : {new_parameter_version}')

        # Deleting hour-2 API key to deal with the limit of 100 keys per WorkSpace
        logger.info(f'Proceeding to delete older API Key')

        try:
            logger.info(f'Deleting key : {old_api_key_name}, if one exists')
            grafana_client.delete_workspace_api_key(
                keyName=old_api_key_name,
                workspaceId=workspace_id
                )
            logger.info(f'Deleted the API Key with name :  {old_api_key_name}')
        except grafana_client.exceptions.ResourceNotFoundException as e:
            logger.error(f'An error occurred: {str(e)}')
            logger.error(f'Old API Key does not exist. Skipping this step')
            pass # If the Key does not exist, ignoring this error

    except Exception as e:
        logger.error(f'An error occurred: {str(e)}')
        return {
            'statusCode': 500,
            'body': f'An error occurred: {str(e)}'

        }

    logger.info(f'New API key created and SSM parameter updated successfully!')
    return {
        'statusCode': 200,
        'body': 'New API key created and SSM parameter updated successfully!'
    }
