@echo off

"../Bin/Deployer/CQtDeployer.exe" -confFile "../Deploy.json"
powershell Compress-Archive "../Bin/Deploy/*" "../Bin/win-64x.zip" -Force
rmdir /s /q "../Bin/Deploy"