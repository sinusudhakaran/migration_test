unit ExtractCSV;

interface
uses
  ExtractCommon,
  Windows,
  Graphics;


function GetExtractVersion: Integer; stdcall;
procedure procInitDllApplication(ApplicationHandle : HWnd; BaseFont: TFont); stdcall;
function DoBulkExport(var Session: TExtractSession): Integer; stdcall;
function GetExtractType(Index: integer; var EType: ExtractType): Boolean; stdcall;

implementation

uses
  Dialogs,
  ExtractHelpers,
  Controls,
  frmCSVConfig,
  Forms,
  SysUtils,
  Classes;


const
  BasicCSV = 0;

  keySeparateClientFiles = 'SeparateClientFiles';
  keyExtractPath = 'ExtractPath';

var // General Extract vars
   MyFont: TFont;
   OutputFile: Text;
   OutputFileName: string;
   FilePerClient: Boolean;

   //SCVExport Specific
   CurrentClientCode: string;
   CurrentAccount: string;
   CurrentContra: string;

var
   FExtractFieldHelper: TExtractFieldHelper;

function  ExtractFieldHelper: TExtractFieldHelper;
begin
   if not Assigned(FExtractFieldHelper) then
      FExtractFieldHelper := TExtractFieldHelper.Create;

   Result := FExtractFieldHelper;

end;


//*****************************************************************************
//
//    REQUIRED EXPORTED FUNCTIONS
//
//*****************************************************************************

function GetExtractVersion: Integer; stdcall;
begin
   Result :=  Version_1;
end;

function GetExtractType(Index: integer; var EType: ExtractType): Boolean; stdcall;
begin
   Result := False;
   case Index of
   BasicCSV : begin
          EType.Index := BasicCSV;
          EType.Code  := CSVSimple;
          EType.Description := 'Simple CSV';
          EType.ExtractClass := ClassBase;
          Result := True;
      end;
   end;
end;

//*****************************************************************************
//
//    File Handeling
//
//*****************************************************************************


procedure OpenFile(const Filename:string);
begin

   Assign(OutputFile, Filename);
   //SetTextBuf( OutputFile, Buffer );
   Rewrite(OutputFile);

   Writeln(OutputFile, '"Account Number","Date","Type","Reference",' +
                        '"Analysis","Amount","Other Party","Particulars",'+
                        '"GST Amount","GST Class","Quantity","Code",'+
                        '"Narration","Contra","ClientCode","Closing Balance","Notes","BSB"' );

end;


//*****************************************************************************
//
//   CONFIGUATION
//
//*****************************************************************************

function GetPrivateProfileText(anApp, AKey, Default, Inifile: string; bufsize: Integer = 400): string;
var LB: PChar;
begin
   Result := Default;
   if (Length(IniFile) = 0)
   or (Length(AnApp) = 0)
   or (Length(AKey) = 0) then
      Exit;

   GetMem(LB, bufsize);
   try
      GetPrivateProfileString(pchar(AnApp),pChar(AKey),pchar(Default),LB,bufsize,Pchar(IniFile));
      Result := string(LB);
   finally
      FreeMem(LB,bufsize);
   End;
End;

function FindExtractPath(Session: TExtractSession): string;
begin
   // Does not have a default, so I know if it has been set
   Result := '';
   if Session.IniFile <> nil then
     case Session.Index of
     0 : Result :=  GetPrivateProfileText(CSVSimple,'ExtractPath', '', string(Session.IniFile));
     end;
end;

function GetExtractPath(Session: TExtractSession): string;
begin
   // Forces a default, so we have a strarting point
   Result := FindExtractPath(Session);



   if Result = '' then
      Result := ExtractFilePath(Application.ExeName) + 'Export.csv';
end;

