# IR-002 — Suspected phishing email (simulated tabletop)

**Status:** Closed — tabletop exercise  
**Severity:** Medium (provisional; raise if credential entry or execution is confirmed)  
**ATT&CK candidates:** [T1566.001 — Spearphishing Attachment](https://attack.mitre.org/techniques/T1566/001/), [T1566.002 — Spearphishing Link](https://attack.mitre.org/techniques/T1566/002/)

## Executive summary
A fictional employee reports an unexpected message requesting urgent review of an invoice. No real email, attachment, URL, or user account is included in this exercise. The analyst must establish whether the message was delivered, clicked, opened, or used to capture credentials.

## Evidence required
- Original message with full headers, preserved in a restricted evidence store.
- Sender domain, reply-to address, sending infrastructure, subject, and delivery time.
- URL expanded and safely analysed using approved tools; do not visit suspicious links from a production endpoint.
- Attachment filename, type, and SHA-256 hash; do not execute it.
- Email gateway, proxy, DNS, browser, identity, and EDR events for the recipient.

## Triage
1. Ask the reporter not to forward the message broadly or interact with it further.
2. Search mail telemetry for other recipients and matching message IDs / hashes.
3. Determine whether the URL was visited or attachment executed.
4. Check identity logs for unusual sign-ins or MFA prompts after the reported click.
5. Distinguish a delivered phish from confirmed credential theft or endpoint compromise.

## Containment (if malicious)
- Use approved mail controls to quarantine matching messages.
- Block confirmed malicious domains / hashes through managed controls.
- If credentials were entered, reset credentials, revoke sessions, and review MFA methods under the identity response playbook.
- Isolate an endpoint only when endpoint evidence justifies it and the incident lead approves.

## Recovery and prevention
Restore affected endpoints from trusted sources if compromise is confirmed. Improve mail filtering, domain authentication, user reporting, browser protections, and phishing-resistant MFA.

## Analyst conclusion
**Disposition:** Suspected phishing; impact unknown until delivery and click telemetry are checked.  
**Confidence:** Low based on the initial report alone.  
**Follow-up:** Obtain headers and correlate mail, web, identity, and endpoint evidence.
