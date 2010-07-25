unit GenBudgetDlg;

//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  OSFont;

const
  ytLastYear = 0;
  ytThisYear = 1;

  btCashflow = 0;
  btProfit   = 1;
  //btBalanceSheet = 2

type
  TdlgGenBudget = class(TForm)
    Label1: TLabel;
    btnGenerate: TButton;
    btnCancel: TButton;
    InfoBmp: TImage;
    Label3: TLabel;
    Panel1: TPanel;
    pnlFigures: TPanel;
    Label2: TLabel;
    rbThisYear: TRadioButton;
    rbLastYear: TRadioButton;
    pnlType: TPanel;
    Label4: TLabel;
    rbCashflow: TRadioButton;
    rbProfit: TRadioButton;
    Label5: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function GetGenerateBudgetOptions( Country : Byte; var Year : byte; var BudgetType : byte) : boolean;

//******************************************************************************
implementation

uses
  BKHelp,
  Globals, bkXPThemes,
  CountryUtils;

{$R *.DFM}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgGenBudget.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);
   SetUpHelp;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgGenBudget.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := BKH_Creating_budgets;
   //Components
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetGenerateBudgetOptions( Country : Byte; var Year : byte; var BudgetType : byte) : boolean;
var
  GenBudget : TDlgGenBudget;
begin
  result := false;
  GenBudget := TDlgGenBudget.Create(Application.MainForm);
  with GenBudget do
  begin
    With Label3 do Caption := Localise( Country, Caption );
    try
      BKHelpSetUp(GenBudget, BKH_Creating_budgets);
      if ShowModal = mrOK then begin
        if rbThisYear.Checked then
          Year := ytThisYear
        else
          Year := ytLastYear;

        if rbCashflow.Checked then
          BudgetType  := btCashflow
        else
          BudgetType  := btProfit;

        result := true;
      end;
    finally
      Free;
    end;
  end;
end;

end.
