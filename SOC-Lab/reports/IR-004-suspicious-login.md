# IR-004 — Anomalous successful login (simulated tabletop)

**Status:** Closed — tabletop exercise  
**Severity:** Medium (provisional)  
**ATT&CK candidate:** [T1078 — Valid Accounts](https://attack.mitre.org/techniques/T1078/)

## Executive summary
A fictional user account signs in at an unusual time and from a source not previously associated with the user. A location or time anomaly is not proof of account compromise; VPNs, travel, mobile networks, and shared egress can explain it.

## Evidence required
- Successful authentication event (Windows 4624 or identity-provider sign-in).
- Source IP, device ID, user agent, MFA result, conditional access result, and session ID.
- User's known travel / VPN / shift context through approved channels.
- Post-login actions: mailbox rules, file downloads, privilege changes, token creation, and access to sensitive systems.

## Triage
1. Validate the sign-in event and identify the authentication method.
2. Compare device compliance, MFA, risk signals, and prior sign-in baseline.
3. Contact the user using a known-good channel.
4. Inspect activity after authentication for unusual resource access.
5. Determine whether the session was legitimate, suspicious, or confirmed compromised.

## Containment (if corroborated)
Revoke sessions and refresh tokens, reset credentials, review MFA registrations, and apply conditional access controls according to policy. Preserve identity logs before retention expires.

## Recovery and prevention
Require phishing-resistant MFA for sensitive roles, review risky sign-in policies, and tune anomaly detections to account for VPN and travel patterns.

## Analyst conclusion
**Disposition:** Anomalous sign-in; compromise unconfirmed.  
**Confidence:** Low until user and session activity are corroborated.  
**Follow-up:** Validate with the account owner and inspect downstream actions.
