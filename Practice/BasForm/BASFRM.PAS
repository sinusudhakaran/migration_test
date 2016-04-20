unit BASfrm;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:    Australian Business Activity Statement

  Written:  Feb 2000
  Authors:  Neil, Matthew

  Purpose:

  Notes:    None of the Gxx fields on the calculation sheet are editable
            Change G7,G18 to not editable on May 1 2000

  History:
            01/06/06: Updated to support V2.11
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  BasControls, ExtCtrls, ComCtrls, OvcBase, StdCtrls, BasCalc, OvcEF,
  OvcPB,RptParams, OvcNF, Mask, ReportDefs, Grids_ts, TSGrid, TSMask;

type
  TfrmBAS = class(TForm)
    pgBasFrm: TPageControl;
    tabDetails: TTabSheet;
    tabGST: TTabSheet;
    tabPAYGWitholding: TTabSheet;
    Bevel4: TBevel;
    pnlButtons: TPanel;
    btnPrint: TButton;
    btnPreview: TButton;
    btnExport: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    ScrollBox1: TScrollBox;
    ScrollBox4: TScrollBox;
    P1: TPanel;
    txfP1A1a: TLabel;
    txfP1A2a: TLabel;
    txfP1A5a: TLabel;
    ffdP1A2a: TStaticText;
    ffdP1A2b: TStaticText;
    ffdP1A5: TStaticText;
    ffdP1A6: TStaticText;
    pnlName: TPanel;
    lblName: TLabel;
    lblAddr1: TLabel;
    lblAddr2: TLabel;
    lbladdr3: TLabel;
    lblemail: TLabel;
    bxfP1A1: TMaskEdit;
    lblFormTitle: TLabel;
    tabPAYGInstalment: TTabSheet;
    tabFBT: TTabSheet;
    P5: TPanel;
    txfP5Title02: TLabel;
    bxfP5W3: TBasBoxField;
    bxfP5W2: TBasBoxField;
    bxfP5W4: TBasBoxField;
    ScrollBox5: TScrollBox;
    P6: TPanel;
    ScrollBox6: TScrollBox;
    P7: TPanel;
    txfP7F4b: TLabel;
    txfP7F4a: TLabel;
    txfP7Title02: TLabel;
    bxfP7F1: TBasBoxField;
    bxfP7F2: TBasBoxField;
    bxfP7F3: TBasBoxField;
    cbfP7F4: TComboBox;
    txfP1A6a: TLabel;
    lblPeriod: TLabel;
    txfP4Title06: TLabel;
    txfP4Method: TLabel;
    tabSummary: TTabSheet;
    tabCalculationSheet: TTabSheet;
    ScrollBox2: TScrollBox;
    P4: TPanel;
    Shape7: TShape;
    Shape8: TShape;
    txfP4Title04: TLabel;
    txfP4Title05: TLabel;
    txfP4Title09: TLabel;
    txfP4Title10: TLabel;
    txfP4Title08: TLabel;
    Shape9: TShape;
    Shape10: TShape;
    Shape11: TShape;
    Shape12: TShape;
    Shape13: TShape;
    Shape14: TShape;
    Shape15: TShape;
    bxfP4G1: TBasBoxField;
    bxfP4G10: TBasBoxField;
    bxfP4G2: TBasBoxField;
    bxfP4G11: TBasBoxField;
    bxfP4G3: TBasBoxField;
    bxfP4G12: TBasBoxField;
    bxfP4G4: TBasBoxField;
    bxfP4G13: TBasBoxField;
    bxfP4G5: TBasBoxField;
    bxfP4G14: TBasBoxField;
    bxfP4G6: TBasBoxField;
    bxfP4G15: TBasBoxField;
    bxfP4G7: TBasBoxField;
    bxfP4G16: TBasBoxField;
    bxfP4G8: TBasBoxField;
    bxfP4G17: TBasBoxField;
    bxfP4G9: TBasBoxField;
    bxfP4G18: TBasBoxField;
    bxfP4G19: TBasBoxField;
    bxfP4G20: TBasBoxField;
    ScrollBox3: TScrollBox;
    P2: TPanel;
    Shape2: TShape;
    Shape3: TShape;
    line8A: TShape;
    line8B: TShape;
    Shape1: TShape;
    Shape6: TShape;
    txfP2Title03: TLabel;
    txfP2Title05: TLabel;
    bxfP21A: TBasBoxField;
    bxfP21B: TBasBoxField;
    bxfP21C: TBasBoxField;
    bxfP21D: TBasBoxField;
    bxfP21E: TBasBoxField;
    bxfP21F: TBasBoxField;
    bxfP22A: TBasBoxField;
    bxfP22B: TBasBoxField;
    bxfP24: TBasBoxField;
    bxfP25A: TBasBoxField;
    bxfP25B: TBasBoxField;
    bxfP26A: TBasBoxField;
    bxfP26B: TBasBoxField;
    bxfP27: TBasBoxField;
    bxfP28A: TBasBoxField;
    bxfP28B: TBasBoxField;
    bxfP21G: TBasBoxField;
    bxfP29: TBasBoxField;
    Label6: TLabel;
    OvcController1: TOvcController;
    bxfP5W1: TBasBoxField;
    basW5_Total: TBasBoxField;
    Bevel1: TBevel;
    Shape16: TShape;
    pnlPAYGInstalmentOpt2: TPanel;
    bxfP6T1: TBasBoxField;
    bxfP6T2: TBasBoxField;
    txfP6T2: TLabel;
    bxfP6T3: TBasBoxField;
    txfP6T3: TLabel;
    txfP6T4a: TLabel;
    txfP6T4b: TLabel;
    cbfP6T4: TComboBox;
    basT11_Calc: TBasBoxField;
    rbPAYGI_Option2: TRadioButton;
    pnlPAYGInstalmentOpt1: TPanel;
    rbPAYGI_Option1: TRadioButton;
    basT7_PAYGOption1: TBasBoxField;
    basT5: TBasBoxField;
    basT8_PAYGOption1: TBasBoxField;
    basT9_PAYGOption1: TBasBoxField;
    Label7: TLabel;
    Label8: TLabel;
    cmbT4_PAYGOption1: TComboBox;
    Label9: TLabel;
    Label10: TLabel;
    stPAYGIDates: TStaticText;
    stPAYGWDates: TStaticText;
    stFBTDates: TStaticText;
    bas1H_Summary: TBasBoxField;
    ScrollBox7: TScrollBox;
    stGSTDates: TStaticText;
    pnlGSTOption1: TPanel;
    lblGoto_Opt1: TLabel;
    basG1_GSTOption1: TBasBoxField;
    basG2_GSTOption1: TBasBoxField;
    basG3_GSTOption3: TBasBoxField;
    basG10_GSTOption1: TBasBoxField;
    BasG11_GSTOption1: TBasBoxField;
    pnlGSTOption2: TPanel;
    Label16: TLabel;
    basG1_GSTOption2: TBasBoxField;
    pnlGSTOption3: TPanel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    basG21_GSTOption3: TBasBoxField;
    basG22_GSTOption3: TBasBoxField;
    basG23_GSTOption3: TBasBoxField;
    basG24_GSTOption3: TComboBox;
    rbGSTOption1: TRadioButton;
    rbGSTOption2: TRadioButton;
    rbGSTOption3: TRadioButton;
    lblDoes_Opt1: TLabel;
    rbYes_GSTOption1: TRadioButton;
    rbNo_GSTOption1: TRadioButton;
    rbYes_GSTOption2: TRadioButton;
    rbNo_GSTOption2: TRadioButton;
    lblFormType: TLabel;
    stGSTCalcDates: TStaticText;
    bas1A_GSTOption3: TBasBoxField;
    bas9_Details: TBasBoxField;
    lbl9_Details: TLabel;
    lbl9_Summary: TLabel;
    Label18: TLabel;
    btnFile: TButton;
    Label19: TStaticText;
    Label3: TStaticText;
    Label2: TStaticText;
    Label1: TStaticText;
    Label5: TStaticText;
    Label4: TStaticText;
    txfP2Title: TStaticText;
    txfP4Title01: TStaticText;
    Label15: TLabel;
    txfP6T3b: TLabel;
    txfP6T3a: TLabel;
    bxfp7c: TBasBoxField;
    bxfp7d: TBasBoxField;
    pnlPAYGInstalmentOpt3: TPanel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    basT6_PAYGOption3: TBasBoxField;
    cmbT4_PAYGOption3: TComboBox;
    rbPAYGI_Option3: TRadioButton;
    tabFuelSheet: TTabSheet;
    ScrollBox8: TScrollBox;
    Panel1: TPanel;
    stFuelDates: TStaticText;
    StaticText2: TStaticText;
    Panel2: TPanel;
    tgFuel: TtsGrid;
    Label17: TLabel;
    tsMaskDefs1: TtsMaskDefs;
    lblTotal: TLabel;
    btnRecalc: TButton;
    rbFuel: TRadioButton;
    rbPercent: TRadioButton;
    Label20: TLabel;
    Label24: TLabel;
    btnEmail: TButton;
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnOKClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CauseRedisplay(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure cbfP6T4DropDown(Sender: TObject);
    procedure cbfP7F4DropDown(Sender: TObject);
    procedure lblGotoTopClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure rbGSTOption1Click(Sender: TObject);
    procedure rbPAYGI_Option1Click(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure cbfP6T4Change(Sender: TObject);
    procedure tgFuelCellChanged(Sender: TObject; OldCol, NewCol, OldRow,
      NewRow: Integer);
    procedure btnRecalcClick(Sender: TObject);
    procedure tgFuelEndCellEdit(Sender: TObject; DataCol, DataRow: Integer;
      var Cancel: Boolean);
    procedure rbFuelClick(Sender: TObject);
    procedure tgFuelEnter(Sender: TObject);
    procedure tgFuelExit(Sender: TObject);
    procedure tabFuelSheetShow(Sender: TObject);
    procedure tabFuelSheetHide(Sender: TObject);
    procedure rbYes_GSTOption1Click(Sender: TObject);
    procedure rbNo_GSTOption1Click(Sender: TObject);
    procedure bxfP1A1Click(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
  private
    { Private declarations }
    BasInfo      : TBasInfo;
    SettingFields : boolean;
    FrptParams: TrptParameters;

    procedure ReadEditableFields;
    procedure SetEditableFields;
    procedure ClearUnselectedFields;

    procedure ReDisplay;

    procedure PromptForFinalise( action : string);
    function  VerifyFields : boolean;
    procedure GenerateReport(Dest: TReportDest; aMsg: string);
    function CalculateQtyTotals(D1, D2 : LongInt; ChartCode: string; var AccountOK: Boolean): Extended;
    procedure UpdateTotalFuelCount;
    procedure ReBuildFuelGrid;
    procedure SetrptParams(const Value: TrptParameters);
  public
    { Public declarations }
    function Execute(d1 : integer; d2: integer;  SpecialFormType : integer) : boolean;
    property rptParams: TrptParameters read FrptParams write SetrptParams;
  end;


procedure ShowBASForm (Fromdate: Integer = 0; Todate: Integer = 0;
                       Params: TrptParameters = nil);

procedure ShowAnnualGSTReturn(Params: TrptParameters = nil);
procedure ShowAnnualGSTInformationReport(Params: TrptParameters = nil);

//******************************************************************************
implementation

uses
//  bkXPThemes,
  bkhelp,
  Globals,
  InfoMoreFrm,
  ErrorMoreFrm,
  EditGSTDlg,
  WarningMoreFrm,
  pddates32,
  SelectGSTPeriodDlg,
  bkdefs,
  baobj32,
  BKBLIO,
  gstUtil32,
  YesnoDlg,
  finalise32,
  bkutil32,
  GenUtils,
  bkDateUtils,
  StdHints,
  TravUtils,
  MonitorUtils,
  bkConst,
  rptBAS,
  StDate,
  StDateSt,
  UbatchBase,
  LogUtil,
  BasUtils,
  BasExport;

{$R *.DFM}

CONST
   UnitName = 'BASfrm';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBAS.FormCreate(Sender: TObject);
var
   WorkArea : TRect;
   MonitorWidth : integer;
   MonitorHeight : integer;
const
   WorkHeight = 750;
begin
//   bkXPThemes.ThemeForm( Self);
   //Find out what area we have to work with
   pgBasFrm.Font := Application.MainForm.font;
   pnlButtons.Font := Application.MainForm.font;
   btnReCalc.Font := Application.MainForm.font;

   WorkArea := GetDesktopWorkArea;
   //Setup Screen
   MonitorHeight := WorkArea.Bottom - WorkArea.Top;
   if MonitorHeight > WorkHeight then
      Height := WorkHeight
   else
      Height := MonitorHeight;
   if MonitorHeight < 600 then
   begin
     Position := poMainFormCenter;
     Top := 0;
   end
   else
     Top := WorkArea.Top + ( MonitorHeight div 2 - Height Div 2);
   MonitorWidth := WorkArea.Right - WorkArea.Left;
   if MonitorWidth < 800 then
     Width := MonitorWidth;
   Left         := WorkArea.Left + ( MonitorWidth div 2 - width div 2);
   SetUpHelp;                                      
   //change the data format of some of the controls
   with bxfP6T2.NumericEdit do begin
      DataType   := nftDouble;
      PictureMask := '##.##';  //percentage
   end;
   //change the data format of some of the controls
   with bxfP6T3.NumericEdit do begin
      DataType   := nftDouble;
      PictureMask := '##.##';  //percentage
   end;
   //Create bas info object
   SettingFields := false;
   BasInfo := TBasInfo.Create;
   BasInfo.IsFuel := MyClient.clFields.clBAS_Include_Fuel;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBAS.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;

   //Components
   btnPreview.Hint     :=
                       STDHINTS.PreviewHint;
   btnPrint.Hint       :=
                       STDHINTS.PrintHint;
   btnExport.Hint      := '';
end;

procedure TfrmBAS.tabFuelSheetHide(Sender: TObject);
begin
  BKHelpSetUp( Self, BKH_How_BankLink_populates_the_GST_Calculation_Sheet);
end;

procedure TfrmBAS.tabFuelSheetShow(Sender: TObject);
begin
  BKHelpSetUp( Self, BKH_How_BankLink_populates_the_Fuel_Tax_Worksheet);
end;

procedure TfrmBAS.tgFuelCellChanged(Sender: TObject; OldCol, NewCol, OldRow,
  NewRow: Integer);
var
  Eligible, Rate, Percent, Litres: Double;
begin
  Eligible := StrToFloatDef(tgFuel.Cell[colEligible, OldRow], 0);
  Rate     := StrToFloatDef(tgFuel.Cell[colRate,     OldRow], 0);
  Percent  := StrToFloatDef(tgFuel.Cell[colPercent,  OldRow], 0);
  Litres   := StrToFloatDef(tgFuel.Cell[colLitres,   OldRow], 0);
  if (OldCol = colRate) then
     tgFuel.Cell[colTotal, OldRow] := MyRoundTo(Eligible * (Rate/ 100), 2)
  else if (OldCol = colEligible) then begin
     if Litres = 0 then
        tgFuel.Cell[colPercent, OldRow] := 0
     else
        tgFuel.Cell[colPercent, OldRow] := MyRoundTo((Eligible / Litres) * 100, 0);
     tgFuel.Cell[colTotal, OldRow] := MyRoundTo(Eligible * (Rate/ 100), 2);
  end else if (OldCol = colPercent)
           or (OldCol = colLitres) then begin
     tgFuel.Cell[colEligible, OldRow] := MyRoundTo((Litres / 100) * Percent, 0);
     tgFuel.Cell[colTotal, OldRow] := MyRoundTo(tgFuel.Cell[colEligible, OldRow] * (Rate / 100), 2);
  end;

  if  (Litres = 0)
  and (Percent = 0)
  and (Eligible = 0)
  and (Rate = 0) then begin
     tgFuel.Cell[colEligible, OldRow] := '';
     tgFuel.Cell[colTotal, OldRow] := '';
     tgFuel.Cell[colLitres, OldRow] := '';
     tgFuel.Cell[colPercent, OldRow] := '';
  end;
  UpdateTotalFuelCount;
  Redisplay;
end;

procedure TfrmBAS.tgFuelEndCellEdit(Sender: TObject; DataCol, DataRow: Integer;
  var Cancel: Boolean);
var
  Eligible: string;
begin
  if (DataCol = colPercent)
  and (tgFuel.Cell[DataCol, DataRow] <> '')
  and (tgFuel.Cell[DataCol, DataRow] > 100) then
  begin
     HelpfulErrorMsg('Percentage cannot be greater than 100', 0);
     Cancel := True;
  end else if (DataCol = colLitres) then begin
     Eligible := tgFuel.Cell[colEligible, DataRow];
     if Eligible = '' then
        Eligible := '0';
     if (tgFuel.Cell[DataCol, DataRow] <> '') and (tgFuel.Cell[DataCol, DataRow] < StrToFloat(Eligible)) then
     begin
        HelpfulErrorMsg('"Total Business Use of Eligible Fuel" cannot be greater than "Total Fuel Acquisitions"', 0);
        Cancel := True;
     end;
  end else if (DataCol = colEligible) then begin
     Eligible := tgFuel.Cell[colLitres, DataRow];
     if Eligible = '' then
       Eligible := '0';
     if (tgFuel.Cell[DataCol, DataRow] <> '') and (tgFuel.Cell[DataCol, DataRow] > StrToFloat(Eligible)) then
     begin
       HelpfulErrorMsg('"Total Business Use of Eligible Fuel" cannot be greater than "Total Fuel Acquisitions"', 0);
       Cancel := True;
     end;
  end
end;

procedure TfrmBAS.tgFuelEnter(Sender: TObject);
begin
  BKHelpSetUp( Self, BKH_How_BankLink_populates_the_Fuel_Tax_Worksheet);
end;

procedure TfrmBAS.tgFuelExit(Sender: TObject);
begin
  BKHelpSetUp( Self, BKH_How_BankLink_populates_the_GST_Calculation_Sheet);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmBAS.CalculateQtyTotals(D1, D2 : LongInt; ChartCode: string; var AccountOK: Boolean): Extended;
var
   T, B            : LongInt;
   Dissection      : pDissection_Rec;
   AccountTypeOK   : boolean;
   pT: pTransaction_Rec;
begin
  Result := 0;
  AccountOK := False;
  for B := 0 to Pred( MyClient.clBank_Account_List.ItemCount ) do
    with MyClient.clBank_Account_List.Bank_Account_At(B) do
    begin
      AccountTypeOK := (baFields.baAccount_Type in [btBank,btCashJournals,btGSTJournals]) or
                      ((baFields.baAccount_Type = btAccrualJournals) and (not MyClient.clFields.clGST_Excludes_Accruals));
      if AccountTypeOK then
      begin
        for T := 0 to Pred(baTransaction_List.ItemCount) do
        begin
          pT := baTransaction_List.Transaction_At(T);
          if ((MyClient.clFields.clGST_on_Presentation_Date ) and (pT.txDate_Presented >=D1) and (pT.txDate_Presented <=D2))
              or ((not MyClient.clFields.clGST_on_Presentation_Date ) and (pT.txDate_Effective >=D1) and ( pT.txDate_Effective <=D2)) then
          begin
            if (pT.txFirst_Dissection = nil) then
            begin
              if pT.txAccount = ChartCode then
              begin
                Result := Result + Round(Percent2Double(pT.txQuantity));
                AccountOK := True;
              end;
            end
            else
            begin
              Dissection := pT.txFirst_Dissection;
              while (Dissection <> nil) do
                with Dissection^ do
                begin
                  if dsAccount = ChartCode then
                  begin
                    Result := Result + Round(Percent2Double(dsQuantity));
                    AccountOK := True;
                  end;
                  Dissection := dsNext;
                end;
            end;//else
          end;//if
        end;//for
      end;//if
    end;//with
end;

function TfrmBAS.Execute(d1 : integer; d2: integer; SpecialFormType : integer): boolean;
//the special form type variable can be used to set this form as being an
//Annual GST Return or an Annual GST information sheet.
//Setting to -1 forces form type to be dynamically set
var
   GroupVisible : boolean;
   j: Integer;
   s: TStringList;
begin
   result := false;
   //calculate bas value for period
   BasInfo.SpecialFormType := SpecialFormType;
   BasInfo.PopulateBAS( d1,d2,tgFuel);
   //updateTotalFuelCount will also overwrite the current value in
   //iFuelCredit_7D if a rule is used or if values exist in the fuel grid
   UpdateTotalFuelCount;
   if (MyClient.clFields.clTax_Interface_Used = tsNone) then
   begin
     //no export format specified so just allow to finalise
     btnExport.Caption := 'Fina&lise';
   end;
   btnExport.Visible := Assigned(AdminSystem) or INI_BooksExtact;
   Self.Caption       := 'Activity Statement';

   //load relevant combos
   //G24
   with basG24_GSTOption3.Items do begin
      Text := '';
      AddObject( '', TObject( 0));
      AddObject( '22 Current business structure not continuing', TOBject( 22));
      AddObject( '23 Significant change in trading conditions', TOBject( 23));
      AddObject( '24 Internal business restructure', TOBject( 24));
      AddObject( '25 Change in legislation or product mix', TOBject( 25));
      AddObject( '26 Financial market changes', TObject( 26));
   end;

   //T4 option 1
   with cmbT4_PAYGOption1.Items do begin
      Text := '';
      AddObject( '', TObject( 0));
      AddObject( '21 Change in investments', Tobject( 21));
      AddObject( '22 Current business structure not continuing', TOBject( 22));
      AddObject( '23 Significant change in trading conditions', TOBject( 23));
      AddObject( '24 Internal business restructure', TOBject( 24));
      AddObject( '25 Change in legislation or product mix', TOBject( 25));
      AddObject( '26 Financial market changes', TObject( 26));
      AddObject( '27 Use of income tax losses', Tobject( 27));
      AddObject( '28 Intends to enter the STS', Tobject( 28));
      AddObject( '29 Intends to leave the STS', Tobject( 29));
      AddObject( '33 Variation due to entering or exiting a consolidated group', Tobject( 33));
   end;

   //T4 option 2
   with cbfP6T4.Items do begin
      if BasInfo.BasFormType = bs2000 then begin
         Text := '';
         AddObject( '', TObject( 0));
         AddObject( '01  Mergers, Acquisitions and takeovers', TObject( 1));
         AddObject( '02  Cessation of business activity', TObject( 2));
         AddObject( '03  Expected utilisation of losses of a revenue or capital nature', TObject( 3));
         AddObject( '04  Significant (abnormal) transactions affecting income or expenses', TObject( 4));
         AddObject( '05  Change in trading conditions affecting income or expenses', TObject( 5));
         AddObject( '06  Domestic or foreign financial market changes', TObject( 6));
         AddObject( '07  Change in investment strategies or policies', TObject( 7));
         AddObject( '08  Change in product mix', TObject( 8));
         AddObject( '09  Business expansion or contraction', TObject( 9));
         AddObject( '10  Change in entity structure', TObject( 10));
         AddObject( '11  Internal or external restructing of business activity', TObject( 11));
         AddObject( '13  Change in profit margin', TObject( 13));
      end
      else begin
         Text := '';
         AddObject( '', TObject( 0));
         AddObject( '21 Change in investments', Tobject( 21));
         AddObject( '22 Current business structure not continuing', TOBject( 22));
         AddObject( '23 Significant change in trading conditions', TOBject( 23));
         AddObject( '24 Internal business restructure', TOBject( 24));
         AddObject( '25 Change in legislation or product mix', TOBject( 25));
         AddObject( '26 Financial market changes', TObject( 26));
         AddObject( '27 Use of income tax losses', Tobject( 27));
         AddObject( '28 Intends to enter the STS', Tobject( 28));
         AddObject( '29 Intends to leave the STS', Tobject( 29));
         AddObject( '33 Variation due to entering or exiting a consolidated group', Tobject( 33));
         AddObject( '75 High rate', TObject( 75));
      end;
   end;

   //T4 option 3
   with cmbT4_PAYGOption3.Items do begin
      Text := '';
      AddObject( '', TObject( 0));
      AddObject( '21 Change in investments', Tobject( 21));
      AddObject( '22 Current business structure not continuing', TOBject( 22));
      AddObject( '23 Significant change in trading conditions', TOBject( 23));
      AddObject( '24 Internal business restructure', TOBject( 24));
      AddObject( '25 Change in legislation or product mix', TOBject( 25));
      AddObject( '26 Financial market changes', TObject( 26));
      AddObject( '27 Use of income tax losses', Tobject( 27));
   end;

   //F4
   with cbfP7F4.Items do begin
      if BasInfo.BasFormType = bs2000 then begin
         Text := '';
         AddObject( '', TObject( 0));
         AddObject( '01  Benefits ceased/reduced and salary increased', TObject( 1));
         AddObject( '02  Benefits ceased/reduced and no compensation to employees', TObject( 2));
         AddObject( '03  Fewer employees', TObject( 3));
         AddObject( '04  Increase in employee contribution', TObject( 4));
         AddObject( '05  Section 65J rebate now claimed', TObject( 5));
         AddObject( '06  Liquidation, receiver/manager appointed', TObject( 6));
         AddObject( '07  None of the above', TObject( 7));
      end
      else begin
         Text := '';
         AddObject( '', TObject( 0));
         AddObject( '22 Current business structure not continuing', TOBject( 22));
         AddObject( '30 Change in fringe benefit for employees', TObject( 30));
         AddObject( '31 Change in employees with fringe benefits', TObject( 31));
         AddObject( '32 Fringe benefits rebate now claimed', TObject( 32));
      end;
   end;

   //set user editable fields
   SetEditableFields;

   //set visibility
   //GST Tab
   GroupVisible                := FieldVisible( bfG1, BasInfo.BasFormType) or
                                  FieldVisible( bfG2, BasInfo.BasFormType) or
                                  FieldVisible( bfG3, BasInfo.BasFormType) or
                                  FieldVisible( bfG10, BasInfo.BasFormType) or
                                  FieldVisible( bfG11, BasInfo.BasFormType);

   basG1_GSTOption1.Visible    := FieldVisible( bfG1, BasInfo.BasFormType);
   lblDoes_Opt1.Visible        := basG1_GSTOption1.Visible;
   rbYes_GSTOption1.Visible    := basG1_GSTOption1.Visible;
   rbNo_GSTOption1.Visible     := basG1_GSTOption1.Visible;
   lblGoto_Opt1.Visible        := basG1_GSTOption1.Visible;

   pnlGSTOption1.Visible       := GroupVisible;

   rbGSTOption1.Visible        := FieldVisible( bfGSTOption1, BasInfo.BasFormType);

   rbGSTOption2.Visible        := FieldVisible( bfGSTOption2, BasInfo.BasFormType);
   pnlGSTOption2.Visible       := rbGSTOption2.Visible;

   GroupVisible                := FieldVisible( bfGSTOption3, BasInfo.BasFormType) or
                                  FieldVisible( bfG21, BasInfo.BasFormType, BasInfo.iG21_ATOInstalment) or
                                  FieldVisible( bfG22, BasInfo.BasFormType, BasInfo.iG22_EstimatedNetGST) or
                                  FieldVisible( bfG23, BasInfo.BasFormType, BasInfo.iG23_VariedAmount);

   rbGSTOption3.Visible        := GroupVisible;
   pnlGSTOption3.Visible       := rbGSTOption3.Visible;

   //see if we were expecting option 3
   if GroupVisible and ( not FieldVisible( bfGSTOption3, BasInfo.BasFormType)) then begin
      //would not normally see option 3, so display opt 1 and 2 to allow user to change
      basG1_GSTOption1.Visible := true;
      rbGSTOption1.Visible     := true;
      pnlGSTOption1.Visible    := true;

      rbGSTOption2.Visible     := true;
      pnlGSTOption2.Visible    := true;
   end;

   //see if should show tab
   tabGST.TabVisible           := ( pnlGSTOption1.Visible or pnlGSTOption2.Visible or pnlGSTOption3.Visible);

   //PAYG Withholding Tab
   GroupVisible                := FieldVisible( bfW1, BasInfo.BasFormType, BasInfo.iTotalSalary_W1) or
                                  FieldVisible( bfW2, BasInfo.BasFormType, BasInfo.iSalaryWithheld_W2) or
                                  FieldVisible( bfW3, BasInfo.BasFormType, BasInfo.iInvstmntDist_W3) or
                                  FieldVisible( bfW4, BasInfo.BasFormType, BasInfo.iInvoicePymt_W4);

   tabPAYGWitholding.TabVisible := GroupVisible;

   //PAYG Instalment
   GroupVisible                := FieldVisible( bfPAYGOption1, BasInfo.BasFormType) or
                                  FieldVisible( bfT7, BasInfo.BasFormType, BasInfo.iT7_ATOInstalment) or
                                  FieldVisible( bfT8, BasInfo.BasFormType, BasInfo.iT8_EstimatedTax) or
                                  FieldVisible( bfT9, BasInfo.BasFormType, BasInfo.iT9_VariedAmount);
   pnlPAYGInstalmentOpt1.Visible := GroupVisible;
   rbPAYGI_Option1.Visible     := GroupVisible;

   GroupVisible                := FieldVisible( bfPAYGOption2, BasInfo.BasFormType) or
                                  FieldVisible( bfT1, BasInfo.BasFormType, BasInfo.iTaxInstalmIncome_T1) or
                                  FieldVisible( bfT11, BasInfo.BasFormType, BasInfo.iT11_T1x_T2orT3);
   pnlPAYGInstalmentOpt2.Visible := GroupVisible;
   rbPAYGI_Option2.Visible     := GroupVisible;

   GroupVisible                := (FieldVisible( bfPAYGOption3, BasInfo.BasFormType) or
                                  FieldVisible( bfT6, BasInfo.BasFormType, BasInfo.iT7_ATOInstalment))
                                 and (BasInfo.BasFormType = bsIASN);
   pnlPAYGInstalmentOpt3.Visible := GroupVisible;
   rbPAYGI_Option3.Visible     := GroupVisible;
   BAST5.Visible   := GroupVisible;

   if ( pnlPAYGInstalmentOpt2.Visible) and (( not pnlPAYGInstalmentOpt1.Visible) and ( not pnlPAYGInstalmentOpt3.Visible)) then begin
      pnlPAYGInstalmentOpt2.Top := pnlPAYGInstalmentOpt1.Top;
      rbPAYGI_Option2.Visible   := false;
   end;
   if (pnlPAYGInstalmentOpt3.Visible) and (pnlPAYGInstalmentOpt2.Visible) then
   begin
     pnlPAYGInstalmentOpt3.Top := pnlPAYGInstalmentOpt1.Top + BAST5.Height + 10;
     pnlPAYGInstalmentOpt2.Top := pnlPAYGInstalmentOpt3.Top + pnlPAYGInstalmentOpt3.Height + 10;
     rbPAYGI_Option3.Top := pnlPAYGInstalmentOpt3.Top + 8;
     rbPAYGI_Option2.Top := pnlPAYGInstalmentOpt2.Top + 8;
     bxfP6T3.Visible := FieldVisible( bfT3, BasInfo.BasFormType, BasInfo.dTaxVarInstalmRate_T3);
     txfP6T3a.Visible := FieldVisible( bfT3, BasInfo.BasFormType, BasInfo.dTaxVarInstalmRate_T3);
     txfP6T3b.Visible := FieldVisible( bfT3, BasInfo.BasFormType, BasInfo.dTaxVarInstalmRate_T3);
     txfP6T3.Visible := FieldVisible( bfT3, BasInfo.BasFormType, BasInfo.dTaxVarInstalmRate_T3);
     cbfP6T4.Visible := FieldVisible( bfT4, BasInfo.BasFormType);
     txfP6T4b.Visible := FieldVisible( bfT4, BasInfo.BasFormType);
     txfP6T4a.Visible := FieldVisible( bfT4, BasInfo.BasFormType);
   end;

   tabPAYGInstalment.TabVisible := ( pnlPAYGInstalmentOpt2.Visible) or
                                   ( pnlPAYGInstalmentOpt1.Visible) or
                                   ( pnlPAYGInstalmentOpt3.Visible);

   //FBT instalment
   GroupVisible                := FieldVisible( bfF1, BasInfo.BasFormType, BasInfo.iFBTInstalm_F1) or
                                  FieldVisible( bfF2, BasInfo.BasFormType, BasInfo.iFBTTotalPayable_F2) or
                                  FieldVisible( bfF3, BasInfo.BasFormType, BasInfo.iFBTVariedInstalm_F3);
   tabFBT.TabVisible           := GroupVisible;

   //summary tab
   bxfP21a.Visible             := FieldVisible( bf1a, BasInfo.BasFormType, BasInfo.iGSTPayable_1A);
   bxfP21b.Visible             := FieldVisible( bf1b, BasInfo.BasFormType, BasInfo.iGSTCredit_1B);
   bxfP21c.Visible             := FieldVisible( bf1c, BasInfo.BasFormType, BasInfo.iWineEqlPayable_1C);
   bxfP21d.Visible             := FieldVisible( bf1d, BasInfo.BasFormType, BasInfo.iWineEqlRefund_1D);
   bxfP21e.Visible             := FieldVisible( bf1e, BasInfo.BasFormType, BasInfo.iLuxCarPayable_1E);
   bxfP21f.Visible             := FieldVisible( bf1f, BasInfo.BasFormType, BasInfo.iLuxCarRefund_1F);
   bxfP21g.Visible             := FieldVisible( bf1g, BasInfo.BasFormType, BasInfo.iSalesTaxCredit_1G);
   bas1H_Summary.Visible       := FieldVisible( bf1h, BasInfo.BasFormType, BasInfo.i1H_GSTInstalment);

   bxfP22a.Visible             := FieldVisible( bf2a, BasInfo.BasFormType);
   Shape3.Visible              := bxfP22a.Visible;
   bxfP22b.Visible             := FieldVisible( bf2b, BasInfo.BasFormType);
   Shape2.Visible              := bxfP22b.Visible;

   bxfP24.Visible              := FieldVisible( bf4, BasInfo.basFormType, BasInfo.iTotalWithheld_4);
   bxfP25a.Visible             := FieldVisible( bf5a, BasInfo.BasFormType, BasInfo.iIncomeTaxInstalm_5A);
   bxfP25b.Visible             := FieldVisible( bf5b, BasInfo.BasFormType, BasInfo.iCrAdjPrevIncome_5B);
   bxfP26A.Visible             := FieldVisible( bf6a, BasInfo.BasFormType, BasInfo.iFBTInstalm_6A);
   bxfP26b.Visible             := FieldVisible( bf6b, BasInfo.BasFormType, BasInfo.iVariationCr_6B);
   bxfp27.Visible              := FieldVisible( bf7, BasInfo.BasFormType, BasInfo.iDeferredInstalm_7);
   bxfp7c.Visible              := FieldVisible( bf7c, BasInfo.BasFormType);
   bxfp7d.Visible              := FieldVisible( bf7d, BasInfo.BasFormType);

   bxfp28a.visible             := FieldVisible( bf8a, BasInfo.BasFormType);
   line8A.Visible              := FieldVisible( bf8a, BasInfo.BasFormType);

   bxfp28b.visible             := FieldVisible( bf8b, BasInfo.BasFormType);
   line8B.Visible              := FieldVisible( bf8b, BasInfo.BasFormType);

   bxfp29.Visible              := FieldVisible( bf9, BasInfo.BasFormType);
   bas9_Details.Visible        := FieldVisible( bf9, BasInfo.BasFormType);
   lbl9_Details.Visible        := bas9_Details.Visible;
   label19.Visible             := bas9_Details.Visible;
   label4.Visible              := bas9_Details.Visible;
   lbl9_Summary.Visible        := bas9_Details.Visible;

   with BasInfo do begin
      GroupVisible := FieldVisible( bf1a, BasFormType, iGSTPayable_1A) or
                      FieldVisible( bf1b, BasFormType, iGSTCredit_1B) or
                      FieldVisible( bf1c, BasFormType, iWineEqlPayable_1C) or
                      FieldVisible( bf1d, BasFormType, iWineEqlRefund_1D) or
                      FieldVisible( bf1e, BasFormType, iLuxCarPayable_1E) or
                      FieldVisible( bf1f, BasFormType, iLuxCarRefund_1F) or
                      FieldVisible( bf1g, BasFormType, iSalesTaxCredit_1G) or
                      FieldVisible( bf1h, BasFormType, i1H_GSTInstalment) or
                      FieldVisible( bf2a, BasFormType) or
                      FieldVisible( bf2b, BasFormType) or
                      FieldVisible( bf4,  basFormType, iTotalWithheld_4) or
                      FieldVisible( bf5a, BasFormType, iIncomeTaxInstalm_5A) or
                      FieldVisible( bf5b, BasFormType, iCrAdjPrevIncome_5B) or
                      FieldVisible( bf6a, BasFormType, iFBTInstalm_6A) or
                      FieldVisible( bf6b, BasFormType, iVariationCr_6B) or
                      FieldVisible( bf7,  BasFormType, iDeferredInstalm_7) or
                      FieldVisible( bf7c, BasFormType) or
                      FieldVisible( bf7d, BasFormType) or
                      FieldVisible( bf8a, BasFormType) or
                      FieldVisible( bf8b, BasFormType) or
                      FieldVisible( bf9,  BasFormType, iNetTaxObligation_9);
   end;
   tabSummary.TabVisible := GroupVisible;

   tabCalculationSheet.TabVisible := BasUtils.IsBASForm( BasInfo.BasFormType) or
                                    ( BasInfo.BasFormType in [ bsH, bsBasZ, bsK]);

   if FieldVisible( bf7d, BasInfo.BasFormType) then
   begin
     tabFuelSheet.TabVisible := True;
     // fill pre-used combo values for credit rate
     s := TStringList.Create;
     try
       s.Sorted := true;
       s.CommaText := PRACINI_FuelCreditRates;
       tgFuel.Col[colRate].Combo.Grid.Rows := s.Count;
       tgFuel.Col[colRate].Combo.Grid.StoreData := True;
       for j := 0 to Pred(s.Count) do
         tgFuel.Col[colRate].Combo.Grid.Cell[1, j+1] := s[j];
     finally
       s.Free;
     end;
     //if the grid is currently empty call rebuildFuelGrid to load the grid
     //based on the BAS rule for 7D
     if (tgFuel.Cell[colCode, 1] = '') and (tgFuel.Cell[colTotal, 1] = '') then // nothing saved
       ReBuildFuelGrid;
     //update fuel total after rebuilding grid
     UpdateTotalFuelCount;
     rbPercent.Checked := BasInfo.iIsFuelPercentMethod;
     rbFuelClick(Self);
   end
   else
    tabFuelSheet.TabVisible := False;

   //call click routines to set enabled
   rbGSTOption1Click( nil);
   rbPAYGI_Option1Click( nil);
   //call display routine
   ReDisplay;
   //Set active tab to first one
   pgBasFrm.ActivePageIndex := 0;
   if Assigned(RptParams)
   and (RptParams.BatchRunMode = R_Batch) then begin
     btnPrintClick(nil);
   end else begin


     //***************
     Self.ShowModal;
     //***************
  end;
end;
//------------------------------------------------------------------------------
procedure ShowBASForm (Fromdate: Integer = 0; Todate: Integer = 0;
                       Params: TrptParameters = nil);

   function OKtoProceed : boolean;
   begin
      with MyClient, MyClient.clFields do begin
         case clCountry of
            whNewZealand : result := not((clGST_Period = gpNone)
                                          or (clGST_Start_Month = 0));

            whAustralia  : result := (( clGST_Period <> gpNone) or
                                      ( clBAS_PAYG_Withheld_Period <> gpNone) or
                                      ( clBAS_PAYG_Instalment_Period <> gpNone)) and
                                      ( clGST_Start_Month <> 0);
         else
            result := false;
         end;
      end;
   end;

var
  myFrm : TfrmBAS;
  dFrom, dTo : integer;
  S          : string;
  NoRepeat : Boolean;
begin
   if not HasEntries then exit;
   NoRepeat := (Fromdate <> 0) and (Todate <> 0);
   myFrm := TfrmBAS.Create(nil);  //dont use application here as xp themes
                                  //total trashes the form
   try repeat
      BKHelpSetUp( myFrm, BKH_How_BankLink_populates_the_GST_Calculation_Sheet);

      //check we have all of the required values
      with MyClient, MyClient.clFields, myFrm do begin
         if not OKtoProceed then begin
            case clCountry of
               whNewZealand : S := 'Before you can do this you must setup the GST Period and Start Month.';
               whAustralia  : S := 'Before you can do this you must setup the GST Period, PAYG Withholding Period and Start Month.';
            end;
            HelpfulInfoMsg( S,0);
            EditGSTDetails(BKH_Set_up_GST);
            {if still not set then exit}
            if not OKtoProceed then exit;
         end;

         //select GST Period to work with
         if (Fromdate = 0)
         or (Todate = 0) then begin
            if not SelectBASPeriod(dFrom, dTo, Params) then
               exit;
         end else begin
            dFrom := FromDate;
            dTo := ToDate;
         end;

         if Assigned(Params) then begin
          if Params.BatchSave then begin
             Params.SaveNodeSettings;
             Exit;
          end;
          if Params.BatchRunMode = R_batch then
             NoRepeat := True;
         end;
         MyFrm.rptParams := Params;
      end;
      MyFrm.Execute(dFrom, dTo, -1);
   until NoRepeat;
   finally
      MyFrm.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBAS.btnOKClick(Sender: TObject);
begin
   //see OnCloseQuery code!
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBAS.FormDestroy(Sender: TObject);
begin
   //free memory of bas info object
   BasInfo.Free;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBAS.ReDisplay;
//Load any editable fields back into the basInfo object, recalc values, and display
//
//Editable fields should NOT be updated as this would overwrite their value
//they will instead be set when loading the form thru SetEditableFields()
var
   d1,d2,m1,m2,y1,y2 : integer;
begin
   //get value of any editable fields
   ReadEditableFields;
   //recalculate totals
   BasInfo.Recalculate;
   //update fields ( note cannot update editable fields because that would set their
   //value again which means no new input can take place).
   //Lock the update of this window so that we don't get flicker
   LockWindowUpdate(Self.Handle);
   try
      with BasInfo do begin
         if BasUtils.IsBASForm( BasInfo.BasFormType) then
            lblFormTitle.Caption := 'Business Activity Statement'
         else
            lblFormTitle.Caption := 'Instalment Activity Statement';

         if BasInfo.BasFormType in [bsH, bsBasZ] then
            lblFormTitle.caption := 'Annual GST return';

         if BasInfo.BasFormType = bsK then
            lblFormTitle.caption := 'Annual GST information report';

         lblFormType.caption := bsNames[ BasInfo.basformType];

         Self.caption := lblFormTitle.Caption;

         //header fields
         with MyClient.clFields do begin
            lblName.Caption             := clName;
            lblAddr1.Caption            := clAddress_L1;
            lblAddr2.Caption            := clAddress_L2;
            lblAddr3.Caption            := clAddress_L3;
            lblEmail.Caption            := clClient_EMail_Address;

            if clGST_Basis in [ gbMin..gbMax] then
               txfP4Method.Caption := gbaNames[ clGST_Basis]
            else
               txfP4Method.Caption := '';
         end;

         ffdP1A2a.Caption               := ABN;
         ffdP1A2b.Caption               := ABN_Extra;

         StDateToDMY( BasFromDate, d1, m1, y1);
         StDatetoDMY( BasToDate, d2, m2, y2);

         if ( y1 = y2) then begin
            //same year
            lblPeriod.caption := moNames[ m1] + ' to ' + moNames[ m2] + ' ' + inttostr( y2);
         end
         else begin
            lblPeriod.caption := moNames[ m1] + ' ' + inttostr( y1) + ' to ' +
                         moNames[ m2] + ' ' + inttostr( y2);
         end;

//         ffdP1A3.Caption                := bkDate2Str( BasFromDate);
//         ffdP1A4.Caption                := bkDate2Str( BasToDate);

         ffdP1A5.Caption                := bkDate2Str( DueDate);
         ffdP1A6.Caption                := bkDate2Str( PaymentDate);

         //calculation sheet fields
         //always show all fields on calculation sheet
         bxfP4G1.AsInteger              := iIncome_G1;
         bxfP4G2.AsInteger              := iExports_G2;
         bxfP4G3.AsInteger              := iGSTFreeSupplies_G3;
         bxfP4G4.AsInteger              := iInputTaxedSales_G4;
         bxfP4G5.AsInteger              := iTotalGSTFree_G5;
         bxfP4G6.AsInteger              := iTotalTaxableSupp_G6;

         if BAS_Rule_Setup[ bfG7 ] then bxfP4G7.AsInteger    := iIncAdjustments_G7;

         bxfP4G8.AsInteger              := iTotalTaxSuppAdj_G8;
         bxfP4G9.Asinteger              := iGSTPayable_G9;

         bxfP4G10.AsInteger             := iCapitalAcq_G10;
         bxfP4G11.AsInteger             := iOtherAcq_G11;
         bxfP4G12.AsInteger             := iTotalAcq_G12;
         bxfP4G13.AsInteger             := iAcqInputTaxedSales_G13;
         bxfP4G14.AsInteger             := iAcqNoGST_G14;
         bxfP4G15.AsInteger             := iEstPrivateUse_G15;
         bxfP4G16.AsInteger             := iTotalNonCreditAcq_G16;
         bxfP4G17.AsInteger             := iTotalCreditAcq_G17;

         if BAS_Rule_Setup[ bfG18 ] then bxfP4G18.AsInteger   := iAcqAdjustments_G18;

         bxfP4G19.AsInteger             := iTotalCreditAcqAdj_G19;
         bxfP4G20.AsInteger             := iGSTCredit_G20;

         //GST Dates
         if not IsAnnualStatement then
            stGSTDates.caption := BasUtils.DatesCaption( GSTFromDate, GSTToDate)
         else
            stGSTDates.caption := lblPeriod.caption;

         if iGSTOptionUsed = 1 then begin
            basG1_GSTOption1.AsInteger := iIncome_G1;

            basG2_GSTOption1.AsInteger      := iExports_G2;
            basG3_GSTOption3.AsInteger      := iGSTFreeSupplies_G3;
            basG10_GSTOption1.AsInteger     := iCapitalAcq_G10;
            BasG11_GSTOption1.AsInteger     := iOtherAcq_G11;
         end
         else begin
            basG1_GSTOption1.AsInteger      := 0;
            basG2_GSTOption1.AsInteger      := 0;
            basG3_GSTOption3.AsInteger      := 0;
            basG10_GSTOption1.AsInteger     := 0;
            BasG11_GSTOption1.AsInteger     := 0;
         end;

         if iGSTOptionUsed = 2 then begin
            basG1_GSTOption2.AsInteger      := iIncome_G1;
         end
         else begin
            basG1_GSTOption2.AsInteger      := 0;
         end;

         bxfP6T1.AsInteger := 0;
         if iPAYGInstalmentOptionUsed = 2 then
           bxfP6T1.AsInteger := basinfo.iTaxInstalmIncome_T1;

         bas1A_GSTOption3.AsInteger         := iGSTPayable_1A;

         //Amounts Withheld
         stPAYGWDates.caption := BasUtils.DatesCaption( PAYG_W_FromDate, PAYG_W_ToDate);

         if BAS_Rule_Setup[ bfW1 ] then bxfP5W1.AsInteger  := iTotalSalary_W1;
         if BAS_Rule_Setup[ bfW2 ] then bxfP5W2.AsInteger  := iSalaryWithheld_W2;
         if BAS_Rule_Setup[ bfW3 ] then bxfP5W3.AsInteger  := iInvstmntDist_W3;
         if BAS_Rule_Setup[ bfW4 ] then bxfP5W4.AsInteger  := iInvoicePymt_W4;

         basW5_Total.AsInteger := iW5_TotalAmountsWithheld;

         //PAYG Instalment
         stPAYGIDates.caption := BasUtils.DatesCaption( PAYG_I_FromDate, PAYG_I_ToDate);

         basT11_Calc.AsInteger  := iT11_T1x_T2orT3;

         //All FBT fields are updated in SetEditableFields

         //Fbt
         stFBTDates.caption   := BasUtils.DatesCaption( FBT_FromDate, FBT_ToDate);

         //All FBT fields are updated in SetEditableFields


         //bas fields
         bxfP21A.AsInteger              := iGSTPayable_1A;

         if BAS_Rule_Setup[ bf1C ] then bxfP21C.AsInteger              := iWineEqlPayable_1C;
         if BAS_Rule_Setup[ bf1E ] then bxfP21E.AsInteger              := iLuxCarPayable_1E;

         bxfP22A.AsInteger              := iTotalDebit_2A;
         bxfP21B.AsInteger              := iGSTCredit_1B;

         if BAS_Rule_Setup[ bf1D ] then bxfP21D.AsInteger              := iWineEqlRefund_1D;
         if BAS_Rule_Setup[ bf1F ] then bxfP21F.AsInteger              := iLuxCarRefund_1F;
         if BAS_Rule_Setup[ bf1G ] then bxfP21G.AsInteger              := iSalesTaxCredit_1G;

         bxfP22B.AsInteger              := iTotalCredit_2B;

         bxfP24.AsInteger               := iTotalWithheld_4;
         bxfP25A.AsInteger              := iIncomeTaxInstalm_5A;
         bxfP26A.AsInteger              := iFBTInstalm_6A;

         if BAS_Rule_Setup[ bf7  ] then bxfP27.AsInteger               := iDeferredInstalm_7;
         if BAS_Rule_Setup[ bf7c ] then bxfP7c.AsInteger               := iFuelOverClaim_7C;

         if BAS_Rule_Setup[ bft5 ] then basT5.AsInteger                := iBAST5;

         bxfP28A.AsInteger              := BasInfo.iTaxPayableTotal_8A;

         if BAS_Rule_Setup[ bf5B ] then bxfP25B.AsInteger              := iCrAdjPrevIncome_5B;
         if BAS_Rule_Setup[ bf6B ] then bxfP26B.AsInteger              := iVariationCr_6B;

         bxfP28B.AsInteger              := BasInfo.iTaxCreditTotal_8B;

         if iTaxCreditTotal_8B > iTaxPayableTotal_8A then begin
            bxfP29.Caption := 'This amount is refundable to you';
            lbl9_Summary.caption := 'REFUND';
         end
         else begin
            bxfP29.Caption := 'This amount is payable to the ATO';
            lbl9_Summary.caption := 'PAYMENT';
         end;

         bxfP29.AsInteger               := iNetTaxObligation_9;

         bas9_Details.AsInteger         := iNetTaxObligation_9;
         bas9_Details.caption           := bxfP29.Caption;
         lbl9_Details.caption           := lbl9_Summary.Caption;

         //calc sheet
         if not IsAnnualStatement then
            stGSTCalcDates.caption := BasUtils.DatesCaption( GSTFromDate, GSTToDate)
         else
            stGSTCalcDates.caption := lblPeriod.caption;

         //fuel tax worksheet
         if not IsAnnualStatement then
           stFuelDates.caption := BasUtils.DatesCaption( GSTFromDate, GSTToDate)
         else
           stFuelDates.caption := lblPeriod.caption;
      end;
   finally
      LockWindowUpdate(0);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBAS.ClearUnselectedFields;
//this clears the values for for options that have not been selected
//otherwise all values will appear on the printouts
begin
   if BasInfo.iGSTOptionUsed <> 3 then begin
      BasInfo.iG21_ATOInstalment   := 0;
      BasInfo.iG22_EstimatedNetGST := 0;
      BasInfo.iG23_VariedAmount    := 0;
      BasInfo.iG24_ReasonVar       := 0;
   end;

   if BasInfo.iPAYGInstalmentOptionUsed <> 1 then begin
      BasInfo.iT7_ATOInstalment    := 0;
      BasInfo.iT8_EstimatedTax     := 0;
      BasInfo.iT9_VariedAmount     := 0;
   end;

   if BasInfo.iPAYGInstalmentOptionUsed <> 2 then begin
      BasInfo.iTaxInstalmIncome_T1 := 0;
      BasInfo.dTaxInstalmRate_T2   := 0.0;
      BasInfo.dTaxVarInstalmRate_T3:= 0.0;
   end;

   if BasInfo.iPAYGInstalmentOptionUsed <> 3 then
      BasInfo.iT6_VariedAmount := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBAS.ReadEditableFields;
//Store the values of any editable fields back in the basInfo object
begin
   with BasInfo do begin
      DocumentID                := bxfP1A1.text;

      //calculation sheet
      if not BAS_Rule_Setup[ bfG7 ] then iIncAdjustments_G7        := bxfP4G7.AsInteger;
      if not BAS_Rule_Setup[ bfG18] then iAcqAdjustments_G18       := bxfP4G18.AsInteger;

      //gst
      iGSTOptionUsed := 0;

      if rbGSTOption2.Checked then
         iGSTOptionUsed := 2;
      if rbGSTOption3.Checked then
         iGSTOptionUsed := 3;
      if rbGSTOption1.Checked then
         iGSTOptionUsed := 1;

      if iGSTOptionUsed = 2 then
         bG1IncludesGST := rbYes_GSTOption2.Checked
      else
         bG1IncludesGST := rbYes_GSTOption1.Checked;

      iG21_ATOInstalment        := basG21_GSTOption3.AsInteger;
      iG22_EstimatedNetGST      := basG22_GSTOption3.AsInteger;
      iG23_VariedAmount         := basG23_GSTOption3.AsInteger;

      iG24_ReasonVar            := 0;
      if basG24_GSTOption3.ItemIndex > 0 then
         iG24_ReasonVar         := Integer( basG24_GSTOption3.Items.Objects[ basG24_GSTOption3.ItemIndex]);

      //payg w
      if not BAS_Rule_Setup[ bfW1 ] then iTotalSalary_W1           := bxfP5W1.AsInteger;
      if not BAS_Rule_Setup[ bfW2 ] then iSalaryWithheld_W2        := bxfP5W2.AsInteger;
      if not BAS_Rule_Setup[ bfW3 ] then iInvstmntDist_W3          := bxfP5W3.AsInteger;
      if not BAS_Rule_Setup[ bfW4 ] then iInvoicePymt_W4           := bxfP5W4.AsInteger;

      //payg instalment
      if rbPAYGI_Option3.Checked then
         iPAYGInstalmentOptionUsed := 3;
      if rbPAYGI_Option2.Checked then
         iPAYGInstalmentOptionUsed := 2;
      if rbPAYGI_Option1.Checked then
         iPAYGInstalmentOptionUsed := 1;

      if not BAS_Rule_Setup[ bfT1 ] then iTaxInstalmIncome_T1      := bxfP6T1.AsInteger;

      dTaxInstalmRate_T2        := bxfP6T2.NumericEdit.AsFloat;
      dTaxVarInstalmRate_T3     := bxfP6T3.NumericEdit.AsFloat;

      iT7_ATOInstalment         := basT7_PAYGOption1.AsInteger;
      iT8_EstimatedTax          := basT8_PAYGOption1.AsInteger;
      iT9_VariedAmount          := basT9_PAYGOption1.AsInteger;
      iT6_VariedAmount          := basT6_PAYGOption3.AsInteger;

      iTaxReasonVar_T4 := 0;
      if iPAYGInstalmentOptionUsed = 1 then begin
         if cmbT4_PAYGOption1.ItemIndex > 0 then
            iTaxReasonVar_T4    := Integer( cmbT4_PAYGOption1.Items.Objects[ cmbT4_PAYGOption1.ItemIndex]);
      end
      else if iPAYGInstalmentOptionUsed = 3 then begin
         if cmbT4_PAYGOption3.ItemIndex > 0 then
            iTaxReasonVar_T4    := Integer( cmbT4_PAYGOption3.Items.Objects[ cmbT4_PAYGOption3.ItemIndex]);
      end
      else begin
         if cbfP6T4.ItemIndex > 0 then
            iTaxReasonVar_T4    := Integer( cbfP6T4.Items.Objects[ cbfP6T4.ItemIndex]);
      end;

      //fbt
      iFBTInstalm_F1            := bxfP7F1.AsInteger;
      iFBTTotalPayable_F2       := bxfP7F2.AsInteger;
      iFBTVariedInstalm_F3      := bxfP7F3.AsInteger;
      iFBTReasonVar_F4 := 0;
      if cbfP7F4.ItemIndex > 0 then
         iFBTReasonVar_F4       := Integer( cbfP7F4.Items.Objects[ cbfP7F4.ItemIndex]);

      //summary
      if not BAS_Rule_Setup[ bf1C ] then iWineEqlPayable_1C        := bxfP21C.AsInteger;
      if not BAS_Rule_Setup[ bf1E ] then iLuxCarPayable_1E         := bxfP21E.AsInteger;

      if not BAS_Rule_Setup[ bf1D ] then iWineEqlRefund_1D         := bxfP21D.AsInteger;
      if not BAS_Rule_Setup[ bf1F ] then iLuxCarRefund_1F          := bxfP21F.AsInteger;
      if not BAS_Rule_Setup[ bf1G ] then iSalesTaxCredit_1G        := bxfP21G.AsInteger;

      i1H_GSTInstalment   := bas1H_Summary.AsInteger;

      if not BAS_Rule_Setup[ bf5B ] then iCrAdjPrevIncome_5B       := bxfP25B.AsInteger;
      if not BAS_Rule_Setup[ bf6B ] then iVariationCr_6B           := bxfP26B.AsInteger;
      if not BAS_Rule_Setup[ bf7  ] then iDeferredInstalm_7        := bxfP27.AsInteger;
      if not BAS_Rule_Setup[ bf7c ] then iFuelOverClaim_7C         := bxfP7C.AsInteger;

      //always update this as the bas rule works differently for 7D
      //it is used to populate the worksheet rather than calc an value using
      //the chart
      iFuelCredit_7D := bxfP7D.AsInteger;

      {if not BAS_Rule_Setup[ bf7d ] then
        iFuelCredit_7D := bxfP7D.AsInteger
      else
        Self.UpdateTotalFuelCount;}

      if not BAS_Rule_Setup[ bft5 ] then iBAST5                    := basT5.AsInteger;
      BasInfo.iIsFuelPercentMethod := rbPercent.Checked;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmBAS.CauseRedisplay(Sender: TObject);
//should be linked to by all editable fields
//tried using is statement but doesn't seem to work.  Should only be called by TBasBoxField's anyway
begin
   if SettingFields then exit;

//   if Sender is TBasBoxField then
     begin
        if not TBasBoxField( Sender).ReadOnly then ReDisplay;
     end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBAS.PromptForFinalise( action : string);
var
   aMSg : string;
begin
   if Action <> '' then
     aMsg := 'You have ' + action + ' the Business Activity Statement.  '
   else
     aMSg := '';

   if (IsLocked(BasInfo.BasFromDate,BasInfo.BasToDate) <> ltAll) and
      (AskYesNo('Finalise Accounting Period', aMsg + 'Do you want to Finalise this Accounting Period?'+#13+#13+
     '(' + bkdate2Str(BasInfo.BasFromDate) + ' - ' + bkDate2Str(BasInfo.BasToDate) + ')'
     ,DLG_YES, BKH_Finalise_accounting_period_for_GST_purposes) = DLG_YES) then
    begin
      AutoLockGSTPeriod(BasInfo.BasFromDate, BasInfo.BasToDate);
      BasInfo.iIsFuelPercentMethod := rbPercent.Checked;
      BasInfo.SaveUserFields(tgFuel);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBAS.btnPrintClick(Sender: TObject);
begin
   //Make sure we have everything
   ReadEditableFields;
   //clear unselected fields for gst and payg instalment
   ClearUnselectedFields;
   //Recalc
   BasInfo.Recalculate;
   //verify
   if not VerifyFields then exit;
   //Call Print/Preview - if returns true then the report went to printer
   GenerateReport(rdPrinter, 'printed');
end;
procedure TfrmBAS.btnRecalcClick(Sender: TObject);
begin
  if AskYesNo('Recalculate', 'This will clear the grid and recalculate all grid rows based on BAS Rule 7D.'#13#13'Are you sure you want to do this?',
        DLG_NO, 0) = DLG_YES then
  begin
    //clear value in 7D edit box
    bxfp7D.AsInteger := 0;
    ReBuildFuelGrid;
    UpdateTotalFuelCount;
    //now update all figures
    ReDisplay;
  end;
end;

procedure TfrmBAS.bxfP1A1Click(Sender: TObject);
begin
  if bxfP1A1.Text = '' then
  begin
    bxfP1A1.SelectAll;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBAS.btnPreviewClick(Sender: TObject);
begin
   //Make sure we have everything
   ReadEditableFields;
   //clear unselected fields for gst and payg instalment
   ClearUnselectedFields;
   //Recalc
   BasInfo.Recalculate;
   //verify
   if not VerifyFields then exit;
   //Call Print/Preview - if returns true then the report went to printer

   GenerateReport( rdScreen, '');
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmBas.GenerateReport(Dest : TReportDest; aMsg : string);
begin
   case MyClient.clFields.clBAS_Report_Format of
     0 : begin
       if DoBasReport(Dest, BasInfo, tgfuel, RptParams) then begin
          PromptForFinalise(aMsg);
       end;
     end;

     1 : begin
       if DoBasSummary(Dest, BasInfo, RptParams) then begin
          PromptForFinalise(aMsg);
       end;
     end;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmBAS.btnEmailClick(Sender: TObject);
begin
   //Make sure we have everything
   ReadEditableFields;
   //clear unselected fields for gst and payg instalment
   ClearUnselectedFields;
   //Recalc
   BasInfo.Recalculate;
   //verify
   if not VerifyFields then
     exit;
   //Call Print/Preview - if returns true then the report went to printer
   GenerateReport( rdEmail, 'produced a copy of');
end;

procedure TfrmBAS.btnExportClick(Sender: TObject);
var
  sMsg        : string;
  ExportedOK, TFNRequired, ABNRequired, MustExit : boolean;
  j           : integer;
begin
   //Make sure we have everything
   ReadEditableFields;
   //clear unselected fields for gst and payg instalment
   ClearUnselectedFields;
   //Recalc
   BasInfo.Recalculate;
   //verify
   if not VerifyFields then exit;

   //make sure all relative paths are relative to data dir
   SysUtils.SetCurrentDir( Globals.DataDir);

   //see if can export
   if MyClient.clFields.clTax_Interface_Used = BKCONST.tsBAS_APS_XML then
   begin
     TFNRequired := IsIASForm(BasInfo.BasFormType) and (BasInfo.TFN = '');
     ABNRequired := (not IsIASForm(BasInfo.BasFormType)) and (BasInfo.ABN = '');
     if ABNRequired or TFNRequired then
     begin
       sMsg := 'You must enter the ';
       if TFNRequired and ABNRequired then
        sMsg := sMsg + 'Australian Business Number (ABN) and Tax File Number (TFN) '
       else if TFNRequired then
        sMsg := sMsg + 'Tax File Number (TFN) '
       else
        sMsg := sMsg + 'Australian Business Number (ABN) ';
       sMsg := sMsg + 'for this client before exporting to ' + BKCONST.tsNames[ tsBAS_APS_XML] + '.';
       HelpfulWarningMsg( sMsg, 0);
       EditGSTDetails(BKH_Set_up_GST);
       //see if user took to oppourtunity to enter the abn
       MustExit := (ABNRequired and (MyClient.clFields.clGST_Number = '')) or (TFNRequired and (MyClient.clFields.clTFN = ''));
       //update Bas Info
       with MyClient.clFields do
       begin
         j := Pos( '-' , clGST_Number);
         if j > 0 then begin
            BasInfo.ABN       := Copy( clGST_Number, 1, j -1);
            BasInfo.ABN_Extra := Copy( clGST_Number, j + 1, length( clGST_Number));
         end
         else begin
            BasInfo.ABN       := clGST_Number;
            BasInfo.ABN_Extra := '';
         end;
         BasInfo.TFN := clTFN;
       end;
       //update form
       ffdP1A2a.Caption               := BasInfo.ABN;
       ffdP1A2b.Caption               := BasInfo.ABN_Extra;
       if MustExit then Exit;
     end;
   end;

   //if no export interface has been specified then just prompt the user to finalise
   if MyClient.clFields.clTax_Interface_Used = BKCONST.tsNone then
   begin
     //ask user if they want to finalise the GST period now
     PromptForFinalise( '');
   end
   else
   begin
     //export file to selected system
     sMsg := '';
     ExportedOK := false;

     case MyClient.clFields.clTax_Interface_Used of
       BKCONST.tsBAS_Sol6ELS :
         ExportedOK := SaveForELS( MyClient, BasInfo, MyClient.clFields.clSave_Tax_Files_To, sMsg);
       BKCONST.tsBAS_XML, tsBAS_APS_XML, tsElite_XML, tsBAS_MYOB, tsBAS_HANDI :
         ExportedOK := SaveXML( MyClient, BasInfo, MyClient.clFields.clSave_Tax_Files_To, sMsg);
     end;

     if ExportedOK then
     begin
       HelpfulInfoMsg( 'BAS Form Exported to '#13#13 + sMsg +
                       ' (' + BKCONST.tsNames[ MyClient.clFields.clTax_Interface_Used] + ')', 0);
       //ask user if they want to finalise the GST period now
       PromptForFinalise( 'exported');
     end
     else
     begin
       HelpfulErrorMsg('Export Failed'#13#13 + sMsg, 0);
     end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBAS.cbfP6T4DropDown(Sender: TObject);
begin

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBAS.cbfP7F4DropDown(Sender: TObject);
begin

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBAS.lblGotoTopClick(Sender: TObject);
begin
   Self.VertScrollBar.Position := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBAS.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   if (tabFuelSheet.TabVisible) and (ModalResult = mrOk) then // move cells so that we save
   begin
     if tgFuel.CurrentDataRow < tgFuel.Rows then
       tgFuel.CurrentDataRow := tgFuel.CurrentDataRow + 1
     else
       tgFuel.CurrentDataRow := tgFuel.CurrentDataRow - 1;
   end;
   if ( ModalResult = mrOK) then begin
      //make sure have latest fields, then save
      ReadEditableFields;
      BasInfo.SaveUserFields(tgFuel);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBAS.SetEditableFields;
//update the editable fields with the values in the object.  Is used to setup
//the initial values.  If we dont do this they will be overwritten by the redisplay

//all user fields should be set here
var
   i : integer;
begin
  SettingFields := true;
  try
     with BasInfo do begin
        bxfP1A1.text                 := DocumentID;
        if not BAS_Rule_Setup[ bfG7 ] then
           bxfP4G7.AsInteger         := iIncAdjustments_G7;
        if not BAS_Rule_Setup[ bfG18 ] then
           bxfP4G18.AsInteger        := iAcqAdjustments_G18;

        //gst
        rbGSTOption1.Checked         := iGSTOptionUsed = 1;
        rbYes_GSTOption1.Checked     := bG1IncludesGST;
        rbNo_GSTOption1.Checked      := not bG1IncludesGST;

        rbGSTOption2.Checked         := iGSTOptionUsed = 2;
        rbYes_GSTOption2.Checked     := bG1IncludesGST;
        rbNo_GSTOption2.Checked      := not bG1IncludesGST;

        rbGSTOption3.Checked         := iGSTOptionUsed = 3;

        basG21_GSTOption3.AsInteger  := iG21_ATOInstalment;
        basG22_GSTOption3.AsInteger  := iG22_EstimatedNetGST;
        basG23_GSTOption3.AsInteger  := iG23_VariedAmount;
        basG24_GSTOption3.ItemIndex  := 0;

        for i := 0 to Pred( basG24_GSTOption3.Items.Count) do
           if Integer( basG24_GSTOption3.Items.Objects[ i]) = iG24_ReasonVar then
              basG24_GSTOption3.ItemIndex := i;

        //payg withheld
        bxfP5W1.AsInteger            := iTotalSalary_W1;
        bxfP5W2.AsInteger            := iSalaryWithheld_W2;
        bxfP5W3.AsInteger            := iInvstmntDist_W3;
        bxfP5W4.AsInteger            := iInvoicePymt_W4;

        //payg instalment
        rbPAYGI_Option1.Checked      := iPAYGInstalmentOptionUsed = 1;
        rbPAYGI_Option2.Checked      := iPAYGInstalmentOptionUsed = 2;
        rbPAYGI_Option3.Checked      := iPAYGInstalmentOptionUsed = 3;        

        if iPAYGInstalmentOptionUsed = 3 then begin
           basT6_PAYGOption3.AsInteger    := iT6_VariedAmount;
           cmbT4_PAYGOption3.ItemIndex  := 0;
           for i := 0 to Pred( cmbT4_PAYGOption3.Items.Count) do
              if Integer( cmbT4_PAYGOption3.Items.Objects[ i]) = iTaxReasonVar_T4 then
                 cmbT4_PAYGOption3.ItemIndex := i;
        end
        else if iPAYGInstalmentOptionUsed = 2 then begin
           bxfP6T1.AsInteger            := iTaxInstalmIncome_T1;

           bxfP6T2.NumericEdit.AsFloat  := dTaxInstalmRate_T2;
           bxfP6T3.NumericEdit.AsFloat  := dTaxVarInstalmRate_T3;

           cbfP6T4.ItemIndex  := 0;
           for i := 0 to Pred( cbfP6T4.Items.Count) do
              if Integer( cbfP6T4.Items.Objects[ i]) = iTaxReasonVar_T4 then
                 cbfP6T4.ItemIndex := i;
        end
        else begin
           basT7_PAYGOption1.AsInteger    := iT7_ATOInstalment;
           basT8_PAYGOption1.AsInteger    := iT8_EstimatedTax;
           basT9_PAYGOption1.AsInteger    := iT9_VariedAmount;

           cmbT4_PAYGOption1.ItemIndex  := 0;
           for i := 0 to Pred( cmbT4_PAYGOption1.Items.Count) do
              if Integer( cmbT4_PAYGOption1.Items.Objects[ i]) = iTaxReasonVar_T4 then
                 cmbT4_PAYGOption1.ItemIndex := i;
        end;

        //fbt
        bxfP7F1.AsInteger            := iFBTInstalm_F1;
        bxfP7F2.AsInteger            := iFBTTotalPayable_F2;
        bxfP7F3.AsInteger            := iFBTVariedInstalm_F3;

        cbfP7F4.ItemIndex  := 0;
        for i := 0 to Pred( cbfP7F4.Items.Count) do
           if Integer( cbfP7F4.Items.Objects[ i]) = iFBTReasonVar_F4 then
              cbfP7F4.ItemIndex := i;

        bxfP21C.AsInteger            := iWineEqlPayable_1C;
        bxfP21E.AsInteger            := iLuxCarPayable_1E;

        bxfP21D.AsInteger            := iWineEqlRefund_1D;
        bxfP21F.AsInteger            := iLuxCarRefund_1F;
        bxfP21G.AsInteger            := iSalesTaxCredit_1G;

        bas1H_Summary.AsInteger      := i1H_GSTInstalment;

        bxfP25B.AsInteger            := iCrAdjPrevIncome_5B;
        bxfP26B.AsInteger            := iVariationCr_6B;
        bxfP27.AsInteger             := iDeferredInstalm_7;

        //fuel tax
        bxfp7C.AsInteger             := iFuelOverClaim_7C;
        bxfp7D.AsInteger             := iFuelCredit_7D;

        basT5.AsInteger  := iBAST5;

        //set read only state
        bxfP4G7.ReadOnly             := BAS_Rule_Setup[ bfG7 ];
        bxfP4G18.ReadOnly            := BAS_Rule_Setup[ bfG18];

        bxfP5W1.ReadOnly             := BAS_Rule_Setup[ bfW1 ];
        bxfP5W2.ReadOnly             := BAS_Rule_Setup[ bfW2 ];
        bxfP5W3.ReadOnly             := BAS_Rule_Setup[ bfW3 ];
        bxfP5W4.ReadOnly             := BAS_Rule_Setup[ bfW4 ];

        bxfP6T1.ReadOnly             := BAS_Rule_Setup[ bfT1 ];

        bxfP21C.ReadOnly             := BAS_Rule_Setup[ bf1C ];
        bxfP21E.ReadOnly             := BAS_Rule_Setup[ bf1E ];
        bxfP21D.ReadOnly             := BAS_Rule_Setup[ bf1D ];
        bxfP21F.ReadOnly             := BAS_Rule_Setup[ bf1F ];
        bxfP21G.ReadOnly             := BAS_Rule_Setup[ bf1G ];
        bxfP25B.ReadOnly             := BAS_Rule_Setup[ bf5B ];
        bxfP26B.ReadOnly             := BAS_Rule_Setup[ bf6B ];
        bxfP27.ReadOnly              := BAS_Rule_Setup[ bf7 ];
        bxfP7c.ReadOnly              := BAS_Rule_Setup[ bf7c ];
        bxfP7d.ReadOnly              := BAS_Rule_Setup[ bf7d ];
      end;
  finally
     SettingFields := false;
  end;
end;
procedure TfrmBAS.SetrptParams(const Value: TrptParameters);
begin
  FrptParams := Value;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmBAS.VerifyFields : boolean;

    function ValidateDIN( DIN : string) : boolean;
    {
      To verify an ABN  ( From ATO Document)

      1) move last to digits to front after inserting leading zeros if length less than 11
      2) subtract 1 from first
      3) multiply digits by weighting
      4) sum products
      5) divide by 89
      6) zero remainder is valid
    }
    const
       Weighting : Array [ 1..11] of integer = ( 10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19 );
    var
       DIN_Digits : Array[ 1..11] of integer;
       Sum : integer;
       i   : integer;

    begin
       result := false;
       //check all char are numeric
       if not (IsNumeric( DIN)) then exit;
       //check length
       if Length( DIN) > 11 then exit;
       //pad with leading zeros
       while Length (DIN) < 11 do
          DIN := '0'+DIN;
       //take last 2 digits and place in front
       DIN_Digits[ 1] := Ord( DIN[ 10]) - 48;
       DIN_Digits[ 2] := Ord( DIN[ 11]) - 48;
       //load remaining string into digits
       for i := 3 to 11 do begin
          DIN_Digits[ i] := Ord( DIN[ i - 2]) - 48;
       end;
       //subtract 1
       Dec( DIN_Digits[ 1]);
       //multiply and add
       Sum := 0;
       for i := 1 to 11 do begin
          Sum := Sum + ( DIN_Digits[ i] * Weighting[ i]);
       end;
       //check the remainder is zero
       if ( Sum mod 89) <> 0 then exit;

       result := true;
    end;


