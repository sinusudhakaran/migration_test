unit gst372frm;
//------------------------------------------------------------------------------
{
   Title:

   Description: displays and prints the gST 372 report

   Author:

   Remarks:

   Last Reviewed :

}
//------------------------------------------------------------------------------

interface

uses
  jPeg,
  PrintMgrObj,
  gstWorkRec,
  clobj32,
  bkConst,
  bkDateUtils,
  Printers,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ovcbase, ovcef, ovcpb, ovcnf, StdCtrls, ExtCtrls, OleCtrls,
  Buttons,
  OSFont,
  bkDefs ;

type
  TFrmGST372 = class(TForm)
    OvcController1: TOvcController;
    ScrollBox1: TScrollBox;
    GBTop: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    RbMonth: TRadioButton;
    Rb2Months: TRadioButton;
    RB6Months: TRadioButton;
    stGSTNumber: TStaticText;
    stname: TStaticText;
    stFrom: TStaticText;
    stTo: TStaticText;
    PAdjust: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Bevel1: TBevel;
    LTotalAdjust: TStaticText;
    NPrivate: TOvcNumericField;
    NBusiness: TOvcNumericField;
    NAssets: TOvcNumericField;
    NEntertainment: TOvcNumericField;
    NChange: TOvcNumericField;
    NGSTExempt: TOvcNumericField;
    Nother: TOvcNumericField;
    GBCreditAdjust: TGroupBox;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label24: TLabel;
    Bevel2: TBevel;
    LTotalCredit: TStaticText;
    ncBusiness: TOvcNumericField;
    ncPrivate: TOvcNumericField;
    NCChange: TOvcNumericField;
    ncOther: TOvcNumericField;
    Label41: TLabel;
    pnlFooter: TPanel;
    BtnPreview: TButton;
    BtnFile: TButton;
    BtnPrint: TButton;
    BtnOK: TBitBtn;
    BtnCancel: TBitBtn;
    btnCopy: TButton;
    Label6: TLabel;
    NCCustoms: TStaticText;

    procedure NTotalChange(Sender: TObject);
    procedure NCreditChange(Sender: TObject);
    procedure BtnPreviewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnPrintClick(Sender: TObject);
    procedure BtnFileClick(Sender: TObject);
    procedure NPrivateKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnCopyClick(Sender: TObject);
  private
    { Private declarations }
    FClient: TClientObj;
    FCreditAdjustment: Double;
    FTotalAdjustment: Double;
    FUserPrintSettings: TPrintManagerObj;
    FShowFormHints: boolean;
    FLastPeriodBalances: tBalances_Rec;
    CustomFormHeight : integer;
    CustomFormWidth : integer;
    FGSTForm: TGSTForm;

    procedure SetClient(const Value: TClientObj);
    procedure SetCreditAdjustment(const Value: Double);
    procedure SetTotalAdjustment(const Value: Double);
    //Function  GetPrintImage: TBitmap;
    procedure SetDateRange(const Value: TDateRange);
    procedure SetUserPrintSettings(const Value: TPrintManagerObj);
    Procedure ReadGstForm(var Value : TGSTForm);
    procedure SetShowFormHints(const Value: boolean);
    function GetCustomsGSTAmount: Double;
    procedure SetGSTForm(const Value: TGSTForm);
  public
    { Public declarations }
    property CustomsGSTAmount: Double read GetCustomsGSTAmount;
    property Client : TClientObj read FClient write SetClient;
    property GSTForm: TGSTForm read FGSTForm write SetGSTForm;
    property ShowFormHints : boolean read FShowFormHints write SetShowFormHints;
    property TotalAdjustment : Double read FTotalAdjustment write SetTotalAdjustment;
    property CreditAdjustment : Double read FCreditAdjustment write SetCreditAdjustment;
    property UserPrintSettings  : TPrintManagerObj read FUserPrintSettings write SetUserPrintSettings;
    property LastPeriodBalances : tBalances_Rec read  FLastPeriodBalances write FLastPeriodBalances;
  end;


function RunGST372 (   AOwner: TComponent;
                       ShowFormHints: Boolean;
                       UserPrintSettings: TPrintManagerObj;
                       ForClient: TClientObj;
                       ForPeriod: TDateRange;
                       var ForGSTForm: TGSTForm;
                       PreviousBalances: pBalances_Rec;
                       Var ATotalAdjustment,
                           ACreditAdjustment : Double): tModalresult;



procedure DeNegativeOvcNumericField(Sender: TObject);

//*************
implementation
//*************

