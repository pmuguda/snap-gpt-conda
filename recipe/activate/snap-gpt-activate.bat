@echo off
rem snap-gpt: expose the real SNAP bin\ (snap.exe + gpt.exe) and pin the JVM.
set "SNAP_HOME=%CONDA_PREFIX%\opt\snap"
set "PATH=%SNAP_HOME%\bin;%PATH%"

rem Force SNAP's install4j launchers to use this env's JDK.
rem conda-forge openjdk on Windows installs under %CONDA_PREFIX%\Library.  # TODO verify
if defined JAVA_HOME (
  set "INSTALL4J_JAVA_HOME_OVERRIDE=%JAVA_HOME%"
) else (
  set "INSTALL4J_JAVA_HOME_OVERRIDE=%CONDA_PREFIX%\Library"
)
