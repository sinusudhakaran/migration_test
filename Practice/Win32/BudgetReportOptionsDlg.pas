unit BudgetReportOptionsDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  RptParams,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  budobj32, Buttons,
  OSFont;

type
  TdlgBudgetReportOptions = class(TForm)
    gbxOptions: TGroupBox;
    lblDivision: TLabel;
    chkChartCodes: TCheckBox;
    cmbDivision: TComboBox;
    btnPreview: TButton;
    btnPrint: TButton;
    btnCancel: TButton;
    gbxBudget: TGroupBox;
    Label1: TLabel;
    cmbBudget: TComboBox;
    btnFile: TButton;
    chkGST: TCheckBox;
    BtnSave: TBitBtn;
    chkQuantities: TCheckBox;
    btnEmail: TButton;
    procedure btnPreviewClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    function CheckOk : Boolean;
    procedure btnEmailClick(Sender: TObject);
  private
    { Private declarations }
    Pressed : integer;
    FParams: TGenRptParameters;

    procedure SetupHelp;
    procedure LoadBudgetList;
    procedure SetParams(const Value: TGenRptParameters);
{$IFDEF SmartBooks}
    procedure LoadDivisionList;
{$ENDIF}
  public
    property RptParams: TGenRptParameters read FParams write SetParams;
    { Public declarations }
  end;

function GetBudgetOptions(Params: TGenRptParameters ) : integer;
//******************************************************************************
implementation

uses
   Globals,
   bkDateUtils,
   BKHelp,
   bkXPThemes,
   WarningMoreFrm,
   LogUtil,
   UBatchBase,
   BkConst,
   stdHints;

{$R *.DFM}

const
   UnitName = 'BUDGETREPORTOPTIONSDLG';

var
   DebugMe : boolean = false;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgBudgetReportOptions.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm(Self);
{$IFDEF SmartBooks}
   cmbBudget.Enabled     := false;
   lblDivision.Visible   := true;
   cmbDivision.Visible   := true;
{$ENDIF}
   SetupHelp;
   chkGST.Caption := '&' + MyClient.TaxSystemNameUC + ' Inclusive';
   if MyClient.clFields.clCountry = whUK then
      chkGST.Hint        := STDHINTS.RptIncludeVATHint;

   if Active_UI_Style = UIS_Simple then
      btnSave.Hide;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgBudgetReportOptions.SetParams(const Value: TGenRptParameters);
begin
  FParams := Value;
  if assigned(FParams) then begin
     FParams.SetDlgButtons(BtnPreview,BtnFile,BtnSave,BtnPrint);
     if Assigned(FParams.RptBatch) then
        Caption := Caption + ' [' + FParams.RptBatch.Name + ']';
  end else
     BtnSave.Hide;
end;

procedure TdlgBudgetReportOptions.SetupHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext :=  BKH_Budget_report;

   //Components
   cmbBudget.Hint   := 'Select a Budget to print|'+
                       'Select which Budget you want to print';

   chkChartCodes.Hint := STDHINTS.RptIncludeCodesHint;

   chkGST.Hint        := STDHINTS.RptIncludeGSTHint;

   btnPreview.Hint    := STDHINTS.PreviewHint;

   btnPrint.Hint      := STDHINTS.PrintHint;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgBudgetReportOptions.LoadBudgetList;
var
   i : integer;
begin
   with MyClient, cmbBudget do begin
      Items.Clear;
      for i := clBudget_List.ItemCount-1 downto 0 do
         with clBudget_List.Budget_At(i) do begin

            Items.AddObject( buFields.buName+'   ('+ bkDate2Str(buFields.buStart_Date)+')',
                             clBudget_List.Budget_At(i));
         end;
      if Items.Count > 0 then
         ItemIndex := 0; //Latest selected by default

{$IFDEF SmartBooks}
      ItemIndex := 0; //Only one budget for SmartBook
{$ENDIF}
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{$IFDEF SmartBooks}
procedure TdlgBudgetReportOptions.LoadDivisionList;
var
   i : integer;
begin
   with cmbDivision do begin
     items.clear;
     items.add('All');

     for i := 1 to Max_Divisions do
       with MyClient.clFields do begin
          if clDivision_Names[i] <> '' then
            items.add(clDivision_Names[i]);
       end;

     ItemIndex := 0;
   end;
end;
{$ENDIF}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgBudgetReportOptions.btnPreviewClick(Sender: TObject);
begin
   if CheckOk then begin
      Pressed := BTN_PREVIEW;
      Close;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgBudgetReportOptions.btnPrintClick(Sender: TObject);
begin
   if CheckOk then begin
      Pressed := BTN_PRINT;
      Close;
   end;
end;
procedure TdlgBudgetReportOptions.btnSaveClick(Sender: TObject);
begin
   if CheckOk then begin
      if not RptParams.CheckForBatch(Self.Caption) then
         Exit;

      Pressed := BTN_SAVE;
      Close;
   end
end;

function TdlgBudgetReportOptions.CheckOk: Boolean;
begin
   if cmbBudget.ItemIndex > -1 then
     Result := True
   else begin
      HelpfulWarningMsg( 'You have not selected which Budget you want to print. '+
                         'Please select one.',0);
      result := False;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgBudgetReportOptions.btnCancelClick(Sender: TObject);
begin
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetBudgetOptions( Params : TGenRptParameters ) : integer;
//returns which button was pressed
var
  BudgetReportOptions : TDlgBudgetReportOptions;
begin
  result := BTN_NONE;

  if not assigned( Params.Client ) then exit;
  BudgetReportOptions := TDlgBudgetReportOptions.Create(Application.MainForm);
  with BudgetReportOptions do begin
     try
        chkChartCodes.Checked := Params.ChartCodes;
        chkGST.Checked        := Params.ShowGST;
        chkQuantities.Checked := Params.ShowBudgetQuantities;
        RptParams := Params;
        LoadBudgetList;

{$IFDEF SmartBooks}
        LoadDivisionList;
{$ENDIF}
        Pressed := BTN_NONE;
        if Params.BatchSetup then begin
           cmbBudget.ItemIndex := cmbBudget.Items.IndexOfObject(Params.Budget);
        end else begin
           if Params.Budget <> nil then
              cmbBudget.ItemIndex := cmbBudget.Items.IndexOfObject(Params.Budget);
        end;

        ShowModal;

        if Pressed in [ BTN_PRINT, BTN_PREVIEW, BTN_FILE, BTN_SAVE ] then
          with params do
          begin
             Budget := TBudget( cmbBudget.Items.objects[ cmbBudget.ItemIndex ]);
             Division := 0;
             ChartCodes := chkChartCodes.Checked;
             ShowGST := chkGST.Checked;
             ShowBudgetQuantities := chkQuantities.Checked;
{$IFDEF SmartBooks}
             Division := cmbDivision.ItemIndex;
{$ENDIF}
          end;
        if params.BatchSave (Pressed) then begin

           Params.SaveNodeSettings;
           {if Params.WasNewBatch then
           else } params.RunBtn := BTN_NONE;
        end;
        result := params.RunBtn;
     finally
        Free;
     end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgBudgetReportOptions.btnEmailClick(Sender: TObject);
begin
   if CheckOk then begin
      Pressed := BTN_EMAIL;
      Close;
   end;
end;

procedure TdlgBudgetReportOptions.btnFileClick(Sender: TObject);
begin
   if CheckOk then begin
      Pressed := BTN_FILE;
      Close;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

initialization
   DebugMe := DebugUnit(UnitName);
end.
