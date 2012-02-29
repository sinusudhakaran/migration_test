unit RptParams;

interface
uses ReportDefs,
     Classes,
     UBatchBase,
     budobj32,
     OmniXML,
     Globals,
     StdCtrls,
     clObj32,
     chList32;

type

  tDateMode = (dNone,dPeriod,dYear);

  TRPTParameters = class (tobject)
  private
     FAccountList : TList;
     FDivisionList: TList;
     FChart: TCustomSortChart; //This chart can be in a different order than the client chart
     FClient: TClientObj;
     FRptBatch: TReportBase;
     FDateMode: TDateMode;

     // Client bits that are saved..
     // FReporting_Year_Starts            : Integer;
     FPeriod_Start_Date                : Integer;
     FPeriod_End_Date                  : Integer;
     FFRS_Print_Chart_Codes            : Boolean;
     FCflw_Cash_On_Hand_Style          : Integer;
     FFRS_Compare_Type                 : Integer;

     FFRS_Show_Variance                : Boolean;
     FFRS_Show_YTD                     : Boolean;
     FFRS_Show_Quantity                : Boolean;
     FFRS_Reporting_Period_Type        : Integer;
     FFRS_Report_Style                 : Integer;
     FFRS_Report_Detail_Type           : Integer;

     FGST_Inclusive_Cashflow           : Boolean;
     FFRS_Prompt_User_to_use_Budgeted_figures : Boolean;
     FFPercentage_Profit               : Boolean;
     FRunBtn: Integer;
     FReportType: Integer;
     FScheduled: Boolean;

     FFRS_PrintNPChartCodeTitles       : Boolean;
     FFRS_NPChartCodeDetailType        : Byte;

     procedure SetClient(const Value: TClientObj);
     procedure SaveClient;
     procedure SetRptBatch(const Value: TReportBase);
     procedure SetDateMode(const Value: TDateMode);
     procedure SetRunBtn(const Value: Integer);
     procedure SetReportType(const Value: Integer);
     procedure SetScheduled(const Value: Boolean);
  protected
     procedure Reset; virtual;
     // Some comon bits...
     function GetContraText(Value : Byte) : string;
     function GetContra (Value : string) : byte;
     function GetReportPeriodText(Value : Byte) : string;
     function GetReportPeriod (Value : string) : byte;
     function GetReportStyleText(Value : Byte) : string;
     function GetReportStyle (Value : string) : byte;

     function GetAccounts (FromNode : IXMLNode):Boolean;
     procedure SaveAccounts (ToNode : IXMLNode);

     function GetDivisions (FromNode : IXMLNode):Boolean;
     procedure SaveDivisions (ToNode : IXMLNode);

     // House keeping
     procedure ClearSetting (FromNode : IXMLNode; Value : string);
     procedure LoadFromRptBatch (Value : TReportBase); virtual;
     // Main ones to override
     procedure LoadFromClient (Value : TClientObj); virtual;
     procedure SaveToClient   (Value : TClientObj); virtual;
     procedure ReadFromNode (Value : IXMLNode); virtual;
     procedure SaveToNode   (Value : IXMLNode); virtual;
     procedure LoadChart;
  public
     FromDate,
     ToDate : LongInt;
     AccountFilter : set of byte;
     constructor Create (aType: Integer;
                         aClient: TClientObj; batch : TReportBase;
                            const ADateMode : tDateMode = dNone) ;
     destructor Destroy; override;
     function MakeRptName (Title : string) : string;

     property Client : TClientObj read FClient write SetClient;
     property Chart: TCustomSortChart read FChart;
     property DateMode : TDateMode read FDateMode write SetDateMode;
     property RptBatch : TReportBase read FRptBatch write SetRptBatch;
     property AccountList : TList read  FAccountList;
     property DivisionList : TList read  FDivisionList;
     property RunBtn: Integer read FRunBtn write SetRunBtn;
     property ReportType: Integer read FReportType write SetReportType;
     property Scheduled: Boolean read FScheduled write SetScheduled;
     // Some simple settings can be done direct...
     function GetBatchBool (const Name : string; Default : boolean= False) : Boolean;
     procedure SetBatchBool (const Name : string; Value : Boolean);
     function GetBatchText (const Name: string; Default : string = ''): string;
     procedure SetBatchText (const Name, Value : string);
     function GetBatchInteger (const Name : string; Default : integer= 0):Integer;
     procedure SetBatchInteger (const Name :string; Value : integer);
     procedure SaveBatchDivision (Value : Integer);
     function GetBatchDivision(Default : Integer= 0): Integer;
     function GetbatchBudget : tBudget;
     // CashFlow / Profit Loss
     procedure SaveBatchReportPeriod(Value : integer);
     function GetBatchReportPeriod(Default: integer = 0) : Integer;
     procedure SaveBatchReportStyle(Value : integer);
     function GetBatchReportStyle(Default: integer = 0) : Integer;
     procedure SaveBatchReportCompare(Value : integer);
     function GetBatchReportCompare(Default: integer = 0) : Integer;
     procedure SaveNodeSettings;
    // procedure ClearDates;
     procedure SaveDates;
     procedure SaveClientSettings;
     procedure RestoreClient;

     function HaveSettings: boolean;
     function BatchRun: Boolean;
     function BatchSetup: Boolean;
     function Batchless: Boolean;
     function BatchRunMode: TBatchRunMode;
     function BatchSave(Btn: Integer = BTN_NONE): Boolean;
     function RunExit(Destination : TReportDest) : Boolean;
     procedure GetClientAccounts;
     procedure GetBatchAccounts;
     procedure SaveBatchAccounts;
     procedure GetBatchDivisions;
     procedure SaveBatchDivisions;

     procedure RunReport (Dest: TReportDest; const Filename: string = '');
     procedure SetDlgButtons(BtnPreview,BtnFile,BtnSave,BtnPrint: TButton);
     function CheckForBatch(NewName: string = ''; Title: string = ''): Boolean;
     function WasNewBatch: Boolean;
     function DlgResult(Btn: Integer = BTN_NONE): Boolean;
     function UsageTitle(Destination: TReportDest): string;
  end;

  TGenRptParameters = class (TRptParameters)
  private
  // Can be used for most reports...
  protected
     procedure LoadFromClient (Value : TClientObj); override;
     procedure SaveToClient   (Value : TClientObj); override;
     procedure ReadFromNode   (Value : IXMLNode); override;
     procedure SaveToNode     (Value : IXMLNode); override;
  public
     ShowGST  : Boolean;
     Division : Integer;
     Period   : Integer;
     ChartCodes : Boolean;
     Budget    : TBudget;
     SpareBool : Boolean;
     ShowBudgetQuantities: Boolean;
     constructor Create (aType: Integer;
                         aClient : TClientObj; batch : TReportBase;
                          const ADateMode : tDateMode = dNone;
                                DoBudget : Boolean = False ) ;
  end;

  TCustomRptParameters = class(TGenRptParameters)
  private
    FPrintNPChartCodeTitles: Boolean;
    FNPChartCodeDetailType: Byte;
    procedure SetPrintNPChartCodeTitles(const Value: Boolean);
    procedure SetNPChartCodeDetailType(const Value: Byte);
  protected
    procedure LoadFromClient (Value : TClientObj); override;
    procedure SaveToClient   (Value : TClientObj); override;
    procedure ReadFromNode   (Value : IXMLNode); override;
    procedure SaveToNode     (Value : IXMLNode); override;
  public
    constructor Create (aType: Integer; aClient: TClientObj;
                        batch: TReportBase; const ADateMode: tDateMode = dNone;
                        DoBudget: Boolean = False);
    property PrintNPChartCodeTitles: Boolean read FPrintNPChartCodeTitles
                                             write SetPrintNPChartCodeTitles;
    property NPChartCodeDetailType: Byte read FNPChartCodeDetailType
                                         write SetNPChartCodeDetailType;
  end;

  // Some Help functions so we do not always have to use a TRPTParameters
  function BatchRun   (Value  : Treportbase): Boolean;
  function batchSetup (value  : Treportbase): Boolean;
  function ReportID (Title : string; Batch : TReportBase):string;
  function LoadBatchIntAsStringValue(Node: IXMLNode; Name: string;
                                   const AnArray: array of string;
                                   Default : Integer= 0): Integer;
  procedure SaveBatchIntAsStringValue(Node: IXMLNode; Name: string;
                                     Value : Integer;
                                     const AnArray: array of string);


