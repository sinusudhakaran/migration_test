echo off
if exist "Notes CD" echo *******************************************************
if exist "Notes CD" echo *                                                     *
if exist "Notes CD" echo * This will DELETE the existing "Notes CD" directory! *
if exist "Notes CD" echo *                                                     *
if exist "Notes CD" echo * Press CTRL+C now to terminate this Batch File       *
if exist "Notes CD" echo *                                                     *
if exist "Notes CD" echo *******************************************************
if exist "Notes CD" Del "Notes CD" /F
REM Create the folder structure
echo "Creating Notes CD..."
md "Notes CD"
md "Notes CD\Software"
md "Notes CD\Updates\AU"
md "Notes CD\Updates\NZ"
md "Notes CD\Updates\UK"
REM Copy the files
copy AUTORUN.INF "Notes CD\AUTORUN.INF"
copy BNOTES.ICO "Notes CD\BNOTES.ICO"
copy NOTESSETUP.EXE "Notes CD\SETUP.EXE"
REM Software
copy "BNotes Install\setupbnotes.exe" "Notes CD\Software\setup.exe"
copy "BNotes Install Update\setupbnotes_update_AU.exe" "Notes CD\Updates\AU\setup.exe"
copy "BNotes Install Update\setupbnotes_update_NZ.exe" "Notes CD\Updates\NZ\setup.exe"
copy "BNotes Install Update\setupbnotes_update_UK.exe" "Notes CD\Updates\UK\setup.exe"
pause
