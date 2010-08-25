@echo off
cls
echo *********************************************************************
echo *                                                                   *
echo *  Copy Files from BankLink Release Directory to :                  *
echo *                                                                   *
echo *  Practice Setup Directory                                         *
echo *  Offsite Setup Directory                                          *
echo *  Demo Setup Directory  - THIS REMed OUT                           *
echo *                                                                   *
echo *                                                                   *
echo *                                                                   *
echo *********************************************************************
echo .
pause
echo .

REM ROOT Dir

Set SetupRootDir=G:\BNotes\FilesForCD

REM SOURCE Dirs

set BNotesRel=G:\BNotes\Release

REM DEST Dirs

set BNotesDir=%SetupRootDir%\BNotes

echo .
echo **********************************************************************
echo Copying latest versions of BNotes setup file
echo .
echo on

copy  %BNotesRel%\bnotes.exe    %BNotesDir%
copy  %BNotesRel%\bnotes.hlp    %BNotesDir%
copy  %BNotesRel%\BNOTES_EULA.TXT  %BNotesDir%

REM INNO SETUP Files

copy  %SetupRootDir%\BNotes.iss  %BNotesDir%

@echo off

echo **********************************************************************
echo .
@echo off

echo .
echo .
echo ***********************************************************************
echo *                                                                     *
echo *  Copy Complete                                                      *
echo *                                                                     *
echo *  Now run the INNO Setup Utility to create the new SETUP.EXE's       *
echo *                                                                     *
echo *  Use script files:                                                  *
echo *                                                                     *
echo *      \Bnotes\bnotes.iss                                       *
echo *                                                                     *
echo *  INNO Setup Will now run                                            *
echo *                                                                     *
echo ***********************************************************************
echo .
echo .
pause
echo on
G:\BK5\CDROM\INNO_SETUP\COMPIL32.EXE
