#!/bin/sh

# basic tests
#cat ./test/00-and.ulc | ./parse.ls
time cat ./test/00-and.ulc | ./parse.ls | ./interpret.ls
#cat ./test/01-not.ulc | ./parse.ls
time cat ./test/01-not.ulc | ./parse.ls | ./interpret.ls
#cat ./test/02-inc.ulc | ./parse.ls
time cat ./test/02-inc.ulc | ./parse.ls | ./interpret.ls
#cat ./test/03-add.ulc | ./parse.ls
time cat ./test/03-add.ulc | ./parse.ls | ./interpret.ls
#cat ./test/04-inf.ulc | ./parse.ls
time cat ./test/04-inf.ulc | ./parse.ls | ./interpret.ls

# fibs
time cat ./test/fibs.ulc | ./parse.ls | ./interpret.ls
