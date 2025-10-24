# Hadoop Cluster Fix Report

## Problem
HDFS cluster was showing only 1 live datanode instead of the expected 2 nodes (master + worker).

## Root Cause Analysis
The issue was a **configuration mismatch** between the master and worker nodes:

### Master Node Configuration
- `core-site.xml` was configured with: `hdfs://localhost:9000`
- This caused the NameNode to bind only to localhost

### Worker Node Configuration
- `core-site.xml` was configured with: `hdfs://hadoop-master:9000`
- The worker was trying to connect to `hadoop-master:9000` but the master was only listening on `localhost:9000`

## Troubleshooting Steps Taken

### 1. Connectivity Verification
- Successfully connected to worker node: `ssh ubuntu@10.149.252.239`
- Confirmed datanode process was running on worker (PID: 208419)
- Verified port 9866 was listening on worker node
- Network connectivity between master and worker was confirmed

### 2. Configuration Analysis
- Compared `/usr/local/hadoop/etc/hadoop/core-site.xml` on both nodes
- Identified the mismatch in `fs.defaultFS` property:
  - Master: `hdfs://localhost:9000`
  - Worker: `hdfs://hadoop-master:9000`

### 3. Fix Implementation
- Updated master node's `core-site.xml` to use consistent hostname:
  ```xml
  <property>
      <name>fs.defaultFS</name>
      <value>hdfs://hadoop-master:9000</value>
  </property>
  ```

### 4. Service Restart
- Stopped HDFS services: `stop-dfs.sh`
- Started HDFS services: `start-dfs.sh`

## Results
After the fix, the HDFS cluster now shows **2 live datanodes**:

```
Live datanodes (2):

Name: 10.149.252.178:9866 (hadoop-master)
Hostname: hadoop-master
Configured Capacity: 19682557952 (18.33 GB)
DFS Remaining: 13778132992 (12.83 GB)

Name: 10.149.252.239:9866 (hadoop-worker1)
Hostname: hadoop-worker1
Configured Capacity: 19682557952 (18.33 GB)
DFS Remaining: 14916149248 (13.89 GB)
```

## Total Cluster Capacity
- **Before Fix**: 18.33 GB (1 node)
- **After Fix**: 36.66 GB (2 nodes)
- **Available Storage**: 26.72 GB

## Key Lessons
1. **Consistent Configuration**: Ensure all Hadoop configuration files are consistent across the cluster
2. **Hostname Resolution**: Use proper hostnames instead of localhost in distributed setups
3. **Verification**: Always verify cluster status after configuration changes

The issue has been completely resolved and the Hadoop cluster is now operating with both nodes properly connected.