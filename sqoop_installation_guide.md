# Sqoop Installation Guide for Hadoop 3.3.6 Cluster

This document provides step-by-step instructions for installing Apache Sqoop 1.4.7 on a Hadoop 3.3.6 cluster.

## Prerequisites

Before installing Sqoop, ensure you have:
- Hadoop 3.3.6 installed and configured
- Java 11 installed
- User with sudo privileges
- Internet connection for downloading dependencies

## Environment Details

This installation was performed on:
- **Hadoop Version**: 3.3.6
- **Java Version**: OpenJDK 11
- **Sqoop Version**: 1.4.7
- **Hadoop Installation Path**: `/usr/local/hadoop`
- **Sqoop Installation Path**: `/usr/local/sqoop`

## Installation Steps

### Step 1: Verify Hadoop Installation

First, verify that your Hadoop cluster is running correctly:

```bash
# Check Hadoop version
hadoop version

# Check Hadoop processes
jps

# Verify HDFS status
hdfs dfsadmin -report
```

Expected output should show:
- Hadoop 3.3.6 version
- Running Hadoop daemons (NameNode, DataNode, ResourceManager, etc.)
- Active DataNodes in the cluster

### Step 2: Download Sqoop

Download Apache Sqoop 1.4.7 binary distribution:

```bash
# Navigate to home directory
cd ~

# Download Sqoop 1.4.7 binary distribution
wget https://archive.apache.org/dist/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
```

### Step 3: Extract and Install Sqoop

Extract the downloaded archive and install Sqoop:

```bash
# Extract Sqoop to /usr/local directory
sudo tar -xzf sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz -C /usr/local

# Rename the extracted directory for easier access
sudo mv /usr/local/sqoop-1.4.7.bin__hadoop-2.6.0 /usr/local/sqoop

# Change ownership to your user
sudo chown -R ubuntu:ubuntu /usr/local/sqoop
```

### Step 4: Configure Environment Variables

Add Sqoop environment variables to your `.bashrc` file:

```bash
# Edit bashrc file
nano ~/.bashrc
```

Add the following lines at the end of the file:

```bash
# Sqoop Environment Variables
export SQOOP_HOME=/usr/local/sqoop
export PATH=$PATH:$SQOOP_HOME/bin
export HADOOP_CLASSPATH=$(hadoop classpath)
```

Reload the environment variables:

```bash
# Apply changes to current session
source ~/.bashrc

# Or manually set for current session
export SQOOP_HOME=/usr/local/sqoop
export PATH=$PATH:$SQOOP_HOME/bin
export HADOOP_CLASSPATH=$(hadoop classpath)
```

### Step 5: Configure Sqoop Environment

Configure Sqoop to work with your Hadoop installation:

```bash
# Copy the environment template
cp $SQOOP_HOME/conf/sqoop-env-template.sh $SQOOP_HOME/conf/sqoop-env.sh

# Edit the configuration file
nano $SQOOP_HOME/conf/sqoop-env.sh
```

Uncomment and update the following lines in the file:

```bash
#Set path to where bin/hadoop is available
export HADOOP_COMMON_HOME=/usr/local/hadoop

#Set path to where hadoop-*-core.jar is available
export HADOOP_MAPRED_HOME=/usr/local/hadoop
```

### Step 6: Install Database JDBC Drivers

Download and install JDBC drivers for the databases you want to connect to. Here's an example for MySQL:

```bash
# Download MySQL JDBC driver
wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.28/mysql-connector-java-8.0.28.jar

# Move the driver to Sqoop lib directory
mv mysql-connector-java-8.0.28.jar $SQOOP_HOME/lib/
```

For other databases, download their respective JDBC drivers and place them in `$SQOOP_HOME/lib/`:

- **PostgreSQL**: `postgresql-xx.x.x.jar`
- **Oracle**: `ojdbcx.jar`
- **SQL Server**: `mssql-jdbc-x.x.x.jrex.jar`
- **MySQL**: `mysql-connector-java-x.x.x.jar`

### Step 7: Verify Installation

