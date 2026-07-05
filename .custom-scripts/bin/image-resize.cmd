@ECHO OFF
SETLOCAL
:: image-resize.cmd - shim to run image-resize.py with either python or py
SET SCRIPT=%~dp0image-resize.py
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
