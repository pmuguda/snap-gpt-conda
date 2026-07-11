#!/bin/sh
# esa-snap-s1tbx-gpt: undo what the activate hook set.
if [ -n "${SNAP_HOME}" ]; then
  # Remove "${SNAP_HOME}/bin" from PATH wherever it appears.
  PATH="$(printf '%s' ":${PATH}:" | sed -e "s#:${SNAP_HOME}/bin:#:#g" -e 's#^:##' -e 's#:$##')"
  export PATH
fi
unset SNAP_HOME
unset INSTALL4J_JAVA_HOME
unset INSTALL4J_JAVA_HOME_OVERRIDE
