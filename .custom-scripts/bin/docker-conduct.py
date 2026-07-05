#!/usr/bin/env python3
"""
docker-conduct.py - Docker Compose Conductor (Python port of docker-conduct.sh)
Usage: docker-conduct.py [-p PROJECT] [-f COMPOSE_FILE] [-c]

This script wraps `docker compose` to bring projects up/down and checks
for existing containers using the Compose project label.
"""

import argparse
import os
import subprocess
import sys
from shutil import which

ALIAS_VERSION = "1.0.0"


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def project_exists(pname):
    if not pname:
        pname = os.path.basename(os.getcwd())
    docker = which("docker")
    if not docker:
        eprint("docker not found on PATH")
        return False
    try:
        result = subprocess.run([
            docker,
            "ps",
            "-a",
            "-f",
            f"label=com.docker.compose.project={pname}",
            "--format",
            "{{.ID}}",
        ], capture_output=True, text=True, check=False)
        return bool(result.stdout.strip())
    except Exception:
        return False


def main(argv):
    parser = argparse.ArgumentParser(description="Dockerissimo - Docker Compose Conductor 🎶")
    parser.add_argument("-p", dest="project", help="Specify the Docker Compose project name")
    parser.add_argument("-f", dest="compose", default="docker-compose.yml", help="Path to docker-compose file")
    parser.add_argument("-c", dest="cease", action="store_true", help="Cease the playing (docker compose down)")

    args = parser.parse_args(argv)

    compose_file = args.compose
    project_name = args.project or "dockerissimo-default-container-group"
    command = "down" if args.cease else "up"

    print("")
    print(f"🐋  Dockerissimo {ALIAS_VERSION} — Docker Compose Conductor 🎶")
    print("───────────────────────────────────────────────────────────────")

    if not os.path.isfile(compose_file):
        eprint(f"❌ Docker Compose file '{compose_file}' not found!")
        sys.exit(1)

    docker = which("docker")
    if not docker:
        eprint("docker not found on PATH")
        sys.exit(1)

    compose_cmd = [docker, "compose", "-f", compose_file]
    if project_name:
        compose_cmd.extend(["-p", project_name])

    try:
        if command == "up":
            if project_exists(project_name):
                print("⚠️ Project already exists! Will not start again.")
            else:
                print("🎵 Dockerissimo is conducting: composing project...")
                subprocess.run(compose_cmd + ["up", "-d", "--build"], check=True)
                print("✅ Project is up and running!")
        else:
            if project_exists(project_name):
                print("✋ Dockerissimo is ceasing the playing...")
                subprocess.run(compose_cmd + ["down", "--rmi", "local"], check=True)
                print("✅ Project stopped and removed!")
            else:
                print("🤔 could not find container to stop")
    except subprocess.CalledProcessError as exc:
        eprint("Command failed:", exc)
        sys.exit(1)

    print("")
    print("🐋  Dockerissimo finished 🎶")
    print("───────────────────────────────────────────────────────────────")


if __name__ == "__main__":
    main(sys.argv[1:])
