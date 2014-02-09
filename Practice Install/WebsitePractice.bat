echo off
echo **********************************************************
echo *  This batch file copies Practice, Books, and Notes     *
echo *  files to the "FilesForWebsite" folder on the Product  *
echo *  drive.                                                *
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
REM Deployment folder
set DirDeploy=\\myob.myobcorp.net\nzakl\Product\FilesForWebsite
echo Deploy Folder = %DirDeploy%
REM Check that FilesForWebsite_BUpgrade folder exists
if not exist "%DirDeploy%" echo **********************************************************
if not exist "%DirDeploy%" echo *                                                        *
if not exist "%DirDeploy%" echo *  The website folder doesn't exist.                     *
if not exist "%DirDeploy%" echo *  Press press CTRL + C to terminate this Batch File.    *
if not exist "%DirDeploy%" echo *                                                        *
if not exist "%DirDeploy%" echo **********************************************************
REM subfolder variables
set DirPracticeAU="%DirDeploy%\AU\"
set DirPracticeNZ="%DirDeploy%\NZ\"
set DirPracticeUK="%DirDeploy%\UK\"
REM Create the folder structure
echo "Creating deployment folders..."
if not exist "%DirPracticeAU%" md "%DirPracticeAU%"
if not exist "%DirPracticeNZ%" md "%DirPracticeNZ%"
if not exist "%DirPracticeUK%" md "%DirPracticeUK%"
REM Copy Practice 
copy "%DirRelease%\bk5win.exe" "%DirPracticeAU%\bk5win.exe" /Y
copy "%DirRelease%\bk5win.exe" "%DirPracticeNZ%\bk5win.exe" /Y
copy "%DirRelease%\bk5win.exe" "%DirPracticeUK%\bk5win.exe" /Y
REM Copy Practice Help
copy "%DirRelease%\Practice CD Files\guide_au.chm" "%DirPracticeAU%\guide.chm" /Y
copy "%DirRelease%\Practice CD Files\guide_nz.chm" "%DirPracticeNZ%\guide.chm" /Y
copy "%DirRelease%\Practice CD Files\guide_uk.chm" "%DirPracticeUK%\guide.chm" /Y
REM Copy Tutorials
copy "%DirRelease%\Practice CD Files\tutorial_au.chm" "%DirPracticeAU%\tutorial.chm" /Y
copy "%DirRelease%\Practice CD Files\tutorial_nz.chm" "%DirPracticeNZ%\tutorial.chm" /Y
REM copy "%DirRelease%\Practice CD Files\tutorial_uk.chm" "%DirPracticeUK%\tutorial.chm"
REM Copy Third Party DLLs
copy "%DirRelease%\Practice CD Files\Redist\wPDF200a.dll" "%DirPracticeAU%" /Y
copy "%DirRelease%\Practice CD Files\Redist\wPDF200a.dll" "%DirPracticeNZ%" /Y
copy "%DirRelease%\Practice CD Files\Redist\wPDF200a.dll" "%DirPracticeUK%" /Y
REM Copy Practice Install
xcopy "%DirRelease%\PracticeInstall_AU\*" "%DirPracticeAU%" /i /s /y
xcopy "%DirRelease%\PracticeInstall_NZ\*" "%DirPracticeNZ%" /i /s /y
xcopy "%DirRelease%\PracticeInstall_UK\*" "%DirPracticeUK%" /i /s /y
REM Copy BNotes
copy "%DirRelease%\bnotes.exe" "%DirPracticeAU%\bnotes.exe" /Y
copy "%DirRelease%\bnotes.exe" "%DirPracticeNZ%\bnotes.exe" /Y
copy "%DirRelease%\bnotes.exe" "%DirPracticeUK%\bnotes.exe" /Y
REM Copy Books Install
xcopy "%DirRelease%\BooksInstall_AU\setup_books.exe" "%DirPracticeAU%setup_books_au.exe" /i /s /y
xcopy "%DirRelease%\BooksInstall_NZ\setup_books.exe" "%DirPracticeNZ%setup_books_nz.exe" /i /s /y
xcopy "%DirRelease%\BooksInstall_UK\setup_books.exe" "%DirPracticeUK%setup_books_uk.exe" /i /s /y
REM Copy Books Update
xcopy "%DirRelease%\Books_Update_AU\setup_update_books.exe" "%DirPracticeAU%setup_update_books_au.exe" /i /s /y
xcopy "%DirRelease%\Books_Update_NZ\setup_update_books.exe" "%DirPracticeNZ%setup_update_books_nz.exe" /i /s /y
xcopy "%DirRelease%\Books_Update_UK\setup_update_books.exe" "%DirPracticeUK%setup_update_books_uk.exe" /i /s /y
REM Copy Practice Update
xcopy "%DirRelease%\Prac_Update_AU\*" "%DirPracticeAU%" /i /s /y
xcopy "%DirRelease%\Prac_Update_NZ\*" "%DirPracticeNZ%" /i /s /y
xcopy "%DirRelease%\Prac_Update_UK\*" "%DirPracticeUK%" /i /s /y
pause
