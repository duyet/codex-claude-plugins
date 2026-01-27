# ClickHouse Operator (Kubernetes)

Deployment, configuration, and operations using the Altinity ClickHouse Operator.

## Operator Overview

The Altinity Kubernetes Operator for ClickHouse provides:
- Automated provisioning
- Self-healing
- Scaling (add/remove replicas)
- Backup/restore integration
- Configuration management

## Installation

### Using kubectl

```bash
# Install operator
kubectl apply -f https://docs.altinity.com/clickhouse-operator-install.yaml

# Verify installation
kubectl get pods -n clickhouse-operator
```

### Using Helm

```bash
# Add Helm repo
helm repo add altinity https://docs.altinity.com/charts
helm repo update

# Install operator
helm install clickhouse-operator altinity/clickhouse-operator \
  --namespace clickhouse-operator --create-namespace
```

## ClickHouseInstallation CRD

### Basic Configuration

```yaml
apiVersion: clickhouse.altinity.com/v1
kind: ClickHouseInstallation
metadata:
  name: my-cluster
spec:
  configuration:
    clusters:
      - name: default
        layout:
          shardsCount: 2
          replicasCount: 2
```

### Complete Example

```yaml
apiVersion: clickhouse.altinity.com/v1
kind: ClickHouseInstallation
metadata:
  name: my-cluster
  namespace: clickhouse
spec:
  configuration:
    clusters:
      - name: default
        layout:
          shardsCount: 2
          replicasCount: 2
        templates:
          podTemplate: clickhouse
          volumeClaimTemplate: data-volume
    settings:
      storage_configuration:
        disks:
          - name: default
            path: /var/lib/clickhouse
          - name: s3
            type: s3
            endpoint: "https://s3.amazonaws.com/bucket"
        policies:
          - name: hot_cold_s3
            volumes:
              - volume: default
                max_data_part_size_bytes: 1073741824
              - volume: s3
    users:
      admin/password: password123
      admin/networks:
        - ::/0
      admin/profile: default
      admin/quotas: default
  templates:
    podTemplates:
      - name: clickhouse
        spec:
          containers:
            - name: clickhouse
              image: clickhouse/clickhouse-server:24.3
              resources:
                requests:
                  memory: 4Gi
                  cpu: 2
                limits:
                  memory: 8Gi
                  cpu: 4
              ports:
                - containerPort: 9000
                  name: clickhouse
                - containerPort: 8123
                  name: http
              volumeMounts:
                - name: data-volume
                  mountPath: /var/lib/clickhouse
    volumeClaimTemplates:
      - name: data-volume
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 100Gi
          storageClassName: fast-ssd
```

## Common Operations

### Get Status

```bash
# List installations
kubectl get clickhouseinstallation -n clickhouse

# Describe installation
kubectl describe clickhouseinstallation my-cluster -n clickhouse

# Get pods
kubectl get pods -l clickhouse.altinity.com/chi=my-cluster -n clickhouse
```

### Connect to Pod

```bash
# Get interactive shell
kubectl exec -it my-cluster-default-0-0 -n clickhouse -- bash

# Connect to ClickHouse client
kubectl exec -it my-cluster-default-0-0 -n clickhouse -- clickhouse-client

# Run query
kubectl exec my-cluster-default-0-0 -n clickhouse -- clickhouse-client --query="SELECT 1"
```

### View Logs

```bash
# Pod logs
kubectl logs my-cluster-default-0-0 -n clickhouse -f

# Operator logs
kubectl logs -n clickhouse-operator deployment/clickhouse-operator -f
```

### Scale Replicas

```bash
# Scale to 3 replicas
kubectl patch clickhouseinstallation my-cluster -n clickhouse \
  --type=json -p='[
    {"op": "replace", "path": "/spec/configuration/clusters/0/layout/replicasCount", "value": 3}
  ]'
```

## Configuration Management

