echo ****************************************************************
echo * !!!  This will DELETE the existing "Books CD" directory  !!! *
echo *                                                              *
echo *  Press CTRL+C now to terminate this Batch File               *
echo *                                                              *
echo ****************************************************************
pause
Del "Books CD" /F
REM Create the folder structure
md "Books CD\Documents\Australia"
md "Books CD\Documents\New Zealand"
md "Books CD\Documents\United Kingdom"
md "Books CD\Software\Books\AU"
md "Books CD\Software\Books\NZ"
md "Books CD\Software\Books\UK"
md "Books CD\Software\Support\Uncompressed"
md "Books CD\Software\Updates\AU"
md "Books CD\Software\Updates\NZ"
md "Books CD\Software\Updates\UK"
REM Copy the files
copy "Books CD Files\AUTORUN.INF" "Books CD\AUTORUN.INF"
copy "Books CD Files\BK2002.ICO" "Books CD\BK2002.ICO"
copy "Books CD Files\SETUP.EXE" "Books CD\SETUP.EXE"
REM Documents   
copy "Books CD Files\Documents\Australia\BankLink_Books_installation.pdf" "Books CD\Documents\Australia\BankLink_Books_installation.pdf"
copy "Books CD Files\Documents\New Zealand\BankLink_Books_installation.pdf" "Books CD\Documents\New Zealand\BankLink_Books_installation.pdf"
REM Software
copy "BooksInstall_AU\setup_books.exe" "Books CD\Software\Books\AU\setup.exe"
copy "BooksInstall_NZ\setup_books.exe" "Books CD\Software\Books\NZ\setup.exe"
copy "BooksInstall_UK\setup_books.exe" "Books CD\Software\Books\UK\setup.exe"
copy BK5WIN.exe "Books CD\Software\Support\BK5WIN.exe"
copy "BKHandler\bkHandlerSetup.exe" "Books CD\Software\Support\bkHandlerSetup.exe"
copy "Uncompressed\BK5WIN.exe" "Books CD\Software\Support\Uncompressed\BK5WIN.exe"
copy "Books_Update_AU\setup_update_books.exe" "Books CD\Software\Updates\AU\setup.exe"
copy "Books_Update_NZ\setup_update_books.exe" "Books CD\Software\Updates\NZ\setup.exe"
copy "Books_Update_UK\setup_update_books.exe" "Books CD\Software\Updates\UK\setup.exe"
