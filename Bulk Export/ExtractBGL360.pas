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
  Classes,
  IniFiles;     

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
   ExtractAccountAs: string;
   OpenBalance: string;
   BalanceDate: string;
   CurrentContra: string;
   DefaultCode: string;
   DateText: string;

var
   FExtractFieldHelper: TExtractFieldHelper;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//***************************************************************************//
// NB!!! This code has had to be duplicated from the Database/Software.pas   //
// file. The reason is because that unit includes presentation layer unit's  //
// in it's uses clause  - DN 30/11/2015                                      //
//***************************************************************************//
Function CanExtractAccountNumberAs( aCountry, aType : Byte ) : boolean;
begin
   result := false;
   Case aCountry of
      whNewZealand   : result := false;
      whAustralia    : If aType in [ saBGL360 ] then
                          result := true;
   end;
end;

(**********************************************)
procedure RetrieveBSBAndAccountNum( aExtractAccountNumberAs, aBankAccountNumber: string; var aBSB, aAccountNumber : string );
var
  lsBSB,
  lsAccountNumber : string;

  function StripOutBSBAndAccountNum( aInStr : string; var aBSB, aAccountNumber : string ) : boolean;
  begin
    result := false;
    aInStr := Trim( aInStr );
    if length( aInStr ) < 7 then // String is too short
      exit
    else begin
      aBSB := copy( aInStr, 1, 6 ); // BSB Number is the first 6 characters
      aAccountNumber := copy( aInStr, 7, length( aInStr ) ); // Account Number is the rest
      result := ( length( aBSB ) > 0 ) and ( length( aAccountNumber ) > 0 );
    end;
  end;
begin
  aExtractAccountNumberAs :=                                         // Get the ExtractAccountNumberAS regardless
    StringReplace( aExtractAccountNumberAs, ' ', '',
      [ rfReplaceAll, rfIgnoreCase ] );

  ProcessDiskCode( trim( aBankAccountNumber ),
    lsBSB, lsAccountNumber);                                         // Get the normal Bank Account number

  if

     {**************************************************************************
      /////////////////////////////////////////////////////
      //No longer necessary, ExtractNumberAs is passed in//
      /////////////////////////////////////////////////////

     (not CanExtractAccountNumberAs(                        // ExtractAccountNumberAs field CANNOT be used, get Normals
            MyClient.clFields.clCountry,
            MyClient.clFields.clAccounting_System_Used) ) or          // Else ExtractAccountNumberAs field can be used BUT,
     **************************************************************************}

     ( aExtractAccountNumberAs = '' ) or                            // ExtractAccountNumberAs is blank
     ( not StripOutBSBAndAccountNum(                                // ExtractAccountNumberAs field can be used BUT is in the incorrect format
             aExtractAccountNumberAs, aBSB, aAccountNumber ) ) then begin
    aBSB           := lsBSB;                                         // Use the normal BSB number
    aAccountNumber := lsAccountNumber;                               // Use the normal Bank Account number
  end;
end; (******************************************************)

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
   SetNodeTextStr(BaseNode,'Import_Export_Version','5.2');

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
  ExtractFieldHelper.SetFields( Session.Data );
  CurrentAccount := ExtractFieldHelper.GetField( f_Number );
//BulkExtract
  ExtractAccountAs := ExtractFieldHelper.GetField( f_ExtractNumberAs );

  AccountType := ExtractFieldHelper.GetField( f_AccountType );

  if (AccountType <> IntToStr( btBank )) then
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
type
  TTransactionTypes = (ttDistribution, ttDividend, ttInterest, ttShareTrade, ttOtherTx );

var
  AccountNum : String;
  BSB        : String;
  LTrans     : IXMLNode;
  ContraEntries: IXMLNode;
  Entry: IXMLNode;
  EntryTypeDetail: IXMLNode;
  TransactionTypeNode : IXMLNode;
  sAcctHead : string;
  iAccountCode : Integer;
  TransType : TTransactionTypes;
  lsTemp : string;

