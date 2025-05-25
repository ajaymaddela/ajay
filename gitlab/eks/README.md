Deploy Gitlab on Kubernetes —On-Prem + EKS —
1 — Introduction
Yassine Essadraoui
Yassine Essadraoui

Follow
androidstudio
·
February 2, 2025 (Updated: February 2, 2025)
·
Free: No
2 — Understanding Gitlab Components

3 — GitLab Helm chart prerequisites

4— Deploy Gitlab on kube on-prem

5 — Deploy Gitlab on AWS-EKS

5.1 — Provisioning External Postgregsql database — AWS RDS

5.2 — Provisioning External Redis — AWS Elasticache

5.3 — Configuring Storage for Gitaly — EBS

5.4 — Configuring Object Storage — AWS S3

5.5 — Final deployment twists

6— Final thoughts

1 — Introduction:
I will be deploying Gitlab on Kube for both on-prem and on AWS cloud with as much details as possible

Deployment will be done via Gitlab Helm chart which installs by default all components on Kubernetes, it's Ok for testing or learning purposes but for a production grade deployment some components need to be externalized to a more resilient services, especially:

Metadata of users, CI/CD pipelines, settings … are stored in a database => solutions like RDS could be used and configuring regular backups
Gitlab uses cache to improve performance, manages session data, does job scheduling, …. => Redis is used for this purpose, solution like Elasti-cache could be used
CI/CD pipelines produces artifacts, logs, traces, … => object Storage could be used
Gitlab pages for hosting static websites, html pages => Object storage could be used
Gitlab provides a Container Registry for docker images => Object Storage could be used (S3 on AWS)
Gitaly is used to centralize Git operations to Git repositories and it offers a shared storage and it was developed to to remove the need to NFS for Git storage or as it's described by project developers "Fault-tolerant horizontal scaling of Git storage in GitLab, and particularly, on GitLab.com." => EBS storage
In summary:

Gitlab runners cache, Docker registry images, Large File Storage, Gitlab CI artifacts and backups could be stored externally on a highly resilient object storage like S3
Gitlab metadata storage about users, project's settings, … PostgreSQL RDS could be used
Gitlab uses Redis to store Job's data … Elasticache could be used to create a resilient Redis cluster
Gitaly persists Git repositories so storage like EBS could be used
more details here: https://docs.gitlab.com/ee/development/architecture.html

Gitlab Installation on Kubernetes could be better if you have already everything in place with enough Kubernetes knowledge and are aware of these limitations/challenges

I see that deploying Gitlab on Kubernetes could be a good way to dive into more technical details about Gitlab components, I mean that using omnibus installation all components are installed together in one package. On kube, components are deployed separately and give you more visibility on how different components interact with each other

Let's mention that deploying Gitlab on Kubernetes is not a recommendation especially for small or medium enterprises, let's say less than 1000 users (and up to 50000 users) that are actively working on gitlab infrastructure details here, Linux package installation is mature and scalable solution and needs to be considered at first

2 — Understanding Gitlab Components
I will be giving details for these components on diagram below:

None
Gitlab Global Architecture
Gitaly:
This service is installed all the time with any Gitlab installation and it centralizes interactions with git repositories. It is a Git RPC service to handle all operations (git pull, push, …) on Git repositories.

Example: When you visualize a repository on your browser, flows are like this:

None
So storage of a Git repository is done on Gitaly server's physical storage, EBS storage for example if deployed on EC2. On Gitlab Rails (Webservice) config file storage path is defined with "gitaly_address:" parameter.

Example: On a Kube deployment, "webservice" Pod config file is pointing to gitaly svc (gitaly server) gitaly_address: tcp://gitlab-gitaly-0.gitlab-gitaly.gitlab.svc:8075

Gitaly offers possibility to be deployed on High Availability mode in combination with other components like Praefect.

HA overview is:

None
Git repositories storage in HA mode is duplicated on all nodes of Gitaly cluster in a way that "Read" operations are loadbalanced and "Write" operations are brodcasted to all nodes. "gitaly_address:" parameter will point to a virtual storage address

Gitaly Clutser mode has these known issues and considerations

