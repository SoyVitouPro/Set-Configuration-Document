# Integrating Kerberos with Hadoop Cluster - Step by Step Guide

## Overview
This guide provides comprehensive steps to integrate Kerberos authentication with your Hadoop 3.3.6 cluster (2-node setup: hadoop-master + hadoop-worker1).

## Prerequisites
- Hadoop 3.3.6 installed and configured
- Ubuntu 20.04+ system
- Root or sudo access
- Kerberos KDC already installed (`/usr/sbin/krb5kdc` found)

## Current Hadoop Setup Status
- ✅ Hadoop 3.3.6 installed at `/usr/local/hadoop`
- ✅ 2-node cluster configured (hadoop-master, hadoop-worker1)
- ✅ Configuration files present
- ✅ Kerberos KDC installed
- ❌ Hadoop services not currently running

## Step 1: Configure Kerberos KDC

### 1.1 Install Kerberos Packages (if missing)
```bash
sudo apt update
sudo apt install -y krb5-kdc krb5-admin-server krb5-config
```

### 1.2 Configure Kerberos Realm
Replace your `/etc/krb5.conf` with this complete configuration:

```bash
sudo nano /etc/krb5.conf
```

Remove all existing content and paste this complete configuration:

```ini
[libdefaults]
    default_realm = HADOOP.LOCAL
    dns_lookup_realm = false
    dns_lookup_kdc = true
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true
    proxiable = true
    rdns = false
    udp_preference_limit = 1
    allow_weak_crypto = true
    kdc_timesync = 1
    ccache_type = 4

[realms]
    HADOOP.LOCAL = {
        kdc = hadoop-master
        admin_server = hadoop-master
        default_domain = hadoop.local
    }

[domain_realm]
    .hadoop.local = HADOOP.LOCAL
    hadoop.local = HADOOP.LOCAL
    .hadoop-master = HADOOP.LOCAL
    hadoop-master = HADOOP.LOCAL
    .hadoop-worker1 = HADOOP.LOCAL
    hadoop-worker1 = HADOOP.LOCAL
```

### 1.3 Create Kerberos Database
```bash
# Create the Kerberos database (you'll be prompted for master password)
sudo kdb5_util create -r HADOOP.LOCAL -s
```

**Example output:**
```
Initializing database '/var/lib/krb5kdc/principal' for realm 'HADOOP.LOCAL',
master key name 'K/M@HADOOP.LOCAL'
You will be prompted for the database Master Password.
It is important that you NOT FORGET this password.
Enter KDC database master key: [enter your password]
Re-enter KDC database master key: [confirm your password]
```

**After successful creation:**
```bash
# Set proper permissions (files will exist after database creation)
sudo chmod 600 /var/lib/krb5kdc/principal*
sudo chmod 644 /etc/krb5kdc/kdc.conf
sudo chmod 644 /etc/krb5.conf
```

### 1.4 Create Kerberos Principals
```bash
# Create admin user
sudo kadmin.local -q "addprinc admin/admin"

# Create Hadoop service principals
sudo kadmin.local -q "addprinc -randkey hdfs/hadoop-master@HADOOP.LOCAL"
sudo kadmin.local -q "addprinc -randkey hdfs/hadoop-worker1@HADOOP.LOCAL"
sudo kadmin.local -q "addprinc -randkey HTTP/hadoop-master@HADOOP.LOCAL"
sudo kadmin.local -q "addprinc -randkey HTTP/hadoop-worker1@HADOOP.LOCAL"
sudo kadmin.local -q "addprinc -randkey yarn/hadoop-master@HADOOP.LOCAL"
sudo kadmin.local -q "addprinc -randkey yarn/hadoop-worker1@HADOOP.LOCAL"
sudo kadmin.local -q "addprinc -randkey jhs/hadoop-master@HADOOP.LOCAL"
sudo kadmin.local -q "addprinc -randkey mapred/hadoop-master@HADOOP.LOCAL"

# Create user principals
sudo kadmin.local -q "addprinc ubuntu"
sudo kadmin.local -q "addprinc hadoop"
```

