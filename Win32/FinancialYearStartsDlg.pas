//------------------------------------------------------------------------------
//
// Title:       Financial year starts dialog
//
// Description: Used by the client manager to change the financial year start date
//
//  Author         Version Date       Comments
//  Michael Foot   1.00    03/04/2003 Initial version
//
//------------------------------------------------------------------------------
unit FinancialYearStartsDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, RzEdit, RzSpnEdt;

type
  TdlgFinancialYearStarts = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    cmbStartMonth: TComboBox;
    spnStartYear: TRzSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    btnOK: TButton;
    btnCancel: TButton;

    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgFinancialYearStarts: TdlgFinancialYearStarts;

function ChangeFinancialYearStart(var StartDate : LongInt) : Boolean;

implementation

uses
  BKConst,
  BKHelp,
  bkXPThemes,
  StDate,
  Globals;

{$R *.dfm}

function ChangeFinancialYearStart(var StartDate : LongInt) : Boolean;
var
  i : Integer;
  Day, Month, Year : Integer;
begin
  Result := False;
  dlgFinancialYearStarts := TdlgFinancialYearStarts.Create(Application);
  if Assigned(dlgFinancialYearStarts) then
  begin
    try
      with dlgFinancialYearStarts do
      begin
        BKHelpSetUp(dlgFinancialYearStarts, BKH_Changing_the_financial_year_start_date);
        //load report year starts months
        cmbStartMonth.Items.Clear;
        for i := ( moMin + 1) to moMax do
          cmbStartMonth.Items.Add( moNames[ i]);
        //set default
        StDateToDMY( StartDate, Day, Month, Year);
        spnStartYear.Value := Year;
        cmbStartMonth.ItemIndex := Month - 1;

        ShowModal;

        if (ModalResult = mrOK) then
        begin
          Month := cmbStartMonth.ItemIndex + 1;
          Year := Trunc(spnStartYear.Value);
          StartDate := DMYtoStDate(1, Month, Year, BKDATEEPOCH);
          Result := True;
        end;

      end;
    finally
      dlgFinancialYearStarts.Free;
    end;
  end;
end;

procedure TdlgFinancialYearStarts.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
end;

end.
