unit MYOBAO;
//------------------------------------------------------------------------------
{
   Title:       MYOB Accountants Office Import Unit

   Description: MYOB Accountants Office Import Unit

   Remarks:    Special Features - Add BAS setup rules automatically if possible

               MYOB AO uses the following fields and flags.  It is based on the
               CA System interface.

               GL_ACCT table

               ACC_TYPE     Account Type
               ACC_GSTIND   GST Indicator
               ACC_EXBAS    Exclude from Bas Boolean
               ACC_EXPORT   Export
               ACC_INBAS    Include on Bas as Capital Acq
               ACC_NONDED   Non deductible expense
               ACC_TAXED    Input Taxed


               GL_CONFG table

               ACC_GSTCAD   Credit adjustment account
               ACC_GSTDAD   Debit adjustment account
               ACC_GSTPRI   Private use adjustment account

               The gst indicator can be I   input tax
                                        O   output tax
                                        E   Input taxed
                                        Z   Zero rated

               We map the information in the chart table to 20 gst classes
               that have been setup using the template.

               The import also adds rule to the bas setup which allows the calculation
               of the adjustment amounts.

               Contacts are:     Don Hounsell        don@housnell.co.nz
                                 Martin Etherington  martin_etherington@myob.co.nz

   Author:     Matthew  Aug 00

   Revisions:  ** MYOB AO COM interface added july 2005

               This interface requires the bclink.dll file to be installed on the
               workstation.  If the com interface is available then BK5 will use
               it, otherwise the existing MYOB AO 7 interface will be used.

               The COM interface does not produce or use any intermediate files.
               All information such as the chart or extracted data is exchanged
               via XML strings.

               The interface no longer needs to know the location of the AO
               software and data as this is handled by the bclink.dll.


               The interface supports chart refresh, setting of the banklink id
               in AO and extracting data.


               ** MYOB AO COM interface supported for NZ



}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
uses
  chList32;

procedure RefreshChart;

{$IFDEF BK_UNITTESTINGON}
procedure ProcessXMLChart_AU( xmlChart : string; NewChart: TChart; var HasDuplicates : boolean);
procedure ProcessXMLChart_NZ( xmlChart : string; NewChart: TChart; var HasDuplicates : boolean);
{$ENDIF}

//******************************************************************************
implementation

uses
  Globals,
  sysutils,
  InfoMoreFrm,
  bkconst,
  bkchio,
  bkdefs,
  ovcDate,
  GenUtils,
  ErrorMorefrm,
  dBaseReader,
  WarningMorefrm,
  ChartUtils,
  classes,
  LogUtil,
  YesNoDlg,
  bk5Except,
  Dialogs,
  bkDateUtils,
  Progress,
  CAUtils,
  BKUtil32,
  glConst,
  BasUtils,
  MoneyDef,
  MyobAO_Utils,
  Software,
  Templates,
  WinUtils,
  OmniXML,
  OmniXMLUtils,
  XMLUtils;

const
   MYOBAO_CONFIG = 'GL_CONFG.DBF';
   MYOBAO_FILE   = 'GL_ACCT.DBF';
   MYOBAO_EXTN   = 'DBF';
   MYOBAO_MASK   = '####';

   UnitName     = 'MYOBAO';
   DebugMe  : Boolean = False;

   //the following constants MUST match the MYOB AO BAS Template
   rtGSTPayable              = 1;            //G1
   rtExportSales             = 2;            //G2
   rtGSTFreeSupplies         = 3;            //G3
   rtInputTaxedSupplies      = 4;            //G4

   rtOtherAcq                = 5;            //G11
   rtCapitalAcq              = 6;            //G10
   rtAcqForInputTaxedSales   = 7;            //G13
   rtAcqForInputTaxedSalesC  = 8;            //G13
   rtAcqNoGSTInputTaxed      = 9;            //G14
   rtAcqNoGSTInputTaxedC     = 10;           //G14
   rtAcqNoGST                = 11;           //G14
   rtAcqNoGSTC               = 12;           //G14
   rtNonIncomeDeductableAcq  = 13;           //G15
   rtUnknownE                = 14;
   rtUnknownZ                = 15;
   rtUserDefined1            = 16;
   rtUserDefined2            = 17;
   rtUserDefined3            = 18;
   rtUserDefined4            = 19;
   rtNotUsed                 = 20;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TrimMYOBCode( aCode : BK5CodeStr) : Bk5CodeStr;
