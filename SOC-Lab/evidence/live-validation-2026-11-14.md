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

- A separate Ubuntu VM endpoint is not connected. The active Linux endpoint is WSL2.
- No Windows Wazuh agent is registered. The current Windows account lacks Administrator elevation, required for the agent MSI and audit policy.
- Windows audit policy and event export have not been run.
- Splunk detections, dashboard, positive/negative alert tests, and incident reports have not been validated against a running Splunk instance.
- No genuine dashboard screenshot has been captured. The dashboard uses a self-signed TLS certificate and the available browser flow did not establish a trusted session.
- No real Windows or Ubuntu VM telemetry evidence is available. Repository fixtures remain synthetic training data.

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

1. Run an elevated Windows PowerShell session on a disposable Windows endpoint to install/enroll the Wazuh agent and enable the documented audit policy.
2. Enroll a separate Ubuntu VM if the portfolio requirement is specifically a VM; the current WSL agent proves the Linux agent path only.
3. Start Splunk from `SOC-Lab/splunk` after the operator reviews and accepts Splunk's license terms, then load fixtures and validate each search and alert.
4. Capture screenshots from the trusted local lab UI and redact hostnames, usernames, credentials, and private addresses before publishing.

Do not describe this record as proof of Windows coverage, a separate Ubuntu VM, validated Splunk detections, or genuine screenshots.
