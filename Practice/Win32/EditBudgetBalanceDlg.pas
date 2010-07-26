unit EditBudgetBalanceDlg;
//------------------------------------------------------------------------------
{
   Title:       Edit Estimated Opening Bank Balance

   Description:

   Remarks:

   Author:      Matthew Hopkins Nov 2001

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OvcBase, OvcEF, OvcPB, OvcNF, MoneyDef,
  bkXPThemes,
  OsFont;

type
  TdlgEditBudgetBalance = class(TForm)
    Label1: TLabel;
    nBalance: TOvcNumericField;
    lblDate: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    OvcController1: TOvcController;
    cmbBalance: TComboBox;
    procedure nBalanceKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function EditBudgetOpeningBalance( const OpeningDate : integer; var Balance : Money) : boolean;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
{$R *.DFM}
uses
   bkDateUtils,
   GenUtils;

const
  BAL_INFUNDS = 0;
  BAL_OVERDRAWN = 1;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEditBudgetBalance.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);
end;

procedure TdlgEditBudgetBalance.nBalanceKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (key = vk_subtract) or (key = 189) then key := 0;  {ignore minus key}
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function EditBudgetOpeningBalance( const OpeningDate : integer; var Balance : Money) : boolean;
var
   Amount : Money;
begin
   result := false;

   with TDlgEditBudgetBalance.Create(Application.MainForm) do begin
      try
         lblDate.Caption := 'Estimated Balance as at ' + BkDate2Str( OpeningDate);
         nBalance.AsFloat := Abs( Money2Double( Balance));
         if ( Balance > 0) then
           cmbBalance.ItemIndex := BAL_OVERDRAWN
         else
           cmbBalance.ItemIndex := BAL_INFUNDS;

         //------------------
         if ShowModal = mrOK then begin
            Amount := Double2Money(nBalance.AsFloat);
            Amount := Abs(Amount);
            case cmbBalance.itemIndex of
               BAL_INFUNDS : Amount := -Amount;
               BAL_OVERDRAWN : ;
            end;
            Balance := Amount;

            result := true;
         end;

      finally
         Free;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
