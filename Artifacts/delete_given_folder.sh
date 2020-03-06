#!/bin/bash
for PATH in "$@"
do
  echo $PATH
  /bin/rm -rf $PATH
done