begin
  aCode := Trim(aCode);
  while(aCode<>'') and not (aCode[Length(aCode)] in ['0'..'9']) do
     aCode[0] := Pred(aCode[0]);
  result := aCode;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UpdateBasRule( BasFieldID : integer; AcctCode : Bk5CodeStr; Factor : integer);
//the adjustment accounts specified may need to be added to the BAS rules so that
//they appear on the bas form.
//If not account rules exist for the bas field then just add the rule based on
//the information provided.
//If account rules already exist then check to see if one already exists for
//this chart code.  Add a rule if not.
var
  RuleCount : integer;
  AddBasRule : boolean;
  BasRuleBalType    : byte;
  BasRulePercent    : Money;
begin
  AcctCode := TrimMYOBCode(AcctCode);
  AddBasRule := false;

  if AcctCode <> '' then begin
     //See if any account rules exist for the bas fields for this account
     RuleCount := BasUtils.BasRuleCount( BasFieldId, ruChartRules);
     if RuleCount = 0 then begin
        //no chart rules exists for this adjustment so add default
        AddBasRule := true;
     end
     else begin
        //see if rule exists for this chart code
        if not BasUtils.FindChartRule( BasFieldID, AcctCode, BasRuleBalType, BasRulePercent) then begin
           //no rule exists for this account so add default
           AddBasRule := true;
           //UserShouldCheckBasSetup := true;
        end;
     end;
     //new rule should be added
     if AddBasRule then
        BasUtils.AddNewRule( BasFieldID, bsFrom_Chart, AcctCode, blGross, Factor * 10000);  // Gross value * 11
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  CalculateGSTClass( GSTInd, AccTypeChar : Char; GST_ExBas, GST_Export,GST_CapitalAcq, GST_NonDed, GST_Taxed : boolean) : integer;
  ///Now match GST information to template fields to get gst class
  //
  // MYOB AO uses the Account Type, the GST Index and four flags to determine
  // where something should appear on the bas form.  We need to map those settings
  // to the GST Classes used by BankLink
begin
  result := 0;

  case GSTInd of
     //Input Tax GST Ind
     'I' : begin
         //determine if capital or other
         if GST_CapitalAcq then
            result := rtCapitalAcq   //g10
         else
            result := rtOtherAcq;    //g11
     end;
     //Output Tax GST Ind
     'O' : begin
        result := rtGSTPayable;
     end;

     //Input taxed GST Ind
     'E' : begin
        result := rtUnknownE;

        case AccTypeChar of
           'R' : begin //revenue
              if GST_ExBas then
                 result := rtInputTaxedSupplies;        // g4
           end;

           //expense
           'E' : begin
               if GST_NonDed then
                  result := rtNonIncomeDeductableAcq    // g15
               else if GST_Taxed then
                  result := rtAcqForInputTaxedSales     // g13
               else if (( not GST_Taxed) and
                        ( not GST_NonDed) and
                        ( not GST_ExBas)) then
                  result := rtAcqNoGSTInputTaxed        // g14
           end;
           //asset
           'A' : begin
               if GST_CapitalAcq then
                  if GST_Taxed then
                     result := rtAcqForInputTaxedSalesC // g13
                  else
                     result := rtAcqNoGSTInputTaxedC    // g14

           end;
        end;
     end;

     //Zero Rated GST Ind
     'Z' : begin
        result := rtUnknownZ;

        case AccTypeChar of
           'R' : begin  //revenue
               if GST_Export then
                  result := rtExportSales      //g2
               else
                  result := rtGSTFreeSupplies; //g3
           end;
           'E' : begin //expense
               if (not GST_Taxed) and
                  (not GST_NonDed) and
                  (not GST_ExBas) then
                  result := rtAcqNoGST;        // g14
           end;
           'A' : begin //asset
               if GST_CapitalAcq then
                  result := rtAcqNoGSTC;       // g14
           end;
        end;
     end;
     'N' : begin
        result := rtNotUsed;
     end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  CalculateGSTClass_NZ( GSTInd, AccTypeChar : Char) : integer;
  ///Now match GST information to gst class
