unit SelectGSTPeriodDlg;
//------------------------------------------------------------------------------
{
   Title:

   Description:  Allows the user to select a GST/BAS period

   Remarks:      Now has seperate dialogs for BAS and GST

   Author:

}
//------------------------------------------------------------------------------

interface

uses
  rptparams,
  bkDateUtils,
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  StDate,Buttons, ExtCtrls, ComCtrls, ImgList,
  OsFont;


type
  TdlgSelectGSTPeriod = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    lvGSTPeriod: TListView;
    Bevel1: TBevel;
    btnSave: TBitBtn;
    btnAdd: TButton;
    BtnClear: TButton;
    procedure OKBtnClick(Sender: TObject);
    procedure lvGSTPeriodDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure lvGSTPeriodChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure btnSaveClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure BtnClearClick(Sender: TObject);
  private
    { Private declarations }
    FSelectedPeriod: TdateRange;
    FHelpID : integer;
    FrptParams: TRptParameters;
    FFirstDate,
    FLastDate : Integer;
    procedure SetSelectedPeriod(const Value: TdateRange);
    procedure AddRange(d1,d2: TstDate; Avail, Uncoded, Image: integer);
    procedure SetUpHelp;
    procedure SetrptParams(const Value: TRptParameters);
    procedure FillPeriod(DFrom,DTo: TstDate; Image: Integer);
    procedure FillFrombalance;
  protected
    procedure UpdateActions; override;
  public
    { Public declarations }
    function Execute (ForDate : TStDate) : boolean;
    property SelectedPeriod : TdateRange read FSelectedPeriod write SetSelectedPeriod;
    procedure SelectDate (adate : TstDate);
    property rptParams: TRptParameters read FrptParams write SetrptParams;
  end;

function SelectGSTPeriod (var Ad1: tStDate; var Ad2 : tStDate; Params: TRptParameters = nil) : boolean;
function SelectBASPeriod (var Ad1: tStDate; var Ad2 : tStDate; Params: TRptParameters = nil) : boolean;
function SelectVATPeriod (var Ad1: tStDate; var Ad2 : tStDate; Params: TRptParameters = nil) : boolean;

function SelectAnnualBASPeriod (var Ad1: tStDate; var Ad2 : tStDate; Params: TRptParameters = nil) : boolean;
//******************************************************************************
implementation

{$R *.DFM}

uses
  YesNoDlg,
  baObj32,
  bkutil32,
  bkHelp,
  bkdefs,
  bkXPThemes,
  DlgSelectPeriod,
  globals,
  pddates32,
  stDateSt,
  imagesfrm,
  bkconst,
  uBatchBase,
  math, clObj32, ECollect, BaList32, trxList32;

const
  img_Balance = 0;
  img_NoBalance = 11;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectGSTPeriod.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  FSelectedPeriod.FromDate := 0;
  FSelectedPeriod.ToDate   := 0;

  SetUpHelp;
  FHelpID := 0;

  //favorite reports functionality is disabled in simpleUI
  if Active_UI_Style = UIS_Simple then
     btnSave.Hide;

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectGSTPeriod.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   lvGSTPeriod.Hint       :=
      'Select a period from the list|'+
      'Select a period from the list';

   btnAdd.Hint :=
      'Add a GST period with dates that do not match the current GST set up|' +
      'Add a GST period with dates that do not match the current GST set up';

   btnClear.Hint :=
      'Clear saved data for this GST period|' +
      'Clear saved data for this GST period';
end;
procedure TdlgSelectGSTPeriod.UpdateActions;
begin
  inherited;

  if btnClear.Visible then begin
     {$B-}
     btnClear.Enabled := Assigned(LVGSTPeriod.Selected)
                       and (LVGSTPeriod.Selected.ImageIndex = Img_Balance);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsValidAccountType( const AccountType : integer; const aClient : TClientObj) : boolean;
begin
  Result := (AccountType in [btBank,btCashJournals,btGSTJournals]) or
            ((AccountType = btAccrualJournals) and (not aClient.clFields.clGST_Excludes_Accruals));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure CountEff( D1, D2 : TstDate; Var Number, Number_Uncoded : LongInt );
Var
   B,
   T    : LongInt;
   pT   : pTransaction_Rec;
   Ba   : TBank_Account;
