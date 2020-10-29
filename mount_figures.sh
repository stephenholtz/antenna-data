#!/bin/bash
mkdir -p ~/figures/
# via brew install s3fs
s3fs antenna-fs:/figures ~/figures
