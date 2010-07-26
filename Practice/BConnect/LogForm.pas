unit LogForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  RzButton, ExtCtrls, RzPanel, StdCtrls, RzEdit;

type
  TfrmLog = class(TForm)
    memoLog: TRzMemo;
    RzPanel1: TRzPanel;
    RzButton1: TRzButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

end.
