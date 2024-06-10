@echo off

CQtDeployer -confFile "./Windows/Config.json"
msbuild ./Windows/Packer/Windows.wixproj /property:Configuration=Release
rmdir /s /q "..\..\Deploy/win-64x"
copy ".\Windows\Packer\bin\Release\Windows.msi" "..\..\Deploy\win-64x.msi"

@echo on