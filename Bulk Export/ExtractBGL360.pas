unit ExtractBGL360;

interface
uses
  ExtractCommon,
  Windows,
  Graphics,
  OmniXML;

function GetExtractVersion: Integer; stdcall;
procedure procInitDllApplication(ApplicationHandle : HWnd; BaseFont: TFont); stdcall;
function DoBulkExport(var Session: TExtractSession): Integer; stdcall;
function GetExtractType(Index: integer; var EType: ExtractType): Boolean; stdcall;
function CheckFeature(const index, Feature: Integer): Integer; stdcall;
procedure WriteBGLFields(var Session: TExtractSession; var TestNode: IxmlNode; TestRun: boolean = false);
function ClientStart(var Session: TExtractSession): Integer; stdcall;
function AccountStart(var Session: TExtractSession): Integer; stdcall;
procedure StartFile;

implementation

uses
  bkConst,
  ExtractHelpers,
  Controls,
  frmBGLConfig,
  Forms,
  StDate,
  StDateSt,
  SysUtils,
  OmniXMLUtils,
  Classes;

const
  BGL360 = 0;

  keySeparateClientFiles = 'SeparateClientFiles';
  keyExtractPath = 'ExtractPath';
  keyExtractCode = 'ExtractCode';
  keyCodedOnly   = 'CodedOnly';

var // General Extract vars
   MyFont: TFont;

   OutputFileName: string;
   FilePerClient: Boolean;
   CodedOnly: Boolean;

   //Export Specific
   CurrentClientCode: string;
   CurrentAccount: string;
   OpenBalance: string;
   BalanceDate: string;
   CurrentContra: string;
   DefaultCode: string;
   DateText: string;

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
   BGL360 : begin
          EType.Index := BGL360;
          EType.Code  := BGL360code;
          EType.Description := 'BGL SF360'; // Has been renamed from BGL 360 to BGL SF360
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

var
  FOutputDocument: IXMLDocument;
  BaseNode: IxmlNode;
  BankBalancesNode: IxmlNode;
  TransactionsNode: IxmlNode;
  ClientNode: IxmlNode;

function OutputDocument :IXMLDocument;
begin
   if FOutputDocument = nil then begin
      FOutputDocument := CreateXMLDoc;
   end;

   Result := FOutputDocument;
end;


procedure StartFile;
begin
   OutputDocument.LoadXML(''); // Clear
   BaseNode := EnsureNode(OutputDocument,'BGL_Import_Export');
   SetNodeTextStr(BaseNode,'Supplier','MYOB BankLink');
   SetNodeTextStr(BaseNode,'Product','SF360');
   SetNodeTextStr(BaseNode,'Import_Export_Version','5.0');

   TransactionsNode := nil;
end;

procedure SaveFile(Filename: string);
begin
   OutputDocument.Save(FileName,ofIndent);
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
     BGL360 : Result :=  GetPrivateProfileText(BGL360code,keyExtractPath, '', string(Session.IniFile));
     end;
end;

function GetExtractPath(Session: TExtractSession): string;
begin
   // Forces a default, so we have a strarting point
   Result := FindExtractPath(Session);

   // Has been renamed to BGL SF360
   if Result = '' then
      Result := ExtractFilePath(Application.ExeName) + 'BGL_SF360.xml';
end;

function DoBGL360Config (var Session: TExtractSession): Integer; stdcall;
var ldlg: TBGLXMLConfig;
begin
   Result := er_Cancel; // Cancel by default
   ldlg := TBGLXMLConfig.Create(nil);
   try
      if Assigned(MyFont) then begin
         ldlg.Font.Assign(MyFont);
      end;
      ldlg.Caption := 'BGL SF360 Setup';
      ldlg.eFilename.Text := GetExtractPath(Session);
      ldlg.eClearing.Text := GetPrivateProfileText(BGL360code, keyExtractCode,'91000', Session.IniFile);
      ldlg.rbSplit.Checked := Bool(GetPrivateProfileInt(BGL360code,keySeparateClientFiles,0,Session.IniFile));
      ldlg.ckCoding.Checked := Bool(GetPrivateProfileInt(BGL360code,keyCodedOnly,0,Session.IniFile));
      if ldlg.ShowModal = mrOK then begin
         WritePrivateProfileString(BGL360code,keyExtractPath,pchar(Trim(ldlg.eFilename.Text)), Session.IniFile);
         WritePrivateProfilestring(BGL360code,keySeparateClientFiles,pchar(intToStr(Integer(ldlg.rbSplit.Checked))),Session.IniFile);

         DefaultCode := Trim(ldlg.eClearing.Text);
         WritePrivateProfileString(BGL360code,keyExtractCode,pchar(DefaultCode), Session.IniFile);

         WritePrivateProfilestring(BGL360code,keyCodedOnly,pchar(intToStr(Integer(ldlg.ckCoding.Checked))),Session.IniFile);
         CodedOnly := ldlg.ckCoding.Checked;
         Result := er_OK; // Extract path is set..
      end;
   finally
      ldlg.Free;
   end;
