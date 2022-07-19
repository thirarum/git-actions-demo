#!/bin/bash

TESTDIR=/home/oracle/testdir
TESTFILE=/home/oracle/testdir/testout.txt

mkdir -p $TESTDIR
rm -rf $TESTFILE

echo "java -version" &>> $TESTFILE
java -version &>> $TESTFILE

echo "ifconfig" &>> $TESTFILE
/sbin/ifconfig &>> $TESTFILE

echo "hostname: " &>> $TESTFILE
hostname -f  &>> $TESTFILE

echo "Script execution is completed."  &>> $TESTFILE

cat $TESTFILE