const
  cttanDistribution = 23800;
  cttanDividend     = 23900;
  cttanInterest     = 25000;
//  cttanShareTrade   = 70000;
  cttanShareTradeRangeStart   = 70000;
  cttanShareTradeRangeEnd     = 79999;

  procedure AddFieldNode(var ToNode: IxmlNode; const Name, Value: string; AllowEmpty: boolean = false);
  begin
    if (Value <> '') or AllowEmpty then
      SetNodeTextStr(ToNode,Name,Value);
  end;

//BulkExport  procedure AddFieldNode(const Name,Value: string; AllowEmpty: boolean = false);
//BulkExport  begin
//BulkExport     if (Value > '') or AllowEmpty then
//BulkExport        SetNodeTextStr(LTrans,Name,Value);
//BulkExport  end;

  procedure AddAccountCodeNode(var aNode: IXMLNode; AccountCode: string);
  const
    PRACTICEINIFILENAME = 'BK5PRAC.INI';    //DATADIR
  var
    PracIniFile: TIniFile;
    ExecDir : string;

  begin
    if (AccountCode = '') then
    begin
      ExecDir                   := ExtractFilePath(Application.ExeName);
      PracIniFile := TIniFile.Create(ExecDir + PRACTICEINIFILENAME);
      try
        AccountCode := PracIniFile.ReadString(BGL360code, 'ExtractCode', '91000');
        if AccountCode = '' then
          AccountCode := '91000'; // default account code for uncoded transactions
      finally
        PracIniFile.Free;
      end;
    end;
    AddFieldNode(aNode, 'Account_Code', AccountCode);
  end;

  procedure AddTaxClass(var ToNode: IxmlNode; const Value: string);
  begin
     if Length(Value) > 0 then
        case Value[1] of
        '1' :AddFieldNode( LTrans, 'GST_Rate','100%');
        '2' :AddFieldNode( LTrans, 'GST_Rate','75%');
        //'3' :AddField('GST_Rate','48.5%');  // BGL Spec
        '3' :AddFieldNode( LTrans, 'GST_Rate','46.5%');    // ATO See case 7664
        '4' :AddFieldNode( LTrans, 'GST_Rate','0% (ITD)');
        '5' :AddFieldNode( LTrans, 'GST_Rate','0% (ITA)');
        '6' :AddFieldNode( LTrans, 'GST_Rate','GST Free');
        else AddFieldNode( LTrans, 'GST_Rate','N/A');
        end
     else
        AddFieldNode( ToNode, 'GST_Rate','N/A')
  end;

  procedure AddGuid(var ToNode: IxmlNode; const Value: string);
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
//BulkExtract     AddField('Other_Reference',id);
     AddFieldNode( ToNode, 'Unique_Reference',id);
  end;

  procedure AddCode(var ToNode: IxmlNode; const Value: string);
  begin
     if Value = '' then
        AddFieldNode( ToNode, 'Account_Code',DefaultCode)
     else
        AddFieldNode( ToNode, 'Account_Code',Value);
  end;

  procedure AddText( var ToNode: IxmlNode);
  const
    GetMaxNarrationLength = 150;

  var
    Ref,
    Nar: string;
    NarrationLength : integer;

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

    if GetMaxNarrationLength <= 150 then
      NarrationLength := GetMaxNarrationLength
    else
      NarrationLength := 150;

    Ref := copy( Ref, 1, NarrationLength );
    AddFieldNode( ToNode, 'Text',Ref,True);
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

  function StripBGL360ControlAccountCode( Value : string ) : integer;
  var
    liPos  : integer;
    lsControlCode : string;
  begin
    Result := 0;
    Value := trim( Value );
    if Value <> '' then begin
      liPos := pos( '/', Value);  // Fetch the control account code, if this is a sub account type
      if liPos = 0 then           // Not a sub account type, so fetch the whole code
        lsControlCode := Value
      else
        lsControlCode := copy( Value, 1, pred( liPos ) ); // Fetch the first characters (or the whole acocunt code if not a sub account)
      result := StrToIntDef(  lsControlCode ,0 );
    end;
  end;

  Procedure AddShareTradeEntities;//(var TransactionNode: IXMLNode);
  const
    ThisMethodName = 'AddShareTradeEntities';
  begin
    with ExtractFieldHelper do begin
      // Units
      AddFieldNode(TransactionTypeNode, fBGL360_Units,
        GetField( fBGL360_Units, '' ), True );
      // Contract_date
      AddFieldNode(TransactionTypeNode, fBGL360_Contract_date,
        GetField( fBGL360_Contract_date, '' ) );
      // Settlement_date
      AddFieldNode(TransactionTypeNode, fBGL360_Settlement_date,
        GetField( fBGL360_Settlement_date, '' ) );
      // Brokerage
      AddFieldNode( TransactionTypeNode, fBGL360_Brokerage,
        GetField( fBGL360_Brokerage, '' ) );
      // GST_Rate
      if Trim(GetField( fBGL360_GST_Rate, '0' ) ) <> '0'  then
        AddFieldNode(
          TransactionTypeNode,
          fBGL360_GST_Rate,
          GetField( fBGL360_GST_Rate, '' ) );
      // GST_Amount
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_GST_Amount,
        GetField( fBGL360_GST_Amount, '' ) );
      // Consideration
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Consideration,
        GetField( fBGL360_Consideration, '' ) );
    end;
  end;

  Procedure AddInterestEntities;//(var TransactionTypeNode: IXMLNode);
  const
    ThisMethodName = 'AddInterestEntities';
  begin
    with ExtractFieldHelper do begin
      // Interest
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Interest,
        GetField( fBGL360_Interest, '' ) );
      // Other_Income
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Other_Income,
        GetField( fBGL360_Other_Income, '' ) );
      // TFN_Amounts_withheld
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_TFN_Amounts_withheld,
        GetField( fBGL360_TFN_Amounts_Withheld, '' ) );
      // Non_Resident_Withholding_Tax
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Non_Resident_Withholding_Tax,
        GetField( fBGL360_Non_Resident_Withholding_Tax, '' ) );
    end;
  end;

  Procedure AddDividendEntities(IsDissection:Boolean=False);//(var TransactionTypeNode: IXMLNode);
  const
    ThisMethodName = 'AddDividendEntities';
  begin
    with ExtractFieldHelper do begin
      // Dividends_Franked
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Dividends_Franked,
        GetField( fBGL360_Dividends_Franked, '' ), True );
      // Dividends_Unfranked
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Dividends_Unfranked,
        GetField( fBGL360_Dividends_Unfranked, '' ), True );
      // Franking_Credits
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Franking_Credits,
        GetField( fBGL360_Franking_Credits, '' ), True );
      // Assessable_Foreign_Source_Income
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Assessable_Foreign_Source_Income,
        GetField( fBGL360_Assessable_Foreign_Source_Income, '' ) );
      // Foreign_Income_Tax_Paid_Offset_Credits
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Foreign_Income_Tax_Paid_Offset_Credits,
        GetField( fBGL360_Foreign_Income_Tax_Paid_Offset_Credits, '' ) );
      // Australian_Franking_Credits_from_a_New_Zealand_Company
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Australian_Franking_Credits_from_a_New_Zealand_Company,
        GetField( fBGL360_Australian_Franking_Credits_from_a_New_Zealand_Company, '' ) );
      // TFN_Amounts_withheld
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_TFN_Amounts_withheld,
        GetField( fBGL360_TFN_Amounts_withheld, '' ) );
      // Non_Resident_Withholding_Tax
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Non_Resident_Withholding_Tax,
        GetField( fBGL360_Non_Resident_Withholding_Tax, '' ) );
      // LIC_Deduction
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_LIC_Deductions,
        GetField( fBGL360_LIC_Deductions, '' ) );
    end;
  end;

  Procedure AddDistributionEntities(IsDissection:Boolean=False);//(var TransactionTypeNode: IXMLNode);
  const
    ThisMethodName = 'AddDistributionEntities';
  begin
    with ExtractFieldHelper do begin
      // Dividends_Franked
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Dividends_Franked,
        GetField( fBGL360_Dividends_Franked, '' ) );
      // Dividends_Unfranked
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Dividends_Unfranked,
        GetField( fBGL360_Dividends_Unfranked, '' ) );
      // Franking_Credits
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Franking_Credits,
        GetField( fBGL360_Franking_Credits, '' ) );
      // Interest
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Interest,
        GetField( fBGL360_Interest, '' ) );
      // Other_Income
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Other_Income,
        GetField( fBGL360_Other_Income, '' ) );

      // Less_Other_Allowable_Trust_Deductions
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Less_Other_Allowable_Trust_Deductions,
        GetField( fBGL360_Less_Other_Allowable_Trust_Deductions, '' ) );
      // Discounted_Capital_Gain_Before_Discount
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Discounted_Capital_Gain_Before_Discount,
        GetField( fBGL360_Discounted_Capital_Gain_Before_Discount, '' ) );
      // Capital_Gains_CGT_Concessional_Amount
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Capital_Gains_CGT_Concessional_Amount,
        GetField( fBGL360_Capital_Gains_CGT_Concessional_Amount, '' ) );
      // Capital_Gain_Indexation_Method
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Capital_Gain_Indexation_Method,
        GetField( fBGL360_Capital_Gain_Indexation_Method, '' ) );
      // Capital_Gain_Other_Method
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Capital_Gain_Other_Method,
        GetField( fBGL360_Capital_Gain_Other_Method, '' ) );
      // Foreign_Discounted_Capital_Gains_Before_Discount
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount,
        GetField( fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount, '' ) );
      // Foreign_Capital_Gains_Indexation_Method
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Foreign_Capital_Gains_Indexation_Method,
        GetField( fBGL360_Foreign_Capital_Gains_Indexation_Method, '' ) );
      // Foreign_Capital_Gains_Other_Method
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Foreign_Capital_Gains_Other_Method,
        GetField( fBGL360_Foreign_Capital_Gains_Other_Method, '' ) );

      // Foreign_Discounted_Capital_Gains_Before_Discount_Tax_Paid
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount_Tax_Paid,
        GetField( fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount_Tax_Paid, '' ) );
      // Foreign_Capital_Gains_Indexation_Method_Tax_Paid
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Foreign_Capital_Gains_Indexation_Method_Tax_Paid,
        GetField( fBGL360_Foreign_Capital_Gains_Indexation_Method_Tax_Paid, '' ) );
      // Foreign_Capital_Gains_Other_Method_Tax_Paid
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Foreign_Capital_Gains_Other_Method_Tax_Paid,
        GetField( fBGL360_Foreign_Capital_Gains_Other_Method_Tax_Paid, '' ) );

      // Assessable_Foreign_Source_Income
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Assessable_Foreign_Source_Income,
        GetField( fBGL360_Assessable_Foreign_Source_Income, '' ) );
      // Foreign_Income_Tax_Paid_Offset_Credits
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Foreign_Income_Tax_Paid_Offset_Credits,
        GetField( fBGL360_Foreign_Income_Tax_Paid_Offset_Credits, '' ) );
      // Australian_Franking_Credits_from_a_New_Zealand_Company
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Australian_Franking_Credits_from_a_New_Zealand_Company,
        GetField( fBGL360_Australian_Franking_Credits_from_a_New_Zealand_Company, '' ) );
      // Other_Net_Foreign_Source_Income
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Other_Net_Foreign_Source_Income,
        GetField( fBGL360_Other_Net_Foreign_Source_Income, '' ) );
      // Cash_Distribution
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Cash_Distribution,
        GetField( fBGL360_Cash_Distribution, '' ) );
      // Tax_Exempted_Amounts
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Tax_Exempted_Amounts,
        GetField( fBGL360_Tax_Exempted_Amounts, '' ) );
      // Tax_Free_Amounts
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Tax_Free_Amounts,
        GetField( fBGL360_Tax_Free_Amounts, '' ) );
      // Tax_Deferred_amounts
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Tax_Deferred_amounts,
        GetField( fBGL360_Tax_Deferred_amounts, '' ) );
      // TFN_Amounts_withheld
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_TFN_Amounts_withheld,
        GetField( fBGL360_TFN_Amounts_withheld, '' ) );
      // Non_Resident_Withholding_Tax
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Non_Resident_Withholding_Tax,
        GetField( fBGL360_Non_Resident_Withholding_Tax, '' ) );
      // Other_Expenses
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Other_Expenses,
        GetField( fBGL360_Other_Expenses, '' ) );
      // LIC_Deduction
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_LIC_Deductions,
        GetField( fBGL360_LIC_Deductions, '' ) );
      // Discounted_Capital_Gain_Before_Discount_Non_Cash
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Discounted_Capital_Gain_Before_Discount_Non_Cash,
        GetField( fBGL360_Discounted_Capital_Gain_Before_Discount_Non_Cash, '' ) );
      // Capital_Gains_Indexation_Method_Non_Cash
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Capital_Gains_Indexation_Method_Non_Cash,
        GetField( fBGL360_Capital_Gains_Indexation_Method_Non_Cash, '' ) );
      // Capital_Gains_Other_Method_Non_Cash
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Capital_Gains_Other_Method_Non_Cash,
        GetField( fBGL360_Capital_Gains_Other_Method_Non_Cash, '' ) );
      // Capital_Losses_Non_Cash
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_Capital_Losses_Non_Cash,
        GetField( fBGL360_Capital_Losses_Non_Cash, '' ) );
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
    AddFieldNode( LTrans, 'Transaction_Type','Bank_Transaction');

    if TestRun then
      SetFields(Session.Data);

    AddGuid( LTrans, Uppercase(GetField(f_TransID)));

    // BSB and Bank_Account_No
    RetrieveBSBAndAccountNum(
      GetField( f_ExtractNumberAs ),
      CurrentAccount,
      BSB, AccountNum );


    AddFieldNode( LTrans, 'BSB', BSB);
    AddFieldNode( LTrans, 'Bank_Account_No', AccountNum);

                                                  ;
    AddFieldNode( LTrans, 'Transaction_Date',GetField(f_Date));

    AddText( LTrans );

    AddFieldNode( LTrans, 'Amount',
      SwapNegAndPosAmounts( GetField(f_amount, '0') ),
      True);

    ContraEntries := OutputDocument.CreateElement('Contra_Entries');

    LTrans.AppendChild(ContraEntries);
    // Entry
    Entry := OutputDocument.CreateElement('Entry');
    ContraEntries.AppendChild(Entry);

    iAccountCode := StripBGL360ControlAccountCode( GetField(f_Code) );

    if iAccountCode = cttanDistribution then
    begin
      sAcctHead := 'Distribution_Transaction';
      TransType := ttDistribution;
    end
    else if iAccountCode = cttanDividend then
    begin
      sAcctHead := 'Dividend_Transaction';
      TransType := ttDividend;
    end
    else if iAccountCode = cttanInterest then
    begin
      sAcctHead := 'Interest_Transaction';
      TransType := ttInterest;
    end
    else if ( iAccountCode >= cttanShareTradeRangeStart ) and
            ( iAccountCode <= cttanShareTradeRangeEnd ) then //DN Refactored out, since range was introduced ((AccountCode >= cttanShareTradeRangeStart) and (AccountCode <= cttanShareTradeRangeEnd)) then
    begin
      sAcctHead := 'Share_Trade_Transaction';
      TransType := ttShareTrade;
    end
    else
    begin
      sAcctHead := 'Other_Transaction';
      TransType := ttOtherTx;
    end;

    // Entry_Type
    AddFieldNode(Entry, 'Entry_Type', sAcctHead);

    // Entry_Type_Detail
    EntryTypeDetail := OutputDocument.CreateElement('Entry_Type_Detail');
    Entry.AppendChild(EntryTypeDetail);

    TransactionTypeNode := OutputDocument.CreateElement(sAcctHead);
    EntryTypeDetail.AppendChild(TransactionTypeNode);

    AddCode(TransactionTypeNode, GetField(f_Code));