begin
  case GSTInd of
    'I' : result := 1;    //input  = expenses
    'O' : result := 2;    //output = sales
    'E' : result := 3;
    'Z' : result := 4;
    'N' : result := 5;
  else
    result := 0;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure InsertIntoChart( newChart : TChart; aCode : bk5CodeStr; aDesc : string; aGST_Class : integer; aPosting : boolean; var HasDuplicates : boolean);
var
  NewAccount : pAccount_Rec;
begin
  //check if this is a duplicate code
  if newChart.FindCode( aCode) = nil then
  begin
     //insert new account into chart
     NewAccount := New_Account_Rec;
     with NewAccount^ do
     begin
       chAccount_Code        := aCode;
       chAccount_Description := aDesc;
       chGST_Class           := aGST_Class;
       chPosting_Allowed     := aPosting;

       if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, Format(' Inserting Code %s %s',[ aCode, aDesc]));
       newChart.Insert(NewAccount);
     end;
  end
  else
  begin
     HasDuplicates := true;
     LogUtil.LogMsg(lmInfo, UnitName, Format('Duplicate Code Found %s %s',[ aCode, aDesc ]));
  end;
end;

procedure LoadGSTTemplate( Chart : TChart);
var
  GSTCodesInChart : boolean;
  i : integer;
  TemplateFileName : string;
  TemplateError : TTemplateError;
begin
   //determine if gst codes in chart
   GSTCodesInChart := false;
   for i := 0 to Pred( Chart.ItemCount) do
      if Chart.Account_At(i)^.chGST_Class <> 0 then GSTCodesInChart := true;

   //import template
   if GSTCodesInChart
      and not( MyClient.GSTHasBeenSetup ) then
   begin
      TemplateFileName := GLOBALS.TemplateDir + 'MYOBAO.TPM';
      If BKFileExists( TemplateFileName ) then
        Template.LoadTemplate( TemplateFilename, tpl_DontCreateChart, TemplateError );
   end;
end;

procedure LoadDefaultGST_NZ( Chart : TChart);
var
  GSTCodesInChart : boolean;
  i : integer;
begin
   //determine if gst codes in chart
   GSTCodesInChart := false;
   for i := 0 to Pred( Chart.ItemCount) do
      if Chart.Account_At(i)^.chGST_Class <> 0 then GSTCodesInChart := true;

   //import template
   if GSTCodesInChart and not( MyClient.GSTHasBeenSetup ) then
   begin
     with MyClient.clFields do
     begin
       //gst has not been setup, so put in some defaults
       clGST_Class_Names[1] := 'Purchases';
       clGST_Class_Types[1] := gtInputTax;   //E   expense
       clGST_Class_Codes[1] := 'I';

       clGST_Class_Names[2] := 'Sales';
       clGST_Class_Types[2] := gtOutputTax ; //I   income
       clGST_Class_Codes[2] := 'O';

       clGST_Class_Names[3] := 'Exempt';
       clGST_Class_Types[3] := gtExempt;     //X   exempt
       clGST_Class_Codes[3] := 'E';

       clGST_Class_Names[4] := 'Zero Rated';
       clGST_Class_Types[4] := gtZeroRated;  //Z   zero rates
       clGST_Class_Codes[4] := 'Z';

       clGST_Class_Names[5] := 'Not Assigned';
       clGST_Class_Types[5] := gtUndefined;  //N   undefined
       clGST_Class_Codes[5] := 'N';

       clGST_Rates[1,1] := 125000;
       clGST_Rates[2,1] := 125000;
     end;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ReadDBaseFile(ClientRef : string; FilePath : string; Chart : TChart);
