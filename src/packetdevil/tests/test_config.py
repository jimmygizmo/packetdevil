import yaml

from packetdevil.config import load_config


def test_load_config_applies_env_overrides(tmp_path, monkeypatch):
    config_path = tmp_path / "config.yaml"
    config_path.write_text(
        yaml.dump(
            {
                "eve_json_path": "/var/log/suricata/eve.json",
                "routeros": {"host": "192.0.2.1", "username": "file-user", "password": "file-pass"},
                "telegram": {"bot_token": "file-token", "chat_id": "file-chat"},
                "blocking": {"max_severity_to_block": 2, "ttl_minutes": 30},
            }
        )
    )
    monkeypatch.setenv("PACKETDEVIL_ROUTEROS_PASSWORD", "env-pass")

    config = load_config(config_path)

    assert config.routeros.username == "file-user"
    assert config.routeros.password == "env-pass"
    assert config.blocking.ttl_minutes == 30
    assert config.telegram.enabled is True