end;


function CheckFeature(const index, Feature: Integer): Integer; stdcall;
begin
   Result := 0;
   if Index = BGL360 then
      case Feature of
       tf_TransactionID : Result := tr_GUID;
       tf_TransactionType : begin
           if CodedOnly then
               Result := tr_Coded;
       end;

       //tf_BankAccountType : Result := tr_Contra;
       //tf_ClientType = 4;
      end;
end;

//*****************************************************************************
//
//   Local Export Event Helpers
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


function CleanTextField(const Value: string): string;
begin
   Result := ExtractFieldHelper.ReplaceQuotesAndCommas
             (
                ExtractFieldHelper.RemoveQuotes(Value)
             );
end;


//*****************************************************************************
//
//   SESSION Start Stop
//
//*****************************************************************************

function BGLSessionStart(var Session: TExtractSession): Integer; stdcall;
begin
   Result := er_OK;
   OutputFileName := FindExtractPath(Session);
   if OutputFileName = '' then
   begin
     if DoBGL360Config(Session) = er_OK then
     begin
       OutputFileName := FindExtractPath(Session);
     end;
   end;

   if OutputFileName > '' then begin
      // Can Have a Go...
      FilePerClient := Bool(GetPrivateProfileInt(BGL360code,keySeparateClientFiles,0,Session.IniFile));
      ExtractFieldHelper.SetFields(Session.Data);
      DateText := CleanTextField(ExtractFieldHelper.GetField(f_Date));

      if not FilePerClient then begin
         // Open File for the Whole session..
         OutputFileName := ExtractFilePath(OutputFileName)
                         + CleanTextField(ExtractFieldHelper.GetField(f_Code))
                         + '_SF360_'
                         + DateText
                         + '.xml';

         StartFile;
         SaveFile(OutputFileName); // Test if we can write it rather than find out too late
      end;

   end else
      Result := er_Cancel; // User must have canceled
end;



function SessionEnd(var Session: TExtractSession): Integer; stdcall;
begin
   if not FilePerClient  then
      FOutputDocument.Save(OutputFileName,ofIndent);

   FOutputDocument := nil;
   TransactionsNode := nil;
   //EntitiesNode := nil;
   Result := er_OK;
end;

//******************************************************************************
//
//   CLIENT Start Stop
//
//******************************************************************************


function ClientStart(var Session: TExtractSession): Integer; stdcall;
begin
  ExtractFieldHelper.SetFields(Session.Data);
  CurrentClientCode := CleanTextField(ExtractFieldHelper.GetField(f_Code));
  if FilePerClient then begin
    OutputFileName := ExtractFilePath(OutputFileName)
                    + CurrentClientCode
                    + '_SF360_'
                    + DateText
                    + '.xml';
    StartFile;
    SaveFile(OutputFileName); // Test if we can write it rather than find out at the end
  end;

  ExtractFieldHelper.SetFields(Session.Data);
  CurrentClientCode := ExtractFieldHelper.GetField(f_Code);
  // Build the Entity Details for the Client
  ClientNode := OutputDocument.CreateElement('Entity_Details');
  BaseNode.AppendChild(ClientNode);
  SetNodeTextStr(ClientNode,'Entity_Code',CurrentClientCode);
  BankBalancesNode := OutputDocument.CreateElement('BankBalances');
  ClientNode.AppendChild(BankBalancesNode);
  TransactionsNode := OutputDocument.CreateElement('Transactions');
  ClientNode.AppendChild(TransactionsNode);
  Result := er_OK;
end;

function ClientEnd (var Session: TExtractSession): Integer; stdcall;
begin
   if FilePerClient then
      SaveFile(OutputFileName);

   Result := er_OK;
end;

//******************************************************************************
//
//   ACCOUNT Start
//
//******************************************************************************

function AccountStart(var Session: TExtractSession): Integer; stdcall;
const
  FDateMask = 'dd/mm/YYYY';