const
   ThisMethodName = 'ReadDBaseFile';
var
   reader        : tDBaseFile;
   i             : integer;
   Deleted       : boolean;
   Code          : Bk5CodeStr;
   Name          : ShortString;

   AccTypeChar   : Char;
   GSTInd        : Char;
   GST_ExBas     : Boolean;  //Exclude from BAS
   GST_Export    : Boolean;  //Export
   GST_CapitalAcq     : Boolean;  //Include in bas a capital adj
   GST_NonDed    : Boolean;  //Non deductable expense
   GST_Taxed     : Boolean;  //Input Taxed
   GST_Class     : integer;

   return        : integer;
   ID            : ShortString;
   Msg           : String;
   HasDuplicates : boolean;   //has duplicate accounts codes in the dbase file

   CreditAdjAcct  : Bk5CodeStr;
   DebitAdjAcct   : Bk5CodeStr;
   PrivateAdjAcct : Bk5CodeStr;

begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   //check that requires GL files exist
   if not BKFileExists(FilePath + MYOBAO_CONFIG) then begin
      Msg := Format( 'The Configuration File %s%s cannot be found.',[ FilePath, MYOBAO_CONFIG ] );
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
      Raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
   end;
   if not BKFileExists(FilePath + MYOBAO_FILE) then begin
      Msg := Format( 'The Account File %s%s cannot be found.',[ FilePath, MYOBAO_FILE ] );
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
      Raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
   end;

   //Read Config File.  This holds the gst percentages and the adjustment accounts
   //Verify that the banklink id file is set correctly in the file and that it is
   //for this current client.
   reader := tDBaseFile.Create(FilePath + MYOBAO_CONFIG);
   try
      with Reader do begin
         GotoRecord(1);
         Return := GetField('BANKMANID',StringCType,ID);

         if Return <> 0 then begin
            Msg := Format( 'Cannot find BANKMANID field in chart file %s%s.',[ FilePath, MYOBAO_CONFIG ] );
            LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
            Raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
         end;

         id := Trim(id);
         if ID = '' then begin
            Msg := Format( 'The BANKMANID field is Blank in chart file %s%s.',[ FilePath, MYOBAO_CONFIG ] );
            LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
            Raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
         end;

         if ID <> ClientRef then begin
            Msg := Format( 'The Current client is %s. chart file %s%s is for client %s.',[ ClientRef, FilePath, MYOBAO_CONFIG, ID ] );
            LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
            Raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
         end;

         //read adjustment accounts
         if not (GetField('ACC_GSTCAD', StringCType, CreditAdjAcct) =0) then
            CreditAdjAcct := '';
         if (GetField('ACC_GSTDAD', StringCType, DebitAdjAcct) =0) then
            DebitAdjAcct := '';
         if (GetField('ACC_GSTPRI', StringCType, PrivateAdjAcct) =0) then
            PrivateAdjAcct := '';
      end;
   finally
     reader.Free;
   end;

   HasDuplicates := false;
   reader := tDBaseFile.Create(FilePath + MYOBAO_FILE);
   try
     with reader do for i := 1 to Header.NrOfRecs do begin
        gotoRecord(i);
        return := GetField(DelMarkName, BooleanCType, Deleted);
        if (return = 0) and not Deleted then begin
          code   := '';
          Name   := '';
          GSTInd := ' ';

          GetField('ACC_NO',StringCType,Code);
          Code := TrimMYOBCode(Code);
           if Code<>'' then begin
            GetField('ACC_DESC',StringCType,Name);
            GetField('ACC_TYPE', CharCType, AccTypeChar);
            Name   := Trim(Name);

            //read gst fields
            GetField( 'ACC_GSTIND',CharCType,GSTInd );

            GST_ExBas := false;
            GST_Export := false;
            GST_CapitalAcq := false;
            GST_NonDed := false;
            GST_Taxed := false;

            if not ( GetField( 'ACC_EXBAS',BooleanCType,GST_ExBas ) =0) then
               GST_ExBas := false;
            if not ( GetField( 'ACC_EXPORT',BooleanCType,GST_Export ) =0) then
               GST_Export := false;
            if not ( GetField( 'ACC_INBAS',BooleanCType,GST_CapitalAcq ) =0) then
               GST_CapitalAcq := false;
            if not ( GetField( 'ACC_NONDED',BooleanCType,GST_NonDed ) =0) then
               GST_NonDed := false;
            if not ( GetField( 'ACC_TAXED',BooleanCType,GST_Taxed ) =0) then
               GST_Taxed := false;

            //calculate gst class
            GST_Class := CalculateGSTClass( GSTInd, AccTypeChar, GST_ExBas, GST_Export, GST_CapitalAcq, GST_NonDed, GST_Taxed);

            //insert into chart, posting = true
            InsertIntoChart( Chart, Code, Name, GST_Class, True, HasDuplicates);
          end;
        end;
     end;
   finally
      reader.Free;
   end;

   if ( MyClient.clFields.clCountry = whAustralia ) then
   begin
     LoadGSTTemplate( Chart);

     //Update bas rules to include adjustment accounts
     //This should be done after the template has been loaded otherwise the fields will be overriden
     UpdateBasRule( bfG7, DebitAdjAcct, 11);
     UpdateBasRule( bfG18,CreditAdjAcct, 11);
     //the private use adjustments affect two bas fields
     UpdateBasRule( bfG11, PrivateAdjAcct, 1);
     UpdateBasRule( bfG15, PrivateAdjAcct, 1);
   end;

   if HasDuplicates then
      HelpfulWarningMsg( 'There were duplicate Account Codes in the select chart file. '#13#13+
                       SHORTAPPNAME + ' has ignored these codes.  A list of the duplicate codes has been '+
                       'written to the System Log.',0);

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetCdataNode( aNode : IXmlNode; aName : string; index : integer = -1) : string;
var
  s : string;
