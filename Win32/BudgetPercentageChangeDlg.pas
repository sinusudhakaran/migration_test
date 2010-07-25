unit BudgetPercentageChangeDlg;
//------------------------------------------------------------------------------
{
   Title:

   Author:      Matthew Hopkins Jan 2004

   Description: Dialog for selecting which cells to increase/decrease by
                a specified percentage

   Remarks:

   Revisions:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, RzEdit, RzSpnEdt, ExtCtrls, ovcbase, ovcef,
  ovcpb, ovcnf,
  OSFont;

type
  TCellTypes = ( ctCell, ctRow, ctColumn, ctAll);

type
  TdlgBudgetPercentageChange = class(TForm)
    btnCancel: TButton;
    btnOK: TButton;
    gbFigures: TGroupBox;
    rbIncreaseFigures: TRadioButton;
    rbDecreaseFigures: TRadioButton;
    Label1: TLabel;
    Label2: TLabel;
    nPercent: TOvcNumericField;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    rbAll: TRadioButton;
    rbCell: TRadioButton;
    rbColumn: TRadioButton;
    rbRow: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure rbCellClick(Sender: TObject);
    procedure rbColumnClick(Sender: TObject);
    procedure rbRowClick(Sender: TObject);
    procedure rbAllClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure nPercentKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    SelectedType : TCellTypes;
  public
    { Public declarations }
  end;

  function GetPercentage( var Percentage : double; var CellsToChange : TCellTypes) : boolean;

implementation
uses
  bkXPThemes,
  WarningmoreFrm;

{$R *.dfm}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetPercentage( var Percentage : double; var CellsToChange : TCellTypes) : boolean;
//- - - - - - - - - - - - - - - - - - - -
//
// Purpose:     function returns the users choices of how to vary the cells
//
// Parameters:  Percentage - returns the percentage selected to 1 d.p
//
//              CellsToChange - can be cell, column, row, or all cells
//
// Result:      True indicates user clicked ok
//- - - - - - - - - - - - - - - - - - - -
begin
  result := false;

  with TdlgBudgetPercentageChange.Create(Application.MainForm) do
  begin
    try
      nPercent.AsFloat := 0;

      if ShowModal = mrOK then
      begin
        CellsToChange := SelectedType;
        if rbIncreaseFigures.Checked then
          Percentage := nPercent.AsFloat
        else
          Percentage := nPercent.AsFloat * - 1;
        result := true;
      end;
    finally
      Free;
    end;
  end;
end;


procedure TdlgBudgetPercentageChange.FormCreate(Sender: TObject);
begin
  SelectedType := ctCell;
  bkXPThemes.ThemeForm( Self);
end;

procedure TdlgBudgetPercentageChange.rbCellClick(Sender: TObject);
begin
  SelectedType := ctCell;
end;

procedure TdlgBudgetPercentageChange.rbColumnClick(Sender: TObject);
begin
  SelectedType := ctColumn;
end;

procedure TdlgBudgetPercentageChange.rbRowClick(Sender: TObject);
begin
  SelectedType := ctRow;
end;

procedure TdlgBudgetPercentageChange.rbAllClick(Sender: TObject);
begin
  SelectedType := ctAll;
end;

procedure TdlgBudgetPercentageChange.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  p : double;
begin
  if ModalResult = mrOK then
  begin
    p := nPercent.AsFloat;
    if ( p < 0) or ( p > 1000) then
    begin
      HelpfulWarningMsg( 'Please select a value between 0 and 1000%', 0);
      CanClose := false;
    end;
  end;
end;

procedure TdlgBudgetPercentageChange.nPercentKeyPress(Sender: TObject;
  var Key: Char);
begin
  if key = '-' then
    key := #0;
end;

end.

