unit SuggMemPopupFrm;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  TeCanvas,
  RzButton,
  StdCtrls,
  ovcbase,
  ovcspeed,
  RzBmpBtn,
  ExtCtrls,
  osfont;

type
  //----------------------------------------------------------------------------
  TfrmSuggMemPopup = class(TForm)
    imgBackground: TImage;
    btnHide: TRzShapeButton;
    btnLater: TRzShapeButton;
    btnCreate: TRzShapeButton;
    lblLine1: TLabel;
    lblLine2: TLabel;
    lblLine3: TLabel;
    lblLine4: TLabel;
    imgBuffer: TImage;
    imgBufferFlip: TImage;
    procedure FormCreate(Sender: TObject);
    procedure btnHideClick(Sender: TObject);
    procedure btnLaterClick(Sender: TObject);
    procedure btnCreateClick(Sender: TObject);
  private
    fFlipPopup : boolean;
    fManualCount : integer;
    fUnCodedCount : integer;
    fMatchedPhrase : string;
  public
    procedure Refresh();

    property FlipPopup : boolean read fFlipPopup write fFlipPopup;
    property ManualCount : integer read fManualCount write fManualCount;
    property UnCodedCount : integer read fUnCodedCount write fUnCodedCount;
    property MatchedPhrase : string read fMatchedPhrase write fMatchedPhrase;
  end;

implementation
{$R *.dfm}

uses
  CodingFrm,
  StrUtils;

//------------------------------------------------------------------------------
{ TfrmSuggMemPopup }
procedure TfrmSuggMemPopup.btnHideClick(Sender: TObject);
begin
  TfrmCoding(Self.Owner).btnHideClick(Sender);
end;

//------------------------------------------------------------------------------
procedure TfrmSuggMemPopup.btnLaterClick(Sender: TObject);
begin
  TfrmCoding(Self.Owner).btnLaterClick(Sender);
end;

//------------------------------------------------------------------------------
procedure TfrmSuggMemPopup.btnCreateClick(Sender: TObject);
begin
  TfrmCoding(Self.Owner).btnCreateClick(Sender);
end;

//------------------------------------------------------------------------------
procedure TfrmSuggMemPopup.FormCreate(Sender: TObject);
begin
  SystemParametersInfo(SPI_SETDRAGFULLWINDOWS, 0, nil, 0); {Disable drag showing}
end;

//------------------------------------------------------------------------------
procedure TfrmSuggMemPopup.Refresh;
Const
  LINE_MAX_LEN = 365;
  FORM_BASE_HEIGHT = 113;
  BUTTON_BASE_HEIGHT = 75;
  FLIP_ADJUSTMENT = 15;
  MORE_STR = '...';
var
  LineWidth : integer;
  LinesUsed : integer;
  Index : integer;
  TempStr : string;
  TempLen : integer;
  Adjustment : integer;

  Line1 : string;
  Line2 : string;
  Line3 : string;
  Line4 : string;

  SrcRect : TRect;
  DestRect : TRect;