Begin
   Number := 0;
   Number_Uncoded := 0;

   //count the number of transactions for in the period
   for b := MyClient.clBank_Account_List.First to MyClient.clBank_Account_List.Last do
   begin
     Ba := MyClient.clBank_Account_List.Bank_Account_At( b);
     //see if this account should be included
     if IsValidAccountType( Ba.baFields.baAccount_Type, MyClient) then
     begin
       for t := ba.baTransaction_List.First to ba.baTransaction_List.Last do
       begin
         pT := ba.baTransaction_List.Transaction_At( t);
         if ( pT^.txDate_Effective >=D1 ) and ( pT^.txDate_Effective <=D2 ) then
         begin
           Inc( Number );
           If IsUncoded( pT) then
             Inc( Number_Uncoded );
         end;
       end;
     end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure CountPres( D1, D2 : TStDate; Var Number, Number_Uncoded : LongInt );
Var
   B,
   T    : LongInt;
   pT   : pTransaction_Rec;
   Ba   : TBank_Account;
Begin
   Number := 0;
   Number_Uncoded := 0;

   //count the number of transactions for in the period
   for b := MyClient.clBank_Account_List.First to MyClient.clBank_Account_List.Last do
   begin
     Ba := MyClient.clBank_Account_List.Bank_Account_At( b);
     //see if this account should be included
     if IsValidAccountType( Ba.baFields.baAccount_Type, MyClient) then
     begin
       for t := ba.baTransaction_List.First to ba.baTransaction_List.Last do
       begin
         pT := ba.baTransaction_List.Transaction_At( t);
         if ( pT^.txDate_Presented >=D1 ) and ( pT^.txDate_Presented <=D2 ) then
         begin
           Inc( Number );
           If IsUncoded( pT) then
             Inc( Number_Uncoded );
         end;
       end;
     end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectGSTPeriod.AddRange(d1, d2: TstDate; Avail,
  Uncoded, Image: integer);
var
  NewItem : TListItem;
begin
  if D1 < MinValidDate then
     Exit;
  if D2 > MaxValidDate then
     Exit;
    
  with lvGSTPeriod do
  begin
     NewItem := items.Add;
     NewItem.ImageIndex := Image;
     NewItem.Data := Pointer(d1);
     NewItem.Caption := stDatetoDateString('dd-nnn-yyyy',d1,true)+ ' to '+
                        stDatetoDateString('dd-nnn-yyyy',d2,true);
     NewItem.SubItems.add(inttostr(avail));
     NewItem.SubItems.add(inttostr(uncoded));
     NewItem.SubItems.Add(bkDate2Str(d1));
     NewItem.SubItems.add(bkDate2Str(d2));
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectGSTPeriod.SelectDate(adate: TstDate);
var Li : Integer;
begin
   if lvGSTPeriod.Items.Count > 0 then begin
     for Li := 0 to lvGSTPeriod.Items.Count - 1 do
       if TstDate(lvGSTPeriod.Items[LI].Data) = ADate then break;
     if LI >= lvGSTPeriod.Items.Count then
         LI := lvGSTPeriod.Items.Count - 1 ;
     {move to last item}
     lvGstPeriod.Selected := lvGSTPeriod.Items[Li];
     lvGSTPeriod.Selected.Focused := true;
     lvGSTPeriod.Selected.MakeVisible(false);

     {so that is actually drawn correctly - bit of a hack really}
     keybd_event(VK_UP,0,0,0);
     keybd_event(VK_DOWN,0,0,0);
   end;

end;

procedure TdlgSelectGSTPeriod.SetrptParams(const Value: TRptParameters);
begin
  FrptParams := Value;
  if Assigned(FrptParams) then begin
      FrptParams.SetDlgButtons(nil,nil,BtnSave,OkBtn);
      if FrptParams.BatchRunMode = R_Normal then begin
         BtnSave.Caption := 'Add to Favourites';
         BtnSave.Left := BtnSave.Left - 75;
         BtnSave.Width := BtnSave.Width + 75;
      end;
      if Assigned(FrptParams.RptBatch) then
         Caption := Caption + ' [' + FrptParams.RptBatch.Name + ']';
  end else
    BtnSave.Hide;
end;

procedure TdlgSelectGSTPeriod.SetSelectedPeriod(const Value: TdateRange);
begin
  FSelectedPeriod := Value;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectGSTPeriod.OKBtnClick(Sender: TObject);
