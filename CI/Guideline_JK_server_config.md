## Continuous integration of Wi-Fi Examples: Jenkin server configuration guideline (Internal use only)

### Jenkins server configuration
* Step 1: Create a new job build. Under [New Item], enter your job name & select [Pipeline] type project. For example: CI_GSDK_Wi-Fi_examples
* Step 2: Job configuration. Press [Configure] button in the just created project.
    * In "General" tab. Set Git server connection for our project. For example: In our side is GIT3-FSOFT server.
        <p align="center">
        <img src="resources/git_connection.png" width="70%" title="git project connection" alt="git project connection"/>
        </p>
    * In "Pipeline" tab. Set URL to our Git repository & branches to build. For example: In our side, we must add our credentials to access internal git system. See [**Credentials Creation**](#adding-credentials) for more details
        <p align="center">
        <img src="resources/pipeline_branch.png" width="70%" title="git project URL" alt="git project URL"/>
        </p>
    > Note: Script path to directory containing your jenkinsfile
* Step 3: There are many ways to configure build triggers. We consider 2 common ways:
    * Periodically build with schedule:
        <p align="center">
        <img src="resources/periodic_trigger.png" width="70%" title="Build periodically" alt="Build periodically"/>
        </p>
    * Push/Merge request events:
        Check on "Build when a change is pushed to..", remember copy the web hook url
        <p align="center">
        <img src="resources/change_build.png" width="70%" title="Build periodically" alt="Build periodically"/>
        </p>
        Click on "Advanced", filter branches that can trigger by regex & generate a secret token.
        <p align="center">
        <img src="resources/advanced_trigger.png" width="70%" title="Advanced settings" alt="Advanced settings"/>
        </p>
        Go to Git server settings (You maybe need to be the master role of your repo), click on Webhook & fill in as the image. Remember to copy & paste the previous secret token from Jenkins server
        <p align="center">
        <img src="resources/webhook_setting.png" width="70%" title="Webhook settings" alt="Webhook settings"/>
        </p>
        After setting, we can test Webhook by push event
        <p align="center">
        <img src="resources/webhook_test.png" width="70%" title="Webhook test" alt="Webhook test"/>
        </p>

> Note: We assume the IT/DevOps department already provide us a slave machine connected to Jenkins server. Remember to change "SLAVE_LABEL" to yours (in our case, slave label is "10.16.118.60"). Actually, we can set "SLAVE_LABEL" in Jenkins server, no need to hard-coded in Jenkinsfile. But I don't think IT department will allow us to set the global environment "SLAVE_LABEL" value on their server. --> We must adapt this by changing the value in Jenkinsfile.
### Adding Credentials 
#### Method #1: Using HTTPS
* Generate Git Access Token
    Under [Settings], click on [Access Tokens]. Fill in & check on boxes as the images:
        <p align="center">
        <img src="resources/generate_token.png" width="70%" title="git access token" alt="git access token"/>
        </p>
    > Important note: Save the generated access token for the next step!
* Adding JK's credentials 
    Back to Jenkins server main page, under [Credentials] tab, click on "(global)" & "Add credentials" with kind: "User name with password". Enter your Git's account & the generated Access Token as your password.
        <p align="center">
        <img src="resources/credentials_https.png" width="70%" title="git access token" alt="git access token"/>
        </p>
#### Method #2: Using SSH
* If already exist, skip this generation step, go to next step. If not, generate private & public SSH keys by using the command tool ssh-keygen on personal machine.
* Skip this step if you already added this. If not, copy public key (file id_rsa.pub) to Git server.
    <p align="center">
    <img src="resources/git_public_key.png" width="70%" title="git access token" alt="git access token"/>
    </p>
* Copy private key (file id_rsa) to Jenkins credentials.
    <p align="center">
    <img src="resources/jenkins_private_key.png" width="70%" title="git access token" alt="git access token"/>
    </p>