begin
   result := false;
   //verify that entered values are ok
   //at this stage only the Document Information Number ( DIN) is checked

   ///verify DIN
   with BasInfo do begin
      if DocumentID <> '' then begin
         if not ValidateDIN( DocumentID) then begin
            if ( AskYesNo( 'Invalid Document Identification Number',
                  'You have entered an invalid Document Identification Number (DIN). '+
                  'Do you want to re-enter it?',
                  DLG_YES, 0) = DLG_YES) then begin
               //set tab control back to first page
               pgBasFrm.ActivePageIndex := 0;
               bxfP1A1.SetFocus;
               exit;
            end;
         end;
      end;
      if (iPAYGInstalmentOptionUsed = 2) and (dTaxVarInstalmRate_T3 <> 0) then // must have a reason
      begin
        if iTaxReasonVar_T4 = 0 then
        begin
          HelpfulErrorMsg('You have entered a new varied rate in box T3 -'#13 +
            'you must choose a reason code for variation from the list in T4', 0);
          pgBasFrm.ActivePage := tabPAYGInstalment;
          cbfP6T4.SetFocus;
          exit;
        end;
      end;
      if (iPAYGInstalmentOptionUsed = 1) and (iT8_EstimatedTax <> 0) then // must have a reason
      begin
        if iTaxReasonVar_T4 = 0 then
        begin
          HelpfulErrorMsg('You have entered estimated tax for the year in box T8 -'#13 +
            'you must choose a reason code for variation from the list in T4', 0);
          pgBasFrm.ActivePage := tabPAYGInstalment;
          cmbT4_PAYGOption1.SetFocus;
          exit;
        end;
      end;
      if (iPAYGInstalmentOptionUsed = 1) and (iT9_VariedAmount <> 0) then // must have a reason
      begin
        if iTaxReasonVar_T4 = 0 then
        begin
          HelpfulErrorMsg('You have entered a varied amount for the quarter in box T9 -'#13 +
            'you must choose a reason code for variation from the list in T4', 0);
          pgBasFrm.ActivePage := tabPAYGInstalment;
          cmbT4_PAYGOption1.SetFocus;
          exit;
        end;
      end;
      if (iPAYGInstalmentOptionUsed = 3) and (iT6_VariedAmount <> 0) then // must have a reason
      begin
        if iTaxReasonVar_T4 = 0 then
        begin
          HelpfulErrorMsg('You have entered a varied amount for the year in box T6 -'#13 +
            'you must choose a reason code for variation from the list in T4', 0);
          pgBasFrm.ActivePage := tabPAYGInstalment;
          cmbT4_PAYGOption3.SetFocus;
          exit;
        end;
      end;
      if (iGSTOptionUsed = 3) and (iG23_VariedAmount <> 0) then // must have a reason
      begin
        if basG24_GSTOption3.ItemIndex = 0 then
        begin
          HelpfulErrorMsg('You have entered a varied amount for the quarter in box G23 -'#13 +
            'you must choose a reason code for variation from the list in G24', 0);
          pgBasFrm.ActivePage := tabGST;
          basG24_GSTOption3.SetFocus;
          exit;
        end;
      end;
      if (iFBTTotalPayable_F2 <> 0) and (iFBTReasonVar_F4 = 0) then
      begin
        HelpfulErrorMsg('You have entered an estimated FBT for the year in box F2 -'#13 +
          'you must choose a reason code for variation from the list in F4', 0);
        pgBasFrm.ActivePage := tabFBT;
        cbfP7F4.SetFocus;
        exit;
      end;
      if (iFBTVariedInstalm_F3 <> 0) and (iFBTReasonVar_F4 = 0) then
      begin
        HelpfulErrorMsg('You have entered a varied amount for the quarter in box F3 -'#13 +
          'you must choose a reason code for variation from the list in F4', 0);
        pgBasFrm.ActivePage := tabFBT;
        cbfP7F4.SetFocus;
        exit;
      end;
   end;
   result := true;