### ConfigMap for Settings

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ch-config
  namespace: clickhouse
data:
  users.xml: |
    <clickhouse>
      <users>
        <admin>
          <password>password</password>
          <access_management>1</access_management>
          <networks>
            <ip>::/0</ip>
          </networks>
          <profile>default</profile>
          <quota>default</quota>
        </admin>
      </users>
    </clickhouse>
  config.xml: |
    <clickhouse>
      <logger>
        <level>information</level>
        <console>true</console>
      </logger>
    </clickhouse>
  macros.xml: |
    <clickhouse>
      <macros>
        <shard>01</shard>
        <replica>replica_1</replica>
      </macros>
    </clickhouse>
```

### Apply ConfigMap

```yaml
apiVersion: clickhouse.altinity.com/v1
kind: ClickHouseInstallation
metadata:
  name: my-cluster
spec:
  configuration:
    files:
      users.xml: /etc/clickhouse-server/users.d/users.xml
      config.xml: /etc/clickhouse-server/config.d/config.xml
      macros.xml: /etc/clickhouse-server/config.d/macros.xml
    ...
  templates:
    podTemplates:
      - name: clickhouse
        spec:
          containers:
            - name: clickhouse
              volumeMounts:
                - name: config-volume
                  mountPath: /etc/clickhouse-server/config.d
          volumes:
            - name: config-volume
              configMap:
                name: ch-config
```

## Backup Integration

### ClickHouseBackup

```yaml
apiVersion: clickhouse.altinity.com/v1
kind: ClickHouseBackup
metadata:
  name: backup-daily
  namespace: clickhouse
spec:
  backupSchedule: "0 2 * * *"  # Daily at 2 AM
  remoteStorage:
    type: s3
    endpoint: "https://s3.amazonaws.com"
    bucket: "clickhouse-backups"
    path: "/backups/"
  retention:
    keepLast: 7
  clickhouseInstallation: my-cluster
```

## Service and Ingress

### Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: clickhouse-service
  namespace: clickhouse
spec:
  type: ClusterIP
  ports:
    - port: 9000
      name: clickhouse
    - port: 8123
      name: http
  selector:
    clickhouse.altinity.com/chi: my-cluster
```

### Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: clickhouse-ingress
  namespace: clickhouse
spec:
  rules:
    - host: clickhouse.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: clickhouse-service
                port:
                  number: 8123
```

## Troubleshooting

### Check Operator Status

```bash
# Operator pods
kubectl get pods -n clickhouse-operator

# Operator logs
kubectl logs -n clickhouse-operator deployment/clickhouse-operator

# Describe ClickHouseInstallation
kubectl describe clickhouseinstallation my-cluster -n clickhouse
```

### Pod Issues

```bash
# Pod events
kubectl describe pod my-cluster-default-0-0 -n clickhouse

# Pod logs
kubectl logs my-cluster-default-0-0 -n clickhouse

# Connect to pod for debugging
kubectl exec -it my-cluster-default-0-0 -n clickhouse -- bash
```

### Common Issues

| Issue | Solution |
|-------|----------|
| Pod not starting | Check resources, PVC status, logs |
| Connection refused | Check service, network policies |
| High memory | Increase memory limit |
| ZooKeeper errors | Check ZK configuration |

## Best Practices

1. **Resource limits**: Set appropriate CPU/memory limits
2. **Storage**: Use fast SSD for hot data
3. **Monitoring**: Deploy Prometheus/Grafana
4. **Backups**: Automate with ClickHouseBackup
5. **High availability**: Use 3+ replicas across AZs
6. **Configuration**: Use ConfigMaps for settings
7. **Version**: Pin ClickHouse version in production

## See Also

- `../SKILL.md` - Main skill entry point
- `cluster-management.md` - Cluster configuration and sharding
- `backup-restore.md` - Backup strategies
- `monitoring.md` - Health checks and metrics
