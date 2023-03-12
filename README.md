# JenkinsASCode

### Requirements
- [docker](https://docs.docker.com/engine/install/)
- [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [ngrok](https://ngrok.com/download) 

``set ngrok-authtoken in var env NGROK_TOKEN``

### Deploy jenkins in local docker env
- sudo make init-data
- make ngrok-start
- make deploy
- make jenkins-url

only for first installation
- make jenkins-initialAdminPassword

### Destroy jenkins in local docker env
- make destroy

if remove all jenkins file (docker volumes)
- make clean-data


### updating plugin [configuration-as-code](https://plugins.jenkins.io/configuration-as-code/)

add file jenkins.yaml in data/jenkinsAsCode/seedJob.groovy

```yaml
jenkins:
  systemMessage: "Jenkins configured automatically by Jenkins Configuration as Code plugin\n\n"
  securityRealm:
    local:
      users:
        - id: jenkins-admin
          password: pwd-admin
  globalNodeProperties:
    - envVars:
        env:
          - key: GITHUB_CREDENTIALS_ID
            value: github-cred
jobs:
  - file: "/var/jenkins_home/jenkinsAsCode/seedJob.groovy"
credentials:
  system:
    domainCredentials:
      - credentials:
          - usernamePassword:
              id: "github-cred"
              username: "user"
              password: "pswd"
              scope: GLOBAL
```

add file seedJob.groovy in data/jenkinsAsCode/seedJob.groovy

```yaml
job('seedJob') {
    scm {
        git {
            branch('main')
            remote {
                credentials('github-cred')
                github('owner/pipelines-repo')
            }
        }
    }
    steps {
        dsl {
            external('pipelines/*.groovy')
            removeAction('DELETE')
        }
    }
}
```