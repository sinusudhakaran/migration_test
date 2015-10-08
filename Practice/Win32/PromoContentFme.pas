unit PromoContentFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, WPRTEDefs, WPCTRMemo, WPCTRRich, StdCtrls, RzLabel, ComCtrls,
  OleCtrls, SHDocVw,  RzEdit, ExtCtrls, PromoWindowObj, OSFont, RichEdit,
  BKRichEdit;

type
  TPromoStyles = (psHeading1, psHeading2, psHeading3, psBold, psItalics,
                  psStrikeOut, psQuote, psURL);

  TPromoContentFrame = class(TFrame)
    lblTitle: TRzLabel;
    lblURL: TRzLabel;
    imgContainer: TImage;
    reDescription: TBKRichEdit;
    procedure reDescriptionResizeRequest(Sender: TObject; Rect: TRect);
    procedure reDescriptionLinkClicked(Sender: TObject; LinkClicked: string;
      LinkLine: Integer);
  private
    { Private declarations }
    FStartPosition : Integer;
    procedure SetTextFormat(AText: string; PromoStyle : TPromoStyles);
    procedure FormatRichText(aFormatChar: string; aIsEndCharAvailable:Boolean;PromoStyle: TPromoStyles);
    function DeleteRichText(aStart, aLength : Integer):string;
    function GetRichText(aStart, aLength : Integer): string;
    procedure ProcessSpecialChar(var aCharIndex : Integer; SpecialChar : string);
  public
    { Public declarations }
    PrevRichEditWndProc: TWndMethod;
    constructor Create(Sender:TComponent;Content:TContentfulObj);reintroduce;
    procedure ApplyTextFormatting;
  end;

const
  PromoSpecialChars : array [1..6] of Char = ('#', '_', '~', '*', '>' , '[');

implementation

uses ShellAPI;

{$R *.dfm}

{ TPromoContentFrame }

procedure TPromoContentFrame.reDescriptionLinkClicked(Sender: TObject;
  LinkClicked: string; LinkLine: Integer);
begin
  ShowMessage(LinkClicked);
end;

procedure TPromoContentFrame.reDescriptionResizeRequest(Sender: TObject;
  Rect: TRect);
begin
  reDescription.Height := Rect.Bottom - Rect.Top;
  reDescription.HideScrollBars := True;
end;

constructor TPromoContentFrame.Create(Sender: TComponent; Content: TContentfulObj);
var
  NonClientMetrics : TNonClientMetrics;
  DPI : Integer;
  lHDC : HDC;
begin
  inherited Create(Sender);

  NonClientMetrics.cbSize := SizeOf(NonClientMetrics);
  SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0);
  Font.Handle := CreateFontIndirect(NonClientMetrics.lfMessageFont);

  lHDC := Windows.GetDC(Hwnd(0));

  DPI := GetDevicecaps(lHDC,LogPixelsX);

  if DPI> 100 then  // Large size 120 DPI
     Font.size := 8
  else  // Normal size 96
     Font.size := 10;

  ReleaseDC(0,lHDC);

  ParentFont := True;
  ParentColor := True;
  Self.AutoSize := False;
  Self.Width := TForm(Sender).Width;
  Self.Height := TForm(Sender).Height;
  lblTitle.Width := Self.Width;
  reDescription.Width := Self.Width;
  lblURL.Width := Self.Width;

  lblTitle.Font.Color := HyperLinkColor;
  lblTitle.Font.Size := 16;
  lblTitle.Font.Style := [fsBold];
  lblTitle.Caption := Trim(Content.Title);

  reDescription.Clear;
  reDescription.Lines.Add(Trim(Content.Description));
  ApplyTextFormatting;

  imgContainer.Visible := Content.IsImageAvilable;
  lblURL.Visible := (Trim(Content.URL) <> '');

  lblURL.Font.Color := HyperLinkColor;
  lblURL.Caption := Content.URL;

  if Content.IsImageAvilable then
    imgContainer.Picture.Assign(Content.MainImageBitmap);
  FStartPosition := 0;
  
  Self.AutoSize := True;
end;