begin
   if lvGSTPeriod.Selected = nil then begin
      exit; // Nothing selected
   end;

   FSelectedPeriod.FromDate := bkStr2Date(lvGSTPeriod.Selected.SubItems[2]);
   FSelectedPeriod.ToDate   := bkStr2Date(lvGSTPeriod.Selected.SubItems[3]);


   if Assigned(rptParams) then
      rptParams.RunBtn := BTN_PRINT;
   modalResult := mrOK;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectGSTPeriod.lvGSTPeriodChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
   OKBtn.Enabled := (lvGSTPeriod.Selected <> nil);
end;

procedure TdlgSelectGSTPeriod.lvGSTPeriodDblClick(Sender: TObject);
begin
  okBtn.click;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectGSTPeriod.btnAddClick(Sender: TObject);
var
  DateRange: TDateRange;
  TaxName: string;
begin
   if lvGSTPeriod.Selected = nil then begin
     if lvGSTPeriod.Items.Count > 0 then begin
        DateRange.FromDate :=
           bkStr2Date(lvGSTPeriod.Items[Pred(lvGSTPeriod.Items.Count)].SubItems[2]);
        DateRange.ToDate :=
           bkStr2Date(lvGSTPeriod.Items[Pred(lvGSTPeriod.Items.Count)].SubItems[3]);
     end;

   end else begin
      DateRange.FromDate := bkStr2Date(lvGSTPeriod.Selected.SubItems[2]);
      DateRange.ToDate   := bkStr2Date(lvGSTPeriod.Selected.SubItems[3]);
   end;

   TaxName := Myclient.TaxSystemNameUC;
   if DlgSelectPeriod.SelectAPeriod('Enter Custom ' + TaxName + ' Period', DateRange) then begin
      FSelectedPeriod := DateRange;
      if Assigned(rptParams) then
         rptParams.RunBtn := BTN_PRINT;
      ModalResult := mrOK;
   end;
end;

procedure TdlgSelectGSTPeriod.BtnClearClick(Sender: TObject);
var
  I: Integer;
  TaxName: string;
begin
   if Assigned(LVGSTPeriod.Selected)
   and (LVGSTPeriod.Selected.ImageIndex = Img_Balance) then begin
      TaxName := Myclient.TaxSystemNameUC;
      if AskYesNo('Clear ' + TaxName + ' Values',
         'Are you sure you want to clear saved values for this ' + TaxName + ' period?', dlg_yes,0 ) <> dlg_yes then
          exit;

      FSelectedPeriod.FromDate := bkStr2Date(lvGSTPeriod.Selected.SubItems[2]);
      FSelectedPeriod.ToDate   := bkStr2Date(lvGSTPeriod.Selected.SubItems[3]);


      with myclient.clBalances_List do
        for I := First to Last do with Balances_At(I)^ do
           if (blGST_Period_Starts =  FSelectedPeriod.FromDate)
           and (blGST_Period_Ends = FSelectedPeriod.ToDate) then begin

              myclient.clBalances_List.DelFreeItem(Balances_At(I));
              Break;
           end;
      FillFrombalance;
      Selectdate(FSelectedPeriod.FromDate);
   end;
end;

procedure TdlgSelectGSTPeriod.btnSaveClick(Sender: TObject);
begin
  if not rptParams.CheckForBatch then
     Exit;
  if Assigned(rptParams) then
     rptParams.RunBtn := BTN_SAVE;
  Modalresult := mrOk;
end;




procedure TdlgSelectGSTPeriod.FillFrombalance;
var I: integer;
    D1, D2: Integer;
    NumberAvailable: LongInt;
    NumberUncoded: LongInt;
    pb: pBalances_Rec;
begin
    lvGSTPeriod.Clear;


    D1 := FFirstDate;
    D2 := 0;
    with MyClient.clBalances_List do
       for I := First to last do begin
          pb := Balances_At(i);
          if (pb.blGST_Period_Starts > MinValidDate) then begin
             if (D1 < pb.blGST_Period_Starts) then // Fill any gaps
                FillPeriod(D1, pb.blGST_Period_Starts, img_NoBalance);
             CountEff(pb.blGST_Period_Starts,pb.blGST_Period_Ends,NumberAvailable,NumberUncoded);
             AddRange(pb.blGST_Period_Starts,pb.blGST_Period_Ends,numberavailable,numberuncoded,img_Balance);
             D1 := pb.blGST_Period_Ends + 1; // Only move forward
             //D1 := Max(D1,pb.blGST_Period_Ends);
             D2 := Max(D2,pb.blGST_Period_Ends);
          end;
        end;

    if (D2 > 0) then begin
       // Have some periods
       if (FlastDate > D2) then
          FillPeriod(D2+1, Get_Next_PSDate_GST(FlastDate, MyClient.clFields.clGST_Period), img_NoBalance);
    end else begin
       FillPeriod(FFirstDate, Get_Next_PSDate_GST(FlastDate, MyClient.clFields.clGST_Period) , img_NoBalance);
    end;
