unit BulkExtractResult;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, osFont;

type
  TfrmBulkResult = class(TForm)
    pButtons: TPanel;
    btnOK: TButton;
    Memo1: TMemo;
    btnCancel: TButton;
    btnLog: TButton;
    ShapeBorder: TShape;
    procedure btnLogClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function ShowExtractResults(Title: string; Value: TStringList; StatusOnly: Boolean = True ): TModalresult;

implementation

uses
   Globals,
   ShellAPI;

{$R *.dfm}

function ShowExtractResults(Title: string; Value: TStringList; StatusOnly: Boolean = true): TModalresult;
begin
   with TfrmBulkResult.Create(Application.MainForm) do begin
      try
         if StatusOnly then begin
            btnCancel.Caption := 'OK';
            btnOK.Visible := False;
         end else
            btnLog.Visible := False;

         Caption := Title;
         Memo1.Lines := Value;
         Result := ShowModal;
      finally
         Free;
      end;
   end;
end;


procedure TfrmBulkResult.btnLogClick(Sender: TObject);
begin
  ShellExecute(Handle,'open',pChar('notepad.exe'),PChar(ExecDir + 'BulkExport.log') ,nil,SW_SHOWNORMAL);
end;

end.
