#!/bin/bash

find_command="find src -name '*.html.wml'"

eval "$find_command" |     \
    xargs perl -pi -e '/^<subject/&&($_.="<version_control_id \"\$Id\$\" />\n")'
    
eval "$find_command" |      \
    xargs svn propset svn:keywords Id