end;

procedure TfrmBAS.rbFuelClick(Sender: TObject);
begin
  tgFuel.Col[colEligible].ReadOnly := rbPercent.Checked;
  tgFuel.Col[colPercent].ReadOnly := rbFuel.Checked;
  if rbFuel.Checked then
  begin
    tgFuel.Col[colPercent].Color := clNone;
    tgFuel.Col[colEligible].Color := clInfoBK;
  end
  else
  begin
    tgFuel.Col[colPercent].Color := clInfoBK;
    tgFuel.Col[colEligible].Color := clNone;
  end;
end;

procedure TfrmBAS.rbGSTOption1Click(Sender: TObject);
begin
   if SettingFields then exit;

   if rbGSTOption1.Checked then
      rbGSTOption1.Font.Style := [ fsBold]
   else
      rbGSTOption1.Font.Style := [];

   if rbGSTOption2.Checked then
      rbGSTOption2.Font.Style := [ fsBold]
   else
      rbGSTOption2.Font.Style := [];

   if rbGSTOption3.Checked then
      rbGSTOption3.Font.Style := [ fsBold]
   else
      rbGSTOption3.Font.Style := [];


   rbYes_GSTOption1.Enabled      := rbGSTOption1.Checked;
   rbNo_GSTOption1.Enabled       := rbGSTOption1.Checked;

   rbYes_GSTOption2.Enabled      := rbGSTOption2.Checked;
   rbNo_GSTOption2.Enabled       := rbGSTOption2.Checked;

   basG21_GSTOption3.NumericEdit.Enabled     := rbGSTOption3.checked;
   basG22_GSTOption3.NumericEdit.Enabled     := rbGSTOption3.checked;
   basG23_GSTOption3.NumericEdit.Enabled     := rbGSTOption3.checked;
   basG24_GSTOption3.Enabled     := rbGSTOption3.checked;

   bas1A_GSTOption3.Visible      := rbGSTOption3.checked;

   if rbGSTOption1.Checked then
     rbNo_GSTOption2.Checked := True
   else if rbGSTOption2.Checked then
     rbNo_GSTOption1.Checked := True
   else if rbGSTOption3.Checked then
   begin
     rbNo_GSTOption1.Checked := True;
     rbNo_GSTOption2.Checked := True;
   end;
   //force a redisplay
   ReDisplay;
