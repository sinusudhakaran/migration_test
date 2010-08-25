unit WPSplash;

interface

{$I WPINC.INC}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, SHellAPI, ExtCtrls, Menus, StdCtrls;

type
  TWPSplashForm = class(TForm)
    Image: TImage;
    TopInfo: TLabel;
    CloseTimer: TTimer;
    PopupMenu1: TPopupMenu;
    PaintBox1: TPaintBox;
    InfoLabel: TLabel;
    procedure ImageClick(Sender: TObject);
    procedure CloseTimerTimer(Sender: TObject);
    procedure PaintBox1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  WPSplashForm: TWPSplashForm;

implementation

{$R *.dfm}

procedure TWPSplashForm.ImageClick(Sender: TObject);
begin
  Close;
end;

procedure TWPSplashForm.CloseTimerTimer(Sender: TObject);
begin
   Close;
end;

procedure TWPSplashForm.PaintBox1Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'http://www.wptools.de',
     '', '', SW_SHOW);
end;

procedure TWPSplashForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TWPSplashForm.FormCreate(Sender: TObject);
begin
  {$IFDEF WPDEMO}
   TopInfo.Caption := 'EVALUATION VERSION';
  {$ENDIF}
end;

end.
