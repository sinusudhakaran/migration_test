unit PromoContentFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, WPRTEDefs, WPCTRMemo, WPCTRRich, StdCtrls, RzLabel, ComCtrls,
  OleCtrls, SHDocVw, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit, cxMemo, cxRichEdit,
  RzEdit, ExtCtrls, PromoWindowObj, OSFont, RichEdit;

type
  TPromoStyles = (psHeading1, psHeading2, psHeading3, psBold, psItalics,
                  psStrikeOut, psQuote);

  TPromoContentFrame = class(TFrame)
    lblTitle: TRzLabel;
    lblURL: TRzLabel;
    imgContainer: TImage;
    lblDescResize: TRzLabel;
    reDescription: TcxRichEdit;
    procedure reDescriptionPropertiesURLClick(Sender: TcxCustomRichEdit;
      const URLText: string; Button: TMouseButton);
    procedure reDescriptionPropertiesResizeRequest(Sender: TObject;
      Rect: TRect);
  private
    { Private declarations }
    FStartPosition : Integer;
    procedure SetTextFormat(AText: string; PromoStyle : TPromoStyles);
    procedure FormatRichText(aFormatChar: string; aIsEndCharAvailable:Boolean;PromoStyle: TPromoStyles);
    function DeleteRichText(aStart, aLength : Integer):string;
    function GetRichText(aStart, aLength : Integer): string;
    procedure ProcessSpecialChar(var aCharIndex : Integer; SpecialChar : string);
    function IsASpecialChar(AChar : Char):Boolean;
  public
    { Public declarations }

    constructor Create(Sender:TComponent;Content:TContentfulObj);
    procedure ApplyTextFormatting;
  end;

const
  PromoSpecialChars : array [1..5] of Char = ('#', '_', '~', '*', '>');

implementation

uses ShellAPI;

{$R *.dfm}

{ TPromoContentFrame }

Function GetTextHeightOfRichEdit(Const RichEdit : TcxCustomRichEdit) : Integer;
Var
  Range: TFormatRange;
  LastChar, MaxLen, OldMap, LogX, LogY : Integer;
  SaveRect: TRect;
  DC : HDC;
Begin
    Result := 0;
    Application.ProcessMessages;
    { We want to use the control itself as rendering DC: }
    DC := GetDC(RichEdit.Handle);
    LogX := GetDeviceCaps(DC, LOGPIXELSX);
    LogY := GetDeviceCaps(DC, LOGPIXELSY);

    FillChar(Range, SizeOf(TFormatRange), 0);
    with Range do
    begin
          hdc := DC;
          hdcTarget := DC;
          rc.left := 0;
          rc.top := 0;
          { The width of RichEdit will stay as it is, we want to know the
            height of the text that fits in
            this width (converted to TWIPS): }
          rc.right := RichEdit.ClientWidth * 1440 div LogX;
          rc.bottom := 0;
          rcPage := rc;
          { Whole text: }
          chrg.cpMax := -1;
    End;

    SaveRect := Range.rc;
    LastChar := 0;
    MaxLen := RichEdit.GetTextLen;

    OldMap := SetMapMode(Range.hdc, MM_TEXT);
    SendMessage(RichEdit.Handle, EM_FORMATRANGE, 0, 0);
    try
          repeat
              Range.rc := SaveRect;
              Range.chrg.cpMin := LastChar;
              LastChar := SendMessage(RichEdit.Handle, EM_FORMATRANGE, 0,LongInt(@Range));
              Inc(Result, (Range.rc.Bottom * LogY Div 1440));
          until (LastChar >= MaxLen) or (LastChar = -1);
    finally
          SendMessage(RichEdit.Handle, EM_FORMATRANGE, 0, 0);
          SetMapMode(Range.hdc, OldMap);
          ReleaseDC(RichEdit.Handle, DC);
    end;
    Application.ProcessMessages;
End;

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
  lblDescResize.Width := Self.Width;
  reDescription.Width := Self.Width;
  lblURL.Width := Self.Width;
  Self.AutoSize := True;

  lblTitle.Font.Color := HyperLinkColor;
  lblTitle.Font.Size := 14;
  lblTitle.Font.Style := [fsBold];
  lblTitle.Caption := Trim(Content.Title);

  reDescription.Clear;
  lblDescResize.Caption := Trim(Content.Description);

  reDescription.Lines.Add(Trim(Content.Description));
  //reDescription.Lines.Add('');
  reDescription.Height := lblDescResize.Height + 5;
  ApplyTextFormatting;
  lblDescResize.Visible := False;
  imgContainer.Visible := Content.IsImageAvilable;
  lblURL.Visible := (Trim(Content.URL) <> '');

  lblURL.Font.Color := HyperLinkColor;
  lblURL.Caption := Content.URL;

  if Content.IsImageAvilable then
    imgContainer.Picture.Assign(Content.MainImageBitmap);
  FStartPosition := 0;
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