function TPromoContentFrame.DeleteRichText(aStart, aLength: Integer):string;
begin
  reDescription.SelStart := aStart;
  reDescription.SelLength := aLength;
  reDescription.SelText := '';
  reDescription.SelLength := 0;

  Result := StringReplace(reDescription.Text,#13#10,'',[rfReplaceAll, rfIgnoreCase]);
end;

function TPromoContentFrame.GetRichText(aStart, aLength: Integer): string;
begin
  reDescription.SelStart := aStart;
  reDescription.SelLength := aLength;
  Result := reDescription.SelText;

  reDescription.SelLength := 0;
end;

{process the special chars in the promo content and show the formatting in the rich edit component.
# means heading 1
## means heading 2
### means heading 3
~~ means strike out
__ means bold
* means italics
[] means link name inside followed by link
> means a quote , should stay till the new line chars
}
procedure TPromoContentFrame.ProcessSpecialChar(var aCharIndex: Integer;
  SpecialChar: string);
var
  FoundPos : Integer;
begin
  if SpecialChar = PromoSpecialChars[1] then
  begin
    {Make sure next 2 chars are  # or not}
    if reDescription.Text[aCharIndex+1] = PromoSpecialChars[1] then // ##
    begin
      if reDescription.Text[aCharIndex+2] = PromoSpecialChars[1] then // ###  /// heading 3
        FormatRichText('### ', False, psHeading3)
      else // Heading 2
        FormatRichText('## ', False, psHeading2);
    end
    else // Heading 1
      FormatRichText('# ', False, psHeading1);
  end
  else if SpecialChar = PromoSpecialChars[2] then // bold
  begin
    {Make sure next 2 chars are  _ or not}
    if reDescription.Text[aCharIndex+1] = PromoSpecialChars[2] then // ##
      FormatRichText('__', True, psBold);
  end
  else if SpecialChar = PromoSpecialChars[3] then // strikeout
  begin
    {Make sure next 2 chars are  ~ or not}
    if reDescription.Text[aCharIndex+1] = PromoSpecialChars[3] then // ##
      FormatRichText('~~', True, psStrikeOut);
  end
  else if SpecialChar = PromoSpecialChars[4] then // italics
  begin
    if reDescription.Text[aCharIndex+1] = PromoSpecialChars[4] then // ##
      FormatRichText('**', True, psBold)
    else
      FormatRichText('*', True, psItalics);
  end
  else if SpecialChar = PromoSpecialChars[5] then // quotes
  begin
    if reDescription.Text[aCharIndex+1] = ' ' then // ##
      FormatRichText('> ', False, psQuote);
  end
  else if SpecialChar = PromoSpecialChars[6] then // url then
    FormatRichText('[', True, psURL);

  FoundPos := Pos(SpecialChar, reDescription.Text);
  if FoundPos > 0 then
    ProcessSpecialChar(FoundPos, reDescription.Text[FoundPos]);
end;

//ShellExecute(0, 'OPEN', PChar(URLText), '', '', SW_SHOWNORMAL);

procedure TPromoContentFrame.FormatRichText(aFormatChar: string; aIsEndCharAvailable:Boolean;PromoStyle: TPromoStyles);
var
  iStartPos, iEndPos , iEndURL: Integer;
  SubDesc : string;
begin
  iStartPos := reDescription.FindText(aFormatChar,0,Length(reDescription.Text),[]);
  DeleteRichText(iStartPos, Length(aFormatChar));
  iEndURL := 0;
  if PromoStyle = psURL then
  begin
    iEndURL := reDescription.FindText(']',iStartPos, Length(reDescription.Text),[]);
    SubDesc := GetRichText(iStartPos, iEndURL-iStartPos);
    if ((iEndURL < 0) and (Trim(SubDesc) = '')) then
    begin
      FStartPosition := FStartPosition + 1;
      Exit;
    end;
  end;
  if aIsEndCharAvailable then
  begin
    if PromoStyle = psURL then
      iEndPos := iEndURL
    else
      iEndPos := reDescription.FindText(aFormatChar,iStartPos,Length(reDescription.Text),[]);
  end
  else
    iEndPos := reDescription.FindText(#$A,iStartPos,Length(reDescription.Text),[]);

  SubDesc := GetRichText(iStartPos, iEndPos-iStartPos);
  if aIsEndCharAvailable then
    DeleteRichText(iEndPos, Length(aFormatChar));

  if FStartPosition > iStartPos then
    FStartPosition := iStartPos;
    
  SetTextFormat(SubDesc, PromoStyle);
end;

procedure TPromoContentFrame.SetTextFormat(AText: string;
  PromoStyle: TPromoStyles);
var
  FoundPos : Integer;
begin
  FoundPos := reDescription.FindText(AText, FStartPosition, Length(reDescription.Text), []);
  reDescription.SelStart := FoundPos;
  reDescription.SelLength := Length(Trim(AText)) + 1;
  case PromoStyle of
    psHeading1:
    begin
      reDescription.SelAttributes.Style := reDescription.SelAttributes.Style + [fsBold];
      reDescription.SelAttributes.Size := 13;
    end;
    psHeading2:
    begin
      reDescription.SelAttributes.Style := reDescription.SelAttributes.Style + [fsBold];
      reDescription.SelAttributes.Size := 12;
    end;
    psHeading3:
    begin
      reDescription.SelAttributes.Style := reDescription.SelAttributes.Style + [fsBold];
      reDescription.SelAttributes.Size := 11;
    end;
    psBold: reDescription.SelAttributes.Style := reDescription.SelAttributes.Style + [fsBold];
    psItalics: reDescription.SelAttributes.Style := reDescription.SelAttributes.Style + [fsItalic];
    psStrikeOut: reDescription.SelAttributes.Style := reDescription.SelAttributes.Style + [fsStrikeOut];
    psURL :
    begin
      reDescription.SelAttributes.Style := reDescription.SelAttributes.Style + [fsUnderline];
      reDescription.SelAttributes.Color := HyperLinkColor;
    end;
  end;
  reDescription.SelLength := 0;

  FStartPosition := FoundPos + Length(Trim(AText));
end;

procedure TPromoContentFrame.ApplyTextFormatting;
var
  i, FoundPos: Integer;
begin
  if Trim(reDescription.Text) = '' then
    Exit;

  FStartPosition := 0;

  if ((Pos(PromoSpecialChars[1], reDescription.Text) > 0) or
      (Pos(PromoSpecialChars[2], reDescription.Text) > 0) or
      (Pos(PromoSpecialChars[3], reDescription.Text) > 0) or
      (Pos(PromoSpecialChars[4], reDescription.Text) > 0) or
      (Pos(PromoSpecialChars[5], reDescription.Text) > 0) ) then
  begin

    for i := 1 to High(PromoSpecialChars) do
    begin
      FoundPos := Pos(PromoSpecialChars[i], reDescription.Text);
      if FoundPos > 0 then
        ProcessSpecialChar(FoundPos, reDescription.Text[FoundPos]);
    end;
  end;
end;

end.
