# SOC Lab deployment runbook

This runbook makes deployment and validation repeatable. Use disposable VMs and systems you own or are authorised to monitor.

## Current execution status

Live deployment and evidence are recorded in [evidence/live-validation-2026-11-15.md](evidence/live-validation-2026-11-15.md). Wazuh runs in Ubuntu WSL; its dashboard responds on Windows localhost (HTTP 302), and API calls authenticate. Wazuh manager, Ubuntu WSL agent, and Windows agent are Active. Windows process-creation alerts and a synthetic Linux SSH failure have reached the Wazuh index. The Linux test is synthetic training data, not an intrusion.

The Wazuh dashboard is open in Edge. The operator supplied two genuine Overview screenshots, archived in [evidence/screenshots](evidence/screenshots/). They show 2 active endpoints and the dashboard panels. Windows audit policy readback and private event export are complete; sanitised review remains open. The Splunk compose file now selects the local Splunk Free license by default; no Splunk Cloud or container has been started.

## Requirements and topology

Use an isolated host-only or NAT network. Never expose SIEM management services publicly. A small Wazuh all-in-one VM should start around 4 vCPU, 8 GiB RAM, and 50 GB disk; check current vendor docs before deployment. Keep VM snapshots before exercises. Keep credentials, agent keys, raw exports, and private IP details out of GitHub.

## 1. Deploy Wazuh on Ubuntu

