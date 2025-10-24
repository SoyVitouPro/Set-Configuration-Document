# ⚙️ Prompt: Simplified Single-Node Hadoop Installation & README Guide (No SSH)

## ⚠️ Important Rules
- Run all installation and configuration steps sequentially until Hadoop is fully set up and verified.
- Do **not** stop or summarize early — continue setup until `hdfs dfsadmin -report` confirms success.
- If a command fails, fix it and retry automatically.
- No SSH setup, no multi-node configuration — single local server only.
- No screenshots or images — text-only documentation.
- After successful installation, generate a complete **README.md** with all setup steps, verification, troubleshooting, and common Hadoop commands.
- Use proper **Markdown formatting**, **bash code blocks** for commands, and **XML code blocks** for config files.
- Output must be **fully self-contained** and **ready for GitHub use**.

---

Act as a **Senior DevOps Engineer** and create a **comprehensive, text-only guide** for installing and configuring **Apache Hadoop (latest stable version)** on a **single Linux server (Ubuntu 22.04 preferred)** in **pseudo-distributed mode**.

Your response must include two clearly separated sections:

---

## Part 1 — Hadoop Single-Node Installation & Configuration Guide

Provide a **clear, step-by-step setup** covering only what’s required for a single-server environment — no SSH setup or multi-node communication.

Include the following sections:

1. **System Setup (Minimal)**
   - Verify OS (Ubuntu/Debian)
   - Install and check Java (OpenJDK 11 or newer)
   - Set essential environment variables:
     - `JAVA_HOME`
     - `HADOOP_HOME`
     - `PATH`

2. **Download and Install Hadoop**
   - Download the latest stable Hadoop release from Apache mirrors
   - Extract to `/usr/local/hadoop`
   - Set correct ownership and permissions

3. **Configure Hadoop for Single-Node Mode**
   Provide full example configurations for:
   - `core-site.xml`
   - `hdfs-site.xml`
   - `mapred-site.xml`
   - `yarn-site.xml`

   Each config file should include:
   - Proper XML formatting
   - Inline comments for each key property
   - Paths consistent with `/usr/local/hadoop`

4. **HDFS Setup and Service Startup**
   - Format the NameNode
   - Start Hadoop services (`start-dfs.sh`, `start-yarn.sh`)
   - Verify daemons using:
     ```bash
     jps
     ```
   - Check HDFS status using:
     ```bash
     hdfs dfsadmin -report
     ```

5. **Environment Validation**
   - Persist variables in `.bashrc`
   - Test installation with:
     ```bash
     hadoop version
     ```

6. **Test MapReduce**
   - Create input/output directories
   - Run the built-in WordCount example
   - View output results from HDFS

7. **Service Management**
   - Commands to start and stop Hadoop
   - How to safely reformat or clean HDFS if needed

8. **Troubleshooting**
   - Common single-node issues (e.g., NameNode format errors, Java path issues)
   - Quick fixes for log or permission errors

Use **bash code blocks** for commands, **XML code blocks** for configuration, and concise **plain text explanations**.  
No screenshots or images — text-only.

---

## Part 2 — README.md File

After generating the installation guide, create a **README.md** file documenting this process.

The README should:
- Include **title**, **overview**, and **minimal prerequisites**
- Walk through all setup steps in order
- Use code blocks for commands and configuration files
- Provide verification steps (`hdfs dfsadmin -report`, `jps`)
- Include **Troubleshooting** and **References** sections
- Add **Common Hadoop Commands (User Quick Reference)** at the end
- Exclude any screenshots or image placeholders

---

✅ End Goal:  
Produce a **fully configured, verified single-node Hadoop environment** and a **ready-to-use README.md** with setup, validation, troubleshooting, and command reference — all in text-only Markdown format.