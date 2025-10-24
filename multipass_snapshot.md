# 🚀 Multipass Snapshot & Instance Management Guide

This guide covers snapshot management, rollback procedures, and troubleshooting for Multipass instances.

## Basic Instance Management

### List All Instances
```bash
multipass list
```

### Instance States
- **Running**: Instance is operational and accessible
- **Stopped**: Instance is powered off but preserved
- **Starting**: Instance is booting up
- **Unknown**: Instance is in a problematic state (requires troubleshooting)

## Snapshot Management

### 1. List Snapshots
```bash
# List snapshots for all instances
multipass list --snapshots

# List snapshots for a specific instance
multipass list --snapshots <instance-name>
```

### 2. Create Snapshot
```bash
# Create a snapshot of a running instance
multipass snapshot <instance-name> --name <snapshot-name>

# Example:
multipass snapshot vitou --name initial-setup
```

**Best Practices:**
- Create snapshots before making major changes
- Use descriptive snapshot names (e.g., "before-update", "post-install")
- Ensure instance is in a stable state before snapshotting

### 3. Restore/Rollback to Snapshot
```bash
# Restore an instance to a specific snapshot
multipass restore <instance-name>.<snapshot-name>

# Example:
multipass restore vitou.initial-setup
```

**Important Notes:**
- The instance must be stopped before restoration
- All current changes will be lost
- The instance will automatically start after restoration

### 4. Start Stopped Instance
```bash
multipass start <instance-name>
```

### 5. Delete Snapshot
```bash
# Remove a specific snapshot
multipass delete <instance-name>.<snapshot-name>

# Example:
multipass delete vitou.initial-setup
```

## Instance Recovery & Troubleshooting

### When Instance Shows "Unknown" State

If an instance gets stuck in "Unknown" state:

1. **Try restart first:**
   ```bash
   multipass restart <instance-name>
   ```

2. **If restart fails, stop and start:**
   ```bash
   multipass stop <instance-name> && multipass start <instance-name>
   ```

3. **Last resort - backup and recreate:**
   ```bash
   # Create snapshot if possible
   multipass snapshot <instance-name> --name backup-before-recreate

   # Delete the problematic instance
   multipass delete <instance-name>
   multipass purge

   # Create new instance with same name
   multipass launch --name <instance-name>
   ```

### Complete Instance Management Example

```bash
# Working with your 'vitou' instance:

# 1. Check current status
multipass list

# 2. Create snapshot before changes
multipass snapshot vitou --name stable-state

# 3. Make your changes (install software, configure, etc.)

# 4. If something goes wrong, rollback
multipass restore vitou.stable-state

# 5. Check instance status
multipass list

# 6. Clean up old snapshots
multipass delete vitou.old-snapshot-name
```

## Useful Commands

### Check Instance Details
```bash
multipass info <instance-name>
```

### Stop an Instance
```bash
multipass stop <instance-name>
```

### Delete Instance Completely
```bash
multipass delete <instance-name>
multipass purge
```

### Shell Access
```bash
multipass shell <instance-name>
```

## Troubleshooting Common Issues

1. **Instance stuck in "Starting" state**: Wait a few minutes, then check again
2. **Instance in "Unknown" state**: Use recovery steps above
3. **Can't create snapshot**: Ensure instance is running and not in transitional state
4. **Restore fails**: Make sure instance is stopped before attempting restore

## Current Instance Information

Your current instance:
- **Name**: vitou
- **State**: Running
- **IP**: 10.149.252.22
- **OS**: Ubuntu 24.04 LTS
- **Snapshots**: 1 (from the previous instance)