implementation

uses Buttons,
     ImagesFrm,
     dlgAddFavourite,
     glConst, bkConst, baObj32, OmniXMLUtils, SysUtils,
     GenUtils, IOStream;

//Const used for writting node values as stings
const
  NPChartCodeDetailTypeStr: array[0..1] of string = ('Detailed', 'Summarised');


function ReportID (Title : string; Batch : TReportBase):string;
begin
   {if assigned(Batch)  then // Make it unique
      Result := Title + ' [' + IntToStr(Batch.Id) + ']'
   else}
   // At this stage, not required to be unique
   Result := Title;
end;

function BatchRun   (Value  : Treportbase): Boolean;
begin
   if assigned(value) then
      Result := Value.BatchRunMode = R_Batch
   else Result := false;
end;

function batchSetup (value  : Treportbase): Boolean;
begin
   if assigned(value) then
      Result := Value.BatchRunMode = R_Setup
   else Result := false;
end;

function LoadBatchIntAsStringValue(Node: IXMLNode; Name: string;
  const AnArray: array of string; Default : Integer= 0): Integer;
var
  i: integer;
  Value: string;
begin
  Result := Default;
  Value := GetNodeTextStr(Node, Name, '');
  for i := Low(AnArray) to High(AnArray) do
    if AnArray[i] = Value then begin
      Result := i;
      Break;
    end;
end;

procedure SaveBatchIntAsStringValue(Node: IXMLNode; Name: string;
  Value : Integer; const AnArray: array of string);
begin
  SetNodeTextStr(Node, Name, AnArray[Value]);
end;

        (*
function BMthBefore(Value,Months : Integer) : Integer;
// Returns the first day in the previous months.
Var
  Day   : Integer;
  Month : Integer;
  Year  : Integer;
  i : integer;
Begin
  StDatetoDMY( Value, Day, Month, Year );
  for i := 1 to Months Do DecMY( Month, Year );
  Result := DMYtoStDate(1, Month, Year, Epoch);
end;
          *)

{ TRPTParameters }

