# Apache Hadoop Single-Node Installation Guide

This guide provides step-by-step instructions for installing and configuring Apache Hadoop (version 3.4.1) on a single Linux server in pseudo-distributed mode.

## Overview

Apache Hadoop is an open-source framework designed for distributed storage and processing of large data sets. This installation guide covers a single-node setup suitable for development, testing, and learning purposes.

## Prerequisites

- **Operating System**: Ubuntu 20.04/22.04 or Debian 10/11
- **Java**: OpenJDK 11 or newer
- **RAM**: Minimum 4GB (8GB recommended)
- **Disk Space**: Minimum 10GB free space
- **User**: Non-root user with sudo privileges

## Installation Steps

### 1. System Setup

Install Java Development Kit:

```bash
sudo apt update
sudo apt install -y openjdk-11-jdk
```

Verify Java installation:

```bash
java -version
javac -version
```

### 2. Environment Variables

Set essential Hadoop environment variables:

```bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/
export HADOOP_HOME=/usr/local/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
```

Persist these variables in `.bashrc`:

```bash
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/' >> ~/.bashrc
echo 'export HADOOP_HOME=/usr/local/hadoop' >> ~/.bashrc
echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin' >> ~/.bashrc
source ~/.bashrc
```

### 3. Download and Install Hadoop

```bash
# Download Hadoop 3.4.1
wget https://downloads.apache.org/hadoop/common/hadoop-3.4.1/hadoop-3.4.1.tar.gz

# Extract to /usr/local
sudo tar -xzf hadoop-3.4.1.tar.gz -C /usr/local/
sudo mv /usr/local/hadoop-3.4.1 /usr/local/hadoop

# Set ownership
sudo chown -R $USER:$USER /usr/local/hadoop
```

### 4. Configure Hadoop

#### 4.1 core-site.xml

Create `/usr/local/hadoop/etc/hadoop/core-site.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
        <description>The default file system URI</description>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/usr/local/hadoop/tmp</value>
        <description>A base for other temporary directories</description>
    </property>
</configuration>
```

#### 4.2 hdfs-site.xml

Create `/usr/local/hadoop/etc/hadoop/hdfs-site.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
        <description>Default block replication</description>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:///usr/local/hadoop/hdfs/namenode</value>
        <description>Directory on local filesystem for NameNode data</description>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///usr/local/hadoop/hdfs/datanode</value>
        <description>Directory on local filesystem for DataNode data</description>
    </property>
</configuration>
```

#### 4.3 mapred-site.xml

Copy template and configure:

```bash
cp /usr/local/hadoop/etc/hadoop/mapred-site.xml.template /usr/local/hadoop/etc/hadoop/mapred-site.xml
```

Edit `/usr/local/hadoop/etc/hadoop/mapred-site.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
        <description>The runtime framework for executing MapReduce jobs</description>
    </property>
</configuration>
```

#### 4.4 yarn-site.xml

Create `/usr/local/hadoop/etc/hadoop/yarn-site.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
        <description>Shuffle service for NodeManager</description>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>localhost</value>
        <description>ResourceManager hostname</description>
    </property>
</configuration>
```

### 5. HDFS Setup

Create necessary directories:

```bash
mkdir -p /usr/local/hadoop/tmp
mkdir -p /usr/local/hadoop/hdfs/namenode
mkdir -p /usr/local/hadoop/hdfs/datanode
```

Format the NameNode:

```bash
hdfs namenode -format
```

### 6. Start Hadoop Services

```bash
# Start HDFS
start-dfs.sh

# Start YARN
start-yarn.sh
```

### 7. Verify Installation

Check running processes:

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
```

Check HDFS status:

```bash
hdfs dfsadmin -report
```

Verify Hadoop version:

```bash
hadoop version
```

### 8. Test with MapReduce Example

Create test input:

```bash
# Create HDFS directories
hdfs dfs -mkdir -p /user/$USER/input

# Create test file
echo "Hello World Hadoop MapReduce Example" > test.txt
echo "This is a test file for WordCount" >> test.txt
echo "Hadoop makes big data processing easy" >> test.txt

