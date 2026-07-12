#!/bin/sh
# esa-snap-s1tbx-gpt: put the real SNAP bin/ (with snap + gpt) on PATH and pin the JVM.
#
# We deliberately expose the REAL binaries (not a wrapper shim) so that tools
# like pyroSAR, which locate SNAP by finding `snap` on PATH and then resolving
# realpath + ../.. to derive SNAP_HOME, see the correct install directory.
export SNAP_HOME="${CONDA_PREFIX}/opt/snap"

case ":${PATH}:" in
  *":${SNAP_HOME}/bin:"*) : ;;                      # already present
  *) export PATH="${SNAP_HOME}/bin:${PATH}" ;;
esac

# Force SNAP's install4j launchers (gpt, snap) to use THIS env's JDK.
# openjdk's own activate.d sets JAVA_HOME (sorted before us: 'openjdk' < 'snap');
# fall back to the conda-forge openjdk location if it isn't set yet.
if [ -n "${JAVA_HOME}" ]; then
  export INSTALL4J_JAVA_HOME="${JAVA_HOME}"
elif [ -d "${CONDA_PREFIX}/lib/jvm" ]; then
  export INSTALL4J_JAVA_HOME="${CONDA_PREFIX}/lib/jvm"
else
  export INSTALL4J_JAVA_HOME="${CONDA_PREFIX}"
fi
export INSTALL4J_JAVA_HOME_OVERRIDE="${INSTALL4J_JAVA_HOME}"
