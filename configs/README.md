# configs/

## Purpose

Example/template configuration files for every component in this project.
**Every file here is a template with placeholder values** — never real
hostnames, credentials, or tokens. Copy to the real (untracked) path
documented in the corresponding `docs/setup/` guide, then fill in real
values there.

## Layout

```
configs/
  packetdevil/
    config.example.yaml    # app config template -> /etc/packetdevil/config.yaml
    packetdevil.service    # systemd unit -> /etc/systemd/system/packetdevil.service
  suricata/
    suricata.yaml.example  # capture/output config template -> /etc/suricata/suricata.yaml
  tzsp2pcap/
    tzsp2pcap.conf.example # tzsp2pcap runtime config template
    tzsp2pcap.service      # systemd unit -> /etc/systemd/system/tzsp2pcap.service
  routeros/
    mirror-port.rsc.example # RouterOS mirror config template, see docs/setup/01-...
```

## Rule

If you add a new config template here, confirm the real (filled-in) path
it's copied to is covered by [.gitignore](../.gitignore), and link the
template from the relevant `docs/setup/` step.

## See also

- [docs/setup/](../docs/setup/)
- [docs/reference/](../docs/reference/)
