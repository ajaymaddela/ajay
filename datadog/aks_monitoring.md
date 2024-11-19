# on the aks cluster using below command to add repo

helm repo add datadog https://helm.datadoghq.com

helm repo update

# install using below values

helm install datadog datadog/datadog -n datadog \
  --set datadog.clusterName='example-aks1' \
  --set datadog.site='datadoghq.com' \
  --set datadog.clusterAgent.replicas='2' \
  --set datadog.clusterAgent.createPodDisruptionBudget='true' \
  --set datadog.kubeStateMetricsEnabled=true \
  --set datadog.kubeStateMetricsCore.enabled=true \
  --set datadog.logs.enabled=true \
  --set datadog.logs.containerCollectAll=true \
  --set datadog.apiKey='f1e8c8fe9a835b5bc3d5c80c26b026b3' \
  --set datadog.processAgent.enabled=true \
  --create-namespace


# go to datadog dashboard and in infrastructure view kubernetees overview we can see all the things associated with it.