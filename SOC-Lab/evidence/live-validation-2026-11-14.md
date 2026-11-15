# Historical Wazuh check — 2026-11-14

This is the initial host-side check, not the current deployment status. At that time Wazuh containers were running under Ubuntu WSL and agent ID 001 appeared Active. The Windows browser later showed `ERR_CONNECTION_REFUSED` because WSL had stopped while idle.

The verified cause, persistent WSL idle-timeout fix, current service status, and remaining SOC lab work are in [live-validation-2026-11-15.md](live-validation-2026-11-15.md).
