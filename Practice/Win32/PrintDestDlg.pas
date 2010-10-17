unit PrintDestDlg;

interface

uses
  Windows, RptParams, UBatchBase, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons,
  OsFont, AccountSelectorFme, ComCtrls, ExtCtrls;


type
  TDlgPrintDest = class(TForm)
    pBtn: TPanel;
    btnPreview: TButton;
    btnPrint: TButton;
    btnCancel: TButton;
    btnFile: TButton;
    btnSave: TBitBtn;
    fmeAccountSelector1: TfmeAccountSelector;
    lDestination: TLabel;
    procedure btnPreviewClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    FHelpID : integer;
    FRPTParameters: TRPTParameters;
    FAccountFilter: TAccountSet;
    procedure SetUpHelp;
    procedure SetRPTParameters(const Value: TRPTParameters);
    procedure SetAccountFilter(const Value: TAccountSet);
    function Verify: Boolean; 
    { Private declarations }
  public
    { Public declarations }
    property RPTParameters: TRPTParameters read FRPTParameters write SetRPTParameters;
    property AccountFilter: TAccountSet read FAccountFilter write SetAccountFilter;
  end;

  function SelectReportDest( ACaption: string;
                             Params: TRPTParameters;
                             HelpCtx: integer = 0;
                             aAccountFilter: TAccountSet = []): boolean;

  function SimpleSelectReportDest( ACaption: string;
                             var Btn: Integer;
                             HelpCtx: integer = 0): boolean;

//******************************************************************************
implementation

{$R *.DFM}

uses
  WarningMoreFrm,
  baObj32,
  ReportDefs,
  dlgAddFavourite,
  bkXPThemes,
  bkHelp,
  Globals,
  StdHints,
  CustomDocEditorFrm;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDlgPrintDest.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  SetUpHelp;

  //favorite reports functionality is disabled in simpleUI
  if Active_UI_Style = UIS_Simple then
     btnSave.Hide;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDlgPrintDest.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   btnPreview.Hint  := STDHINTS.PreviewHint;
   btnPrint.Hint    := STDHINTS.PrintHint;
end;


function TDlgPrintDest.Verify: Boolean;
var AnyAccountsSelected: Boolean;
    i: integer;
    ba: TBank_Account;
begin
   if FAccountFilter = [] then
      Result := True
   else  begin
      Result := False;
       //Accounts selected
      AnyAccountsSelected := false;
      for i := 0 to (fmeAccountSelector1.AccountCheckBox.Items.Count - 1) do
         if fmeAccountSelector1.AccountCheckBox.Checked[i] then begin
            AnyAccountsSelected := true;
            break;
         end;

      if not AnyAccountsSelected then begin
         HelpfulWarningMsg( 'You have not selected any accounts to use.  Please select at least one.', 0);
         fmeAccountSelector1.chkAccounts.SetFocus;
         Exit;
      end;

      // While we are here...
      with MyClient do begin
      for i := 0 to Pred( clBank_Account_List.ItemCount) do begin
         ba := clBank_Account_List.Bank_Account_At(i);
         ba.baFields.baTemp_Include_In_Report := false;
      end;
      if assigned(FRptParameters) then
         FRptParameters.AccountList.Clear;
         //now turn back on accounts which are selected
         for i := 0 to Pred(fmeAccountSelector1.AccountCheckBox.Items.Count) do begin
            ba := TBank_Account(fmeAccountSelector1.AccountCheckBox.Items.Objects[ i]);
            ba.baFields.baTemp_Include_In_Report := fmeAccountSelector1.AccountCheckBox.Checked[ i];
              if fmeAccountSelector1.AccountCheckBox.Checked[ i] then
                if assigned(FRptParameters) then
                   FRptParameters.AccountList.Add(ba);
         end;
      end;

      Result := True;
   end;

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TDlgPrintDest.SetAccountFilter(const Value: TAccountSet);
begin
  FAccountFilter := Value;
  if FAccountFilter = [] then begin
     fmeAccountSelector1.Visible := False;
     lDestination.Visible := True;
     Self.Height := 100;
  end else begin
     fmeAccountSelector1.LoadAccounts(MyClient, FAccountFilter);
     fmeAccountSelector1.Visible := True;
     lDestination.Visible := False;
  end;
