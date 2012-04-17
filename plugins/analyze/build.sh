#!/bin/bash
# This is a simple script that compiles the plugin using the free Flex SDK on Linux/Mac.
# Learn more at http://developer.longtailvideo.com/trac/wiki/PluginsCompiling

FLEXPATH=/Applications/Adobe\ Flash\ Builder\ 4/sdks/4.0.0


echo "Compiling awesm and GA plugin..."
"$FLEXPATH"/bin/mxmlc ./Analyze.as -sp ./ -o ./analyze-jwplayer.swf \
  -library-path+=../../lib \
  -library-path+=./ \
  -load-externs ../../lib/jwplayer-5-classes.xml \
  -use-network=false
