# Demo Multi-Cluster Upgrades at Scale

# Setup:
- Install idpbuilder cli https://github.com/cnoe-io/idpbuilder

## Run

Deploy clusters:
```shell
idpbuilder create --kind-config kind-config.yaml -c argocd:argocd/in-cluster.yaml --use-path-routing -p platform -p vcluster-generator --dev-password
```

## Web UIs
- ArgoCD: https://cnoe.localtest.me:8443/argocd
- Gitea: https://cnoe.localtest.me:8443/gitea
- Grafana: https://cnoe.localtest.me:8443/grafana
- Prometheus: https://cnoe.localtest.me:8443/prometheus

Grafana username `admin` password is `prom-operator`

Get Passwords (ArgoCD, Gitea):
```shell
idpbuilder get secrets
```

## Watch mode
As you make changes to yaml files they can be auto sync to gitea run with `--no-exit`
```shell
idpbuilder create --kind-config kind-config.yaml -c argocd:argocd/in-cluster.yaml --use-path-routing -p platform -p vcluster-generator --no-exit
```

## Using vcluster

Connect to a cluster
```shell
vcluster connect cluster-0
```

Disconnect from cluster
```shell
vcluster disconnect
```


## Clean
```shell
kind delete cluster --name localdev
```


## Appendix
You can use idpbuilder to extract secrets

For example for grafana, label the secret
```shell
kubectl label secret -n monitoring kube-prometheus-stack-grafana "cnoe.io/cli-secret=true"
```
Extract with idpbuilder
```shell
idpbuilder get secrets -o json | jq -r '.[] | select(.name == "kube-prometheus-stack-grafana") .data."admin-user"'
idpbuilder get secrets -o json | jq -r '.[] | select(.name == "kube-prometheus-stack-grafana") .data."admin-password"'
```

# Clusters
Argo Clusters are represented by secrets labeled with argocd.argoproj.io/secret-type=cluster AND clusterType=vcluster in the namespace argocd, they are part of the fleet of clusters
The Argo Clusters have additional labels that categorize the grouping of these clusters labels like cloud, environment, location, org, maintenanceGroup, provider, clusterName

## Example Table of Cluster sorted by deployment order
| CLUSTER | ORG | CLOUD | REGION | ENV | GROUP | K8S_VERSION |
|---------|-----|-------|--------|-----|-------|-------------|
| cluster-0 | team-1 | aws | us-east-1 | staging | staging-a | v1.32.0 |
| cluster-2 | team-1 | azure | us-east-1 | staging | staging-a | v1.32.0 |
| cluster-4 | team-1 | gcp | us-east-1 | staging | staging-b | v1.32.0 |
| cluster-6 | team-2 | aws | us-east-1 | staging | staging-b | v1.32.0 |
| cluster-8 | team-2 | azure | us-east-1 | staging | staging-c | v1.32.0 |
| cluster-1 | team-1 | aws | us-east-1 | production | production-a | v1.32.0 |
| cluster-3 | team-1 | azure | us-east-1 | production | production-a | v1.32.0 |
| cluster-5 | team-1 | gcp | us-east-1 | production | production-b | v1.32.0 |
| cluster-7 | team-2 | aws | us-east-1 | production | production-b | v1.32.0 |
| cluster-9 | team-2 | azure | us-east-1 | production | production-c | v1.32.0 |
