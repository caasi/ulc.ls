#!/bin/sh
cat ./test/00-id.ulc | ./parser.ls
cat ./test/01-nested.ulc | ./parser.ls
cat ./test/02-true.ulc | ./parser.ls
cat ./test/03-capture.ulc | ./parser.ls
cat ./test/04-and.ulc | ./parser.ls
cat ./test/05-not.ulc | ./parser.ls
