stop:
	multipass stop vitou

stop-worker:
	multipass stop worker1

start:
	multipass start vitou

start-worker:
	multipass start worker1

list:
	multipass list --snapshots

ssh:
	ssh ubuntu@10.149.252.178

ssh-worker:
	ssh ubuntu@10.149.252.239

init:
	multipass restore vitou.claude

claude:
	multipass restore vitou.installed-hadoop