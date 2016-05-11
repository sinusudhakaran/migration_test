unit ClassSuperIP;

interface

function RefreshChart: Boolean;


// Some more utils
type ClassSuperIPList = (cs_Fund, cs_Investments, cs_Members);

function ImportClassSuperList(const LedgerCode: string; csType: ClassSuperIPList): string;

function GetLedgerName(const LedgerCode: string): string;

function SetLedger(Current: ShortString): ShortString;

implementation

uses
   GlobalDirectories,
   Dialogs,
   WinUtils,
   Templates,
   Select_Desktop_GLfrm,
   Classes,
   bkConst,
   stDate,
   chartutils,
   GSTCalc32,
   bkchio,
   bkDefs,
   chList32,
   InfoMoreFrm,
   ErrorMoreFrm,
   XMLDoc,
   XMLIntf,
   xmldom,
   Sysutils,
   LogUtil,
   Globals;




const
  UNIT_NAME = 'ClassSuperIP';
  DEBUG_ME  : Boolean = False;


  ChartFilename = 'Chart.XML';
  ClassFundData = 'Class Fund Data.xml';

  nBankLinkChartOfAccounts = 'BankLinkChartOfAccounts';
  nChart_Code = 'Chart_Code';
  nCode = 'Code';
  nDescription = 'Description';
  nPosting = 'Posting';
  nGST_Class = 'GST_Class';


 function GetFieldText(FromNode: IXMLNode; Name: string):string;
 var LNode: IXMLNode;
 begin
    Result := '';
    LNode := FromNode.ChildNodes.FindNode(Name);
    if Assigned(LNode) then
       Result := LNode.NodeValue;
 end;


function GetDataFile(var FilePath: string; const aFilename: string): IXMLDocument;
var OpenDlg: TOpenDialog;
begin
   Result := XMLDoc.NewXMLDocument;
   Result.Active := true;
   FilePath := IncludeTrailingPathDelimiter(MyClient.clFields.clLoad_Client_Files_From) + aFilename;

   if not BKFileExists(FilePath) then begin
      OpenDlg := TOpenDialog.Create(Nil);
      try
         with OpenDlg do begin
            DefaultExt := '*.XML';;
            Filename := aFilename;
            Filter := 'Exported Fund Data (*.XML)|*.XML|All Files|*.*';
            HelpContext := 0;
            Options := [ofHideReadOnly, ofFileMustExist, ofEnableSizing, ofNoChangeDir ];
            Title := 'Load Class Super Fund Data';
            InitialDir := MyClient.clFields.clLoad_Client_Files_From;
         end;
         if OpenDlg.Execute then
            FilePath := OpenDlg.Filename
         else begin
            raise exception.Create('Cannot find file');
         end;
      finally
         OpenDlg.Free;
         //make sure all relative paths are relative to data dir after browse
         SysUtils.SetCurrentDir( GlobalDirectories.glDataDir);
      end;
      MyClient.clFields.clLoad_Client_Files_From := SysUtils.ExtractFileDir(FilePath);
   end;
   // try read the file
   Result.LoadFromFile(FilePath);
end;






//******************************** RefreshChart ******************************

function RefreshChart: Boolean;
const
   ThisMethodName = 'RefreshChart';
var
  msg,
  Chartfile: string;
  lXMLDoc: IXMLDocument;
  CNode: IXMLNode;
  I: Integer;
  NewChart: TChart;
  TemplateError : TTemplateError;

  procedure AddAccount(FromNode: IXMLNode);
  var NewAccount : pAccount_Rec;
      aCode: shortString;
      lNode: IXMLNode;

  begin
      if not SameText(FromNode.NodeName,nChart_Code) then
         raise exception.Create('Wrong file format');

      LNode := FromNode.ChildNodes.FindNode(nCode);
      if not Assigned(LNode) then
         raise exception.Create('Wrong file format');
      aCode := LNode.NodeValue;

      if not (aCode > '')then
         exit;

      aCode := copy(ACode,1,MaxBK5CodeLen);

      if (NewChart.FindCode(ACode) <> Nil) then
           LogUtil.LogMsg(lmError,UNIT_NAME,Format('%s, Duplicate Code "%s" found in: %s',[UNIT_NAME, ACode,ChartFile]))
         else begin
            //insert new account into chart
            NewAccount := New_Account_Rec;
            NewAccount.chAccount_Code := ACode;
            NewAccount.chAccount_Description := GetFieldText(FromNode, nDescription);
            aCode := GetFieldText(FromNode, nGST_Class);
            NewAccount.chGST_Class := GSTCalc32.GetGSTClassNo(MyClient, aCode);
            if(NewAccount.chGST_Class = 0 )
            and (aCode <> '' ) then begin
               LogUtil.LogMsg(lmError,UNIT_NAME,format('%s Unknown GST Indicator "%s" found in: %s', [UNIT_NAME, acode, ChartFile] ));
               //UnknownGSTCodesFound := True;
            end;

            NewAccount.chPosting_Allowed := SameText('Y', GetFieldText(FromNode, nPosting));

            NewChart.Insert(NewAccount);
         end;
  end;

