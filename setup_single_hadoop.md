# Apache Hadoop 3.3.6 Single-Node Installation Guide

This guide provides step-by-step instructions for installing and configuring Apache Hadoop 3.3.6 in single-node (pseudo-distributed) mode on Ubuntu 24.04 LTS.

## Overview

This installation sets up Hadoop in pseudo-distributed mode where all Hadoop daemons run on a single machine. This configuration is ideal for development, testing, and learning purposes.

## Prerequisites

- Ubuntu 22.04 LTS or 24.04 LTS
- At least 4GB RAM (8GB recommended)
- 20GB of available disk space
- Root or sudo access
- Internet connection for downloading packages

## System Setup

### 1. Verify Operating System

```bash
lsb_release -a
```

### 2. Install Java Development Kit (JDK)

Hadoop requires Java 11 or newer. We'll install OpenJDK 11:

```bash
sudo apt update
sudo apt install -y openjdk-11-jdk
```

### 3. Verify Java Installation

```bash
java -version
javac -version
```

Expected output:
```
openjdk version "11.0.28" 2025-07-15
OpenJDK Runtime Environment (build 11.0.28+6-post-Ubuntu-1ubuntu124.04.1)
OpenJDK 64-Bit Server VM (build 11.0.28+6-post-Ubuntu-1ubuntu124.04.1, mixed mode, sharing)
```

### 4. Find Java Installation Path

```bash
readlink -f $(which java)
```

Expected output:
```
/usr/lib/jvm/java-11-openjdk-amd64/bin/java
```

## Hadoop Installation

### 1. Download Hadoop

Hadoop 3.3.6 is used in this guide. Download from Apache archive:

```bash
wget https://downloads.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
```

### 2. Extract Hadoop

```bash
sudo tar -xzf hadoop-3.3.6.tar.gz -C /usr/local/
sudo mv /usr/local/hadoop-3.3.6 /usr/local/hadoop
sudo chown -R $USER:$USER /usr/local/hadoop
```

### 3. Set Environment Variables

Add the following to your `~/.bashrc` file:

```bash
# Hadoop Environment Variables
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=/usr/local/hadoop
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
```

Apply the environment variables:

```bash
source ~/.bashrc
```

### 4. Update Hadoop Environment Configuration

Edit `/usr/local/hadoop/etc/hadoop/hadoop-env.sh` and set:

```bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```

## Hadoop Configuration

### 1. Core Configuration (core-site.xml)

Edit `/usr/local/hadoop/etc/hadoop/core-site.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <!-- NameNode URI for HDFS -->
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
        <description>The default file system URI for HDFS</description>
    </property>

    <!-- Directory for Hadoop temporary files -->
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/usr/local/hadoop/tmp</value>
        <description>Base directory for other temporary directories</description>
    </property>

    <!-- Buffer size for reading files -->
    <property>
        <name>io.file.buffer.size</name>
        <value>4096</value>
        <description>Buffer size for reading files</description>
    </property>
</configuration>
```

### 2. HDFS Configuration (hdfs-site.xml)

Edit `/usr/local/hadoop/etc/hadoop/hdfs-site.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <!-- Replication factor for single node setup -->
    <property>
        <name>dfs.replication</name>
        <value>1</value>
        <description>Default block replication for HDFS blocks</description>
    </property>

    <!-- NameNode data directory -->
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:/usr/local/hadoop/data/namenode</value>
        <description>Directory for NameNode data storage</description>
    </property>

    <!-- DataNode data directory -->
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:/usr/local/hadoop/data/datanode</value>
        <description>Directory for DataNode data storage</description>
    </property>

    <!-- Block size configuration -->
    <property>
        <name>dfs.blocksize</name>
        <value>128m</value>
        <description>Default block size for HDFS files</description>
    </property>

    <!-- Web UI for NameNode -->
    <property>
        <name>dfs.http.address</name>
        <value>localhost:9870</value>
        <description>NameNode HTTP web UI address</description>
    </property>

    <!-- Enable permission checking -->
    <property>
        <name>dfs.permissions</name>
        <value>false</value>
        <description>Disable permission checking for single node setup</description>
    </property>
</configuration>
```

