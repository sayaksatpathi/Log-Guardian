# Live lab validation — 2026-11-15

## Root cause and fix

The Windows browser showed `ERR_CONNECTION_REFUSED` because Ubuntu WSL had stopped after its idle timeout. Docker and its published localhost ports stop with the distro. A temporary `sleep 600` kept WSL alive for ten minutes only, so the earlier restart appeared to fix the problem and then expired.

The host had no existing `%UserProfile%\\.wslconfig`. I created it with:

```ini
[general]
instanceIdleTimeout=-1
```

This disables WSL's distro idle auto-shutdown. WSL 2.7.11 applied the setting after `wsl --shutdown` and restart. With no keepalive shell process left, `wsl --list --running` still listed Ubuntu after 30 seconds. The setting is documented by [Microsoft](https://learn.microsoft.com/en-us/windows/wsl/wsl-config).

The transient `vm.max_map_count` was `1048576`, above Wazuh's required value; it was not the cause.

## Verified after the fix

- Docker service is active.
- Wazuh indexer, manager, and dashboard containers are running.
- Wazuh manager core services are running.
- Windows `curl.exe -k -I https://127.0.0.1:8443/` returns HTTP 302 to `/app/login`.
- Wazuh manager lists the Ubuntu WSL agent as Active (ID 001).
- A synthetic SSH failure matches Wazuh rule 5710 in `wazuh-logtest`; the corresponding agent-forwarded alert has not yet been confirmed.
- The dashboard's Server APIs page showed the configured manager as Offline. Diagnosis found the dashboard API password and manager API user had drifted. The existing local API secret was synchronized into the manager bootstrap config and dashboard connection config; the manager was restarted.
- From inside the dashboard container, the configured API credentials now authenticate successfully against `/security/user/authenticate?raw=true` (HTTP 200). An authenticated `GET /agents` returns two Active agents: manager ID 000 and Ubuntu WSL agent ID 001.
- The API backend is verified healthy. The browser's Server APIs status table still needs a Refresh/Check connection action to show the updated Online state; no post-refresh screenshot has been captured yet.

The browser error screenshot was captured before the containers had started after WSL restart. The dashboard uses a self-signed certificate; do not bypass the browser warning automatically.

## Still outstanding

- Windows Wazuh agent installation and audit-policy verification require an elevated PowerShell session. The current account is not an administrator, and the attempted elevation launch was rejected by the command approval policy.
- Splunk searches and alerts remain untested because Splunk's license and General Terms have not been accepted by the operator.
- Genuine dashboard screenshots are not captured.

## Recheck commands

```powershell
wsl --list --running
curl.exe -k -I https://127.0.0.1:8443/
```

```sh
systemctl is-active docker
docker ps
docker exec single-node-wazuh.manager-1 /var/ossec/bin/agent_control -lc
```