end;
procedure TfrmBAS.rbNo_GSTOption1Click(Sender: TObject);
begin

end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBAS.rbPAYGI_Option1Click(Sender: TObject);
begin
   if SettingFields then exit;

   if rbPAYGI_Option3.Checked then
      rbPAYGI_Option3.Font.Style := [ fsBold]
   else
      rbPAYGI_Option3.Font.Style := [];

   if rbPAYGI_Option2.Checked then
      rbPAYGI_Option2.Font.Style := [ fsBold]
   else
      rbPAYGI_Option2.Font.Style := [];

   if rbPAYGI_Option1.Checked then
      rbPAYGI_Option1.Font.Style := [ fsBold]
   else
      rbPAYGI_Option1.Font.Style := [];

   basT7_PAYGOption1.NumericEdit.Enabled   := rbPAYGI_Option1.Checked;
   basT8_PAYGOption1.NumericEdit.Enabled   := rbPAYGI_Option1.Checked;
   basT9_PAYGOption1.NumericEdit.Enabled   := rbPAYGI_Option1.Checked;
   cmbT4_PAYGOption1.Enabled               := rbPAYGI_Option1.Checked;

   bxfP6T1.NumericEdit.Enabled             := rbPAYGI_Option2.Checked;
   bxfP6T2.NumericEdit.Enabled             := rbPAYGI_Option2.Checked;
   bxfP6T3.NumericEdit.Enabled             := rbPAYGI_Option2.Checked;
   basT11_Calc.NumericEdit.Enabled         := rbPAYGI_Option2.Checked;
   cbfP6T4.Enabled                         := rbPAYGI_Option2.Checked;

   basT6_PAYGOption3.NumericEdit.Enabled   := rbPAYGI_Option3.Checked;
   cmbT4_PAYGOption3.Enabled               := rbPAYGI_Option3.Checked;
   Redisplay;
