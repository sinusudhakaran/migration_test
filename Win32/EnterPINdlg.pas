unit EnterPINdlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Verifies the PIN number required for processing a disk image
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  OsFont;

type
  TdlgEnterPIN = class(TForm)
    lblMessage: TLabel;
    ePIN: TEdit;
    Label2: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
  private
    { Private declarations }
    okPressed : boolean;
  public
    { Public declarations }
    PIN : integer;
    function Execute : boolean;
  end;

function EnterPIN(FileName : string; KeyPhrase : ShortString; var StoredPIN : integer) : boolean;

//******************************************************************************
implementation

{$R *.DFM}

uses
  bkXPThemes,
  Globals,
  ErrorMoreFrm,
  cryptx;

//------------------------------------------------------------------------------
procedure TdlgEnterPIN.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  SetUpHelp;
end;
//------------------------------------------------------------------------------
procedure TdlgEnterPIN.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   Self.Caption     := 'Enter PIN';
   ePIN.Hint :=
             'Enter your PIN number|' +
             'Enter the PIN number to decode your '+SHORTAPPNAME+' transactions';
end;
//------------------------------------------------------------------------------
Function GenerateKey( Name : ShortString ): LongInt;
//expects a right trimmed string
Var
   Buf : Array[0..255] of Byte;
   Sum : LongInt;
   i   : Byte;
   l   : Byte;
Begin
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
//------------------------------------------------------------------------------
procedure TdlgEnterPIN.btnOKClick(Sender: TObject);
var
  v, err :integer;
begin
  Val(ePIN.text,v,err);
  if err = 0 then
    PIN := v
  else
    PIN := 0;

  okPressed := true;
  close;
end;
//------------------------------------------------------------------------------
procedure TdlgEnterPIN.btnCancelClick(Sender: TObject);
begin
   okPressed := false;
   close;
end;
//------------------------------------------------------------------------------
function TdlgEnterPIN.Execute: boolean;
begin
  PIN := 0;
  okPressed := false;

  ShowModal;

  result := okPressed;
end;
//------------------------------------------------------------------------------
function EnterPIN(FileName : string; KeyPhrase : ShortString; var StoredPIN : integer) : boolean;
var
  PINShouldBe : integer;
  MyDlg       : TdlgEnterPin;
begin
  result := false;

  PINShouldBe := GenerateKey(KeyPhrase);
  if StoredPIN = PINShouldBe then begin
     result := true;
     exit;
  end;

  MyDlg := TdlgEnterPIn.Create(Application.MainForm);
  try
     MyDlg.PIN := 0;
     MyDlg.ePIN.Text := IntToStr(StoredPIN);
     MyDlg.lblMessage.Caption :='You must enter your PIN number to decode and '+
                                 'process the transactions in file '+filename;

     if MyDlg.Execute then begin
        if (MyDlg.PIN = PinShouldBe) then begin
           StoredPIN := MyDlg.PIN;
           result := true;
        end
     end;
  finally
     MyDlg.Free;
  end;
end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
end.