### 1.5 Generate and Distribute Keytabs
```bash
# Create keytab directory
sudo mkdir -p /etc/security/keytabs
sudo chmod 755 /etc/security/keytabs

# Generate keytabs for all services
sudo kadmin.local -q "xst -k /etc/security/keytabs/hdfs.service.keytab hdfs/hadoop-master@HADOOP.LOCAL"
sudo kadmin.local -q "xst -k /etc/security/keytabs/hdfs.service.keytab hdfs/hadoop-worker1@HADOOP.LOCAL"
sudo kadmin.local -q "xst -k /etc/security/keytabs/http.service.keytab HTTP/hadoop-master@HADOOP.LOCAL"
sudo kadmin.local -q "xst -k /etc/security/keytabs/http.service.keytab HTTP/hadoop-worker1@HADOOP.LOCAL"
sudo kadmin.local -q "xst -k /etc/security/keytabs/yarn.service.keytab yarn/hadoop-master@HADOOP.LOCAL"
sudo kadmin.local -q "xst -k /etc/security/keytabs/yarn.service.keytab yarn/hadoop-worker1@HADOOP.LOCAL"
sudo kadmin.local -q "xst -k /etc/security/keytabs/jhs.service.keytab jhs/hadoop-master@HADOOP.LOCAL"
sudo kadmin.local -q "xst -k /etc/security/keytabs/mapred.service.keytab mapred/hadoop-master@HADOOP.LOCAL"

# Generate user keytabs
sudo kadmin.local -q "xst -k /etc/security/keytabs/ubuntu.keytab ubuntu@HADOOP.LOCAL"
sudo kadmin.local -q "xst -k /etc/security/keytabs/hadoop.user.keytab hadoop@HADOOP.LOCAL"

# Set proper permissions for keytabs
sudo chown hdfs:hdfs /etc/security/keytabs/hdfs.service.keytab
sudo chown hdfs:hdfs /etc/security/keytabs/http.service.keytab
sudo chown yarn:yarn /etc/security/keytabs/yarn.service.keytab
sudo chown mapred:mapred /etc/security/keytabs/jhs.service.keytab
sudo chown mapred:mapred /etc/security/keytabs/mapred.service.keytab
sudo chmod 400 /etc/security/keytabs/*
```

### 1.6 Enable Kerberos Services
```bash
# Start Kerberos services
sudo systemctl start krb5-kdc
sudo systemctl start krb5-admin-server
sudo systemctl enable krb5-kdc
sudo systemctl enable krb5-admin-server

# Test Kerberos
kinit admin/admin
klist
```

## Step 2: Update Hosts File

Update `/etc/hosts` on ALL nodes:
```bash
# Add these entries if not present
127.0.0.1 localhost
<MASTER_IP> hadoop-master hadoop-master.hadoop.local
<WORKER1_IP> hadoop-worker1 hadoop-worker1.hadoop.local
```

## Step 3: Configure Hadoop for Kerberos Authentication

### 3.1 Update core-site.xml
Edit `/usr/local/hadoop/etc/hadoop/core-site.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <!-- Existing configuration -->
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://hadoop-master:9000</value>
        <description>The default file system URI for HDFS</description>
    </property>

    <property>
        <name>hadoop.tmp.dir</name>
        <value>/usr/local/hadoop/tmp</value>
        <description>Base directory for other temporary directories</description>
    </property>

    <property>
        <name>io.file.buffer.size</name>
        <value>4096</value>
        <description>Buffer size for reading files</description>
    </property>

    <!-- Kerberos Security Configuration -->
    <property>
        <name>hadoop.security.authentication</name>
        <value>kerberos</value>
        <description>Enable Kerberos authentication</description>
    </property>

    <property>
        <name>hadoop.security.authorization</name>
        <value>true</value>
        <description>Enable Hadoop authorization</description>
    </property>

    <property>
        <name>hadoop.security.group.mapping</name>
        <value>org.apache.hadoop.security.ShellBasedUnixGroupsMapping</value>
        <description>Group mapping implementation</description>
    </property>

    <property>
        <name>hadoop.security.group.mapping.ldap.url</name>
        <value>ldap://hadoop-master:389</value>
        <description>LDAP URL for group mapping (if using LDAP)</description>
    </property>

    <property>
        <name>hadoop.rpc.protection</name>
        <value>integrity</value>
        <description>SASL QOP for RPC connections</description>
    </property>
</configuration>
```