Test the Sqoop installation:

```bash
# Check Sqoop version
sqoop version

# List available commands
sqoop help
```

Expected output should show:
- Sqoop version 1.4.7
- List of available commands (codegen, import, export, etc.)

You may see some warnings about HBase, HCatalog, Accumulo, and Zookeeper not being installed. These are optional components and can be ignored for basic Sqoop functionality.

## Post-Installation Configuration

### Testing Sqoop with a Sample Database Connection

To test Sqoop with a database, you can use the following command structure:

```bash
# List databases on a MySQL server
sqoop list-databases \
    --connect jdbc:mysql://hostname:3306/ \
    --username username \
    --password password

# List tables in a specific database
sqoop list-tables \
    --connect jdbc:mysql://hostname:3306/database_name \
    --username username \
    --password password
```

### Common Sqoop Commands

Here are some common Sqoop operations:

```bash
# Import a table from MySQL to HDFS
sqoop import \
    --connect jdbc:mysql://hostname:3306/database_name \
    --username username \
    --password password \
    --table table_name \
    --target-dir /user/hadoop/table_name \
    --m 1

# Export data from HDFS to MySQL
sqoop export \
    --connect jdbc:mysql://hostname:3306/database_name \
    --username username \
    --password password \
    --table table_name \
    --export-dir /user/hadoop/table_name \
    --m 1
```

## Troubleshooting

### Common Issues and Solutions

1. **Command not found error**
   ```bash
   # Ensure environment variables are set
   echo $SQOOP_HOME
   echo $PATH

   # Set manually if needed
   export SQOOP_HOME=/usr/local/sqoop
   export PATH=$PATH:$SQOOP_HOME/bin
   ```

2. **Hadoop classpath issues**
   ```bash
   # Set Hadoop classpath
   export HADOOP_CLASSPATH=$(hadoop classpath)
   ```

3. **Database connection errors**
   - Verify JDBC driver is in `$SQOOP_HOME/lib/`
   - Check database connectivity
   - Verify connection string format
   - Ensure database server is accessible from the cluster

4. **Permission issues**
   ```bash
   # Check permissions
   ls -la /usr/local/sqoop/

   # Fix ownership if needed
   sudo chown -R ubuntu:ubuntu /usr/local/sqoop
   ```

### Expected Warnings

The following warnings are normal and can be ignored for basic functionality:

```
Warning: /usr/local/sqoop/../hbase does not exist! HBase imports will fail.
Warning: /usr/local/sqoop/../hcatalog does not exist! HCatalog jobs will fail.
Warning: /usr/local/sqoop/../accumulo does not exist! Accumulo imports will fail.
Warning: /usr/local/sqoop/../zookeeper does not exist! Accumulo imports will fail.
```

## Integration with Hadoop Cluster

Sqoop is now configured to work with your existing Hadoop 3.3.6 cluster. The installation:

1. ✅ Uses the existing Hadoop configuration
2. ✅ Integrates with HDFS for data storage
3. ✅ Works with YARN for resource management
4. ✅ Supports MapReduce jobs for data transfer

## Next Steps

1. **Configure Database Connections**: Set up connections to your source databases
2. **Test Data Transfers**: Perform sample import/export operations
3. **Schedule Jobs**: Set up automated data transfer workflows
4. **Monitor Performance**: Optimize parallel operations and resource usage

## Files Modified/Created

- `/usr/local/sqoop/` - Sqoop installation directory
- `/usr/local/sqoop/conf/sqoop-env.sh` - Sqoop environment configuration
- `~/.bashrc` - Updated with Sqoop environment variables
- `/usr/local/sqoop/lib/mysql-connector-java-8.0.28.jar` - MySQL JDBC driver

## Verification Commands

```bash
# Verify Sqoop installation
sqoop version

# Check environment variables
echo $SQOOP_HOME
echo $HADOOP_CLASSPATH

# Verify Hadoop integration
hadoop classpath

# Test Sqoop help
sqoop help
```

Sqoop is now successfully installed and configured to work with your Hadoop 3.3.6 cluster!