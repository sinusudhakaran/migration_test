unit FrmChartExportAccountCodeErrors;

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
  OSFont, StdCtrls;

type
  TfrmChartExportAccountCodeErrors = class(TForm)
    LstErrors: TListBox;
    btnOk: TButton;
    lblErrors: TLabel;
    lblErrors2: TLabel;
  private
    fErrors : TStringList;
  public
    function Execute : boolean;

    property Errors : TStringList read fErrors write fErrors;
  end;

  procedure ShowChartExportAccountCodeErrors(w_PopupParent: Forms.TForm; aErrors : TStringList);

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

//------------------------------------------------------------------------------
procedure ShowChartExportAccountCodeErrors(w_PopupParent: Forms.TForm; aErrors : TStringList);
var
  MyDlg : TfrmChartExportAccountCodeErrors;
begin
  MyDlg := TfrmChartExportAccountCodeErrors.Create(Application.mainForm);
  try
    MyDlg.PopupParent := w_PopupParent;
    MyDlg.PopupMode   := pmExplicit;
    MyDlg.Errors      := aErrors;

    //BKHelpSetUp(MyDlg, BKH_Setting_up_BankLink_users);
    MyDlg.Execute;
  finally
    FreeAndNil(MyDlg);
  end;
end;

{ TfrmChartExportAccountCodeErrors }
//------------------------------------------------------------------------------
function TfrmChartExportAccountCodeErrors.Execute: boolean;
var
  Index : integer;
begin
  Result := false;
  LstErrors.Clear;
  for Index := 0 to fErrors.Count - 1 do
  begin
    LstErrors.AddItem(fErrors.Strings[Index], nil);
  end;

  ShowModal;
  Result := true;
end;

end.