function DoSimpleConfig (var Session: TExtractSession): Integer; stdcall;
var ldlg: TCSVConfig;
begin
   Result := er_Cancel; // Cancel by default
   ldlg := TCSVConfig.Create(nil);
   try
      if Assigned(MyFont) then begin
         ldlg.Font.Assign(MyFont);
      end;
      ldlg.Caption :='Simple CSV Setup';
      ldlg.eFilename.Text := GetExtractPath(Session);
      ldlg.ckSeparate.Checked := Bool(GetPrivateProfileInt(CSVSimple,keySeparateClientFiles,0,Session.IniFile));
      if ldlg.ShowModal = mrOK then begin
         WritePrivateProfileString(CSVSimple,keyExtractPath,pchar(ldlg.eFilename.Text), Session.IniFile);
         WritePrivateProfilestring(CSVSimple,keySeparateClientFiles,pchar(intToStr(Integer(ldlg.ckSeparate.Checked))),Session.IniFile);
         Result := er_OK; // Extract path is set..
      end;
   finally
      ldlg.Free;
   end;
end;


//*****************************************************************************
//
//   Local Export EVents
//
//*****************************************************************************


function TrapException (var Session: TExtractSession; value: ProcBulkExport):Integer; stdcall;
begin  // Helper to trap any IO or other exeptions
   try
      Result := Value(Session);
   except
     on E: exception do begin
        Result := er_Abort;
        Session.Data := PChar(E.Message);
     end;
   end;
end;


function SimpleSessionStart(var Session: TExtractSession): Integer; stdcall;
var
  Path: string;
begin
   Result := er_OK;
   OutputFileName := FindExtractPath(Session);
//   if OutputFileName = '' then
//      if DoSimpleConfig(Session) = er_OK then
//         OutputFileName := FindExtractPath(Session);
   Path := ExtractFilePath(OutputFileName);
   while (Path = '') or (not DirectoryExists(Path)) or (OutputFileName = '') do begin
     if DoSimpleConfig(Session) = er_OK then begin
       OutputFileName := FindExtractPath(Session);
       Path := ExtractFilePath(OutputFileName);
     end else begin
       Result := er_Cancel; //Can't continue without a valid path
       Exit;
     end;
   end;

   if OutputFileName > '' then begin
      FilePerClient := Bool(GetPrivateProfileInt(CSVSimple,keySeparateClientFiles,0,Session.IniFile));
      if not FilePerClient then
         // Open it for the Whole session..
         OpenFile(OutputFileName);

   end else
      Result := er_Cancel; // User must have canceled
end;

function CleanTextField(const Value: string): string;
begin
      Result := ExtractFieldHelper.ForceQuotes
                (
                  ExtractFieldHelper.ReplaceQuotesAndCommas
                  (
                      ExtractFieldHelper.RemoveQuotes(Value)
                  )
                )
end;



function SessionEnd(var Session: TExtractSession): Integer; stdcall;
begin
   try
      if (TTextRec(OutPutFile).Mode <> 0)
      and (TTextRec(OutPutFile).Mode <> fmClosed) then
         CloseFile(OutPutFile); // SavetyNet..
   except
     // I tryed...
   end;
   Result := er_OK;
end;


function ClientStart(var Session: TExtractSession): Integer; stdcall;
begin
   ExtractFieldHelper.SetFields(Session.Data);
   CurrentClientCode := CleanTextField(ExtractFieldHelper.GetField(f_Code));
   if FilePerClient then begin
      OutputFileName := ExtractFilePath(OutputFileName) + ExtractFieldHelper.RemoveQuotes(CurrentClientCode) + '.csv';
      OpenFile(OutputFileName);
   end;

   Result := er_OK;
end;

function ClientEnd (var Session: TExtractSession): Integer; stdcall;
begin
  if FilePerClient then begin
      CloseFile(OutPutFile);
  end;

  Result := er_OK;
end;


