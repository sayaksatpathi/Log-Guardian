# Live lab validation record — 2026-11-14

This record reflects checks performed on the attached Windows/WSL2 host. It separates observed facts from checklist items that need a different endpoint or user action.

## Verified on the host

- Wazuh Docker stack (manager, indexer, dashboard) was running.
- Wazuh manager API and auth daemon were running.
- Wazuh dashboard HTTPS endpoint at `https://127.0.0.1:8443/` returned HTTP 302.
- Wazuh manager listed agent ID `001` as Active, running Wazuh 4.14.10 on Linux kernel `microsoft-standard-WSL2`.
- The WSL agent service was active.
- Splunk has not been started or its license accepted.

## Not completed / evidence unavailable

- Ubuntu WSL is connected and Active. This satisfies the Linux/Ubuntu endpoint requirement for this lab; it is specifically a WSL endpoint, not a separate VM.
- No Windows Wazuh agent is registered. The current Windows account lacks Administrator elevation, required for the agent MSI and audit policy. The attempt to launch the elevated installer was rejected by the command approval policy before execution.
- Windows audit policy and event export have not been run.
- Splunk detections, dashboard, positive/negative alert tests, and incident reports have not been validated against a running Splunk instance.
- No genuine dashboard screenshot has been captured. The browser rejected the dashboard's self-signed certificate with ERR_CERT_AUTHORITY_INVALID; it was not bypassed.
- No real Windows authentication event is available. Repository fixtures and the Wazuh SSH rule test are synthetic training data.

## Reproduction checks

Run in the Ubuntu WSL distribution:

```sh
docker ps --format '{{.Names}} {{.Status}}'
docker exec single-node-wazuh.manager-1 /var/ossec/bin/agent_control -lc
sudo systemctl is-active wazuh-agent
curl -sk -o /dev/null -w 'dashboard_http=%{http_code}\n' https://127.0.0.1:8443/
```

The `-k` option was used only for this local self-signed lab endpoint check. It is not a recommendation for normal browsing or production TLS validation.

## Remaining environment gates

1. Run [windows/Install-WazuhAgent.ps1](../windows/Install-WazuhAgent.ps1) from elevated PowerShell to install/enroll Windows and enable its documented audit policy. Then generate a benign failed logon and verify the event in Wazuh.
2. Start Splunk from `SOC-Lab/splunk` after the operator reviews and accepts Splunk's license terms, then load fixtures and validate each search and alert.
3. Capture screenshots from the trusted local lab UI and redact hostnames, usernames, credentials, and private addresses before publishing.

Do not describe this record as proof of Windows coverage, a separate Ubuntu VM, validated Splunk detections, or genuine screenshots.