var
  AccountNum    : String;
  BSB           : String;
  BalanceNode   : IXmlNode;
  AccountType   : String;

  procedure AddFieldNode(var ToNode: IxmlNode; const Name, Value: string; AllowEmpty: boolean = false);
  begin
    if (Value > '') or AllowEmpty then
      SetNodeTextStr(ToNode,Name,Value);
  end;

  Function Date2Str( CONST ADate: Integer; Const APicture : ShortString) : ShortString;
  Begin
    If ADate <= 0 then
      Result := '' { Bad date or null date }
    else
      Result := StDateSt.StDateToDateString( APicture, ADate, False );
  end;

begin
  ExtractFieldHelper.SetFields(Session.Data);
  CurrentAccount := ExtractFieldHelper.GetField(f_Number);
  AccountType := ExtractFieldHelper.GetField(f_AccountType);

  if (AccountType <> IntToStr(btBank)) then
  begin
    Result := er_OK;
    Exit; // Don't include journals
  end;

  OpenBalance := ExtractFieldHelper.GetField(f_Balance);
  BalanceDate := ExtractFieldHelper.GetField(f_Date);

  // Don't create the balance node if the account balance amount is unknown
  if (ExtractFieldHelper.GetField(f_IsUnknownAmount) <> '1') then
  begin
    BalanceNode := OutputDocument.CreateElement('Balance');
    BankBalancesNode.AppendChild(BalanceNode);
    AddFieldNode(BalanceNode, 'BalanceDate', BalanceDate);
    if OpenBalance = '' then
      OpenBalance := '0';
    AddFieldNode(BalanceNode, 'BalanceAmount', OpenBalance);
    ProcessDiskCode(CurrentAccount, BSB, AccountNum);
    AddFieldNode(BalanceNode, 'BSB', BSB);
    AddFieldNode(BalanceNode, 'Bank_Account_No', AccountNum);
    AddFieldNode(BalanceNode, 'Balance_Type', '10'); // 10 = Opening Balance, 15 = Closing Balance
  end;
  Result := er_OK;
end;


//******************************************************************************
//
//   TRANSACTION / DISSECTION
//
//******************************************************************************


const // from bkConst // did not want to link it in...
   btBank            = 0; btMin = 0;
   btCashJournals    = 1;
   btAccrualJournals = 2;
   btGSTJournals     = 3;
   btStockJournals   = 4;          //non transferring
   btOpeningBalances = 5;          //non transferring
   btYearEndAdjustments = 6;       //non transferring
   btStockBalances = 7;

procedure WriteBGLFields(var Session: TExtractSession; var TestNode: IxmlNode; TestRun: boolean = false);
var
  AccountNum : String;
  BSB        : String;
  LTrans     : IXMLNode;

  procedure AddField(const Name,Value: string; AllowEmpty: boolean = false);
  begin
     if (Value > '') or AllowEmpty then
        SetNodeTextStr(LTrans,Name,Value);
  end;

  procedure AddTaxClass(const Value: string);
  begin
     if Length(Value) > 0 then
        case Value[1] of
        '1' :AddField('GST_Rate','100%');
        '2' :AddField('GST_Rate','75%');
        //'3' :AddField('GST_Rate','48.5%');  // BGL Spec
        '3' :AddField('GST_Rate','46.5%');    // ATO See case 7664
        '4' :AddField('GST_Rate','0% (ITD)');
        '5' :AddField('GST_Rate','0% (ITA)');
        '6' :AddField('GST_Rate','GST Free');
        else AddField('GST_Rate','N/A');
        end
     else
        AddField('GST_Rate','N/A')
  end;

  procedure AddGuid(const Value: string);
  var id: string;
      i,o : integer;
  begin   //1234567890123456789
     id := '               ';
     o := Length(id);
     for i := Length(Value) downto 1 do begin
        if Value[i] in ['0'..'9', 'A'..'F'] then begin
           id[o] := Value[i];
           dec(o);
           if o < 1 then
              Break; // Thats all we can fit..
        end;
     end;
     AddField('Other_Reference',id);
  end;

  procedure AddCode(const Value: string);
  begin
     if Value = '' then
        AddField('Account_Code',DefaultCode)
     else
        AddField('Account_Code',Value);
  end;

  procedure AddText;
  var Ref, Nar: string;
  begin

      Nar := ExtractFieldHelper.GetField(f_Narration);
      Ref := ExtractFieldHelper.GetField(f_ChequeNo);
      if Ref > '' then
         if Nar > '' then
            Ref := Nar + ' BL Ref: ' + Ref
         else
            Ref := 'BL Ref: ' + Ref
      else
         Ref := Nar;

      AddField('Text',Ref,True);
  end;

  procedure StrToFile(const FileName, SourceString : string);
  var
    Stream : TFileStream;
  begin
    Stream:= TFileStream.Create(FileName, fmCreate);
    try
      Stream.WriteBuffer(Pointer(SourceString)^, Length(SourceString));
    finally
      Stream.Free;
    end;
  end;

