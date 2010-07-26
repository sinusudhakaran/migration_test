unit WPSyntaxInterface;
{ --------------------------------------------------------------------------
  WPTools Version 5 - CopyRight (C) 2005 by WPCubed GmbH and Julian Ziersch
  Info: http://www.wpcubed.com
  --------------------------------------------------------------------------
  This unit serves as an interface class between the WPTools 5 RTF-Engine
  and the TSynCustomHighlighter class provided with the
  Project SynEdit which is published under the Mozilla Public License V 1.1
  You may retrieve the latest version of SynEdit at the SynEdit home page,
  located at http://SynEdit.SourceForge.net
  -------------------------------------------------------------------------- }
  // Last Update: 9.1.2005

interface

uses SysUtils, Classes, WPRTEPaint, WPRTEDefs, SynEditHighlighter;

type
  {:: The component TWPSynEditHighlight has been created to use the
  SynEdit (http://SynEdit.SourceForge.net) syntax highlighter with WPTools 5.
  This makes it possible to show the syntax of about 30 different languages,
  including pascal, Java c++ and SQL!<br>
  All you need to add the syntax highlighter
  units to the project. Then you can select a highlighter with<br>
     WPSynEditHighlight1.SelectClass( HighlighterName.Text )<br>.
  To highlight the complete text use this code:
  <code>
      WPSynEditHighlight1.Execute(WPRichText1.FirstPar);
      WPRichText1.ReformatAll(true, true);
  </code>
  To refrehs the format of the paragraph which is currently edited use the
  BeforeInitializePar event:
  <code>
  if WPSynEditHighlight1.HL<>nil then
      WPSynEditHighlight1.Execute(par,par.NextPar);
  </code>
  Note that it is also possible to only highlight some of the paragraphs.
  The highlighter actually applies attributes to the text. So if the text is
  copied to clipboard it can be pasted somewhere else while the format
  stays.
  }

  TWPSynEditHighlight = class(TComponent)
  private
    FEnabled: Boolean;
    FOwnedHL, FHL: TSynCustomHighlighter;
    FRTFPropsStateID: Integer;
    // --- Standard CharAttr
    FStdCharAttr: Cardinal;
    FStoredAttr, FStoredIndex: TList;
    FFontName: string;
    FFontSize: Integer;
    procedure SetHL(x: TSynCustomHighlighter);
    procedure SetFontName(x: string);
    procedure SetFontSize(x: Integer);
  public
    constructor Create(aOwner: TComponent);
    destructor Destroy; override;
    {:: This procedure formats all paragraphs from StartPar until
    (but not including) NextPar. To format the complete text use
     <code>WPSynEditHighlight1.Execute(WPRichText1.FirstPar);</code>.
     To format ony one paragraph and its children paragraphs use
     <code>WPSynEditHighlight1.Execute(par, par.NextPar);</code>.
     The optional parameter Memo can be set to WPRichText1.Memo; In this case the
     highlighter can force a full reformat if required.
    }
    procedure Execute(StartPar: TParagraph; EndPar: TParagraph = nil;
      Memo: TWPRTFEngineBasis = nil);
    {:: This function is used internally to apply certain attributes to
    a part of the given paragraph }
    procedure ApplyAttr(par: TParagraph; Pos, Len: Integer;
      attr: TSynHighlighterAttributes);
    {:: This function selects a the highlighter with the given class name }
    function SelectClass(HighlighterClassName: string): Boolean;
    {:: This function selects the highlighter for the given language name }
    function SelectLanguage(HighlighterLanguage: string): Boolean;
  published
    {:: This is the highlighter class which is active }
    property HL: TSynCustomHighlighter read FHL write SetHL;
    property FontName: string read FFontName write SetFontName;
    property FontSize: Integer read FFontSize write SetFontSize;
    property Enabled: Boolean read FEnabled write FEnabled default TRUE;
  end;

implementation

constructor TWPSynEditHighlight.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FFontName := ''; // 'Courier New';
  FFontSize := 0;  // 10;
  FStoredAttr := TList.Create;
  FStoredIndex := TList.Create;
  FEnabled := TRUE;
end;

destructor TWPSynEditHighlight.Destroy;
begin
  FreeAndNil(FOwnedHL);
  FreeAndNil(FStoredAttr);
  FreeAndNil(FStoredIndex);
  inherited Destroy;
end;

procedure TWPSynEditHighlight.SetHL(x: TSynCustomHighlighter);
begin
  FStoredAttr.Clear;
  FStoredIndex.Clear;
  FHL := x;
end;

procedure TWPSynEditHighlight.SetFontName(x: string);
begin
  if FFontName <> x then
  begin
    FRTFPropsStateID := 0;
    FFontName := x;
  end;
end;

procedure TWPSynEditHighlight.SetFontSize(x: Integer);
begin
  if FFontSize <> x then
  begin
    FRTFPropsStateID := 0;
    FFontSize := x;
  end;
end;

procedure TWPSynEditHighlight.ApplyAttr(par: TParagraph; Pos, Len: Integer;
  attr: TSynHighlighterAttributes);
var CharAttr: Cardinal;
  i: Integer;
begin
  if FRTFPropsStateID <> par.RTFProps.StateID then
  begin
   // Init Standard Attr
    par.RTFProps.AttrHelper.Clear;
    if FFontName<>'' then
        par.RTFProps.AttrHelper.SetFontName(FFontName);
    if FFontSize>0 then
        par.RTFProps.AttrHelper.SetFontSize(FFontSize);
    FStdCharAttr := par.RTFProps.AttrHelper.CharAttr;
    FRTFPropsStateID := par.RTFProps.StateID;
    FStoredAttr.Clear;
    FStoredIndex.Clear;
  end;

  if attr = nil then CharAttr := FStdCharAttr
  else
  begin
    i := FStoredAttr.IndexOf(attr);
    if i >= 0 then
      CharAttr := Cardinal(FStoredIndex[i])
    else
    begin
      par.RTFProps.AttrHelper.Clear;
      if FFontName<>'' then
         par.RTFProps.AttrHelper.SetFontName(FFontName);
      if FFontSize>0 then
         par.RTFProps.AttrHelper.SetFontSize(FFontSize);
      par.RTFProps.AttrHelper.SetColor(attr.Foreground);
      par.RTFProps.AttrHelper.SetBGColor(attr.Background);
      par.RTFProps.AttrHelper.SetFontStyle(attr.Style);
      CharAttr := par.RTFProps.AttrHelper.CharAttr;
      // Cache the CharAttr!
      FStoredAttr.Add(attr);
      FStoredIndex.Add(Pointer(CharAttr));
    end;
  end;
  for i := Pos to Pos + Len - 1 do
    par.CharAttr[i] := CharAttr;
end;

function TWPSynEditHighlight.SelectClass(HighlighterClassName: string): Boolean;
var i: Integer;
begin
  i := GetPlaceableHighlighters.Count - 1;
  while i >= 0 do
  begin
    if CompareText(GetPlaceableHighlighters[i].ClassName, HighlighterClassName) = 0 then
      break;
    dec(i);
  end;
  if i >= 0 then
  begin
    FreeAndNil(FOwnedHL);
    FOwnedHL := GetPlaceableHighlighters[i].Create(nil);
    HL := FOwnedHL;
    Result := TRUE;
  end else Result := FALSE;
end;

function TWPSynEditHighlight.SelectLanguage(HighlighterLanguage: string): Boolean;
var i: Integer;
begin
  i := GetPlaceableHighlighters.FindByName(HighlighterLanguage);
  if i >= 0 then
  begin
    FreeAndNil(FOwnedHL);
    FOwnedHL := GetPlaceableHighlighters[i].Create(nil);
    HL := FOwnedHL;
    Result := TRUE;
  end else Result := FALSE;
end;

procedure TWPSynEditHighlight.Execute(
  StartPar: TParagraph; EndPar: TParagraph = nil;
  Memo: TWPRTFEngineBasis = nil);
var par, ppar: TParagraph;
  ln, aTokenLen, aTokenPos, aIsRange, aRange, i: Integer;
  aToken, ansitext: string;
  aTokenAttr: TSynHighlighterAttributes;
begin
  if FEnabled and (FHL <> nil) then
  begin
    par := StartPar;
    ppar := par.prev;
    if ppar = nil then
      FHL.ResetRange
    else FHL.SetRange(Pointer(par.AGetDef(WPAT_USER2, 0)));
    ln := 0;
    while (par <> nil) and (par <> EndPar) do
    begin
      SetLength(ansitext, par.CharCount);
      for i := 1 to par.CharCount do
        ansitext[i] := Char(Integer(par.CharItem[i - 1]) and 255);
      FHL.SetLine(ansitext, ln);
      while not FHL.GetEol do
      begin
        aTokenPos := FHL.GetTokenPos;
        aToken := FHL.GetToken;
        aTokenLen := Length(aToken);
        aTokenAttr := FHL.GetTokenAttribute;
        if aTokenAttr <> nil then
          ApplyAttr(par, aTokenPos, aTokenLen, aTokenAttr);
        FHL.Next;
      end;
      inc(ln);
      aRange := Integer(FHL.GetRange);
      par := par.next;
      if par <> nil then
      begin
        if (par = EndPar) and not (paprMustInit in par.prop) then
        begin
          aIsRange := par.AGetDef(WPAT_USER2, 0);
          if aIsRange <> aRange then
          begin
            if Memo <> nil then Memo._NeedFullReformat := TRUE;
            ppar := par;
            while ppar <> nil do
            begin
              if ppar.AGet(WPAT_USER2, aIsRange)
                and (aIsRange = aRange) then break;
              include(ppar.prop, paprMustInit);
              ppar := ppar.next;
            end;
          end;
        end;
        par.ASet(WPAT_USER2, aRange);
      end;
    end;
  end;
end;

end.

