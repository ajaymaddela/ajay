```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

```
```
kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"
```

```
kubectl -n kube-system edit deployment.apps/cluster-autoscaler

- --balance-similar-node-groups
- --skip-nodes-with-system-pods=false
- --scale-down-unneeded-time=10m
- --scale-down-delay-after-add=1m
- --scale-down-delay-after-delete=1m

```

```
get latest eks cluster autoscaler check version
https://github.com/kubernetes/autoscaler/releases?source=post_page-----4aab8c89f9a1--------------------------------

```
kubectl -n kube-system logs -f deployment.apps/cluster-autoscaler