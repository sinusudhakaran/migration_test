unit MainFrm;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
   Title:     Notes CD Setup

   Written:   25 July 2006
   Authors:   Steve Teare

   Purpose:   For new Notes Master CD

   Notes:     Copied from the master BK CD setup
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RzButton, ExtCtrls, jpeg;

type
  TfrmMain = class(TForm)
    btnBooks: TRzBitBtn;
    btnUpdate: TRzBitBtn;
    btnClose: TRzButton;
    lblHint: TLabel;
    btnExplore: TRzBitBtn;
    imgLogin: TImage;
    procedure FormCreate(Sender: TObject);
    procedure btnExploreClick(Sender: TObject);
    procedure btnBooksClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    CDDrive : string;
    procedure DisplayHint(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

//******************************************************************************
implementation

{$R *.DFM}
{$R WinXP.RES}

uses
   ShellAPI;

procedure TfrmMain.DisplayHint(Sender: TObject);
begin
  lblHint.Caption := GetLongHint(Application.Hint);
  if lblHint.Caption = '' then
    lblHint.Caption := Self.Hint;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Application.OnHint := DisplayHint;
  CDDrive            := ExtractFileDrive( Application.ExeName);

  Self.Hint          := 'Please choose the appropriate version to install:';
  btnBooks.Hint      := 'Choosing this option will install BankLink Notes.';
  btnUpdate.Hint     := 'Choosing this option will update an existing installation of BankLink Notes.';
  btnExplore.Hint    := 'View the files on the CD-ROM.';
  lblHint.Caption    := Self.Hint;
end;

procedure TfrmMain.btnExploreClick(Sender: TObject);
begin
  ShellExecute(Handle,'open',pChar('Explorer'),pChar(CDDrive) ,nil,SW_SHOWNORMAL);
end;

procedure TfrmMain.btnBooksClick(Sender: TObject);
begin
  ShellExecute(Handle,'open',pChar( CDDrive + '\SOFTWARE\NOTES\SETUP.EXE'),nil ,nil,SW_SHOWNORMAL);
end;

procedure TfrmMain.btnUpdateClick(Sender: TObject);
begin
   ShellExecute(Handle,'open',pChar( CDDrive + '\SOFTWARE\UPDATES\SETUP.EXE'),nil ,nil,SW_SHOWNORMAL);
end;

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
   Close;
end;

end.