end;
procedure TfrmBAS.rbYes_GSTOption1Click(Sender: TObject);
begin

end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ShowAnnualGSTReturn(Params: TrptParameters = nil);
var
  myFrm : TfrmBAS;
  dFrom, dTo : integer;
  S          : string;
begin
   if not HasEntries then exit;

   myFrm := TfrmBAS.Create( nil);  //themes dont work for this form
   try repeat
      //check we have all of the required values
      with MyClient, MyClient.clFields, myFrm do begin
         if ( clGST_Start_Month = 0) then begin
            S := 'Before you can do this you must setup the GST Period and Start Month';
            HelpfulInfoMsg( S,0);
            EditGSTDetails(BKH_Set_up_GST);
            if ( clGST_Start_Month = 0) then exit;
         end;
         //select GST Period to work with
         if not SelectAnnualBASPeriod( dFrom, dTo, Params ) then exit;


      end;

      if Assigned(Params) then begin
          if Params.BatchSave then begin
             Params.SaveNodeSettings;
             Exit;
          end;
      end;

      MyFrm.rptParams := Params;

      if MyClient.clFields.clGST_Period = gpNone then
        MyFrm.Execute( dFrom, dTo, bsIASN)
      else if MyClient.clFields.clBAS_Include_Fuel and (dTo >= bkStr2Date('01/07/06')) then
        MyFrm.Execute( dFrom, dTo, bsBasZ)
      else
        MyFrm.Execute( dFrom, dTo, bsH);

      if Assigned(Params) then
         if Params.BatchRunMode = R_batch then
             Break;

   until false;
   finally
      MyFrm.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ShowAnnualGSTInformationReport(Params: TrptParameters = nil);
