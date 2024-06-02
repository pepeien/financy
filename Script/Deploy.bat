@echo off

del 

..\Bin\Deployer\CQtDeployer.exe -confFile ../Deploy.json

powershell Compress-Archive ../Bin/Deploy/* ../Bin/financy-win-64x.zip -Force

rmdir /s /q "../Bin/Deploy"