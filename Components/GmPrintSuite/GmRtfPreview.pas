{******************************************************************************}
{                                                                              }
{                              GmRtfPreview.pas                                }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmRtfPreview;

interface

uses Windows, Classes, StdCtrls, GmPreview, GmResource, GmPrinter, Messages,
  Graphics, GmTypes, GmClasses;

type
  TGmRtfNewPageEvent      = procedure (Sender: TObject; var ATopMargin, ABottomMargin: TGmValue) of object;
  TGmRtfProgressEvent     = procedure (Sender: TObject; Percent: integer) of object;

  // *** TGmRtfPreview ***

  TGmRtfPreview = class(TGmComponent)
  private
    FPreview: TGmPreview;
    FForceNewPages: Boolean;
    FTopMargin: TGmValue;
    FBottomMargin: TGmValue;
    FTextFileFont: TFont;
    FWrapLines: Boolean;
    // events...
    FOnNewPage: TGmRtfNewPageEvent;
    FOnProgress: TGmRtfProgressEvent;
    function GetPrinter: TGmPrinter;
    function GetResourceTable: TGmResourceTable;
    procedure NextPage;
    procedure SetPreview(APreview: TGmPreview);
    procedure SetTextFileFont(Value: TFont);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    property Printer: TGmPrinter read GetPrinter;
    property ResourceTable: TGmResourceTable read GetResourceTable;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;
    // rich text methods...
    procedure LoadRtfFromFile(AFilename: string);
    procedure LoadRtfFromRichEdit(ARichEdit: TCustomMemo);
    procedure LoadRtfFromStream(Stream: TStream);
    // text file methods...
    procedure LoadTextFromFile(const AFileName: string);
    procedure LoadTextFromMemo(ACustomMemo: TCustomMemo);
    property MarginTop: TGmValue read FTopMargin;
    property MarginBottom: TGmValue read FBottomMargin;
  published
    property ForceNewPages: Boolean read FForceNewPages write FForceNewPages default True;
    property Preview: TGmPreview read FPreview write SetPreview;
    property TextFileFont: TFont read FTextFileFont write SetTextFileFont;
    property WrapLines: Boolean read FWrapLines write FWrapLines default True;
    // events...
    property OnNewPage: TGmRtfNewPageEvent read FOnNewPage write FOnNewPage;
    property OnProgress: TGmRtfProgressEvent read FOnProgress write FOnProgress;
  end;

implementation

uses RichEdit, Forms, GmRtfFuncs, ComCtrls, GmConst, GmErrors, Controls;

//------------------------------------------------------------------------------

constructor TGmRtfPreview.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  FTextFileFont := TFont.Create;
  FTopMargin := TGmValue.Create;
  FBottomMargin := TGmValue.Create;
  FForceNewPages := True;
  FTextFileFont.Name := DEFAULT_FONT;
  FTextFileFont.Size := DEFAULT_FONT_SIZE;
  FWrapLines := True;
end;

destructor TGmRtfPreview.Destroy;
begin
  FTopMargin.Free;
  FBottomMargin.Free;
  FTextFileFont.Free;
  inherited Destroy;
end;

function TGmRtfPreview.GetPrinter: TGmPrinter;
begin
  Result := FPreview.GmPrinter;
end;

function TGmRtfPreview.GetResourceTable: TGmResourceTable;
begin
  Result := TGmResourceTable(FPreview.ResourceTable);
end;

procedure TGmRtfPreview.NextPage;
begin
  if (FPreview.CurrentPageNum = FPreview.NumPages) or (FForceNewPages) then
    FPreview.NewPage
  else
    FPreview.NextPage;
  if Assigned(FOnNewPage) then FOnNewPage(Self, FTopMargin, FBottomMargin);
end;

procedure TGmRtfPreview.SetPreview(APreview: TGmPreview);
begin
  FPreview := APreview;
  if Assigned(FPreview) then
  begin
    with FPreview do
    begin
      FTopMargin.AsInches := Margins.Top.AsInches + Header.Height[gmInches];
      FBottomMargin.AsInches := Margins.Bottom.AsInches + Footer.Height[gmInches];
    end;
  end;
end;

procedure TGmRtfPreview.SetTextFileFont(Value: TFont);
begin
  FTextFileFont.Assign(Value);
end;

procedure TGmRtfPreview.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FPreview) then
    FPreview := nil;
end;

//------------------------------------------------------------------------------

// rich text methods...

procedure TGmRtfPreview.LoadRtfFromFile(AFilename: string);
var
  ARichEdit: TCustomMemo;
  ALines: TStrings;
begin
  if not Assigned(FPreview) then
  begin
    ShowGmError(Self, GM_NO_PREVIEW_ASSIGNED);
    Exit;
  end;
  ARichEdit := ResourceTable.CustomMemoList.CreateMemo;
  ALines := TStringList.Create;
  try
    ALines.LoadFromFile(AFilename);
    ARichEdit.Parent := Application.MainForm;
    InsertRtfText(ARichEdit, ALines.Text);
    LoadRtfFromRichEdit(ARichEdit);
  finally
    ALines.Free;
    ARichEdit.Free;
  end;
end;

procedure TGmRtfPreview.LoadRtfFromRichEdit(ARichEdit: TCustomMemo);
var
  Range: TFormatRange;
  LastChar, MaxLen: Integer;
  NewRichEdit: TCustomMemo;
  FormatPage: integer;
  TextLenEx: TGetTextLengthEx;
  LastCursor: TCursor;