var
  myFrm : TfrmBAS;
  dFrom, dTo : integer;
  S          : string;
begin
   if not HasEntries then exit;

   myFrm := TfrmBAS.Create( nil);  //themes dont work for this form
   try repeat
      //check we have all of the required values
      with MyClient, MyClient.clFields, myFrm do begin
         if ( clGST_Period = gpNone) or ( clGST_Start_Month = 0) then begin
            S := 'Before you can do this you must setup the GST Period and Start Month';
            HelpfulInfoMsg( S,0);
            EditGSTDetails(BKH_Set_up_GST);
            if ( clGST_Period = gpNone) or ( clGST_Start_Month = 0) then exit;
         end;
         //select GST Period to work with
         if not SelectAnnualBASPeriod( dFrom, dTo, Params ) then exit;
      end;

      if Assigned(Params) then begin
          if Params.BatchSave then begin
             Params.SaveNodeSettings;
             Exit;
          end;
      end;

      MyFrm.rptParams := Params;

      MyFrm.Execute(dFrom, dTo, bsK);

      if Assigned(Params) then
         if Params.BatchRunMode = R_batch then
             Break;

   until False;
   finally
      MyFrm.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBAS.btnFileClick(Sender: TObject);
begin
   //Make sure we have everything
   ReadEditableFields;
   //clear unselected fields for gst and payg instalment
   ClearUnselectedFields;
   //Recalc
   BasInfo.Recalculate;
   //verify
   if not VerifyFields then
     exit;
   //Call Print/Preview - if returns true then the report went to printer
   GenerateReport( rdFile, 'produced a copy of');