Choosing between Gitaly or Gitaly cluster should be carefully studied and depends on every enterprises specific needs, Gitlab are recommending "GitLab installations for more than 2000 active users performing daily Git write operation may be best suited by using Gitaly Cluster."

Communication between Gitlab (Rails) and Gitaly goes through other components (proxies), for simplicity, I preferred to not include them for the moment but I mention that:

HTTP Git Operations communication goes through Workhorse proxy and
SSH Git Operations communication goes through Gitlab-Shell.
I will go into more details for these components just after

Repository of Gitaly project is here: https://gitlab.com/gitlab-org/gitaly

GitLab Workhorse:
Motivation behind creation of WorkHorse is to maintain connection for long running operations over HTTP that may timeout on large repositories, it is a reverse proxy that resides in front of Gitlab (Rails) and intercepts every HTTP request going in or out from it, in particular git operations (clone, pull, push) over HTTP workhorse send them to Gitaly server presented above. Workhorse main goal is to speed up Gitlab, full story of its creation is here

To be noted that this component had been created while Gitlab were using Unicorn web server, so before migrating to Puma and as mentioned on How we migrated application servers from Unicorn to Puma: "Unicorn is an HTTP server for Rack applications designed to only serve fast clients on low-latency, high-bandwidth connections and take advantage of features in Unix/Unix-like kernels. Slow clients should only be served by placing a reverse proxy capable of fully buffering both the the request and response in between unicorn and slow clients." so WorkHorse came to fill this gap that Unicorn suffers from => instead of letting Git HTTP operations compete with regular Gitlab Rails web access to Gitlab application itself, these Git operations over HTTP have been delegated to Workhorse

Here's a list of features that rely on workhorse: https://docs.gitlab.com/ee/development/workhorse/gitlab_features.html

In summary, workhorse is a reverse proxy in front of Gitlab Rails (Puma) that intercepts all HTTP requests. HTTP requests that need long processing time (file uploads, git blob push or pull …) are delegated to workhorse by Gitlab Rails.

let's take an example of doing a git push over HTTP:

You run "git push" over HTTP for already added and committed files/changes
Request lands on "Gitlab Workhorse" who forwards it to "Gitlab Rails (Puma)"
"Gitlab Rails (Puma)" decides what to do with it and responds to "Gitlab workhorse" with some headers indicating how to proceed after
Then "Gitlab Workhorse" send a gRPC call to Gitaly
None
git push over HTTP
more resources are here:

https://docs.gitlab.com/ee/development/workhorse/handlers.html
https://gitlab.com/gitlab-org/gitlab/-/tree/master/workhorse
https://www.youtube.com/watch?v=9cRd-k0TRqI
Gitlab Shell:
This service is handling Git operation over ssh. This component runs a SSH daemon similar to sshd called "gitlab-sshd"

None
Git fetch over SSH
List of features that rely on Gitlab-Shell is here: https://docs.gitlab.com/ee/development/gitlab_shell/features.html

More details here:

https://docs.gitlab.com/ee/development/gitlab_shell/
Gitlab Rails (Puma):
Puma is Ruby application server that is running Gitlab core application. So this components is the central point of Gitlab solution and handles requests for web interface and API calls

Example of request workflow:

You open your browser at Gitlab web page
Requests land on nginx proxy (see Gitlab Global Architecture above)
Then Gitlab Workhorse, here decision made if forwarding to Gitlab Rails or somewhere else
In this case, Workhorse will forward it directly to Puma
… this flow may continue to services described just after …
PostgreSQL:
Gitlab uses PostgreSql DB to store application meta data and user information. Gitlab comes with a packaged DB for omnibus or Helm chart installation method, for production grade deployments using an external DB in most cases is a better option.

Redis:
Gitlab documentation: "GitLab uses Redis for the following distinct purposes:

Caching (mostly via Rails.cache).
As a job processing queue with Sidekiq.
To manage the shared application state.
To store CI trace chunks.
As a Pub/Sub queue backend for ActionCable.
Rate limiting state storage.
Sessions."
For all these needs one Redis cluster could be used or creating different clusters, for example at Gitlab they are using 11 different Redis clusters, more details on A survival guide for SREs to working with Redis at GitLab

Sidekiq:
Sidekiq is a Ruby background job processor that pulls jobs from the Redis queue and processes them.

