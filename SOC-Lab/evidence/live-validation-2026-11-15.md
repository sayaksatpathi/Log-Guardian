# Live lab validation — 2026-11-15

## Wazuh deployment and connectivity

The Wazuh all-in-one stack is running in Ubuntu WSL. Windows localhost responds with HTTP 302 from the dashboard endpoint at `https://127.0.0.1:8443/`. Dashboard and API use a lab self-signed certificate; the browser requires an explicit operator trust decision. The API credentials were repaired and authenticated API requests return HTTP 200.

The host's WSL idle timeout had stopped the distro and caused `ERR_CONNECTION_REFUSED`. Setting `instanceIdleTimeout=-1` in the Windows user's `.wslconfig`, then restarting WSL, fixed that cause. Ubuntu WSL remains running while idle. This global setting keeps WSL services consuming resources; see [Microsoft's WSL configuration reference](https://learn.microsoft.com/en-us/windows/wsl/wsl-config).

## Endpoint enrollment

The manager reports all three expected agents Active:

- ID 000: Wazuh manager (local)
- ID 001: Ubuntu WSL endpoint `LAPTOP-5EJH0UG8`
- ID 002: Windows endpoint `LAPTOP-5EJH0UG8-Windows`

The Windows MSI installed successfully; WazuhSvc is running and the agent enrolled under a distinct name to avoid colliding with the WSL agent.

## Alert pipeline checks

- A synthetic Linux SSH failure using reserved TEST-NET-2 address `198.51.100.23` and fictional user `labdemo` was written to the configured WSL auth test log. Wazuh rule 5710 matched it in `wazuh-logtest`, and the alert was forwarded by agent 001 and indexed in `wazuh-alerts-*`. This validates the pipeline with synthetic data; it is not a real intrusion.
- Windows agent ID 002 produced process-creation alerts (rule 67027) that were indexed in `wazuh-alerts-*`. This confirms Windows telemetry reached the manager and indexer.
- The host dashboard URL and API were checked from command line. The browser still displays a certificate authority warning for the local self-signed certificate. No browser bypass was automated and no genuine UI screenshot has been captured.
- An elevated `auditpol /get /category:*` readback succeeded. Logon and Process Creation auditing show Success and Failure enabled. The full readback is stored privately in the Windows user's LocalAppData, not in GitHub.
- A two-hour Windows event export completed: 5,406 records across selected Security and PowerShell event IDs. The CSV/JSON originals are stored outside the repository in the Windows user's LocalAppData; the export directory ACL grants Full Control only to that user and SYSTEM. Only record counts and event-ID categories were inspected; raw event contents were not copied to GitHub. The export still needs analyst review and a redacted portfolio sample.

## Splunk status

Splunk compose configuration passed `docker compose config --quiet` using an ignored local `.env`. The local secret is protected by a Windows ACL granting Full Control only to the current user and SYSTEM; the value is not in GitHub. The container was not started, and no license or General Terms acceptance is recorded. Splunk searches/alerts remain untested until the operator personally reviews and accepts applicable terms; see [SOC-Lab/DEPLOYMENT.md](../DEPLOYMENT.md).

## Remaining evidence

1. Operator handles the browser's local certificate warning, then capture a genuine Wazuh inventory/event screenshot with sensitive details redacted.
2. Review the private two-hour export locally and create only a sanitised portfolio sample if useful.
3. Operator accepts applicable Splunk terms, then start Splunk, import fixtures, and test each search with positive and negative cases.
4. Capture genuine Splunk results and document tested alerts.

Do not describe synthetic events as real attacks or claim screenshots/search results that have not been captured.
