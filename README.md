# ArgoCon EU 2025 Demo Multi-Cluster at Scale

# Setup:
- Install idpbuilder cli https://github.com/cnoe-io/idpbuilder

## Run

```shell
idpbuilder create --kind-config kind-config.yaml -p vcluster-multi-env -p platform
./vcluster-multi-env/add-vclusters.sh
```

## Web UIs
- ArgoCD: https://argocd.cnoe.localtest.me:8443
- Gitea: https://gitea.cnoe.localtest.me:8443
- Grafana: https://grafana.cnoe.localtest.me:8443
- Prometheus: https://prometheus.cnoe.localtest.me:8443

Grafana username and password is admin/prom-operator

Get Passwords (ArgoCD, Gitea):
```shell
idpbuilder get secrets
```

## Watch mode
As you make changes to yaml files they can be auto sync to gitea run with `--no-exit`
```shell
idpbuilder create -p vcluster-multi-env -p platform --no-exit
```

## Clean
```shell
kind delete cluster --name localdev
```