function TRPTParameters.CheckForBatch(NewName: string = ''; Title: string = ''): Boolean;
var LName: string;
begin
   Result := True;
   if Batchless then begin
      if NewName = '' then
         NewName := Get_ReportName(ReportType);
      if GetNewFavouriteName(NewName,LName) then begin
         // need a new Batch..
         RptBatch := Batchreports.NewReport(LName);
         if Title > '' then
            RptBatch.Title := Title
         else
            RptBatch.Title := NewName;
         RptBatch.BatchRunMode := R_BatchAdd;
      end else
         Result := False;
   end;
end;

function TRPTParameters.Batchless: Boolean;
begin
   Result := not assigned(FRptbatch);
end;

function TRPTParameters.BatchRun : Boolean;
begin
   if assigned(FRptbatch) then
      Result := False{FRptBatch.BatchRunMode = R_Batch} //
   else Result := False;
end;

function TRPTParameters.BatchRunMode: TBatchRunMode;
begin
   if assigned(FRptbatch) then
      Result := FRptBatch.BatchRunMode
   else Result := R_Normal;
end;

function TRPTParameters.BatchSave(Btn: Integer): Boolean;
begin
   if btn <> BTN_NONE then
      RunBtn := Btn;
   case BatchRunMode of
   R_Setup,R_BatchAdd : Result := (RunBtn = BTN_Save)
   else Result := False;
   end;

end;

function TRPTParameters.BatchSetup: Boolean;
begin
   if assigned(FRptbatch) then
      Result := FRptBatch.BatchRunMode in [R_Setup,R_BatchAdd]
   else Result := False;
end;

   (*
procedure TRPTParameters.ClearDates;
begin
   FromDate := 0;
   ToDate   := 0;
end;
     *)
procedure TRPTParameters.ClearSetting(FromNode : IXMLNode; Value: string);
var NN : IXMLNode;
begin
   if assigned(FromNode) then begin
      NN := FindNode(FromNode,Value);
      if assigned(NN) then
         FromNode.RemoveChild(NN);
   end;
end;


constructor TRPTParameters.Create(aType: Integer;
                                  aClient : TClientObj; batch : TReportBase;
                                  const ADateMode : tDateMode = dNone ) ;
begin
   inherited Create;
   FAccountList := TList.Create;
   FDivisionList := TList.Create;
   Reset;
   // Needs to be in this order
   // The Client loads the defaults..
   // And saves any Client fields..
   Client := AClient;
   // Picks up default dates..
   DateMode := ADateMode;
   // Batch loads any further settings..
   Rptbatch := Batch;
   ReportType := aType;
end;

destructor TRPTParameters.Destroy;
begin
   if Assigned(FRptBatch)
   and Assigned(FClient)then
      RestoreClient; // Stuff may have changed...

   if Assigned(FChart) then
     FreeAndNil(FChart);
   FDivisionList.Free;
   FAccountList.Free;
   inherited;
end;


function TRPTParameters.DlgResult(Btn: Integer): Boolean;
begin
  if btn <> BTN_NONE then
     RunBtn := Btn;

  if BatchRunMode = R_Batch then
     Result := not (RunBtn in [BTN_SAVE, BTN_NONE])
  else
     Result := RunBtn <> BTN_NONE;
end;

function TRPTParameters.GetAccounts(FromNode: IXMLNode): Boolean;

  var NN : IXMLNode;
      LList : IXMLNodeList;
      I : Integer;

      procedure CheckAcc(Value : string) ;
      var J : Integer;
      begin
         for J := 0 to pred(LList.Length) do
           if Sametext(Value,GetNodeTextStr(LList.Item[J],'_Number','')) then begin
              // In the 'Node list', add it to the Account list
              AccountList.Add(fClient.clBank_Account_List.Bank_Account_At(i));
              break;
           end;
      end;
      function CheckNone : boolean;
      var J : Integer;
      begin
         Result := True;
         for J := 0 to pred(LList.Length) do
           if Sametext('None',GetNodeTextStr(LList.Item[J],'_Number','')) then
              Exit;
         Result := False;// Still here...
      end;

  begin
     result := false;
     NN := FindNode(FromNode,'Accounts');
     if not assigned(NN) then
        Exit; // Leave them all selected
     LList := FilterNodes(NN,'Account');
     if not assigned(LList) then
        Exit;
     if LList.Length = 0 then
        Exit;
     if CheckNone then begin
        Result := True;
        Exit;
     end;

     with Client.clBank_Account_List do
        for i := 0 to Pred( itemCount ) do
          CheckAcc( Bank_Account_At(i).baFields.baBank_Account_Number );
     Result := AccountList.Count > 0;
  end;


procedure TRPTParameters.GetBatchAccounts;
begin
   if HaveSettings then begin
     if Not GetAccounts(fRptBatch.Settings) then
        GetClientAccounts;
   end else
      GetClientAccounts;
end;

function TRPTParameters.GetBatchBool(const Name: string;
  Default: boolean): Boolean;
begin
   if HaveSettings then
      Result := GetNodeBool(FrptBatch.Settings,Name,Default)
   else
      Result := Default;
end;

function TRPTParameters.GetbatchBudget: tBudget;
var I : Integer;
    Bgt : string;