function TPromoContentFrame.IsASpecialChar(AChar: Char): Boolean;
begin
  Result := (AChar = PromoSpecialChars[1]) or
            (AChar = PromoSpecialChars[2]) or
            (AChar = PromoSpecialChars[3]) or
            (AChar = PromoSpecialChars[4]) or
            (AChar = PromoSpecialChars[5]);
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
  SubDesc : string;
  FoundPos, iStartPos, iEndPos : Integer;
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
  end;

  FoundPos := Pos(SpecialChar, reDescription.Text);
  if FoundPos > 0 then
    ProcessSpecialChar(FoundPos, reDescription.Text[FoundPos]);
  //aCharIndex := aCharIndex + 1;
end;

procedure TPromoContentFrame.reDescriptionPropertiesResizeRequest(
  Sender: TObject; Rect: TRect);
var
  i, j : Integer;
begin
  i := TcxRichEdit(Sender).ClientRect.Left;
  j := TcxRichEdit(Sender).ClientRect.Bottom;
end;

procedure TPromoContentFrame.reDescriptionPropertiesURLClick(
  Sender: TcxCustomRichEdit; const URLText: string; Button: TMouseButton);
begin
  if Trim(URLText) <> '' then
    ShellExecute(0, 'OPEN', PChar(URLText), '', '', SW_SHOWNORMAL);
end;

procedure TPromoContentFrame.FormatRichText(aFormatChar: string; aIsEndCharAvailable:Boolean;PromoStyle: TPromoStyles);
var
  iStartPos, iEndPos : Integer;
  SubDesc : string;
begin
  iStartPos := reDescription.FindText(aFormatChar,0,Length(reDescription.Text),[]);
  DeleteRichText(iStartPos, Length(aFormatChar));
  if aIsEndCharAvailable then
    iEndPos := reDescription.FindText(aFormatChar,iStartPos,Length(reDescription.Text),[])
  else
    iEndPos := reDescription.FindText(#$D,iStartPos,Length(reDescription.Text),[]);

  SubDesc := GetRichText(iStartPos, iEndPos-iStartPos);
  if aIsEndCharAvailable then
    DeleteRichText(iEndPos, Length(aFormatChar));

  SetTextFormat(SubDesc, PromoStyle);
end;

procedure TPromoContentFrame.SetTextFormat(AText: string;
  PromoStyle: TPromoStyles);
var
  FoundPos : Integer;
begin
  FoundPos := reDescription.FindText(AText, FStartPosition, Length(reDescription.Text), []);
  reDescription.SelStart := FoundPos;
  reDescription.SelLength := Length(Trim(AText))+1;
  case PromoStyle of
    psHeading1:
    begin
      reDescription.SelAttributes.Style := reDescription.SelAttributes.Style + [fsBold];
      reDescription.SelAttributes.Size := 10;
    end;
    psHeading2:
    begin
      reDescription.SelAttributes.Style := reDescription.SelAttributes.Style + [fsBold];
      reDescription.SelAttributes.Size := 9;
    end;
    psHeading3:
    begin
      reDescription.SelAttributes.Style := reDescription.SelAttributes.Style + [fsBold];
      reDescription.SelAttributes.Size := 8;
    end;
    psBold: reDescription.SelAttributes.Style := reDescription.SelAttributes.Style + [fsBold];
    psItalics: reDescription.SelAttributes.Style := reDescription.SelAttributes.Style + [fsItalic];
    psStrikeOut: reDescription.SelAttributes.Style := reDescription.SelAttributes.Style + [fsStrikeOut];
  end;
  reDescription.SelLength := 0;

  FStartPosition := FoundPos + Length(Trim(AText));
end;

procedure TPromoContentFrame.ApplyTextFormatting;
var
  i, FoundPos: Integer;
  Line : string;
  DoNeedABreak : Boolean;
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

    {while (j <= Length(reDescription.Text)-1) do
    begin
      if ((reDescription.Text[j] <> #$D) and (IsASpecialChar(reDescription.Text[j]))) then
        ProcessSpecialChar(j, reDescription.Text[j]);
      j := j + 1;
    end;}
  end;
end;

end.
