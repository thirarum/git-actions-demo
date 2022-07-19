#!/bin/bash

export USER_HOME=/home/oracle

wget https://raw.githubusercontent.com/thirarum/git-actions-demo/patch-1/myscript.sh
cp myscript.sh $USER_HOME
chown oracle:oracle $USER_HOME/myscript.sh
chmod +x $USER_HOME/myscript.sh
runuser -l oracle -c "sh $USER_HOME/myscript.sh"
