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