end;

procedure TfrmBAS.cbfP6T4Change(Sender: TObject);
begin
   if SettingFields then exit;
   ReDisplay;
end;

procedure TfrmBAS.UpdateTotalFuelCount;
//updates the label total in the fuel worksheeet tab
//also updates the 7D field in the summary tab and
//directly updates the BasInfo structure
var
  i: Integer;
  Total: Double;
  s: string;
  GridHasValues : boolean;
begin
  Total := 0;
  GridHasValues := false;
  for i := 0 to Pred(tgFuel.Rows) do
  begin
    if tgFuel.Cell[colTotal, i + 1] <> '' then
    begin
      Total := Total + tgFuel.Cell[colTotal, i + 1];
      GridHasValues := true;
    end;
  end;
  s := IntToStr(Trunc(Total));
  lblTotal.Caption := '$' + s;

  //now update 7D fields from worksheet
  GridHasValues := GridHasValues or ( Total <> 0);
  if GridHasValues then
    bxfp7D.AsInteger := StrToIntDef(s, 0);

  //set to read only if populated by rule or via worksheet
  bxfp7D.ReadOnly := BasInfo.BAS_Rule_Setup[ bf7d ] or
                    ((not BasInfo.BAS_Rule_Setup[ bf7d ]) and GridHasValues);   //(StrToIntDef(s, 0) <> 0));

  //directly populate basInfo structure if field has been updated from
  //rule or through worksheet
  if bxfp7D.ReadOnly then
    BasInfo.iFuelCredit_7D := bxfp7D.AsInteger;
