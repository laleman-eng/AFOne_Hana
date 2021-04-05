set BaseDir="Z:\VisualK\AFOne Hana"
set BinDir="Z:\VisualK\AFOne Hana\Bin\Debug"
set Version=2.216
call "%VS110COMNTOOLS%vsvars32.bat"

msbuild ActivoFijo.sln /t:Clean,Build  /p:Configuration="Debug SAP910 x86" /p:PlatformTarget=x86
set BUILD_STATUS=%ERRORLEVEL%
if %BUILD_STATUS%==0 GOTO Reactor
pause
EXIT

:Reactor
"C:\Program Files (x86)\Eziriz\.NET Reactor\dotNET_Reactor.exe" -project "Z:\VisualK\AFOne Hana\Bin\Debug\Activo Fijo - IFRS.nrproj" -targetfile "Z:\VisualK\AFOne Hana\Bin\Debug\Activo Fijo - IFRS.exe"
set REACTOR_STATUS=%ERRORLEVEL%
if %REACTOR_STATUS%==0 GOTO INNO
pause
EXIT

:INNO
"C:\Program Files (x86)\Inno Setup 5\iscc.exe" "Z:\VisualK\AFOne Hana\Activo Fijo dll.iss"
set INNO_STATUS=%ERRORLEVEL%
if %INNO_STATUS%==0 GOTO ARD
pause
EXIT

:ARD 
"C:\Program Files (x86)\SAP\SAP Business One SDK\Tools\AddOnRegDataGen\AddOnRegDataGen.exe" "Z:\VisualK\AFOne Hana\OutPut\AFOneSAP910x86.xml" %Version% "Z:\VisualK\AFOne Hana\OutPut\setup.exe" "Z:\VisualK\AFOne Hana\OutPut\setup.exe" "Z:\VisualK\AFOne Hana\Bin\Debug\Activo Fijo - IFRS.exe"
ECHO %ERRORLEVEL%
pause