begin
  Line3 := '';
  Line4 := '';
  LinesUsed := 2;
  Line1 := inttostr(fManualCount) + ' matching codings for "' + fMatchedPhrase + '"';
  LineWidth := Canvas.TextWidth(Line1);
  lblLine2.Font.Style := [];

  if fFlipPopup then
    Adjustment := FLIP_ADJUSTMENT
  else
    Adjustment := 0;

  if LineWidth > LINE_MAX_LEN then
  begin
    lblLine2.Font.Style := [fsBold];
    LinesUsed := LinesUsed + 1;
    Line1 := inttostr(fManualCount) + ' matching codings for ';
    Line2 := '"' + fMatchedPhrase + '"';
    LineWidth := Canvas.TextWidth(Line2);

    if LineWidth > LINE_MAX_LEN then
    begin
      TempLen := length(fMatchedPhrase) - 3;
      TempStr := leftstr(fMatchedPhrase, TempLen);
      Line2 := '"' + TempStr + ' ' + MORE_STR + '"';
      LineWidth := Canvas.TextWidth(Line2);

      while (LineWidth > LINE_MAX_LEN) do
      begin
        TempLen := length(TempStr) - 1;
        TempStr := leftstr(TempStr, TempLen);
        Line2 := '"' + TempStr + ' ' + MORE_STR + '"';
        LineWidth := Canvas.TextWidth(Line2);
      end;
    end;
  end;

  if fUnCodedCount = 0 then
  begin
    if LinesUsed = 2 then
      Line2 := 'Would you like to create a memorisation based on this coding?'
    else
      Line3 := 'Would you like to create a memorisation based on this coding?'
  end
  else if fUnCodedCount = 1 then
  begin
    LinesUsed := LinesUsed + 1;
    if LinesUsed = 3 then
    begin
      Line2 := '1 uncoded entry could be coded by creating a memorisation.';
      Line3 := 'Would you like to create this memorisation?';
    end
    else
    begin
      Line3 := '1 uncoded entry could be coded by creating a memorisation.';
      Line4 := 'Would you like to create this memorisation?';
    end;
  end
  else
  begin
    LinesUsed := LinesUsed + 1;
    if LinesUsed = 3 then
    begin
      Line2 := inttostr(fUnCodedCount) + ' uncoded entries could be coded by creating a memorisation.';
      Line3 := 'Would you like to create this memorisation?';
    end
    else
    begin
      Line3 := inttostr(fUnCodedCount) + ' uncoded entries could be coded by creating a memorisation.';
      Line4 := 'Would you like to create this memorisation?';
    end;
  end;

  lblLine1.Caption := Line1;
  lblLine2.Caption := Line2;
  if LinesUsed < 3 then
  begin
    lblLine3.Visible := false;
    lblLine4.Visible := false;
    Self.Height := FORM_BASE_HEIGHT;

    btnHide.Top := BUTTON_BASE_HEIGHT - Adjustment;
    btnLater.Top := BUTTON_BASE_HEIGHT - Adjustment;
    btnCreate.Top := BUTTON_BASE_HEIGHT - Adjustment;
  end
  else if LinesUsed < 4 then
  begin
    lblLine3.Caption := Line3;
    lblLine3.Visible := true;
    lblLine4.Visible := false;
    Self.Height := FORM_BASE_HEIGHT + 20;

    btnHide.Top := BUTTON_BASE_HEIGHT + 20 - Adjustment;
    btnLater.Top := BUTTON_BASE_HEIGHT + 20 - Adjustment;
    btnCreate.Top := BUTTON_BASE_HEIGHT + 20 - Adjustment;
  end
  else
  begin
    lblLine3.Caption := Line3;
    lblLine4.Caption := Line4;
    lblLine3.Visible := true;
    lblLine4.Visible := true;
    Self.Height := FORM_BASE_HEIGHT + 40;

    btnHide.Top := BUTTON_BASE_HEIGHT + 40 - Adjustment;
    btnLater.Top := BUTTON_BASE_HEIGHT + 40 - Adjustment;
    btnCreate.Top := BUTTON_BASE_HEIGHT + 40 - Adjustment;
  end;

  lblLine1.Top := 27 - Adjustment;
  lblLine2.Top := 47 - Adjustment;
  lblLine3.Top := 67 - Adjustment;
  lblLine4.Top := 87 - Adjustment;

  SrcRect.Left := 0;
  SrcRect.Top := 0;
  SrcRect.Right := imgBuffer.Width;
  SrcRect.Bottom := imgBuffer.Height - 20;

  DestRect := SrcRect;

  if fFlipPopup then
    imgBackground.Canvas.CopyRect(DestRect, imgBufferFlip.Canvas, SrcRect)
  else
    imgBackground.Canvas.CopyRect(DestRect, imgBuffer.Canvas, SrcRect);

  SrcRect.Left := 0;
  SrcRect.Top := imgBuffer.Height - (20 * LinesUsed);
  SrcRect.Right := imgBuffer.Width;
  SrcRect.Bottom := imgBuffer.Height;

  DestRect.Left := 0;
  DestRect.Top := Self.Height - (20 * LinesUsed);
  DestRect.Right := imgBuffer.Width;
  DestRect.Bottom := Self.Height;

  if fFlipPopup then
    imgBackground.Canvas.CopyRect(DestRect, imgBufferFlip.Canvas, SrcRect)
  else
    imgBackground.Canvas.CopyRect(DestRect, imgBuffer.Canvas, SrcRect);
end;

end.

