@echo off
rem esa-snap-s1tbx-gpt: undo the activate hook (best-effort PATH restore).
set "INSTALL4J_JAVA_HOME="
set "INSTALL4J_JAVA_HOME_OVERRIDE="
if defined SNAP_HOME call set "PATH=%%PATH:%SNAP_HOME%\bin;=%%"
set "SNAP_HOME="