//    AddFieldNode( TransactionTypeNode, 'Amount', GetField(f_amount, '0'), true);



    if TransType in [ ttDividend, ttDistribution] then
    begin
      // AccrualDate
      AddFieldNode(TransactionTypeNode, fBGL360_Accrual_Date,
        GetField( fBGL360_Accrual_Date, '' ), false );
      // CashDate
      AddFieldNode(TransactionTypeNode, fBGL360_Cash_Date,
        GetField( fBGL360_Cash_Date, '' ), false );
      // RecordDate
      AddFieldNode(TransactionTypeNode, fBGL360_Record_Date,
        GetField( fBGL360_Record_Date, '' ), false );
    end
    else if TransType = ttInterest then
    begin
      if Trim(GetField(f_amount, '')) = '' then
      begin
        AddFieldNode(LTrans, 'BSB', BSB);
        AddFieldNode(LTrans, 'Bank_Account_No', AccountNum);
      end;
    end;

    // Amount
    AddFieldNode( TransactionTypeNode, f_Amount,
      GetField(f_amount, '0'),
      True);

(*
    lsTemp := GetField( fBGL360_GST_Amount, '0' );
    // Output GST?
//    if ((TransType= ttOtherTx) and (strToInt( GetField( fBGL360_GST_Amount, '0' ) )  <> 0)) then
    if ((TransType= ttOtherTx) and (strToInt( lsTemp )  <> 0)) then
    begin
      // GST_Amount
      AddFieldNode(
        TransactionTypeNode,
        fBGL360_GST_Amount,
        GetField( fBGL360_GST_Amount ), false );
    end;
*)
    if TransType = ttDistribution then
      AddDistributionEntities()
    else if TransType = ttDividend then
      AddDividendEntities()
    else if TransType = ttInterest then
      AddInterestEntities()
    else if TransType = ttShareTrade then
      AddShareTradeEntities();
