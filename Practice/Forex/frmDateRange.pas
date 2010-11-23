unit frmDateRange;

interface

uses
   bkDateUtils,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DateSelectorFme, ExtCtrls, OsFont;

type
  TDateRangeFrm = class(TForm)
    pButtons: TPanel;
    btnCancel: TButton;
    BtnoK: TButton;
    DateSelector: TfmeDateSelector;
    ltext: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtnoKClick(Sender: TObject);
  private
    procedure SetRange(const Value: TDateRange);
    function GetRange: TDateRange;
    { Private declarations }
  public
    property Range: TDateRange read GetRange write SetRange;
    { Public declarations }
  end;

function GetDateRange(var aRange: TDateRange; const Title, RangeText: string): Boolean;

implementation

uses
  bkXPThemes;

{$R *.dfm}

function GetDateRange(var aRange: TDateRange; const Title, RangeText: string): Boolean;
begin
   Result := False;
   with TDateRangeFrm.Create(Application.MainForm) do try
      Caption := Title;
      ltext.Caption := RangeText;
      Range := aRange;
      DateSelector.btnQuik.Visible := True;
      DateSelector.AllData1.Visible := False;
      if ShowModal = mrOK then begin
         aRange := Range;
         Result := True;
      end;

   finally
      Free;
   end;
end;



{ TDateRangeFrm }

procedure TDateRangeFrm.BtnoKClick(Sender: TObject);
begin
   if DateSelector.ValidateDates then
      Modalresult := mrOK;
end;

procedure TDateRangeFrm.FormCreate(Sender: TObject);
begin
    bkXPThemes.ThemeForm(Self);
    DateSelector.InitDateSelect(0, Maxint,nil);
end;

function TDateRangeFrm.GetRange: TDateRange;
begin
  Result.FromDate := DateSelector.eDateFrom.AsStDate;
  Result.ToDate :=  DateSelector.eDateTo.AsStDate;
end;

procedure TDateRangeFrm.SetRange(const Value: TDateRange);
begin

  DateSelector.eDateFrom.AsStDate := Value.FromDate;
  DateSelector.eDateTo.AsStDate := Value.ToDate;
end;

end.
