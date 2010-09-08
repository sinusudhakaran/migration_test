@Echo off
Echo.
Echo   !!!  This will DELETE ALL the directories   !!!
Echo   !!!  used for creating a new BNotes Setup   !!!
Echo.
Echo   Press CTRL+C now to terminate this Batch File
Echo.
pause
Echo.
Echo   Last Chance...
Echo.
pause

REM Set Directories

SET SetupRootDir=G:\BNotes\FilesForCD

SET CDDir=%SetupRootDir%\BNotes

REM Clean out %CDDir%
Echo.
Echo Clean out directory :
RD %CDDir% /s

REM Recreate Structure
MD %CDDir%

Echo.
Echo    Setup Structure Recreated
Echo.
pause



