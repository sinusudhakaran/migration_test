unit wpinfdlg;

interface

{$I WPINC.INC}

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TInsFootNote = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    FText: TEdit;
    Label3: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure Edit2Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    C : Char;
    nr : integer;
  end;

var
  InsFootNote: TInsFootNote;

implementation

{$R *.DFM}

procedure TInsFootNote.Edit2Change(Sender: TObject);
var
  s : string;
begin
  s := Edit2.Text;
  if (Length(s)<1) or (s[1]<=#32) then BitBtn1.Enabled := FALSE
  else
  begin C:=s[1];
        BitBtn1.Enabled := TRUE;
  end;
end;

procedure TInsFootNote.Edit1Change(Sender: TObject);
begin
    try
       nr := StrToInt(Edit1.Text);
    except
       nr := 0;
       Edit1.Text := '0';
    end;
end;

procedure TInsFootNote.FormShow(Sender: TObject);
begin
    Label1.Enabled := Edit2.Enabled;
    Edit2.Text := C;
    Edit1.Text := IntToStr(nr);
end;

end.
