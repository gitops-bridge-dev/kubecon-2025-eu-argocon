# ArgoCon EU 2025 Demo Multi-Cluster at Scale

# Setup:
- Install idpbuilder cli https://github.com/cnoe-io/idpbuilder

## Run

Deploy clusters:
```shell
idpbuilder create --kind-config kind-config.yaml -p vcluster-multi-env -p platform --use-path-routing
```

Register clusters:
```shell
./vcluster-multi-env/add-vclusters.sh
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
idpbuilder create -p vcluster-multi-env -p platform --no-exit
```

## Clean
```shell
kind delete cluster --name localdev
```
