#!/usr/bin/env python3
"""Generate harmless synthetic SOC events for SPL practice.

No network activity, credential access, persistence, or system changes occur.
The output is fictional and suitable for importing into a disposable SIEM index.
"""
from __future__ import annotations

import csv
import json
from datetime import datetime, timedelta, timezone
from pathlib import Path

OUT = Path(__file__).resolve().parent
now = datetime.now(timezone.utc)
events = []

def add(minutes: int, event_id: int, user: str, host: str, source: str, message: str) -> None:
    events.append({
        "TimeCreated": (now - timedelta(minutes=minutes)).isoformat(),
        "EventCode": event_id,
        "TargetUserName": user,
        "Computer": host,
        "IpAddress": source,
        "Message": message,
        "Simulation": True,
    })

# Six failed attempts, then one successful sign-in from the same fictional source.
for m in (18, 16, 14, 12, 10, 8):
    add(m, 4625, "lab.user", "WIN-LAB01", "192.0.2.55", "Synthetic failed logon")
add(6, 4624, "lab.user", "WIN-LAB01", "192.0.2.55", "Synthetic successful logon; investigate context")

add(5, 4720, "new.labuser", "WIN-LAB01", "127.0.0.1", "Synthetic account creation")
add(4, 4732, "new.labuser", "WIN-LAB01", "127.0.0.1", "Synthetic local group membership change")
add(3, 4104, "lab.user", "WIN-LAB01", "127.0.0.1", "Synthetic PowerShell script block event")
add(2, 1102, "lab.admin", "WIN-LAB01", "127.0.0.1", "Synthetic audit log cleared event")

events.sort(key=lambda item: item["TimeCreated"])
json_path = OUT / "synthetic-windows-events.json"
csv_path = OUT / "synthetic-windows-events.csv"
json_path.write_text(json.dumps(events, indent=2), encoding="utf-8")
with csv_path.open("w", newline="", encoding="utf-8") as handle:
    writer = csv.DictWriter(handle, fieldnames=events[0].keys())
    writer.writeheader()
    writer.writerows(events)

print(f"Wrote {len(events)} synthetic events:")
print(f"  {json_path}")
print(f"  {csv_path}")
print("All identities, addresses, and events are fictional training data.")