function AccountStart(var Session: TExtractSession): Integer; stdcall;
begin
   ExtractFieldHelper.SetFields(Session.Data);
   CurrentAccount := CleanTextField(ExtractFieldHelper.GetField(f_Number));
   CurrentContra := CleanTextField(ExtractFieldHelper.GetField(f_ContraCode));

   Result := er_OK;
end;


procedure WriteSimpleFields(var Session: TExtractSession);
var
  Bsb, AccountNum: string;
begin
//   ShowMessage('ExtractCSV.WriteSimpleFields');
   ProcessDiskCode(CurrentAccount, Bsb, AccountNum);
   with ExtractFieldHelper do
   Writeln(Outputfile,
     {CurrentAccount}ForceQuotes(AccountNum), ',',
     ForceQuotes(GetField(f_Date)), ',',
     ForceQuotes(GetField(f_TransType)), ',',
     CleanTextField(GetField(f_Reference)), ',',
     CleanTextField(GetField(f_Analysis)), ',',
     ForceQuotes(GetField(f_Amount,'0.00')), ',',
     CleanTextField(GetField(f_Otherparty)), ',',
     CleanTextField(GetField(f_Particulars)), ',',
     ForceQuotes(GetField(f_Tax,'0.00')), ',',
     ForceQuotes(GetField(f_TaxCode)), ',',
     ForceQuotes(GetField(f_Quantity,'0.0000')), ',',
     ForceQuotes(GetField(f_Code)), ',',
     CleanTextField(GetField(f_Narration)), ',',
     CurrentContra, ',',
     CurrentClientCode, ',',
     ForceQuotes(GetField(f_Balance,'0.00')), ',',
     ExtractFieldHelper.RemoveCRLF(CleanTextField(GetField(f_Notes))),
     ForceQuotes(Bsb)
   );

end;



function Transaction(var Session: TExtractSession): Integer; stdcall;
begin
   ExtractFieldHelper.SetFields(Session.Data);
   case Session.Index of
   0:  WriteSimpleFields(Session);
   end;
   Result := er_OK;
end;



//*****************************************************************************
//
//    MAIN EXPORTED EXPORT FUNCTION
//
//*****************************************************************************

function DoBulkExport(var Session: TExtractSession): Integer; stdcall;
begin
   Result := er_NotImplemented; // Do not fail u
   case Session.ExtractFunction of

   ef_SessionStart  : case Session.Index of
                        0: Result := TrapException(Session,SimpleSessionStart);
                      end;
   ef_SessionEnd    : Result := TrapException(Session,SessionEnd);

   ef_ClientStart   :Result := TrapException(Session,ClientStart);
   ef_ClientEnd     :Result := TrapException(Session,ClientEnd);
   ef_AccountStart  :Result := TrapException(Session,AccountStart);
   //ef_AccountEnd    :Result := TrapException(Session,Transaction);

   ef_Transaction   :Result := TrapException(Session,Transaction);
   ef_Dissection    :Result := TrapException(Session,Transaction);

   ef_CanConfig    : case Session.Index of
                       0: Result := er_OK;
                     end;
   ef_DoConfig     : case Session.Index of
                       0: Result := DoSimpleConfig(Session);
                     end;

   end;

end;


procedure procInitDllApplication(ApplicationHandle : HWnd; BaseFont: TFont); stdcall;
begin
  if ApplicationHandle <> 0 then
     Application.Handle := ApplicationHandle;

  if Assigned(BaseFont) then begin
     if not assigned(MyFont) then
        MyFont := TFont.Create;
     // cannot use assign because the class is not the same.
     MyFont.Name :=  BaseFont.Name;
     MyFont.Height := BaseFont.Height;
  end;
end;

initialization

  MyFont := nil;
  OutputFileName := '';
  CurrentClientCode := '';
  CurrentAccount := '';
  CurrentContra := '';
finalization
   OutputFileName := '';

   if assigned(MyFont) then begin
      MyFont.Free;
      MyFont := nil;
   end;

   if Application.Handle <> 0 then
      Application.Handle := 0;


end.