Uses
   PDDATES32,
   STDHINTS,
   reportDefs,
   rptgst372,
   bkXPThemes,
   bkHelp,
   Math,
   GenUtils;


procedure TFrmGST372.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  PnlFooter.Font := Application.MainForm.Font;
  //default form size, as designed is set here
  //this allows us to manipulate that size displayed without windows
  //trying to interfer

  CustomFormHeight := 624;
  CustomFormWidth := 840;
end;

function TFrmGST372.GetCustomsGSTAmount: Double;
begin
  Result := FGstForm.rAcrt_Customs;
end;

{$R *.dfm}

procedure TFrmGST372.SetClient(const Value: TClientObj);
begin
  FClient := Value;
  if assigned(FClient) then begin
     StName.caption := FClient.clFields.clName;
     stGSTNumber.Caption := FClient.clFields.clGST_Number;

     {case FClient.clFields.clGST_Period of
       gpMonthly   : RBMonth.Checked := true;
       gp2Monthly  : RB2Months.Checked := true;
       gp6Monthly  : RB6Months.Checked := true;
     end;}
  end;
end;


procedure DeNegativeOvcNumericField(Sender: TObject);
var s : String;

    function RemoveChars ( AChar : Char) : Boolean;
    var  pc : Integer;
    begin
       Result := False;
       pc := Pos (AChar,s);
       while pc <> 0 do begin
          Delete(s,pc,1);
          pc := Pos (AChar,s);
          result := true;
       end;
    end;
begin
   {$B-}
   if assigned(Sender)
   and (sender is TOvcNumericField) then
      with sender as TOvcNumericField do begin
         s := AsString;
         if RemoveChars('-') then begin
            RemoveChars(',');
            AsString := S;
            Deselect;
         end;
      end;
end;

procedure TFrmGST372.NTotalChange(Sender: TObject);

begin
   DeNegativeOvcNumericField(Sender);

   TotalAdjustment :=
       NPrivate.AsFloat +
       NBusiness.AsFloat +
       NAssets.AsFloat +
       NEntertainment.AsFloat +
       NChange.AsFloat +                                         
       NGSTExempt.AsFloat +
       Nother.AsFloat;
end;

{procedure TFrmGST372.Reset;
begin
   NPrivate.AsFloat        := 0;
   NBusiness.AsFloat       := 0;
   NAssets.AsFloat         := 0;
   NEntertainment.AsFloat  := 0;
   NChange.AsFloat         := 0;
   NGSTExempt.AsFloat      := 0;
   Nother.AsFloat          := 0;

   TotalAdjustment         := 0;

   ncBusiness.AsFloat      := 0;
   ncPrivate.AsFloat       := 0;
   nCChange.AsFloat        := 0;
   ncOther.AsFloat         := 0;

   CreditAdjustment        := 0;
end;}

procedure TFrmGST372.NCreditChange(Sender: TObject);
begin
   DeNegativeOvcNumericField(Sender);
   CreditAdjustment :=
      ncBusiness.AsFloat +
      ncPrivate.AsFloat +
      ncChange.AsFloat +
      FGSTForm.rAcrt_Customs +
      ncOther.AsFloat;
end;

procedure TFrmGST372.SetCreditAdjustment(const Value: Double);
begin
  FCreditAdjustment := Value;
  LTotalCredit.Caption := FormatFloat('#,##0.00',FCreditAdjustment)
end;

procedure TFrmGST372.SetTotalAdjustment(const Value: Double);
begin
  FTotalAdjustment := Value;
  LTotalAdjust.Caption := FormatFloat('#,##0.00',FTotalAdjustment)
end;

procedure TFrmGST372.BtnPreviewClick(Sender: TObject);
begin
   DoGST372Report(Self,rdScreen);
end;

procedure TFrmGST372.BtnPrintClick(Sender: TObject);
begin
   DoGST372Report(Self,rdPrinter);
end;

