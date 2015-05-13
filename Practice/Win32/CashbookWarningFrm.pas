unit CashbookWarningFrm;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  OSFont,
  Grids,
  StdCtrls;

type
  TFrmCashbookWarning = class(TForm)
    stgSelectedClients: TStringGrid;
    btnOK: TButton;
    lblYouHave: TLabel;
    lblProvisinalAccounts: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    fSelectClientAccounts : TStringList;
  protected
    procedure DoRebranding();
    procedure UpdateClientAccountsGrid();
  public
    property SelectClientAccounts : TStringList read fSelectClientAccounts write fSelectClientAccounts;
  end;

  procedure ShowCashbookWarning(w_PopupParent: Forms.TForm; aSelectClientAccounts : TStringList);

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  BKConst;

//------------------------------------------------------------------------------
procedure ShowCashbookWarning(w_PopupParent: Forms.TForm; aSelectClientAccounts : TStringList);
var
  CashbookWarning : TFrmCashbookWarning;
begin
  CashbookWarning := TFrmCashbookWarning.Create(Application.MainForm); // FormCreate
  try
    CashbookWarning.PopupParent          := w_PopupParent;
    CashbookWarning.PopupMode            := pmExplicit;
    CashbookWarning.SelectClientAccounts := aSelectClientAccounts;

    CashbookWarning.ShowModal;
  finally
    FreeAndNil(CashbookWarning);
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmCashbookWarning.FormCreate(Sender: TObject);
begin
  DoRebranding();
end;

//------------------------------------------------------------------------------
procedure TFrmCashbookWarning.FormShow(Sender: TObject);
begin
  UpdateClientAccountsGrid();
end;

//------------------------------------------------------------------------------
procedure TFrmCashbookWarning.DoRebranding;
begin
  lblProvisinalAccounts.caption := 'Provisional accounts are not available in ' + BRAND_CASHBOOK_NAME +
                                   ' and will not be migrated. If you''d like to delete a provisional account' +
                                   ' from ' + BRAND_FULL_PRACTICE + '. please send a delete request through to' +
                                   ' Client Services from the System | Bank | Accounts menu option.';
end;

//------------------------------------------------------------------------------
procedure TFrmCashbookWarning.UpdateClientAccountsGrid();
var
  SelIndex : integer;
begin
  stgSelectedClients.ColCount := 1;
  stgSelectedClients.ColWidths[0] := 498;

  stgSelectedClients.RowCount := SelectClientAccounts.Count;
  for SelIndex := 0 to SelectClientAccounts.Count-1 do
  begin
    stgSelectedClients.Cells[0, SelIndex] := SelectClientAccounts.Strings[SelIndex];
  end;
end;

end.
