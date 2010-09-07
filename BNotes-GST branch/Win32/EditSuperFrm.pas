unit EditSuperFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, RzEdit, ExtCtrls, Mainfrm, ECDEFS, MoneyDef, ecObj,DissectionFrm,
  Buttons;

type
  TfrmEditSuper = class(TForm)
    pnlHeader: TPanel;
    Label1: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    lblDate: TLabel;
    lblNarrationField: TLabel;
    lblPayeeName: TLabel;
    Label2: TLabel;
    Label6: TLabel;
    lblAmount: TLabel;
    lblRef: TLabel;
    imgCoded: TImage;
    pnlRight: TPanel;
    pnlBottom: TPanel;
    pnlTop: TPanel;
    pnlLeft: TPanel;
    PnlSuper: TPanel;
    pnlBtn: TPanel;
    btnClear: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    PnlEdit: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    EFranked: TRzNumericEdit;
    EUnfranked: TRzNumericEdit;
    ECredits: TRzNumericEdit;
    btnCalc: TBitBtn;
    procedure EFrankedChange(Sender: TObject);
    procedure EUnfrankedChange(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure ECreditsChange(Sender: TObject);
    procedure btnCalcClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FTransaction: PTransaction_Rec;
    FClientFile: TEcClient;
    InUpdate: Boolean;
    FModified: Boolean;
    FDissection: PWork_Dissect_Rec;
    FIsReadOnly: Boolean;
    procedure SetTransaction(const Value: PTransaction_Rec);
    function GetTransaction: PTransaction_Rec;
    function CompanyTax: Money;
    procedure SetClientFile(const Value: TEcClient);
    procedure CalcFranked(InValue, OutValue: TRzNumericEdit);
    function CheckCredits(Force: Boolean): Boolean;
    procedure Clear;
    procedure SetDissection(const Value: PWork_Dissect_Rec);
    function GetDissection: PWork_Dissect_Rec;
    procedure SetModified(const Value: Boolean);
    procedure SetIsReadOnly(const Value: Boolean);
    { Private declarations }
  public
    property Transaction: PTransaction_Rec read GetTransaction write SetTransaction;
    property Dissection: PWork_Dissect_Rec read GetDissection write SetDissection;
    property ClientFile: TEcClient read FClientFile write SetClientFile;
    procedure Save;
    property Modified: Boolean read FModified write SetModified;
    property IsReadOnly: Boolean read FIsReadOnly write SetIsReadOnly;
    { Public declarations }
  end;


implementation

uses
   ECPayeeObj,
   GenUtils,
   ecColors,
   FormUtils,
   NotesHelp,
   ecGlobalConst;

{$R *.dfm}

{ TForm1 }

procedure TfrmEditSuper.btnCalcClick(Sender: TObject);
begin
   if InUpdate then
      Exit;
   InUpdate := True;
   try
      CheckCredits(True);
      Modified := False;
   finally
      InUpdate := False;
   end;
end;

procedure TfrmEditSuper.btnClearClick(Sender: TObject);
begin
   Clear;
end;

procedure TfrmEditSuper.btnOKClick(Sender: TObject);
begin
   Save;
   Modalresult := mrOK;
end;

procedure TfrmEditSuper.CalcFranked(InValue, OutValue: TRzNumericEdit);
var Amount: Extended;
begin
   if Assigned(FTransaction) then
      Amount := Abs(Money2Double(FTransaction.txAmount))
   else if Assigned(FDissection) then
      Amount := Abs(Money2Double(FDissection.dtAmount))
   else
      Exit;

   if (InValue.Value <= 0) then begin
      InValue.Value := 0;
      OutValue.Value := AMount;
   end else if InValue.Value < Amount then begin
      OutValue.Value :=  AMount - InValue.Value;
   end else begin
      InValue.Value := Amount;
      OutValue.Value := 0;
   end;

end;

function TfrmEditSuper.CheckCredits(Force: Boolean): Boolean;

var
   Tax, lAmount: Double;
const clOrange = $000080FF;
begin
  

   Tax := Percent2Double(CompanyTax);
   lAmount := EFranked.Value;
   // Workout the Franking Credits
   if (lAmount <> 0)
   and (Tax <> 0) then begin
      lAmount := Money2Double(Double2Money(LAmount * (Tax/(100-Tax)))) {Rounded the same}
   end else
      LAmount := 0;

   Tax := ECredits.Value; // Double <> Extended...
   Result := (LAMount = Tax);

   if Force then begin
      // Franking Credits ..
      ECredits.Value := lAmount;
      ECredits.Color := clwindow;

   end else begin
      //Just check Franking Credits ..
      if Result then
         ECredits.Color := clwindow
      else
         ECredits.Color := clOrange;
   end;
end;


procedure TfrmEditSuper.Clear;
var lKeep: Boolean;
begin
   lKeep := InUpdate;
   InUpdate := True;
   try
      EFranked.Value := 0;
      EUnFranked.Value := 0;
      ECredits.Value := 0;
      Modified := not CheckCredits(False);
   finally
      InUpdate := lKeep;
   end;
end;

function TfrmEditSuper.CompanyTax: Money;

var D,
    ForDate: Integer;
begin
    if assigned(FTransaction) then
       Fordate := FTransaction.txDate_Effective
    else if assigned(FDissection) then
       Fordate := FDissection.dtTransaction.txDate_Effective
    else begin
       Result := Double2percent(30.0);
       Exit;
    end;

    if Assigned(FClientFile) then with FClientFile.ecFields do begin
       for D  := High(ecTAX_Applies_From[tt_CompanyTax]) downto low(ecTAX_Applies_From[tt_CompanyTax]) do
          if (ecTAX_Applies_From[tt_CompanyTax][D] > 0)
          and (ForDate >= ecTAX_Applies_From[tt_CompanyTax][D]) then begin
             Result := ecTAX_Rates[tt_CompanyTax][D];
             Exit;
          end;
   end;

   // ?? Still here
   Result := Double2percent(30.0);
end;

procedure TfrmEditSuper.ECreditsChange(Sender: TObject);
begin
   if InUpdate then
      Exit;
   InUpdate := True;
   try
      Modified := not CheckCredits(False);
   finally
      InUpdate := False;
   end;
end;

procedure TfrmEditSuper.EFrankedChange(Sender: TObject);
begin
   if InUpdate then
      Exit;
   InUpdate := True;
   try
      CalcFranked(EFranked, EUnfranked);
      CheckCredits(not Modified);
   finally
      InUpdate := False;
   end;
end;

procedure TfrmEditSuper.EUnfrankedChange(Sender: TObject);
begin
   if InUpdate then
      Exit;
   InUpdate := True;
   try
      CalcFranked(EUnFranked, Efranked);
      CheckCredits(not Modified);
   finally
      InUpdate := False;
   end;
end;

procedure TfrmEditSuper.FormCreate(Sender: TObject);
begin
   ApplyStandards(Self);
   pnlTop.Color := clBorderColor;
   pnlLeft.Color := clBorderColor;
   pnlBottom.Color := clBorderColor;
   pnlRight.Color := clBorderColor;
   BKHelpSetUp(Self, BKH_Editing_Superfund_details);
end;

function TfrmEditSuper.GetDissection: PWork_Dissect_Rec;
begin
  Result := FDissection;
  if Assigned (Result) then with Result^ do begin
     dtSF_Franked := Double2Money(EFranked.Value);
     dtSF_UnFranked := Double2Money(EUnFranked.Value);
     dtSF_Franking_Credit := Double2Money(ECredits.Value);
     {$B-}
     dtSF_Edited := (dtSF_Franked <> 0)
                 or (dtSF_UnFranked <> 0)
                 or (dtSF_Franking_Credit <> 0);//this one is a bit ecademic
   end;
end;

function TfrmEditSuper.GetTransaction: PTransaction_Rec;
begin
   Result := FTransaction;

   if Assigned (Result) then with Result^ do begin
      txSF_Franked := Double2Money(EFranked.Value);
      txSF_UnFranked := Double2Money(EUnFranked.Value);
      txSF_Franking_Credit := Double2Money(ECredits.Value);
      {$B-}
      txSF_Edited := (txSF_Franked <> 0)
                  or (txSF_UnFranked <> 0)
                  or (txSF_Franking_Credit <> 0);//this one is a bit ecademic
   end;
end;

procedure TfrmEditSuper.Save;
begin
   if IsReadOnly then
      Exit;
   if Assigned(FTransaction) then
      GetTransaction
   else if Assigned(FDissection) then
      GetDissection;
end;

procedure TfrmEditSuper.SetClientFile(const Value: TEcClient);
begin
   FClientFile := Value;
end;

procedure TfrmEditSuper.SetDissection(const Value: PWork_Dissect_Rec);
var APayee: TECPayee;
begin
  FDissection := Value;
  FTransaction := nil;
  InUpdate := True;
  try
      if Assigned(FDissection) then begin
         if FDissection.dtSF_Edited then begin
            EFranked.Text := MakeAmountStr(FDissection.dtSF_Franked);
            EUnFranked.Text := MakeAmountStr(FDissection.dtSF_UnFranked);
            ECredits.Text := MakeAmountStr(FDissection.dtSF_Franking_Credit);
            Modified := not CheckCredits(False);
         end else
            Clear;
         imgCoded.Visible := FDissection.dtTransaction.txCode_Locked;
         IsReadOnly := (FDissection.dtTransaction.txLocked);
         lblAmount.caption := MakeAmountStr(FDissection.dtAmount);
         lbldate.Caption := bkDate2Str(FDissection.dtTransaction.txDate_Effective);
         lblNarrationField.Caption := FDissection.dtNarration;
         lblRef.Caption := GetFormattedReference(FDissection.dtTransaction);

         if FDissection.dtPayee_Number <> 0 then begin
            APayee := ClientFile.ecPayees.Find_Payee_Number(FDissection.dtPayee_Number);
            if Assigned(APayee) then
               lblPayeeName.Caption := APayee.pdName
            else
               lblPayeeName.Caption := ''
         end else
            lblPayeeName.Caption := '';

      end else begin
         Clear;
         lblAmount.caption := '-';
         lbldate.Caption := '-/-/-';
         lblNarrationField.Caption := '';
         lblRef.Caption := '';
         lblPayeeName.Caption := ''
      end;

      lblNarrationField.caption := lblNarrationField.Caption;
      lblNarrationField.Hint := lblNarrationField.caption;
      lblRef.Hint := lblRef.caption;

       Modified := not CheckCredits(False);
   finally
      InUpdate := False;
   end;
end;

procedure TfrmEditSuper.SetIsReadOnly(const Value: Boolean);
begin
  FIsReadOnly := Value;
  EFranked.ReadOnly := FIsReadOnly;
  EUnFranked.ReadOnly := FIsReadOnly;
  ECredits.ReadOnly := FIsReadOnly;
  btnCalc.Visible := not FIsReadOnly;
end;

procedure TfrmEditSuper.SetModified(const Value: Boolean);
begin
  FModified := Value;
  btnCalc.Enabled := FModified;
end;

procedure TfrmEditSuper.SetTransaction(const Value: PTransaction_Rec);
var APayee: TECPayee;
begin
   FTransaction := Value;
   FDissection := nil;
   InUpdate := True;
   try
      if Assigned(FTransaction) then begin
         if FTransaction.txSF_Edited then begin
            EFranked.Text := MakeAmountStr(FTransaction.txSF_Franked);
            EUnFranked.Text := MakeAmountStr(FTransaction.txSF_UnFranked);
            ECredits.Text := MakeAmountStr(FTransaction.txSF_Franking_Credit);
            Modified := not CheckCredits(False);
         end else
            Clear;
         imgCoded.Visible := FTransaction.txCode_Locked;
         IsReadOnly := (FTransaction.txLocked);
         lblAmount.caption := MakeAmountStr(FTransaction.txAmount);
         lbldate.Caption := bkDate2Str(FTransaction.txDate_Effective);
         lblNarrationField.Caption := FTransaction.txNarration;
         lblRef.Caption := GetFormattedReference(FTransaction);

         if FTransaction.txPayee_Number <> 0 then begin
            APayee := ClientFile.ecPayees.Find_Payee_Number( FTransaction.txPayee_Number );
            if Assigned(APayee) then
               lblPayeeName.Caption := APayee.pdName
            else
               lblPayeeName.Caption := ''
         end else
            lblPayeeName.Caption := '';

      end else begin
         Clear;
         lblAmount.caption := '-';
         lbldate.Caption := '-/-/-';
         lblNarrationField.Caption := '';
         lblRef.Caption := '';
         lblPayeeName.Caption := '';
      end;

      lblNarrationField.caption := lblNarrationField.Caption;
      lblNarrationField.Hint := lblNarrationField.caption;
      lblRef.Hint := lblRef.caption;

      Modified := not CheckCredits(False);
   finally
      InUpdate := False;
   end;
end;


end.
