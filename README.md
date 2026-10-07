<div align="center">

# 🛡️ Log-Guardian

### Offline-first log **integrity** monitor + **forensic heuristics** — does this log's timeline, rhythm, and "voice" look physically plausible?

[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat-square&logo=python&logoColor=white)](https://www.python.org/)
[![CLI](https://img.shields.io/badge/Interface-CLI-121011?style=flat-square&logo=gnubash&logoColor=white)](#)
[![Cryptography](https://img.shields.io/badge/Tamper--Evident-SHA--256_hash_chain-6E40C9?style=flat-square&logo=letsencrypt&logoColor=white)](#)
[![Docker](https://img.shields.io/badge/Docker-ready-2496ED?style=flat-square&logo=docker&logoColor=white)](#)
[![Offline First](https://img.shields.io/badge/Offline-first-success?style=flat-square)](#)

</div>

---

## Overview

**Log-Guardian** scans log files for signs of tampering and produces a forensic-style report — entirely offline, with no backend or third-party service. It combines two layers:

1. **Evidence Protector** — the integrity core: streaming scans of huge files, multi-format timestamp parsing, suspicious time-gap detection, and output in terminal, CSV, or JSON.
2. **Ghost Protocol** — a forensic-heuristics layer that asks whether a log's *timeline is plausible*, whether its *rhythm or character "DNA" shifted* versus a baseline, and whether *filesystem receipts contradict the narrative*.

## 🔍 What It Detects

| Signal | Meaning |
|--------|---------|
| `TIME_REVERSAL` / `TIME_GAP` | Timestamps go backwards, or an implausible gap appears |
| `SYNTHETIC_REGULARITY` / `RHYTHM_DRIFT` | Entries look machine-generated, or the cadence shifts |
| `LOG_DNA_SHIFT` / `ENTROPY_SPIKE` | Character distribution changes unexpectedly vs a baseline |
| `INJECTION_PRIMITIVE` | Patterns consistent with log injection |
| `FS_TIME_MISMATCH` | File timestamps disagree with the log's own narrative |
| `FS_TRUNCATION` / `FS_REWRITE` / `FS_MTIME_BACKWARDS` | Filesystem receipts reveal truncation, rewrites, or mtime regressions |

## ✨ Features

- 📂 **Streaming scans** of large files without loading them into memory
- 🕰️ **Multi-format timestamp** parsing with configurable gap thresholds
- 🧬 **Baseline + analyze + watch** modes (`ghost baseline`, `ghost analyze`, `ghost watch`)
- 🧾 **Receipts** — file size/mtime/ctime with optional head/tail SHA-256 sampling; best-effort process & netstat snapshots
- 🔗 **Portable commitments & anchors** — tamper-evident artifacts witnessable and verifiable later
- 📤 **Output formats** — terminal, CSV, JSON
- 🐳 **Dockerized** with smoke tests, plus standalone build scripts (PowerShell & Bash)

## 🚀 Quickstart

```bash
# 1. set up a virtual environment
python3 -m venv .venv
source .venv/bin/activate      # Windows: .venv\Scripts\activate

# 2. install
pip install -e .
pip install -r requirements.txt   # optional: test/quality tooling

# 3. scan a log for suspicious gaps
evidence_protector scan --file ./sample.log --gap 300 --format terminal

# 4. run the forensic layer
ghost baseline --file ./sample.log
ghost analyze  --file ./sample.log
ghost watch    --file ./sample.log
```

### Docker

```bash
docker compose up --build
# or run the smoke test:
./scripts/docker-smoke-test.sh
```

## 🗂️ Project Layout

```
src/evidence_protector/
├── cli.py              # command-line entry point
├── core.py             # integrity scan engine
├── ghost_protocol.py   # forensic orchestration
├── ghost_narrative.py  # timeline/rhythm/DNA heuristics
├── ghost_receipts.py   # filesystem + process receipts
├── ghost_correlate.py  # cross-signal correlation
├── ghost_commitments.py# portable witnessable commitments
├── ghost_canary.py · ghost_watch.py · ghost_selftest.py
docs & specs:  GHOST_PROTOCOL_SCOPE.md · GHOST_PROTOCOL_THREAT_MODEL.md ·
               KEY_MANAGEMENT.md · SECURITY_OPERATIONS.md
```

## 📚 Design Docs

- **[GHOST_PROTOCOL_SCOPE.md](GHOST_PROTOCOL_SCOPE.md)** — what's in and out of scope
- **[GHOST_PROTOCOL_THREAT_MODEL.md](GHOST_PROTOCOL_THREAT_MODEL.md)** — adversary model
- **[KEY_MANAGEMENT.md](KEY_MANAGEMENT.md)** · **[SECURITY_OPERATIONS.md](SECURITY_OPERATIONS.md)**

---

<div align="center">

Built by **[Sayak Satpathi](https://github.com/sayaksatpathi)** · Offline-first forensic tooling.

</div>
