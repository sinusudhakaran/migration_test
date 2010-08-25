{******************************************************************************}
{                                                                              }
{                             GmRtfMailMerge.pas                               }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmRtfMailMerge;

interface

uses
  SysUtils, Classes, GmTypes, GmRtfPreview, GmClasses, stdctrls;

{$I GMPS.INC}

type
  TGmGetFieldTextEvent = procedure(Sender: TObject; MergeCount: integer; Field: string; var Text: string) of object;
  TGmMailMergeProgress = procedure(Sender: TObject; Progress, Total: integer) of object;

  // *** TGmRtfMailMerge ***

  TGmRtfMailMerge = class(TGmComponent)
  private
    FGmRtfPreview: TGmRtfPreview;
    FMergeCount: integer;
    FTokens: TStrings;
    // events...
    FOnGetField: TGmGetFieldTextEvent;
    FOnProgress: TGmMailMergeProgress;
    procedure ReplaceFields(MergeCount: integer; ALines: TStrings; var Result: TStringStream);
    procedure SetGmRtfPreview(AGmRtfPreview: TGmRtfPreview);
    procedure SetTokens(ATokens: TStrings);
    { Private declarations }
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // text mailmerge methods...
    procedure MailMergeTextFile(const AFileName: string);
    procedure MailMergeText(AMemo: TCustomMemo);

    // rich text mailmerge methods...
    procedure MailMergeRichEdit(ARichEdit: TCustomMemo); {$IFDEF D4+} overload; {$ENDIF}
    procedure MailMergeRtfFile(const AFileName: string); {$IFDEF D4+} overload; {$ENDIF}
    procedure MailMergeRtfStream(Stream: TStream);       {$IFDEF D4+} overload; {$ENDIF}
    { Public declarations }
  published
    property GmRtfPreview: TGmRtfPreview read FGmRtfPreview write SetGmRtfPreview;
    property MergeCount: integer read FMergeCount write FMergeCount default 1;
    property Tokens: TStrings read FTokens write SetTokens;
    // evenrs...
    property OnGetField: TGmGetFieldTextEvent read FOnGetField write FOnGetField;
    property OnMergeProgress: TGmMailMergeProgress read FOnProgress write FOnProgress;
    { Published declarations }
  end;

implementation

uses GmRtfFuncs, Forms, Controls, comctrls;

constructor TGmRtfMailMerge.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTokens := TStringList.Create;
  FMergeCount := 1;
end;

destructor TGmRtfMailMerge.Destroy;
begin
  FTokens.Free;
  inherited Destroy;
end;

procedure TGmRtfMailMerge.MailMergeTextFile(const AFileName: string);
var
  AMemo: TRichEdit;
begin
  AMemo := TRichEdit.Create(nil);
  try
    AMemo.Visible := False;
    AMemo.Parent := Application.MainForm;
    AMemo.Lines.LoadFromFile(AFileName);
    MailMergeText(AMemo);
  finally
    AMemo.Free;
  end;
end;

procedure TGmRtfMailMerge.MailMergeText(AMemo: TCustomMemo);
var
  ARichEdit: TRichEdit;
begin
  ARichEdit := TRichEdit.Create(nil);
  try
    ARichEdit.Visible := False;
    ARichEdit.Parent := Application.MainForm;
    ARichEdit.PlainText := True;
    ARichEdit.Font.Assign(FGmRtfPreview.TextFileFont);
    ARichEdit.Lines.Text := AMemo.Text;
    MailMergeRichEdit(ARichEdit);
  finally
    ARichEdit.Free;
  end;
end;

// rich text mailmerge methods...

procedure TGmRtfMailMerge.MailMergeRichEdit(ARichEdit: TCustomMemo);
var
  AStream: TStringStream;
begin
  AStream := TStringStream.Create('');
  try
    GetRtfTextStream(ARichEdit, AStream);
    AStream.Seek(0, soFromBeginning);
    MailMergeRtfStream(AStream);
  finally
    AStream.Free;
  end;
end;

procedure TGmRtfMailMerge.MailMergeRtfFile(const AFileName: string);
var
  AStream: TFileStream;
begin
  AStream := TFileStream.Create(AFileName, fmOpenRead);
  try
    AStream.Seek(0, soFromBeginning);
    MailMergeRtfStream(AStream);
  finally
    AStream.Free;
  end;
end;

procedure TGmRtfMailMerge.MailMergeRtfStream(Stream: TStream);
var
  ICount: integer;
  ALines: TStrings;
  LastCursor: TCursor;
  Result: TStringStream;
begin
  ALines := TStringList.Create;

  LastCursor := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;
    ALines.LoadFromStream(Stream);
    FGmRtfPreview.Preview.BeginUpdate;
    ICount := 1;
    while ICount < FMergeCount+1 do
    begin
      Result := TStringStream.Create('');
      try
        ReplaceFields(ICount, ALines, Result);
        FGmRtfPreview.LoadRtfFromStream(Result);
        if ICount < FMergeCount then
          FGmRtfPreview.Preview.NewPage;
        if Assigned(FOnProgress) then FOnProgress(Self, ICount, MergeCount);
        Inc(ICount);
      finally
        Result.Free;
      end;
    end;
  finally
    Screen.Cursor := LastCursor;
  end;
  FGmRtfPreview.Preview.EndUpdate;
  ALines.Free;
end;

procedure TGmRtfMailMerge.ReplaceFields(MergeCount: integer; ALines: TStrings; var Result: TStringStream);
var
  ACopy: TStrings;
  ICount: integer;
  TokenCount: integer;
  AToken: string;
  ARtfLine: string;
  TokenPos: integer;
  InsertStr: string;
begin
  ACopy := TStringList.Create;
  ACopy.Assign(ALines);
  try
    for ICount := 0 to ACopy.Count-1 do
    begin
      ARtfLine := ACopy[ICount];
      for TokenCount := 0 to FTokens.Count-1 do
      begin
        AToken := FTokens[TokenCount];
        while Pos(AToken, ARtfLine) > 0 do
        begin
          TokenPos := Pos(AToken, ARtfLine);
          if Assigned(FOnGetField) then
          begin
            InsertStr := '?';
            FOnGetField(Self, MergeCount, AToken, InsertStr);
            Delete(ARtfLine, TokenPos, Length(AToken));
            Insert(InsertStr, ARtfLine, TokenPos);
          end;
        end;
      end;
      ACopy[ICount] := ARtfLine;
    end;  
    ACopy.SaveToStream(Result);
    Result.Seek(0, soFromBeginning);
  finally
    ACopy.Free;
  end;
end;

procedure TGmRtfMailMerge.SetGmRtfPreview(AGmRtfPreview: TGmRtfPreview);
begin
  FGmRtfPreview := AGmRtfPreview;
end;

procedure TGmRtfMailMerge.SetTokens(ATokens: TStrings);
begin
  FTokens.Assign(ATokens);
end;

procedure TGmRtfMailMerge.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FGmRtfPreview) then
    FGmRtfPreview := nil;
end;

end.
