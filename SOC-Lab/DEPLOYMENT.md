# SOC Lab deployment runbook

This runbook describes deployment and validation. It does not claim that software has already been installed or telemetry validated on your machines.

## Safety and topology

- Use disposable Windows and Ubuntu VMs on a host-only or isolated NAT network.
- Keep SIEM management ports private; never expose them to the public internet.
- Take VM snapshots before exercises. Use only systems you own or are authorised to monitor.
- Keep credentials, agent keys, raw event exports and private IP details out of GitHub.

## 1. Deploy Wazuh

Follow the current official Quickstart because supported OS releases and package versions change: https://documentation.wazuh.com/current/quickstart.html

1. Create an Ubuntu Server VM for the Wazuh all-in-one deployment.
2. Follow the official installation assistant instructions for your Ubuntu release.
3. Record the manager address and dashboard URL in a private notebook.
4. In the dashboard, open Agents > Deploy new agent and generate the command for each endpoint.
5. Install the generated agent on your Windows and Ubuntu VMs.
6. Confirm both agents show Active before generating test events.

Validation means you can identify each agent and see its expected endpoint events in the Wazuh dashboard. An installed agent alone is not enough.

## 2. Start Splunk with Docker

From SOC-Lab/splunk:

```bash
cp .env.example .env
# Edit .env and set a unique strong SPLUNK_PASSWORD.
docker compose up -d
docker compose ps
docker compose logs -f splunk
```

Open http://localhost:8000 and sign in as admin with the password in your private .env file. Initial startup can take several minutes.

Stop without deleting indexed data:

```bash
docker compose down
```

Remove the persistent lab data too (destructive):

```bash
docker compose down -v
```

Do not expose ports 8089 or 9997 to an untrusted network. The compose file uses persistent Docker volumes for Splunk state.

## 3. Generate synthetic events

From the repository root:

```bash
python SOC-Lab/samples/generate_events.py
```

The output is synthetic practice data, not real endpoint telemetry. Import it into a dedicated lab index and set the correct sourcetype. Then run the searches in splunk/queries.spl individually.

SPL field names vary by input method and sourcetype. Inspect the imported events and adjust field names as needed. A query is validated only when it returns expected rows and a benign/negative test behaves as expected.

## 4. Validate Windows auditing

Inside the disposable Windows VM, review the PowerShell scripts before running them. Run as Administrator only in that VM. Verify policy settings with:

```powershell
auditpol /get /category:*
```

Confirm expected event IDs appear in Event Viewer before exporting. Sanitise exported data before using it in reports; never upload raw Security.evtx or unredacted logs.

## 5. Evidence required before marking complete

- Wazuh: dashboard screenshot showing both agents Active and a timestamped event.
- Windows: audit policy verification and a sanitised event record.
- Splunk: results for all eight searches and three tested alert examples.
- ATT&CK: mapping rationale tied to observed behaviour, with confidence and limitations.
- Incident reports: evidence IDs, timestamps, analyst actions and disposition; simulated scenarios remain labelled simulated.
- Portfolio: screenshots with usernames, IPs, tokens and other sensitive details redacted.

A running container or installed package does not prove end-to-end telemetry. Validate the complete path from event generation to SIEM search result.