### 3. MapReduce Configuration (mapred-site.xml)

Edit `/usr/local/hadoop/etc/hadoop/mapred-site.xml`:

```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <!-- MapReduce framework name -->
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
        <description>Execution framework for MapReduce jobs</description>
    </property>

    <!-- MapReduce job history server address -->
    <property>
        <name>mapreduce.jobhistory.address</name>
        <value>localhost:10020</value>
        <description>Address for MapReduce job history server</description>
    </property>

    <!-- MapReduce job history web UI address -->
    <property>
        <name>mapreduce.jobhistory.webapp.address</name>
        <value>localhost:19888</value>
        <description>Web UI address for MapReduce job history server</description>
    </property>

    <!-- Directory for MapReduce application logs -->
    <property>
        <name>mapreduce.jobtracker.system.dir</name>
        <value>file:/usr/local/hadoop/data/mapred/system</value>
        <description>Directory for MapReduce system files</description>
    </property>

    <!-- Directory for MapReduce staging -->
    <property>
        <name>mapreduce.cluster.local.dir</name>
        <value>file:/usr/local/hadoop/data/mapred/local</value>
        <description>Local directory for MapReduce tasks</description>
    </property>

    <!-- Environment variables for MapReduce -->
    <property>
        <name>yarn.app.mapreduce.am.env</name>
        <value>HADOOP_MAPRED_HOME=/usr/local/hadoop</value>
        <description>Environment variables for MapReduce Application Master</description>
    </property>

    <property>
        <name>mapreduce.map.env</name>
        <value>HADOOP_MAPRED_HOME=/usr/local/hadoop</value>
        <description>Environment variables for Map tasks</description>
    </property>

    <property>
        <name>mapreduce.reduce.env</name>
        <value>HADOOP_MAPRED_HOME=/usr/local/hadoop</value>
        <description>Environment variables for Reduce tasks</description>
    </property>
</configuration>
```

### 4. YARN Configuration (yarn-site.xml)

Edit `/usr/local/hadoop/etc/hadoop/yarn-site.xml`:

```xml
<?xml version="1.0"?>
<configuration>
    <!-- NodeManager settings -->
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
        <description>Shuffle service for MapReduce</description>
    </property>

    <property>
        <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
        <value>org.apache.hadoop.mapred.ShuffleHandler</value>
        <description>Shuffle handler class</description>
    </property>

    <!-- ResourceManager settings -->
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>localhost</value>
        <description>ResourceManager hostname</description>
    </property>

    <property>
        <name>yarn.resourcemanager.scheduler.address</name>
        <value>localhost:8030</value>
        <description>Scheduler address for ResourceManager</description>
    </property>

    <property>
        <name>yarn.resourcemanager.resource-tracker.address</name>
        <value>localhost:8031</value>
        <description>Resource tracker address for ResourceManager</description>
    </property>

    <property>
        <name>yarn.resourcemanager.address</name>
        <value>localhost:8032</value>
        <description>ResourceManager address for applications</description>
    </property>

    <property>
        <name>yarn.resourcemanager.admin.address</name>
        <value>localhost:8033</value>
        <description>ResourceManager admin address</description>
    </property>

    <property>
        <name>yarn.resourcemanager.webapp.address</name>
        <value>localhost:8088</value>
        <description>ResourceManager web UI address</description>
    </property>

    <!-- Memory and CPU allocation -->
    <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>4096</value>
        <description>Memory available for NodeManager in MB</description>
    </property>

    <property>
        <name>yarn.nodemanager.resource.cpu-vcores</name>
        <value>2</value>
        <description>Number of virtual cores available for NodeManager</description>
    </property>

    <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>512</value>
        <description>Minimum memory allocation for containers</description>
    </property>

    <property>
        <name>yarn.scheduler.maximum-allocation-mb</name>
        <value>4096</value>
        <description>Maximum memory allocation for containers</description>
    </property>

    <!-- Application log aggregation -->
    <property>
        <name>yarn.log-aggregation-enable</name>
        <value>true</value>
        <description>Enable log aggregation for applications</description>
    </property>

    <property>
        <name>yarn.nodemanager.vmem-pmem-ratio</name>
        <value>4</value>
        <description>Virtual memory to physical memory ratio</description>
    </property>
</configuration>
```