### 3.2 Update hdfs-site.xml
Edit `/usr/local/hadoop/etc/hadoop/hdfs-site.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <!-- Existing configuration -->
    <property>
        <name>dfs.replication</name>
        <value>1</value>
        <description>Default block replication for HDFS blocks</description>
    </property>

    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:/usr/local/hadoop/data/namenode</value>
        <description>Directory for NameNode data storage</description>
    </property>

    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:/usr/local/hadoop/data/datanode</value>
        <description>Directory for DataNode data storage</description>
    </property>

    <property>
        <name>dfs.blocksize</name>
        <value>128m</value>
        <description>Default block size for HDFS files</description>
    </property>

    <property>
        <name>dfs.http.address</name>
        <value>0.0.0.0:9870</value>
        <description>NameNode HTTP web UI address</description>
    </property>

    <property>
        <name>dfs.permissions</name>
        <value>true</value>
        <description>Enable permission checking for Kerberos setup</description>
    </property>

    <!-- Kerberos Security Configuration -->
    <property>
        <name>dfs.block.access.token.enable</name>
        <value>true</value>
        <description>Enable access tokens for DataNode access</description>
    </property>

    <property>
        <name>dfs.http.policy</name>
        <value>HTTPS_ONLY</value>
        <description>Require HTTPS for Hadoop web UIs</description>
    </property>

    <property>
        <name>dfs.https.enable</name>
        <value>true</value>
        <description>Enable HTTPS for HDFS</description>
    </property>

    <property>
        <name>dfs.namenode.https.port</name>
        <value>9871</value>
        <description>NameNode HTTPS port</description>
    </property>

    <property>
        <name>dfs.datanode.https.address</name>
        <value>0.0.0.0:9865</value>
        <description>DataNode HTTPS address</description>
    </property>

    <!-- NameNode Kerberos Configuration -->
    <property>
        <name>dfs.namenode.kerberos.principal</name>
        <value>hdfs/_HOST@HADOOP.LOCAL</value>
        <description>NameNode service principal</description>
    </property>

    <property>
        <name>dfs.namenode.keytab.file</name>
        <value>/etc/security/keytabs/hdfs.service.keytab</value>
        <description>NameNode keytab file</description>
    </property>

    <property>
        <name>dfs.namenode.kerberos.https.principal</name>
        <value>HTTP/_HOST@HADOOP.LOCAL</value>
        <description>NameNode HTTPS principal</description>
    </property>

    <property>
        <name>dfs.namenode.kerberos.internal.spnego.principal</name>
        <value>HTTP/_HOST@HADOOP.LOCAL</value>
        <description>NameNode SPNEGO principal</description>
    </property>

    <!-- DataNode Kerberos Configuration -->
    <property>
        <name>dfs.datanode.kerberos.principal</name>
        <value>hdfs/_HOST@HADOOP.LOCAL</value>
        <description>DataNode service principal</description>
    </property>

    <property>
        <name>dfs.datanode.keytab.file</name>
        <value>/etc/security/keytabs/hdfs.service.keytab</value>
        <description>DataNode keytab file</description>
    </property>

    <property>
        <name>dfs.datanode.kerberos.https.principal</name>
        <value>HTTP/_HOST@HADOOP.LOCAL</value>
        <description>DataNode HTTPS principal</description>
    </property>

    <!-- Web Authentication -->
    <property>
        <name>dfs.web.authentication.kerberos.principal</name>
        <value>HTTP/_HOST@HADOOP.LOCAL</value>
        <description>Web authentication principal</description>
    </property>

    <property>
        <name>dfs.web.authentication.kerberos.keytab</name>
        <value>/etc/security/keytabs/http.service.keytab</value>
        <description>Web authentication keytab</description>
    </property>
</configuration>
```

