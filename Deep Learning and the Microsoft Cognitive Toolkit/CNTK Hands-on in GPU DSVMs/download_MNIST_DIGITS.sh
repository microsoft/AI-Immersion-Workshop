#!/bin/bash

cd /dsvm/tools/DIGITS
/anaconda/bin/python -m digits.download_data mnist ~/mnist
cd -