On a fresh supported Ubuntu Server VM, follow the [official Wazuh Quickstart](https://documentation.wazuh.com/current/quickstart.html). It installs the server, indexer, and dashboard on one host. Confirm supported OS and resource requirements before proceeding.

```bash
sudo apt-get update
sudo apt-get install -y curl
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
sudo bash ./wazuh-install.sh -a
```

The assistant prints the dashboard URL and credentials. Save them privately. Never commit the generated password archive. The dashboard API is healthy in this WSL lab, and Windows localhost returns HTTP 302. The browser presents a local self-signed certificate warning; decide whether to trust it before continuing. Never bypass certificate warnings on public services.

## Keep the Ubuntu WSL lab available

WSL stops an idle distro by default. For this Docker lab, that stops the published dashboard port and causes Windows to report `ERR_CONNECTION_REFUSED`. On this host, the persistent fix is in the Windows user profile file `%UserProfile%\\.wslconfig`:

```ini
[general]
instanceIdleTimeout=-1
```

This global WSL2 setting disables distro idle auto-shutdown. Apply it by running `wsl --shutdown`, then start Ubuntu again. Docker is enabled under systemd and the lab containers have restart policies. The setting leaves the WSL distro and its services running while idle, so WSL continues using resources. See [Microsoft's WSL configuration reference](https://learn.microsoft.com/en-us/windows/wsl/wsl-config).

## 2. Enrol Windows and Ubuntu agents

In Wazuh select **Agents management → Summary → Deploy new agent**. Choose the endpoint OS and copy the generated commands for your manager. Do not put environment-specific keys or passwords in this repository.

- Windows: the provided installer script installed the official Wazuh MSI in elevated PowerShell. The service is running and the manager reports agent ID 002 Active. See [Windows agent deployment](https://documentation.wazuh.com/current/installation-guide/wazuh-agent/wazuh-agent-package-windows.html).
- Ubuntu WSL: agent ID 001 is Active. See [Linux agent deployment](https://documentation.wazuh.com/current/installation-guide/wazuh-agent/wazuh-agent-package-linux.html).

Use [wazuh/agent-ossec.conf](wazuh/agent-ossec.conf) only as a reference. Merge relevant log collection blocks into each endpoint's existing configuration; do not replace the full config. Windows channels belong on Windows; Linux file paths belong on Ubuntu. Confirm paths exist.

**Pass condition:** both agents show **Active** and a timestamped event from each appears under the correct agent. This was observed: Windows process-creation alerts (rule 67027) were indexed from agent 002; a synthetic SSH failure matched rule 5710 and was indexed from agent 001. Details and limitations are in the live validation record.

## 3. Windows audit policy and event export

On the disposable Windows VM, review [windows/Enable-SOC-Auditing.ps1](windows/Enable-SOC-Auditing.ps1) and [windows/Install-WazuhAgent.ps1](windows/Install-WazuhAgent.ps1), then run it from elevated PowerShell. It changes local audit policy. Verify with:

```powershell
auditpol /get /category:*
```

For process command-line capture, use the local policy path printed by the script. Command lines can contain secrets. Export a bounded event window:

```powershell
.\\windows\\Export-SecurityEvents.ps1 -HoursBack 2 -OutputDirectory .\\evidence-private
```

The export contains sensitive event data and XML. Keep it local and sanitise a copy before sharing. Never commit raw Security.evtx or unredacted exports. An elevated `auditpol /get /category:*` readback succeeded; Logon and Process Creation show Success and Failure enabled. A two-hour event export completed in private LocalAppData (5,406 records); raw contents remain local and the redacted review is pending.

## 4. Start Splunk

This lab uses a local, standalone Splunk Free license (`SPLUNK_LICENSE_URI=Free`), not Splunk Cloud. Splunk documents Free as non-expiring with a 500 MB/day limit; scheduled alerting is unavailable, so this phase tests searches and dashboards while Wazuh remains responsible for alert validation. See [Splunk Free limits](https://help.splunk.com/en/data-management/splunk-enterprise-admin-manual/10.6/configure-splunk-licenses/about-splunk-free) and [the Docker Free-license example](https://github.com/splunk/docker-splunk/blob/develop/docs/EXAMPLES.md).

Before startup, the operator must read and personally accept Splunk's current [General Terms](https://www.splunk.com/en_us/legal/splunk-general-terms.html) and applicable [software license agreement](https://www.splunk.com/en_us/legal/splunk-software-license-agreement-bah.html). Splunk 10.x Docker startup requires flags that explicitly represent that acceptance; they remain commented out in `.env.example`. Do not enable them unless you personally accept the terms.

The compose file maps Splunk Web to `http://localhost:18000`; other ports are loopback-bound. From SOC-Lab/splunk:

```bash
cp .env.example .env
# Replace SPLUNK_PASSWORD with a strong unique value; keep .env private.
docker compose up -d
docker compose ps
docker compose logs -f splunk
```

Open http://localhost:18000 and sign in as admin. Initial startup may take several minutes. Compose ports bind to loopback by default. For endpoints in separate VMs, deliberately configure a reachable host-only interface and firewall rule; do not bind management or receiving ports publicly.

Stop without deleting data using `docker compose down`. Removing volumes with `docker compose down -v` permanently deletes Splunk lab state. No Splunk container has been started and no SPL runtime result has been claimed.

## 5. Import and validate synthetic events

From the repository root:

```bash
python SOC-Lab/samples/generate_events.py
```

The generator creates synthetic Windows JSON/CSV and a Linux SSH authentication log. All identities and addresses are fictional training data. Import the Windows file into a disposable index and configure timestamp/field extraction for EventCode, TargetUserName, IpAddress, Computer, and LogonType. The fixture marks its successful 4624 event as LogonType 10 to exercise the remote interactive logon search. Ingest synthetic-linux-auth.log as linux_secure or syslog with timestamp extraction. If Splunk uses different field names, adapt [splunk/queries.spl](splunk/queries.spl).

There are eight detection searches plus one dashboard panel search. Run each detection individually and record time range, result count, and field mapping changes. The Windows fixture includes failed and successful logons, account creation, group membership, PowerShell, and log clearing. The Linux fixture contains repeated SSH failures. Synthetic events validate SPL behavior only; they do not validate endpoint collection or live telemetry.

Searches in [splunk/savedsearches.conf](splunk/savedsearches.conf) are disabled by default. Import only after verifying SPL and field extraction. Enable a scheduled alert only after a positive test returns the expected result and a benign negative test does not fire. For three alert examples, record test event, observed result, and time.

Record search title, SPL, index/sourcetype, test data ID, expected and observed result, timestamp, and disposition. A successful search execution alone is not validation.

## 6. Evidence and screenshots

Capture evidence only from the running lab. Keep unredacted originals privately; create redacted portfolio copies. Show enough context to identify platform, result, and timestamp while hiding usernames, hostnames, private addresses, keys, passwords, tokens, and unrelated personal data. Use actual screenshots and event identifiers. Never present mock screenshots or synthetic events as live telemetry.

Minimum evidence:

1. Wazuh agent inventory with both endpoints Active and a recent event from each.
2. Windows audit policy verification and one sanitised event.
3. Results for all eight detections and the dashboard panel, including Linux authentication data.
4. Three tested alerts with positive and negative results.
5. ATT&CK rationale tied to observed events, confidence, and limitations.
6. One incident report based on observed, sanitised lab evidence, with evidence IDs and analyst actions.

## Completion gate

- [x] Wazuh deployed in Ubuntu WSL; manager, indexer, and dashboard services running
- [x] Windows and Ubuntu WSL agents both Active
- [x] Timestamped Windows and Ubuntu agent alerts indexed in Wazuh (Linux event is synthetic)
- [x] Genuine Wazuh Overview screenshots archived in evidence/screenshots (operator-provided; not redacted)
- [x] Windows audit policy readback verified (Logon and Process Creation: Success and Failure)
- [x] Bounded Windows event export completed and stored with user/SYSTEM-only ACL
- [x] Sanitised aggregate summary generated from event IDs/counts only
- [ ] Analyst review raw Windows event details locally; redact any selected examples
- [ ] Redact screenshot/browser identifiers before broader portfolio sharing
- [ ] Operator personally accepts the applicable Splunk terms
- [ ] Local Splunk Free container started and synthetic data imported after acceptance
- [ ] Splunk running with private credentials and imported synthetic data
- [ ] Eight SPL detections tested against suitable positive data
- [ ] Benign negative test completed for each alert
- [ ] Three alerts tested and documented
- [ ] ATT&CK mapping checked against current knowledge base
- [ ] One report completed using observed, sanitised lab evidence
- [ ] Genuine screenshots captured and redacted

Keep unchecked items open until each has evidence from the running environment.
