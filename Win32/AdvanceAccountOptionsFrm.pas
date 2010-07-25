unit AdvanceAccountOptionsFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,bkXPThemes,
  OSFont;

type
  TfrmAdvanceAccountOptions = class(TForm)
    Button1: TButton;
    Button2: TButton;
    chkEnhancedTempAccounts: TCheckBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

procedure TfrmAdvanceAccountOptions.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);
end;

end.