begin
   Result := nil;
   if not assigned(fClient) then // nothing i can do...
      Exit;

   if HaveSettings then begin
      Bgt := GetBatchText('Budget','');
      with Client.clBudget_List do
         for i := first to last do with Budget_At(i) do
            if Sametext(buFields.buName,Bgt)  then begin
               Result := Budget_At(i);
               Exit
            end;
   end;
   // Still here..
   if Client.clBudget_List.ItemCount = 1 then // Can't select it from the dialog..
       Result := Client.clBudget_List.Budget_At(0);
end;

function TRPTParameters.GetBatchDivision(default : Integer): Integer;
var Divn : string;
    V,C : Integer;
begin
   Result := Default;
   if not assigned(fClient) then // nothing i can do...
      Exit;

   if HaveSettings then begin
      Divn := GetNodeTextStr(FrptBatch.Settings,'Division','');
      if Divn > '' then begin
         for Result := 1 to Max_Divisions do
            if Sametext( Client.clCustom_Headings_List.Get_Division_Heading(Result),Divn) then
               Exit;
         // Maybe index ?
         Val(Divn,V,C );
         if (C = 0)
         and (V >= 1)
         and (V <= Max_Divisions) then begin
            Result := V;
            Exit;
         end;
      end;
      // Still here ....
      Result := Default;
   end;
end;

procedure TRPTParameters.GetBatchDivisions;
begin
  if HaveSettings then
    GetDivisions(fRptBatch.Settings);
end;

function TRPTParameters.GetBatchInteger(const Name: string;
  Default: integer): Integer;
begin
   if HaveSettings then
      Result := GetNodeTextInt(FrptBatch.Settings,Name,Default)
   else
      Result := Default;
end;

function TRPTParameters.GetBatchReportCompare(Default: integer): Integer;
var s : string;
begin
   Result := Default;
   if HaveSettings then begin
     s := GetNodeTextStr(FrptBatch.Settings,'Compare','');
     if s > '' then begin
        if sametext(s, 'None') then begin
           Result := cflCompare_None;
           Exit;
        end else if sametext(s, 'Budget') then begin
           Result := cflCompare_To_Budget;
           Exit;
        end else if sametext(s, 'Last Year') then begin
           Result := cflCompare_To_Last_Year;
           Exit;
        end;
     end;
  end;
end;

function TRPTParameters.GetBatchReportPeriod(Default: integer): Integer;
var s : string;
begin
  Result := Default;
  if HaveSettings then begin
     s := GetNodeTextStr(FrptBatch.Settings,'Periods','');
     if s > '' then
        Result := GetReportPeriod(s);
  end;
end;

function TRPTParameters.GetBatchReportStyle(Default: integer): Integer;
var s : string;
begin
  Result := Default;
  if HaveSettings then begin
     s := GetNodeTextStr(FrptBatch.Settings,'Style','');
     if s > '' then
        Result := GetReportStyle(s);
  end;
end;


function TRPTParameters.GetBatchText(const Name : string; Default: string): string;
begin
   if HaveSettings then
      Result := GetNodeTextStr(FrptBatch.Settings,Name,Default)
   else
      Result := Default;
end;

procedure TRPTParameters.GetClientAccounts;
var I : Integer;
begin
   FAccountList.Clear;
   if assigned(FClient) then
      with FClient.clBank_Account_List do
        for i := 0 to Pred( itemCount ) do
          FAccountList.Add( Bank_Account_At(i));
end;

function TRPTParameters.GetContra(Value: string): byte;
begin
   if sametext('All',value) then Result := 1 else
   if sametext('Total',value) then Result := 2 else
   result := 0;
end;

function TRPTParameters.GetContraText(Value: Byte): string;
begin
   case Value of
   1 : Result := 'All';
   2 : Result := 'Total';
   else Result := 'None';
   end;
end;

function TRPTParameters.GetDivisions(FromNode: IXMLNode): Boolean;
var
  i: Integer;
  NN: IXMLNode;
  LList: IXMLNodeList;
  Division: integer;

  function DivisionExists(aDivision: integer): Boolean;
  var
    ChartIdx: integer;
  begin
    Result := False;
    for ChartIdx := 0 to Pred(FClient.clChart.ItemCount) do begin
      if FClient.clChart.Account_At(ChartIdx).chPrint_in_Division[aDivision] then begin
        Result := True;
        Break;
      end;
    end;
  end;

begin
  Result := False;
  NN := FindNode(FromNode,'Divisions');
  if not Assigned(NN) then Exit;
  LList := FilterNodes(NN,'Division');
  if not Assigned(LList) then Exit;
  if LList.Length = 0 then  Exit;

  for i := 0 to Pred(LList.Length) do begin
    Division := StrToInt(GetNodeTextStr(LList.Item[i],'_Number',''));
    if (Division = 0) then
      DivisionList.Add(TObject(Division)) //No division allocated
    else if DivisionExists(Division) then begin
      DivisionList.Add(TObject(Division));
    end;
  end;
  Result := (AccountList.Count > 0);
end;

function TRPTParameters.GetReportPeriod(Value: string): byte;
var I : Byte;
begin
  for I := Low(frpNames) to High(frpNames) do
     if sametext(frpNames[i],Value) then begin
        Result := I;
        Exit;
     end;
  Result := Low(frpNames);
end;

