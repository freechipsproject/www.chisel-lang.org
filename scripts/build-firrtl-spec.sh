#!/usr/bin/env bash

# Force pdflatex to set the /date based on the date at which the
# current commit was authored. This lets you build an old version of
# the FIRRTL specification, but keep historical dates.
AUTHOR_EPOCH=`git log --pretty=format:"%at"`
export SOURCE_DATE_EPOCH=$AUTHOR_EPOCH FORCE_SOURCE_DATE=1

# Build the FIRRTL spec, using a Makefile if one exists. Otherwise,
# use latexmk to build it (using latexmk should be slightly more
# efficient than a blind 3x run of pdflatex).
if [ -f Makefile ]; then
  make
else
  latexmk -pdf spec.tex
fi
