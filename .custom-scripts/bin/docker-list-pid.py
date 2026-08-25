#!/usr/bin/env python3
"""
docker-list-pid.py
List PIDs used by Docker (containers + daemon/runtime processes).
Outputs CSV lines: pid, name, purpose
Also prints a copyable kill command for the detected PIDs.

Works on Linux/WSL/macOS/Windows (best-effort). If docker CLI is available, container PIDs are discovered via `docker inspect`.
"""

import os
import sys
import subprocess
import shlex
import platform
from shutil import which

ALIAS_VERSION = "1.0.0"

# Ensure UTF-8
try:
    sys.stdout.reconfigure(encoding='utf-8')
    sys.stderr.reconfigure(encoding='utf-8')
except Exception:
    pass

KEYWORDS = [
    'dockerd', 'docker', 'containerd', 'containerd-shim', 'runc', 'docker-proxy', 'com.docker', 'docker-desktop'
]


def run(cmd):
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, check=False)
        return proc.returncode, proc.stdout.strip(), proc.stderr.strip()
    except FileNotFoundError:
        return 127, '', f'command not found: {cmd[0]}'


def gather_containers():
    """Return list of dicts with keys: pid (int or None), name, purpose"""
    docker = which('docker') or which('docker.exe')
    results = []
    if not docker:
        return results

    # Get containers
    code, out, err = run([docker, 'ps', '-a', '--format', '{{.ID}}||{{.Names}}||{{.Image}}'])
    if code != 0 or not out:
        return results

    for line in out.splitlines():
        parts = line.split('||')
        if not parts:
            continue
        cid = parts[0].strip()
        name = parts[1].strip() if len(parts) > 1 else cid
        image = parts[2].strip() if len(parts) > 2 else ''

        # Inspect to get PID and optionally command
        pid = None
        cmd_repr = ''
        c, o, e = run([docker, 'inspect', '--format', "{{.State.Pid}}||{{json .Config.Cmd}}||{{json .Config.Entrypoint}}", cid])
        if c == 0 and o:
            try:
                # Format: PID||["/bin/sh","-c","..."]||null
                s1 = o.split('||')
                pid_str = s1[0].strip()
                if pid_str.isdigit() and int(pid_str) > 0:
                    pid = int(pid_str)
                # try to compose a short command/entrypoint
                if len(s1) > 1 and s1[1] and s1[1] != 'null':
                    cmd_repr = s1[1]
                elif len(s1) > 2 and s1[2] and s1[2] != 'null':
                    cmd_repr = s1[2]
            except Exception:
                pass

        purpose = image
        if cmd_repr:
            purpose = f"{image} {cmd_repr}"

        results.append({'pid': pid, 'name': name, 'purpose': purpose, 'container': cid})

    return results


def gather_host_procs():
    """Find docker-related processes on the host. Return list of dicts pid,name,purpose"""
    is_win = platform.system().lower().startswith('win') or os.name == 'nt'
    seen = {}
    results = []

    if is_win:
        # Use tasklist CSV output
        code, out, err = run(['tasklist', '/fo', 'csv', '/nh'])
        if code != 0 or not out:
            return results
        # CSV lines: "Image Name","PID","Session Name","Session#","Mem Usage"
        for line in out.splitlines():
            cols = [c.strip('"') for c in line.split(',')]
            if len(cols) < 2:
                continue
            image = cols[0]
            pid = cols[1]
            lname = image.lower()
            if any(k in lname for k in KEYWORDS):
                try:
                    ival = int(pid)
                except Exception:
                    continue
                purpose = 'docker-related process'
                # Friendly name mapping
                lname_no_ext = os.path.splitext(image)[0].lower()
                if 'dockerd' in lname_no_ext:
                    purpose = 'docker daemon'
                elif 'containerd' in lname_no_ext:
                    purpose = 'container runtime'
                elif 'runc' in lname_no_ext:
                    purpose = 'OCI runtime'
                results.append({'pid': ival, 'name': image, 'purpose': purpose})
    else:
        # POSIX: use ps
        code, out, err = run(['ps', '-eo', 'pid,comm,args'])
        if code != 0 or not out:
            return results
        for line in out.splitlines():
            line = line.strip()
            if not line:
                continue
            # split into pid, comm, args
            try:
                pid_str, comm_and_rest = line.split(None, 1)
            except ValueError:
                continue
            try:
                pid = int(pid_str)
            except Exception:
                continue
            # comm is first token of comm_and_rest
            comm = comm_and_rest.split(None, 1)[0]
            lower = (comm + ' ' + comm_and_rest).lower()
            if any(k in lower for k in KEYWORDS):
                purpose = 'docker-related process'
                if 'dockerd' in lower:
                    purpose = 'docker daemon'
                elif 'containerd-shim' in lower or 'containerd' in lower:
                    purpose = 'container runtime / shim'
                elif 'runc' in lower:
                    purpose = 'OCI runtime'
                elif 'docker-proxy' in lower:
                    purpose = 'docker-proxy'
                results.append({'pid': pid, 'name': comm, 'purpose': purpose})

    return results