procedure TFrmGST372.btnCopyClick(Sender: TObject);
begin
  //Copy values from last 372 form.
  //First see if any values are entered and display a message warning that the values will be overwritten
  if (not IsZero(FTotalAdjustment))
  or (not IsZero(FCreditAdjustment)) then
  begin
    if MessageDlg('This will clear any previously entered values.'#13#10'Are you sure you wish to continue?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      Exit;
  end;

  NPrivate.AsFloat := Money2Double(FLastPeriodBalances.blGST_Adj_PrivUse + FLastPeriodBalances.blBAS_6B_GST_Adj_PrivUse);
  NBusiness.AsFloat := Money2Double(FLastPeriodBalances.blGST_Adj_BAssets + FLastPeriodBalances.blBAS_7_VAT4_GST_Adj_BAssets);
  NAssets.AsFloat := Money2Double(FLastPeriodBalances.blGST_Adj_Assets + FLastPeriodBalances.blBAS_G7_GST_Adj_Assets);
  NEntertainment.AsFloat := Money2Double(FLastPeriodBalances.blGST_Adj_Entertain + FLastPeriodBalances.blBAS_G18_GST_Adj_Entertain);
  NChange.AsFloat := Money2Double(FLastPeriodBalances.blGST_Adj_Change + FLastPeriodBalances.blBAS_W1_GST_Adj_Change);
  NGSTExempt.AsFloat := Money2Double(FLastPeriodBalances.blGST_Adj_Exempt + FLastPeriodBalances.blBAS_W2_GST_Adj_Exempt);
  Nother.AsFloat := Money2Double(FLastPeriodBalances.blGST_Adj_Other + FLastPeriodBalances.blBAS_W3_GST_Adj_Other);

  ncBusiness.AsFloat := Money2Double(FLastPeriodBalances.blGST_Cdj_BusUse + FLastPeriodBalances.blBAS_W4_GST_Cdj_BusUse);
  ncPrivate.AsFloat := Money2Double(FLastPeriodBalances.blGST_Cdj_PAssets + FLastPeriodBalances.blBAS_T1_VAT1_GST_Cdj_PAssets);
  NCChange.AsFloat := Money2Double(FLastPeriodBalances.blGST_Cdj_Change + FLastPeriodBalances.blBAS_T2_VAT2_GST_Cdj_Change);
  ncOther.AsFloat := Money2Double(FLastPeriodBalances.blGST_Cdj_Other + FLastPeriodBalances.blBAS_T3_VAT3_GST_Cdj_Other);
  
  // Update the totals..
  NTotalChange(nil);
  NCreditChange(nil);
end;

procedure TFrmGST372.BtnFileClick(Sender: TObject);
begin
    DoGST372Report(Self,rdFile);
end;

procedure TFrmGST372.SetGSTForm(const Value: TGSTForm);
begin
  FGSTForm := Value;
  // Read the values..
  NPrivate.AsFloat       := FGSTForm.rAdj_Private;
  NBusiness.AsFloat      := FGSTForm.rAdj_Bassets;
  NAssets.AsFloat        := FGSTForm.rAdj_Assets;
  NEntertainment.AsFloat := FGSTForm.rAdj_Entertain;
  NChange.AsFloat        := FGSTForm.rAdj_Change ;
  NGSTExempt.AsFloat     := FGSTForm.rAdj_Exempt;
  Nother.AsFloat         := FGSTForm.rAdj_Other;

  ncBusiness.AsFloat     := FGSTForm.rAcrt_Use;
  ncPrivate.AsFloat      := FGSTForm.rAcrt_Private;
  nCChange.AsFloat       := FGSTForm.rAcrt_Change;
  NCCustoms.Caption      := FormatFloat('#,##0.00',FGSTForm.rAcrt_Customs);
  ncOther.AsFloat        := FGSTForm.rAcrt_Other;

   // Update the totals..
  NTotalChange(Nil);
  NCreditChange(Nil);
end;

procedure TFrmGST372.SetDateRange(const Value: TDateRange);
begin

  stFrom.Caption :=  bkDate2Str(Value.FromDate);
  stTo.Caption   :=  bkDate2Str(Value.ToDate);

  case GetPeriodMonths(Value.FromDate,Value.ToDate) of
     1 : rbMonth.Checked  := True;
     2 : rb2Months.Checked := True;
     6 : rb6Months.Checked := True;
  end;

end;

procedure TFrmGST372.SetUserPrintSettings(const Value: TPrintManagerObj);
begin
  FUserPrintSettings := Value;
end;

procedure TFrmGST372.ReadGSTForm(var Value : TGSTForm);
begin // fills the Adjust bits...
  Value.rAdj_Private   := NPrivate.AsFloat;
  Value.rAdj_Bassets   := NBusiness.AsFloat;
  Value.rAdj_Assets    := NAssets.AsFloat;
  Value.rAdj_Entertain := NEntertainment.AsFloat;
  Value.rAdj_Change    := NChange.AsFloat;
  Value.rAdj_Exempt    := NGSTExempt.AsFloat;
  Value.rAdj_Other     := Nother.AsFloat;

  Value.rAcrt_Use      := ncBusiness.AsFloat;
  Value.rAcrt_Private  := ncPrivate.AsFloat;
  Value.rAcrt_Change   := nCChange.AsFloat;
  Value.rAcrt_Other    := ncOther.AsFloat;
end;


procedure TFrmGST372.SetShowFormHints(const Value: boolean);

   procedure AddHint (baseText : String; Control : tControl);
   begin
      Control.Hint := 'Enter ' + baseText +
                      '| Enter ' + baseText;
   end;

begin
  FShowFormHints := Value;
  Self.ShowHint  := fShowFormHints;

  AddHint(Label7.Caption  ,NPrivate);
  AddHint(Label8.Caption  ,NBusiness);
  AddHint(Label9.Caption  ,NAssets);
  AddHint(Label10.Caption ,NEnterTainment);
  AddHint(Label11.Caption ,NChange);
  AddHint(Label12.Caption ,NGSTExempt);
  AddHint(Label13.Caption ,NOther);
  AddHint(Label14.Caption + ' ' +
          label15.Caption ,NPrivate);


  AddHint(Label17.Caption  ,NCBusiness);
  AddHint(Label18.Caption  ,NCPrivate);
  AddHint(Label19.Caption  ,NCChange);
  AddHint(Label20.Caption  ,NCOther);

  btnPreview.Hint     :=
                       STDHINTS.PreviewHint;
  btnPrint.Hint       :=
                       STDHINTS.PrintHint;
  btnCopy.Hint        := 'Copy the values from the last IR372 Return|' +
                         'Copy the values from the last IR372 Return';

end;

function RunGST372 (   AOwner: TComponent;
                       ShowFormHints: Boolean;
                       UserPrintSettings: TPrintManagerObj;
                       ForClient: TClientObj;
                       ForPeriod: TDateRange;
                       var ForGSTForm: TGSTForm;
                       PreviousBalances: pBalances_Rec;
                       Var ATotalAdjustment,
                           ACreditAdjustment : Double): tModalresult;
var FrmGST372: TFrmGST372;
Begin
  FrmGST372:= TFrmGST372.Create(AOwner);
  try
    BKHelpSetUp( FrmGST372, BKH_GST_adjustments_calculation_sheet_IR372);
    FrmGST372.Client := ForClient;
    FrmGST372.SetDateRange(ForPeriod);
    FrmGST372.GSTForm := ForGSTForm;
    if Assigned(PreviousBalances) then
      FrmGst372.LastPeriodBalances := PreviousBalances^
    else
      FrmGST372.btnCopy.Enabled := false;
    FrmGST372.ShowFormHints := ShowFormHints;
    FrmGST372.UserPrintSettings := UserPrintSettings;

    //set form size
    FrmGST372.Height := FrmGST372.CustomFormHeight;
    FrmGST372.Width := FrmGST372.CustomFormWidth;

    if Screen.WorkAreaHeight < FrmGST372.CustomFormHeight then
    begin
      FrmGST372.Height := Screen.WorkAreaHeight;
      FrmGST372.ScrollBox1.VertScrollBar.Position := 0;
    end;

    if Screen.WorkAreaWidth < FrmGST372.CustomFormWidth then
    begin
      FrmGST372.Width := Screen.WorkAreaWidth;
      FrmGST372.ScrollBox1.HorzScrollBar.Position := 0;
    end;

    FrmGST372.Left := Screen.WorkAreaLeft + (Screen.WorkAreaWidth - FrmGST372.Width) div 2;
    FrmGST372.Top := Screen.WorkAreaTop + (Screen.WorkAreaHeight - FrmGST372.Height) div 2;

    if Screen.WorkAreaHeight < 600 then
    begin
      FrmGST372.Position := poMainFormCenter;
      FrmGST372.Top := 0;
    end;

    //***************************
    Result := FrmGST372.ShowModal;
    //***************************

    if result = mrOK then begin
       FrmGST372.ReadGstForm(ForGstForm);
       ATotalAdjustment  := FrmGST372.TotalAdjustment;
       ACreditAdjustment := FrmGST372.CreditAdjustment;
    end;

  finally
    FrmGST372.Free;
  end;
end;

procedure TFrmGST372.NPrivateKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then begin  //translate enter to tab
     if ssShift	In Shift then begin
       if sender <> nPrivate then
          SelectNext(Sender as TWinControl,False,True)
       else SelectNext(BtnPreview,False,True);
     end else begin
       if sender <> ncother then
          SelectNext(Sender as TWinControl,True,True)
       else SelectNext(BtnCancel,True,True);
     end;
     Key := 0; // Processed
  end;
end;

end.
