# MITRE ATT&CK detection coverage

This is a starter mapping for the five simulated case studies. Technique mapping is an analytical hypothesis, not a finding of maliciousness.

| Scenario | Candidate technique | Evidence needed | Data source |
|---|---|---|---|
| Password guessing | [T1110 — Brute Force](https://attack.mitre.org/techniques/T1110/) | Repeated failures, source, targeted accounts, time window | Windows 4625 / Linux auth |
| Phishing attachment | [T1566.001 — Spearphishing Attachment](https://attack.mitre.org/techniques/T1566/001/) | Email headers, attachment hash, delivery evidence | Email gateway / EDR |
| Phishing link | [T1566.002 — Spearphishing Link](https://attack.mitre.org/techniques/T1566/002/) | Message, URL, browser and identity telemetry | Email / proxy / identity |
| PowerShell execution | [T1059.001 — PowerShell](https://attack.mitre.org/techniques/T1059/001/) | Script block, parent process, user, command context | PowerShell 4104 / Sysmon |
| Malicious file execution | [T1204.002 — Malicious File](https://attack.mitre.org/techniques/T1204/002/) | File hash, origin, execution telemetry, reputation | EDR / Sysmon |
| Valid account anomaly | [T1078 — Valid Accounts](https://attack.mitre.org/techniques/T1078/) | Successful login plus corroborating unusual context | 4624 / identity logs |
| Privileged group change | [T1098 — Account Manipulation](https://attack.mitre.org/techniques/T1098/) | Group membership event, approval, account owner | 4728 / 4732 |

## Analyst rules

1. Prefer the narrowest technique supported by evidence.
2. Record the data source and event IDs used to make the mapping.
3. Separate observed facts from interpretation.
4. Include confidence (low / medium / high) and explain why.
5. Re-check technique IDs and names against the current ATT&CK website before interviews or publication.
