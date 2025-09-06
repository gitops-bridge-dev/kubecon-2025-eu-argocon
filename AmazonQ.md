# Cert-Manager Fleet Upgrade Demo

## Demo Scenario: Upgrade cert-manager to v1.17.1 across 10-cluster fleet

### Current State
- **CI**: v1.17.1 (already latest)
- **Staging-A**: v1.16.4 (cluster-0, cluster-2)
- **Staging-B**: v1.16.3 (cluster-4, cluster-6, cluster-8)
- **Production Canary**: v1.15.5
- **Production-A**: v1.15.4 (cluster-1, cluster-3)
- **Production-B**: v1.15.3 (cluster-5, cluster-7, cluster-9)

### Proper Rollout Process

#### Step 1: Update Staging First
```bash
# Update staging environments to v1.17.1
# Edit platform/addons/clusters/fleet/cert-manager.yaml
# Change staging maintenanceGroup a: v1.16.4 → v1.17.1
# Change staging maintenanceGroup b: v1.16.3 → v1.17.1

git add . && git commit -m "cert-manager: Update staging to v1.17.1"

# Sync staging clusters
for cluster in cluster-0 cluster-2 cluster-4 cluster-6 cluster-8; do
  kubectl patch application cert-manager-$cluster -n argocd --type merge -p '{"operation":{"sync":{"revision":"HEAD"}}}'
done
```

#### Step 2: Validate Staging
```bash
# Check staging deployment status
kubectl get applications -n argocd | grep "cert-manager-cluster-[02468]"

# All should show: Synced & Healthy
```

#### Step 3: Production Rollout (After Staging Validation)
```bash
# 3a. Update Production Canary
# Edit cert-manager.yaml: canary v1.15.5 → v1.17.1
git add . && git commit -m "cert-manager: Update production canary to v1.17.1"

# 3b. Update Production-A (cluster-1, cluster-3)
# Edit cert-manager.yaml: production maintenanceGroup a: v1.15.4 → v1.17.1
git add . && git commit -m "cert-manager: Update production-a to v1.17.1"
for cluster in cluster-1 cluster-3; do
  kubectl patch application cert-manager-$cluster -n argocd --type merge -p '{"operation":{"sync":{"revision":"HEAD"}}}'
done

# 3c. Update Production-B (cluster-5, cluster-7)
# Edit cert-manager.yaml: production maintenanceGroup b: v1.15.3 → v1.17.1
git add . && git commit -m "cert-manager: Update production-b to v1.17.1"
for cluster in cluster-5 cluster-7; do
  kubectl patch application cert-manager-$cluster -n argocd --type merge -p '{"operation":{"sync":{"revision":"HEAD"}}}'
done

# 3d. Add Production-C (cluster-9)
# Add new selector for maintenanceGroup c: v1.17.1
git add . && git commit -m "cert-manager: Add production-c and update to v1.17.1"
kubectl patch application cert-manager-cluster-9 -n argocd --type merge -p '{"operation":{"sync":{"revision":"HEAD"}}}'
```

#### Step 4: Final Validation
```bash
# Check all clusters
echo "=== STAGING CLUSTERS ==="
kubectl get applications -n argocd | grep "cert-manager-cluster-[02468]"

echo "=== PRODUCTION CLUSTERS ==="
kubectl get applications -n argocd | grep "cert-manager-cluster-[13579]"

# All should show: Synced & Healthy
```

### Key Demo Points
1. **Staging First**: Always validate in staging before production
2. **Maintenance Groups**: Controlled rollout using maintenance group ordering
3. **Git-based**: Each step is a separate commit for rollback capability
4. **ArgoCD Sync**: Applications automatically sync from Git changes
5. **Fleet Scale**: Managing 10 clusters across multiple clouds/environments

### Rollback for Next Demo
```bash
# Reset to original state
git checkout b69c971 -- platform/addons/clusters/fleet/cert-manager.yaml
git add . && git commit -m "DEMO RESET: Rollback cert-manager to original versions"

# Sync all clusters back
for cluster in cluster-{0..9}; do
  kubectl patch application cert-manager-$cluster -n argocd --type merge -p '{"operation":{"sync":{"revision":"HEAD"}}}'
done
```

### Validation Commands
```bash
# Monitor applications
kubectl get applications -n argocd | grep cert-manager

# Check specific cluster
vcluster connect cluster-1
kubectl get pods -n cert-manager
kubectl get deployment cert-manager -n cert-manager -o jsonpath='{.spec.template.spec.containers[0].image}'
```

### Web UIs for Demo
- **ArgoCD**: https://cnoe.localtest.me:8443/argocd
- **Gitea**: https://cnoe.localtest.me:8443/gitea
- **Grafana**: https://cnoe.localtest.me:8443/grafana
