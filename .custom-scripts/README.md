# README Custom Script

This repository provides lightweight shims and Python ports of small helper scripts so they work across Bash, WSL and PowerShell.

Summary of what’s included (repo/.custom-scripts/bin):
- toolshed            (extensionless shim for Git Bash / WSL)
- docker-conduct      (extensionless shim for Git Bash / WSL)
- toolshed.cmd        (PowerShell/Windows shim)
- docker-conduct.cmd  (PowerShell/Windows shim)
- list-git-aliases-and-custom-scripts.py
- docker-conduct.py

Quick setup (fresh clone)
1. Clone the repo and note its absolute path.
2. Ensure the repository "repo-root/.custom-scripts/bin" directory is on your PATH.
   - Recommended: set CUSTOM_SCRIPTS to the repo .custom-scripts folder and add %CUSTOM_SCRIPTS%\bin to PATH (Windows), or export PATH in your shell for Git Bash:
     export PATH="/c/path/to/repo/.custom-scripts/bin:$PATH"
3. Make the Unix shims executable (Git Bash / WSL):
   chmod +x /c/path/to/repo/.custom-scripts/bin/toolshed \
             /c/path/to/repo/.custom-scripts/bin/docker-conduct
4. Ensure Python is installed and "python" or "py" is on PATH (Windows) and that "python3" or "python" is on PATH for Bash.

How to run
- Git Bash / WSL: run extensionless shims directly:
  toolshed
  docker-conduct -p myproject -f docker-compose.yml
- PowerShell / cmd.exe: the .cmd shims invoke the Python scripts, so run:
  toolshed
  docker-conduct
  (or: bash toolshed if you prefer the bash shim)
- You can also run the Python scripts explicitly:
  python ./.custom-scripts/bin/list-git-aliases-and-custom-scripts.py

Notes and troubleshooting
- After editing system PATH on Windows, restart Git Bash / PowerShell to pick up changes.
- If "which toolshed" returns nothing in Git Bash, ensure the exact folder 
  /c/path/to/repo/.custom-scripts/bin exists in $PATH (Git Bash shows POSIX-style paths).
- If Python emoji or Unicode fails on Windows consoles, run PowerShell/Windows Terminal with UTF-8 or update PYTHONUTF8=1 in environment.
- Keep files saved with LF line endings for the shims; Windows .cmd files use CRLF.

If you want an automated setup step (append to ~/.bashrc or create the Windows env var), open an issue or run the provided setup helper.
