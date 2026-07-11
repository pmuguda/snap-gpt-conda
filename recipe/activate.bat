@echo off
rem snap-gpt: expose the real SNAP bin\ (snap.exe + gpt.exe) and pin the JVM.
set "SNAP_HOME=%CONDA_PREFIX%\opt\snap"
set "PATH=%SNAP_HOME%\bin;%PATH%"

rem If a conda JDK is present (JAVA_HOME set by an openjdk package), use it;
rem otherwise leave it unset so SNAP's own bundled JRE (kept on Windows) is used.
if defined JAVA_HOME set "INSTALL4J_JAVA_HOME_OVERRIDE=%JAVA_HOME%"