end;

procedure TdlgSelectGSTPeriod.FillPeriod(DFrom, DTo: TstDate; Image: Integer);
var D1, D2: TstDate;
   NumberAvailable      : LongInt;
   NumberUncoded        : LongInt;
begin
    // Start with a valid date.
    D1 := DMYTostDate( 1, MyClient.clFields.clGST_Start_Month, DefaultYear, BKDATEEPOCH );
    repeat //Now Move the period back.....
       D1 := Get_Previous_PSDate_GST( D1, MyClient.clFields.clGST_Period );
       D2 := Get_PEDate_GST( D1, MyClient.clFields.clGST_Period );
    until (D2 < DFrom); //... until the last whole period before the from-date

    repeat // now move forward....
       D1 := Get_Next_PSDate_GST( D1, MyClient.clFields.clGST_Period );
       D2 := Get_PEDate_GST( D1, MyClient.clFields.clGST_Period );
    until (D2 >= DFrom); //...to find the first one to include the from date

    repeat // From here add them to the listview and continue to move forward ...
       CountPres(D1, D2, NumberAvailable, NumberUncoded);
       if (NumberAvailable > 0) then
          AddRange(d1,d2,numberavailable,numberuncoded,Image);
       D1 := Get_Next_PSDate_GST(D1, MyClient.clFields.clGST_Period);
       D2 := Get_PEDate_GST(D1, MyClient.clFields.clGST_Period);
    until (D2 >= DTo); // we have reached/passed the to-date
end;

function TdlgSelectGSTPeriod.Execute(ForDate : TStDate): boolean;
var
   B, T            :LongInt;
   Transaction     :pTransaction_Rec;
   AccountTypeOK   :boolean;
begin
   FFirstDate := MaxInt;
   FLastDate := 0;

   {find first and last dates of transactions}
   With MyClient, clFields, clBank_Account_List do
   For B := 0 to Pred( itemCount ) do With Bank_Account_At( B ) do
   begin
     //check correct journal accounts are being used, exclude stock and opening journals
     AccountTypeOK := IsValidAccountType( baFields.baAccount_Type, MyClient);

     If AccountTypeOK then
        With baTransaction_List do For T := 0 to Pred( itemCount ) do
        Begin
          Transaction := Transaction_At( T );
          With Transaction^ do Begin
             if clGST_on_Presentation_Date then begin
                if ( txDate_Presented > 0 ) then begin
                  FFirstDate := Min(FFirstDate, txDate_Presented);
                  FLastDate  := Max(FLastDate,  txDate_Presented);
                end;
             end else begin
                if (txDate_Effective > 0) then Begin
                  FFirstDate := Min(FFirstDate, txDate_Effective);
                  FLastDate  := Max(FLastDate,  txDate_Effective);
                end;
             end;
          end;
        end;
   end;

   (* Original way...
   //Build list of GST/BAS periods
   With MyClient, MyClient.clFields do
   Begin
      If clGST_on_Presentation_Date then
      Begin
         D1 := DMYTostDate( 1, clGST_Start_Month, DefaultYear, BKDATEEPOCH );
         Repeat
            D1 := Get_Previous_PSDate_GST( D1, clGST_Period );
            D2 := Get_PEDate_GST( D1, clGST_Period );
         Until ( D2 < FirstPres );

         D1 := Get_Next_PSDate_GST( D1, clGST_Period );
         D2 := Get_PEDate_GST( D1, clGST_Period );

         {add into listview}
         Repeat
            CountPres( D1, D2, NumberAvailable, NumberUncoded );
            if ( NumberAvailable > 0 ) then AddRange(d1,d2,numberavailable,numberuncoded);
            D1 := Get_Next_PSDate_GST( D1, clGST_Period );
            D2 := Get_PEDate_GST( D1, clGST_Period );
         Until ( D1 > LastPres );
      end
      else
      Begin { Show them based on Effective Date }
         D1 := DMYTostDate( 1, clGST_Start_Month, DefaultYear , BKDATEEPOCH);
         Repeat
            D1 := Get_Previous_PSDate_GST( D1, clGST_Period );
            D2 := Get_PEDate_GST( D1, clGST_Period );
         Until ( D2 < FirstEff );

         D1 := Get_Next_PSDate_GST( D1, clGST_Period );
         D2 := Get_PEDate_GST( D1, clGST_Period );

         {add into list view}
         Repeat
            CountEff( D1, D2, NumberAvailable, NumberUncoded );
            if NumberAvailable >0 then AddRange(d1,d2,numberavailable,numberuncoded);
            D1 := Get_Next_PSDate_GST( D1, clGST_Period );
            D2 := Get_PEDate_GST( D1, clGST_Period );
         Until ( D1 > LastEff );
      end;
   end;
   *)

   // Fill using the balance list
   FillFrombalance;

   Selectdate(ForDate);

   Self.ShowModal;

   result := ( ModalResult = mrOK);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SelectGSTPeriod (var Ad1: tStDate; var Ad2 : tStDate; Params: TRptParameters = nil) : boolean;
