# IR-001 — Repeated authentication failures (simulated)

**Status:** Closed — training exercise  
**Severity:** Medium (provisional)  
**Asset:** WIN-LAB01 (fictional Windows endpoint)  
**Account:** lab.user (fictional)  
**Source:** 192.0.2.55 (TEST-NET-1 documentation address)  
**ATT&CK candidate:** [T1110 — Brute Force](https://attack.mitre.org/techniques/T1110/)

## Executive summary
A burst of six failed logons was followed by one successful logon for the same fictional account and source. This is consistent with password guessing followed by a possible successful authentication. The sequence alone does not establish that the account was compromised.

## Evidence and timeline
- 18 to 8 minutes before collection: six synthetic Windows 4625 events.
- 6 minutes before collection: one synthetic 4624 event.
- Source and account fields are generated training values, not observed network activity.
- Evidence source: `samples/synthetic-windows-events.json`.

## Triage and analysis
1. Confirm the 4625 and 4624 events belong to the same account, host, and source.
2. Inspect logon type, authentication package, workstation, and status/substatus codes.
3. Compare the source with VPN, jump-host, and known scanner ranges.
4. Check whether the successful login was followed by 4672, 4688, remote access, or unusual account activity.
5. Contact the account owner through an approved channel.

## Containment (if corroborated)
- Follow the organisation's identity incident process; consider disabling or resetting the account only with authorisation.
- Revoke active sessions and tokens where supported.
- Block a source only after confirming it is not shared infrastructure or a legitimate service.
- Preserve relevant authentication and endpoint logs.

## Recovery and prevention
Enforce MFA, rate limiting / lockout policy appropriate to the environment, strong unique passwords, and alerting on failure bursts followed by success.

## Analyst conclusion
**Disposition:** Suspicious pattern; compromise unconfirmed.  
**Confidence:** Medium that a password-guessing pattern occurred in the synthetic dataset; no claim about a real attacker.  
**Follow-up:** Validate source context and inspect post-authentication activity.
