unit quikDate;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, ComCtrls;

type
  TfrmDate = class(TForm)
    Panel1: TPanel;
    MonthCalendar1: TMonthCalendar;
    procedure MonthCalendar1DblClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    okPressed : boolean;
  public
    { Public declarations }
    function DateValueStr(defDate : TDateTime) : string;
  end;

  function PopUpDateStr(x,y : integer;def : TDateTime) : string;

//var
//  frmDate: TfrmDate;

implementation

{$R *.DFM}

uses
  bkXPThemes;

function TfrmDate.DateValueStr(defDate: TDateTime) : string;
begin
{   okPressed := false;
   result := '';
   Cal1.Date := defDate;
   lblDate.caption := DateToStr(defDate);
   ShowModal;
   if OkPressed then
     result := lblDate.caption;}
end;    //

function PopUpDateStr(x,y : integer;def : TDateTime) : string;
var
   tempForm : TfrmDate;
begin
   result := '';
   tempForm := TfrmDate.Create(Application);
   try
      tempForm.MonthCalendar1.Date := def;
      tempForm.left := x;
      tempForm.top  := y;
      tempForm.ShowModal;
      result := DateToStr(tempForm.MonthCalendar1.date);
   finally // wrap up
      tempForm.Free;
   end;    // try/finally
end;

procedure TfrmDate.MonthCalendar1DblClick(Sender: TObject);
begin
  okPressed := true;
  close;
end;

procedure TfrmDate.FormDeactivate(Sender: TObject);
begin
   close;
end;

procedure TfrmDate.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
end;

end.