var
  myDlg : tdlgselectGstPeriod;
begin
  result := false;
  myDlg := tdlgSelectGstPeriod.Create(Application.MainForm);
  try
    MyDlg.FHelpID := BKH_GST_Return_GST_101;
    MyDlg.rptParams := Params;
    if myDlg.execute(Ad1) then begin
      Ad1 := MyDlg.SelectedPeriod.FromDate;
      Ad2 := MyDlg.SelectedPeriod.ToDate;
      if Assigned(Params) then
         Result := Params.DlgResult
      else
         Result := true;
    end;
  finally
    myDlg.free;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function SelectVATPeriod (var Ad1: tStDate; var Ad2 : tStDate; Params: TRptParameters = nil) : boolean;
var
  myDlg : tdlgselectGstPeriod;
begin
  result := false;
  myDlg := tdlgSelectGstPeriod.Create(Application);
  try
    MyDlg.Caption := 'Select VAT Period';
    MyDlg.BtnAdd.Hide; // Not Used for VAT
    MyDlg.btnClear.Hide;
    MyDlg.FHelpID := BKH_GST_Return_GST_101; // ????
    MyDlg.rptParams := Params;
    if myDlg.execute(Ad1) then begin
      Ad1 := MyDlg.SelectedPeriod.FromDate;
      Ad2 := MyDlg.SelectedPeriod.ToDate;
      if Assigned(Params) then
         Result := Params.DlgResult
      else
         Result := true;
    end;
  finally
    myDlg.free;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function SelectBASPeriod (var Ad1: tStDate; var Ad2 : tStDate; Params: TRptParameters = nil) : boolean;
//called from:  BASFrm
//Assumes that the gst period will be assigned and start date assigned
var
   NumberAvailable      : LongInt;
   NumberUncoded        : LongInt;
   FirstEff, LastEff    : LongInt;
   FirstPres, LastPres  : LongInt;
   B, T                 : LongInt;
   Transaction          : pTransaction_Rec;
   AccountTypeOK        : boolean;

   GSTPeriodType,
   PAYGWithheldType,
   PAYGInstalmentType   : byte;

   BASPeriodType        : byte;
   d1, d2 : TstDate;