begin
  try
    result := GetNodeCData( bkSelectChildNode( aNode, aName));
  except
    on E : exception do
    begin
      s := 'Reading field ' + aName + ': ' + E.Message;
      //optionally record the index if coming from a list
      if index > -1 then
        s := s + ' (Index = ' + intToStr(index) + ')';
      raise EBkXMLError.Create( s);
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetDataNode( aNode : IXmlNode; aName : string; index : integer = -1) : string;
var
  s : string;
  n : IxmlNode;
begin
  try
    n := FindNode( aNode, aName);
    if assigned(n) then
      result := n.Text
    else
      raise Exception.Create( 'node not found');
  except
    On E : exception do
    begin
      s := 'Reading field ' + aName + ': ' + E.Message;
      //optionally record the index if coming from a list
      if index > -1 then
        s := s + ' (Index = ' + intToStr(index) + ')';
      raise EBkXMLError.Create( s);
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetBooleanField( aNode : IXmlNode; aName : string; index : integer = -1) : boolean;
var
  s : string;
begin
  s := GetDataNode( aNode, aName, index);

  if not(( s = '.T.') or ( s = '.F.') or ( s = '')) then
    raise EBkXMLError.Create( 'Unexpected boolean identifier "' + s + '" ( Index = ' + inttostr( index) + ')');

  result := ( s = '.T.');
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ProcessXMLChart_AU( xmlChart : string; NewChart: TChart; var HasDuplicates : boolean);
var
  xmlParser : IXMLDocument;
  AccountNode, n : IXmlNode;
  AccountsList : IXmlNodeList;
  i : integer;

  acCode : bk5CodeStr;
  acDesc : string;
  acGSTClass : integer;
  acGSTIndicator : string;
  acAccountType : string;
  charGSTInd : Char;
  charAcctInd : Char;
  acGst_ExBas,
  acGST_Export,
  acGST_Capital,
  acGST_NonDed,
  acGST_Taxed : boolean;