def main():

    print("")
    print(f"🐋   DockerListPID {ALIAS_VERSION} — List all instances related to Docker 🐳")
    print("───────────────────────────────────────────────────────────────")

    conts = gather_containers()
    procs = gather_host_procs()

    # Consolidate by pid
    entries = {}

    for c in conts:
        pid = c.get('pid')
        name = c.get('name')
        purpose = c.get('purpose') or 'container'
        if pid is None:
            # container PID not available (e.g., Docker Desktop on Windows): show as N/A with container id
            key = f"container:{c.get('container')[:12]}"
            entries[key] = {'pid': None, 'name': name, 'purpose': purpose}
        else:
            entries[int(pid)] = {'pid': int(pid), 'name': name, 'purpose': purpose}

    for p in procs:
        pid = p.get('pid')
        if pid in entries:
            # prefer container name if present, but ensure purpose contains both
            existing = entries[pid]
            existing_name = existing.get('name') or p.get('name')
            existing_purpose = existing.get('purpose', '')
            # merge purposes
            merged = existing_purpose
            if p.get('purpose') and p.get('purpose') not in merged:
                merged = f"{merged}; {p.get('purpose')}" if merged else p.get('purpose')
            entries[pid] = {'pid': pid, 'name': existing_name, 'purpose': merged}
        else:
            entries[pid] = {'pid': pid, 'name': p.get('name'), 'purpose': p.get('purpose')}

    # Sort entries: numeric PIDs first, then others
    numeric_items = [v for k,v in entries.items() if isinstance(k, int) or (isinstance(v.get('pid'), int))]
    other_items = [v for k,v in entries.items() if not isinstance(k, int) and not isinstance(v.get('pid'), int)]

    numeric_items_sorted = sorted(numeric_items, key=lambda x: x['pid'])

    final = numeric_items_sorted + other_items

    # Print CSV header and rows
    out_lines = []
    out_lines.append('pid, name, purpose')
    pid_list = []
    for it in final:
        pid = it.get('pid')
        name = it.get('name') or ''
        purpose = it.get('purpose') or ''
        if pid is None:
            out_lines.append(f'N/A, {name}, {purpose}')
        else:
            out_lines.append(f'{pid}, {name}, {purpose}')
            pid_list.append(str(pid))

    print('\n'.join(out_lines))

    # Print a copyable kill command
    is_win = platform.system().lower().startswith('win') or os.name == 'nt'
    if pid_list:
        if is_win:
            # taskkill supports multiple /PID flags
            flags = ' '.join(f'/PID {p}' for p in pid_list)
            cmd = f'taskkill /F {flags}'
        else:
            # Prefer graceful TERM, but show force option as well
            cmd = 'sudo kill ' + ' '.join(pid_list)
            cmd_force = 'sudo kill -9 ' + ' '.join(pid_list)
            cmd = f"{cmd}  # or force: {cmd_force}"
        print('\nCopy/paste to kill these PIDs:')
        print(cmd)
    else:
        print('\nNo numeric PIDs discovered to kill. If using Docker Desktop on Windows, container PIDs are inside a VM and not visible to the host.')

    print()
    print(f"🐋   DockerListPID finished 🐳")
    print("───────────────────────────────────────────────────────────────")


if __name__ == '__main__':
    main()