# Copy to HDFS
hdfs dfs -put test.txt /user/$USER/input/
```

Run WordCount example:

```bash
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.4.1.jar wordcount /user/$USER/input /user/$USER/output
```

View results:

```bash
hdfs dfs -cat /user/$USER/output/part-r-00000
```

Expected output:
```
Example	1
Hadoop	2
Hello	1
MapReduce	1
World	1
big	1
data	1
easy	1
for	1
is	1
makes	1
processing	1
test	1
this	1
WordCount	1
file	1
```

## Service Management

### Start Services
```bash
start-dfs.sh    # Start HDFS services
start-yarn.sh   # Start YARN services
```

### Stop Services
```bash
stop-yarn.sh    # Stop YARN services
stop-dfs.sh     # Stop HDFS services
```

### Restart Services
```bash
stop-yarn.sh && stop-dfs.sh
start-dfs.sh && start-yarn.sh
```

## Web Interfaces

Hadoop provides web-based monitoring interfaces:

- **NameNode**: http://localhost:9870/
- **ResourceManager**: http://localhost:8088/
- **NodeManager**: http://localhost:8042/
- **HDFS Datanodes**: http://localhost:9864/

## Troubleshooting

### Common Issues and Solutions

#### 1. NameNode Format Errors

If you encounter NameNode format errors:

```bash
# Stop all services
stop-dfs.sh
stop-yarn.sh

# Delete HDFS data directories
rm -rf /usr/local/hadoop/hdfs/namenode/*
rm -rf /usr/local/hadoop/hdfs/datanode/*

# Reformat NameNode
hdfs namenode -format

# Restart services
start-dfs.sh
```

#### 2. Java Path Issues

If JAVA_HOME is not set correctly:

```bash
# Find correct Java path
readlink -f /usr/bin/java | sed "s:bin/java::"

# Set JAVA_HOME temporarily
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/

# Update .bashrc if needed
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/' >> ~/.bashrc
```

#### 3. Permission Errors

If you encounter permission-related errors:

```bash
# Fix ownership of Hadoop directory
sudo chown -R $USER:$USER /usr/local/hadoop
```

#### 4. Port Conflicts

If ports are already in use:

```bash
# Check port usage
netstat -tulpn | grep :9000
netstat -tulpn | grep :9870

# Kill conflicting processes
sudo kill -9 <PID>
```

#### 5. Service Startup Failures

Check Hadoop logs for detailed error information:

```bash
# HDFS logs
tail -f /usr/local/hadoop/logs/hadoop-*-namenode-*.log
tail -f /usr/local/hadoop/logs/hadoop-*-datanode-*.log

# YARN logs
tail -f /usr/local/hadoop/logs/yarn-*-resourcemanager-*.log
tail -f /usr/local/hadoop/logs/yarn-*-nodemanager-*.log
```

### Health Checks

Run these commands to verify system health:

```bash
# Check HDFS health
hdfs dfsadmin -report
hdfs fsck / -files -blocks -locations

# Check YARN health
yarn node -list
yarn application -list

# Check all processes
jps -v
```

## Common Hadoop Commands (User Quick Reference)

### HDFS File System Commands

```bash
# List directory contents
hdfs dfs -ls /user/$USER

# Create directory
hdfs dfs -mkdir /user/$USER/test

# Copy file to HDFS
hdfs dfs -put localfile.txt /user/$USER/

# Copy file from HDFS
hdfs dfs -get /user/$USER/hdfsfile.txt localcopy.txt

# View file contents
hdfs dfs -cat /user/$USER/hdfsfile.txt

# Remove file/directory
hdfs dfs -rm /user/$USER/hdfsfile.txt
hdfs dfs -rm -r /user/$USER/testdir

# Check disk usage
hdfs dfs -du -h /user/$USER

# Check HDFS status
hdfs dfsadmin -report
```

### YARN Commands

```bash
# List running applications
yarn application -list

# List cluster nodes
yarn node -list

# Kill application
yarn application -kill <application_id>

# Check queue status
yarn queue -status default
```

### MapReduce Commands

```bash
# Run built-in examples
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar <example> <input> <output>

# Common examples:
# WordCount
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar wordcount input output

# Pi estimation
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 10 1000
```

### System Commands

```bash
# Check Hadoop version
hadoop version

# Check running Java processes
jps

# View Hadoop configuration
hadoop classpath

# Check environment variables
echo $JAVA_HOME
echo $HADOOP_HOME
```

## References

- [Apache Hadoop Official Documentation](https://hadoop.apache.org/docs/current/)
- [Hadoop 3.4.1 Release Notes](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/releaseNotes.html)
- [Hadoop Configuration Parameters](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/core-default.xml)
- [HDFS Commands Guide](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html)
- [YARN Commands Guide](https://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/YARNCommands.html)

## License

This guide is provided under the Apache License 2.0. Apache Hadoop is licensed under the Apache License 2.0.