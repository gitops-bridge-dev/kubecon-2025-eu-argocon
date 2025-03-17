# addon-atascado

A simple Helm chart that demonstrates how an ArgoCD application can get stuck in the "Progressing" state.

## Purpose

This chart is designed for ArgoCD conference demonstrations to show how applications can get stuck in the synchronization process when resources like Jobs don't complete.

## Components

1. **ConfigMap**: A simple ConfigMap with a message about the demo

2. **Job with conditional behavior**: The key component that will cause ArgoCD to stay in the "Progressing" state, but only in specific conditions:
   - Uses a busybox container
   - Checks if the two magic words (`magicWord1` and `magicWord2`) match
   - If magic words match, it enters an infinite loop and never completes
   - If magic words don't match, it completes normally
   - Has backoffLimit set to 0 to prevent retries

## How it works

When ArgoCD deploys this chart:
1. The ConfigMap is created successfully
2. The Job checks if magic words match:
   - If `magicWord1` and `magicWord2` have the same non-empty value, the Job will never complete, causing ArgoCD to stay in "Progressing" state
   - If the magic words don't match, the Job completes normally, allowing ArgoCD to reach "Synced" state

## Configuration

You can configure the chart behavior with the following values:

```yaml
# values.yaml
# Magic words that will cause the job to get stuck if they match
magicWord1: "abracadabra"
magicWord2: "hocus-pocus"
```

## Usage in Demo

To use this chart in your ArgoCD conference demo:

### Using magic words to trigger stuck state
1. Create an ArgoCD Application with `magicWord1` and `magicWord2` set to the same value
2. Show how the application gets stuck in "Progressing"
3. Create another ArgoCD Application with different values for `magicWord1` and `magicWord2`
4. Show how this application completes successfully

### Demo Explanation
5. Explain how Jobs and other resources that have completion criteria can affect ArgoCD sync status
6. Demonstrate troubleshooting approaches for applications stuck in this state

## Cleanup

When you're done with the demo, you can manually delete the job:
```
kubectl delete job atascado-job
```

Or delete the entire ArgoCD application.
