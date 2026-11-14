# IR-005 — Unexpected privileged group membership (simulated)

**Status:** Closed — training exercise  
**Severity:** High if unauthorised change to a privileged group is confirmed  
**ATT&CK candidate:** [T1098 — Account Manipulation](https://attack.mitre.org/techniques/T1098/)

## Executive summary
A synthetic Windows event indicates a user was added to a local security-enabled group (Event 4732). The lab sample uses fictional identities. The event may reflect approved administration; the analyst must validate the group, actor, target, and change record.

## Evidence and triage
- Windows Security Event 4732 (local security-enabled group) or 4728 (global security-enabled group).
- Subject account, member SID/name, target group, host, timestamp, and event record ID.
- Change ticket, administrator session, endpoint management activity, and relevant 4624 / 4672 events.
- Whether the group grants local admin, remote access, backup, or domain-level privileges.

## Investigation steps
1. Resolve the target group SID/name and determine its effective permissions.
2. Identify who performed the change and whether the account was expected to administer the host.
3. Correlate with logon session ID and change-management records.
4. Check for subsequent privileged logons, new services, scheduled tasks, and remote access.
5. Record whether the change was approved, benign but undocumented, or unauthorised.

## Containment (if unauthorised)
- Obtain incident lead approval before removing membership.
- Preserve event logs and relevant endpoint telemetry.
- Disable or restrict the initiating account only when supported by evidence and policy.
- Review other systems for the same account or group change.

## Recovery and prevention
Use privileged access management, just-in-time elevation, separate admin accounts, approval workflows, and alerts on sensitive group changes.

## Analyst conclusion
**Disposition:** Privilege change observed in synthetic telemetry; unauthorised escalation not established.  
**Confidence:** Medium that a group membership change occurred in the sample; low regarding malicious intent.  
**Follow-up:** Confirm group privilege, administrator identity, and approved change ticket.
