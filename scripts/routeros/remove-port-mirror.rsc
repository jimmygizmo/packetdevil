# Rollback for scripts/routeros/configure-port-mirror.rsc
# Blast radius: stops mirror traffic reaching the Suricata host (detection blind spot until re-enabled)

/tool sniffer set streaming-enabled=no
/tool sniffer stop
:log info "packetdevil: disabled TZSP sniffer streaming"
