unit MainFrm;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
   Title:     Books CD Setup

   Written:   28 March 2006
   Authors:   Steve Teare

   Purpose:   For new Books Master CD

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
{ $ R WinXP.RES}

uses
   ShellAPI, countryfrm;

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
  btnBooks.Hint      := 'Choosing this option will install BankLink Books.';
  btnUpdate.Hint     := 'Choosing this option will update an existing installation of BankLink Books.';
  btnExplore.Hint    := 'View the files on the CD-ROM.';
  lblHint.Caption    := Self.Hint;
end;

procedure TfrmMain.btnExploreClick(Sender: TObject);
begin
  ShellExecute(Handle,'open',pChar('Explorer'),pChar(CDDrive) ,nil,SW_SHOWNORMAL);
end;

procedure TfrmMain.btnBooksClick(Sender: TObject);
var
  cid : integer;
begin
   //ask for country
   cid := CountryFrm.GetCountry;
   case cid of
     0 : ShellExecute(Handle,'open',pChar( CDDrive + '\SOFTWARE\BOOKS\NZ\SETUP.EXE'),nil ,nil,SW_SHOWNORMAL);
     1 : ShellExecute(Handle,'open',pChar( CDDrive + '\SOFTWARE\BOOKS\AU\SETUP.EXE'),nil ,nil,SW_SHOWNORMAL);
     2 : ShellExecute(Handle,'open',pChar( CDDrive + '\SOFTWARE\BOOKS\UK\SETUP.EXE'),nil ,nil,SW_SHOWNORMAL);
   end;
end;

procedure TfrmMain.btnUpdateClick(Sender: TObject);
var
  cid : integer;
begin
   //ask for country
   cid := CountryFrm.GetCountry;
   case cid of
     0 : ShellExecute(Handle,'open',pChar( CDDrive + '\SOFTWARE\UPDATES\NZ\SETUP.EXE'),nil ,nil,SW_SHOWNORMAL);
     1 : ShellExecute(Handle,'open',pChar( CDDrive + '\SOFTWARE\UPDATES\AU\SETUP.EXE'),nil ,nil,SW_SHOWNORMAL);
     2 : ShellExecute(Handle,'open',pChar( CDDrive + '\SOFTWARE\UPDATES\UK\SETUP.EXE'),nil ,nil,SW_SHOWNORMAL);     
   end;
end;

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
   Close;
end;

end.
