//------------------------------------------------------------------------------
//
// Title:       Select list dialog
//
// Description: Provides a generic list dialog.
//
//  Author         Version Date       Comments
//  Michael Foot   1.00    02/04/2003 Initial version
//
//------------------------------------------------------------------------------
unit SelectListDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls,
  OSFont;

type
  TdlgSelectList = class(TForm)
    lvList: TListView;
    pnlFooter: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    procedure lvListDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//******************************************************************************
implementation

{$R *.dfm}

procedure TdlgSelectList.lvListDblClick(Sender: TObject);
begin
  btnOK.Click;
end;

end.
