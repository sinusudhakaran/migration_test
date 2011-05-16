echo off
echo **********************************************************
echo *  This batch file copies the updates for Practice,      *
echo *  Books, and Notes to the "FilesForWebsite_BUpgrade"    *
echo *  folder on the Product drive.                          *
echo **********************************************************
REM setlocal
setlocal EnableDelayedExpansion
REM Check release folder
set DirRelease=%CD%
echo Release Folder = %DirRelease%
if not exist "%DirRelease%" echo The release folder doesn't exist! 
if not exist "%DirRelease%" echo Press CTRL+C to terminate this Batch File. 
if not exist "%DirRelease%" pause
if exist "%DirRelease%" echo Is this the correct release folder? 
if exist "%DirRelease%" echo If not, press CTRL+C to terminate this Batch File and edit "DirRelease". 
if exist "%DirRelease%" pause
REM Check for bkupgcor.dll
if not exist "%DirRelease%\bkupgcor.dll" echo Copy bkupgcor.dll to %DirRelease% before continuing!
if not exist "%DirRelease%\bkupgcor.dll" pause
REM Check for bkinstall.exe
if not exist "%DirRelease%\bkinstall.exe" echo Copy bkinstall.exe to %DirRelease% before continuing!
if not exist "%DirRelease%\bkinstall.exe" pause
REM Deployment folder
set DirDeploy=\\banklink-fp\product\FilesForWebsite_BUpgrade
echo Deploy Folder = %DirDeploy%
REM Check that FilesForWebsite_BUpgrade folder exists
if not exist "%DirDeploy%" echo **********************************************************
if not exist "%DirDeploy%" echo *                                                        *
if not exist "%DirDeploy%" echo *  The delpoyment folder doesn't exist.                  *
if not exist "%DirDeploy%" echo *  Press press CTRL + C to terminate this Batch File.    *
if not exist "%DirDeploy%" echo *                                                        *
if not exist "%DirDeploy%" echo **********************************************************
REM subfolder variables
set DirPracticeUpdateAU="%DirDeploy%\AU\"
set DirPracticeUpdateNZ="%DirDeploy%\NZ\"
set DirPracticeUpdateUK="%DirDeploy%\UK\"
REM Delete Practice update folders
if exist "%DirPracticeUpdateAU%" echo Delete AU subfolder...
if exist "%DirPracticeUpdateAU%" Del "%DirPracticeUpdateAU%" /F
if exist "%DirPracticeUpdateAU%" echo Delete NZ subfolder...
if exist "%DirPracticeUpdateNZ%" Del "%DirPracticeUpdateNZ%" /F
if exist "%DirPracticeUpdateAU%" echo Delete UK subfolder...
if exist "%DirPracticeUpdateUK%" Del "%DirPracticeUpdateUK%" /F
REM Create the folder structure
echo "Creating deployment folders..."
md "%DirPracticeUpdateAU%"
md "%DirPracticeUpdateNZ%"
md "%DirPracticeUpdateUK%"
REM Copy Practice updates
copy "%DirRelease%\Prac_Update_AU\setup_update_au.exe" "%DirPracticeUpdateAU%\setup_update_au.exe"
copy "%DirRelease%\Prac_Update_NZ\setup_update_nz.exe" "%DirPracticeUpdateNZ%\setup_update_nz.exe"
copy "%DirRelease%\Prac_Update_UK\setup_update_uk.exe" "%DirPracticeUpdateUK%\setup_update_uk.exe"
REM Copy Books updates
copy "%DirRelease%\Books_Update_AU\setup_update_books.exe" "%DirPracticeUpdateAU%\setup_update_books.exe"
copy "%DirRelease%\Books_Update_NZ\setup_update_books.exe" "%DirPracticeUpdateNZ%\setup_update_books.exe"
copy "%DirRelease%\Books_Update_UK\setup_update_books.exe" "%DirPracticeUpdateUK%\setup_update_books.exe"
REM Copy Notes updates
copy "%DirRelease%\BNotes Install Update\setupbnotes_update_AU.exe" "%DirPracticeUpdateAU%\setupbnotes_update_AU.exe"
copy "%DirRelease%\BNotes Install Update\setupbnotes_update_NZ.exe" "%DirPracticeUpdateNZ%\setupbnotes_update_NZ.exe"
copy "%DirRelease%\BNotes Install Update\setupbnotes_update_UK.exe" "%DirPracticeUpdateUK%\setupbnotes_update_UK.exe"
REM upgrade dll
copy "%DirRelease%\bkupgcor.dll" "%DirPracticeUpdateAU%\bkupgcor.dll"
copy "%DirRelease%\bkupgcor.dll" "%DirPracticeUpdateNZ%\bkupgcor.dll"
copy "%DirRelease%\bkupgcor.dll" "%DirPracticeUpdateUK%\bkupgcor.dll"
REM Install exe
copy "%DirRelease%\bkinstall.exe" "%DirPracticeUpdateAU%\bkinstall.exe"
copy "%DirRelease%\bkinstall.exe" "%DirPracticeUpdateNZ%\bkinstall.exe"
copy "%DirRelease%\bkinstall.exe" "%DirPracticeUpdateUK%\bkinstall.exe"
REM %BNOTESDIR%\Parsebnotes.dll ???
REM %RELEASEDIR%\parsebk5win.dll ???
REM xcopy "folder\*" "Path\folder" /i /s /y
pause
