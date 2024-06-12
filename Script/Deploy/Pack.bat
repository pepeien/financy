@echo off

### Building
cmake "../../" -B "../../build" -G "Visual Studio 16 2019" ^
-DCMAKE_BUILD_TYPE="Release"

cmake --build "../../build" --target ALL_BUILD --config "Release"

### Packing
CQtDeployer -confFile ".\Windows\Config.json"
msbuild ./Windows/Packer/Windows.wixproj /property:Configuration=Release

### Clean up
rmdir /s /q "..\..\Deploy\win-64x"
copy ".\Windows\Packer\bin\Release\Windows.msi" "..\..\Deploy\win-64x.msi"

@echo on