begin
   result := false;
   with TDlgSelectGSTPeriod.Create(Application.MainForm) do begin
      try
         caption := 'Select BAS/IAS Period';
         //find first and last dates of transactions
         FirstEff    := 0;
         LastEff     := 0;
         FirstPres   := 0;
         LastPres    := 0;
         BtnAdd.Hide; // Not Used for BAS
         btnClear.Hide;

         FHelpID := BKH_Producing_the_Business_Activity_Statement;

         with MyClient, clFields, clBank_Account_List do begin
            for B := 0 to Pred( itemCount ) do With Bank_Account_At( B ) do begin
               //check correct journal accounts are being used, exclude stock and opening journals
               AccountTypeOK := IsValidAccountType( baFields.baAccount_Type, MyClient);

               If AccountTypeOK then
                  With baTransaction_List do For T := 0 to Pred( itemCount ) do Begin
                     Transaction := Transaction_At( T );
                     With Transaction^ do Begin
                        If ( txDate_Effective > 0 ) then Begin
                           If ( FirstEff=0 ) or ( ( FirstEff<>0 ) and ( txDate_Effective<FirstEff ) ) then
                              FirstEff := txDate_Effective;
                           If txDate_Effective > LastEff then LastEff := txDate_Effective;
                        end;
                        If ( txDate_Presented > 0 ) then Begin
                           If ( FirstPres=0 ) or ( ( FirstPres<>0 ) and ( txDate_Presented<FirstPres ) ) then
                              FirstPres := txDate_Presented;
                           If txDate_Presented > LastPres then LastPres := txDate_Presented;
                        end;
                     end;
                  end;
            end;
         end; //with
         //Build list of BAS periods.  Need to select the narrowest period
         //from the gst period and payg period.
         GSTPeriodType := 99;
         PAYGInstalmentType := 99;
         PAYGWithheldType := 99;

         with MyClient.clFields do begin
            //get the real type out of the objects property
            if ( clGST_Period > 0) then
               GSTPeriodType := clGST_Period;
            if ( clBAS_PAYG_Withheld_Period > 0) then
               PAYGWithheldType := clBAS_PAYG_Withheld_Period;
            if ( clBAS_PAYG_Instalment_Period > 0) then
               PAYGInstalmentType := clBAS_PAYG_Instalment_Period;
         end;

         BasPeriodType := Min( PAYGWithheldType, Min( GSTPeriodType, PAYGInstalmentType));

         With MyClient, MyClient.clFields do Begin
            If clGST_on_Presentation_Date then Begin
               D1 := DMYTostDate( 1, clGST_Start_Month, DefaultYear, BKDATEEPOCH );
               Repeat
                  D1 := Get_Previous_PSDate_GST( D1, BASPeriodType );
                  D2 := Get_PEDate_GST( D1, BASPeriodType );
               Until ( D2 < FirstPres );

               D1 := Get_Next_PSDate_GST( D1, BASPeriodType );
               D2 := Get_PEDate_GST( D1, BASPeriodType );

               {add into listview}
               Repeat
                  CountPres( D1, D2, NumberAvailable, NumberUncoded );
                  if ( NumberAvailable > 0 ) then AddRange(d1,d2,numberavailable,numberuncoded,img_Balance);
                  D1 := Get_Next_PSDate_GST( D1, BASPeriodType );
                  D2 := Get_PEDate_GST( D1, BASPeriodType );
               Until ( D1 > LastPres );
            end
            else Begin
               { Show them based on Effective Date }
               D1 := DMYTostDate( 1, clGST_Start_Month, DefaultYear , BKDATEEPOCH);
               Repeat
                  D1 := Get_Previous_PSDate_GST( D1, BASPeriodType );
                  D2 := Get_PEDate_GST( D1, BASPeriodType );
               Until ( D2 < FirstEff );

               D1 := Get_Next_PSDate_GST( D1, BASPeriodType );
               D2 := Get_PEDate_GST( D1, BASPeriodType );

               {add into list view}
               Repeat
                  CountEff( D1, D2, NumberAvailable, NumberUncoded );
                  if NumberAvailable >0 then AddRange(d1,d2,numberavailable,numberuncoded,img_Balance);
                  D1 := Get_Next_PSDate_GST( D1, BASPeriodType );
                  D2 := Get_PEDate_GST( D1, BASPeriodType );
               Until ( D1 > LastEff );
            end;
         end;
         //move to last item
         SelectDate(Ad1);
         rptParams := Params;
         //--------------
         ShowModal;
         //--------------
         if ( ModalResult = mrOK) then begin
            Ad1 := SelectedPeriod.FromDate;
            Ad2 := SelectedPeriod.ToDate;
            result := true;
         end;
      finally
         Free;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SelectAnnualBASPeriod (var Ad1: tStDate; var Ad2 : tStDate;Params: TRptParameters = nil) : boolean;
//called from:  BASFrm
//Assumes that the gst period will be assigned and start date assigned
var
   NumberAvailable      : LongInt;
   NumberUncoded        : LongInt;
   FirstEff, LastEff    : LongInt;
   FirstPres, LastPres  : LongInt;
   B, T                 : LongInt;
   Transaction          : pTransaction_Rec;
   AccountTypeOK        : boolean;
   BASPeriodType        : byte;
   d1,d2 : tStDate;

