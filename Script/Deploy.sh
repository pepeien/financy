#!/bin/bash

"../Bin/Deployer/CQtDeployer" -confFile ../Deploy.json
zip -r ../Bin/linux-64x.zip ../Bin/Deploy/*
rm -r ../Bin/Deploy