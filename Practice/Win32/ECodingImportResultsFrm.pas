unit ECodingImportResultsFrm;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Remarks:

   Author:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, WinUtils,
  bkXPThemes,
  OsFont;

type
  TfrmEcodingImportResults = class(TForm)
    lblImported: TLabel;
    lblNew: TLabel;
    pnlRejects: TPanel;
    lblRejected: TLabel;
    btnView: TButton;
    InfoBmp: TImage;
    lblFile: TLabel;
    Label1: TLabel;
    btnYes: TButton;
    btnNo: TButton;
    procedure btnViewClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    filename : string;
  public
    { Public declarations }
  end;

  function ConfirmImport( fromFile : string;
                          importCount : integer; newCount : integer;
                          rejectedCount : integer; rejectFilename : string;
                          importType: string = 'transaction(s)';
                          importVerb: string = 'imported') : boolean;

//******************************************************************************
implementation
uses
   ShellAPI;
{$R *.DFM}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ConfirmImport( fromFile : string;
                        importCount : integer; newCount : integer;
                        rejectedCount : integer; rejectFilename : string;
                        importType: string = 'transaction(s)';
                        importVerb: string = 'imported') : boolean;
begin
   with TfrmEcodingImportResults.Create(Application.MainForm) do begin
      try
         lblFile.caption     := 'From File: ' + ExtractFilename( FromFile);

         lblImported.caption := inttostr( importCount) + ' ' + importType + ' will be ' + importVerb;
         if newcount = -1 then
          lblNew.Visible := False
         else
          lblNew.caption      := inttostr( newcount)    + ' new ' + importType;

         lblRejected.caption := inttostr( rejectedCount) + ' ' + importType + ' rejected';
         filename            := RejectFilename;
         pnlRejects.visible  := ( rejectedCount > 0);

         if rejectedCount > 0 then begin
            btnYes.Default := false;
            btnNo.Default := true;
         end;

         result := ( ShowModal = mrYes);
      finally
         free;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmEcodingImportResults.btnViewClick(Sender: TObject);
begin
   if BKFileExists( filename) then
      ShellExecute(Handle,'open',pChar('notepad.exe'),PChar( filename) ,nil,SW_SHOWNORMAL);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmEcodingImportResults.Button1Click(Sender: TObject);
begin
   Close;
end;
procedure TfrmEcodingImportResults.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
