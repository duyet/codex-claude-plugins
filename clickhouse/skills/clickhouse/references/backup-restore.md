# ClickHouse Backup & Restore

Backup strategies, disaster recovery, and data protection.

## Backup Strategies Comparison

| Strategy | Pros | Cons | Use Case |
|----------|------|------|----------|
| **clickhouse-backup** | Full-featured, S3 support, incremental | External tool | Production (recommended) |
| **BACKUP statement** | Native, SQL-based, async | Newer feature (v23.6+) | Simple setups |
| **Snapshot** | Instant, consistent | Cloud-only, requires coordination | Cloud deployments |
| **rsync** | Simple, no dependencies | Downtime required | Small setups, emergencies |

## clickhouse-backup (Recommended)

### Installation

See the [official clickhouse-backup documentation](https://github.com/AlexAkulov/clickhouse-backup#installation) for installation instructions using:
- Docker images
- DEB/RPM packages
- Helm charts (for Kubernetes)
- Building from source

### Configuration

```yaml
# /etc/clickhouse-backup/config.yml
general:
  remote_storage: s3
  max_file_size: 1073741824
  disable_progress_bar: false
  backups_to_keep_local: 5
  backups_to_keep_remote: 10

clickhouse:
  username: default
  password: ""  # ⚠️ Use proper secret management in production
  host: localhost
  port: 9000
  debug: false
  sync_replicated_tables: true
  skip_table_engines: [Dictionary, View, Set, Join]
  skip_tables: [system.*, temporary_*.*, information_schema*]

s3:
  access_key: AKIAIOSFODNN7EXAMPLE  # ⚠️ Placeholder - use AWS IAM roles or proper secrets
  secret_key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY  # ⚠️ Placeholder
  bucket: clickhouse-backups
  endpoint: https://s3.amazonaws.com
  region: us-west-2
  acl: private
  force_path_style: false
  path: /backups/

# GCS configuration
gcs:
  credentials_file: /path/to/service-account.json
  bucket: clickhouse-backups
  path: /backups/

# Azure configuration
azblob:
  account_name: myaccount
  account_key: mykey
  container: clickhouse-backups
  path: /backups/
```

### Commands

```bash
# Create local backup
clickhouse-backup create my_backup

# Upload to remote storage
clickhouse-backup upload my_backup

# List backups
clickhouse-backup list

# Download from remote
clickhouse-backup download my_backup

# Restore from backup
clickhouse-backup restore my_backup

# Restore specific tables
clickhouse-backup restore my_backup -t my_db.my_table

# Create and upload in one command
clickhouse-backup create my_backup --upload

# Delete backup
clickhouse-backup delete local my_backup
clickhouse-backup delete remote my_backup
```

### Incremental Backups

```bash
# Differential backup (only changes since last)
clickhouse-backup create --diff-from=previous_backup my_backup

# Upload
clickhouse-backup upload my_backup
```

### Backup Automation

```bash
# Cron job for daily backups
0 2 * * * clickhouse-backup create "daily-$(date +\%Y\%m\%d)" --upload >/dev/null 2>&1

# Cron job for weekly full backup
0 3 * * 0 clickhouse-backup create "weekly-$(date +\%Y\%m\%d)" --upload >/dev/null 2>&1

# Cron job to clean old backups
0 4 * * * clickhouse-backup delete local --clickhouse-backup /etc/clickhouse-backup/config.yml >/dev/null 2>&1
```

## BACKUP Statement (v23.6+)

### Backup to Disk

```sql
-- Backup entire database
BACKUP DATABASE my_db TO DISK('backups/my_db');

-- Backup specific tables
BACKUP TABLE my_db.table1, my_db.table2 TO DISK('backups/partial');

-- Backup with pattern
BACKUP DATABASE my_db.* TO DISK('backups/my_db');

-- Async backup
BACKUP DATABASE my_db TO DISK('backups/my_db') SETTINGS async=true;
```

### Backup to S3

```sql
-- Backup to S3
BACKUP DATABASE my_db TO S3('https://bucket.s3.amazonaws.com/backups/my_db');

-- With credentials
BACKUP DATABASE my_db TO S3(
    'https://bucket.s3.amazonaws.com/backups/my_db',
    'access_key',
    'secret_key'
);
```

### Restore

```sql
-- Restore database
RESTORE DATABASE my_db FROM DISK('backups/my_db');

-- Restore with new name
RESTORE DATABASE my_db AS my_db_new FROM DISK('backups/my_db');

-- Restore specific tables
RESTORE TABLE my_db.table1 FROM DISK('backups/partial');

-- Async restore
RESTORE DATABASE my_db FROM DISK('backups/my_db') SETTINGS async=true;
```

### Backup Status

```sql
-- Check backup status
SELECT * FROM system.backups;

-- List backups
SELECT name, status, size
FROM system.backups
ORDER BY creation_time DESC;
```

## Snapshot-Based Backup

### EBS Snapshots (AWS)

```bash
# 1. Freeze filesystem
clickhouse-client --query="SYSTEM FREEZE TABLES;"

# 2. Take snapshot
aws ec2 create-snapshot \
  --volume-id vol-xxxxxxxx \
  --description "ClickHouse backup $(date +%Y-%m-%d)"

# 3. Unfreeze
clickhouse-client --query="SYSTEM UNFREEZE TABLES;"

# 4. Cleanup old snapshots (keep last 7 days)
aws ec2 describe-snapshots \
  --filters Name=description,Values="ClickHouse backup*" \
  --query 'Snapshots[?StartTime<`$(date -d '7 days ago' +%Y-%m-%d)`].SnapshotId' \
  --output text | xargs -I {} aws ec2 delete-snapshot --snapshot-id {}
```

### GCE Persistent Disks

```bash
# 1. Freeze tables
clickhouse-client --query="SYSTEM FREEZE TABLES;"

# 2. Create snapshot
gcloud compute disks snapshot clickhouse-disk \
  --snapshot-names clickhouse-snapshot-$(date +%Y%m%d)

# 3. Unfreeze
clickhouse-client --query="SYSTEM UNFREEZE TABLES;"
```

## Filesystem-Based Backup

### Using rsync

```bash
# Stop ClickHouse
systemctl stop clickhouse-server

# Backup data directory
rsync -av --delete /var/lib/clickhouse/ /backup/clickhouse/

# Start ClickHouse
systemctl start clickhouse-server
```

### Using cp

```bash
# Stop ClickHouse
systemctl stop clickhouse-server

# Copy data directory
cp -r /var/lib/clickhouse/ /backup/clickhouse/

# Start ClickHouse
systemctl start clickhouse-server
```

## Disaster Recovery

### Complete Restore Procedure

For disaster recovery procedures, see the [clickhouse-backup documentation](https://github.com/AlexAkulov/clickhouse-backup#restore-commands).

Key considerations:
- Always verify backup integrity before restore
- Test restore procedures in non-production environments
- Use clickhouse-backup's built-in restore commands rather than manual filesystem operations
- Consider restoring to a new database/cluster first to verify data integrity

### Point-in-Time Recovery

```sql
-- 1. Find backup
SELECT * FROM system.backups
WHERE creation_time >= '2024-01-01 00:00:00'
  AND creation_time <= '2024-01-01 12:00:00'
ORDER BY creation_time DESC
LIMIT 1;

-- 2. Restore to new database
RESTORE DATABASE my_db AS my_db_pit
FROM DISK('backups/my_db_20240101');

-- 3. Export needed data
-- 4. Import to production
```

### Data Migration

```bash
# Using clickhouse-backup
clickhouse-backup create migration_backup
clickhouse-backup upload migration_backup

# On new cluster
clickhouse-backup download migration_backup
clickhouse-backup restore migration_backup

# Using clickhouse-copier for large clusters
# Configure and run:
clickhouse-copier --config=config.xml --base-dir=/tmp/
```

## Backup Verification

### Check Backup Integrity

```sql
-- Verify row counts after restore
SELECT
    database,
    table,
    sum(rows) as row_count
FROM system.parts
WHERE active = 1
GROUP BY database, table
ORDER BY database, table;

-- Compare checksums
SELECT
    table,
    sum(bytes_on_disk) as size,
    checksum(*) as checksum
FROM system.parts
WHERE active = 1
GROUP BY table;
```

### Test Restore Procedure

```bash
# 1. Create test database
clickhouse-client --query="CREATE DATABASE test_restore;"

# 2. Restore to test database
clickhouse-backup restore my_backup -d my_db --db-target test_restore

# 3. Verify data
clickhouse-client --query="SELECT count() FROM test_restore.events"

# 4. Drop test database
clickhouse-client --query="DROP DATABASE test_restore;"
```

## Best Practices

1. **Automate backups** - Use cron or Kubernetes cronjobs
2. **Test restores** - Regularly test restore procedure
3. **Offsite storage** - Store backups in S3/GCS/Azure
4. **Retention policy** - Keep 7-30 daily, 4-12 weekly backups
5. **Monitor backups** - Alert on backup failures
6. **Document RTO/RPO** - Define recovery objectives
7. **Encrypt backups** - Use encryption for sensitive data
8. **Version control** - Track backup configuration

## Backup Checklist

- [ ] Automated daily backups configured
- [ ] Backups stored offsite (S3, GCS, Azure)
- [ ] Retention policy defined
- [ ] Test restore procedure documented
- [ ] Backup monitoring configured
- [ ] Disaster recovery plan documented
- [ ] RTO/RPO defined
- [ ] Encryption enabled for sensitive data
- [ ] Backup size monitored and optimized
- [ ] Incremental backups configured

## See Also

- `../SKILL.md` - Main skill entry point
- `debugging.md` - Troubleshooting backup issues
- `cluster-management.md` - Replication for high availability
- `monitoring.md` - Backup monitoring and health checks