begin
   result := false;
   with TDlgSelectGSTPeriod.Create(Application.MainForm) do begin
      try
         caption := 'Select Period';
         //find first and last dates of transactions
         FirstEff    := 0;
         LastEff     := 0;
         FirstPres   := 0;
         LastPres    := 0;
         BtnAdd.Hide; // Not Used for BAS
         BtnClear.Hide;
         with MyClient, clFields, clBank_Account_List do begin
            for B := 0 to Pred( itemCount ) do With Bank_Account_At( B ) do begin
               //check correct journal accounts are being used, exclude stock and opening journals
               AccountTypeOK := IsValidAccountType( baFields.baAccount_Type, MyClient);

               If AccountTypeOK then
                  With baTransaction_List do For T := 0 to Pred( itemCount ) do Begin
                     Transaction := Transaction_At( T );
                     With Transaction^ do Begin
                        If ( txDate_Effective > 0 ) then Begin
                           If ( FirstEff=0 ) or ( ( FirstEff<>0 ) and ( txDate_Effective<FirstEff ) ) then
                              FirstEff := txDate_Effective;
                           If txDate_Effective > LastEff then LastEff := txDate_Effective;
                        end;
                        If ( txDate_Presented > 0 ) then Begin
                           If ( FirstPres=0 ) or ( ( FirstPres<>0 ) and ( txDate_Presented<FirstPres ) ) then
                              FirstPres := txDate_Presented;
                           If txDate_Presented > LastPres then LastPres := txDate_Presented;
                        end;
                     end;
                  end;
            end;
         end; //with
         BasPeriodType := gpAnnually;

         With MyClient, MyClient.clFields do Begin
            If clGST_on_Presentation_Date then Begin
               D1 := DMYTostDate( 1, clGST_Start_Month, DefaultYear, BKDATEEPOCH );
               Repeat
                  D1 := Get_Previous_PSDate_GST( D1, BASPeriodType );
                  D2 := Get_PEDate_GST( D1, BASPeriodType );
               Until ( D2 < FirstPres );

               D1 := Get_Next_PSDate_GST( D1, BASPeriodType );
               D2 := Get_PEDate_GST( D1, BASPeriodType );

               {add into listview}
               Repeat
                  CountPres( D1, D2, NumberAvailable, NumberUncoded );
                  if ( NumberAvailable > 0 ) then AddRange(d1,d2,numberavailable,numberuncoded,img_Balance);
                  D1 := Get_Next_PSDate_GST( D1, BASPeriodType );
                  D2 := Get_PEDate_GST( D1, BASPeriodType );
               Until ( D1 > LastPres );
            end
            else Begin
               { Show them based on Effective Date }
               D1 := DMYTostDate( 1, clGST_Start_Month, DefaultYear , BKDATEEPOCH);
               Repeat
                  D1 := Get_Previous_PSDate_GST( D1, BASPeriodType );
                  D2 := Get_PEDate_GST( D1, BASPeriodType );
               Until ( D2 < FirstEff );

               D1 := Get_Next_PSDate_GST( D1, BASPeriodType );
               D2 := Get_PEDate_GST( D1, BASPeriodType );

               {add into list view}
               Repeat
                  CountEff( D1, D2, NumberAvailable, NumberUncoded );
                  if NumberAvailable >0 then AddRange(d1,d2,numberavailable,numberuncoded,img_Balance);
                  D1 := Get_Next_PSDate_GST( D1, BASPeriodType );
                  D2 := Get_PEDate_GST( D1, BASPeriodType );
               Until ( D1 > LastEff );
            end;
         end;
         //move to last item
         Selectdate(Ad1);

         RptParams := Params;
         //--------------
         ShowModal;
         //--------------
         if ( ModalResult = mrOK) then begin
            Ad1 := SelectedPeriod.FromDate;
            Ad2 := SelectedPeriod.ToDate;
            result := true;
         end;
      finally
         Free;
      end;
   end;
end;

//------------------------------------------------------------------------------


procedure TdlgSelectGSTPeriod.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
   
end;
//------------------------------------------------------------------------------

procedure TdlgSelectGSTPeriod.FormShow(Sender: TObject);
begin
  BKHelpSetUp( Self, FHelpID);
end;

end.