Background jobs allow GitLab to provide a faster request/response cycle by moving work to background.

Gitlab pages:
GitLab Pages is a feature that allows you to publish static websites directly from a repository in GitLab.

You can use it either for personal or business websites, such as portfolios, documentation, manifestos, and business presentations.

3 — GitLab chart prerequisites
To install Gitlab on your Kube Cluster, some pre-requisites needs to be fullfilled or prepared in advance, list is here: https://docs.gitlab.com/charts/installation/tools.html

For development deployment of Gitlab :

I will be using in-cluster {PostgreSql, Redis, Gitaly}
Gitlab generates many secrets automatically for different services (Gitlab registry, passwords, …) but if for any reason manual creation of secrets, ssh host keys, … is needed steps are here: https://docs.gitlab.com/charts/installation/secrets.html
Gitlab exposes gitlab-webservice, registry and minio as services of type LoadBalancer, for this we need to specify a domain name during installation, for sake of this demo and on on-prem cluster I will be using "<IP-OF-INGRESS-CONTROLLER-SERVICE>.nip.io", for example: minio.192.168.59.201.nip.io, registry.192.168.59.201.nip.io and gitlab.192.168.59.201.nip.io will be my services domain names
For TLS Certificates, I've installed cert-manager on the cluster but can't use let's encrypt for local development cluster so I will be using a self generated certificate by configuring cert-manager to create self signed clusterissuer
4 — Deploy Gitlab on on-prem kube cluster
Deployment will be done via Gitlab Helm chart. Kube cluster has been prepared by installing and configuring: ingress-nginx, metallb, cert-manager, for networking I'm using Calico.

Gitlab Helm chart Installation requires some values, I'm using these values:

Copy
global:
 hosts:
   domain: 192.168.59.201.nip.io
   externalIP: 192.168.59.201
 ingress: 
   class: nginx
   configureCertmanager: false
   annotations: 
     kubernetes.io/ingress.class: "nginx"
     cert-manager.io/cluster-issuer: "my-ca-issuer"
   tls:
     secretName: tls-secret-name
 registry:
  hpa:
    minReplicas: 1
    maxReplicas: 1
  api:
   serviceName: gitlab-registry
certmanager:
  installCRDs: false
  install: false
nginx-ingress:
  enabled: false
gitlab:
  webservice:
    minReplicas: 1
    maxReplicas: 1
    ingress:
     tls:
      secretName: tls-secret-name-webservice
    resources:
     requests:
      memory: 1G
  kas:
   tls:
    secretName: tls-secret-name-kas
  sidekiq:
    minReplicas: 1
    maxReplicas: 1
  gitlab-shell:
    minReplicas: 1
    maxReplicas: 1
    service:
      type: NodePort
      nodePort: 32022
gitlab-runner:
  install: false
registry:
 ingress:
  tls:
   secretName: tls-secret-name-registry
minio:
 ingress:
  tls:
   secretName: tls-secret-name-minio
Installation of all components (Gitlab, Cert-manager, Metal-LB, ...) are done via helmfile, I will be sharing in a separate article details about helmfile and structure I've adopted

Possible deployment issues:

"Problem accessing main database (gitlabhq_production). Confirm username, password, and permissions." : If you are receiving these errors (possibly from sidekiq and webservice pods) please check (kubectl get jobs) a job named "gitlab-migrations-*". This job needs to complete correctly.
Permission denied issues may happen depending on CSI driver that you are using, you may need to update security contexts:
Copy
redis:
  volumePermissions:
   enabled: true
   containerSecurityContext:
    runAsUser: 0
    fsGroup: 1000
    allowPrivilegeEscalation: true
  master:
   persistence:
    enabled: true
   podSecurityContext:
    enabled: true
    fsGroup: 1000
   containerSecurityContext:
    enabled: true
    runAsUser: 1000
    fsGroup: 1000
postgresql:
 volumePermissions:
  enabled: true 
 primary:
  persistence:
   enabled: true 
  containerSecurityContext:
   runAsUser: 0
   fsGroup: 1000
Gitlab may take a while to bootstrap:

None
to login use: root as username and decode base64 initial root password in secret "*-gitlab-initial-root-password"

