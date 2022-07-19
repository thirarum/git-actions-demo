#!/bin/bash

TESTDIR=~/testdir
TESTFILE=~/testdir/testout.txt

runuser -l wlsqa -c "mkdir -p $TESTDIR"
runuser -l wlsqa -c "rm -rf $TESTFILE"

runuser -l wlsqa -c "echo 'java -version' &>> $TESTFILE"
runuser -l wlsqa -c "java -version &>> $TESTFILE"

runuser -l wlsqa -c "echo 'ifconfig' &>> $TESTFILE"
runuser -l wlsqa -c "ifconfig &>> $TESTFILE"

runuser -l wlsqa -c "echo 'hostname: ' &>> $TESTFILE"
runuser -l wlsqa -c "hostname -f  &>> $TESTFILE"

runuser -l wlsqa -c "echo 'Script execution is completed.'  &>> $TESTFILE"

runuser -l wlsqa -c "cat $TESTFILE"
