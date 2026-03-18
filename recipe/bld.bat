setlocal EnableDelayedExpansion

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
FOR %%F IN (activate deactivate) DO (
    IF NOT EXIST %PREFIX%\etc\conda\%%F.d MKDIR %PREFIX%\etc\conda\%%F.d
    COPY %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\refnx_%%F.bat
)

%PYTHON% -m build -w -n -v -x -Cbuilddir=builddir
for /f %%f in ('dir /b /S .\dist') do (
    %PYTHON% -m pip install %%f
    if %ERRORLEVEL% neq 0 exit 1
)

if errorlevel 1 exit 1
