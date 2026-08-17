# packetdevil

Enterprise-grade Network IDS/IPS for home or small-business infrastructure
— DIY, very high security. Mirrors all WAN traffic from a MikroTik RB5009
(RouterOS) to a dedicated Linux box running Suricata for deep packet
inspection; a custom Python app turns severe Suricata alerts into
temporary RouterOS firewall blocks and Telegram notifications.

## Start here

- **AI agents (Copilot, Claude, etc.): read [AGENTS.md](AGENTS.md) first.**
  It's the canonical entry point and links to everything else.
- **Humans:** [docs/README.md](docs/README.md) is the full documentation
  index. New to the project? Start with
  [docs/architecture/overview.md](docs/architecture/overview.md), then
  follow [docs/setup/00-prerequisites.md](docs/setup/00-prerequisites.md)
  through `06`.

## What's here

| Path | Contents |
|---|---|
| [AGENTS.md](AGENTS.md) | Agent operating instructions (repo map, safety rules, conventions). |
| [docs/](docs/) | All project documentation — architecture, setup, reference, operations, scenarios. |
| [vendor/tzsp2pcap/](vendor/tzsp2pcap/) | Vendored + patched copy of `tzsp2pcap` (TZSP mirror decapsulation). |
| [src/packetdevil/](src/packetdevil/) | The Python app: Suricata alert triage, RouterOS blocking, Telegram alerts. |
| [configs/](configs/) | Example/template configs for every component (never real secrets). |
| [scripts/](scripts/) | Helper scripts (Linux shell, RouterOS `.rsc`), documented and idempotent. |

## Core components

RB5009 (RouterOS) → mirrors WAN traffic (TZSP) → `tzsp2pcap` → `dummy`
interface → Suricata (IDS) → `eve.json` → `packetdevil` (Python) →
RouterOS firewall API (temporary blocks) + Telegram (severe-alert
notifications). Full diagram and rationale:
[docs/architecture/overview.md](docs/architecture/overview.md).

## License

See [LICENSE](LICENSE).