### 3.3 Update yarn-site.xml
Edit `/usr/local/hadoop/etc/hadoop/yarn-site.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>

<!-- Existing YARN configuration -->
<property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
</property>

<property>
    <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
    <value>org.apache.hadoop.mapred.ShuffleHandler</value>
</property>

<property>
    <name>yarn.resourcemanager.hostname</name>
    <value>hadoop-master</value>
</property>

<property>
    <name>yarn.nodemanager.vmem-pmem-ratio</name>
    <value>4</value>
</property>

<property>
    <name>yarn.nodemanager.memory.mapped</name>
    <value>false</value>
</property>

<!-- Kerberos Security Configuration -->
<property>
    <name>yarn.resourcemanager.keytab</name>
    <value>/etc/security/keytabs/yarn.service.keytab</value>
    <description>ResourceManager keytab file</description>
</property>

<property>
    <name>yarn.resourcemanager.principal</name>
    <value>yarn/_HOST@HADOOP.LOCAL</value>
    <description>ResourceManager principal</description>
</property>

<property>
    <name>yarn.nodemanager.keytab</name>
    <value>/etc/security/keytabs/yarn.service.keytab</value>
    <description>NodeManager keytab file</description>
</property>

<property>
    <name>yarn.nodemanager.principal</name>
    <value>yarn/_HOST@HADOOP.LOCAL</value>
    <description>NodeManager principal</description>
</property>

<property>
    <name>yarn.nodemanager.container-executor.class</name>
    <value>org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor</value>
    <description>Container executor class for security</description>
</property>

<property>
    <name>yarn.nodemanager.linux-container-executor.group</name>
    <value>hadoop</value>
    <description>Linux container executor group</description>
</property>

<!-- Web UI Security -->
<property>
    <name>yarn.http.policy</name>
    <value>HTTPS_ONLY</value>
    <description>Require HTTPS for YARN web UIs</description>
</property>

<property>
    <name>yarn.resourcemanager.webapp.https.address</name>
    <value>0.0.0.0:8090</value>
    <description>ResourceManager HTTPS web UI address</description>
</property>

<property>
    <name>yarn.nodemanager.webapp.https.address</name>
    <value>0.0.0.0:8044</value>
    <description>NodeManager HTTPS web UI address</description>
</property>

<property>
    <name>yarn.timeline-service.http-authentication.type</name>
    <value>kerberos</value>
    <description>Timeline service authentication type</description>
</property>

<property>
    <name>yarn.timeline-service.http-authentication.kerberos.principal</name>
    <value>HTTP/_HOST@HADOOP.LOCAL</value>
    <description>Timeline service principal</description>
</property>

<property>
    <name>yarn.timeline-service.http-authentication.kerberos.keytab</name>
    <value>/etc/security/keytabs/http.service.keytab</value>
    <description>Timeline service keytab</description>
</property>

</configuration>
```

### 3.4 Update mapred-site.xml
Edit `/usr/local/hadoop/etc/hadoop/mapred-site.xml`:
```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>

<!-- Existing MapReduce configuration -->
<property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
</property>

<property>
    <name>mapreduce.jobhistory.address</name>
    <value>hadoop-master:10020</value>
</property>

<property>
    <name>mapreduce.jobhistory.webapp.address</name>
    <value>hadoop-master:19888</value>
</property>

<property>
    <name>mapreduce.jobhistory.intermediate-done-dir</name>
    <value>/usr/local/hadoop/tmp/mr-history/tmp</value>
</property>

<property>
    <name>mapreduce.jobhistory.done-dir</name>
    <value>/usr/local/hadoop/tmp/mr-history/done</value>
</property>

<!-- Kerberos Security Configuration -->
<property>
    <name>mapreduce.jobhistory.keytab</name>
    <value>/etc/security/keytabs/mapred.service.keytab</value>
    <description>JobHistory Server keytab file</description>
</property>

<property>
    <name>mapreduce.jobhistory.principal</name>
    <value>mapred/_HOST@HADOOP.LOCAL</value>
    <description>JobHistory Server principal</description>
</property>

<property>
    <name>mapreduce.jobhistory.http.policy</name>
    <value>HTTPS_ONLY</value>
    <description>Require HTTPS for JobHistory web UI</description>
</property>

<property>
    <name>mapreduce.jobhistory.webapp.https.address</name>
    <value>0.0.0.0:19890</value>
    <description>JobHistory Server HTTPS web UI address</description>
</property>

<property>
    <name>mapreduce.jobhistory.http-authentication.type</name>
    <value>kerberos</value>
    <description>JobHistory Server authentication type</description>
</property>

<property>
    <name>mapreduce.jobhistory.http-authentication.kerberos.principal</name>
    <value>HTTP/_HOST@HADOOP.LOCAL</value>
    <description>JobHistory Server HTTP principal</description>
</property>

<property>
    <name>mapreduce.jobhistory.http-authentication.kerberos.keytab</name>
    <value>/etc/security/keytabs/http.service.keytab</value>
    <description>JobHistory Server HTTP keytab</description>
</property>

</configuration>
```

