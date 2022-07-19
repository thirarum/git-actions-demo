#!/bin/bash

TESTDIR=~/testdir
TESTFILE=~/testdir/testout.txt

runuser -l oracle -c "mkdir -p $TESTDIR"
runuser -l oracle -c "rm -rf $TESTFILE"

runuser -l oracle -c "echo 'java -version' &>> $TESTFILE"
runuser -l oracle -c "java -version &>> $TESTFILE"

runuser -l oracle -c "echo 'ifconfig' &>> $TESTFILE"
runuser -l oracle -c "ifconfig &>> $TESTFILE"

runuser -l oracle -c "echo 'hostname: ' &>> $TESTFILE"
runuser -l oracle -c "hostname -f  &>> $TESTFILE"

runuser -l oracle -c "echo 'Script execution is completed.'  &>> $TESTFILE"

runuser -l oracle -c "cat $TESTFILE"
