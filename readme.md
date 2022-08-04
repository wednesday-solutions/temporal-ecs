# AWS ECS - Temporal Deployment

A temporal deployment tool which lets you setup , deploy and get your temporal service running on ECS in few minutes. This tool deploys **Temporal Server** , **RDS** , **OpenSearch** and **Temporal UI**. **AWS Copilot** is used to do the deployment part.


# Getting Started 📌

- Pre - requisites :memo:
    - You need to have AWS Copilot setup in order to make the script work. If you haven't done it already, [go through this.](https://aws.github.io/copilot-cli/docs/getting-started/install/)
- Once you have all things in place , clone this repo and open it in any of your favourite IDE.
- Make sure you are in the root directory of the project, this is where you will execute the next steps.
- Run this command to give the execution permission to the script's.
  `chmod +x setup-temporal.sh update-temporal.sh`
- Run the script `./setup-temporal serverName uiName envName`
- When prompted by copilot init
  `Would you like to deploy a test environment?`
    - Enter `N` (We will create our on env for deployment)
- Have a :popcorn: and watch the things being deployed :rocket:

## All about the script :magic_wand:

`./setup-temporal.sh` will take in three arguments and all are mandatory.
`serverName uiName envName` are the arguments that are required.

- **Server Name** - Specify the name that you want the temporal app and service to be called with. Don't worry about the naming conventions , we will add suffix to the names correctly.

  `serverName-app` will be the app name.

  `serverName-svc` will be the service name.

- **UI Name** -  Specify the name that you want the temporal ui server to be called with. Again , we will take care of the naming conventions :wink:

  `uiName-svc` will be the service name

- **Env Name** - Specify the name for the environment which you want all the services to be deployed. And for the suffix - **We Don't Do That Here**
# Setting up your temporal workflow.
Considering that you have some idea about temporal , let's see how you can use the deployed Temporal servers within your existing workflow and workers.
Incase you are new to temporal, you should consider going through [temporal first.](https://temporal.io/)

When the temporal server is deployed you will get a link on the terminal , you will need this link to point your workflow to the server.

Grab the link and pass it to your WorkflowServiceStubs -

    WorkflowServiceStubs service = WorkflowServiceStubs.newServiceStubs(  
        WorkflowServiceStubsOptions.newBuilder().setTarget("urlToTemporal:7233").build()  
        );
Also if you launch all the services in the same VPC (which is the case with the current deployment) you can simply use the `service discovery url's`  which will always be `{service_name}.{env_name}.{app_name}.local`.

You can read more about copilot service discovery [over here.](https://aws.github.io/copilot-cli/docs/developing/service-discovery/)

When the UI server is deployed you will get another link ,  this link will be used to see the dashboard for your workflow details.

To know more about the script or for detailed tutorial please visit the blogpost.

