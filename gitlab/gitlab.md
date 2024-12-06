## On git lab ci/cd configuring the self hosted git lab runner

```
https://docs.gitlab.com/runner/install/linux-repository.html
```
## In gitlab hosted runner are directly enabled we can also disable it if requires.

## for ubuntu
```
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash

sudo apt install gitlab-runner
```
## Go to gitlab ci portal in settings ci/cd go to runners and Project runners and click on add project runners and give sample name and create runner then it will pop up new page with below content.

```
gitlab-runner register  --url https://gitlab.com  --token glrt-t3_mRT-F9NVH1vshve1RGSg
```

## After installing it we have register the ec2 instance to gitlab ci

```
sudo gitlab-runner register
```
```
Then specify the gitlab server url ex:https://gitlab.com/
```


## creating git lab runner on cluster 

## in group section click on build and click on gropu runners create a runner with sample name

## after creating runner while registerig copy the token, click on kuberenetes container, and it will prompt a new page

```
glrt-t2_TkxFVc91ztnj5d1xH4pu #Token

kubectl create ns runner

helm repo add gitlab https://charts.gitlab.io

helm repo update gitlab

helm install --namespace runner gitlab-runner -f values.yaml gitlab/gitlab-runner

```

## In values.yaml update

```
gitlabUrl: https://gitlab.com/

runnerToken: "glrt-t2_79fCXUPJFbYdDWVDHav2"

use this values.yaml file in above helm install command

```

## Using rbac for runner in rbac.yaml
## use kubectl apply -f rbac.yaml

```
# gitlab-runner-rbac.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: runner  # The namespace where GitLab Runner is installed
  name: gitlab-runner-role
rules:
  - apiGroups: [""]
    resources: ["pods", "pods/exec", "pods/log", "secrets", "serviceaccounts", "services", "events", "namespaces", "pods/attach"]
    verbs: ["create", "get", "list", "update", "delete"]  # Allow all actions on secrets

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: gitlab-runner-binding
  namespace: runner  # The namespace where GitLab Runner is installed
subjects:
  - kind: ServiceAccount
    name: default  # The service account used by GitLab Runner
    namespace: runner  # The namespace where GitLab Runner is installed
roleRef:
  kind: Role
  name: gitlab-runner-role
  apiGroup: rbac.authorization.k8s.io

```

## kubectl get pods -n runner


## In order to install git lab agent on cluster
## create a file ajaymaddela
```
.gitlab/agents/<agent-name>/config.yaml
```
## In config.yaml
```
ci_access:
  projects:
    - id: "ajaymaddela" ## project name  
```
## give access to particular project
## Installing gitlab agent on cluster on operate section use kubernetes clusters and click on connect cluster

## select the Register agent with the UI file appears with the agent name and click on register

## in next prompt provide the installation steps as shown below

```
helm repo add gitlab https://charts.gitlab.io
helm repo update
helm upgrade --install my-agent2 gitlab/gitlab-agent \
    --namespace gitlab-agent-my-agent2 \
    --create-namespace \
    --set config.token=glagent-Z2dutqndaoyuMFsFoxWzVRmmBj4TseE-J24d7ZiybftUkYWobg \
    --set config.kasAddress=wss://kas.gitlab.com

```


## Connect private repo to argocd 

## Register the repo using argocd cli, install the argocd cli first

```
argocd login http://74.179.232.45/ --username admin --password cLO5nHEyCiuUGfeC
```

## Use below command to regitser the repo and after run the application.yaml

```
argocd repo add https://gitlab.com/ajay3961047/ajaymaddela.git \
  --username ajay3961047 \
  --password glpat-p7pd5xVziD8AQ22ZFFdk \
  --name gitlab-repo
```

## Apply application.yaml





