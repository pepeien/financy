#!/bin/bash

..\Bin\Deployer\CQtDeployer -confFile ../Deploy.json

tar -czvf financy-linux-64x.tar.gz ..\Bin\Deploy\*

rm -r ..\Bin\Deploy