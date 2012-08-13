unit AppParser;

interface

function ParserApp
             (CallingApp: string;
              aHandle: THandle;
              ApplicationID: longInt;
              var Reply: string): LongInt;

function GetParserDLLName(ApplicationID: integer): string;

// If Result < 0 it failed and Reply (may) hold an error text message
// If Result >= 0 it was sucsefull, Can show what/how it was found

implementation

uses
  sysutils,
  upgConstants,
  Windows;


  // Could put this in a header/include file so it can be used directly by the Dlls
type
  TAppParserProc = function (CallingApp: PChar;
              aHandle: THandle;
              ApplicationID: longInt;
              ReplyBuffer: PChar;
              ReplyBufferSize: longInt;
              out ReplySize: LongInt) : LongInt; stdcall;

const
   AppParserProcName =  'ParserApp';


function ParserApp
             (CallingApp: string;
              aHandle: THandle;
              ApplicationID: longInt;
              var Reply: string): LongInt;
var
  ParserName: string;


   procedure CallParser(DllName: string);
   var Dll: THandle;
       ParserProc: TAppParserProc;
       ReplyBuffer: pchar;
       ReplySize: LongInt;
   const
      ReplyBufferSize = 1024; // a bit, big but he...
   begin
      Dll := LoadLibrary(PChar(DllName));
      if DLL = 0 then begin
         // May need to add '.dll' for older OS
         Result := Pa_NoDll;
         Exit;
      end;
      try
         ParserProc := GetProcAddress(Dll,AppParserProcName);
         if Assigned(ParserProc) then begin
            GetMem(ReplyBuffer,ReplyBufferSize);
            ReplyBuffer^ := #0;
            try try
               Result := ParserProc(PChar(CallingApp),aHandle,ApplicationID,ReplyBuffer,ReplyBufferSize,ReplySize);
               Reply := string(ReplyBuffer);
            except
               on e : exception do begin
                  Result := Pa_WrongDll;
                  Reply := e.Message;
               end;
            end;
            finally
               FreeMem(ReplyBuffer,ReplyBufferSize);
            end;
         end else
            Result := Pa_WrongDll;
      finally
         FreeLibrary(Dll);
      end;

   end;

begin
   Result := Pa_Fail;
   Reply := '';
   ParserName := GetParserDLLName(ApplicationID);
   if ParserName <> '' then
    CallParser(ParserName);
end;

function GetParserDLLName(ApplicationID: integer): string;
begin
   case ApplicationID of
      aidBK5_Practice,
      aidBK5_Offsite : Result := Pn_ParseBK5;
      //aidUpgrader = 7;
      aidInvoicePlus : Result := Pn_ParseIPlus;
      aidBNotes : Result := Pn_ParseBNotes;
      //aidSmartLink = 20;
      else
        Result := '';
   end;

end;


end.
