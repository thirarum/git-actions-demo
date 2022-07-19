#!/bin/bash

wget https://raw.githubusercontent.com/thirarum/git-actions-demo/patch-1/myscript.sh
chmod +x myscript.sh
runuser -l oracle -c "./myscript.sh"
