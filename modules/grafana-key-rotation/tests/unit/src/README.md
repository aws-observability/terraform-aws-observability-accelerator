### Steps to perform Unit Tests with the Lambda function
1. Pre-requisites 
   - Install and configure AWS CLI in the local environment and set the desired region using the `aws configure` command.
   - Create an EKS Cluster and NodeGroup. 
2. From the folder you want to create your project in, clone the repo using the following command : 
   - `git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git`
3. Navigate to the following directory : 
   - `cd modules/grafana-key-rotation/tests/unit/src` 
4. Run Unit Tests using the following command : 
   - `python3 -m unittest test_lambda_function.py`
   - Note : If you have a different version of python installed on the local, modify the command to use the correct version; for example `python -m unittest test_lambda_function.py`
5. Expected Output that represents a successful execution of Unit Tests: 
    ```
    $ python3 -m unittest test_lambda_function.py
    Event received is :  {'ssmparameter': '/my/api/key', 'workspaceid': 'g-1234567890', 'interval': 5400}
    An error occurred: An error occurred (ResourceNotFoundException) when calling the CreateWorkspaceApiKey operation: Workspace not found
    .Event received is :  {'ssmparameter': '/my/api/key', 'workspaceid': 'g-1234567890', 'interval': 5400}
    An error occurred: An error occurred (ParameterLimitExceeded) when calling the PutParameter operation: Parameter Limit Exceeded
    .Event received is :  {'ssmparameter': '/my/api/key', 'workspaceid': 'g-1234567890', 'interval': 5400}
    .
    ----------------------------------------------------------------------
    Ran 3 tests in 0.006s
    
    OK
    ```