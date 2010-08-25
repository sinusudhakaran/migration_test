unit DelimitedClientList;

interface
uses
  SysUtils, Types;

function GetBKClientList( Buffer : PChar; BufferLen : DWord) : LongBool; stdCall;
//returns true if a delimited list of client codes and names is returned
//parameters:
//  Buffer     : buffer to put delimited list into, delimited by Tab char
//  BufferLen  : length of buffer so we can check result not too big

function GetBKClientListBufferLen() : LongInt; stdCall;
//returns the length of the buffer needed to store the delimited list of codes
//returns -1 if the call failed


implementation
uses
  syDefs, admin32, globals, dialogs, bkconst;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ConstructDelimitedList : string;
var
  i : integer;
  ClientRec : pClient_File_Rec;
begin
  result := '';
  Admin32.ReloadAdminAndTakeSnapshot( Globals.GlobalAdminSnapshot);
  for i := GlobalAdminSnapshot.fdSystem_Client_File_List.First to
           GlobalAdminSnapshot.fdSystem_Client_File_List.Last do
  begin
    ClientRec := GlobalAdminSnapshot.fdSystem_Client_File_List.Client_File_At(i);
    //only add active clients
    if ClientRec.cfClient_Type = bkConst.ctActive then
      result := result + ClientRec.cfFile_Code + #9 + ClientRec.cfFile_Name + #9;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetBKClientList( Buffer : PChar; BufferLen : DWord) : LongBool; stdCall;
var
  DelimitedList : string;
begin
  result := false;
  try
    DelimitedList := ConstructDelimitedList;
    if (DelimitedList <> '') and ((Length(DelimitedList) + 2) <= Int(BufferLen)) then
    begin
      StrPCopy( Buffer, DelimitedList);
      result := true;
    end;
  except
    On E : Exception do
    begin
      MessageDlg('Error retrieving client list: ' + E.Message, mtError, [mbOK], 0);
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function GetBKClientListBufferLen() : LongInt; stdcall;
var
  DelimitedList : string;
begin
  result := -1;
  try
    DelimitedList := ConstructDelimitedList;
    if DelimitedList <> '' then
    begin
      result := Length( DelimitedList) + 2;
    end;
  except
    On E : Exception do
    begin
      MessageDlg('Error retrieving client list: ' + E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

end.
