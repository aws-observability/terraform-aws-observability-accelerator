import sys
import unittest
from unittest.mock import patch, MagicMock
from botocore.exceptions import ClientError
from datetime import datetime, timedelta


# Importing lambda function
sys.path.append('../../../src')

import lambda_function

class TestLambdaFunction(unittest.TestCase):

    # Success Test Case 
    @patch('lambda_function.boto3.client')
    def test_lambda_handler_success(self, mock_boto_client):

        # Mocking the clients 
        mock_grafana_client = MagicMock()
        mock_ssm_client = MagicMock()
        mock_boto_client.side_effect = lambda service_name, **kwargs: {
            'grafana': mock_grafana_client, 
            'ssm': mock_ssm_client
        }[service_name]

        # Deleting hour-2 API key to deal with the limit of 100 keys per WorkSpace
        now = datetime.now()
        last_hour_date_time = now - timedelta(hours = 2) 
        current_api_key_name = 'observability-accelerator-'+now.strftime("%Y%m%d-%H")
        old_api_key_name = 'observability-accelerator-'+last_hour_date_time.strftime('%Y%m%d-%H')

        # Mock Grafana create_workspace_api_key response 
        mock_grafana_client.create_workspace_api_key.return_value = {'key': 'dummy_api_key'}
        
        # Mock SSM put_parameter response 
        mock_ssm_client.put_parameter.return_value = {'Version': 1}

        event = {
            'ssmparameter': '/my/api/key',
            'workspaceid': 'g-1234567890',
            'interval': 5400
        }
        context = {}

        # Mock Grafana delete_workspace_api_key response 
        mock_grafana_client.delete_workspace_api_key.return_value = {}

        # Invoke the lambda handler
        response = lambda_function.lambda_handler(event, context)

        # Assert the lambda function returned the expected response
        self.assertEqual(response['statusCode'], 200)
        self.assertIn('API key created and SSM parameter updated successfully!', response['body'])
        

        # Assert API Key was created with expected parameters
        mock_grafana_client.create_workspace_api_key.assert_called_with(
            workspaceId='g-1234567890',
            keyRole='ADMIN',
            keyName=current_api_key_name,
            secondsToLive=5400
        )

        # Assert the SSM parameter was updated with expected parameters
        mock_ssm_client.put_parameter.assert_called_with(
            Name='/my/api/key',
            Value='{"GF_SECURITY_ADMIN_APIKEY":"dummy_api_key"}',
            Type='SecureString',
            Overwrite=True
        )

        # Assert API Key was deleted with expected parameters
        mock_grafana_client.delete_workspace_api_key.assert_called_with(
            workspaceId='g-1234567890',
            keyName=old_api_key_name
        )


    # Grafana Error Test Case 
    @patch('lambda_function.boto3.client')
    def test_lambda_handler_grafana_error(self, mock_boto_client):

        # Mocking clients
        mock_grafana_client = MagicMock()
        mock_ssm_client = MagicMock()
        mock_boto_client.side_effect = lambda service_name, **kwargs: {
            'grafana': mock_grafana_client, 
            'ssm': mock_ssm_client
        }[service_name]
        
        # Simulate an error when creating Workspace API Key
        mock_grafana_client.create_workspace_api_key.side_effect = ClientError({'Error': {'Code': 'ResourceNotFoundException', 'Message': 'Workspace not found'}}, 'CreateWorkspaceApiKey')

        event = {
            'ssmparameter': '/my/api/key',
            'workspaceid': 'g-1234567890',
            'interval': 5400
        }
        context = {}

        response = lambda_function.lambda_handler(event, context)
        self.assertIn('ResourceNotFoundException', response['body'])


    # SSM Error Test Case 
    @patch('lambda_function.boto3.client')
    def test_lambda_handler_ssm_error(self, mock_boto_client):

        # Mocking clients
        mock_grafana_client = MagicMock()
        mock_ssm_client = MagicMock()
        mock_boto_client.side_effect = lambda service_name, **kwargs: {
            'grafana': mock_grafana_client, 
            'ssm': mock_ssm_client
        }[service_name]

        # Simulate an error when putting API Key to SSM parameter
        mock_grafana_client.create_workspace_api_key.return_value = {'key': 'dummy_api_key'}
        mock_grafana_client.delete_workspace_api_key.return_value = {}

        mock_ssm_client.put_parameter.side_effect = ClientError({'Error': {'Code': 'ParameterLimitExceeded', 'Message': 'Parameter Limit Exceeded'}}, 'PutParameter')

        event = {
            'ssmparameter': '/my/api/key',
            'workspaceid': 'g-1234567890',
            'interval': 5400
        }
        context = {}

        response = lambda_function.lambda_handler(event, context)
        self.assertIn('ParameterLimitExceeded', response['body'])


if __name__ == '__main__':
    unittest.main()


