# Fix Hadoop Single Live Datanode Issue

## Problem
HDFS cluster shows only 1 live datanode instead of multiple worker nodes.

## Symptoms
- `hdfs dfsadmin -report` shows "Live datanodes (1)"
- Only localhost/127.0.0.1 appears as datanode
- Worker nodes (hadoop-worker1) not connecting

## Fix Steps

### 1. Check SSH Connectivity
```bash
# Test SSH to worker nodes
ssh hadoop-worker1 "hostname"
```

### 2. Verify Worker Node Services
```bash
# On each worker node (hadoop-worker1, etc.)
ssh hadoop-worker1
sudo systemctl status hadoop-hdfs-datanode
sudo systemctl start hadoop-hdfs-datanode
```

### 3. Check Firewall Settings
```bash
# On master and all workers
sudo ufw status
sudo ufw allow 9866  # Datanode port
sudo ufw allow 9864  # Datanode HTTP port
sudo ufw allow 9000  # Namenode port
```

### 4. Verify Network Configuration
```bash
# Check /etc/hosts on all nodes
cat /etc/hosts
# Ensure proper hostname resolution
```

### 5. Restart HDFS Services
```bash
# Stop all services
stop-dfs.sh

# Start all services
start-dfs.sh

# Check status
hdfs dfsadmin -report
```

### 6. Monitor Logs
```bash
# Check datanode logs on workers
tail -f /usr/local/hadoop/logs/hadoop-*-datanode-*.log

# Check namenode logs on master
tail -f /usr/local/hadoop/logs/hadoop-*-namenode-*.log
```

## Expected Result
After fixes, `hdfs dfsadmin -report` should show multiple live datanodes corresponding to your worker nodes.