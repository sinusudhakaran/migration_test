unit sounds;

//-----------------------------------------------------------------------------
interface
//-----------------------------------------------------------------------------

Const
   sndAppOpen           = 1;  sndMin = 1;
   sndAppClose          = 2;
   sndFileOpen          = 3;
   sndFileSave          = 4;
   sndHelp              = 5;
   sndMemorise          = 6;
   sndConnecting        = 7;
   sndStartingLogin     = 8;
   sndRequestingFiles   = 9;
   sndUpdatingSystem    = 10;
   sndDownloadCompleted = 11; sndMax = 11;

   sndNames : Array[ sndMin..sndMax ] of String[40] =
   (
{  AppOpen            } 'Starting Application',
{  AppClose           } 'Closing Application',
{  FileOpen           } 'Opening File',
{  FileSave           } 'Saving File',
{  Help               } 'Help Pressed',
{  Memorise           } 'Transaction Memorised',
{  Connecting         } 'Starting Banklink Connect',
{  StartingLogin      } 'Authenticating to Server',
{  RequestingFiles    } 'Requesting New Files',
{  UpdatingSystem     } 'Processing New Files',
{  DownloadCompleted  } 'BankLink Connect Completed'
   );


Var
   sndFiles   : Array[ sndMin..sndMax ] of String;

Const
   sndEnabled : Boolean = True;

Function  GetSoundDir : String;
Procedure PlaySound( Number : Integer );
Procedure PlaySoundFile( FQFileName : String );
Procedure LoadSoundTheme;
Procedure SaveSoundTheme;

//-----------------------------------------------------------------------------
implementation uses SysUtils, mmsystem, INIFiles, Forms, Globals;
//-----------------------------------------------------------------------------

Const { Wait for the sound to finish }
   sndWait : Array[ sndMin..sndMax ] of Boolean =
   (
{  AppOpen            } False,
{  AppClose           } True,
{  FileOpen           } False,
{  FileSave           } False,
{  Help               } False,
{  Memorise           } False,
{  Connecting         } True,
{  StartingLogin      } True,
{  RequestingFiles    } True,
{  UpdatingSystem     } True,
{  DownloadCompleted  } True
   );

Const
   SGroupKey = 'Sound Settings';

//-----------------------------------------------------------------------------

Function  GetSoundDir : String;
Begin
   Result := ExtractFileDir( Application.ExeName ) + '\Sounds\';
end;

//-----------------------------------------------------------------------------

Procedure LoadSoundTheme;
Var
   ThemeFileName : String;
   i             : Integer;
   ItemKey       : String;
Begin
   ThemeFileName := GetSoundDir + CurrUser.Code + '.thm';
   If BKFileExists( ThemeFileName ) then
   Begin
      With TMemIniFile.Create( ThemeFileName ) do
      try
         For i := sndMin to sndMax do
         Begin
            ItemKey := sndNames[ i ];
            sndFiles[ i ] := ReadString( SGroupKey, ItemKey, '' );
         end;
      finally
         Free;
      end;
   end
   else
      For i := sndMin to sndMax do sndFiles[ i ] := '';
end;

//-----------------------------------------------------------------------------

Procedure SaveSoundTheme;
Var
   ThemeFileName : String;
   i             : Integer;
   ItemKey       : String;
Begin
   ThemeFileName := GetSoundDir + CurrUser.Code + '.thm';
   With TMemIniFile.Create( ThemeFileName ) do
   try
      For i := sndMin to sndMax do
      Begin
         ItemKey := sndNames[ i ];
         WriteString( SGroupKey, ItemKey, sndFiles[ i ] );
      end;
   finally
      DeleteFile(FileName);
      UpdateFile;
      Free;
   end;
end;

//-----------------------------------------------------------------------------

Procedure PlaySound( Number : Integer );
Var
   FileName : String;
Begin
   FileName := GetSoundDir + sndFiles[ Number ];
   If INI_PlaySounds and
      ( FileName <> '' ) and
      ( BKFileExists( FileName ) ) then
   Begin
      If sndWait[ Number ] then
         sndPlaySound( PChar( FileName ), snd_Sync or snd_NoDefault )
      else
         sndPlaySound( PChar( FileName ), snd_Async or snd_NoDefault );
   end;
end;

//-----------------------------------------------------------------------------

Procedure PlaySoundFile( FQFileName : String );
Begin
   If ( FQFileName <> '' ) and
      ( BKFileExists( FQFileName ) ) then
      sndPlaySound( PChar( FQFileName ), snd_Async or snd_NoDefault );
end;

end.