function TRPTParameters.GetReportPeriodText(Value: Byte): string;
begin
  if Value in [Low(frpNames).. High(frpNames)] then
    Result := frpNames[Value]
  else Result := '';
end;

function TRPTParameters.GetReportStyle(Value: string): byte;
var I : Byte;
begin
   for I := Low(crsNames) to High(crsNames) do
     if sametext(crsNames[i],Value) then begin
        Result := I;
        Exit;
     end;
  Result := Low(frpNames);
end;

function TRPTParameters.GetReportStyleText(Value: Byte): string;
begin
   if Value in [Low(crsNames).. High(crsNames)] then
    Result := crsNames[Value]
  else Result := '';
end;

function TRPTParameters.HaveSettings: boolean;
begin
   Result := False;
   if assigned(RptBatch) then
      Result := Assigned(RptBatch.Settings);
end;

procedure TRPTParameters.LoadFromClient(Value: TClientObj);
begin

end;

procedure TRPTParameters.LoadFromRptBatch(Value: TReportBase);
begin
   if HaveSettings then
      ReadFromNode(Value.Settings);
   {  If we want to Use the Saved dates
   if Value.RundateFrom <> 0  then
      Fromdate := Value.RundateFrom;
   if Value.RundateTo <> 0  then
      Todate := Value.RundateTo;
   {}
end;

procedure TRPTParameters.LoadChart;
begin
  //Use a copy of the client chart that can be sorted
  FChart := TCustomSortChart.Create(FClient.ClientAuditMgr);
  FChart.CopyChart(FClient.clChart);
  if UseXlonSort then
    FChart.Sort(XlonCompare);
end;

function TRPTParameters.MakeRptName(Title: string): string;
begin
   Result := ReportID(Title,FRptBatch);
end;

procedure TRPTParameters.ReadFromNode(Value: IXMLNode);
begin

end;

procedure TRPTParameters.Reset;
begin
   FAccountList.Clear;
end;

procedure TRPTParameters.RestoreClient;
begin
   if not assigned(FClient) then exit;
   with FClient.clFields, FClient.clExtra do begin
      //clReporting_Year_Starts := FReporting_Year_Starts;
      clPeriod_Start_Date     := FPeriod_Start_Date;
      clPeriod_End_Date       := FPeriod_End_Date;
      clFRS_Print_Chart_Codes :=  FFRS_Print_Chart_Codes;

      clCflw_Cash_On_Hand_Style := FCflw_Cash_On_Hand_Style;
      clFRS_Compare_Type        := FFRS_Compare_Type;

      clFRS_Show_Variance       := FFRS_Show_Variance;
      clFRS_Show_YTD            := FFRS_Show_YTD;
      clFRS_Show_Quantity       := FFRS_Show_Quantity;
      clFRS_Reporting_Period_Type := FFRS_Reporting_Period_Type;
      clFRS_Report_Style        := FFRS_Report_Style;
      clFRS_Report_Detail_Type  := FFRS_Report_Detail_Type;

      clGST_Inclusive_Cashflow   := FGST_Inclusive_Cashflow;
      clFRS_Prompt_User_to_use_Budgeted_figures
                             := FFRS_Prompt_User_to_use_Budgeted_figures;
      clProfit_Report_Show_Percentage :=  FFPercentage_Profit;

      ceFRS_Print_NP_Chart_Code_Titles :=  FFRS_PrintNPChartCodeTitles;
      ceFRS_NP_Chart_Code_Detail_Type  :=  FFRS_NPChartCodeDetailType;
   end;

end;

function TRPTParameters.RunExit (Destination : TReportDest): Boolean;
begin // Exit the Repeat until Loop
  if assigned(FrptBatch)  then
      Result := FrptBatch.BatchRunMode in [R_Batch, R_BatchAdd] // If i am running it i can exit..
  else Result := Scheduled;{not (Destination in [RdScreen, rdNone])} // Not a Batch.. Exit
end;

procedure TRPTParameters.RunReport(Dest: TReportDest; const Filename: string);

   function GetUserName : string;
   begin
      if assigned(CurrUser) then
         if CurrUser.FullName > '' then
            Result := CurrUser.FullName
         else if CurrUser.Code > '' then
            Result := CurrUser.Code
         else
            Result := 'ID: ' + IntTostr(CurrUser.LRN)
      else
         Result := '';
   end;

begin
  if assigned(FrptBatch) then begin
     Savedates;
     frptBatch.LastRun := Now;
     frptBatch.User := GetUserName;
     if (frptBatch.BatchRunMode = R_Batch)
     and (Dest = rdFile) then
        frptBatch.RunDestination := 'Screen'
     else
        frptBatch.RunDestination := Get_DestinationText(Dest);
     if FileName <> '' then begin
        if pos('.',FileName) <> 0 then
           frptBatch.RunFileLocation := ExtractFilePath(Filename)
        else
           frptBatch.RunFileLocation := Filename;
        frptBatch.RunFileName := FileName;
     end;
  end;
end;

procedure TRPTParameters.SaveAccounts(ToNode: IXMLNode);
var NN,NA : IXMLNode;
    I : integer;

    function AllAccounts : Boolean;
    // Dont want to save All accounts...
    var I, C : Integer;
    begin
       if Assigned(fClient) then begin
          Result := True;
          if fClient.clBank_Account_List.Last = Pred(AccountList.Count) then
             exit;
          if AccountFilter <> [] then begin
             // Have to count...
             C := 0;
             with Client do
                for i := 0 to clBank_Account_List.ItemCount-1 do
                   with clBank_Account_List.Bank_Account_At(i) do
                      if (baFields.baAccount_Type in AccountFilter)
                      or ((btForeign in AccountFilter) and IsAForexAccount)then
                         inc(c);
             Result := (c = AccountList.Count);
          end else Result := False;
      end else
         Result := false;
   end;

begin
   if AllAccounts then begin
      ClearSetting(ToNode,'Accounts');
      Exit;
   end;

   if AccountList.Count = 0 then begin
      // No Accounts..
      NN := EnsureNode( ToNode, 'Accounts');
      NN.Text := ''; // Clear any..
      NA := AppendNode(NN, 'Account');
      SetNodeTextStr(NA,'_Number','None');
   end else begin
      NN := EnsureNode( ToNode, 'Accounts');
      NN.Text := ''; // Clear any..
      for I := 0 to Pred(AccountList.Count) do
      with tBank_account( AccountList[i]), baFields do begin
          NA := AppendNode(NN, 'Account');
          SetNodeTextStr(NA,'_Number',baBank_Account_Number);
          // If we show settings , you can see the name..
          SetNodeTextStr(NA,'Account',AccountName);
      end;
   end;
end;

procedure TRPTParameters.SaveBatchAccounts;
begin
   if Havesettings then
      SaveAccounts (RptBatch.Settings);
end;

procedure TRPTParameters.SaveBatchDivision(Value: Integer);
begin
  if HaveSettings then begin
     if (Value > 0)  // Don't save 'All'
     and (Value <= Max_Divisions)
     and (assigned(fClient)) then begin
        if Client.clCustom_Headings_List.Get_Division_Heading(Value) > '' then
           SetNodeTextStr(rptbatch.Settings,'Division', Client.clCustom_Headings_List.Get_Division_Heading(Value))
        else
           SetNodeTextStr(rptbatch.Settings,'Division',IntTostr(Value));
     end;
  end;
end;

procedure TRPTParameters.SaveBatchDivisions;
begin
  if Havesettings then
    SaveDivisions(RptBatch.Settings);
end;

procedure TRPTParameters.SaveBatchReportCompare(Value: integer);
begin
  if HaveSettings then
     case Value of
     cflCompare_None         :SetNodeTextStr(rptbatch.Settings,'Compare','None');
     cflCompare_To_Budget    :SetNodeTextStr(rptbatch.Settings,'Compare','Budget');
     cflCompare_To_Last_Year :SetNodeTextStr(rptbatch.Settings,'Compare','Last Year');
     end;

end;

procedure TRPTParameters.SaveBatchReportPeriod(Value: integer);
begin
   if HaveSettings then
     SetNodeTextStr(rptbatch.Settings,'Periods',GetReportPeriodText(value));
end;

procedure TRPTParameters.SaveBatchReportStyle(Value: integer);
begin
   if HaveSettings then
     SetNodeTextStr(rptbatch.Settings,'Style',GetReportStyleText(value));
end;

procedure TRPTParameters.SaveClient;
begin
   if not assigned(FClient) then Exit;
   with FClient.clFields, FClient.clExtra do begin
      //FReporting_Year_Starts := clReporting_Year_Starts ;
      FPeriod_Start_Date       := FClient.clFields.clPeriod_Start_Date;
      FPeriod_End_Date         := FClient.clFields.clPeriod_End_Date;
      FFRS_Print_Chart_Codes   := clFRS_Print_Chart_Codes;

      FCflw_Cash_On_Hand_Style := clCflw_Cash_On_Hand_Style;
      FFRS_Compare_Type        := clFRS_Compare_Type;

      FFRS_Show_Variance       := clFRS_Show_Variance;
      FFRS_Show_YTD            := clFRS_Show_YTD;
      FFRS_Show_Quantity       := clFRS_Show_Quantity;
      FFRS_Reporting_Period_Type
                               := clFRS_Reporting_Period_Type;

      FFRS_Report_Style        := clFRS_Report_Style;
      FFRS_Report_Detail_Type  := clFRS_Report_Detail_Type;

      FGST_Inclusive_Cashflow  := clGST_Inclusive_Cashflow;
      FFRS_Prompt_User_to_use_Budgeted_figures
                               := clFRS_Prompt_User_to_use_Budgeted_figures;

      FFPercentage_Profit := clProfit_Report_Show_Percentage;

      FFRS_PrintNPChartCodeTitles := ceFRS_Print_NP_Chart_Code_Titles;
      FFRS_NPChartCodeDetailType := ceFRS_NP_Chart_Code_Detail_Type;
   end;
end;

procedure TRPTParameters.SaveClientSettings;
begin
  if assigned(FClient) then
     SaveToClient(FClient);
end;

procedure TRPTParameters.SaveDates;
begin

  if assigned (RptBatch)
  and (Datemode <> dNone) then begin
     if Fromdate <> 0 then
        RptBatch.RundateFrom := Fromdate;
     if Todate <> 0 then
        RptBatch.RundateTo := ToDate;
  end;

end;

procedure TRPTParameters.SaveDivisions(ToNode: IXMLNode);
var
  i: integer;
  NN, NA: IXMLNode;
  Division: integer;
  DivisionName: string;
begin
  NN := EnsureNode( ToNode, 'Divisions');
  NN.Text := ''; // Clear any..

  if (DivisionList.Count > 0) then begin
    for i := 0 to Pred(DivisionList.Count) do begin
      Division := Integer(DivisionList[i]);
      DivisionName := Client.clCustom_Headings_List.Get_Division_Heading(Division);
      NA := AppendNode(NN, 'Division');
      SetNodeTextStr(NA, '_Number', IntToStr(Division));
      SetNodeTextStr(NA, 'Division', DivisionName);
    end;
  end;
end;

procedure TRPTParameters.SaveNodeSettings;
begin
   if HaveSettings then
      SaveToNode(rptBatch.Settings);

   if assigned (RptBatch) then begin // may not have settings
      RptBatch.Saved := true;
   end;
end;

procedure TRPTParameters.SaveToClient(Value: TClientObj);
begin

end;

procedure TRPTParameters.SaveToNode(Value: IXMLNode);
begin // Make sure its empty..
  if assigned(Value) then
     DeleteAllChildren(Value);
end;

procedure TRPTParameters.SetBatchBool(const Name: string; Value: Boolean);
begin
   if HaveSettings then
     SetNodeBool(FrptBatch.Settings,Name,Value);
end;

procedure TRPTParameters.SetBatchInteger(const Name: string; Value: integer);
begin
   if HaveSettings then
      SetNodeTextInt(FrptBatch.Settings,Name,Value);
end;

procedure TRPTParameters.SetBatchText(const Name, Value: string);
begin
    if HaveSettings then
     SetNodeTextStr(FrptBatch.Settings,Name,Value);
end;

procedure TRPTParameters.SetClient(const Value: TClientObj);
begin
  FClient := Value;
  if Assigned(FCLient) then begin
     SaveClient;
     LoadFromClient(FClient);
     LoadChart;
  end;
end;

procedure TRPTParameters.SetDateMode(const Value: TDateMode);
begin
  FDateMode := Value;
  Fromdate := 0;
  ToDate := 0;
  if assigned(FClient) then
     case FDateMode of
        dNone: ; // done..
        dPeriod: begin
            Fromdate := Client.clFields.clPeriod_Start_Date;
            ToDate   := Client.clFields.clPeriod_End_Date;
        end;
        dYear: begin
           Fromdate := Client.clFields.clReporting_Year_Starts;
           Todate := 0; // The dialogs will sort this...
           (*
           if gCodingDateTo > Fromdate then
              ToDate := gCodingDateTo
           else if Client.clFields.clPeriod_End_Date > Fromdate then
              ToDate   := Client.clFields.clPeriod_End_Date
           else
              ToDate  := Fromdate;
           *)
         end
     end;
end;

procedure TRPTParameters.SetDlgButtons(BtnPreview,BtnFile,BtnSave,BtnPrint: TButton);
begin
 RunBtn := BTN_NONE; //While we are here...
 case BatchRunMode of
    R_Normal : begin
                BtnSave.caption := 'Add';
                if btnSave is TBitBtn then
                   ImagesFrm.AppImages.Client.GetBitmap(CLIENT_FAVOURITES_BMP, TBitBtn(BtnSave).Glyph);
             end;
    R_Setup,
    R_BatchAdd : begin // R_BatchAdd should not realy happen here...
                BtnSave.caption := 'Sa&ve';
                if btnSave is TBitBtn then
                   ImagesFrm.AppImages.Client.GetBitmap(CLIENT_FAVOURITES_BMP, TBitBtn(BtnSave).Glyph);
             end;
    R_Batch : begin
               BtnSave.caption := 'Pre&vious';
               BtnSave.Enabled := BatchReports.Selected.IndexOf( FRptBatch) <> 0;

               BtnPrint.caption := 'Ne&xt';
               BtnPrint.Default := True;
               if Assigned(BtnPreview) then begin
                  BtnPreview.Hide;
                  BtnPreview.Default := False;
               end;
               if Assigned(BtnFile) then
                  BtnFile.Hide;
             end;
    end;
end;

procedure TRPTParameters.SetReportType(const Value: Integer);
begin
  FReportType := Value;
end;

procedure TRPTParameters.SetRptBatch(const Value: TReportBase);
begin
  FRptBatch := Value;
  if assigned(FRptBatch) then begin
      LoadFromRptBatch(FRptBatch);
  end;
end;

procedure TRPTParameters.SetRunBtn(const Value: Integer);
begin
  FRunBtn := Value;
  if assigned(FRptBatch) then
    FRptBatch.RunBtn := FRunBtn;
end;

procedure TRPTParameters.SetScheduled(const Value: Boolean);
begin
  FScheduled := Value;
end;

function TRPTParameters.UsageTitle(Destination: TReportDest): string;
begin
   Result := Get_ReportName(ReportType);

   if Assigned(RptBatch) then  // Via Favourites
      if BatchRunMode = R_Batch then
         Result := Result + '(Generate)'
      else
         Result := Result + '(Favourite)';
   if Scheduled then
      Result := Result + '(Scheduled)';

   case Destination of
      rdScreen:  Result := Result + '(View)';
      rdPrinter:  Result := Result + '(Print)';
      rdFile: if BatchRunMode = R_Batch then
         Result := Result + '(View)' // PDF for viewer
         // Could Make result '' ....
         // You get no option but to view,
         // so maybe only interested if they do something,
         // Email or print is counted as well
      else
         Result := Result + '(File)';
      // These dont realy happen...
      rdEmail: Result := Result + '(Email)';
      rdFax: Result := Result + '(Fax)';
      rdEcoding:Result := Result + '(Ecoding)';
      rdCSVExport:Result := Result + '(CSVExport)';
      rdWebX:Result := Result + '(WebX)';
      rdCheckOut:Result := Result + '(FCheckOut)';
      rdBusinessProduct:Result := Result + '(BusinessProduct)';
   end;

end;

function TRPTParameters.WasNewBatch: Boolean;
begin
   Result := (BatchRunMode = R_BatchAdd);
  // if Result then
  //    FRptBatch.BatchRunMode := R_Setup;
end;

{ TGenRptParameters }

constructor TGenRptParameters.Create(aType: Integer;
                       aClient: TClientObj; batch: TReportBase;
  const ADateMode: tDateMode; DoBudget: Boolean);
begin
   inherited Create(aType, aClient, batch, ADateMode);
   if DoBudget then
      Budget := GetBatchBudget;
end;

procedure TGenRptParameters.LoadFromClient(Value: TClientObj);
begin
   ChartCodes := Client.clFields.clFRS_Print_Chart_Codes;
   ShowGst := Client.clFields.clGST_Inclusive_Cashflow;
   ShowBudgetQuantities := Client.clExtra.ceBudget_Include_Quantities;
   Period := 0;
   Budget := nil;
end;

procedure TGenRptParameters.ReadFromNode(Value: IXMLNode);
begin
   ShowGst := GetBatchBool('GST_Inclusive',ShowGst);
   Division := GetBatchDivision;
   Period := GetBatchInteger('_Period',period);
   //Budget := GetBatchBudget; Case 5701
   ChartCodes := GetBatchBool('Show_Chart_Codes',ChartCodes);
   ShowBudgetQuantities := GetBatchBool('Show_Budget_Quantaties', ShowBudgetQuantities);
end;

procedure TGenRptParameters.SaveToClient(Value: TClientObj);
begin
   Client.clFields.clFRS_Print_Chart_Codes := ChartCodes;
end;

procedure TGenRptParameters.SaveToNode(Value: IXMLNode);
begin
   inherited;
   // Save the details...
   SetBatchBool('GST_Inclusive',ShowGst);
   SaveBatchDivision(Division);
   if assigned(Budget) then
      SetBatchText('Budget',Budget.buFields.buName);
   if period <> 0 then
      SetBatchInteger('_Period',Period);
   SetBatchBool('Show_Chart_Codes',ChartCodes);
   SetBatchBool('Show_Budget_Quantaties', ShowBudgetQuantities);
end;


constructor TCustomRptParameters.Create(aType: Integer; aClient: TClientObj;
  batch: TReportBase; const ADateMode: tDateMode; DoBudget: Boolean);
begin
  FPrintNPChartCodeTitles := False;
  FNPChartCodeDetailType := 0;
  inherited create(aType, aClient, batch, ADateMode, DoBudget);
end;

procedure TCustomRptParameters.LoadFromClient(Value: TClientObj);
begin
  inherited;
  PrintNPChartCodeTitles := Client.clExtra.ceFRS_Print_NP_Chart_Code_Titles;
  if PrintNPChartCodeTitles then
    NPChartCodeDetailType := Client.clExtra.ceFRS_NP_Chart_Code_Detail_Type;
end;

procedure TCustomRptParameters.ReadFromNode(Value: IXMLNode);
begin
  inherited;
  PrintNPChartCodeTitles := GetBatchBool('Show_NP_Chart_Titles',
                                         PrintNPChartCodeTitles);
  if PrintNPChartCodeTitles then
    NPChartCodeDetailType :=
      LoadBatchIntAsStringValue(Value, 'NP_Chart_Code_Detail_Type',
                                NPChartCodeDetailTypeStr);
end;

procedure TCustomRptParameters.SaveToClient(Value: TClientObj);
begin
  inherited;
  Client.clExtra.ceFRS_Print_NP_Chart_Code_Titles := PrintNPChartCodeTitles;
  Client.clExtra.ceFRS_NP_Chart_Code_Detail_Type := NPChartCodeDetailType;
end;

procedure TCustomRptParameters.SaveToNode(Value: IXMLNode);
begin
  inherited;
  SetBatchBool('Show_NP_Chart_Titles', PrintNPChartCodeTitles);
  if PrintNPChartCodeTitles then
    SaveBatchIntAsStringValue(Value, 'NP_Chart_Code_Detail_Type',
                              NPChartCodeDetailType,
                              NPChartCodeDetailTypeStr);
end;

procedure TCustomRptParameters.SetNPChartCodeDetailType(const Value: Byte);
begin
  FNPChartCodeDetailType := Value;
end;

procedure TCustomRptParameters.SetPrintNPChartCodeTitles(const Value: Boolean);
begin
  FPrintNPChartCodeTitles := Value;
end;

end.