(*(*(*(*(*(**}*}*}*}*}*)






(*    AddFieldNode( LTrans, 'GST',GetField(f_tax));
    AddTaxClass(GetField(f_TaxCode));

    AddFieldNode( LTrans, 'Quantity',GetField(f_Quantity));

    // Supper fields
    AddFieldNode( LTrans, 'CGT_Transaction_Date',GetField(f_CGTDate));
    AddFieldNode( LTrans, 'Franked_Dividend',GetField(f_Franked));
    AddFieldNode( LTrans, 'UnFranked_Dividend',GetField(f_UnFranked));
    AddFieldNode( LTrans, 'Imputation_Credit',GetField(f_Imp_Credit));

    AddFieldNode( LTrans, 'Tax_Free_Distribution',GetField(f_TF_Dist));

    AddFieldNode( LTrans, 'Tax_Exempt_Distribution',GetField(f_TE_Dist));
    AddFieldNode( LTrans, 'Tax_Defered_Distribution',GetField(f_TD_Dist));
    AddFieldNode( LTrans, 'TFN_Credit',GetField(f_TFN_Credit));
    AddFieldNode( LTrans, 'Foreign_Income',GetField(f_Frn_Income));
    AddFieldNode( LTrans, 'Foreign_Credit',GetField(f_Frn_Credit));

    AddFieldNode( LTrans, 'Expenses',GetField(f_OExpences));

    AddFieldNode( LTrans, 'Indexed_Capital_Gain',GetField(f_CGI));
    AddFieldNode( LTrans, 'Discount_Capital_Gain',GetField(f_CGD));
    AddFieldNode( LTrans, 'Other_Capital_Gain',GetField(f_CGO));
    AddFieldNode( LTrans, 'Member_Component',GetField(f_MemComp)); *)


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
