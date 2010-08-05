unit files;
//------------------------------------------------------------------------------
{
   Title:       Files

   Description: File Handler

   Remarks:     Handles the opening and saving of ecoding files
                Handles any errors

   Author:      Matthew Hopkins Jul 2001

}
//------------------------------------------------------------------------------

interface
uses
   ecObj;

procedure OpenFile( const filename : string; var aECFile : TEcClient; var ErrorMsg : string; aHandle: Cardinal);

function  SaveFile( const filename : string; const aECFile : TEcClient) : boolean;

procedure CloseFile( var aECFile : TEcClient);

function  FileHasChanged( aECFile : TEcClient) : boolean;

//******************************************************************************
implementation
uses
   SysLog,
   SysUtils,
   ecMessageBoxUtils,
   Dialogs,
   ecGlobalVars;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure OpenFile( const filename : string; var aECFile : TEcClient; var ErrorMsg : string; aHandle: Cardinal);
{
   returns a ecfile object if one can be opened, otherwise returns nil

   handles all errors

   expects aECFile to be nil
}
begin
   Assert( aECFile = nil, 'OpenFile called with aECFile <> nil');

   try
      aECFile := TEcClient.Create;
      if aECFile.LoadFromFile( filename, aHandle) then
      begin
        aECFile.ecFields.ecCurrent_CRC  := aECFile.GetCurrentCRC;
        SysLog.ApplicationLog.LogMsg( lmInfo, 'File ' + filename + ' opened');
      end
      else
      begin
        try aECFile.Free; except ; end;
        aECFile := nil;
      end;
   except
      On E : Exception do begin
         if not ApplicationMustShutdownForUpdate then
         begin
           ApplicationLog.LogError( 'Unable to open file ' + E.Message);
           ErrorMsg := E.Message;

           try aECFile.Free; except ; end;
           aECFile := nil;
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SaveFile( const filename : string; const aECFile : TEcClient) : boolean;
begin
   result := false;
   Assert( aECFile <> nil, 'SaveFile called with aECFile = nil');
   //save new file
   try
      aECFile.ecFields.ecFirst_Save_Done := true;
      aECFile.SaveToFile( filename);
      result := true;
   except
      On E : Exception do begin
         ApplicationLog.LogError('Unable to save file ' + E.Message);
         ErrorMessage( 'Unable to save file ' + Filename + '.'#13#13 + E.Message);
         exit;
      end;
   end;
   SysLog.ApplicationLog.LogMsg( lmInfo, 'File ' + filename + ' saved');
   aECFile.ecFields.ecCurrent_CRC  := aECFile.GetCurrentCRC;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CloseFile( var aECFile : TEcClient);
begin
   aECFile.Free;
   aECFile := nil;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function FileHasChanged( aECFile : TEcClient) : boolean;
var
  CRC : integer;
begin
   //see if file has changed
   CRC    := aECFile.GetCurrentCRC;
   result := ( CRC <> aECFile.ecFields.ecCurrent_CRC);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
