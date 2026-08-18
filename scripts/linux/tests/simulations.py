#!/usr/bin/env python3
"""Unified command-line runner for the Linux test/simulation host workflows.

This is the first-pass replacement for the ad hoc shell scripts under
scripts/linux/tests/. It focuses on the exact real-world commands already used
in the repo and adds a setup phase that checks and repairs prerequisites for
both internal and external test hosts.

The script intentionally does not yet try to support several variations of each
simulation; it keeps the commands simple and uses constants for the obvious
values the project already documents in the shell scripts.
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Iterable, Sequence


# ---------------------------------------------------------------------------
# Constants used by the project-defined simulations.
# ---------------------------------------------------------------------------

INTERNAL_TOR_DOMAIN = "thisisatest.onion"
INTERNAL_TOR_RESOLVER = "1.1.1.1"
INTERNAL_CRYPTO_DOMAIN = "xmr.2miners.com"
INTERNAL_CRYPTO_RESOLVER = "1.1.1.1"
INTERNAL_PASSWORD_URL = "http://httpbun.com/basic-auth/user/pass"
INTERNAL_SCAMMER_HOST = "boot.net.anydesk.com"
INTERNAL_SCAMMER_PORT = 443
DEFAULT_EXTERNAL_SCAN_TARGET = "203.0.113.10"
SETUP_DIR = Path("/tmp/packetdevil-test-hosts")
PUBLIC_IP_STORE_PATH = SETUP_DIR / "external" / "public_ip.txt"


# ---------------------------------------------------------------------------
# Output helpers.
# ---------------------------------------------------------------------------

SEPARATOR = "- - - - - - - - - - - - - - - - - - - -"


def print_blank_lines(count: int = 1) -> None:
    for _ in range(count):
        print()


def print_step(title: str) -> None:
    print_blank_lines(1)
    print(f"{title}")


def print_separator() -> None:
    print(SEPARATOR)


def print_result_block(command: str, output: str) -> None:
    print_step(f"🚀 Running: {command}")
    print_separator()
    if not output.strip():
        print("<NO-OUTPUT-RESULTED>")
    else:
        print(output.strip())
    print_separator()


# ---------------------------------------------------------------------------
# Command helpers.
# ---------------------------------------------------------------------------


def run_command(command: Sequence[str] | str, *, shell: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        shell=shell,
        text=True,
        capture_output=True,
        check=False,
    )


def run_privileged_apt(args: Sequence[str]) -> subprocess.CompletedProcess[str]:
    """Runs apt-get via sudo when needed."""
    if os.geteuid() == 0:
        return run_command(["apt-get", *args])
    return run_command(["sudo", "apt-get", *args])


def ensure_program(program: str, package: str | None = None) -> bool:
    """Check for a required program and install it when missing."""
    if shutil.which(program):
        print(f"✅ {program} is available")
        return True

    print(f"⚠️ {program} is missing")
    if not package:
        print(f"❌ No package mapping available for {program}; cannot install automatically.")
        return False

    if os.geteuid() != 0:
        print(f"⚠️ Running without root; using sudo to install {package}")

    print(f"🔧 Installing: {package}")
    apt_result = run_privileged_apt(["update"])
    if apt_result.returncode != 0:
        print(apt_result.stderr.strip() or apt_result.stdout.strip() or "apt-get update failed")
        return False

    install_result = run_privileged_apt(["install", "-y", package])
    if install_result.returncode != 0:
        print(install_result.stderr.strip() or install_result.stdout.strip() or f"install failed for {package}")
        return False

    print(f"✅ Installed {package}")
    return True


def ensure_directory(path: Path, *, mode: int = 0o700) -> Path:
    path.mkdir(parents=True, exist_ok=True)
    os.chmod(path, mode)
    return path


def ensure_file(path: Path, *, content: str, mode: int = 0o600) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.exists():
        path.write_text(content, encoding="utf-8")
    os.chmod(path, mode)
    return path


def ensure_host_setup(host_type: str) -> None:
    """Make the internal/external host prerequisites and dirs correct."""
    host_type = host_type.lower().strip()
    if host_type not in {"internal", "external"}:
        raise ValueError(f"Unsupported host type: {host_type!r}")

    print_step(f"🧰 {host_type.title()} host setup")

    package_map = {
        "internal": {"curl": "curl", "dig": "dnsutils", "openssl": "openssl"},
        "external": {"nmap": "nmap", "dig": "dnsutils"},
    }[host_type]

    all_ok = True
    for program, package in package_map.items():
        if not ensure_program(program, package):
            all_ok = False

    work_dir = ensure_directory(SETUP_DIR / host_type)
    marker = ensure_file(
        work_dir / "host-type.txt",
        content=f"{host_type}\n",
        mode=0o600,
    )

    if all_ok:
        print(f"✅ {host_type.title()} host prerequisites are ready")
    else:
        print(f"⚠️ {host_type.title()} host setup completed with missing prerequisites; review the output above")

    print(f"📁 Setup directory verified: {work_dir}")
    print(f"📄 Marker file verified: {marker}")


def is_valid_ipv4(value: str) -> bool:
    parts = value.split(".")
    if len(parts) != 4:
        return False
    try:
        return all(0 <= int(part) <= 255 for part in parts if part.isdigit())
    except ValueError:
        return False


def read_stored_public_ip(path: Path = PUBLIC_IP_STORE_PATH) -> str | None:
    if not path.exists():
        return None
    try:
        value = path.read_text(encoding="utf-8").strip()
    except OSError:
        return None
    return value or None


def write_public_ip(value: str, path: Path = PUBLIC_IP_STORE_PATH) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(f"{value.strip()}\n", encoding="utf-8")
    os.chmod(path, 0o600)


def resolve_public_ip(explicit_ip: str | None = None) -> str:
    if explicit_ip:
        candidate = explicit_ip.strip()
        if not is_valid_ipv4(candidate):
            raise ValueError(f"--public-ip value is not a valid IPv4 address: {explicit_ip!r}")
        write_public_ip(candidate)
        print_step("🌐 External public IP configured")
        print(f"✅ Using public IP from --public-ip: {candidate}")
        print(f"💾 Stored at: {PUBLIC_IP_STORE_PATH}")
        return candidate

    stored_ip = read_stored_public_ip()
    if stored_ip:
        print_step("🌐 External simulation target")
        print(f"✅ Using stored public IP: {stored_ip}")
        return stored_ip

    while True:
        print_step("🌐 External simulation target")
        print("No stored public IP was found for external simulations.")
        try:
            value = input("Enter your public external IP address: ").strip()
        except EOFError:
            raise RuntimeError("No public IP found and no --public-ip was supplied. Please provide one.")
        if not value:
            print("⚠️ Empty input; please enter a valid IPv4 address.")
            continue
        if not is_valid_ipv4(value):
            print(f"⚠️ '{value}' is not a valid IPv4 address. Please try again.")
            continue
        write_public_ip(value)
        print(f"✅ Saved public IP to {PUBLIC_IP_STORE_PATH}")
        return value


# ---------------------------------------------------------------------------
# Simulation commands.
# ---------------------------------------------------------------------------


def run_internal_tor() -> int:
    command = (
        f"dig +short {INTERNAL_TOR_DOMAIN} @{INTERNAL_TOR_RESOLVER}"
    )
    print_result_block(command, run_command(command, shell=True).stdout)
    return 0


def run_internal_crypto() -> int:
    command = (
        f"dig +short {INTERNAL_CRYPTO_DOMAIN} @{INTERNAL_CRYPTO_RESOLVER}"
    )
    print_result_block(command, run_command(command, shell=True).stdout)
    return 0


def run_internal_password() -> int:
    command = (
        f"curl -su user:pass '{INTERNAL_PASSWORD_URL}'"
    )
    print_result_block(command, run_command(command, shell=True).stdout)
    return 0


def run_internal_scammer() -> int:
    command = (
        f"echo | openssl s_client -connect {INTERNAL_SCAMMER_HOST}:{INTERNAL_SCAMMER_PORT} "
        f"-servername {INTERNAL_SCAMMER_HOST}"
    )
    print_result_block(command, run_command(command, shell=True).stdout)
    return 0


def print_external_ip_reminder() -> None:
    print_step("🌐 External simulation target")
    print("📌 Using the stored public IP for this external simulation.")
    print("Remove /tmp/packetdevil-test-hosts/external/public_ip.txt to change it.")


def run_external_scan(public_ip: str | None = None) -> int:
    target = public_ip or DEFAULT_EXTERNAL_SCAN_TARGET
    command = f"nmap -sS -sV -Pn {target}"
    print_result_block(command, run_command(command, shell=True).stdout)
    return 0


def run_internal_all() -> int:
    print_step("🔒 Running all internal simulations")
    for runner in (
        run_internal_tor,
        run_internal_crypto,
        run_internal_scammer,
        run_internal_password,
    ):
        exit_code = runner()
        if exit_code != 0:
            return exit_code
    return 0


def run_external_all(public_ip: str | None = None) -> int:
    print_step("🌐 Running all external simulations")
    return run_external_scan(public_ip)


# ---------------------------------------------------------------------------
# Argument parsing and main flow.
# ---------------------------------------------------------------------------


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Run the repo's Linux test/simulation commands and repair their setup prerequisites.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    parser.add_argument("--setup", action="store_true", help="repair prerequisites and config before running simulations")

    parser.add_argument("--internal-tor", action="store_true", help="simulate outbound Tor activity from an internal test host")
    parser.add_argument("--internal-crypto", action="store_true", help="simulate outbound crypto-mining activity from an internal test host")
    parser.add_argument("--internal-scammer", action="store_true", help="simulate outbound scammer remote-control activity from an internal test host")
    parser.add_argument("--internal-password", action="store_true", help="simulate outbound cleartext password leakage from an internal test host")
    parser.add_argument("--internal-all", action="store_true", help="run all outbound simulations from an internal test host")

    parser.add_argument("--external-scan", action="store_true", help="simulate inbound port-scanning activity from an external test host")
    parser.add_argument("--external-all", action="store_true", help="run all inbound simulations from an external test host")
    parser.add_argument("--public-ip", help="store and reuse the public IPv4 address for all external simulations")

    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    internal_selected = any(
        [
            args.internal_tor,
            args.internal_crypto,
            args.internal_scammer,
            args.internal_password,
            args.internal_all,
        ]
    )
    external_selected = any([args.external_scan, args.external_all])

    if not any(
        [
            args.setup,
            internal_selected,
            external_selected,
        ]
    ):
        parser.print_help()
        return 1

    if args.setup:
        if internal_selected or not external_selected:
            ensure_host_setup("internal")
        if external_selected or not internal_selected:
            ensure_host_setup("external")

    print_step("🧪 Simulation command runner")
    print(f"✅ Setup mode: {bool(args.setup)}")

    if args.internal_all:
        return run_internal_all()

    if args.internal_tor:
        return run_internal_tor()
    if args.internal_crypto:
        return run_internal_crypto()
    if args.internal_scammer:
        return run_internal_scammer()
    if args.internal_password:
        return run_internal_password()

    if args.external_all:
        public_ip = resolve_public_ip(args.public_ip)
        print_external_ip_reminder()
        return run_external_all(public_ip)
    if args.external_scan:
        public_ip = resolve_public_ip(args.public_ip)
        print_external_ip_reminder()
        return run_external_scan(public_ip)

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        print_blank_lines(1)
        print("🛑 Interrupted by user")
        raise SystemExit(130)
