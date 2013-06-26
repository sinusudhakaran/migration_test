//
// Main.pas
//
// Get a Pin for Disc
//
// Copyright BankLink Limited 2002
//
// Version
//   1.00 04/10/2002 Michael Foot - Initial Version.
//
//------------------------------------------------------------------------------
unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons;

type
  TMainForm = class(TForm)
    pnlExtraTitleBar: TPanel;
    lblAcctDetails: TLabel;
    pnlGraphic: TPanel;
    imgGraphic: TImage;
    Label1: TLabel;
    edtFilename: TEdit;
    grpDetails: TGroupBox;
    Label3: TLabel;
    lblClientName: TLabel;
    Label4: TLabel;
    lblPinNumber: TLabel;
    btnGetPin: TButton;
    btnClose: TButton;
    btnBackupDir: TSpeedButton;
    OpenDialog1: TOpenDialog;
    Label5: TLabel;
    lblError: TLabel;
    Label2: TLabel;
    lblCountry: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnBackupDirClick(Sender: TObject);
    procedure btnGetPinClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
    procedure HideError;
    procedure ShowError(ErrorMsg : String);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

function GenerateKey( Name : ShortString ): LongInt;

implementation

{$R *.dfm}

uses
  NFDiskObj, NZDiskObj, UKDiskObj, OZDiskObj, NFUtils, CRYPTX;

procedure TMainForm.FormShow(Sender: TObject);
begin
  edtFilename.Text := '';
  lblCountry.Caption := '';
  lblClientName.Caption := '';
  lblPinNumber.Caption := '';
  HideError;
end;

procedure TMainForm.btnBackupDirClick(Sender: TObject);
var
  FileName : string;
begin
  FileName := Trim(edtFilename.Text);

  with OpenDialog1 do
  begin
    DefaultExt   := '*.*';
    Filename     := '*.*';
    Filter       := 'All Files|*.*';
    Options      := [ ofHideReadOnly, ofShowHelp, ofFileMustExist, ofEnableSizing, ofNoChangeDir ];
    Title        := 'Open File';
    InitialDir   := ExtractFilePath(FileName);
  end;

  if OpenDialog1.Execute then
    edtFilename.Text := OpenDialog1.Filename;
end;

procedure TMainForm.btnGetPinClick(Sender: TObject);
var
  i, PinNumber : Integer;
  FileName, NameForPin, Country : String;
  NewFormat : Boolean;
  FNew : File of NewDiskIDRec;
  NewDiskID : NewDiskIDRec;
  FOld : File of Char;
  OldDiskID : Char;
  DiskImage : TNewFormatDisk;
begin
  if (edtFilename.Text <> '') and (FileExists(edtFilename.Text)) then
  begin
    lblCountry.Caption := '';
    lblClientName.Caption := '';
    lblPinNumber.Caption := '';
    HideError;

    FileName := ExtractFileName(edtFilename.Text);

    NewFormat := (Copy(FileName,1,3) = 'BK_');

    if (NewFormat) then
    begin
      AssignFile(FNew, edtFilename.Text);
      Reset(FNew);
      Read(FNew, NewDiskID);
      Country := NewDiskID.nidCountryID;
      CloseFile(FNew);
    end else
    begin
      AssignFile(FOld, edtFilename.Text);
      Reset(FOld);
      Read(FOld, OldDiskID);
      i := Integer(OldDiskID);
      Country := '';
      while (i > 0) do
      begin
        Read(FOld, OldDiskID);
        Country := Country + OldDiskID;
        Dec(i);
      end;
      CloseFile(FOld);
      if (Country = 'OZLink') then
        Country := 'AU'
      else if (Country = 'UKLink') then
        Country := 'UK'
      else
        Country := 'NZ';
    end;

    //create disk image
    if (Country = 'AU') then
       DiskImage := TOZDisk.Create
    else if (Country = 'UK') then
       DiskImage := TUKDisk.Create
    else
       DiskImage := TNZDisk.Create;
    try
      //load disk image, reraise any errors as EDownloadVerify so that
      //can be caught, otherwise will cause Critical Application Error
      try
        if NewFormat then
          DiskImage.LoadFromFile( edtFilename.Text, '', False)
        else
          DiskImage.LoadFromFileOF( edtFilename.Text, '', False);

        //validate disk image format
        DiskImage.Validate;
      except
        on E : Exception do
        begin
          ShowError(E.Message);
          Exit;
        end;
      end;

      //check that we have the correct pin number for this disk
      if (Country = 'AU')
      or (Country = 'UK') then
        NameForPin := TrimRight(Copy( DiskImage.dhFields.dhClient_Name, 1, 40))
      else
        NameForPin := TrimRight(Copy( DiskImage.dhFields.dhClient_Name, 1, 20));

      if (Country = 'NZ') then
        lblCountry.Caption := 'New Zealand'
      else if (Country = 'AU') then
        lblCountry.Caption := 'Australia'
      else if (Country = 'UK') then
        lblCountry.Caption := 'United Kingdom';

      lblClientName.Caption := NameForPin;
      PinNumber := GenerateKey(NameForPin);
      lblPinNumber.Caption := IntToStr(PinNumber);
    finally
      DiskImage.Free;
    end;
  end else
    ShowError('File does not exist');
end;

procedure TMainForm.HideError;
begin
  Label5.Visible := False;
  lblError.Caption := '';
  lblError.Visible := False;
end;

procedure TMainForm.ShowError(ErrorMsg : String);
begin
  Label5.Visible := True;
  lblError.Caption := ErrorMsg;
  lblError.Visible := True;
end;

//------------------------------------------------------------------------------
//
//GenerateKey
//
//expects a right trimmed string
//
function GenerateKey( Name : ShortString ): LongInt;
var
   Buf : Array[0..255] of Byte;
   Sum : LongInt;
   i   : Byte;
   l   : Byte;
begin
   Name := UpperCase(Name);
   l := Length(Name) + 1;
   FillChar( Buf, Sizeof( Buf ), 0 );
   Move( Name, Buf, l );
   Encrypt( Buf, l );
   Sum := 0;
   For i := 0 to l-1 do
      Sum := Sum + ( Buf[i] * Ord( Name[i] ) );
   GenerateKey := ( Sum mod 9999 ) + 1;
end;

//
// btnCloseClick
//
// Closes for form when the Close button is pressed
//
procedure TMainForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