5— Deploy Gitlab on AWS-EKS
For this part I will be using external services for a production like deployment, offering more resilience and disaster recovery capabilities leveraging AWS services, options are:

Defining Custom Storage Class and using EBS storage for: Gitaly, Postgresql, Redis and Minio services
Using managed services like RDS for PostgreSql, S3 for object storage, EBS for Gitaly and ElastiCache for Redis
Second option is more expensive but it offers more resilience so I will be using it for this deployment.

5.1 — Provisioning External Postgregsql database — AWS RDS
Some per-requisites need to be fulfilled to use External DB for Gitlab:

PostgreSQL 14 or later
Create a db user ("gitlab" for example) with a custom password. This user must be owner of "gitlabhq_production" default database
RDS needs installation of some extensions: pg_trgm, btree_gist and plpgsql so install them manually prior starting gitlab install or give rds_superuser role to "gitlab" user to be able to install them automatically
"gitlab" user's password needs to be put in a kubernetes secret
Creation of RDS DB will be in the same VPC as EKS cluster, I will be using remote state of vpc module here

For Cost Savings especially during first tries to create RDS, you could provision only (free) required resources with: terraform plan -target=module.vpc -var=enable_nat_gateway=false -parallelism=20

For RDS postgresql required extensions I developed/reused a python script that will be executed with a lambda function invoked via terraform code

I will use a library called "psycopg2" to connect to db:

Copy
import os
import psycopg2
import logging
import json
import sys
import psycopg2.sql as sql
from psycopg2 import OperationalError, ProgrammingError

def lambda_handler(event, context):
    
    username = os.environ['username']
    password = os.environ['password']
    rds_endpoint = os.environ["rds_endpoint"]
    db_name = os.environ["db_name"]
    extensions = json.loads(os.environ["extensions"])

    logger = logging.getLogger(__name__)

    try:
        conn = psycopg2.connect(
        host=rds_endpoint,
        database=db_name,
        user=username,
        password=password
    )
    
    except OperationalError as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Database connection error: {str(e)}")
        }

    logger.info("Succesfully connected to RDS gitlab DB")

    cur = conn.cursor()
    results = []
    ok = True

    for e in extensions:
        print(e)
        try:
            query = sql.SQL("CREATE EXTENSION IF NOT EXISTS {}").format(
                sql.Identifier(e)
            )
            cur.execute(query)
            results.append(f"Extension {e} created successfully.")
        except ProgrammingError as pe:
            conn.rollback()
            results.append(f"Error creating extension {e}: {str(pe)}")
            ok = False
        except Exception as exc:
            conn.rollback()
            results.append(f"Unexpected error with extension {e}: {str(exc)}")
            ok = False

    conn.commit()
    cur.close()
    conn.close()
    
    is_it_ok = 200 if ok else 400

    return {
        'statusCode': is_it_ok,
        'body': json.dumps(results)
    }
All database related details will be added as environment variables and dependencies installed via pip then uploaded a layer of lambda function

5.2 — Provisioning External Redis — AWS Elasticache
Redis stores all user sessions and background tasks for Gitlab

I will be creating a Single Redis Instance node but for resiliency, more architectures need to be considered (HA, Sentinel, …) or using AWS Elasticache Redis Serverless product which is offering the least management overhead from your side, more details are on resources just after.

Resources:

https://architecturenotes.co/p/redis
https://redis.io/learn/develop/node/nodecrashcourse/whatisredis
Redis Caching: https://redis.io/learn/develop/node/nodecrashcourse/caching
Sample Redis Application: https://redis.io/learn/develop/node/nodecrashcourse/sampleapplicationoverview
https://redis.io/technology/redis-enterprise-cluster-architecture/
Session Storage: https://redis.io/learn/develop/node/nodecrashcourse/sessionstorage
Gitlab helm values need to be updated to use Redis Instance, details are here: https://docs.gitlab.com/charts/advanced/external-redis/#configure-the-chart

In summary this needs to be done:

Copy
helm install gitlab gitlab/gitlab  \
  --set redis.install=false \
  --set global.redis.host=redis.example \
  --set global.redis.auth.secret=gitlab-redis \
  --set global.redis.auth.key=redis-password \