begin
   if DEBUG_ME then
      LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Begins' );

   Result := False;
   NewChart := nil;

   try try
      if not Assigned(MyClient) then
         Exit;

      if (not MyClient.GSTHasBeenSetup) then begin
         Chartfile := GLOBALS.TemplateDir + 'CLASS.TPM';
         if BKFileExists(Chartfile)  then
            Template.LoadTemplate(Chartfile, tpl_DontCreateChart, TemplateError);
      end;

      lXMLDoc := GetDataFile(Chartfile,ChartFilename);

      CNode := lXMLDoc.DocumentElement;
      if not SameText(CNode.NodeName,nBankLinkChartOfAccounts) then
         raise exception.Create('Wrong file format');

      // Good to go..
      NewChart := TChart.Create(MyClient.ClientAuditMgr);
      for I := 0 to CNode.ChildNodes.Count - 1 do
         AddAccount(CNode.ChildNodes[I]);

      if NewChart.ItemCount > 0 then begin
          MergeCharts(NewChart, MyClient, True);
          MyClient.clFields.clChart_Last_Updated := CurrentDate;

          Msg := 'The client''s chart of accounts has been refreshed.';
          HelpfulInfoMsg( Msg, 0 );
          Result := true;
      end;
   except
      on E : Exception do begin // File I/O only
         Msg := Format( 'Error refreshing chart %s.', [Chartfile] );
         LogUtil.LogMsg( lmError, UNIT_NAME, ThisMethodName + ' : ' + Msg );
         HelpfulErrorMsg(Msg+#13'The existing chart has not been modified.', 0, False, E.Message, True);

      end;
   end;
   finally
      lXMLDoc := nil;
      newchart.free;
   end;

   if DEBUG_ME then
      LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Ends' );
end;


//******************************************************************************

const
     nCashCodingFundData = 'CashCodingFundData';
     csnames : array[ClassSuperIPList] of shortstring = ('Fund', 'Investments', 'Members');



function GetLedgerName(const LedgerCode: string): string;
const
   ThisMethodName = 'GetLedgerName';

var msg,
  FilePath: string;
  lXMLDoc: IXMLDocument;
  CNode: IXMLNode;
  I: Integer;

  function  TestFund(FromNode: IXMLNode): Boolean;
  var lNode: IXMLNode;
  begin
      Result := False;
      if not sametext(FromNode.NodeName,csnames[cs_Fund]) then
         raise exception.Create('Wrong file format');

      lNode :=  FromNode.ChildNodes.FindNode(nCode);
      if not Assigned(LNode) then
         raise exception.Create('Wrong file format');

      if sametext(LNode.NodeValue,LedgerCode) then begin
         lNode :=  FromNode.ChildNodes.FindNode(nDescription);
         if not Assigned(LNode) then
             raise exception.Create('Wrong file format');
         GetLedgerName := LNode.NodeValue;
         Result := true;
      end;
  end;

begin
   if DEBUG_ME then
      LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Begins' );
    try try
      if not Assigned(MyClient) then
         Exit;

      lXMLDoc := GetDataFile(FilePath, ClassFundData);

      CNode := lXMLDoc.DocumentElement;
      if not SameText(CNode.NodeName,nCashCodingFundData) then
         raise exception.Create('Wrong file format');

      for I := 0 to CNode.ChildNodes.Count - 1 do
         if TestFund(CNode.ChildNodes[I]) then
            Break;

   except
      on E : Exception do begin
         Msg := ('Error reading file.');
         LogUtil.LogMsg( lmError, UNIT_NAME, ThisMethodName + ' : ' + Msg + #13#13 + E.Message);
         HelpfulErrorMsg(Msg, 0, false, 'Error in file: ' + FilePath+ #13#13 + E.Message );
      end;
   end;
   finally
      lXMLDoc := nil;
   end;

   if DEBUG_ME then
      LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Ends' );
end;


function SetLedger(Current: ShortString): ShortString;
const
   ThisMethodName    = 'SetLedger';

begin
   if DEBUG_ME then
      LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Begins' );

   if not Assigned(MyClient) then
      Exit;

   Result := Current;
   SelectLedgerCode(Result, ImportClassSuperList('',cs_Fund));


   if DEBUG_ME then
      LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Ends' );
end;



function ImportClassSuperList(const LedgerCode: string; csType: ClassSuperIPList): string;
const
   ThisMethodName = 'ImportClassSuperList';

var msg,
  FilePath: string;
  lXMLDoc: IXMLDocument;
  CNode: IXMLNode;
  I: Integer;
  LList: TStringList;

  procedure AddItem(FromNode: IXMLNode);
  var aCode: shortString;
      lNode: IXMLNode;
  begin

      LNode := FromNode.ChildNodes.FindNode(nCode);
      if not Assigned(LNode) then
         raise exception.Create('Wrong file format');
      aCode := LNode.NodeValue;

      if not (aCode > '')then
         exit;
      // Make it desktop compatible
      if csType = cs_Fund then
         LList.Add(format('%d,%s,%s',[LList.Count + 1,aCode, GetFieldText(FromNode, nDescription) ] ))
      else
         LList.Add(format('%d,%s,%s,%s',[LList.Count + 1,LedgerCode,aCode, GetFieldText(FromNode, nDescription) ] ))
  end;


  function  TestFund(FromNode: IXMLNode): Boolean;
  var lNode: IXMLNode;
      I: Integer;
  begin
      Result := False;
      if not sametext(FromNode.NodeName,csnames[cs_Fund]) then
         raise exception.Create('Wrong file format');

      if csType = cs_Fund then begin
         // Stay at this level
         AddItem(FromNode);
         // Do all of themso fail
         Exit;
      end;

      // Still here need to check if I have the correct Fund list
      lNode :=  FromNode.ChildNodes.FindNode(nCode);
      if not Assigned(LNode) then
         raise exception.Create('Wrong file format');

      if not sametext(LNode.NodeValue,LedgerCode) then
         Exit; // Nope, wrong list, keep looking

      // Good to go..
      lNode :=  FromNode.ChildNodes.FindNode(csnames[csType]);
      if not Assigned(lNode) then
         Exit;// Dont have the list?

      // Just add all the items
      for I := 0 to lNode.ChildNodes.Count - 1 do
         AddItem(LNode.ChildNodes[I]);

      // Still here, I'm done
      Result := True;
  end;

begin //ImportClassSuperList

   if DEBUG_ME then
      LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Begins' );

   Result := '';
   if not Assigned(MyClient) then
     Exit;

   LList := TStringList.Create;
   try try

      LList.Add('Header'); // Desktop skips the first line, so just add a dummy..

      lXMLDoc := GetDataFile(FilePath,ClassFundData);

      CNode := lXMLDoc.DocumentElement;
      if not SameText(CNode.NodeName,nCashCodingFundData) then
         raise exception.Create('Wrong file format');

      for I := 0 to CNode.ChildNodes.Count - 1 do
         if TestFund(CNode.ChildNodes[I]) then
            Break; // Im done

      Result := LList.Text;
   except
      on E : Exception do begin // File I/O only
         Msg := ('Error reading file.');
         LogUtil.LogMsg( lmError, UNIT_NAME, ThisMethodName + ' : ' + Msg + #13#13 + E.Message);
         HelpfulErrorMsg(Msg, 0, false, 'Error in file: ' + FilePath+ #13#13 + E.Message );
      end;
   end;
   finally
      lXMLDoc := nil;
      LList.Free;
   end;

   if DEBUG_ME then
      LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Ends' );

end;



Initialization
   DEBUG_ME := LogUtil.DebugUnit( UNIT_NAME );
end.

