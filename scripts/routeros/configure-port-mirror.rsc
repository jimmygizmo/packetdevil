# Idempotent RouterOS script: enable TZSP mirror streaming to the Suricata host.
# See docs/setup/01-mikrotik-rb5009-port-mirroring.md and
# .github/instructions/routeros.instructions.md before running.
#
# Blast radius: enables continuous packet sniffing/streaming on the named
# WAN interface; consumes router CPU proportional to WAN throughput.
# Rollback: see scripts/routeros/remove-port-mirror.rsc

:local wanInterface "<WAN_INTERFACE>"
:local suricataHost "<SURICATA_HOST_IP>"

:if ([/tool sniffer get streaming-enabled] = false) do={
  /tool sniffer set streaming-enabled=yes streaming-server=$suricataHost filter-interface=$wanInterface
  /tool sniffer start
  :log info "packetdevil: enabled TZSP sniffer streaming to $suricataHost"
} else={
  :log info "packetdevil: sniffer streaming already enabled, skipping"
}