In my case I'm using an Helmfile structure to deploy to different environments, I will be sharing this in a separate article soon.

Redis doesn't allow connection from outside a vpc, so create an EC2 instance in the same VPC as Redis or use cloudshell and create a VPC environment (it's what I'm using for quick connectivity testing to Redis)

5.3 — Configuring Storage for Gitaly — EBS
Gitlay persists its storage (git repositories) on storage disks depending on used provider, in case of AWS and EKS there's a challenge where a pod wouldn't be able to access its storage disk if in different AZs. AWS EBS disks are tied to one AZ so any pod using corresponding disk needs to stay on the same AZ as its disk(s)

I'm summarizing this constraint by:

None
Figure EBS AZ
So disk(s) provisioning could be done:

Manually then attach it to PV => example here and more details here
Dynamically via a StorageClass
For me, I will be using second option of creating a StorageClass:

Copy
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: CUSTOM_STORAGE_CLASS_NAME
provisioner: kubernetes.io/aws-ebs
reclaimPolicy: Retain
parameters:
  type: gp2
  zone: '*AWS_ZONE*'
StorageClass must be attached to an availability zone to avoid issue depicted on "Figure EBS AZ" above but EBS disks will be provisioned only on this AZ i.e if there's an AZ unavailability => Gitlab service unavailable, to mitigate this risk, a network storage (like EFS) could be used but unfortunately gitlab doesn't support network storage for Gitaly, declared here (NFS for Git repository storage deprecated and support removed starting from GitLab 14.0)

Gitlab suggesting a solution of using "Gitaly Cluster" to offer a more resilient and high available solution for Gitlay service BUT it adds management complexity (adding new components for traffic routing "Praefect", ensuring replication is correctly done between all gitaly cluster nodes, … see requirements) and its not suited for all enterprises: "GitLab installations for more than 2000 active users performing daily Git write operation may be best suited by using Gitaly Cluster." (more details) I believe most enterprises don't exceed this number of users working actively on Gitlab daily !!

Last thing is that "Gitaly Cluster" is not yet supported on Kubernetes "Gitaly Cluster is not yet supported in Kubernetes, Amazon ECS, or similar container environments. For more information, see epic 6127."

So in a 100% kubernetes deployment approach a single gitaly instance mode is the only option available which is also a single point of failure (SPOF) and a sensitive component to many factors (size of repositories, number of users, …) which makes prediction of resource usage difficult, especially memory usage which could in case of OOM causes Gitaly pod(s) to be terminated which could lead to issue depicted in "Figure EBS AZ" above => interruption of service

Another possible issue is about auto-scaling of EKS/Pods may lead to interruption of service also (automatic scale down for example and termination of pod(s)), PostgreSQL and Redis stateful components have been externalized to be managed by AWS (RDS and ElastiCache) => it would be convenient if possible to externalize this stateful component also !

In summary you should crawl "all" resources/links starting by reference architectures . This starting point is fundamental because it gives you which direction you would head to, it's long but necessary before deploying such important product.

To make Gitaly more "stable" on kube we must leverage kubernetes resources to make gitaly pods less likely to move/evict/…

Points to take care of in view to avoid gitaly disruption of service or at least less likely to happen:

Assign a PriorityClass to Gitaly pods
Prevent Pod(s) eviction by adding annotation: "cluster-autoscaler.kubernetes.io/safe-to-evict: "false""
Putting custom security context for FS group policy to avoid long startup time in case of big repositories "fsGroupChangePolicy: OnRootMismatch"
There's other optimizations that could be done but I will add only these three mentioned just before, gitlab recommendations are here

By the way, I've tried to scale up number of gitaly STS pods to more than one pod to check if pods in this statefulset will behave like Master-Slave i.e git repositories stored in storage of first pod (gitlab-gitaly-0) will replicate to storage of second pod (gitlab-gitaly-1) … but unfortunatly it's not the case.