begin
  //initialise
  HasDuplicates := false;

  //translate xml chart into bk5 chart structure
  xmlParser := CreateXMLDoc;
  try
    xmlParser.PreserveWhiteSpace := false;
    if XMLLoadFromString( xmlParser, xmlChart) then
    begin
      n := bkSelectChildNode( xmlParser.FirstChild, 'Accounts');
      AccountsList := FilterNodes( n, 'Account');
      try
        for i := 0 to AccountsList.Length - 1 do
        begin
          AccountNode := AccountsList.Item[i];

          //read fields from for chart, all fields are expected to exist
          acCode := TrimMYOBCode( GetCDataNode( AccountNode, 'exp_1', i));
          if acCode <> '' then
          begin
            acDesc := Trim( GetCDataNode( AccountNode, 'acc_desc', i));
            acGSTIndicator := Trim(GetCDataNode( AccountNode, 'acc_gstind', i));
            acAccountType := Trim(GetCDataNode( AccountNode, 'acc_type', i));
            charGSTInd := ' ';
            charAcctInd := ' ';

            acGst_ExBas := GetBooleanField( AccountNode, 'acc_exbas', i);
            acGST_Export := GetBooleanField( AccountNode, 'acc_export', i);
            acGST_Capital := GetBooleanField( AccountNode, 'acc_inbas', i);
            acGST_NonDed := GetBooleanField( AccountNode, 'acc_nonded', i);
            acGST_Taxed := GetBooleanField( AccountNode, 'acc_taxed', i);

            //determine gst class from available information
            if acGSTIndicator <> '' then
              charGSTInd := acGSTIndicator[1];

            if acAccountType <> '' then
              charAcctInd := acAccountType[1];

            acGSTClass := CalculateGSTClass( charGSTInd, charAcctInd, acGst_ExBas, acGST_Export, acGST_Capital, acGST_NonDed, acGST_Taxed);

            //insert into chart, posting = true
            InsertIntoChart( NewChart, acCode, acDesc, acGSTClass, True, HasDuplicates);
          end;
        end;
      finally
        AccountsList := nil;
      end;
    end
    else
      raise EBkXMLError.Create( 'XML parse error: ' + xmlParser.ParseError.Reason);
  finally
    xmlParser := nil;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ProcessXMLChart_NZ( xmlChart : string; NewChart: TChart; var HasDuplicates : boolean);
var
  xmlParser : IXMLDocument;
  AccountNode, n : IXmlNode;
  AccountsList : IXmlNodeList;
  i : integer;

  acCode : bk5CodeStr;
  acDesc : string;
  acGSTClass : integer;
  acGSTIndicator : string;
  acAccountType : string;
  charGSTInd : Char;
  charAcctInd : Char;
