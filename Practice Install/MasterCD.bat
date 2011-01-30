echo off
echo **********************************************************
echo *                                                        *
echo * This will DELETE the existing "Practice CD" directory! *
echo *                                                        *
echo * Press CTRL+C now to terminate this Batch File          *
echo *                                                        *
echo **********************************************************
Del "Practice CD" /F
REM Create the folder structure
md "Practice CD\Documents\Australia\Books"
md "Practice CD\Documents\Australia\Practice"
md "Practice CD\Documents\New Zealand\Books"
md "Practice CD\Documents\New Zealand\Practice"
REM md "Practice CD\Documents\United Kingdom\Books"
md "Practice CD\Documents\United Kingdom\Practice"
md "Practice CD\Redist
md "Practice CD\Software\BankLink\Books\AU"
md "Practice CD\Software\BankLink\Books\NZ"
md "Practice CD\Software\BankLink\Books\UK"
md "Practice CD\Software\BankLink\Practice\AU"
md "Practice CD\Software\BankLink\Practice\NZ"
md "Practice CD\Software\BankLink\Practice\UK"
md "Practice CD\Software\BankLink\Samples\AU"
md "Practice CD\Software\BankLink\Samples\NZ"
md "Practice CD\Software\BankLink\Samples\UK"
md "Practice CD\Software\BankLink\Template"
md "Practice CD\Software\BankLink\Notes"
md "Practice CD\Software\BankLink\Support"
md "Practice CD\Toolkit\Australia
md "Practice CD\Toolkit\New Zealand

REM Copy the files
copy "Master CD Files\AUTORUN.INF" "Practice CD\AUTORUN.INF"
copy "Master CD Files\BK2002.ICO" "Practice CD\\BK2002.ICO"
copy "Master CD Files\InfoPrac.txt" "Practice CD\InfoPrac.txt"
copy CDSETUP.EXE "Practice CD\SETUP.EXE"
REM Documents
copy "Master CD Files\Guide_AU.chm" "Practice CD\Documents\Australia\Practice\Guide.chm
copy "Books CD Files\Guide_AU.chm" "Practice CD\Documents\Australia\Books\Guide.chm
copy "Master CD Files\Guide_NZ.chm" "Practice CD\Documents\New Zealand\Practice\Guide.chm
copy "Books CD Files\Guide_NZ.chm" "Practice CD\Documents\New Zealand\Books\Guide.chm
copy "Master CD Files\Guide_UK.chm" "Practice CD\Documents\United Kingdom\Practice\Guide.chm
REM copy "Books CD Files\Guide_UK.chm" "Practice CD\Documents\United Kingdom\Books\Guide.chm
REM Redist
xcopy "Master CD Files\Redist\*" "Practice CD\Redist" /i /s
REM Software
copy BooksInstall_AU\setup_books.exe "Practice CD\Software\BankLink\Books\AU\Setup.exe
copy BooksInstall_NZ\setup_books.exe "Practice CD\Software\BankLink\Books\NZ\Setup.exe
copy BooksInstall_UK\setup_books.exe "Practice CD\Software\BankLink\Books\UK\Setup.exe
copy PracticeInstall_AU\setup_practice_au.exe "Practice CD\Software\BankLink\Practice\AU\Setup.exe
copy PracticeInstall_AU\setup_practice_nz.exe "Practice CD\Software\BankLink\Practice\NZ\Setup.exe
copy PracticeInstall_AU\setup_practice_uk.exe "Practice CD\Software\BankLink\Practice\UK\Setup.exe
REM Samples
xcopy "Master CD Files\AU Samples\*" "Practice CD\Software\Samples\AU Samples" /i /s
xcopy "Master CD Files\NZ Samples\*" "Practice CD\Software\Samples\NZ Samples" /i /s
xcopy "Master CD Files\UK Samples\*" "Practice CD\Software\Samples\UK Samples" /i /s
REM Templates
xcopy "Master CD Files\Templates\*" "Practice CD\Software\Template" /i /s
REM Toolkit
xcopy "Master CD Files\Toolkit\Australia\*" "Practice CD\Toolkit\Australia" /i /s
xcopy "Master CD Files\Toolkit\New Zealand\*" "Practice CD\Toolkit\New Zealand" /i /s
