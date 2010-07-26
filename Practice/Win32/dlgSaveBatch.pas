unit dlgSaveBatch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, clObj32, ExtCtrls;

type
  TSaveBatchDlg = class(TForm)
    Button2: TButton;
    Panel1: TPanel;
    Label2: TLabel;
    EName: TEdit;
    Button1: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
     function MakeFilename(Value: string): string;
    { Public declarations }
  end;

function GetBatchDestination(ForClient: TClientObj):string;

implementation


{$R *.dfm}

function GetBatchDestination(ForClient: TClientObj):string;
begin
   Result := '';
   with TSaveBatchDlg.Create(nil) do try
      if assigned(ForClient) then
         EName.Text := MakeFilename(ForClient.clFields.clName)
      else
         EName.Text := MakeFilename('Batch');

      if ShowModal = mrOk then
         Result := EName.Text;
   finally
      Free;
   end;
end;

{ TSaveBatchDlg }

procedure TSaveBatchDlg.Button1Click(Sender: TObject);
begin
    ModalResult := mrCancel;
end;

procedure TSaveBatchDlg.Button2Click(Sender: TObject);
begin
   // Check file...
   ModalResult := mrOK;
end;

function TSaveBatchDlg.MakeFilename(Value: string): string;
var C: integer;
    D: string;
begin
   D := FormatDateTime('_ddmmyyyy',Date);
   Result := Value + D + '.pdf';
   C := 0;
   while fileexists(Result) do begin
      Inc(C);
      Result := Value +  D + '(' + IntTostr(C) + ').pdf';
   end;

end;

end.
