unit ExtractPraemium;

///------------------------------------------------------------------------------
///  Title:   Bulk Export to Praemium
///
///  Written: June 2009
///
///  Authors: Andre' Joosten
///
///  Purpose: Export dll function for the export DLL
///
///  Notes:  It has its own counters, because they are per file.
///
///  History:
///
///  Nov 2009 : updated TransNum on ef_Dissected Case#  13699
///
///------------------------------------------------------------------------------


interface
uses
  ExtractCommon,
  Windows,
  Graphics;


function GetExtractVersion: Integer; stdcall;
procedure procInitDllApplication(ApplicationHandle : HWnd; BaseFont: TFont); stdcall;
function DoBulkExport(var Session: TExtractSession): Integer; stdcall;
function GetExtractType(Index: integer; var EType: ExtractType): Boolean; stdcall;
function CheckFeature(const index, Feature: Integer): Integer; stdcall;

implementation

uses
  ExtractHelpers,
  Controls,
  frmPraemiumConfig,
  Forms,
  SysUtils,
  Classes;


const
  BasicPraemium = 0;

  keySeparateClientFiles = 'SeparateClientFiles';
  keyExtractPath = 'ExtractPath';

  DefaultExtention = '.csv';
  DefaultFileName = 'BankLink_Praemium' + DefaultExtention;

var // General Extract vars
   MyFont: TFont;
   OutputFile: Text;
   OutputFileName: string;
   FilePerClient: Boolean;

   //PraemiumExport Specific
   CurrentClientCode: string;
   CurrentAccount: string;
   CurrentContra: string;
   LineNum: Integer;
   TransNum: Integer;
   CheckSum: Currency;
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
   BasicPraemium : begin
          EType.Index := BasicPraemium;
          EType.Code  := PraemiumCode;
          EType.Description := 'Praemium';
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
   Writeln(OutputFile,  '"Number","Account Number","Bank","Date","Reference","Account","Account Description","Amount","Narration","Quantity","GST Class","GST Amount"');
   //Reset for Checksum line handeling
   LineNum := 0;
   TransNum := 0;
   CheckSum := 0.0;
end;

procedure EndFile;
begin
   //First Write the checksum Line
   Writeln(OutputFile,
      IntToStr(TransNum) ,                //Number
      ',"CHECKSUM","",',                  //Account, Bank
      FormatDateTime('dd/mm/yyyy',Date),  //Date
      ',"","","",',                       //Reference, Account, Description
      Format('%f',[CheckSum]),            //Amount
      ',"",',                             //Narration
      IntToStr(LineNum),                  //Qty
      '.0000,"",0.00'                     //+ GST Class, GST Amount

   );
   // Close the file..
   CloseFile(outPutFile)
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
      Result :=  GetPrivateProfileText(PraemiumCode,'ExtractPath', '', string(Session.IniFile));
end;

function GetExtractPath(Session: TExtractSession): string;
begin
   // Forces a default, so we have a starting point
   Result := FindExtractPath(Session);

   if Result = '' then
      Result := ExtractFilePath(Application.ExeName) + DefaultFilename;
end;

function DoPraemiumConfig (var Session: TExtractSession): Integer; stdcall;
var ldlg: TPraemiumConfig;
begin
   Result := er_Cancel; // Cancel by default
   ldlg := TPraemiumConfig.Create(nil);
   try
      if Assigned(MyFont) then begin
         ldlg.Font.Assign(MyFont);
      end;
      ldlg.Caption :='Praemium Setup';
      ldlg.eFilename.Text := GetExtractPath(Session);
      ldlg.ckSeparate.Checked := Bool(GetPrivateProfileInt(PraemiumCode,keySeparateClientFiles,0,Session.IniFile));
      if ldlg.ShowModal = mrOK then begin
         WritePrivateProfileString(PraemiumCode,keyExtractPath,pchar(ldlg.eFilename.Text), Session.IniFile);
         WritePrivateProfilestring(PraemiumCode,keySeparateClientFiles,pchar(intToStr(Integer(ldlg.ckSeparate.Checked))),Session.IniFile);
         Result := er_OK; // Extract path is set..
      end;
   finally
      ldlg.Free;
   end;
end;



function CheckFeature(const index, Feature: Integer): Integer; stdcall;
begin
   Result := 0;
   {case Feature of
      //tf_TransactionID : Result := tr_GUID;
       //tf_TransactionType :;
       //tf_BankAccountType :;
       //tf_ClientType :;
   end;}
end;

//*****************************************************************************
//
//   Local Export EVents
//
//*****************************************************************************


