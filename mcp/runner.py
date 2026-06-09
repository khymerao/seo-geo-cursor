#!/usr/bin/env python3
"""Run upstream connector scripts as subprocesses."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONNECTORS = ROOT / "scripts" / "connectors"


def run_script(
    script: str,
    args: list[str],
    timeout: int = 120,
    stdin_data: str | None = None,
) -> dict:
    path = CONNECTORS / script
    if not path.is_file():
        return {"ok": False, "error": f"Missing script: {path}"}
    cmd = [sys.executable, str(path), *args]
    try:
        proc = subprocess.run(
            cmd,
            input=stdin_data,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
    except subprocess.TimeoutExpired:
        return {"ok": False, "error": f"Timeout after {timeout}s", "script": script}
    if proc.returncode != 0:
        return {
            "ok": False,
            "error": proc.stderr.strip() or f"exit {proc.returncode}",
            "script": script,
            "stdout": proc.stdout.strip(),
        }
    out = proc.stdout.strip()
    try:
        data = json.loads(out)
    except json.JSONDecodeError:
        data = out
    return {"ok": True, "data": data}