begin
  //initialise
  HasDuplicates := false;

  //translate xml chart into bk5 chart structure
  xmlParser := CreateXMLDoc;
  try
    xmlParser.PreserveWhiteSpace := false;
    if XMLLoadFromString( xmlParser, xmlChart) then
    begin
      n := bkSelectChildNode( xmlParser.FirstChild, 'Accounts');
      AccountsList := FilterNodes( n, 'Account');
      try
        for i := 0 to AccountsList.Length - 1 do
        begin
          AccountNode := AccountsList.Item[i];

          //read fields from for chart, all fields are expected to exist
          acCode := TrimMYOBCode( GetCDataNode( AccountNode, 'exp_1', i));
          if acCode <> '' then
          begin
            acDesc := Trim( GetCDataNode( AccountNode, 'acc_desc', i));
            acGSTIndicator := Trim(GetCDataNode( AccountNode, 'acc_gstind', i));
            acAccountType := Trim(GetCDataNode( AccountNode, 'acc_type', i));
            charGSTInd := ' ';
            charAcctInd := ' ';

            //determine gst class from available information
            if acGSTIndicator <> '' then
              charGSTInd := acGSTIndicator[1];

            if acAccountType <> '' then
              charAcctInd := acAccountType[1];

            acGSTClass := CalculateGSTClass_NZ( charGSTInd, charAcctInd);

            //insert into chart, posting = true
            InsertIntoChart( NewChart, acCode, acDesc, acGSTClass, True, HasDuplicates);
          end;
        end;
      finally
        AccountsList := nil;
      end;
    end
    else
      raise EBkXMLError.Create( 'XML parse error: ' + xmlParser.ParseError.Reason);
  finally
    xmlParser := nil;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ReadChartFromBCLink( const bkCode, LedgerPath : string; NewChart : TChart);
const
  ThisMethodName = 'ReadChartFromBCLink';
var
  XmlChart : string;
  CreditAdjAcct  : string;
  DebitAdjAcct   : string;
  PrivateAdjAcct : string;
  HasDuplicates : boolean;
begin
  try
    //get the chart in xml format from bclink
    xmlchart := myobao_utils.GetXMLChart( bkCode,
                                          LedgerPath,
                                          CreditAdjAcct,
                                          DebitAdjAcct,
                                          PrivateAdjAcct);
    if DebugMe then
      SaveXMLStringToFile( xmlChart, DataDir + 'myobao_chart_' +  LedgerPath + '.xml');

    //set up bas rules
    if ( MyClient.clFields.clCountry = whAustralia ) then
    begin
      //convert the xml into a banklink chart
      ProcessXMLChart_AU( xmlChart, NewChart, HasDuplicates);
      LoadGSTTemplate( NewChart);

      //Update bas rules to include adjustment accounts
      //This should be done after the template has been loaded otherwise the fields will be overriden
      UpdateBasRule( bfG7, DebitAdjAcct, 11);
      UpdateBasRule( bfG18,CreditAdjAcct, 11);
      //the private use adjustments affect two bas fields
      UpdateBasRule( bfG11, PrivateAdjAcct, 1);
      UpdateBasRule( bfG15, PrivateAdjAcct, 1);
    end
    else
    begin
      //nz client
      ProcessXMLChart_NZ( xmlChart, NewChart, HasDuplicates);
      LoadDefaultGST_NZ( NewChart);
    end;

    if HasDuplicates then
      HelpfulWarningMsg( 'There were duplicate Account Codes in the select chart file. '#13#13+
                       SHORTAPPNAME + ' has ignored these codes.  A list of the duplicate codes has been '+
                       'written to the System Log.',0);
  except
    on E : ERefreshAbandoned do
    begin
      //let refresh code know that user abandoned so exist gracefully
      raise ERefreshAbandoned.Create('');
    end;

    on E : Exception do
    begin
      raise EExtractData.Create( ThisMethodName + ' failed: ' + E.Message );
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RefreshChart;
const
   ThisMethodName = 'RefreshChart';