begin
  if TestRun then
  begin
    StartFile;
    TransactionsNode := OutputDocument.CreateElement('Transactions');
  end;

  LTrans := TransactionsNode.AppendChild(FOutputDocument.CreateElement('Transaction'));

   with ExtractFieldHelper do begin
     AddField('Transaction_Type','Other Transaction');
     AddField('Account_Code_Type','Simple Fund');

     if TestRun then
       SetFields(Session.Data);

     AddGuid(Uppercase(GetField(f_TransID)));

     ProcessDiskCode(CurrentAccount, BSB, AccountNum);
     AddField('BSB', BSB);
     AddField('Bank_Account_No', AccountNum);

     AddField('Transaction_Source','Bank Statement');

     if Session.AccountType in [btBank,btCashJournals] then
        AddField('Cash','Cash')
     else
        AddField('Cash','Non Cash');

     AddCode(GetField(f_Code));

     AddField('Transaction_Date',GetField(f_Date));

     AddText;

     AddField('Amount',GetField(f_amount, '0'), True);
     AddField('GST',GetField(f_tax));
     AddTaxClass(GetField(f_TaxCode));

     AddField('Quantity',GetField(f_Quantity));

     // Supper fields
     AddField('CGT_Transaction_Date',GetField(f_CGTDate));
     AddField('Franked_Dividend',GetField(f_Franked));
     AddField('UnFranked_Dividend',GetField(f_UnFranked));
     AddField('Imputation_Credit',GetField(f_Imp_Credit));

     AddField('Tax_Free_Distribution',GetField(f_TF_Dist));

     AddField('Tax_Exempt_Distribution',GetField(f_TE_Dist));
     AddField('Tax_Defered_Distribution',GetField(f_TD_Dist));
     AddField('TFN_Credit',GetField(f_TFN_Credit));
     AddField('Foreign_Income',GetField(f_Frn_Income));
     AddField('Foreign_Credit',GetField(f_Frn_Credit));

     AddField('Expenses',GetField(f_OExpences));

     AddField('Indexed_Capital_Gain',GetField(f_CGI));
     AddField('Discount_Capital_Gain',GetField(f_CGD));
     AddField('Other_Capital_Gain',GetField(f_CGO));
     AddField('Member_Component',GetField(f_MemComp));
   end;

   if TestRun then
     TestNode := TransactionsNode;
end;



function Transaction(var Session: TExtractSession): Integer; stdcall;
var
  TestNode: IXmlNode;
begin
   ExtractFieldHelper.SetFields(Session.Data);
   case Session.Index of
   BGL360:  WriteBGLFields(Session, TestNode);
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
                        BGL360: Result := TrapException(Session,BGLSessionStart);
                      end;
   ef_SessionEnd    : Result := TrapException(Session,SessionEnd);

   ef_ClientStart   :Result := TrapException(Session,ClientStart);
   ef_ClientEnd     :Result := TrapException(Session,ClientEnd);
   ef_AccountStart  :Result := TrapException(Session,AccountStart);
   //ef_AccountEnd    :Result := TrapException(Session,Transaction);

   ef_Transaction   :Result := TrapException(Session,Transaction);
   ef_Dissection    :Result := TrapException(Session,Transaction);

   ef_CanConfig    : case Session.Index of
                       BGL360: begin // Also Doubles as get initial settings...
                            DefaultCode := GetPrivateProfileText(BGL360code, keyExtractCode,'91000', Session.IniFile);
                            CodedOnly :=  GetPrivateProfileInt(BGL360code,keyCodedOnly,0,Session.IniFile) = 1;
                            Result := er_OK;
                       end;
                     end;
   ef_DoConfig     : case Session.Index of
                       BGL360: Result := DoBGL360Config(Session);
                     end;

   end;

end;



//*****************************************************************************
//
//    Optional Export Procedures..
//
//*****************************************************************************


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
  FOutputDocument := nil;
  TransactionsNode := nil;
  BaseNode := nil;

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

   FOutputDocument := nil;
   TransactionsNode := nil;
   BaseNode := nil;
end.
