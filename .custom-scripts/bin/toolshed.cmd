@ECHO OFF
SETLOCAL
:: toolshed.cmd - shim to run list-git-aliases-and-custom-scripts.py with either python or py
SET SCRIPT=%~dp0list-git-aliases-and-custom-scripts.py
WHERE python >nul 2>&1
IF %ERRORLEVEL%==0 (
  python "%SCRIPT%" %*
) ELSE (
  WHERE py >nul 2>&1
  IF %ERRORLEVEL%==0 (
    py "%SCRIPT%" %*
  ) ELSE (
    ECHO Python not found on PATH. Please install Python or add it to PATH.
    EXIT /B 1
  )
)
ENDLOCAL
