@echo off
setlocal enabledelayedexpansion
rem Build esa-snap-s1tbx-gpt on Windows: unattended SNAP install -> prune -> wire conda JDK.
rem The installer (.exe) is fetched by conda-build as `source` into %SRC_DIR%\installer\.

set "SNAP_DEST=%PREFIX%\opt\snap"

rem --- locate the installer .exe -------------------------------------------
set "INSTALLER="
for %%f in ("%SRC_DIR%\installer\*.exe") do set "INSTALLER=%%f"
if not defined INSTALLER (
  echo No installer .exe found in %SRC_DIR%\installer\ & exit /b 1
)

rem --- 1. unattended install ----------------------------------------------
rem install4j: -q unattended, -dir target, -overwrite non-interactive.
"%INSTALLER%" -q -dir "%SNAP_DEST%" -overwrite
if errorlevel 1 exit /b 1
if not exist "%SNAP_DEST%\bin\gpt.exe" ( echo gpt.exe missing & exit /b 1 )

rem --- 2. license capture for meta.yaml license_file ----------------------
mkdir "%SRC_DIR%\installer_licenses" 2>nul
copy /y "%SNAP_DEST%\LICENSE.txt" "%SRC_DIR%\installer_licenses\" >nul 2>&1
copy /y "%SNAP_DEST%\THIRDPARTY_LICENSES.txt" "%SRC_DIR%\installer_licenses\" >nul 2>&1

rem --- 3. prune optical toolboxes ONLY ------------------------------------
rem NOTE: unlike Linux/macOS, we KEEP SNAP's bundled JRE on Windows, because
rem conda-forge has no Windows openjdk to depend on. SNAP uses its own JRE here.
rmdir /s /q "%SNAP_DEST%\s2tbx"  2>nul
rmdir /s /q "%SNAP_DEST%\s3tbx"  2>nul
rmdir /s /q "%SNAP_DEST%\smostbx" 2>nul

rem --- 4. register installer-provided clusters that survived pruning -------
set "CLUSTERS_FILE=%SNAP_DEST%\etc\snap.clusters"
set "CLUSTERS_TMP=%SNAP_DEST%\etc\snap.clusters.tmp"
del "%CLUSTERS_TMP%" >nul 2>&1
type nul > "%CLUSTERS_TMP%"
if exist "%CLUSTERS_FILE%" (
  for /f "usebackq delims=" %%c in ("%CLUSTERS_FILE%") do (
    if not "%%c"=="s2tbx" if not "%%c"=="s3tbx" if not "%%c"=="smostbx" (
      if exist "%SNAP_DEST%\%%c" echo %%c>> "%CLUSTERS_TMP%"
    )
  )
) else (
  for %%c in (etc ide platform bin snap microwavetbx s1tbx rstb) do (
    if exist "%SNAP_DEST%\%%c" echo %%c>> "%CLUSTERS_TMP%"
  )
)
move /y "%CLUSTERS_TMP%" "%CLUSTERS_FILE%" >nul
echo Registered SNAP clusters:
type "%CLUSTERS_FILE%"

rem --- 6. activate/deactivate hooks ---------------------------------------
mkdir "%PREFIX%\etc\conda\activate.d"   2>nul
mkdir "%PREFIX%\etc\conda\deactivate.d" 2>nul
copy /y "%RECIPE_DIR%\activate.bat"   "%PREFIX%\etc\conda\activate.d\esa-snap-s1tbx-gpt.bat"   >nul
copy /y "%RECIPE_DIR%\deactivate.bat" "%PREFIX%\etc\conda\deactivate.d\esa-snap-s1tbx-gpt.bat" >nul

rem --- 7. NOTICE ----------------------------------------------------------
mkdir "%PREFIX%\share\esa-snap-s1tbx-gpt" 2>nul
(
  echo esa-snap-s1tbx-gpt %SNAP_VERSION% - unofficial community repackaging of ESA SNAP.
  echo Subset of the official ESA SNAP "sentinel" distribution; optical s2tbx/s3tbx
  echo and the bundled JRE removed; SNAP source unmodified. GPL-3.0.
  echo Corresponding source: https://github.com/senbox-org  ^(tag matching %SNAP_VERSION%^).
  echo NOT affiliated with or endorsed by ESA.
) > "%PREFIX%\share\esa-snap-s1tbx-gpt\NOTICE.txt"

echo esa-snap-s1tbx-gpt build complete: %SNAP_DEST%