### 5. Workers Configuration

Edit `/usr/local/hadoop/etc/hadoop/workers` and ensure it contains:

```
localhost
```

## HDFS Setup

### 1. Create Required Directories

```bash
mkdir -p /usr/local/hadoop/tmp
mkdir -p /usr/local/hadoop/data/namenode
mkdir -p /usr/local/hadoop/data/datanode
mkdir -p /usr/local/hadoop/data/mapred/system
mkdir -p /usr/local/hadoop/data/mapred/local
```

### 2. Format NameNode

```bash
hdfs namenode -format
```

### 3. Set Up Passwordless SSH (for localhost)

```bash
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
ssh localhost 'echo SSH works'
```

## Starting Hadoop Services

### 1. Start HDFS

```bash
start-dfs.sh
```

### 2. Start YARN

```bash
start-yarn.sh
```

### 3. Verify Services

```bash
jps
```

Expected output:
```
NameNode
DataNode
SecondaryNameNode
ResourceManager
NodeManager
Jps
```

## Verification

### 1. Check HDFS Status

```bash
hdfs dfsadmin -report
```

### 2. Test HDFS Operations

```bash
# Create directories
hdfs dfs -mkdir -p /user/ubuntu/input

# Create test file
echo "Hello Hadoop World
This is a test file for WordCount example
Hadoop makes big data processing easy
MapReduce is the programming model
WordCount counts words in text files" > test.txt

# Upload to HDFS
hdfs dfs -put test.txt /user/ubuntu/input/

# List files
hdfs dfs -ls /user/ubuntu/input
```

### 3. Run MapReduce WordCount Example

```bash
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar wordcount /user/ubuntu/input/test.txt /user/ubuntu/output
```

### 4. View Results

```bash
hdfs dfs -cat /user/ubuntu/output/part-r-00000
```

Expected output should show word counts like:
```
Hadoop	2
Hello	1
World	1
MapReduce	1
...
```

## Service Management

### Starting Services

```bash
# Start HDFS only
start-dfs.sh

# Start YARN only
start-yarn.sh

# Start all services
start-dfs.sh && start-yarn.sh
```

### Stopping Services

```bash
# Stop YARN only
stop-yarn.sh

# Stop HDFS only
stop-dfs.sh

# Stop all services
stop-yarn.sh && stop-dfs.sh
```

### Checking Service Status

```bash
# Check running Java processes
jps

# Check HDFS status
hdfs dfsadmin -report

# Check YARN applications
yarn application -list
```

## Web Interfaces

After starting services, you can access the following web interfaces:

- **NameNode Web UI**: http://localhost:9870
- **ResourceManager Web UI**: http://localhost:8088
- **NodeManager Web UI**: http://localhost:8042
- **MapReduce Job History**: http://localhost:19888

## Troubleshooting

### Common Issues and Solutions

#### 1. JAVA_HOME Not Found
**Error**: `ERROR: JAVA_HOME is not set and could not be found`

**Solution**:
```bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/.bashrc
```

#### 2. NameNode Format Issues
**Error**: NameNode fails to start or shows formatting errors

**Solution**:
```bash
# Stop all services
stop-dfs.sh && stop-yarn.sh

# Remove existing NameNode data
rm -rf /usr/local/hadoop/data/namenode/*

# Format again
hdfs namenode -format
```

#### 3. Memory Issues
**Error**: Container exits with memory errors

**Solution**: Reduce memory allocation in `yarn-site.xml`:
```xml
<property>
    <name>yarn.nodemanager.resource.memory-mb</name>
    <value>2048</value>
</property>
```

#### 4. Port Conflicts
**Error**: Services fail to start due to port conflicts

**Solution**: Check and kill processes using conflicting ports:
```bash
# Check ports
netstat -tulpn | grep :8088
netstat -tulpn | grep :9870

# Kill conflicting processes
sudo kill -9 <PID>
```

#### 5. DataNode Connection Issues
**Error**: DataNode fails to connect to NameNode

