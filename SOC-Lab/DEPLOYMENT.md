# SOC Lab deployment runbook

This runbook makes deployment and validation repeatable. It does not claim software is installed or live telemetry validated. Use disposable VMs and systems you own or are authorised to monitor.

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

The assistant prints the dashboard URL and credentials. Save them privately. Never commit the generated password archive. Open the dashboard from the isolated network. Follow vendor guidance for its first-login certificate; do not bypass certificate warnings on public services. If the documented release changes, use the version and URL shown by current official docs.

## 2. Enrol Windows and Ubuntu agents

In Wazuh select **Agents management → Summary → Deploy new agent**. Choose the endpoint OS and copy the generated commands for your manager. Do not put environment-specific keys or passwords in this repository.

- Windows: run the official MSI installation command in elevated PowerShell on the disposable VM and start the Wazuh service. See [Windows agent deployment](https://documentation.wazuh.com/current/installation-guide/wazuh-agent/wazuh-agent-package-windows.html).
- Ubuntu: install from the official Wazuh APT repository with the manager address, then enable and start wazuh-agent. See [Linux agent deployment](https://documentation.wazuh.com/current/installation-guide/wazuh-agent/wazuh-agent-package-linux.html).

Use [wazuh/agent-ossec.conf](wazuh/agent-ossec.conf) only as a reference. Merge relevant log collection blocks into each endpoint's existing configuration; do not replace the full config. Windows channels belong on Windows; Linux file paths belong on Ubuntu. Confirm paths exist.

**Pass condition:** both agents show **Active**. Generate a benign test event on each and confirm it appears with the correct agent name and timestamp. An installed service alone does not pass.

## 3. Windows audit policy and event export

On the disposable Windows VM, review [windows/Enable-SOC-Auditing.ps1](windows/Enable-SOC-Auditing.ps1), then run it from elevated PowerShell. It changes local audit policy. Verify with:

```powershell
auditpol /get /category:*
```

For process command-line capture, use the local policy path printed by the script. Command lines can contain secrets. Export a bounded event window:

```powershell
.\windows\Export-SecurityEvents.ps1 -HoursBack 2 -OutputDirectory .\evidence-private
```

The export contains sensitive event data and XML. Keep it local and sanitise a copy before sharing. Never commit raw Security.evtx or unredacted exports.

## 4. Start Splunk

From SOC-Lab/splunk:

```bash
cp .env.example .env
# Replace SPLUNK_PASSWORD with a strong unique password; keep .env private.
docker compose up -d
docker compose ps
docker compose logs -f splunk
```

Open http://localhost:8000 and sign in as admin. Initial startup may take several minutes. Compose ports bind to loopback by default. For endpoints in separate VMs, deliberately configure a reachable host-only interface and firewall rule; do not bind management or receiving ports publicly.

Stop without deleting data using docker compose down. Removing volumes with docker compose down -v permanently deletes Splunk lab state.

## 5. Import and validate synthetic events

From the repository root:

```bash
python SOC-Lab/samples/generate_events.py
```

Generated identities and events are fictional practice data, not endpoint telemetry. Import CSV or JSON into a disposable index. Configure timestamps and extraction for fields such as EventCode, TargetUserName, IpAddress, and Computer. If Splunk extracts different names, adapt [splunk/queries.spl](splunk/queries.spl).

Run all eight searches individually. Record time range, result count, and field mapping changes. The synthetic data supports Windows logon, account creation, group membership, PowerShell, and log clearing searches. The Linux SSH detection requires Linux authentication events; Windows-only synthetic events cannot validate it.

Searches in [splunk/savedsearches.conf](splunk/savedsearches.conf) are disabled by default. Import only after verifying SPL and field extraction. Enable a scheduled alert only after a positive test returns the expected result and a benign negative test does not fire. For three alert examples, record test event, observed result, and time.

Record search title, SPL, index/sourcetype, test data ID, expected and observed result, timestamp, and disposition. A successful search execution alone is not validation.

## 6. Evidence and screenshots

Capture evidence only from the running lab. Keep unredacted originals privately; create redacted portfolio copies. Show enough context to identify platform, result, and timestamp while hiding usernames, hostnames, private addresses, keys, passwords, tokens, and unrelated personal data. Use actual screenshots and event identifiers. Never present mock screenshots or synthetic events as live telemetry.

Minimum evidence:

1. Wazuh agent inventory with both endpoints Active and a recent event from each.
2. Windows audit policy verification and one sanitised event.
3. Results for all eight SPL searches, including Linux authentication data for its rule.
4. Three tested alerts with positive and negative results.
5. ATT&CK rationale tied to observed events, confidence, and limitations.
6. One incident report based on observed, sanitised lab evidence, with evidence IDs and analyst actions.

## Completion gate

- [ ] Wazuh dashboard reachable on isolated lab network
- [ ] Windows and Ubuntu agents both Active
- [ ] Timestamped event from each agent visible in Wazuh
- [ ] Windows audit policy verified and bounded export reviewed
- [ ] Splunk running with private credentials and imported data
- [ ] Eight SPL detections tested against suitable positive data
- [ ] Benign negative test completed for each alert
- [ ] Three alerts tested and documented
- [ ] ATT&CK mapping checked against current knowledge base
- [ ] One report completed using observed, sanitised lab evidence
- [ ] Genuine screenshots captured and redacted

Keep this checklist open until each item has evidence from the running environment.
