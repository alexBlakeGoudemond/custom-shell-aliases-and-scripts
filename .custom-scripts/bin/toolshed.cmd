@ECHO OFF
SETLOCAL
:: toolshed.cmd - shim to run toolshed.py with either python or py
SET SCRIPT=%~dp0toolshed.py
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