## Step 4: Configure SSL/TLS Certificates

### 4.1 Generate Self-Signed Certificates
```bash
# Create SSL directory
sudo mkdir -p /usr/local/hadoop/etc/hadoop/ssl
cd /usr/local/hadoop/etc/hadoop/ssl

# Generate private key
sudo openssl genrsa -out hadoop.key 2048

# Generate certificate signing request
sudo openssl req -new -key hadoop.key -out hadoop.csr -subj "/C=US/ST=State/L=City/O=Organization/OU=IT/CN=hadoop-master"

# Generate self-signed certificate
sudo openssl x509 -req -days 365 -in hadoop.csr -signkey hadoop.key -out hadoop.crt

# Create keystore and truststore
sudo keytool -genkeypair -alias hadoop -keyalg RSA -keysize 2048 -keystore keystore.jks -storepass hadoop -dname "CN=hadoop-master, OU=IT, O=Organization, L=City, ST=State, C=US"
sudo keytool -export -alias hadoop -keystore keystore.jks -storepass hadoop -file hadoop.cer
sudo keytool -import -alias hadoop -file hadoop.cer -keystore truststore.jks -storepass hadoop -noprompt

# Set permissions
sudo chown -R hdfs:hadoop /usr/local/hadoop/etc/hadoop/ssl
sudo chmod 600 /usr/local/hadoop/etc/hadoop/ssl/*
```

### 4.2 Configure SSL Properties
Create `/usr/local/hadoop/etc/hadoop/ssl-server.xml`:
```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>ssl.server.truststore.location</name>
        <value>/usr/local/hadoop/etc/hadoop/ssl/truststore.jks</value>
        <description>Truststore to be used by NN and DN</description>
    </property>

    <property>
        <name>ssl.server.truststore.password</name>
        <value>hadoop</value>
        <description>Comma separated list of truststore passwords</description>
    </property>

    <property>
        <name>ssl.server.truststore.type</name>
        <value>jks</value>
        <description>Optional, default jks</description>
    </property>

    <property>
        <name>ssl.server.keystore.location</name>
        <value>/usr/local/hadoop/etc/hadoop/ssl/keystore.jks</value>
        <description>Keystore to be used by NN and DN</description>
    </property>

    <property>
        <name>ssl.server.keystore.password</name>
        <value>hadoop</value>
        <description>Server keystore password</description>
    </property>

    <property>
        <name>ssl.server.keystore.keypassword</name>
        <value>hadoop</value>
        <description>Server key password</description>
    </property>

    <property>
        <name>ssl.server.keystore.type</name>
        <value>jks</value>
        <description>Optional, default jks</description>
    </property>

    <property>
        <name>ssl.server.exclude.cipher.list</name>
        <value>TLS_ECDHE_RSA_WITH_RC4_128_SHA,SSL_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA,SSL_RSA_WITH_DES_CBC_SHA,SSL_DHE_RSA_WITH_DES_CBC_SHA,SSL_RSA_EXPORT_WITH_RC4_40_MD5,TLS_ECDH_RSA_WITH_RC4_128_SHA,SSL_DH_anon_EXPORT_WITH_RC4_40_MD5,TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA,TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA,SSL_DH_anon_EXPORT_WITH_DES40_CBC_SHA,TLS_ECDH_anon_EXPORT_WITH_RC4_40_MD5,TLS_ECDH_anon_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDH_anon_WITH_DES_CBC_SHA,TLS_ECDHE_RSA_WITH_DES_CBC_SHA,SSL_RSA_EXPORT_WITH_DES40_CBC_SHA,TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA,TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA,TLS_ECDH_RSA_WITH_DES_CBC_SHA,TLS_ECDH_RSA_EXPORT_WITH_DES40_CBC_SHA,TLS_ECDH_anon_EXPORT_WITH_DES40_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDH_anon_WITH_AES_256_CBC_SHA,TLS_ECDH_anon_WITH_RC4_128_SHA,TLS_ECDHE_anon_WITH_3DES_EDE_CBC_SHA,TLS_ECDH_anon_WITH_RC4_128_SHA,TLS_ECDHE_anon_WITH_AES_128_CBC_SHA,TLS_ECDHE_anon_WITH_DES_CBC_SHA,TLS_ECDHE_anon_WITH_AES_256_CBC_SHA,SSL_RSA_WITH_RC4_128_SHA,SSL_DH_anon_WITH_DES_CBC_SHA,SSL_DH_anon_WITH_3DES_EDE_CBC_SHA,TLS_RSA_EXPORT_WITH_DES40_CBC_SHA,SSL_DH_anon_EXPORT_WITH_DES40_CBC_SHA,SSL_DH_anon_WITH_3DES_EDE_CBC_SHA,TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA,SSL_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA,SSL_DHE_anon_EXPORT_WITH_DES40_CBC_SHA,SSL_DHE_anon_WITH_DES_CBC_SHA,SSL_RSA_WITH_3DES_EDE_CBC_SHA,TLS_ECDH_RSA_WITH_RC4_128_SHA</value>
        <description>Blacklisted ciphers</description>
    </property>
</configuration>
```

