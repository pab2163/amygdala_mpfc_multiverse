#!/bin/bash

mkdir errFiles
mkdir outFiles
for f in *.err; do mv "$f" errFiles/; done
for f in *.out; do mv "$f" outFiles/; done