begin
  if not Assigned(FPreview) then
  begin
    ShowGmError(Self, GM_NO_PREVIEW_ASSIGNED);
    Exit;
  end;
  FPreview.BeginUpdate;

  FTopMargin.AsTwips    := (FPreview.Margins.Top.AsTwips + Round(FPreview.Header.Height[gmTwips]));
  FBottomMargin.AsTwips := (FPreview.Margins.Bottom.AsTwips + Round(FPreview.Footer.Height[gmTwips]));
  LastCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    FillChar(Range, SizeOf(TFormatRange), 0);
    Range.hdc := printer.handle;
    Range.hdcTarget := printer.handle;
    Range.rcPage.Left := 0;
    Range.rcPage.Top := 0;

    LastChar := 0;
    with TextLenEx do
    begin
      flags := GTL_DEFAULT;
      codepage := CP_ACP;
    end;
    Range.chrg.cpMax := -1;
    FormatPage := FPreview.CurrentPageNum;
    with FPreview.Pages[FormatPage].PageSize[gmInches] do
    begin
      Range.rcPage.Right := Round(Width * 1440);
      Range.rcPage.Bottom := Round(Height * 1440);
    end;
    Range.rc := Range.rcPage;
    range.rcPage := range.rc;
    SendMessage(ARichEdit.Handle, EM_FORMATRANGE, 0, 0);    // flush buffer

    // changed NewRichEdit to ARichEdit...
    if IsRxRichEdit(ARichEdit) then
       MaxLen := SendMessage(ARichEdit.Handle, EM_GETTEXTLENGTHEX, WParam(@TextLenEx), 0)
    else
       MaxLen := ARichEdit.GetTextLen;
    if IsRichEdit98(ARichEdit) then Dec(MaxLen);

    NewRichEdit := ResourceTable.CustomMemoList.AddMemo(ARichEdit);
    repeat
      FormatPage := FPreview.CurrentPageNum;
      // set the page extents...
      with FPreview.Pages[FormatPage].PageSize[gmInches] do
      begin
        Range.rcPage.Right := Round(Width * 1440);
        Range.rcPage.Bottom := Round(Height * 1440);
      end;
      range.rc := range.rcPage;
      with range.rc do
      begin
        Left := Left + FPreview.Margins.Left.AsTwips;
        // add a small gap (16th inch) under the header line...
        Top := Top + FTopMargin.AsTwips + Round(1440 / 16);
        Right := Right - FPreview.Margins.Right.AsTwips;
        Bottom := Bottom - FBottomMargin.AsTwips;
      end;

      if not FWrapLines then range.rc.Right := (range.rc.Right * 10);

      with range.rc do
        Range.chrg.cpMin := LastChar;

      if IsRxRichEdit(NewRichEdit) then
        LastChar := SendMessage(NewRichEdit.Handle, EM_FORMATRANGE, 0, Longint(@Range))
      else
        LastChar := SendMessage(NewRichEdit.Handle, EM_FORMATRANGE, 0, Longint(@Range));
      with FPreview.Pages[FormatPage].RtfInfo do

      begin
        Margins.AsInchRect := GmRect(Range.rc.Left / 1440,
                                     Range.rc.Top / 1440,
                                     Range.rc.Right / 1440,
                                     Range.rc.Bottom / 1440);
        Offset := Point(Range.chrg.cpMin, LastChar);
        RichEdit := NewRichEdit;
        WrapText := FWrapLines;
      end;
      if (LastChar < MaxLen) and (LastChar <> -1) then NextPage;
      if Assigned(FOnProgress) then FOnProgress(Self, Round((LastChar / MaxLen) * 100));
    until (LastChar >= MaxLen) or (LastChar = -1);
  finally
    FPreview.EndUpdate;
    Screen.Cursor := LastCursor;
  end;
end;

procedure TGmRtfPreview.LoadRtfFromStream(Stream: TStream);
var
  ARichEdit: TCustomMemo;
begin
  ARichEdit := ResourceTable.CustomMemoList.CreateMemo;
  //ARichEdit.Lines.LoadFromStream(Stream);
  InsertRtfStream(ARichEdit, Stream);
  LoadRtfFromRichEdit(ARichEdit);
end;

//------------------------------------------------------------------------------

// text file methods...

procedure TGmRtfPreview.LoadTextFromFile(const AFileName: string);
var
  ARichEdit: TRichEdit;
begin
  ARichEdit := CreateTRichEdit;
  try
    ARichEdit.PlainText := True;
    ARichEdit.Font.Assign(FTextFileFont);
    ARichEdit.Parent := Application.MainForm;
    ARichEdit.Lines.LoadFromFile(AFileName);
    LoadRtfFromRichEdit(ARichEdit);
  finally
    ARichEdit.Free;
  end;
end;

procedure TGmRtfPreview.LoadTextFromMemo(ACustomMemo: TCustomMemo);
var
  ARichEdit: TRichEdit;
begin
  ARichEdit := CreateTRichEdit;
  try
    ARichEdit.PlainText := True;
    ARichEdit.Font.Assign(FTextFileFont);
    ARichEdit.Parent := Application.MainForm;
    ARichEdit.Lines.Text := (ACustomMemo.Lines.Text);
    LoadRtfFromRichEdit(ARichEdit);
  finally
    ARichEdit.Free;
  end;
end;

end.
