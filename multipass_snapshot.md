# 🚀 Multipass Snapshot


1. List Snapshot

   ```
   multipass list --snapshots
   ```
2. Create Snapshot:
   ```
   multipass snapshot <name-server> --name <name-snapshot>
   ```
3. Rollback server
   ```
   multipass restore <name-server>.<name-snapshot>
   ```

4. Start your stopped server
   ```
   multipass start <name-server>
   ```

5. Remove-Snapshot
   ```
   multipass delete <name-server>.<name-snapshot>
   ```