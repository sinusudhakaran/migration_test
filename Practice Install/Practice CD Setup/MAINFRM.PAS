unit MainFrm;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
   Title:

   Written:
   Authors:

   Purpose:

   Notes:      Jan 2002 - Now uses Raize components and compiled with Delphi 6
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RzButton, ExtCtrls, jpeg;

type
  TfrmMain = class(TForm)
    btnPractice: TRzBitBtn;
    btnClient: TRzBitBtn;
    RzButton1: TRzButton;
    lblHint: TLabel;
    btnToolkit: TRzBitBtn;
    btnBNotes: TRzBitBtn;
    imgLogin: TImage;
    btnExplore: TRzBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure btnToolkitClick(Sender: TObject);
    procedure btnPracticeClick(Sender: TObject);
    procedure btnClientClick(Sender: TObject);
    procedure RzButton1Click(Sender: TObject);
    procedure btnBNotesClick(Sender: TObject);
    procedure btnExploreClick(Sender: TObject);
  private
    CDDrive : string;
    procedure DisplayHint(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

function  GetScreenColors( CanvasHandle : hDC): Int64;

var
  frmMain: TfrmMain;

//******************************************************************************
implementation

{$R *.DFM}

uses
   ShellAPI, CountryFrm;

const
  BKCOLOR_TEAL = $808000;   //clTeal
  BKHICOLOR_TEAL = $009F9B00;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function GetScreenColors( CanvasHandle : hDC): Int64;
var
  n1, n2: longint;
begin
  n1 := GetDeviceCaps( CanvasHandle, PLANES );
  n2 := GetDeviceCaps( CanvasHandle, BITSPIXEL );
  Result := Int64( 1 ) shl ( n1 * n2 );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmMain.DisplayHint(Sender: TObject);
begin
   lblHint.Caption := GetLongHint(Application.Hint);
   if lblHint.Caption = '' then
      lblHint.Caption := Self.Hint;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmMain.FormCreate(Sender: TObject);
begin
   Application.OnHint := DisplayHint;
   CDDrive            := ExtractFileDrive( Application.ExeName);

   Self.Hint          := 'BankLink Practice is for use by an accounting practice, while BankLink Books is for use by a client of an accounting practice.'+#13#10#13#10+'Please choose the appropriate version to install:';
   btnPractice.Hint   := 'Choosing this option will install BankLink Practice. This is usually installed on a network and made available to all staff members.';
   btnClient.Hint     := 'Choosing this option will install BankLink Books. This is usually installed on a stand alone PC for use by a client.'+#13#10+'A staff member may also install this version to process BankLink files off-site.';
   btnBNotes.Hint     := 'Choosing this option will install BankLink Notes. This is usually installed on a stand alone PC so that a client may process their own transactions.';
   btnToolkit.Hint    := 'View the BankLink Toolkit on the CD-ROM';
   btnExplore.Hint    := 'View the files on the CD-ROM.';
   lblHint.Caption    := Self.Hint;
{$IFDEF Testing}
   CDDrive := 'E:';
{$ENDIF}
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmMain.btnToolkitClick(Sender: TObject);
var
  a       : array[0..7] of char;
  iLocale : integer;
  Bytes   : integer;
  Folder  : string;
begin
  //decide on country to use
  Bytes := GetLocaleInfo( LOCALE_USER_DEFAULT, LOCALE_ICOUNTRY, a, SizeOf(a));
  Folder := CDDrive + '\TOOLKIT\';
  if Bytes <> 0 then
  begin
    iLocale := StrToIntDef( a, -1);
    case iLocale of
      CTRY_NEW_ZEALAND : Folder := CDDrive + '\TOOLKIT\NEW ZEALAND\';
      CTRY_AUSTRALIA   : Folder := CDDrive + '\TOOLKIT\AUSTRALIA\';
      CTRY_UNITED_KINGDOM   : Folder := CDDrive + '\TOOLKIT\UNITED KINGDOM\';
    end;
  end;

  ShellExecute(Handle,'open',pChar('Explorer'),pChar(Folder) ,nil,SW_SHOWNORMAL);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.btnPracticeClick(Sender: TObject);
var
  cid : integer;
begin
   //ask for country
   cid := CountryFrm.GetCountry;

   case cid of
     0 : ShellExecute(Handle,'open',pChar( CDDrive + '\SOFTWARE\BANKLINK\PRACTICE\NZ\SETUP.EXE'),nil ,nil,SW_SHOWNORMAL);
     1 : ShellExecute(Handle,'open',pChar( CDDrive + '\SOFTWARE\BANKLINK\PRACTICE\AU\SETUP.EXE'),nil ,nil,SW_SHOWNORMAL);
     2 : ShellExecute(Handle,'open',pChar( CDDrive + '\SOFTWARE\BANKLINK\PRACTICE\UK\SETUP.EXE'),nil ,nil,SW_SHOWNORMAL);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.btnClientClick(Sender: TObject);
var cid: Integer;
begin
//ask for country
   cid := CountryFrm.GetCountry;

   case cid of
     0 : ShellExecute(Handle,'open',pChar( CDDrive + '\SOFTWARE\BANKLINK\BOOKS\NZ\SETUP.EXE'),nil ,nil,SW_SHOWNORMAL);
     1 : ShellExecute(Handle,'open',pChar( CDDrive + '\SOFTWARE\BANKLINK\BOOKS\AU\SETUP.EXE'),nil ,nil,SW_SHOWNORMAL);
     2 : ShellExecute(Handle,'open',pChar( CDDrive + '\SOFTWARE\BANKLINK\BOOKS\UK\SETUP.EXE'),nil ,nil,SW_SHOWNORMAL);
   end;

end;
procedure TfrmMain.btnExploreClick(Sender: TObject);
begin
   ShellExecute(Handle,'open',pChar('Explorer'),pChar(CDDrive) ,nil,SW_SHOWNORMAL);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.btnBNotesClick(Sender: TObject);
begin
   ShellExecute(Handle,'open',pChar( CDDrive + '\SOFTWARE\NOTES\SETUPBNOTES.EXE'),nil ,nil,SW_SHOWNORMAL);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMain.RzButton1Click(Sender: TObject);
begin
   Close;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