function TrapException (var Session: TExtractSession; value: ProcBulkExport):Integer; stdcall;
begin  // Helper to trap any IO or other exceptions
   try
      Result := Value(Session);
   except
     on E: exception do begin
        Result := er_Abort;
        Session.Data := PChar(E.Message);
     end;
   end;
end;


function SessionStart(var Session: TExtractSession): Integer; stdcall;
begin
   Result := er_OK;
   OutputFileName := FindExtractPath(Session);
   if OutputFileName = '' then
      if DoPraemiumConfig(Session) = er_OK then
         OutputFileName := FindExtractPath(Session);


   if OutputFileName > '' then begin
      FilePerClient := Bool(GetPrivateProfileInt(PraemiumCode,keySeparateClientFiles,0,Session.IniFile));
      if not FilePerClient then
         // Open it for the Whole session..
         OpenFile(MakeFilePath(OutputFileName,DefaultFilename) );

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
   if not FilePerClient then
      Endfile;

   {try
      if (TTextRec(OutPutFile).Mode <> 0)
      and (TTextRec(OutPutFile).Mode <> fmClosed) then
         CloseFile(OutPutFile); // SavetyNet..
   except
     // I tryed...
   end;   }
   Result := er_OK;
end;


function ClientStart(var Session: TExtractSession): Integer; stdcall;
begin
   ExtractFieldHelper.SetFields(Session.Data);
   CurrentClientCode := CleanTextField(ExtractFieldHelper.GetField(f_Code));
   if FilePerClient then begin
      OpenFile(MakeFilePath(ExtractFilePath(OutputFileName),ExtractFieldHelper.RemoveQuotes(CurrentClientCode) + DefaultExtention  ));
   end;

   Result := er_OK;
end;

function ClientEnd (var Session: TExtractSession): Integer; stdcall;
begin
  if FilePerClient then begin
     EndFile;
  end;

  Result := er_OK;
end;


function AccountStart(var Session: TExtractSession): Integer; stdcall;
begin
   ExtractFieldHelper.SetFields(Session.Data);
   CurrentAccount := ExtractFieldHelper.ForceQuotes(ExtractFieldHelper.GetField(f_Number));
   CurrentContra := ExtractFieldHelper.ForceQuotes(ExtractFieldHelper.GetField(f_ContraCode));

   Result := er_OK;
end;


procedure WritePraemiumFields(var Session: TExtractSession);
    //"Number","Account Number","Bank","Date","Reference","Account","Account Description","Amount","Narration","Quantity","GST Class","GST Amount"
begin
   inc(LineNum);
   with ExtractFieldHelper do begin
      Writeln(Outputfile,
         IntToStr(TransNum),',',                       //Number
         CurrentAccount, ',',                          //Bank Account
         CurrentContra, ',',                           //Bank Contra
         ForceQuotes(GetField(f_Date)), ',',           //Date
         ForceQuotes(GetField(f_Reference)), ',',      //reference ??Checque Number
         ForceQuotes(GetField(f_Code)), ',',           //Chart Code
         ForceQuotes(GetField(f_Desc)), ',',           //Chart description
         GetField(f_Amount,'0.00'), ',',               //Amount
         ForceQuotes(GetField(f_Narration)), ',',      //Narration
         GetField(f_Quantity,'0.0000'), ',',           //Quantity
         ForceQuotes(GetField(f_TaxCode)), ',',        //GST Class
         GetField(f_Tax,'0.00')                        //GST Amount
         );
      CheckSum := CheckSum + GetMoney(f_Amount);
   end;
end;



function Transaction(var Session: TExtractSession): Integer; stdcall;
begin
   ExtractFieldHelper.SetFields(Session.Data);
   WritePraemiumFields(Session);
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

   ef_SessionStart  : Result := TrapException(Session,SessionStart);
   ef_SessionEnd    : Result := TrapException(Session,SessionEnd);

   ef_ClientStart   : Result := TrapException(Session,ClientStart);
   ef_ClientEnd     : Result := TrapException(Session,ClientEnd);
   ef_AccountStart  : Result := TrapException(Session,AccountStart);
   //ef_AccountEnd    :Result := TrapException(Session,Transaction);

   ef_Transaction   : begin
                        Inc(TransNum);
                        Result := TrapException(Session,Transaction);
                      end;
   ef_Dissected     : begin
                        Inc(TransNum);
                        Result := er_OK;
                      end;
   ef_Dissection    : Result := TrapException(Session,Transaction);

   ef_CanConfig     : Result := er_OK;
   ef_DoConfig      : Result := DoPraemiumConfig(Session);

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