end;

procedure TfrmBAS.RebuildFuelGrid;
var
  i, j: Integer;
  Total: Extended;
  Account: pAccount_Rec;
  AccountOK: Boolean;
  E: TtsCellChangedEvent;
begin
   j := 1;
   E := tgFuel.OnCellChanged;
   tgFuel.OnCellChanged := nil;
   tgFuel.Rows := 0;
   tgfuel.Rows := 50;
   tgFuel.OnCellChanged := E;

   for i := MIN_SLOT to MAX_SLOT do
   begin
     if (MyClient.clFields.clBAS_Field_Number[i] = bf7D) and (MyClient.clFields.clBAS_Field_Source[i] = BASUtils.bsFrom_Chart) then // fill worksheet
     begin
      Total := CalculateQtyTotals(BasInfo.GSTFromDate, BasInfo.GSTToDate, MyClient.clFields.clBAS_Field_Account_Code[i], AccountOK);
      if AccountOK then
      begin
        tgFuel.Cell[colCode, j] := MyClient.clFields.clBAS_Field_Account_Code[i];
        Account := MyClient.clChart.FindCode( MyClient.clFields.clBAS_Field_Account_Code[i] );
        if Assigned(Account) then
          tgFuel.Cell[ColDesc, j] := Account.chAccount_Description
        else if MyClient.clFields.clBAS_Field_Account_Code[ i ] <> '' then
          tgFuel.Cell[ColDesc, j] := 'INVALID ACCOUNT';

        tgFuel.Cell[colLitres, j] := MyRoundTo(Total, 0);
        tgFuel.Cell[colPercent, j] := MyRoundTo(Percent2Double(MyClient.clFields.clBAS_Field_Percent[i]), 0);
        if MyClient.clFields.clBAS_Field_Percent[i] <> 0 then
          tgFuel.Cell[colEligible, j] := MyRoundTo((tgFuel.Cell[colLitres, j] / 100) * tgFuel.Cell[colPercent, j], 0);
        tgFuel.Cell[colTotal,j] := 0;
        Inc(j);
      end;
      if (MyClient.clFields.clBAS_Field_Percent[i] <> 0) and (MyClient.clFields.clBAS_Field_Percent[i] <> 1000000) then
      begin
        rbPercent.Checked := True;
        rbFuelClick(Self);
      end;
     end;
   end;
end;

end.