Copy
 gitaly {"level":"error","error":"failed to render template /etc/gitaly/templates/config.toml.tpl: template: /etc/gitaly/templates/c │
│ onfig.toml.tpl:25:162: executing \"/etc/gitaly/templates/config.toml.tpl\" at <fail>: error calling fail: template generation faile │
│ d: Storage for node 1 is not present in the storageNames array. Did you use kubectl to scale up? You need to solely use helm for th │
│ is purpose.","time":"2025-01-24T12:35:07Z"} 
As mentioned here, "internal.names" should be used to create more gitaly sts pods, by default i's one (named "default"):

Copy
global: 
 gitaly:
   internal:
     names: 
       - default
       - secondary
Second pod (gitlab-gitaly-1) succeeded to start but replication doesn't happen !!

None
None
Replication not happening after a while
It would be a good option by creating 3 pods, 3 storages in 3 different AZs with replication from "gitlab-gitaly-0" pod as master and trigger leader election process when needed (kube nodes upgrade for example, …) => more stable service

Anyway, now let's deploy Gitaly with a storage class tied to us-east-1a AZ.

Copy
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gitlab-gitaly-storage-class-name-gp2
provisioner: kubernetes.io/aws-ebs
reclaimPolicy: Retain
parameters:
  type: gp2
  zone: us-east-1a
PriorityClass:

Copy
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: gitlab-gitaly-priority-class-name
value: 1000000
globalDefault: false
description: "GitLab Gitaly priority class"
I will add these two yaml files to Helmfile as "presync" hooks like:

None
but you could create them via terraform, manually, …

Also I'm creating RDS postgresql secret as a helmfile presync hook, it's hardcoded for the moment but this could be enhanced for more security by retrieving password value from secret manager … for the moment it's ok

5.4 —Configuring Object Storage — AWS S3
Minio is the default object storage for Gitlab that could be disabled and use other providers or NFS storage (not recommended)

I will be configuring S3 instead of minio. This Object Storage is used by Gitlab for different purposes: CI artifacts, uploads, lfs, packages, pages, terraform_state, …

So we will be creating a set of buckets for every type of object.

I've grouped them here:

None
Gitlab S3 Buckets
Buckets will be assigned to every gitlab service type like shown here

Copy
--set global.appConfig.artifacts.bucket=<BUCKET NAME> \
--set global.appConfig.lfs.bucket=<BUCKET NAME> \
--set global.appConfig.packages.bucket=<BUCKET NAME> \
--set global.appConfig.uploads.bucket=<BUCKET NAME> \
--set global.appConfig.externalDiffs.bucket=<BUCKET NAME> \
--set global.appConfig.terraformState.bucket=<BUCKET NAME> \
--set global.appConfig.ciSecureFiles.bucket=<BUCKET NAME> \
--set global.appConfig.dependencyProxy.bucket=<BUCKET NAME>
Also we need to specify how these services will connect to S3 buckets via "connection" property as explained here, the idea is to create kubernetes secrets that points to authentication parameters(please see this example)

Copy
# Example configuration of `connection` secret for Rails
# Example for AWS S3
#   See https://gitlab.com/gitlab-org/charts/gitlab/blob/master/doc/charts/globals.md#connection
#   See https://gitlab.com/gitlab-org/charts/gitlab/blob/master/doc/advanced/external-object-storage
provider: AWS
# Specify the region
region: us-east-1
# Specify access/secret keys
aws_access_key_id: AWS_ACCESS_KEY
aws_secret_access_key: AWS_SECRET_KEY
# The below settings are for S3 compatible endpoints
#   See https://docs.gitlab.com/ee/administration/object_storage.html#s3-compatible-connection-settings
# aws_signature_version: 4
# host: storage.example.com
# endpoint: "https://minio.example.com:9000"
# path_style: false
In my case, I won't be using secrets as that needs to store AWS access keys in secrets but I will configure IRSA (that I've already discussed in detail here)

Steps are:

Configure Gitlab Helm chart to create service account for different Gitlab services, I mean this:
None
This could be configured like this:

Copy
global:  
  serviceAccount:
    enabled: true
    create: true
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::xxxxxxxxxxxx:role/gitlab_s3_access_iam_role
This will auto-create SAs for different Gitlab services but if you would like to create SAs yourself just put "global.serviceAccount.create: false" and follow instructions here

Add annotation(s) to these service accounts pointing to IAM role:
None
This step is done vi Helm values just shared before