**Solution**:
```bash
# Stop all services
stop-dfs.sh && stop-yarn.sh

# Remove DataNode data
rm -rf /usr/local/hadoop/data/datanode/*

# Restart services
start-dfs.sh
```

### Log Locations

- **NameNode logs**: `/usr/local/hadoop/logs/hadoop-ubuntu-namenode-*.log`
- **DataNode logs**: `/usr/local/hadoop/logs/hadoop-ubuntu-datanode-*.log`
- **ResourceManager logs**: `/usr/local/hadoop/logs/yarn-ubuntu-resourcemanager-*.log`
- **NodeManager logs**: `/usr/local/hadoop/logs/yarn-ubuntu-nodemanager-*.log`

## Common Hadoop Commands

### HDFS Commands

```bash
# List files
hdfs dfs -ls /path

# Create directory
hdfs dfs -mkdir /path/directory

# Copy from local to HDFS
hdfs dfs -put localfile /hdfs/path

# Copy from HDFS to local
hdfs dfs -get /hdfs/file localfile

# View file contents
hdfs dfs -cat /hdfs/file

# Remove file/directory
hdfs dfs -rm /hdfs/file
hdfs dfs -rm -r /hdfs/directory

# Check disk usage
hdfs dfs -du -h /path

# Check HDFS health
hdfs dfsadmin -report
hdfs fsck / -files -blocks -locations
```

### YARN Commands

```bash
# List running applications
yarn application -list

# Kill application
yarn application -kill <application_id>

# List running containers
yarn container -list

# Check node status
yarn node -list

# Queue information
yarn queue -status
```

### MapReduce Commands

```bash
# List running jobs
mapred job -list

# Kill job
mapred job -kill <job_id>

# Job history server
mr-jobhistory-daemon.sh start
mr-jobhistory-daemon.sh stop
```

### Environment Variables Check

```bash
# Check Hadoop version
hadoop version

# Check Hadoop configuration
hadoop classpath

# Check native libraries
hadoop checknative -a
```

## Maintenance

### Cleaning Up HDFS

```bash
# Clean up old checkpoints
hdfs dfsadmin -saveNamespace

# Clean up trash
hdfs dfs -expunge
```

### Backup Configuration

```bash
# Backup configuration files
cp -r /usr/local/hadoop/etc/hadoop ~/hadoop-config-backup/

# Backup important data
hdfs dfs -copyToLocal /user /home/ubuntu/hdfs-backup
```

## Security Considerations

1. **Firewall**: Configure firewall to allow Hadoop ports (8020-8040, 9000, 9870, 8088, 19888)
2. **Authentication**: In production, enable Kerberos authentication
3. **Permissions**: Enable file permissions by setting `dfs.permissions` to `true`
4. **Encryption**: Enable HDFS encryption for sensitive data

## Performance Tuning

### Memory Optimization

```xml
<!-- In yarn-site.xml -->
<property>
    <name>yarn.scheduler.maximum-allocation-mb</name>
    <value>8192</value>
</property>
```

### HDFS Optimization

```xml
<!-- In hdfs-site.xml -->
<property>
    <name>dfs.namenode.handler.count</name>
    <value>10</value>
</property>

<property>
    <name>dfs.datanode.handler.count</name>
    <value>10</value>
</property>
```

## Uninstallation

If you need to uninstall Hadoop:

```bash
# Stop all services
stop-dfs.sh && stop-yarn.sh

# Remove Hadoop installation
sudo rm -rf /usr/local/hadoop

# Remove environment variables from ~/.bashrc
# Edit ~/.bashrc and remove Hadoop-related lines

# Remove SSH keys (optional)
rm -rf ~/.ssh/id_rsa*
```

## References

- [Apache Hadoop Official Documentation](https://hadoop.apache.org/docs/stable/)
- [Hadoop 3.3.6 Release Notes](https://hadoop.apache.org/docs/r3.3.6/)
- [Hadoop Configuration Guide](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/CoreConfigurations.html)

## License

This guide is provided as-is under the Apache License 2.0. The Apache Hadoop project is also licensed under the Apache License 2.0.