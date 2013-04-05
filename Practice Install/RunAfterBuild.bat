echo off

REM creates a mapping to the current drive (for UNC paths)
pushd "%~dp0"

setlocal EnableDelayedExpansion

REM Get version number to use as folder name
for /f "delims=" %%x in (version.txt) do set VersionText=%%x

REM get Current Date 
For /F "tokens=1 delims=/" %%A in ('Date /t') do Set Day=%%A
For /F "tokens=2 delims=/" %%A in ('Date /t') do Set Month=%%A
For /F "tokens=3 delims=/" %%A in ('Date /t') do Set Year=%%A

set DirTesting=\\banklink-fp\Product\BK5\Testing\%VersionText% TPR
Set ReleaseFolder=BK%Year%Release %VersionText% (%Year%Dev) 
set DirRelease=\\banklink-fp\Product\BK5\%ReleaseFolder%

:MAINMENU
CLS
echo ****************************************************************************
echo *  Build Version
echo *    %VersionText%
echo *
echo *  Testing Folder
echo *    %DirTesting%
echo *
echo *  Release Folder
echo *    %DirRelease%
echo *
echo *  Choose one of the following :
echo *  1 - Copies the Build to Testing (no installs)                         
echo *  2 - Copies the Build to Testing (includes installs)
echo *  3 - Copies the Build to Release 
echo *  4 - Burns Practice CD
echo *  5 - Burns Books CD
echo *  X - Exit
echo ****************************************************************************
choice /C 12345X /N /M "Select 1,2,3,4,5 or X?"
echo %ERRORLEVEL%

if %ERRORLEVEL%==1 GOTO TESTINGNOINST
if %ERRORLEVEL%==2 GOTO TESTINGINST
if %ERRORLEVEL%==3 GOTO RELEASE
if %ERRORLEVEL%==4 GOTO BURNPRACTICE
if %ERRORLEVEL%==5 GOTO BURNBOOKS
if %ERRORLEVEL%==6 GOTO ENDBATCH
GOTO MAINMENU


:TESTINGNOINST
REM Check testing folder
if exist "%DirTesting%" goto TESTFOLDERERROR
xcopy "bk*" "%DirTesting%" /i /y
xcopy "Debug\*" "%DirTesting%\Debug" /i /y
xcopy "Migrator.exe" "%DirTesting%" /i /y
xcopy "BooksIO.dll" "%DirTesting%" /i /y
xcopy "ByteArrayConverter.dll" "%DirTesting%" /i /y
xcopy "Muddler.*" "%DirTesting%" /i /y
xcopy "ResetPractice.exe" "%DirTesting%" /i /y
GOTO MAINMENU


:TESTINGINST
REM Check testing folder
if exist "%DirTesting%" goto TESTFOLDERERROR
xcopy "bk*" "%DirTesting%" /i /y
xcopy "Debug\*" "%DirTesting%\Debug" /i /y
xcopy "Migrator.exe" "%DirTesting%" /i /y
xcopy "BooksIO.dll" "%DirTesting%" /i /y
xcopy "ByteArrayConverter.dll" "%DirTesting%" /i /y
xcopy "Muddler.*" "%DirTesting%" /i /y
xcopy "ResetPractice.*" "%DirTesting%" /i /y
xcopy "Books_Update_AU\*" "%DirTesting%\Books_Update_AU" /i /y /e
xcopy "Books_Update_NZ\*" "%DirTesting%\Books_Update_NZ" /i /y /e
xcopy "Books_Update_UK\*" "%DirTesting%\Books_Update_UK" /i /y /e
xcopy "BooksInstall_AU\*" "%DirTesting%\BooksInstall_AU" /i /y /e
xcopy "BooksInstall_NZ\*" "%DirTesting%\BooksInstall_NZ" /i /y /e
xcopy "BooksInstall_UK\*" "%DirTesting%\BooksInstall_UK" /i /y /e
xcopy "Prac_Update_AU\*" "%DirTesting%\Prac_Update_AU" /i /y /e
xcopy "Prac_Update_NZ\*" "%DirTesting%\Prac_Update_NZ" /i /y /e
xcopy "Prac_Update_UK\*" "%DirTesting%\Prac_Update_UK" /i /y /e
xcopy "PracticeInstall_AU\*" "%DirTesting%\PracticeInstall_AU" /i /y /e
xcopy "PracticeInstall_NZ\*" "%DirTesting%\PracticeInstall_NZ" /i /y /e
xcopy "PracticeInstall_UK\*" "%DirTesting%\PracticeInstall_UK" /i /y /e
GOTO MAINMENU


:RELEASE
if exist "%DirRelease%" goto RELEASEFOLDERERROR
xcopy "*" "%DirRelease%" /i /y /e
GOTO MAINMENU


:BURNPRACTICE
%SystemRoot%\explorer.exe /select,Practice cd
GOTO MAINMENU


:BURNBOOKS
%SystemRoot%\explorer.exe /select,Books cd
GOTO MAINMENU


:ENDBATCH
popd
Exit


:TESTFOLDERERROR
echo The testing folder already exist! 
pause 
popd
Exit


:RELEASEFOLDERERROR
echo The release folder already exist! 
pause 
popd
Exit