## Step 5: Create Hadoop Users and Set Permissions

```bash
# Create Hadoop users if they don't exist
sudo useradd -r -m -d /var/lib/hdfs hdfs
sudo useradd -r -m -d /var/lib/yarn yarn
sudo useradd -r -m -d /var/lib/mapred mapred

# Create user groups
sudo groupadd hadoop
sudo usermod -a -G hadoop hdfs,yarn,mapred,ubuntu

# Set proper ownership for Hadoop directories
sudo chown -R hdfs:hdfs /usr/local/hadoop/data/namenode
sudo chown -R hdfs:hdfs /usr/local/hadoop/data/datanode
sudo chown -R hdfs:hdfs /usr/local/hadoop/tmp
sudo chown -R hdfs:hdfs /etc/security/keytabs
sudo chown -R hdfs:hadoop /usr/local/hadoop/etc/hadoop/ssl

# Create necessary directories
sudo mkdir -p /usr/local/hadoop/tmp/mr-history/tmp
sudo mkdir -p /usr/local/hadoop/tmp/mr-history/done
sudo chown -R mapred:mapred /usr/local/hadoop/tmp/mr-history
```

## Step 6: Update Hadoop Environment Variables

Edit `/usr/local/hadoop/etc/hadoop/hadoop-env.sh`:
```bash
# Add these lines at the end
export HADOOP_SECURE_DN_USER=hdfs
export HADOOP_SECURE_DN_PID_DIR=/usr/local/hadoop/tmp/pids
export HADOOP_SECURE_DN_LOG_DIR=/usr/local/hadoop/logs
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Kerberos configuration
export HADOOP_OPTS="-Djava.security.krb5.conf=/etc/krb5.conf ${HADOOP_OPTS}"
export HADOOP_NAMENODE_OPTS="-Djava.security.krb5.conf=/etc/krb5.conf ${HADOOP_NAMENODE_OPTS}"
export HADOOP_DATANODE_OPTS="-Djava.security.krb5.conf=/etc/krb5.conf ${HADOOP_DATANODE_OPTS}"
export HADOOP_SECONDARYNAMENODE_OPTS="-Djava.security.krb5.conf=/etc/krb5.conf ${HADOOP_SECONDARYNAMENODE_OPTS}"
export HADOOP_JOBTRACKER_OPTS="-Djava.security.krb5.conf=/etc/krb5.conf ${HADOOP_JOBTRACKER_OPTS}"
export HADOOP_TASKTRACKER_OPTS="-Djava.security.krb5.conf=/etc/krb5.conf ${HADOOP_TASKTRACKER_OPTS}"
export YARN_RESOURCEMANAGER_OPTS="-Djava.security.krb5.conf=/etc/krb5.conf ${YARN_RESOURCEMANAGER_OPTS}"
export YARN_NODEMANAGER_OPTS="-Djava.security.krb5.conf=/etc/krb5.conf ${YARN_NODEMANAGER_OPTS}"
```

