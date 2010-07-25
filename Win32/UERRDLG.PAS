unit UErrDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// dialog to use for unexpected errors }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  OSFont;

type
  TdlgUError = class(TForm)
    MemoError: TMemo;
    Label2: TLabel;
    lblSupport: TLabel;
    btnClose: TButton;
    lblVersion: TLabel;
    lblTitle: TLabel;
    imgError: TImage;
    lblMessage: TLabel;
    bvlDividingLine: TBevel;
    Shape1: TShape;
    btnCopyError: TButton;
    lblSupportContact1: TLabel;
    lblSupportContact2: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure btnCopyErrorClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//******************************************************************************
implementation
{$R *.DFM}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgUError.btnCloseClick(Sender: TObject);
begin
    Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgUError.btnCopyErrorClick(Sender: TObject);
begin
  memoError.SelectAll;
  memoError.CopyToClipboard;
  memoError.SelLength := 0;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
