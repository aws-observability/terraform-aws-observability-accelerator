import boto3
import os
import logging
from datetime import datetime, timedelta

# Initializing the AWS SDK clients
ssm_client = boto3.client('ssm')
grafana_client = boto3.client('grafana', region_name=os.environ['AWS_REGION'])

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        # Parse input arguments from the request event
        ssm_parameter_name = event['ssmparameter']
        interval_value = int(event['interval'])
        workspace_id = event['workspaceid']

        # Check if the SSM Parameter exists
        response = ssm_client.get_parameter(Name=ssm_parameter_name)
        parameter_version = response['Parameter']['Version']
        logger.info(f'SSM Parameter exists. Current Parameter Version is : {parameter_version}')

        # Timestamp to be used for unique KeyName while creating Grafana Workspace API Key
        now = datetime.now()

        # Create a new API key in Amazon Managed Grafana
        response = grafana_client.create_workspace_api_key(
            workspaceId=workspace_id,
            keyRole='ADMIN',
            keyName='observability-accelerator-'+now.strftime("%Y%m%d-%H"),
            secondsToLive=interval_value
        )
        new_api_key = '{\"GF_SECURITY_ADMIN_APIKEY\":\"'+response['key']+'\"}'
        new_api_key_name = response['keyName']
        logger.info(f'New API Key Name : {new_api_key_name}')

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
        last_hour_date_time = now - timedelta(hours = 2)
        old_key_name = 'observability-accelerator-'+last_hour_date_time.strftime('%Y%m%d-%H')
        logger.info(f'Deleting key : {old_key_name}')
        grafana_client.delete_workspace_api_key(
            keyName=old_key_name,
            workspaceId=workspace_id
            )
        logger.info(f'Deleted the API Key with name :  {old_key_name}')

        return {
            'statusCode': 200,
            'body': 'API key updated successfully and older key has been deleted'
        }

    except ssm_client.exceptions.ParameterNotFound:
        logger.error('SSM Parameter does not exist')
        return {
            'statusCode': 404,
            'body': 'SSM Parameter does not exist'
        }

    except grafana_client.exceptions.ResourceNotFoundException:
        logger.error('Older API Key does not exist')
        return {
            'statusCode': 200,
            'body': 'New API Key added to SSM Parameter value.'
        }

    except Exception as e:
        logger.error(f'An error occurred: {str(e)}')
        return {
            'statusCode': 500,
            'body': 'Lambda execution failed. Please check CloudWatch Logs for additional information on error encountered.'
        }
