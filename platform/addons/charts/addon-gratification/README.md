# addon-gratification

A simple Helm chart that demonstrates how an ArgoCD application can get stuck in the "Degraded" state.

## Purpose

This chart is designed for ArgoCD conference demonstrations to show how applications can get stuck in the synchronization process when resources like Deployment don't successfully run

## How it works

When ArgoCD deploys this chart:
1. The deployment tries to launch with a bad image and gets into a CrashLoopBackoff state

## Cleanup

When you're done with the demo, you can manually delete the deployment:
```
kubectl delete deployment gratification
```

Or delete the entire ArgoCD application.