I mention that IAM roles could be created separately on ServiceAccount basis for every Gitlab service (registry, webservice, migrations, …) in my case I will use one Role for all of them for simplicity but if there's any strict security requirements this is achieveable like here

Create via TF IAM role that will give permissions to S3 buckets respectively
Configure via TF trust relationship between this Role and federated identities
These two steps are configured and permissions given to SAs are based on this document

Copy
data "aws_iam_policy_document" "gitlab_iam_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["${local.oidc_provider_arn}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "${local.oidc_provider}:sub"

      values = [
        "system:serviceaccount:gitlab:*"
      ]
    }
  }
}

resource "aws_iam_role_policy" "gitlab_iam_role_sa_permissions_policy" {
  name = "gitlab_iam_role_sa_permissions_policy"
  role = aws_iam_role.gitlab_s3_access_iam_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ]
        Effect = "Allow"
        Resource : [
          "arn:aws:s3:::gitlab-*-objects/*"
        ]
      },
      {
        Effect : "Allow",
        Action : [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads"
        ],
        Resource : "arn:aws:s3:::gitlab-*-objects"
      }
    ]
  })
}

resource "aws_iam_role" "gitlab_s3_access_iam_role" {
  name               = "gitlab_s3_access_iam_role_name"
  assume_role_policy = data.aws_iam_policy_document.gitlab_iam_assume_role_policy.json

  tags = {
    Environment = var.env
    Name        = "gitlab-s3-access-iam-role"
  }
}
For simplicity I've given permissions for all federated SAs in "gitlab" namespace and S3 permissions are on any S3 bucket starting with "gitlab-" and ending with "-objects"

Adapting Helm values to point Gitlab services to their respective bucket, example here
This last step consists of:

For Registry service to be able to authenticte via IRSA to S3 this secret content needs to be created before:
Copy
apiVersion: v1
kind: Secret
metadata:
  name: registry-storage-secret
  namespace: gitlab
type: Opaque
stringData:
  config: |
    s3:
      bucket: "gitlab-registry-objects"
      region: us-east-1
      v4auth: true
This could be confirmed via:

Copy
git@gitlab-registry-86b9d44b47-p62td:/$ env | grep -i AWS
AWS_DEFAULT_REGION=us-east-1
AWS_REGION=us-east-1
AWS_ROLE_ARN=arn:aws:iam::1111111111:role/gitlab_s3_access_iam_role_name
AWS_WEB_IDENTITY_TOKEN_FILE=/var/run/secrets/eks.amazonaws.com/serviceaccount/token
AWS_STS_REGIONAL_ENDPOINTS=regional
git@gitlab-registry-86b9d44b47-p62td:/$
or check "gitlab-registry-objects" S3 bucket, a first folder "docker" should be created

For Toolbox service (backups):
A secret with this content (omitting access and secret keys) needs to be created first:

Copy
apiVersion: v1
kind: Secret
metadata:
  name: s3cmd-config
  namespace: gitlab
type: Opaque
stringData:
  config: |
    [default]
    bucket_location = us-east-1
Put correct Helm values like:

Copy
gitlab:
  toolbox:
    backups:
      objectStorage:
        config:
          secret: s3cmd-config
          key: config
You could confirm everything is working fine by accessing toolbox pod and run:

s3cmd ls (or la)
Copy
ERROR: S3 error: 403 (AccessDenied): User: arn:aws:sts::111111111111:assumed-role/gitlab_s3_access_iam_role_name/role-session-1738244106 is not authorized to perform: s3:ListAllMyBuckets because no identity-based policy allows the s3:ListAllMyBuckets action
Then run:

s3cmd ls s3://gitlab-registry-objects
Copy
                          DIR  s3://gitlab-registry-objects/docker/
Also and if everything is good you should be able to run "backup-utility" from inside Toolbox pod:

None
Then check your bucket (gitlab-backup-objects in my case), a first backup will be there (.tar)

For Sidekiq and webservice services (LFS, Artifacts, Uploads, Packages):
A secret with this content needs to be created first:

Copy
apiVersion: v1
kind: Secret
metadata:
  name: object-store-connection
  namespace: gitlab
type: Opaque
stringData:
  connection: |
    provider: AWS
    region: us-east-1
    use_iam_profile: true
