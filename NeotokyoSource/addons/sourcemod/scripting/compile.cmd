@echo off
setlocal

:Start
:: Prompt for the input file name
set /p FILENAME=Enter the file name (without extension): 

:: Ensure only one .sp extension is added
if not "%FILENAME:~-3%"==".sp" (
    set FILENAME=%FILENAME%.sp
)

:: Check if the file exists
if not exist "%FILENAME%" (
    echo File "%FILENAME%" not found!
    timeout /t 2 >nul
    goto Start
)

:: Generate a timestamp for uniqueness
for /f "delims=" %%b in ('powershell -command "(Get-Date).ToString('yyyyMMdd_HHmmss')"') do set TIMESTAMP=%%b

:: Set log file name using the timestamp to avoid overwriting
set LOG_FILE=compile_log_%TIMESTAMP%.txt

:: Run compile.exe in the background and log output to the log file
echo Running compile.exe with "%FILENAME%"...
start "" /B compile.exe "%FILENAME%" > "%LOG_FILE%" 2>&1

:: Wait for compile.exe to finish processing
timeout /t 5 >nul

:: Forcefully kill any lingering compile.exe processes to prevent issues
taskkill /F /IM compile.exe >nul 2>&1

:: Simulate pressing Enter on the compile.exe process to close the prompt
powershell -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class SendKeys { [DllImport(\"user32.dll\")] public static extern bool PostMessage(IntPtr hWnd, uint msg, int wParam, int lParam); }';[SendKeys]::PostMessage([System.Diagnostics.Process]::GetProcessesByName('compile')[0].MainWindowHandle, 0x100, 0x0D, 0)" >nul 2>&1

:: Wait briefly to ensure that Enter has been sent
timeout /t 1 >nul

:: Loop start function
goto Start

endlocal
