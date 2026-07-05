#!/usr/bin/env python3
"""
list-git-aliases-and-custom-scripts.py - Python port of list-git-aliases-and-custom-scripts.sh
Prints custom scripts found in ~/.custom-scripts and lists git aliases.
"""

import os
import sys
import subprocess
from shutil import which

# Ensure UTF-8 stdout/stderr to avoid Windows console encoding errors when printing emojis
try:
    sys.stdout.reconfigure(encoding='utf-8')
    sys.stderr.reconfigure(encoding='utf-8')
except Exception:
    try:
        import io
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
        sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')
    except Exception:
        pass

ALIAS_VERSION = "1.0.2"


def detect_home():
    # Try WSL detection
    try:
        if os.path.exists('/proc/version'):
            with open('/proc/version', 'r', encoding='utf-8', errors='ignore') as f:
                ver = f.read().lower()
            if 'microsoft' in ver:
                # Ask Windows for %USERPROFILE% and convert with wslpath if available
                try:
                    out = subprocess.run(['cmd.exe', '/c', 'echo', '%USERPROFILE%'], capture_output=True, text=True, check=True)
                    win_profile = out.stdout.strip().replace('\r', '')
                    wslpath = which('wslpath')
                    if wslpath:
                        conv = subprocess.run([wslpath, '-u', win_profile], capture_output=True, text=True, check=False)
                        if conv.stdout:
                            return conv.stdout.strip()
                    # fallback: try a crude transform
                    return win_profile.replace('\\', '/')
                except Exception:
                    pass
    except Exception:
        pass

    # MSYS / Git Bash on Windows
    try:
        import platform
        uname = platform.uname().system
        if uname.startswith('MINGW') or uname.startswith('MSYS'):
            return os.environ.get('USERPROFILE', os.path.expanduser('~'))
    except Exception:
        pass

    # Default
    return os.environ.get('HOME') or os.path.expanduser('~')


def list_custom_scripts(home_dir):
    # Repository scripts (the bin folder where this script lives)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_custom_dir = script_dir  # repository .custom-scripts/bin

    print("========================================")
    print(" Repository Custom Scripts")
    print("========================================")
    if os.path.isdir(repo_custom_dir):
        # Group files by base name (without extension)
        script_groups = {}
        for entry in os.listdir(repo_custom_dir):
            path = os.path.join(repo_custom_dir, entry)
            if os.path.isfile(path):
                # Skip this script itself
                if os.path.abspath(path) == os.path.abspath(__file__):
                    continue
                # Get base name without extension
                base_name = os.path.splitext(entry)[0]
                if base_name not in script_groups:
                    script_groups[base_name] = []
                script_groups[base_name].append(entry)
        
        if script_groups:
            # Show deduplicated scripts, preferring .py files
            for base_name in sorted(script_groups.keys()):
                variants = script_groups[base_name]
                # Prefer .py file if it exists, otherwise show first variant
                py_file = next((f for f in variants if f.endswith('.py')), None)
                if py_file:
                    print(base_name)
                elif variants:
                    print(base_name)
        else:
            print("(no scripts found in repository bin)")
    else:
        print("Repository custom scripts directory not found:")
        print(repo_custom_dir)

    # Also list user custom scripts (previous behaviour)
    user_custom_dir = os.path.join(home_dir, '.custom-scripts')
    print()
    print("========================================")
    print(" User Custom Scripts")
    print("========================================")
    if os.path.isdir(user_custom_dir):
        items = []
        for entry in os.listdir(user_custom_dir):
            path = os.path.join(user_custom_dir, entry)
            if os.path.isfile(path):
                items.append(entry)
        if items:
            for name in sorted(items):
                print(name)
        else:
            print("(no scripts found in user custom-scripts)")
    else:
        print("Custom scripts directory not found:")
        print(user_custom_dir)


def show_git_aliases():
    print()
    print("========================================")
    print(" Git Aliases")
    print("========================================")
    git = which('git') or which('git.exe')
    if not git:
        print("git not found on PATH")
        return
    try:
        proc = subprocess.run([git, 'config', '--show-origin', '--get-regexp', r'^alias\.'], capture_output=True, text=True, check=False)
        if proc.returncode == 0 and proc.stdout.strip():
            print(proc.stdout.strip())
        else:
            print("No aliases found")
    except Exception as e:
        print("Error listing git aliases:", e)


def main():
    print("")
    print(f"🔍   ToolShed {ALIAS_VERSION} — Reveals Git Alias' and Custom Scripts")
    print("───────────────────────────────────────────────────────────────")

    home = detect_home()
    list_custom_scripts(home)
    show_git_aliases()

    print("")
    print("🔍   ToolShed finished")
    print("───────────────────────────────────────────────────────────────")


if __name__ == '__main__':
    main()