Put Helm values like:

Copy
global:
  appConfig:
    object_store:
       enabled: true
       connection:
        secret: object-store-connection
        key: connection
Last step is to put Helm values to map S3 buckets < = > Gitlab Services as:

Copy
global:
    lfs:
      bucket: gitlab-git-lfs-objects
    artifacts:
      bucket: gitlab-artifacts-objects
    uploads:
      bucket: gitlab-uploads-objects
    packages:
      bucket: gitlab-packages-objects
    backups:
      bucket: gitlab-backup-objects
      tmpBucket: gitlab-tmp-objects
    externalDiffs:
      bucket: gitlab-mr-diffs-objects
    dependencyProxy:
      bucket: gitlab-dependency-proxy-objects
    terraformState:
      bucket: gitlab-terraform-state-objects
    pages:
      bucket: gitlab-pagess-objects
    ciSecureFiles:
      bucket: gitlab-ci-secure-files-objects
5.5 — Final deployment twist:
To deploy Gitlab and to be publicly exposed that needs a public domain name, I used a free domain name provider ClouDNS. It gives possibility to create a hosted Zone under "ip-ddns.com", I've created "gitlablab.ip-ddns.com"

This free domain name consider it as your custom domain and go to AWS route 53 then create a hosted zone as a sub domain, I've chosen "gitlablab.gitlablab.ip-ddns.com", Route 53 will give you NS servers that it assigned to your hosted zone, go back to ClouDNS UI and add them as NS records

This way you will have a publicly accessible domain name that works with automatic certificate generation/renewal and External-DNS automatic records creation

Gitalb UI will be accessible at "gitlab.gitlablab.gitlablab.ip-ddns.com", registry at: "regsitry.gitlablab.gitlablab.ip-ddns.com"

External-DNS configuration is done via Helm/Helmfile installation, example values:

Copy
provider:
  name: aws
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::111111111111:role/external-dns-irsa-role
sources:
  - ingress
interval: 5m
domainFilters:
  - gitlablab.gitlablab.ip-ddns.com
External-DNS controller will be listening to ingresses. To be able to add records to your hosted zone (gitlablab.gitlablab.ip-ddns.com in my case), create a role, establish a trust policy and give permissions like:

Trust relationship:

Copy
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::<ACC-ID>:oidc-provider/oidc.eks.region-code.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.region-code.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "oidc.eks.region-code.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE:sub": "system:serviceaccount:external-dns:external-dns"
                }
            }
        }
    ]
}
Role permissions:

Copy
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:ListResourceRecordSets",
                "route53:ListTagsForResource"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
6— Final thoughts:
Deploying gitlab on kubernetes is not the first option to be considered, it may be a good fit for (very) large organizations. In most cases, I believe, standalone deployment (omnibus) is enough, having a look at initial sizing suggested here, a standalone deployment described here and for 2000 users actively working on gitlab is fairly enough. For larger entreprises options of high availability could be introduced especially for Gitaly …

Installation on Kube adds a (lot) of management overhead to DevOps team (depending on chosen components "Gitaly Cluster", …) an SRE/DevOps should have a look at SRE Gitaly on AWS , also risk of service unstability is high and to reduce risk of unstability, cost of having a dedicated Gitlab team will be high because beyond of Kubernetes mastering, gitlab components need good understanding (bahaviour during upgrades for example is different on omnibus and kube, …), you could play with thhis here: https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/blob/main/docs/environment_advanced_hybrid.md

A hybrid approach is also possible by installing stateless components on Kubernetes and stateful components installed via omnibus on VM(s) details here:

https://docs.gitlab.com/charts/advanced/
https://docs.gitlab.com/ee/administration/reference_architectures/2k_users.html#cloud-native-hybrid-reference-architecture-with-helm-charts-alternative
Talking about costs, you could have a look at these cost templates here: https://docs.gitlab.com/ee/administration/reference_architectures/index.html#cost-calculator-templates

All this said and we didn't talk yet about gitlab-runners that will execute jobs and they need a good amount of management and fine tuning …

At the end, Decision tree should follow this logic: https://docs.gitlab.com/ee/administration/reference_architectures/index.html#decision-tree