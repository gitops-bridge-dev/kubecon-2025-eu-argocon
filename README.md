# ArgoCon EU 2025 Demo Multi-Cluster at Scale

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
kubeclt label secret -n monitoring kube-prometheus-stack-grafana "cnoe.io/cli-secret=true"
```
Extract with idpbuilder
```shell
idpbuilder get secrets -o json | jq -r '.[] | select(.name == "kube-prometheus-stack-grafana") .data."admin-user"'
idpbuilder get secrets -o json | jq -r '.[] | select(.name == "kube-prometheus-stack-grafana") .data."admin-password"'
```