## Step 7: Distribute Configuration to Worker Node

```bash
# Copy keytabs to worker node
scp -r /etc/security/keytabs ubuntu@hadoop-worker1:/etc/security/

# Copy configuration files to worker node
scp /usr/local/hadoop/etc/hadoop/core-site.xml ubuntu@hadoop-worker1:/usr/local/hadoop/etc/hadoop/
scp /usr/local/hadoop/etc/hadoop/hdfs-site.xml ubuntu@hadoop-worker1:/usr/local/hadoop/etc/hadoop/
scp /usr/local/hadoop/etc/hadoop/yarn-site.xml ubuntu@hadoop-worker1:/usr/local/hadoop/etc/hadoop/
scp /usr/local/hadoop/etc/hadoop/mapred-site.xml ubuntu@hadoop-worker1:/usr/local/hadoop/etc/hadoop/
scp /usr/local/hadoop/etc/hadoop/hadoop-env.sh ubuntu@hadoop-worker1:/usr/local/hadoop/etc/hadoop/
scp /usr/local/hadoop/etc/hadoop/ssl-server.xml ubuntu@hadoop-worker1:/usr/local/hadoop/etc/hadoop/

# Copy SSL certificates
scp -r /usr/local/hadoop/etc/hadoop/ssl ubuntu@hadoop-worker1:/usr/local/hadoop/etc/hadoop/

# Copy Kerberos configuration
scp /etc/krb5.conf ubuntu@hadoop-worker1:/etc/

# On worker node, set permissions
ssh ubuntu@hadoop-worker1 "sudo chown -R hdfs:hdfs /etc/security/keytabs && sudo chmod 600 /etc/security/keytabs/*"
```

## Step 8: Start Hadoop Services with Kerberos

### 8.1 Initialize Kerberos Ticket
```bash
# Get Kerberos ticket for HDFS user
kinit -kt /etc/security/keytabs/hdfs.service.keytab hdfs/$(hostname -f)@HADOOP.LOCAL

# Verify ticket
klist
```

### 8.2 Format HDFS (if first time)
```bash
# Only run this if setting up HDFS for the first time
/usr/local/hadoop/bin/hdfs namenode -format
```

### 8.3 Start HDFS Services
```bash
# Start NameNode
sudo -u hdfs /usr/local/hadoop/sbin/start-dfs.sh

# Verify services are running
jps
```

### 8.4 Start YARN Services
```bash
# Get Kerberos ticket for YARN user
kinit -kt /etc/security/keytabs/yarn.service.keytab yarn/$(hostname -f)@HADOOP.LOCAL

# Start YARN
sudo -u yarn /usr/local/hadoop/sbin/start-yarn.sh

# Start JobHistory Server
sudo -u mapred /usr/local/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver

# Verify all services
jps
```

## Step 9: Verify Kerberos Integration

### 9.1 Test HDFS Access
```bash
# Get user ticket
kinit ubuntu

# Test HDFS operations
hdfs dfs -ls /
hdfs dfs -mkdir /user/ubuntu
hdfs dfs -put /etc/hosts /user/ubuntu/
hdfs dfs -ls /user/ubuntu
```

### 9.2 Test MapReduce Job
```bash
# Create test data
echo "Hello Hadoop Kerberos Integration Test" > test.txt
hdfs dfs -put test.txt /user/ubuntu/

# Run wordcount job
hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar wordcount /user/ubuntu/test.txt /user/ubuntu/output

# Check results
hdfs dfs -cat /user/ubuntu/output/part-r-00000
```

