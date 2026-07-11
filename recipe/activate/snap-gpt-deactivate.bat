@echo off
rem snap-gpt: undo snap-gpt-activate.bat (best-effort PATH restore).
set "INSTALL4J_JAVA_HOME_OVERRIDE="
if defined SNAP_HOME call set "PATH=%%PATH:%SNAP_HOME%\bin;=%%"
set "SNAP_HOME="
