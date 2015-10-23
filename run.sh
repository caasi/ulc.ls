#!/bin/sh -x
PS4='$(date "+%s.%N ($LINENO) + ")'
#cat ./test/00-and.ulc | ./parse.ls
cat ./test/00-and.ulc | ./parse.ls | ./interpret.ls
echo
#cat ./test/01-not.ulc | ./parse.ls
cat ./test/01-not.ulc | ./parse.ls | ./interpret.ls
echo
#cat ./test/02-inc.ulc | ./parse.ls
cat ./test/02-inc.ulc | ./parse.ls | ./interpret.ls
echo
#cat ./test/03-add.ulc | ./parse.ls
cat ./test/03-add.ulc | ./parse.ls | ./interpret.ls
echo
#cat ./test/04-inf.ulc | ./parse.ls
cat ./test/04-inf.ulc | ./parse.ls | ./interpret.ls