### 9.3 Verify Web UI Access with Kerberos
```bash
# Access NameNode Web UI (HTTPS)
curl -k --negotiate -u : https://hadoop-master:9871/

# Access ResourceManager Web UI (HTTPS)
curl -k --negotiate -u : https://hadoop-master:8090/

# Access JobHistory Web UI (HTTPS)
curl -k --negotiate -u : https://hadoop-master:19890/
```

## Step 10: Troubleshooting

### 10.1 Common Issues and Solutions

1. **Keytab Permission Errors**
   ```bash
   sudo chown hdfs:hdfs /etc/security/keytabs/hdfs.service.keytab
   sudo chmod 400 /etc/security/keytabs/hdfs.service.keytab
   ```

2. **Kerberos Clock Skew**
   ```bash
   # Sync time on all nodes
   sudo apt install -y ntp
   sudo systemctl start ntp
   sudo systemctl enable ntp
   ```

3. **NameNode Fails to Start**
   ```bash
   # Check NameNode logs
   tail -f /usr/local/hadoop/logs/hadoop-hdfs-namenode-*.log

   # Verify keytab and principal
   kinit -kt /etc/security/keytabs/hdfs.service.keytab hdfs/$(hostname -f)@HADOOP.LOCAL
   ```

4. **HTTPS Certificate Issues**
   ```bash
   # Check certificate validity
   keytool -list -v -keystore /usr/local/hadoop/etc/hadoop/ssl/keystore.jks -storepass hadoop
   ```

5. **RPC Authentication Failures**
   ```bash
   # Check Kerberos ticket
   klist

   # Verify principal in keytab
   klist -kt /etc/security/keytabs/hdfs.service.keytab
   ```

### 10.2 Useful Commands

```bash
# Check Kerberos tickets
klist

# List principals
kadmin.local -q "listprincs"

# Test keytab
kinit -kt /etc/security/keytabs/hdfs.service.keytab hdfs/$(hostname -f)@HADOOP.LOCAL

# Renew ticket
kinit -R

# Destroy ticket
kdestroy

# Check Hadoop service status
jps

# Check HDFS health
hdfs dfsadmin -report

# Check YARN nodes
yarn node -list
```

## Step 11: Monitoring and Maintenance

### 11.1 Monitor Kerberos Tickets
```bash
# Create monitoring script
cat > /usr/local/hadoop/scripts/check-kerberos.sh << 'EOF'
#!/bin/bash
# Check Kerberos tickets for Hadoop services

services=("hdfs" "yarn" "mapred")
for service in "${services[@]}"; do
    if kinit -kt /etc/security/keytabs/${service}.service.keytab ${service}/$(hostname -f)@HADOOP.LOCAL -c /tmp/krb5cc_${service}; then
        echo "${service} Kerberos ticket: OK"
    else
        echo "${service} Kerberos ticket: FAILED"
    fi
done
EOF

chmod +x /usr/local/hadoop/scripts/check-kerberos.sh
```

### 11.2 Auto-renew Tickets
```bash
# Create ticket renewal service
cat > /etc/systemd/system/hadoop-kerberos-renewal.service << 'EOF'
[Unit]
Description=Hadoop Kerberos Ticket Renewal
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/hadoop/scripts/check-kerberos.sh
User=hdfs
Group=hdfs
```

cat > /etc/systemd/system/hadoop-kerberos-renewal.timer << 'EOF'
[Unit]
Description=Run Hadoop Kerberos ticket renewal every hour
Requires=hadoop-kerberos-renewal.service

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
EOF

sudo systemctl enable hadoop-kerberos-renewal.timer
sudo systemctl start hadoop-kerberos-renewal.timer
```

## Summary

After completing these steps, your Hadoop cluster will have:

✅ Kerberos authentication enabled for all Hadoop services
✅ HTTPS encryption for web UIs and data transfer
✅ Secure RPC communication between nodes
✅ User authentication and authorization
✅ Automated ticket renewal system

### Key Benefits:
- Strong authentication mechanism
- Protection against unauthorized access
- Secure data transmission
- Compliance with enterprise security standards
- User-level access control

### Next Steps:
1. Set up regular backups of Kerberos database
2. Implement monitoring for Kerberos service health
3. Configure log aggregation for security events
4. Document user access procedures
5. Regular security audits and certificate updates