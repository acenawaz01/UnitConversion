Below are the few development tasks we can take up next.

1. Integrating CD for Dev and Test environments in the pipeline.
2. Setup test cases for the code.
3. Dockerize the application.
4. Configure Code quality step in the pipeline using Sonar cloud.
5. Setup monitoring in cloudwatch for the code deploy.

URL for uploaded artifact: https://api.github.com/repos/acenawaz01/UnitConversion/actions/artifacts

To Setup Project:
1. Fork this repo.
2. Configure access key and secret key as secret in github (Settings --> Secrets)
3. Update access keys in terraform/main.tf
4. Checkout repo locally and cd to terraform folder.
5. Run "terraform init" followed by "terraform apply"
6. This will take care of setting up entire infrastructure including EC2 and CodeDeploy.
7. Once you commit in master branch, it wll trigger workflow and the deployment in Codedeploy.