var
   ChartFileName : string;
   HCtx : integer;
   NewChart          : TChart;

   TempAccount       : pAccount_Rec;
   Next              : pAccount_Rec;
   i                 : integer;
   ThisCode          : string;
   NextCode          : string;
   LoadFromPath      : string;
   Msg               : string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if not Assigned(MyClient) then
    exit;

  if not Software.CanUseMYOBAO_DLL_Refresh( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) then
  begin
    //MYOB interface prior to Jul 2005, AU only until bclink released to NZ

    ChartFileName := AddSlash(MyClient.clFields.clLoad_Client_Files_From) +
                     MYOBAO_FILE;

    {check file exists, ask for a new one if not}
    if not BKFileExists(ChartFileName) then begin
      HCtx := 0; //hcMYOBAO001;
      if not ChartUtils.LoadChartFrom( MyClient.clFields.clCode,
                                       ChartFileName,
                                       MyClient.clFields.clLoad_Client_Files_From,
                                       'CA Chart File ('+MYOBAO_File+')|'+MYOBAO_FILE,MYOBAO_EXTN,HCtx) then
        exit;
    end;

    LoadFromPath := AddSlash(ExtractFilePath(ChartFileName));
  end
  else
  begin
    //com based interface, chart will be returned as an xml string
    //interface works for both NZ and AU
    LoadFromPath := ExtractFileName(ExcludeTrailingBackslash(MyClient.clFields.clLoad_Client_Files_From));

    if LoadFromPath = '' then
    begin
      if GetMYOBLedgerPath( LoadFromPath) <>  bkMYOBAO_COM_Refresh_Supported_User_Selected_Ledger  then
      begin
        HelpfulErrorMsg( 'Could not access the list of ' + GetMYOBAO_Name(MyClient.clFields.clCountry) +
                           ' ledger paths', 0);
        Exit;
      end;
    end;
    ChartFilename := LoadFromPath;
  end;

  with MyClient.clFields do
  begin
    try
      NewChart := TChart.Create(MyClient.ClientAuditMgr);
      UpdateAppStatus('Loading Chart','Reading Chart',0);
      try
        if Software.CanUseMYOBAO_DLL_Refresh( MyClient.clFields.clCountry,
                                            MyClient.clFields.clAccounting_System_Used ) then
        begin
          ReadChartFromBCLink( clCode, LoadFromPath, NewChart);
        end
        else
        begin
          ReadDBaseFile(clCode, LoadFromPath, NewChart);
        end;

        //  Assigned( NewChart ) then  {new chart will be nil if no accounts or an error occured}
        If NewChart.ItemCount > 0 then Begin
           {flag accounts as posting accounts}
           For i := 0 to NewChart.ItemCount - 1 do Begin
              TempAccount := NewChart.Account_At(i);
              TempAccount.chPosting_Allowed := true;

              // #1666 - option to have posting always true
              if Globals.PRACINI_PostingAlwaysTrue then
                Continue;

              ThisCode := TempAccount.chAccount_Code;

              If ( i+1 ) < NewChart.ItemCount then Begin
                 Next := NewChart.Account_At(i+1);
                 NextCode    := Copy( Next.chAccount_Code, 1, Length( ThisCode ) );
                 If ( NextCode = ThisCode ) then TempAccount.chPosting_Allowed := FALSE;
              end;
           end;

           //merge existing chart with entries in new chart
           MergeCharts(NewChart,MyClient);

           //update chart details
           clChart_Last_Updated := CurrentDate;
           if Software.CanUseMYOBAO_DLL_Refresh( MyClient.clFields.clCountry,
                                               MyClient.clFields.clAccounting_System_Used ) then
             clLoad_Client_Files_From := LoadFromPath
           else
             clLoad_Client_Files_From := ExtractFilePath(ChartFileName);

           If clAccount_Code_Mask = '' then
               clAccount_Code_Mask := MYOBAO_MASK;

           ClearStatus(True);
           HelpfulInfoMsg( 'The clients chart of accounts has been refreshed.', 0 );
        end
        else begin
           Msg := Format( 'Could not read Client Chart %s.',[ ChartFileName ] );
           LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
           Raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
        end;
      finally
        ClearStatus(True);
        NewChart.Free;
      end;
    except
      on E : ERefreshAbandoned do
      begin
        //user abandoned refresh, go quietly
        exit;
      end;

      on E : EExtractData do begin
        //error occured during refresh
        Msg := Format( 'Error refreshing chart %s.', [ChartFileName] );
        LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
        HelpfulErrorMsg(Msg+#13'The existing chart has not been modified.', 0, False, E.Message, True);
      end;
    end;
  end;  {with}
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.