end;

procedure TDlgPrintDest.SetRPTParameters(const Value: TRPTParameters);
var i: Integer;
    d: Integer;
begin
  FRPTParameters := Value;
  if Assigned(FRptParameters) then begin
     FRptParameters.SetDlgButtons(BtnPreview,BtnFile,BtnSave,BtnPrint);
     if Assigned(FRptParameters.RptBatch) then
        Caption := Caption + ' [' + FRptParameters.RptBatch.Name + ']';

     FRptParameters.AccountFilter :=  AccountFilter;
     if FRptParameters.AccountList.Count <> 0 then begin
        for i := 0 to Pred( FRptParameters.AccountList.Count) do begin
         // Over time could get out of step...
         d := fmeAccountSelector1.AccountCheckBox.Items.IndexOfObject(FRptParameters.AccountList[i]);
         if d >= 0 then
            fmeAccountSelector1.AccountCheckBox.checked[d]:= True
        end
     end else
        fmeAccountSelector1.btnSelectAllAccounts.Click;


  end else
     BtnSave.Hide;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDlgPrintDest.btnPreviewClick(Sender: TObject);
begin
   if Verify then begin
      RPTParameters.RunBtn := BTN_PREVIEW;
      Close;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDlgPrintDest.btnPrintClick(Sender: TObject);
begin
   if Verify then begin
      RPTParameters.RunBtn := BTN_PRINT;
      Close;
   end;
end;

procedure TDlgPrintDest.btnSaveClick(Sender: TObject);
begin
   if not RPTParameters.CheckForBatch(Self.Caption, Self.Caption) then
      Exit;

   if (RptParameters.ReportType = Integer(REPORT_CUSTOM_DOCUMENT)) then begin
      RptParameters.RunBtn := BTN_SAVE;
      Close;
   end else begin
     if Verify then begin
        RptParameters.SaveNodeSettings;
        if AccountFilter <> [] then
           RptParameters.SaveBatchAccounts;

        RptParameters.RunBtn := BTN_SAVE;
        Close;
     end;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDlgPrintDest.btnFileClick(Sender: TObject);
begin
   if Verify then begin
      RptParameters.RunBtn := BTN_FILE;
      Close;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDlgPrintDest.btnCancelClick(Sender: TObject);
begin
   RptParameters.RunBtn := BTN_NONE;
   Close;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SelectReportDest( ACaption: string;
                           Params: TRPTParameters;
                           HelpCtx: integer = 0;
                           aAccountFilter: TAccountSet = []): boolean;
begin
//  Result := False;
  Params.RunBtn := BTN_NONE;
  with TDlgPrintDest.Create(Application.MainForm) do begin
    try
       Caption := ACaption;

       AccountFilter := aAccountFilter;
       RPTParameters := Params;

       FHelpID := HelpCtx;

       ShowModal;

       Result := (Params.RunBtn <> BTN_NONE);

    finally
       Free;
    end;
  end;
end;

function SimpleSelectReportDest( ACaption: string;
                             var Btn: Integer;
                             HelpCtx: integer = 0): boolean;
var lparams: TRPTParameters;
begin
  lparams:= TRPTParameters.Create(ord(Report_Last),nil,nil);
  with TDlgPrintDest.Create(Application.MainForm) do begin
    try
       Caption := ACaption;
       RPTParameters := LParams;

       FHelpID := HelpCtx;
       BtnSave.Visible := False;
       AccountFilter := [];

       ShowModal;

       Btn := LParams.RunBtn;
       Result := (LParams.RunBtn <> BTN_NONE);
    finally
       Free;
       lparams.Free;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDlgPrintDest.FormShow(Sender: TObject);
begin
   BKHelp.BKHelpSetUp( Self, FHelpID);
end;

end.
