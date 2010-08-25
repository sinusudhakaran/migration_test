unit UseBudgetedDataDlg;
//------------------------------------------------------------------------------
{
   Title:       Budget Data Question Dialog

   Description: This dialog allows the user to select if the financial report
                should use budgeted data for periods where no actual data
                is available

   Author:      Matthew Hopkins  Jun 2002

   Remarks:     Called from CashflowOptionsDlg

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, clObj32,
  OsFont;

type
  TdlgUseBudgetedData = class(TForm)
    lblMessage: TLabel;
    lblBudget: TLabel;
    btnYes: TButton;
    btnNo: TButton;
    cmbBudget: TComboBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function UseBudgetedFigures( const aClient : TClientObj; AskForBudget : boolean; LastPeriod : Integer;
                             RequestPeriod : Integer; var BudgetName : string; var BudgetDate: Integer) : boolean;

//******************************************************************************
implementation

uses
  ovcDate,
  bkDateUtils,
  BUDOBJ32,
  bkXPThemes,
  StDateSt;

{$R *.dfm}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function UseBudgetedFigures( const aClient : TClientObj; AskForBudget : boolean; LastPeriod : Integer;
                             RequestPeriod : Integer; var BudgetName : string; var BudgetDate: Integer) : boolean;
var
  i : integer;
  LastPeriodStr : String;
  RequestPeriodStr : String;
  Budget : TBudget;
  clD, clM, clY  : Integer;
  buD, buM, buY  : Integer;
begin
  result := false;

  if (LastPeriod = 0) then
    LastPeriodStr := ''
  else
    LastPeriodStr := StDateToDateString( 'dd nnn yy', LastPeriod, false);
  if (RequestPeriod = 0) then
    RequestPeriodStr := ''
  else
    RequestPeriodStr := StDateToDateString( 'dd nnn yy', RequestPeriod, false);

  with TdlgUseBudgetedData.Create(Application.MainForm) do begin
    try
      if LastPeriodStr <> '' then
      begin
        lblMessage.caption := 'Actual data is only available up to ' + LastPeriodStr +
                            ' however you have selected to report up to ' + RequestPeriodStr +
                            '. ' + #13#13 +
                            'Do you wish to use budgeted data for the remaining periods?';
      end
      else
      begin
        lblMessage.caption := 'You have selected to report up to ' + RequestPeriodStr +
                            ', however there is no actual data to use.' + #13#13 +
                            'Do you wish to use budgeted data instead?';
      end;

      if AskForBudget then begin
        //fill budgets list
        cmbBudget.Items.Clear;
        with aClient do begin
          StDateToDMY(clFields.clReporting_Year_Starts, clD, clM, clY );
          for i:= clBudget_List.ItemCount-1 downto 0 do
          begin
            Budget := clBudget_List.Budget_At(i);
            StDateToDMY(Budget.buFields.buStart_Date, buD, buM, buY );

            if (buM = clM) then
              cmbBudget.Items.AddObject( Budget.buFields.buName +
                                         ' (' + bkDate2Str( Budget.buFields.buStart_Date) +
                                         ')' , Budget);
          end;
          //set default
          if (Budgetname  ='') then
          begin
            if (cmbBudget.Items.Count > 0) then
              cmbBudget.ItemIndex := 0;
          end else
            cmbBudget.ItemIndex := cmbBudget.Items.IndexOf( BudgetName);
        end;
      end
      else begin
        lblBudget.visible := false;
        cmbBudget.visible := false;
      end;

      //-----------------------
      if (cmbBudget.Items.Count > 0) then
      begin
        if (ShowModal = mrYes) then begin
          if AskForBudget then begin
            if (cmbBudget.Items.Count > 0) and (cmbBudget.ItemIndex >= 0) then
            begin
              BudgetName   := TBudget( cmbBudget.Items.Objects[cmbBudget.ItemIndex]).buFields.buName;
              BudgetDate   := TBudget( cmbBudget.Items.Objects[cmbBudget.ItemIndex]).buFields.buStart_Date;
            end
            else
            begin
              BudgetName   := '';
              BudgetDate   := -1;
            end;
          end;
          result := true;
        end;
      end;
      //-----------------------
    finally
      Free;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgUseBudgetedData.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
end;

end.
