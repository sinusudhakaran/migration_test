echo off
echo **********************************************************
echo *  This batch file copies Practice files to the Testing  *
echo *  folder on the Product drive.                          *
echo *  \\banklink-fp\Product\BK5\Testing\<Version>\          *
echo **********************************************************
setlocal EnableDelayedExpansion
REM Get version number to use as folder name
for %%* in (.) do set ThisDir=%%~xn*
set VersionText=%ThisDir:~14%
echo is this the correct version? %VersionText%
REM Check testing folder
set DirTesting=\\banklink-fp\Product\BK5\Testing\%VersionText%
echo Testing Folder = %DirTesting%
if exist "%DirTesting%" echo The release folder already exist! 
pause
REM md %DirTesting%
xcopy "bk*" "%DirTesting%" /i /y
xcopy "Debug\*" "%DirTesting%\Debug" /i /y
xcopy "Migrator.exe" "%DirTesting%" /i /y