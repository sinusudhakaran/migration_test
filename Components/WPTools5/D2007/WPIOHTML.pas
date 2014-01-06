{:: This unit contains the reader and writer classes to support HTML (*.HTM|*.HTML) files }
unit WPIOHTML;

//******************************************************************************
// WPTools V5/6- THE word processing component for VCL and .NET
// Copyright (C) 2004 by WPCubed GmbH and Julian Ziersch, all rights reserved
// WEB: http://www.wpcubed.com   mailto: support@wptools.de
//******************************************************************************
// WPIOHTML - WPTools 5 HTML text writer and reader. Also handles BB codes!
//
// (Replaces WPTools 4 units WPReadHT and WPWriteHT and WPXMLFile)
// 5.6.2007 - improves stability with non "X" HTML
//******************************************************************************

{ COLSPAN: At end of Column create additional column with marker
  ROWSPAN: At given position in next row create column (evtl colspan )
   @page Section1 }

{$DEFINE HTML_CELLS_VALIGN_MIDDLE} //V5.21 DEFAULT vertical "middle" for table cells

{-$DEFINE HTML_ONLYINBODY}//V5.21 - off: default to -onlyinbodytag (switch off with 'outsidebodytag')
// please note that it is often practical to assign some short HTML code (without body tags)
// to footnotes and header/footer

{$DEFINE NO_LISTYLE_IN_CELL} //on-V5.24.4
{$DEFINE NOMARGINS_IN_LIST} //on-V5.24.4
{-$DEFINE TABLEBORDER_AS_STYLE}//off-V5.24.4

{.$DEFINE HIGHLIGHTCOLSPAN}// debug only

{-$DEFINE IGNOREEMPTYHYPERLINKS}

{.$DEFINE DONTAUTOCREATE_NBSP}// if NOT active duplicated #32 will be converted into &nbsp
{$DEFINE USESTDWIDTHHEIGHT}// Write images width/height as pixel values
{.$DEFINE DONT_WRITE_SIMPLE_LISTS}// Don't write simple one level UL / OL lists
{.$DEFINE HTMLWRITEOWNERBLOCKS}//OFF - write owner selected RTFDataBlocks (such as TextBoxes)
{.$DEFINE WPHTMLEXT}//OFF, Experimental HTML Extensions
{.$DEFINE NO_FOOTNOTELINKS}//OFF - only for PremiumEditon - do not save linked footnotes
{.$DEFINE NO_TEXTBOXES}//OFF - only Premium edition - do not save text boxes

// If defined the TWPTextObj.Source overrides the setting of TWPObject.StreamName
// this is used in WPIOWriteRTF, WPOBJ_Image, and WPIO_HTML - also see WPINC.INC
{--$DEFINE WPIMG_USE_SOURCE_AS_LINK}
{--$DEFINE USEBASESTYLES}// Look for styles with the same name of the tag if a class was also specified and assign props
{--$DEFINE DONT_LOAD_LI_INDENTS}// When importing HTML do not apply IndentLeft to <li> items

{--$DEFINE ASSIGN_IMG_PATH}// when loading images <IMG> - also see WPINC.INC

{$DEFINE IGNOREFORM} // TRUE for now
{$DEFINE IGNOREblockquote} // TRUE for now
{.$DEFINE TBLDEBUG}// FALSE

interface
{$I WPINC.INC}

{$IFDEF VER200} //For now - special adaption will be in V6
  {$WARNINGS OFF}
{$ENDIF}

uses Classes, Sysutils, Forms, WPRTEDefs, Graphics, WPIOCSS, Windows;

type (*
TWPHTMLReaderCellDef =  record
  cols    : Integer; // running integer, same number means colspan with previous
  rowspan : Integer; // -1 - decreased for each run
end;

TWPHTMLReaderRowDef = record
  Columns : array of TWPHTMLReaderCellDef;
  end;    *)

  TWPHTMLReaderTableDef = class
  private
    FPrevious: TWPHTMLReaderTableDef;
    FTable: TParagraph;
    RowSpan: array of Integer;
    MaxColCount, ColNr, ColSpan: Integer;
    FInCell, FTableHasBorder: Boolean;
  end;

  TWPHTMLReader = class(TWPCustomTextReader) { from WPTools.RTE.Defs }
  private
    FFontStack: array of TWPCharAttr;
    FFontStackCount: Integer;
    FTempIgnoreOptuseCR: Boolean; // when inside align or center elements!
    FOptIgnoreSTDHTML: Boolean; // -ignorehtml
    FOptNoSpanObjects: Boolean; // -nospanobjects
    FOptIgnoreSpan: Boolean; // -IgnoreSpan
    FOptOnlyInBodyTag: Boolean; //V5.21 -onlyinbodytag
    FOptUTF8: Boolean;
    procedure PushTable;
    procedure PopTable;
    procedure PrintSkippedSpace;
  protected
    FNoText, FInBlockQuote, FTableIsClosed: Boolean;
    FCurrentTable: TWPHTMLReaderTableDef;
    FReadingHead, FReadingStyle, FReadingScript: Boolean;
    FStyleTemplates: TStringList; // [lowercasename=TWPTEXTSTyle]
    FOptuseBBCodes: Boolean; // -useBBCodes
    FOptuseCR: Boolean; // -useCR
    FHasSPC, FNLIsNotSPC, FSkipCRNL : Boolean;
    class function UseForFilterName(const Filtername: string): Boolean; override;
    class function UseForContents(const First500Char: AnsiString): Boolean; override;
    function ParAllowed: Boolean;
  public
    procedure SetOptions(optstr: string); override;
    function Parse(datastream: TStream): TWPRTFDataBlock; override;
    function ProcessBBCode(bbCode: string; var HtmlTag: TWPCustomHTMLTag): Boolean; virtual;
    {:: If this property is true the HTML reader will not use HTML tags. This is useful if also
         useBBCodes is used. }
    property OptIgnoreSTDHTML: Boolean read FOptIgnoreSTDHTML write FOptIgnoreSTDHTML; // -ignorehtml
    {:: This property  is true SPAN tags will be ignored }
    property OptIgnoreSpan: Boolean read FOptIgnoreSpan write FOptIgnoreSpan; // -ignorespan

    {:: This property  is true SPAN tags will not be embedded (but interpreted!) }
    property OptNoSpanObjects: Boolean read FOptNoSpanObjects write FOptNoSpanObjects; // -nospanobjects
    {:: Only allow text inside the body tags. -onlyinbodytag }
    property OptOnlyInBodyTag: Boolean read FOptOnlyInBodyTag write FOptOnlyInBodyTag; // -onlyinbodytag

  end;

  TWPHTMLWriterTableStack =
    record
    MaxCol, CurrCol: Integer;
    DontWriteCellBrd: Boolean;
    FCurrentListInTableCount: Integer;
  end;

  TWPHTMLWriter = class(TWPCustomTextWriter) { from WPTools.RTE.Defs }
  protected
    FDefParStyleNr: Integer;
    FBodyExtra, FBeforeHeader: string;
    FOptWriteBaseFont: Boolean;
    FOptWriteAllFontNames: Boolean;
    FOptWriteSPAN: Boolean;
    FOptDontWriteStyleParam: Boolean;
    FOptWriteAllColWidths: Boolean;
    LastChar: WideChar;
    FSavedStyles: TList;
    FSavedCharStyles: TList;
    FCloseParTag: string;
    FTableStack: array of TWPHTMLWriterTableStack;
    FTableStackPos: Integer;
    FCharAttrOpen, FFontOpen, FSpanOpen: Boolean;
    FCharAttr: TWPStoredCharAttrInterface;
    FCurrentList: TStringList;
    class function UseForFilterName(const Filtername: string): Boolean; override; // RTF, HTML or classname
    function WriteElementStart(RTFData: TWPRTFDataBlock): Boolean; override;
    function WriteElementEnd(RTFData: TWPRTFDataBlock): Boolean; override;
    procedure WriteStyleClass(const StyleName: string);
  public
    constructor Create(RTFDataCollection: TWPRTFDataCollection); override;
    destructor Destroy; override;
    function WriteChar(aChar: Word): Boolean; override;
    procedure SetOptions(optstr: string); override;
    function WriteHeader: Boolean; override;
    function WriteFooter: Boolean; override;
    function WriteParagraphStart(
      par: TParagraph;
      ParagraphType: TWPParagraphType;
      Style: TWPTextStyle): Boolean; override;
    function WriteParagraphEnd(par: TParagraph;
      ParagraphType: TWPParagraphType; NeedNL: Boolean): Boolean; override;
    function WriteObject(txtobj: TWPTextObj; par: TParagraph; posinpar: Integer): Boolean; override;

    function UpdateCharAttr(CharAttrIndex: Cardinal): Boolean; override;
    //:: This text is written inside the BODY tag.
    property BodyExtra: string read FBodyExtra write FBodyExtra;

    //:: Write parameter for <body> tag
    property OptWriteBaseFont: Boolean read FOptWriteBaseFont write FOptWriteBaseFont;
    //:: Write default font name for othewise undefined fonts
    property OptWriteAllFontNames: Boolean read FOptWriteAllFontNames write FOptWriteAllFontNames;

    property OptWriteSPAN: Boolean read FOptWriteSPAN write FOptWriteSPAN;
    //:: Do not write style=".."
    property OptDontWriteStyleParam: Boolean read FOptDontWriteStyleParam write FOptDontWriteStyleParam; //V5.22
    //:: Write all columns with fixed width unless they have defined variable width
    property OptWriteAllColWidths: Boolean read FOptWriteAllColWidths write FOptWriteAllColWidths; //V5.22

  end;

  // Set the URL for the list images used for the bullet and circle list styles
var WPHTMLUL_ListImageURL_circle: string;
  WPHTMLUL_ListImageURL_bullet: string;

implementation

{ ----------------------------------------------------------------------------- }
{$IFNDEF WPPREMIUM}{$DEFINE NO_FOOTNOTELINKS}{$DEFINE NO_TEXTBOXES}{$ENDIF}
uses Math{$IFNDEF NO_TEXTBOXES}, wpobj_textbox{$ENDIF};
{ ----------------------------------------------------------------------------- }

type
  TCodePageDef = record id: Integer; name: string; end;

// http://msdn.microsoft.com/library/default.asp?url=/library/en-us/intl/unicode_81rn.asp
const codepages: array[0..20] of TCodePageDef =
  ((id: 1250; name: 'windows-1250'),
    (id: 1251; name: 'windows-1251'),
    (id: 1252; name: 'windows-1252'),
    (id: 1253; name: 'windows-1253'),
    (id: 1254; name: 'windows-1254'),
    (id: 1255; name: 'windows-1255'),
    (id: 1256; name: 'windows-1256'),
    (id: 1257; name: 'windows-1257'),
    (id: 1258; name: 'windows-1258'),
    (id: 21866; name: 'koi8-u'),
    (id: 28591; name: 'iso-8859-1'),
    (id: 28592; name: 'iso-8859-2'),
    (id: 28593; name: 'iso-8859-3'),
    (id: 28594; name: 'iso-8859-4'),
    (id: 28595; name: 'iso-8859-5'),
    (id: 28596; name: 'iso-8859-6'),
    (id: 28597; name: 'iso-8859-7'),
    (id: 28598; name: 'iso-8859-8'),
    (id: 28599; name: 'iso-8859-9'),
    (id: 28603; name: 'iso-8859-13'),
    (id: 28605; name: 'iso-8859-15'));

class function TWPHTMLWriter.UseForFilterName(const Filtername: string): Boolean;
begin
  Result := inherited UseForFilterName(Filtername)
    or (CompareText(Filtername, 'HTML') = 0)
    or (CompareText(Filtername, 'HTM') = 0)
    ;
end;

constructor TWPHTMLWriter.Create(RTFDataCollection: TWPRTFDataCollection);
begin
  inherited Create(RTFDataCollection);
  FSavedStyles := TList.Create;
  FTableStack := nil;
  FCurrentList := TStringList.Create;
  FTableStackPos := 0;
  FSavedCharStyles := TList.Create;
  FCharAttr := TWPStoredCharAttrInterface.Create(RTFDataCollection);
  FDontSeparateTables := TRUE;
end;

destructor TWPHTMLWriter.Destroy;
begin
  FTableStack := nil;
  FTableStackPos := 0;
  FCurrentList.Free;
  FSavedStyles.Free;
  FSavedCharStyles.Free;
  FCharAttr.Free;
  inherited Destroy;
end;

procedure TWPHTMLWriter.SetOptions(optstr: string);
var i: Integer;
  aoptstr: string;
begin
  i := Pos('-', optstr);
  if i > 0 then
  begin
    aoptstr := lowercase(Copy(optstr, i, Length(optstr) - i + 1)) + ',';
    FOptWriteBaseFont := Pos('-writebasefont,', aoptstr) > 0;
    FOptWriteAllFontNames := Pos('-writeallfontnames,', aoptstr) > 0;
    FOptWriteSPAN := Pos('-writespan,', aoptstr) > 0;
    FOptDontWriteStyleParam := Pos('-dontwritestyleparam,', aoptstr) > 0;
    FOptWriteAllColWidths := Pos('-writeallcolwidths,', aoptstr) > 0;
  end;
  inherited SetOptions(optstr);
end;

function TWPHTMLWriter.WriteElementStart(RTFData: TWPRTFDataBlock): Boolean;
begin
  //- we write the Header first, then the Body
  if (FWrittenBody or (RTFData.Kind = wpIsHeader))
     and not RTFData.Empty //V5.36.1 - do not write an empty header!
  then
  begin
{$IFNDEF HTMLWRITEOWNERBLOCKS}
    if (RTFData.Kind = wpIsOwnerSelected) then
      Result := FALSE
    else
{$ENDIF}
      if (RTFData.Kind = wpIsLoadedBody) then
        Result := FALSE
      else begin
{$IFNDEF NO_FOOTNOTELINKS}
        if RTFData.Kind = wpIsFootnote then
        begin
          WriteString('<a name="#FNT_' + RTFData.Name + '"></a>');
        end;
{$ENDIF}
        Result := TRUE;
        FDefParStyleNr := RTFData.StyleNr;
      end;
  end else Result := FALSE;
end;

function TWPHTMLWriter.WriteElementEnd(RTFData: TWPRTFDataBlock): Boolean;
begin
  // Close existing numbering
  while FCurrentList.Count > 0 do
  begin
    WriteString(FCurrentList[FCurrentList.Count - 1]);
    FCurrentList.Delete(FCurrentList.Count - 1);
  end;
  Result := TRUE;
  FDefParStyleNr := 0;
end;

function TWPHTMLWriter.WriteHeader: Boolean;
var s: string;
  i: Integer;
  fn: TFontName;
begin
  LastChar := #0;
  if FBeforeHeader<>'' then
     WriteString(FBeforeHeader + #13 + #10);
  if not OptOnlyBody then //V5.21.1
    Result := WriteString('<html>' + #13 + #10)
  else Result := true;
  FTableStackPos := -1;
  if not (soOnlyHTMLBody in FHTMLStoreOptions) and not OptOnlyBody then
  begin
    WriteString('<head>');
    // Since the character are written as unicode this code makes only
    // a difference for other strings
    {if (OptCodePage<>0) and (OptCodePage<>1252) then
        WriteString('<meta http-equiv=Content-Type content="text/html; charset=windows-' +
                    IntToStr(OptCodePage) + '">');  }
     // Write Title
    s := FRTFDataCollection.RTFVariables.Strings['Title'];
    if s = '' then s := FRTFDataCollection.RTFVariables.Strings['Subject'];
    if s <> '' then
    begin
      WriteString('<title>');
      WriteString(s);
      WriteString('</title>');
    end;

    if CssPath <> '' then
    begin
      WriteString('<link rel="stylesheet" href="' + CssPath + '"/>');
    end else
      if not (soDontWriteStyleSheet in FHTMLStoreOptions) and
        (FRTFProps.ParStyles.Count > 0) then
      begin
        WriteString(#13 + #10 + '<style><!--' + #13 + #10);
        for i := 0 to FRTFProps.ParStyles.Count - 1 do
          if FRTFProps.ParStyles[i].Name <> '' then
          begin
          //V5.18.3 start class with '.'
            if (Pos('.', FRTFProps.ParStyles[i].Name) <= 0) and
              (Pos('#', FRTFProps.ParStyles[i].Name) <= 0) then WriteString('.');

            WriteString(FRTFProps.ParStyles[i].Name);
            WriteString('{');
            WriteString(FRTFProps.ParStyles[i].TextStyle.AGet_CSS(true, true, false, true));
            WriteString('}' + #13 + #10);
          end;
        WriteString(#13 + #10 + '--></style>');
      end;
  // Save StyleSheet ?  (FSavedStyles) !
  // Meta Tags !
    WriteString('</head>');
    if BodyExtra <> '' then //V5.15.6
    begin
      WriteString('<body' + #32);
      WriteString(BodyExtra);
      WriteString('>' + #13 + #10);
    end
    else WriteString('<body>' + #13 + #10);
  end;

  if OptWriteBaseFont or (soWriteBasefontTag in FHTMLStoreOptions) then
  begin
    WriteString('<basefont face="');
    if FRTFDataCollection.DefaultAttr.GetFontName(fn) then
      WriteString(fn)
    else WriteString(DefaultFontName);
    WriteString('"/>');
  end;
end;

function TWPHTMLWriter.WriteFooter: Boolean;
begin
  // Close existing numbering
  while FCurrentList.Count > 0 do
  begin
    WriteString(FCurrentList[FCurrentList.Count - 1]);
    FCurrentList.Delete(FCurrentList.Count - 1);
  end;

  {if soWriteBasefontTag in FHTMLStoreOptions then
    WriteString('</basefont>'); }

  if not (soOnlyHTMLBody in FHTMLStoreOptions) and not OptOnlyBody then
  begin
    WriteString('</body>');
    Result := WriteString('</html>');
  end else Result := true;
end;

{$WARNINGS OFF}

procedure TWPHTMLWriter.WriteStyleClass(const StyleName: string);
var i: Integer;
begin
  if StyleName <> '' then
  begin
    i := Pos('#', StyleName);
    if i > 0 then
      WriteString(' id="' + Copy(StyleName, i + 1, Length(StyleName)) + '"')
    else if StyleName[1] = '.' then
      WriteString(' class="' + Copy(StyleName, 2, Length(StyleName)) + '"')
    else WriteString(' class="' + StyleName + '"');
  end;
end;

function TWPHTMLWriter.WriteParagraphStart(
  par: TParagraph;
  ParagraphType: TWPParagraphType;
  Style: TWPTextStyle): Boolean;
var
  val, i, brd: Integer;
  FNeedNSP, SameBrd: Boolean;
  StyleName: string;
  aPar, aCell: TParagraph;
{$IFNDEF DONT_WRITE_SIMPLE_LISTS}
  nsty: TWPTextStyle;
  numlevel: Integer;
  skipnumber: Boolean;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure StartULOL;
  var s: string;
  begin
    s := '</ol>';
    case nsty.AGetDef(WPAT_NumberMODE, WPNUM_BULLET) of
      WPNUM_BULLET:
        begin
          s := '</ul>';
          WriteString('<ul style="list-style-type:bullet;');
          if WPHTMLUL_ListImageURL_bullet <> '' then
            WriteString('list-style-image:url(' + WPHTMLUL_ListImageURL_bullet + ');');
          WriteString('">');
        end;
      WPNUM_CIRCLE:
        begin
          s := '</ul>';
          WriteString('<ul style="list-style-type:circle;');
          if WPHTMLUL_ListImageURL_circle <> '' then
            WriteString('list-style-image:url(' + WPHTMLUL_ListImageURL_circle + ');');
          WriteString('">');
        end;
      WPNUM_UP_ROMAN:
        begin
          WriteString('<ol type="I">');
        end;
      WPNUM_LO_ROMAN:
        begin
          WriteString('<ol type="i">');
          WriteString('<ul>');
        end;
      WPNUM_UP_LETTER:
        begin
          WriteString('<ol type="A">');
        end;
      WPNUM_LO_LETTER:
        begin
          WriteString('<ol type="a">');
        end;
    else // WPNUM_ARABIC
      begin
        WriteString('<ol type="1">');
      end;
    end;
    FCurrentList.AddObject(s, nsty);
  end;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{$ENDIF}
var s: string; bNoParStyles: Boolean;
begin
  LastChar := #0;
  FCloseParTag := '';
  bNoParStyles := FALSE;
  if ((paprColMerge in par.prop) and (par.CharCount = 0)) or (paprRowMerge in par.prop) then
  begin
    Result := TRUE;
    exit;
  end;

  if (par.PrevPar = nil) and (par.ParentPar <> nil) and (paprIsTable in par.ParentPar.prop) then
  begin
    UpdateCharAttr(Cardinal(-1));

    // Close table started in first par
    if (FCurrentList.Count > 0) then
    begin
      WriteString('</li>')
    end;
  end;

  last_charattr_index := Cardinal(-1);
  (* while true do
  begin *)
  // Save Style: ---------------------------------------------------------------
  (*
  if par.Style <> 0 then
  begin
{$IFDEF CLR}
    sty := FSavedStyles.IndexOf(IntPtr.Create(par.Style)) + 1;
{$ELSE}
    sty := FSavedStyles.IndexOf(Pointer(par.Style)) + 1;
{$ENDIF}
    // if sty = 0 then sty := SaveStyle(par.Style, par.ABaseStyle);
  end else sty := 0;   *)
  // ---------------------------------------------------------------------------

  if paprIsTable in par.prop then
  begin
    WriteString('<');
    WriteString('td');

    FNeedNSP := par.Empty([], false);

    if FTableStackPos >= 0 then
      inc(FTableStack[FTableStackPos].CurrCol);

    if par.Style <> 0 then
      StyleName := FRTFProps.ParStyles.GetStyleName(par.Style)
    else if FDefParStyleNr <> 0 then
      StyleName := FRTFProps.ParStyles.GetStyleName(FDefParStyleNr)
    else StyleName := '';
    WriteStyleClass(StyleName);

    s := par.AGet_CSS(true, true, false, (FTableStackPos < 0) or
      not FTableStack[FTableStackPos].DontWriteCellBrd); // AddBorderProps!

    if par.AGet(WPAT_COLWIDTH, val) then
    begin
      if OptDontWriteStyleParam{$IFDEF USESTDWIDTHHEIGHT} or true{$ENDIF} then
      begin
        WriteString(' width=');
        WriteInteger(MulDiv(val, CSSPixelsPerInch, 1440));
      end
      else s := s + 'width:' + WPTwipsToCSSInch(val) + ';';
    end else
      if par.AGet(WPAT_COLWIDTH_PC, val) then
      begin
        if OptDontWriteStyleParam{$IFDEF USESTDWIDTHHEIGHT} or true{$ENDIF} then
        begin
          WriteString(' width=');
          WriteInteger(val div 100);
          WriteString('%');
        end
        else s := s + Format('width:%d%%;', [val div 100]{$IFDEF FMS}, WPToolsFormatSettings{$ENDIF});
      end
      else if OptWriteAllColWidths then
      begin
        if OptDontWriteStyleParam{$IFDEF USESTDWIDTHHEIGHT} or true{$ENDIF} then
        begin
          WriteString(' width=');
          WriteInteger(MulDiv(par._IsWidthTw, CSSPixelsPerInch, 1440));
        end
        else s := s + 'width:' + WPTwipsToCSSInch(par._IsWidthTw) + ';';
      end;

    // Write COLSPAN and ROWSPAN

    if (par.NextPar = nil) and (FTableStackPos >= 0) then
    begin
      if FTableStack[FTableStackPos].CurrCol < FTableStack[FTableStackPos].MaxCol then
        i := FTableStack[FTableStackPos].MaxCol - FTableStack[FTableStackPos].CurrCol
      else i := 0;
    end else i := par.ColSpan;

    if i > 0 then
    begin
      WriteString(' colspan=');
      WriteInteger(i + 1);
      if FTableStackPos >= 0 then
        inc(FTableStack[FTableStackPos].CurrCol, i);
    end;

    if par.AGet(WPAT_VertAlignment, i) then
    begin
      case i of
        0: WriteString(' valign=top');
        1: WriteString(' valign=middle');
        2: WriteString(' valign=bottom');
        3: WriteString(' valign=middle');
      end;
    end { - done in ROW!
    else WriteString(' valign=top')}
      ;

    i := par.RowSpan;
    if i > 0 then
    begin
      WriteString(' rowspan=');
      WriteInteger(i + 1);
    end;

    if not OptDontWriteStyleParam and (s <> '') then
      WriteString(' style="' + s + '"');

  // ----- name and base style -------------------------------------------------
    if par.Name <> '' then
    begin
      WriteString(' name="');
      WriteHTMLString(par.Name);
      WriteString('"');
    end;

    Result := WriteString('>');
{$IFNDEF DONT_WRITE_SIMPLE_LISTS}
    nsty := par.GetNumberStyle(numlevel, skipnumber);
    if nsty <> nil then
    begin
      if FCurrentList.Count = FTableStack[FTableStackPos].FCurrentListInTableCount then StartULOL;
      WriteString('<li>');
    end;
{$ENDIF}
  end
  else if (ParagraphType = wpIsTable) and // V5.25 - Don't write empty table
    (par.ChildPar <> nil) then
  begin
    WriteString('<table');

    inc(FTableStackPos);
    if FTableStackPos >= Length(FTableStack) then
      SetLength(FTableStack, Length(FTableStack) + 20);
    FTableStack[FTableStackPos].FCurrentListInTableCount := FCurrentList.Count;

    FTableStack[FTableStackPos].MaxCol := 0;
    aPar := par.ChildPar;
    brd := -1;

    SameBrd := TRUE;
    while aPar <> nil do
    begin
      i := aPar.ChildrenCount;
      if i > FTableStack[FTableStackPos].MaxCol then FTableStack[FTableStackPos].MaxCol := i;
      aCell := aPar.ChildPar;
      while SameBrd and (aCell <> nil) do
      begin
        i := aCell.AGetDefInherited(WPAT_BorderFlags, 0);
        if brd < 0 then brd := i
        else if aPar.NextPar = nil then
        begin
          if (brd <> (i and not WPBRD_DRAW_Bottom)) or ((i and WPBRD_DRAW_Right) = 0)
            then SameBrd := FALSE;
        end
        else if brd <> i then SameBrd := FALSE;
        aCell := aCell.NextPar;
      end;
      aPar := aPar.NextPar;
    end;
    FTableStack[FTableStackPos].CurrCol := 0;

    if par.Style <> 0 then
      StyleName := FRTFProps.ParStyles.GetStyleName(par.Style)
    else if FDefParStyleNr <> 0 then
      StyleName := FRTFProps.ParStyles.GetStyleName(FDefParStyleNr)
    else StyleName := '';
    WriteStyleClass(StyleName);

    s := par.AGet_CSS(true, true, false, true);
    if s = '' then s := 'padding:0px;margin:0px;';

    if SameBrd then
    begin
      if brd <= 0 then
      begin
        WriteString(' border=0');
        FTableStack[FTableStackPos].DontWriteCellBrd := TRUE;
      end
      else
      begin
{$IFDEF TABLEBORDER_AS_STYLE}
        //NO - only create line around table!
        //s := s + 'border-style:solid;border-width:1px;';
{$ELSE}
        WriteString(' border=1');
        FTableStack[FTableStackPos].DontWriteCellBrd := TRUE;
{$ENDIF}
      end;

    end else
      FTableStack[FTableStackPos].DontWriteCellBrd := FALSE;

    if par.AGet(WPAT_BoxWidth, i) then
    begin
      if OptDontWriteStyleParam{$IFDEF USESTDWIDTHHEIGHT} or true{$ENDIF} then
      begin
        WriteString(' width=');
        WriteInteger(MulDiv(i, WPScreenPixelsPerInch, 1440));
      end else
        s := s + 'width:' + WPTwipsToCSSInch(i) + ';';
    end else if par.AGet(WPAT_BoxWidth_PC, i) then
    begin
      if OptDontWriteStyleParam{$IFDEF USESTDWIDTHHEIGHT} or true{$ENDIF} then
      begin
        WriteString(' width=');
        WriteInteger(i div 100);
        WriteString('%');
      end else
        s := s + Format('width:%d%%;', [i div 100]{$IFDEF FMS}, WPToolsFormatSettings{$ENDIF});
    end else
      WriteString(' width=100%');

    if not OptDontWriteStyleParam then
      WriteString(' style="' + s + '"'); // padding:0px;margin:0px;

  // ----- name and base style -------------------------------------------------
    if par.Name <> '' then
    begin
      WriteString(' name="');
      WriteHTMLString(par.Name);
      WriteString('"');
    end;

    Result := WriteString('>');

  end
  else if ParagraphType = wpIsTableRow then
  begin
    WriteString('<tr');
    if FTableStackPos >= 0 then
      FTableStack[FTableStackPos].CurrCol := 0;

    if par.Style <> 0 then
      StyleName := FRTFProps.ParStyles.GetStyleName(par.Style)
    else if FDefParStyleNr <> 0 then
      StyleName := FRTFProps.ParStyles.GetStyleName(FDefParStyleNr)
    else StyleName := '';
    WriteStyleClass(StyleName);

    if par.AGet(WPAT_VertAlignment, i) then
    begin
      case i of
        0: WriteString(' valign=top');
        1: WriteString(' valign=middle');
        2: WriteString(' valign=bottom');
        3: WriteString(' valign=middle');
      end;
    end
    else WriteString(' valign=top');

    s := par.AGet_CSS(true, true, false,
      (FTableStackPos < 0) or
      not FTableStack[FTableStackPos].DontWriteCellBrd);

    // V5.18.3 WPTOOLS tag to create a new page.
    if paprNewPage in par.prop then
      s := s + 'page-break-before:always;';

    if not OptDontWriteStyleParam and (s <> '') then
      WriteString(' style="' + s + '"');

  // ----- name and base style -------------------------------------------------
    if par.Name <> '' then
    begin
      WriteString(' name="');
      WriteHTMLString(par.Name);
      WriteString('"');
    end;

    Result := WriteString('>');
  end else
  // ------------ text --------------
  begin
    if par.Style <> 0 then
      StyleName := FRTFProps.ParStyles.GetStyleName(par.Style)
    else if FDefParStyleNr <> 0 then
      StyleName := FRTFProps.ParStyles.GetStyleName(FDefParStyleNr)
    else StyleName := '';
    if StyleName <> '' then
    begin
      i := Pos('.', StyleName);
      if i > 0 then
      begin
        FCloseParTag := Copy(StyleName, 1, i - 1);
        StyleName := Copy(StyleName, i + 1, 255);
      end;
    end;

    // Create UL and OL tags -------------------------------------------- 5.17.2
{$IFNDEF DONT_WRITE_SIMPLE_LISTS}
    nsty := par.GetNumberStyle(numlevel, skipnumber);

    // Close existing numbering
    if (FCurrentList.Count > 0)
      and
      ((nsty = nil) or //V5.25.1
      (nsty <> FCurrentList.Objects[FCurrentList.Count - 1])
      ) then
    begin
      WriteString(FCurrentList[FCurrentList.Count - 1]);
      FCurrentList.Delete(FCurrentList.Count - 1);
    end;

    if (nsty <> nil) then
    begin
      if FCurrentList.Count = 0 then
      begin
        StartULOL;
      end;
{$IFDEF NO_LISTYLE_IN_CELL}
      if par.Cell <> nil then
      begin
        WriteString('<li>');
        bNoParStyles := TRUE;
        FNeedNSP := FALSE;
      end
      else
{$ENDIF}
        WriteString('<li');
    end else
{$ENDIF}
    // -------------------------------------------------------------------------
      if FCloseParTag <> '' then
      begin
        WriteString('<');
        WriteString(FCloseParTag);
      end
      else
      begin
        WriteString('<');
        s := par.AClass;
        if (s <> '') and ((par.ParagraphType <> wpIsTable) or (par.ChildPar <> nil)) then WriteString(s)
        else WriteString('div');
      end;
    if not bNoParStyles then
    begin
      WriteStyleClass(StyleName);
      FNeedNSP := par.CharCount = 0;

    // -------- WPSTYLE ----------------------------------------------------------
      s := par.AGet_CSS(true, false, false, par.Cell = nil
{$IFDEF NOMARGINS_IN_LIST}
        , par.Number > 0 //V5.21 - no margins in lists
{$ELSE}
        , false //V5.24.4
{$ENDIF}
        ); // no borders in table cells

    // V5.18.3 WPTOOLS tag to create a new page.
      if paprNewPage in par.prop then
        s := s + 'page-break-before:always;';

      if OptDontWriteStyleParam then
      begin
        if par.AGet(WPAT_Alignment, i) then
          case i of
            0: WriteString(' align=left');
            1: WriteString(' align=center');
            2: WriteString(' align=right');
            3: WriteString(' align=justify');
          end;
      end else
        if (s <> '') then
        begin
          WriteString(' style="');
          WriteHTMLString(s);
          WriteString('"');
        end;

      if par.Name <> '' then
      begin
        WriteString(' name="');
        WriteHTMLString(par.Name);
        WriteString('"');
      end;

      Result := WriteString('>');
    end;
  end;

  // Write at least a non breaking space
  if FNeedNSP and not (spDontWriteNBSP in FHTMLStoreOptions) and
    not (par.ParagraphType in [wpIsTable, wpIsTableRow]) and (par.ChildPar = nil) then
    WriteString('&nbsp;');
end;
{$WARNINGS ON}

function TWPHTMLWriter.WriteChar(aChar: Word): Boolean;
begin
  if aChar = 10 then
    Result := WriteString('<br/>')
{$IFNDEF DONTAUTOCREATE_NBSP}
  else if (LastChar = #32) and (aChar = 32) then
    Result := WriteString('&nbsp;')
{$ENDIF}
  else Result := WriteHTMLChar(WideChar(aChar));
  LastChar := WideChar(aChar);
end;

function TWPHTMLWriter.WriteParagraphEnd(par: TParagraph;
  ParagraphType: TWPParagraphType; NeedNL: Boolean): Boolean;
var s: string;
begin
  UpdateCharAttr(0);

  if (ParagraphType = wpIsTable) and (FTableStackPos >= 0) then
  begin
    dec(FTableStackPos);
  end;

  if (paprColMerge in par.prop) and (par.CharCount = 0) then // V5.18.10
  begin
    Result := TRUE;
    exit;
  end;

  if paprIsTable in par.prop then
  begin
     // Close the lists which might be used inside of this table
    while FCurrentList.Count > FTableStack[FTableStackPos].FCurrentListInTableCount do
    begin
      WriteString(FCurrentList[FCurrentList.Count - 1]);
      FCurrentList.Delete(FCurrentList.Count - 1);
    end;
    WriteString('</td');
  end
  else if (FCurrentList.Count > 0) and (par.ParagraphType = wpIsSTDPar) then
    WriteString('</li')
  else if FCloseParTag <> '' then
  begin
    WriteString('</');
    WriteString(FCloseParTag);
  end
  else
  begin
    WriteString('</');
    s := par.AClass;
    if (s <> '') and ((par.ParagraphType <> wpIsTable) or (par.ChildPar <> nil)) then WriteString(s)
    else WriteString('div');
  end;
  Result := WriteString('>' + #13 + #10);
  FCloseParTag := '';
  LastChar := #0;
end;

function TWPHTMLWriter.WriteObject(txtobj: TWPTextObj; par: TParagraph; posinpar: Integer): Boolean;
var
  sty: TWPTextStyle;
  stylename, s, fnam: string;
  FRestoreCharAttr: Cardinal;
  DontSave: Boolean;
  obj: TWPObject;
{$IFDEF IGNOREEMPTYHYPERLINKS}txtobj2: TWPTextObj; {$ENDIF}
{$IFNDEF FMS}c: Char; {$ENDIF}
{$IFNDEF NO_TEXTBOXES}b: TWPRTFDataBlock; {$ENDIF}
  procedure ImageAlign;
  begin
    if (wpobjRelativeToParagraph in txtobj.Mode) or
      (wpobjRelativeToPage in txtobj.Mode) then
    begin
      if wpobjPositionAtRight in txtobj.Mode then
        WriteString(' align="right"')
      else if wpobjPositionAtCenter in txtobj.Mode then
        WriteString(' align="center"')
      else // if wpobjRelativeToParagraph in txtobj.Mode then // We cannot position it
      begin
        if txtobj.RelX > (RTFDataCollection.Header.PageWidth -
          RTFDataCollection.Header.LeftMargin - RTFDataCollection.Header.RightMargin -
          txtobj.Width) div 2 then
          WriteString(' align="right"')
        else WriteString(' align="left"');
      end;
    end;
  end;
begin
  Result := TRUE;

  if wpobjUsedPairwise in txtobj.Mode then
  begin
    FRestoreCharAttr := FCharAttr.CharAttr;
    UpdateCharAttr(0);
  end else  FRestoreCharAttr := 0;

  if txtobj.ObjType = wpobjImage then
  begin
    DontSave := FALSE;
    fnam := '';
    PrepareImageforSaving(txtobj, DontSave, fnam); // execute event
    if not DontSave then
    begin
      obj := txtobj.ObjRef;
{$IFNDEF FMS}
      c := DecimalSeparator;
      DecimalSeparator := '.';
{$ENDIF}
{$IFNDEF NO_TEXTBOXES} //only for "Premium" Edition!
      if _WPCheck2(txtobj, b) then
      begin
        WriteString('<textbox name="'); WriteString(txtobj.Name);
        WriteString('" w='); WriteInteger(txtobj.Width);
        WriteString(' h='); WriteInteger(txtobj.Height);
        WriteString(' x='); WriteInteger(txtobj.RelX);
        WriteString(' y='); WriteInteger(txtobj.RelY);
        WriteString('><textcode><table border=0 style="padding:0;margins:0"');
        ImageAlign; WriteString('><tr><td></textcode>');
        _rtfdataobj := b; PushBLOCK; UpdateCharAttr($FFFFFFFF); WriteBody; PopBLOCK; _rtfdataobj := nil;
        last_charattr_index := $FFFFFF;
        WriteString('<textcode></td></tr></table></textcode></textbox>');
      end else {$ENDIF}
      begin
{$IFDEF WPIMG_USE_SOURCE_AS_LINK}
        if fnam = '' then
          fnam := txtobj.Source;
{$ELSE}
        //fnam := '';
{$ENDIF}
        if (fnam = '') and (obj <> nil) then
          fnam := obj.FileName;
        if (fnam = '') and (obj <> nil) then
          fnam := obj.StreamName;

     // Before WRITE HTML Images
        if fnam <> '' then
        begin
          {$IFDEF ADDIMG_CID}
          if Copy(fnam ,1,4) <> 'cid:' then
          fnam := 'cid:' + fnam;
          {$ENDIF}
          WriteString('<img src="');
          WriteString(fnam);
          WriteString('"');

          ImageAlign;

          if OptDontWriteStyleParam{$IFDEF USESTDWIDTHHEIGHT} or true{$ENDIF} then
          begin
            WriteString(
              Format(' width=%d height=%d',
              [MulDiv(txtobj.Width, CSSPixelsPerInch, 1440),
              MulDiv(txtobj.Height, CSSPixelsPerInch, 1440)]{$IFDEF FMS}, WPToolsFormatSettings{$ENDIF}));
            s := '';
          end else
          begin
            s := 'width:' + WPTwipsToCSSInch(txtobj.Width) +
              ';height:' + WPTwipsToCSSInch(txtobj.Height) + ';';
          end;

        // This only works on first page!!!
        (*
        if wpobjRelativeToPage in txtobj.Mode then
        begin
            s := s +  Format('position:absolute;top:%0.2fin;left:%0.2fin;',
               [txtobj.RelY/1440,txtobj.RelX/1440]{$IFDEF FMS}, WPToolsFormatSettings{$ENDIF});
            if wpobjObjectUnderText in txtobj.Mode then
              s := s + 'z-order:-1;'
        end; *)

          if not OptDontWriteStyleParam and (s <> '') then
          begin
            WriteString(' style="');
            WriteString(s);
            WriteString('"');
          end;
          WriteString('/>');
        end;
{$IFNDEF FMS}
        DecimalSeparator := c;
{$ENDIF}
      end;
    end;
  end else
{$IFDEF WPPREMIUM}
    if (txtobj.ObjType = wpobjTextObject) and (txtobj.Name = 'SYMBOL') and (txtobj.Source = 'FOOTNR') then
    begin
      WriteString('<sup>');
      WriteString(txtobj.Params);
      WriteString('</sup>)');
    end else
{$ENDIF}
    try
      if (txtobj.ObjType = wpobjSPANStyle) then stylename := txtobj.Name
      else stylename := '';

      if stylename <> '' then
      begin
        sty := RTFProps.ParStyles.FindTextStyle(txtobj.Name);
        if sty = nil then
          sty := RTFProps.ParStyles.FindTextStyle('.' + txtobj.Name);
        if sty <> nil then
        begin

      // stynr := FSavedStyles.IndexOf(Pointer(RTFProps.ParStyles.CurrID)) + 1;

      // if stynr = 0 then SaveStyle(RTFProps.ParStyles.CurrID, sty);
        end;
      end;
      if (wpobjUsedPairwise in txtobj.Mode) and (wpobjIsOpening in txtobj.Mode) then
      begin
        if txtobj.ObjType = wpobjMergeField then
        begin
          WriteString('<mergefield name="');
          WriteString(txtobj.Name);
          WriteString('"');
          if txtobj.Source <> '' then
          begin
            WriteString(' command="');
            WriteString(txtobj.Source);
            WriteString('"');
          end;
          WriteString('>');
        end else
          if txtobj.ObjType = wpobjHyperlink then
          begin
{$IFDEF IGNOREEMPTYHYPERLINKS}
            txtobj2 := txtobj.EndTag;
            if (txtobj2 = nil) or
              ((txtobj2.ParentPar = txtobj.ParentPar) and
              (txtobj2.ParentPosInPar = txtobj.ParentPosInPar + 1)) then
            begin
             // Ignore this object
            end else
{$ENDIF}
            begin
              WriteString('<a href="');
              s := txtobj.Source;

        {Convert \l "..." Word hyperlinks into internal HTML hyperlinks }
              if (Length(s) > 3) and (s[1] = '\') and (s[2] = 'l') and (s[3] <= #32) then
              begin
                s := AnsiDequotedStr(Copy(s, 4, 255), '"');
              end else s := AnsiDequotedStr(s, '"'); ;

              WriteString(s);
              WriteString('"');
              if txtobj.Name <> '' then
              begin
                WriteString(' title="');
                WriteString(AnsiDequotedStr(txtobj.Name, '"'));
                WriteString('"');
              end;

              if not OptDontWriteStyleParam and (txtobj.Style <> nil) then
              begin
                WriteString(' style="');
                WriteString(txtobj.Style.AGet_CSS(true, false, false, true));
                WriteString('"');
              end;
              WriteString('>');
            end;
          end
          else if txtobj.ObjType = wpobjBookmark then
          begin
            WriteString('<a name="');
            WriteString(txtobj.Name);
            WriteString('"');
            if txtobj.Source <> '' then
            begin
              WriteString(' title="');
              WriteString(txtobj.Source);
              WriteString('"');
            end;
            WriteStyleClass(txtobj.StyleName);

            if not OptDontWriteStyleParam and (txtobj.Style <> nil) then
            begin
              WriteString(' style="');
              WriteString(txtobj.Style.AGet_CSS(true, false, false, true));
              WriteString('"');
            end;
            WriteString('>');
          end
          else if txtobj.ObjType = wpobjSPANStyle then
          begin
            WriteString('<span');
            WriteStyleClass(txtobj.StyleName);
            if txtobj.Name <> '' then
            begin
              WriteString(' title="');
              WriteString(txtobj.Name);
              WriteString('"');
            end;
        // Style - either from object or from 'Source'
            if not OptDontWriteStyleParam and (txtobj.Style <> nil) then
            begin
              WriteString(' style="');
              WriteString(txtobj.Style.AGet_CSS(true, false, false, true));
              WriteString('"');
            end else
              if txtobj.Source <> '' then
              begin
                WriteString(' style="');
                WriteString(txtobj.Source);
                WriteString('"');
              end;
            WriteString('>');
          end
      end
      else if (wpobjUsedPairwise in txtobj.Mode) and (wpobjIsClosing in txtobj.Mode) then
      begin
        if txtobj.ObjType = wpobjHyperlink then
        begin
{$IFDEF IGNOREEMPTYHYPERLINKS}
          txtobj2 := txtobj.StartTag;
          if (txtobj2 = nil) or
            ((txtobj2.ParentPar = txtobj.ParentPar) and
            (txtobj2.ParentPosInPar = txtobj.ParentPosInPar - 1)) then
          begin
             // Ignore this object
          end else
{$ENDIF}
            WriteString('</a>');
        end
        else if txtobj.ObjType = wpobjBookmark then
        begin
          WriteString('</a>');
        end
        else if txtobj.ObjType = wpobjSPANStyle then
          WriteString('</span>')
        else if txtobj.ObjType = wpobjMergeField then
          WriteString('</mergefield>');
      end else
      begin
        if txtobj.ObjType = wpobjHorizontalLine then
        begin
          WriteString('<hr/>');
        end else
          if txtobj.ObjType = wpobjFootnote then
          begin
            WriteString('<footnote><sup>');
{$IFNDEF NO_FOOTNOTELINKS}
            WriteString('<a name="#FNN_' + txtobj.Name
              + '" href="#FNT_' + txtobj.Name + '">');
{$ENDIF}
            WriteInteger(txtobj.CParam);
{$IFNDEF NO_FOOTNOTELINKS}
            WriteString('</a>');
{$ENDIF}
            WriteString('</sup></footnote>');
          end
          else if txtobj.ObjType = wpobjTextObject then
          begin
        { Now you can insert a TWPTextObj, gibve it the name 'HTMLCODE' and add
          some HTML tags to property 'Source'. }
            if txtobj.Name = 'HTMLCODE' then
            begin
              WriteString(txtobj.Source);
            end else
        // Symbols
              if txtobj.Name = 'UNICODEC' then
              begin
                if txtobj.CParam = 2013 then
                begin
                  WriteString('-');
                end
                else if txtobj.CParam = 2014 then
                begin
                  WriteString('-');
                end else
                begin
                  WriteString('&#$');
                  WriteString(IntToHex(txtobj.CParam, 4));
                  WriteString(';');
                end;
              end else
              begin
           // Page number etc ...
                WriteString('<textobj name="');
                WriteString(txtobj.Name);
                WriteString('"');

                if txtobj.Source <> '' then
                begin
                  WriteString(' source="');
                  WriteHTMLString(txtobj.Source);
                  WriteString('"');
                end;

                if txtobj.IParam > 0 then
                begin
                  WriteString(' iparam=');
                  WriteInteger(txtobj.IParam);
                end;

                if txtobj.Params <> '' then
                begin
                  WriteString('>');
                  if (FRTFData.Kind = wpIsFootnote) and
                    (CompareText(txtobj.Name, 'SYMBOL') = 0) and
                    (CompareText(txtobj.Source, 'FOOTNR') = 0) then
                    WriteString('<a href="#FNN_' + FRTFData.Name + '">' +
                      txtobj.Params + '</a>') else
                    WriteHTMLString(txtobj.Params);
                  WriteString('</textobj>');
                end
                else WriteString('/>'); ;

              end;
          end else
            if (txtobj.ObjType = wpobjImage) then
            begin
         // WRITE IMG
         //TODO:   txtobj.ObjRef <> nil
            end;
      end;
    finally
    if FRestoreCharAttr <> 0 then
    begin
      UpdateCharAttr(FRestoreCharAttr);
    end;
    end;
  LastChar := #0;
end;

type
  TWP_HTML_FONTSIZE =
    record
    smin, smax: Integer; // range: [smin, smax]
    snumber: Integer; // Translated into ...
    ssize: Integer; // applied at read time
  end;

const
  WP_HTML_FONTSIZEMAX = 7;
var
  // 8,10,12,14,18,24,36
  WPHTFONTSIZES: array[1..WP_HTML_FONTSIZEMAX] of
  TWP_HTML_FONTSIZE =
    ((smin: 0; smax: 8; snumber: 1; ssize: 8),
    (smin: 9; smax: 10; snumber: 2; ssize: 10),
    (smin: 11; smax: 12; snumber: 3; ssize: 12),
    (smin: 13; smax: 16; snumber: 4; ssize: 14),
    (smin: 17; smax: 22; snumber: 5; ssize: 18),
    (smin: 23; smax: 28; snumber: 6; ssize: 24),
    (smin: 29; smax: 255; snumber: 7; ssize: 36));

function TWPHTMLWriter.UpdateCharAttr(CharAttrIndex: Cardinal): Boolean;
var oldstyles, substyles, addstyles, stylesA, stylesB: WrtStyle;
  procedure SaveAttr(styles: WrtStyle; ele: TOneWrtStyle; const str: string);
  begin
    if ele in styles then
    begin
      WriteString('<');
      WriteString(str);
      WriteString('>');
    end;
  end;
var fontparam: string;
  FontNr, i, a: Integer;
  FontSize: Single;
  aColor: TColor;
  aFontName: TFontName;
begin
  stylesA := []; 
  stylesB := []; 
  if FSpanOpen then
  begin
    WriteString('</span>');
    FSpanOpen := FALSE;
  end;

  if FFontOpen then
  begin
    WriteString('</font>');
    FFontOpen := FALSE;
  end;

  if FCharAttrOpen then
  begin
    FCharAttr.GetStyles(stylesA);
    stylesA := stylesA * [afsSub, afsSuper, afsBold, afsItalic, afsStrikeOut, afsUnderline];
  end;

  if CharAttrIndex <> $FFFFFFFF then
  begin
    FCharAttr.CharAttr := CharAttrIndex;
    if CharAttrIndex > 0 then
    begin
      FCharAttr.GetStyles(stylesB);
      stylesB := stylesB * [afsSub, afsSuper, afsBold, afsItalic, afsStrikeOut, afsUnderline];
    end;
    if soStrictXHTML in FHTMLStoreOptions then
    begin
      if stylesA <> stylesB then
      begin
        substyles := stylesA;
        addstyles := stylesB;
      end else
      begin
        substyles := [];
        addstyles := [];
      end;
    end else
    begin
      oldstyles := stylesA * stylesB;
      substyles := stylesA - oldstyles;
      addstyles := stylesB - oldstyles;
    end;
    if substyles <> [] then
    begin
      SaveAttr(substyles, afsSub, '/sub');
      SaveAttr(substyles, afsSuper, '/sup');
      SaveAttr(substyles, afsBold, '/b');
      SaveAttr(substyles, afsItalic, '/i');
      SaveAttr(substyles, afsStrikeOut, '/s');
      SaveAttr(substyles, afsUnderline, '/u');
    end;
    if addstyles <> [] then
    begin
      FCharAttrOpen := TRUE;
      SaveAttr(addstyles, afsUnderline, 'u');
      SaveAttr(addstyles, afsStrikeOut, 's');
      SaveAttr(addstyles, afsItalic, 'i');
      SaveAttr(addstyles, afsBold, 'b');
      SaveAttr(addstyles, afsSuper, 'sup');
      SaveAttr(addstyles, afsSub, 'sub');
    end
    else
      if oldstyles = [] then FCharAttrOpen := FALSE;

    fontparam := '';

    // V5.40.1  : FCharAttr.GetBGColorNr(a) and (a>0)
    if FCharAttr.GetBGColorNr(a) and (a>0) and  FCharAttr.GetBGColor(aColor) then
    begin
      fontparam := fontparam + 'background.color:' + WPColorToString(aColor) + ';';
    end;

    if OptWriteSPAN or (soSPANInsteadOfFontTag in FHTMLStoreOptions) then
    begin
      if FCharAttr.GetColor(aColor) then
      begin
        fontparam := fontparam + 'color:' + WPColorToString(aColor) + ';';
      end;

      if FCharAttr.GetFont(FontNr) then
      begin
        fontparam := fontparam + 'font-family:''' +
          FRTFProps.GetFontName(FontNr) + ''';';
      end
      else if FOptWriteAllFontNames then
      begin
         // aFontName : TFontName;
        if not FRTFDataCollection.DefaultAttr.GetFontName(aFontName) then
          aFontName := (DefaultFontName);
        fontparam := fontparam + 'font-family:''' + aFontName + ''';';
      end;

      if FCharAttr.GetFontSize(FontSize) then
      begin
        fontparam := fontparam + 'font-size:' +
          WPFloatToStr(FontSize / 72) + 'in;';
      end;
    end;

    if fontparam <> '' then
    begin
      WriteString('<span style="' + fontparam + '">');
      FSpanOpen := TRUE;
    end;

    if not (soSPANInsteadOfFontTag in FHTMLStoreOptions) then
    begin
      fontparam := '';

      if FCharAttr.GetFont(FontNr) then
      begin
        fontparam := fontparam + ' face="' +
          FRTFProps.GetFontName(FontNr) + '"';
      end;

      if FCharAttr.GetFontSize(FontSize) then
      begin
        for i := 1 to WP_HTML_FONTSIZEMAX do
          if (FontSize <= WPHTFONTSIZES[i].smax) and
            (FontSize >= WPHTFONTSIZES[i].smin) then
          begin
            fontparam := fontparam + ' size=' + IntToStr(i);
            break;
          end;
      end;

      if FCharAttr.GetColor(aColor) then
      begin
        fontparam := fontparam + ' color="' + WPColorToString(aColor) + '"';
      end;

  { that's not HTML !
    if FCharAttr.GetBGColor(aColor) then
    begin
        fontparam := fontparam  + ' bgcolor="' + WPColorToString(aColor)+'"';
    end; }

      if fontparam <> '' then
      begin
        WriteString('<font' + fontparam + '>');
        FFontOpen := TRUE;
      end;
    end;
  end;
  Result := TRUE;
end;

{ ----------------------------------------------------------------------------- }

class function TWPHTMLReader.UseForFilterName(const Filtername: string): Boolean;
begin
  Result := inherited UseForFilterName(Filtername)
    or (CompareText(Filtername, 'HTML') = 0)
    or (CompareText(Filtername, 'HTM') = 0);
end;

class function TWPHTMLReader.UseForContents(const First500Char: AnsiString): Boolean;
var i, c, hasspc: Integer; HasOpen: Boolean;
begin
  Result := FALSE;
  if (Copy(First500Char, 1, 5) = '{\rtf') or (Copy(First500Char, 1, 5) = '%PDF-')
    or (Pos('<!WPTools_Format', First500Char) > 0) then Result := FALSE else
  begin
    c := 0;
    hasspc := 0;
    HasOpen := FALSE;
    // Looks for a < > pair with max 20 chars inbetween.
    for i := 1 to Length(First500Char) do
    begin
      if First500Char[i] = '<' then
      begin
        if HasOpen then exit
        else HasOpen := TRUE;
        c := 0;
        hasspc := 0;
      end else if First500Char[i] = '>' then
      begin
        if not HasOpen then exit
        else
        begin
          if (c < 20) and (hasspc = 0) then
          begin
            Result := TRUE;
            exit;
          end else HasOpen := FALSE;
        end;
      end else if HasOpen then
      begin
          // One tag must be without special characters or style
        if not (First500Char[i] in ['A'..'Z', 'a'..'z', ' ', '/']) then inc(hasspc);
        inc(c);
      end;
    end;
  end;
end;

function TWPHTMLReader.ParAllowed: Boolean;
begin
  Result := (FCurrentParagraph = nil) or
    (FTableIsClosed and (FCurrentParagraph.ParagraphType = wpIsTable)) or
    not (FCurrentParagraph.ParagraphType in [wpIsTable, wpIsTableRow]);
end;

procedure TWPHTMLReader.SetOptions(optstr: string);
var i: Integer;
  aoptstr: string;
begin
{$IFDEF HTML_ONLYINBODY}
  OptOnlyInBodyTag := true;
{$ENDIF}
  i := Pos('-', optstr);
  if i > 0 then
  begin
    aoptstr := lowercase(Copy(optstr, i, Length(optstr) - i + 1)) + ',';
    FOptuseBBCodes := Pos('-usebbcodes,', aoptstr) > 0;
    FOptuseCR := Pos('-usecr,', aoptstr) > 0;
    FOptIgnoreSTDHTML := Pos('-ignorehtml,', aoptstr) > 0;
    OptNoSpanObjects := Pos('-nospanobjects,', aoptstr) > 0;
    OptIgnoreSpan := Pos('-ignorespan,', aoptstr) > 0;
    FOptUTF8 := Pos('-utf8,', aoptstr) > 0;
{$IFDEF HTML_ONLYINBODY}
    if Pos('-outsidebodytag,', aoptstr) > 0 then OptOnlyInBodyTag := false;
{$ELSE}
    OptOnlyInBodyTag := Pos('-onlyinbodytag,', aoptstr) > 0;
{$ENDIF}
  end else
  begin
    FOptuseBBCodes := FALSE;
    FOptuseCR := FALSE;
    FOptIgnoreSTDHTML := FALSE;
  end;
  inherited SetOptions(optstr);
end;

procedure TWPHTMLReader.PushTable;
var p: TWPHTMLReaderTableDef;
begin
  p := TWPHTMLReaderTableDef.Create;
  p.FPrevious := FCurrentTable;
  p.MaxColCount := 100;
  SetLength(p.RowSpan, p.MaxColCount);
  FCurrentTable := p;
end;

procedure TWPHTMLReader.PopTable;
var p: TWPHTMLReaderTableDef;
begin
  if FCurrentTable <> nil then
  begin
    p := FCurrentTable.FPrevious;
    FCurrentTable.RowSpan := nil;
    FCurrentTable.FTable := nil;
    FCurrentTable.Free;
    FCurrentTable := p;
  end;
end;

procedure TWPHTMLReader.PrintSkippedSpace;
begin
  if FHasSPC then
  begin
    // ALL SPACES AT THE BEGINNING OF THE PARAGRAPH ARE IGNORED!
    if not FCurrentParagraph.Empty([wpobjMergeField, wpobjHyperlink,
      wpobjBookmark, wpobjTextProtection,
        wpobjSPANStyle, wpobjCode], true) then
      PrintAChar(#32);
    FHasSPC := FALSE;
  end;
end;

{ ---------------------------------------------------------------
  Process a BB code. If the code is unknown, FALSE is returned!
  Some codes are processed right away, others are converted into
  HTML tags which are then returned in the variable HtmlTag to be
  used by the HTML parser --------------------------------------- }

function TWPHTMLReader.ProcessBBCode(bbCode: string; var HtmlTag: TWPCustomHTMLTag): Boolean;
var i: Integer;
  bbname, bbpar: string;
begin
  i := Pos('=', bbcode);
  if i > 0 then
  begin
    bbname := lowercase(Copy(bbcode, 1, i - 1));
    bbpar := Copy(bbcode, i + 1, Length(bbcode));
  end else
  begin
    bbname := lowercase(bbcode);
    bbpar := '';
  end;
  // Check for BB Codes
  Result := TRUE;
  // Attributes
  if bbname = 'b' then
    Attr.IncludeStyle(afsBold)
  else if bbname = '/b' then
    Attr.ExcludeStyle(afsBold)
  else if bbname = 'k' then
    Attr.IncludeStyle(afsBold)
  else if bbname = '/k' then
    Attr.ExcludeStyle(afsBold)
  else if bbname = 'i' then
    Attr.IncludeStyle(afsItalic)
  else if bbname = '/i' then
    Attr.ExcludeStyle(afsItalic)
  else if bbname = 'u' then
    Attr.IncludeStyle(afsUnderline)
  else if bbname = '/u' then
    Attr.ExcludeStyle(afsUnderline)
  else if bbname = 's' then
    Attr.IncludeStyle(afsStrikeOut)
  else if bbname = '/s' then
    Attr.ExcludeStyle(afsStrikeOut)
  // Font attributes ----------------------------------------------------
  else if bbname = 'color' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('font', wpXMLOpeningTag);
    HtmlTag.AddParam('color', bbpar);
  end
  else if bbname = '/color' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('font', wpXMLClosingTag);
  end
  else if bbname = 'size' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('font', wpXMLOpeningTag);
    HtmlTag.AddParam('size', bbpar + 'pt');
  end
  else if bbname = '/size' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('font', wpXMLClosingTag);
  end
  // Par Alignment -----------------------------------------------------
  else if bbname = 'align' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('div', wpXMLOpeningTag);
    if bbpar <> '' then
      HtmlTag.AddParam('align', bbpar);
    FTempIgnoreOptuseCR := TRUE;
  end
  else if bbname = '/align' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('div', wpXMLClosingTag);
    FTempIgnoreOptuseCR := FALSE;
  end
  else if bbname = 'center' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('div', wpXMLOpeningTag);
    HtmlTag.AddParam('align', 'center');
    FTempIgnoreOptuseCR := TRUE;
  end
  else if bbname = '/center' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('div', wpXMLClosingTag);
    FTempIgnoreOptuseCR := FALSE;
  end
  else if bbname = 'left' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('div', wpXMLOpeningTag);
    HtmlTag.AddParam('align', 'left');
    FTempIgnoreOptuseCR := TRUE;
  end
  else if bbname = '/left' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('div', wpXMLClosingTag);
    FTempIgnoreOptuseCR := FALSE;
  end
  else if bbname = 'right' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('div', wpXMLOpeningTag);
    HtmlTag.AddParam('align', 'right');
    FTempIgnoreOptuseCR := TRUE;
  end
  else if bbname = '/right' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('div', wpXMLClosingTag);
    FTempIgnoreOptuseCR := FALSE;
  end
  else if bbname = 'justify' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('div', wpXMLOpeningTag);
    HtmlTag.AddParam('align', 'justify');
    FTempIgnoreOptuseCR := TRUE;
  end
  else if bbname = '/justify' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('div', wpXMLClosingTag);
    FTempIgnoreOptuseCR := FALSE;
  end
  // Lists --------------------------------------------------------------
  else if bbname = 'list' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('ol', wpXMLOpeningTag);
    if bbpar <> '' then
      HtmlTag.AddParam('type', bbpar);
    FTempIgnoreOptuseCR := TRUE;
  end
  else if bbname = '/list' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('ol', wpXMLClosingTag);
    FTempIgnoreOptuseCR := FALSE;
  end
  else if bbname = '*' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('li', wpXMLOpeningTag);
    //-later! FTempIgnoreOptuseCR := FALSE;
  end
  // Links --------------------------------------------------------------
  else if bbname = 'url' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('a', wpXMLOpeningTag);
    if bbpar <> '' then
      HtmlTag.AddParam('href', bbpar);
  end
  else if bbname = '/url' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('a', wpXMLClosingTag);
  end
  else if bbname = 'email' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('a', wpXMLOpeningTag);
    if bbpar <> '' then
      HtmlTag.AddParam('href', 'mailto:' + bbpar);

    HtmlTag.AddParam('class', 'maillink'); // Use style MailLink!
  end
  else if bbname = '/email' then
  begin
    HtmlTag := TWPCustomHTMLTag.Create('a', wpXMLClosingTag);
  end
  // --------------------------------------------------------------------
  else Result := FALSE; // UNKNOWN!!!

end;

function TWPHTMLReader.Parse(datastream: TStream): TWPRTFDataBlock;
var
  D, UTF8Sequence: Integer;
  V: Integer;
  ch, ch2: Integer;
  ret: TWPToolsIOErrCode;
  NewCa: TWPCharAttr;
  objtype: TWPTextObjType;
  FTagStack: TList;
  ReadEntity, NoNewParagraph: Boolean;
  Entity : AnsiString;
  StyleString: string;
  EscapeCloseTag: Ansistring;
  EscapeCloseTagActive: Boolean;
  FIgnoreText, FLastWasTD: Boolean;
  FReadingVariable: Boolean;
  FReadingVariableTag, FReadingVariableName: string;
  FReadStringBuffer: TWPStringBuilder;
  cssparser: TWPCSSParser;
  onecssstyle: TWPCSSParserStyle;
  parsty: TWPTextStyle;
  FAObjectList: TWPTextObjList;
  FLastMergeTag: Integer;
  FSpanObjectList: TWPTextObjList;
  aLinkObj, aSpanObj, aImageObj: TWPTextObj;
  bulletlevel, numberlevel, currnumstyle: Integer;
  fnummode: TWPNumberStyle;
  FDivStack: array of TWPTextStyle;
  CurrNumberStyles: array of Integer;
  FNeedDivParagraph: Boolean;
  FDivStackCount: Integer;
  body_sty, table_sty: TWPTextStyle;
{$IFDEF DIVTREE}
  function NewParagraph: TParagraph;
  begin
    if FParLevel > 0 then
      Result := Self.NewChildParagraph
    else Result := Self.NewParagraph;
  end;
{$ENDIF}
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure AttrClear;
  begin
    Attr.Clear;
  end;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure CheckDivPar;
  var i: Integer;
  begin
    if FNeedAutoPar then Self.NewChildParagraph();
    if FNeedDivParagraph or (FCurrentParagraph = nil) then
    begin
      FNeedDivParagraph := FALSE;
      if (FCurrentParagraph <> nil) and (paprIsTable in FCurrentParagraph.prop) then
      begin
        NewChildParagraph;
      end
      else
      begin
         // if NoNewParagraph then NoNewParagraph := false else
         NewParagraph;
      end;
      for i := 0 to FDivStackCount do
      begin
        FCurrentParagraph.Assign(FDivStack[i], false);
      end;
      if FDivStack[FDivStackCount].Style <> 0 then FCurrentParagraph.Style := FDivStack[FDivStackCount].Style; //V5.20.1
    end;
  end;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  function MakeTable: Boolean;
  begin
    Result := FALSE;
    if (FCurrentParagraph <> nil) and
      (FCurrentParagraph = FAutoCreatedParagraph) and
      (FCurrentParagraph.CharCount = 0) then
      FAutoCreatedParagraph := nil
    else
      if // (FCurrentTable <> nil) and
        (FCurrentParagraph = nil) or
        ((FCurrentParagraph.ParagraphType = wpIsHTML_DIV) and (FParLevel > 0) {V5.17.3}) or
        (not (FCurrentParagraph.ParagraphType in [wpIsTable, wpIsTableRow]) and
        (paprIsTable in FCurrentParagraph.prop)) then
      begin
        Result := TRUE;
        Self.NewChildParagraph
      end else
      begin
        Self.NewParagraph;
      end;
    FCurrentParagraph.ParagraphType := wpIsTable;
    PushTable;
    FCurrentTable.FTable := FCurrentParagraph;
  end;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure CheckRowSpan;
  begin
    if (FCurrentTable <> nil) and (FCurrentParagraph.ParagraphType = wpIsTableRow) then
    begin
      while (FCurrentTable.ColNr < Length(FCurrentTable.RowSpan)) and
        (FCurrentTable.RowSpan[FCurrentTable.ColNr] > 0) do
      begin
        dec(FCurrentTable.RowSpan[FCurrentTable.ColNr]);

        NewChildParagraph;
        include(FCurrentParagraph.prop, paprRowMerge);
        ParLevelUp;
        inc(FCurrentTable.ColNr);
      end;
    end;
  end;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure ClosePreviousColumn;
  var col: Integer;
  begin
    if (FCurrentTable <> nil) and (FCurrentTable.ColSpan > 0) then
    begin
      if FCurrentParagraph.ParagraphType = wpIsTableRow then
      begin
        col := FCurrentTable.ColNr - 1;
        if col >= 0 then
          while FCurrentTable.ColSpan > 0 do
          begin
            if FCurrentTable.ColNr < Length(FCurrentTable.RowSpan) then
            begin
              FCurrentTable.RowSpan[FCurrentTable.ColNr] :=
                FCurrentTable.RowSpan[col];
              NewChildParagraph;
            //FCurrentParagraph.SetText('CL' + IntToStr(FCurrentTable.ColSpan));
{$IFDEF HIGHLIGHTCOLSPAN}
              FCurrentParagraph.ASetColor(WPAT_FGColor, clRed);
{$ENDIF}
              include(FCurrentParagraph.prop, paprColMerge);
              FCurrentParagraph.Optimize;
              ParLevelUp;
              inc(FCurrentTable.ColNr);
            end;
            dec(FCurrentTable.ColSpan);

          end;
      end;
    end else CheckRowSpan; ;
  end;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure InitStandardProps(aPar: TWPTextStyle; const TagName, ClassName, IDName: string; level: Integer);
  var jj: Integer;
    sty: TWPTextStyle;
    st: TWPRTFStyleElement;
    // Copy the attributes which are not inherited from styles
    procedure CpyBrd(src, dst: TWPTextStyle);
    var a, b: Integer;
    begin
      if src.AGet(WPAT_BorderFlags, b) then
      begin
        for a := WPAT_BorderFirstAttr to
          WPAT_BorderLastAttr do
          if src.AGet(a, b) then dst.ASet(a, b);
      end;

     {  if src.AGet(WPAT_PaddingLeft,b) then
            dst.ASet(WPAT_PaddingLeft,b);
       if src.AGet(WPAT_PaddingRight,b) then
            dst.ASet(WPAT_PaddingRight,b);
       if src.AGet(WPAT_PaddingTop,b) then
            dst.ASet(WPAT_PaddingTop,b);
       if src.AGet(WPAT_PaddingBottom,b) then
            dst.ASet(WPAT_PaddingBottom,b); }
    end;
  begin
    if ClassName <> '' then
    begin
      st := RTFProps.ParStyles.FindStyle(TagName + '.' + ClassName);
      if st <> nil then
      begin
        aPar.ASetBaseStyle(st.ID);
        CpyBrd(st.TextStyle, aPar);
        exit;
      end;

      st := RTFProps.ParStyles.FindStyle(ClassName);
      if st <> nil then
      begin
        aPar.ASetBaseStyle(st.ID);
        CpyBrd(st.TextStyle, aPar);
        exit;
      end;
      st := RTFProps.ParStyles.FindStyle(TagName + '.' + ClassName);
      if st <> nil then
      begin
        aPar.ASetBaseStyle(st.ID);
        CpyBrd(st.TextStyle, aPar);
        exit;
      end;
    end else
      if IDName <> '' then
      begin
        st := RTFProps.ParStyles.FindStyle(TagName + '#' + IDName);
        if st <> nil then
        begin
          aPar.ASetBaseStyle(st.ID);
          CpyBrd(st.TextStyle, aPar);
          exit;
        end;
      end;
    st := RTFProps.ParStyles.FindStyle(TagName);
    if st <> nil then
    begin
      aPar.ASetBaseStyle(st.ID);
      CpyBrd(st.TextStyle, aPar);
      exit;
    end;

    jj := FStyleTemplates.IndexOf(lowercase(TagName));
    if jj >= 0 then sty := TWPTextStyle(FStyleTemplates.Objects[jj])
    else
    begin
      sty := RTFDataCollection.RequestStyle(TagName, level);
      FStyleTemplates.AddObject(lowercase(TagName), sty);
    end;
    if sty <> nil then
    begin
      aPar.Assign(sty);
       {no, we need to inherit!
          if sty.AGet( WPAT_CharFontSize, siz) then
          Attr.SetFontSize( siz / 100 ); }
    end;
  end;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
var s: AnsiString;
  val: Integer;
  style: TWPCSSParserStyleWP;
  TxtStyle: TWPTextStyle;
  FSkipMode: Boolean;
  FSkipEnd: string;
  procedure ApplyAttribs(aTag: TWPCustomHTMLTag; aStyle: TWPTextStyle = nil; IgnoreAlignProp: Boolean = FALSE);
  var nsty{$IFDEF USEBASESTYLES}, asty{$ENDIF}: TWPTextStyle;
  begin
    if aStyle = nil then aStyle := FCurrentParagraph;
    if not (loIgnoreStdHTMLParams in FLoadHTMLOptions) then
    begin
      s := aTag.ParamString('ALIGN', '');
      if (s <> '') and not IgnoreAlignProp then
      begin
        begin
          if (CompareText(s, 'left') = 0) then
            aStyle.ASet(WPAT_Alignment, Integer(paralLeft))
          else if (CompareText(s, 'center') = 0) then
            aStyle.ASet(WPAT_Alignment, Integer(paralCenter))
          else if (CompareText(s, 'right') = 0) then
            aStyle.ASet(WPAT_Alignment, Integer(paralRight))
          else if (CompareText(s, 'justify') = 0) then
            aStyle.ASet(WPAT_Alignment, Integer(paralBlock));
        end;
        aStyle.ASetAdd(WPAT_USEHTMLSYNTAX, WPSYNTAX_ALIGN);
      end;

      s := aTag.ParamString('VALIGN', ''); //V5.21
      if (s <> '') and not IgnoreAlignProp then
      begin
        if (CompareText(s, 'top') = 0) then
          aStyle.ASet(WPAT_VertAlignment, 0)
        else if (CompareText(s, 'middle') = 0) then
          aStyle.ASet(WPAT_VertAlignment, 1)
        else if (CompareText(s, 'bottom') = 0) then
          aStyle.ASet(WPAT_VertAlignment, 2);
        aStyle.ASetAdd(WPAT_USEHTMLSYNTAX, WPSYNTAX_ALIGN);
      end;

      if not (loIgnoreShading in FLoadHTMLOptions) then
      begin
        s := aTag.ParamString('bgcolor', '');
        if s <> '' then
        begin
          aStyle.ASetColorString(WPAT_BGCOLOR, s);
          aStyle.ASet(WPAT_ShadingValue, 100);
          aStyle.ASetAdd(WPAT_USEHTMLSYNTAX, WPSYNTAX_BGCOLOR);
        end;
      end;
    end;
    if style <> nil then
    begin
      style.ApplyToPar(FRTFProps, aStyle, 0);

      if (FCurrentParagraph <> nil) and ((aStyle.AGetDef(WPAT_ParFlags, 0) and WPPARFL_NewPage) <> 0) then
      begin
        include(FCurrentParagraph.prop, paprNewPage);
        aStyle.ADel(WPAT_ParFlags);
      end;
      // For <div> paragraphs !
      if not FNeedDivParagraph and //V5.20.9 !!!
        (aStyle <> FCurrentParagraph) and (FCurrentParagraph <> nil) then
        FCurrentParagraph.Assign(aStyle, false);
    end;
    // --- CLASS -> StyleName
    s := aTag.ParamString('class', '');
    if s <> '' then
    begin
      nsty := FRTFProps.ParStyles.FindTextStyle(s, UpperCase(aTag.Name)); //V5.20.1
      if nsty = nil then
        nsty := FRTFProps.ParStyles.FindTextStyle(s, '')
{$IFDEF USEBASESTYLES}
      else
      begin
        asty := FRTFProps.ParStyles.FindTextStyle(UpperCase(aTag.Name), '');
        if (asty <> nil) and (asty <> nsty) then
          aStyle.Assign(asty);
      end
{$ENDIF};
      if nsty = nil then
        nsty := FRTFProps.ParStyles.FindTextStyle(UpperCase(aTag.Name), '');
      aStyle.ABaseStyle := nsty;
    end else
    begin
      s := aTag.ParamString('id', '');
      if s <> '' then
      begin
        nsty := FRTFProps.ParStyles.FindTextStyle(UpperCase(aTag.Name) + '#' + s, s);
        if nsty = nil then
          nsty := FRTFProps.ParStyles.FindTextStyle(s, '');
        aStyle.ABaseStyle := nsty;
      end;
    end;
  end;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure AddStyles;
  var i, j, a: Integer; st: string;
  begin
    for i := 0 to cssparser.StyleCount - 1 do
      if cssparser.Style[i].Name <> '' then
      begin
        st := cssparser.Style[i].Name;
              // Catch the BODY and TABLE style  V5.21.3
        if CompareText(st, 'body') = 0 then
        begin
          body_sty := TWPTextStyle.Create(RTFProps);
          TWPCSSParserStyleWP(cssparser.Style[i]).ApplyToPar(RTFProps, body_sty);
                // Now apply to default attr
          if not FLoadBodyOnly then
          begin
            for j := 1 to 16 do
              if body_sty.AGet(j, a) then
              begin
                if (j = WPAT_CharFontSize) and (a <= 0) then
                  RTFDataCollection.ANSITextAttr.ASet(j, 1) // VERY small 0.01 pt
                else
                  RTFDataCollection.ANSITextAttr.ASet(j, a);
              end;
          end;
        end else
          if CompareText(st, 'table') = 0 then
          begin
            table_sty := TWPTextStyle.Create(RTFProps);
            TWPCSSParserStyleWP(cssparser.Style[i]).ApplyToPar(RTFProps, table_sty);
          end else
          begin
            while (Length(st) > 2) and (st[1] = '.') and (st[2] = '.') do //V5.17.3 - delete double '.'
              Delete(st, 1, 1);
            parsty := RTFProps.ParStyles.AddStyle(st);
            cssparser.Style[i].Reference := parsty;
            TWPCSSParserStyleWP(cssparser.Style[i]).ApplyToPar(RTFProps, parsty);
          end;
      end;
  end;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure LoadLINK(aTag: TWPCustomHTMLTag);
  begin
    // Link to CSS File
    if CompareText(aTag.ParamString('rel', ''), 'stylesheet') = 0 then
    begin
      if not (loIgnoreLinkedCSSStyleSheet in FLoadHTMLOptions) then
      begin
        StyleString :=
          RTFDataCollection.RequestHTTPString(
          Self, 
          FLoadPath,
          aTag.ParamString('href', ''));
        if StyleString <> '' then
        begin
                       // Load into Style collection ?
          cssparser.AsString := StyleString;
          AddStyles;
        end;
      end;
    end;

  end;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

var FReadingPRE, FLoadingNoFramesOnly, FNewRowInClosePar: Boolean;
  FOpenTextObj: TWPTextObj;
  sect: TWPRTFSectionProps;
  FLastTagName : string;
   // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure ProcessTag(aTag: TWPCustomHTMLTag);
  var i, kk: Integer;
    sta, sa: string;
    bFSkipWhiteSpace: Boolean;
  {$IFDEF WPHTMLEXT}
    strlst: TStringList;
    astore: TWPAbstractCharAttrStore;
  {$ENDIF}
// This labels are used to fix wrong HTML code
  // ---------------------------------------------------------------------------
    procedure LoadImage;
    var i: Integer;
    begin
      if OptNoImages then exit;
      FAutoCreatedParagraph := nil;
               // This is a placeholder
                {  if aTag.ParamValue('height', 2) = 1 then
                  begin
                    if paprIsTable in FCurrentParagraph.prop then
                       FCurrentParagraph.ASetNeutral(WPAT_COLWIDTH,
                          MulDiv(aTag.ParamValue('width',0),1440,CSSPixelsPerInch)  );
                  end;  }
      s := aTag.NormalizedParamString('src', '');

  CheckDivPar;
      PrintSkippedSpace;
      aImageObj := PrintTextObj(wpobjImage,
        aTag.ParamString('alt', ''),
        s,
        false,
        false,
        false);

      if aImageObj <> nil then
      begin
                                       // This is usually used when pasting from clipboard
        if not RTFDataCollection.RequestHTTPImage(
          Self, FLoadPath, s, aImageObj) and
          (_DefaultImage <> nil) then
        begin
          aImageObj.LoadObjFromGraphic(_DefaultImage.Graphic);
          FreeAndNil(_DefaultImage);
          s := '';
        end;

        sa := aTag.ParamString('width');
        if sa <> '' then
        begin
          val := Pos('%', sa);
          if val > 0 then
          begin
            val := StrToIntDef(Copy(sa, 1, val - 1), 0);
            if val > 0 then
            begin
              aImageObj.Width := MulDiv(RTFDataCollection.Header.PageWidth -
                RTFDataCollection.Header.LeftMargin -
                RTFDataCollection.Header.RightMargin, val, 100);
            end
            else aImageObj.Width := 180;
          end
          else
          begin
            aImageObj.Width := MulDiv(aTag.ParamValue('width', 16), 1440, CSSPixelsPerInch);
          end;
        end
        else if aImageObj.ObjRef <> nil then
          aImageObj.Width := aImageObj.ObjRef.ContentsWidth
        else aImageObj.Width := 180;

        sa := aTag.ParamString('height');

        if sa <> '' then
        begin
          val := Pos('%', sa);
          if val > 0 then
          begin
            val := StrToIntDef(Copy(sa, 1, val - 1), 0);
            if val > 0 then
            begin
              aImageObj.Height := MulDiv(RTFDataCollection.Header.PageHeight -
                RTFDataCollection.Header.TopMargin -
                RTFDataCollection.Header.BottomMargin, val, 100);
            end
            else aImageObj.Height := 180;
          end
          else
          begin
            aImageObj.Height := MulDiv(aTag.ParamValue('height', 16), 1440, CSSPixelsPerInch);
          end;
        end
        else if aImageObj.ObjRef <> nil then
          aImageObj.Height := aImageObj.ObjRef.ContentsHeight
        else aImageObj.Height := 180;

           // --- DO NOT EMBED, USE NAME
  {$IFDEF ASSIGN_IMG_PATH}
        aImageObj.Source := s;
  {$ENDIF}

        s := aTag.ParamString('align', '');
        if CompareText(s, 'right') = 0 then
          aImageObj.Mode := aImageObj.Mode + [wpobjRelativeToParagraph, wpobjPositionAtRight]
        else if CompareText(s, 'center') = 0 then
          aImageObj.Mode := aImageObj.Mode + [wpobjRelativeToParagraph, wpobjPositionAtCenter]
        else if CompareText(s, 'left') = 0 then
          aImageObj.Mode := aImageObj.Mode + [wpobjRelativeToParagraph];

        s := aTag.ParamString('style', '');
        if s <> '' then
        begin
          onecssstyle := TWPCSSParserStyle.Create(self);
          try
            onecssstyle.AsString := s;
            for i := 0 to onecssstyle.ElementCount - 1 do
              case onecssstyle.Elements[i].CSS of
                wpcss_height:
                begin
                    aImageObj.Height := onecssstyle.Elements[i].GetTwipValue(0,
                    aImageObj.Height);
                end;
                wpcss_width:
                begin
                    aImageObj.Width := onecssstyle.Elements[i].GetTwipValue(0,
                    aImageObj.Width);
                end;
  {$IFDEF WPHTMLEXT}
                wpcss_left:
                  begin
                    aImageObj.PositionMode := wpotPage;
                    aImageObj.Wrap := wpwrNone;
                    aImageObj.RelX := onecssstyle.Elements[i].GetTwipValue(0, 0);
                  end;
                wpcss_top:
                  begin
                    aImageObj.PositionMode := wpotPage;
                    aImageObj.Wrap := wpwrNone;
                    aImageObj.RelY := onecssstyle.Elements[i].GetTwipValue(0, 0);
                  end;
  {$ENDIF}
              end;
          finally
            onecssstyle.Free;
          end;
        end;

        {$IFDEF WPHTMLEXT} // pagexpos in twips
        if aTag.HasParam('pagexpos') or aTag.HasParam('pageypos') then
        begin
          aImageObj.PositionMode := wpotPage;
          aImageObj.Wrap := wpwrNone;
          aImageObj.RelX := aTag.ParamValue('pagexpos', 0);
          aImageObj.RelY := aTag.ParamValue('pageypos', 0);
        end;
  {$ENDIF}
      end;

          // --- CLASS -> StyleName
      s := aTag.ParamString('class', '');
      if s <> '' then aImageObj.StyleName := s;
    end;
  // ---------------------------------------------------------------------------
  label CreateNewCell, CloseRow;
  begin
    style := nil;
    try
            //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            //+++++++++++++++++++++++++++++++++++++++++++ CLOSED +++++++++++++++
            //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      if aTag.Typ = wpXMLClosedTag then
      begin
        if aTag.NameEqual('meta') then
        begin
          sta := aTag.ParamString('content');
          if sta <> '' then
          begin
            sta := lowercase(sta);
            i := Pos('charset', sta);
            if i > 0 then
            begin
              inc(i, 7);
              while (i < Length(sta)) and (sta[i] in [#32, '=']) do inc(i);
              Delete(sta, 1, i - 1);
              if (CompareText(sta, 'utf8') = 0) or (CompareText(sta, 'utf-8') = 0) then
                FOptUTF8 := true else
                for i := 0 to Length(codepages) - 1 do
                begin
                  if Copy(sta, 1, Length(codepages[i].name)) = codepages[i].name then
                  begin
                    OptCodePage := codepages[i].id;
                    break;
                  end;
                end;
            end;
          end;

        end else
{$IFDEF HTMLMERGE}
          if aTag.NameEqual('field') then
          begin
            CheckDivPar;
            PrintSkippedSpace;
            FLastMergeTag := PrintTextObj(wpobjMergeField,
              aTag.ParamString('name', ''), aTag.ParamString('command', ''),
              true, false, false).NewTag;
            PrintTextObj(wpobjMergeField,
              aTag.ParamString('name', ''), aTag.ParamString('command', ''),
              true, true, false).SetTag(FLastMergeTag);
          end else
{$ENDIF}

                if aTag.NameEqual('textobj') then
                begin
                  CheckDivPar;
                  PrintSkippedSpace;
                  PrintTextObj(wpobjTextObject,
                    aTag.ParamString('name', ''), aTag.ParamString('source', ''),
                    false, false, false).IParam :=
                    aTag.ParamValue('iparam', 0);
                end
                else if aTag.NameEqual('link') then //------------- Load CSS File -----
                begin
                  LoadLINK(aTag);
                end
                else if aTag.NameEqual('p') then // closed P tag
                begin
                  if (FCurrentParagraph <> nil) and (paprIsTable in FCurrentParagraph.prop) then
                    NewChildParagraph
                  else NewParagraph;
                end
                else if aTag.NameEqual('page') or aTag.NameEqual('section') then
                begin
                  if (FCurrentParagraph <> nil) and
                    ((FCurrentParagraph.prev <> nil) or (FCurrentParagraph.CharCount > 0)) then
                  begin
                    if FCurrentParagraph.CharCount > 0 then NewParagraph;
                    FCurrentParagraph.IsNewPage := TRUE;
                  end;

                  if aTag.NameEqual('section') then
                  begin
                    if FCurrentParagraph = nil then NewParagraph;
                    sect := FRTFDataCollection.AddSectionProps;
                    FWorkRTFData.UsedForSectionID := sect.SectionID;
                    FCurrentParagraph.SectionID := sect.SectionID;
                    include(FCurrentParagraph.prop, paprNewSection);
                  end else sect := FRTFDataCollection.Header;

                  s := aTag.ParamString('style', '');
                  if s <> '' then
                  begin
                    onecssstyle := TWPCSSParserStyle.Create(self);
                    try
                      onecssstyle.AsString := s;
                      for i := 0 to onecssstyle.ElementCount - 1 do
                        case onecssstyle.Elements[i].CSS of
                          wpcss_height:
                            begin
                              Sect.Select := Sect.Select + [wpsec_PageSize];
                              Sect.PageHeight := onecssstyle.Elements[i].GetTwipValue(0,
                                FRTFDataCollection.Header.PageHeight);
                            end;
                          wpcss_width:
                            begin
                              Sect.Select := Sect.Select + [wpsec_PageSize];
                              Sect.PageWidth := onecssstyle.Elements[i].GetTwipValue(0,
                                FRTFDataCollection.Header.PageWidth);
                            end;
                          wpcss_pageRotate:
                            begin
                              Sect.Select := Sect.Select + [wpsec_PageSize];
                              s := onecssstyle.Elements[i].GetStringValue('');
                              if (CompareText(s, 'Yes') = 0) or (CompareText(s, 'true') = 0) then
                                Sect.Landscape := TRUE
                              else if (CompareText(s, 'No') = 0) or (CompareText(s, 'false') = 0) then
                                Sect.Landscape := FALSE
                              else Sect.Landscape := FRTFDataCollection.Header.Landscape;
                            end;
                          wpcss_margin_left:
                            begin
                              Sect.Select := Sect.Select + [wpsec_Margins];
                              Sect.LeftMargin := onecssstyle.Elements[i].GetTwipValue(0,
                                FRTFDataCollection.Header.LeftMargin);
                            end;
                          wpcss_margin_right:
                            begin
                              Sect.Select := Sect.Select + [wpsec_Margins];
                              Sect.RightMargin := onecssstyle.Elements[i].GetTwipValue(0,
                                FRTFDataCollection.Header.RightMargin);
                            end;
                          wpcss_margin_top:
                            begin
                              Sect.Select := Sect.Select + [wpsec_Margins];
                              Sect.TopMargin := onecssstyle.Elements[i].GetTwipValue(0,
                                FRTFDataCollection.Header.TopMargin);
                            end;
                          wpcss_margin_bottom:
                            begin
                              Sect.Select := Sect.Select + [wpsec_Margins];
                              Sect.BottomMargin := onecssstyle.Elements[i].GetTwipValue(0,
                                FRTFDataCollection.Header.BottomMargin);
                            end;
                        end;
                    finally
                      onecssstyle.Free;
                    end;
                  end;
                end
{$IFDEF WPHTMLEXT}
                else if aTag.NameEqual('chdir') then
                begin
                  s := aTag.NormalizedParamString('name', '');
                  if s = '.' then
                    ChDir(LoadPath)
                  else if s <> '' then ChDir(s);
                end
                else if aTag.NameEqual('textfile') then
                begin
                  s := aTag.NormalizedParamString('src', '');
                  if s <> '' then
                  begin
                    strlst := TStringList.Create;
                    try
                      strlst.LoadFromFile(s);
                    except
                      strlst.Text := 'ERROR: ' + s;
                    end;
                    bFSkipWhiteSpace := FSkipWhiteSpace;
                    FSkipWhiteSpace := FALSE;
                    Attr.AttrSave(astore);
                    s := aTag.NormalizedParamString('font', '');
                    if s <> '' then Attr.SetFontName(s);
                    s := aTag.NormalizedParamString('size', '');
                    if s <> '' then Attr.SetFontSize(WPStrToFloat(s));
                    for i := 0 to strlst.Count - 1 do
                    begin
                      PrintAString(strlst[i]);
                      if paprIsTable in FCurrentParagraph.prop then
                        NewChildParagraph
                      else NewParagraph;
                    end;
                    FSkipWhiteSpace := bFSkipWhiteSpace;
                    Attr.AttrLoad(astore);
                    strlst.Free;
                  end;
                end
{$ENDIF}
                else if aTag.NameEqual('br') then 
                begin
                  if ParAllowed then
                  begin
                    if (FCurrentParagraph <> nil) and
                      (FCurrentParagraph.ParagraphType = wpIsTable) then
                      NewParagraph;
                    CheckDivPar;
                    PrintAChar(#10);
                    FHasSPC := FALSE;
                    FNLIsNotSPC := TRUE; //V5.17.3
                    FAutoCreatedParagraph := nil;
                  end;
                end
                else if aTag.NameEqual('img') then
                begin
                  LoadImage;
                end
                else if aTag.NameEqual('hr') then
                begin
                  FHasSPC := FALSE;
                  if (FCurrentParagraph <> nil) and
                    not FTableIsClosed and //V5.22.2
                    (FCurrentParagraph.ParagraphType = wpIsTable) then
                  begin
                // Ignore in table
                  end
                  else if (FCurrentParagraph <> nil) and
                    (FCurrentParagraph.ParagraphType = wpIsTableRow) then
                  begin
                // Convert to line in row
                    FCurrentParagraph.ASetAdd(WPAT_BorderFlags, WPBRD_DRAW_Top);
                  end
                  else
                  begin
                    if (FCurrentParagraph = nil) or
                      (FCurrentParagraph.ParagraphType <> wpIsSTDPar) or
                      (FCurrentParagraph.CharCount > 0) then
                      NewParagraph;
                    FCurrentParagraph.ADel(WPAT_Alignment);
                    with PrintTextObj(wpobjHorizontalLine,
                      '',
                      '',
                      false,
                      false,
                      false) do
                    begin
                      s := aTag.ParamString('width');
                      val := Pos('%', s);
                      if val > 0 then
                      begin
                        val := StrToIntDef(Copy(s, 1, val - 1), 0);
                        if val > 0 then
                          Width := MulDiv(RTFDataCollection.Header.PageWidth -
                            RTFDataCollection.Header.LeftMargin -
                            RTFDataCollection.Header.RightMargin, val, 100);
                      end else if s <> '' then
                        Width := MulDiv(aTag.ParamValue('width', 0), 1440, CSSPixelsPerInch);
                      if aTag.HasParam('Size') then
                        Height := aTag.ParamValue('size', 1) * 20 // pt
                      else Height := MulDiv(aTag.ParamValue('height', 0), 1440, CSSPixelsPerInch);
                    end;
                  end;
                end
                else if aTag.NameEqual('pagenr') then //WPTOOLS-HTML-EXTENSION
                begin
                  CheckDivPar;
                  PrintSkippedSpace;
                  PrintTextObj(wpobjTextObject,
                    'PAGE',
                    '',
                    false,
                    false,
                    false);
                end
                else if aTag.NameEqual('pagecount') then //WPTOOLS-HTML-EXTENSION
                begin
                  CheckDivPar;
                  PrintSkippedSpace;
                  PrintTextObj(wpobjTextObject,
                    'NUMPAGES',
                    '',
                    false,
                    false,
                    false);
                end
                else if aTag.NameEqual('tab') then //WPTOOLS-HTML-EXTENSION
                begin
                  FSkipWhiteSpace := FALSE;
                  bFSkipWhiteSpace := FSkipWhiteSpace;
                  FSkipWhiteSpace := FALSE;
                  PrintWideChar(9);
                  FSkipWhiteSpace := bFSkipWhiteSpace;
                  if aTag.HasParam('clear') then
                    FCurrentParagraph.TabstopClear;
                  for i := 0 to aTag.ParamCount - 1 do
                  begin
                    s := aTag.ParamName(i);
                    kk := aTag.ParamValue(i, 0);
                    if s = 'left' then FCurrentParagraph.TabstopAdd(kk, tkLeft)
                    else if s = 'right' then FCurrentParagraph.TabstopAdd(kk, tkRight)
                    else if s = 'center' then FCurrentParagraph.TabstopAdd(kk, tkCenter)
                    else if s = 'decimal' then FCurrentParagraph.TabstopAdd(kk, tkDecimal);
                  end;
                end
                else if aTag.NameEqual('pageref') then //WPTOOLS-HTML-EXTENSION
                begin
                  CheckDivPar;
                  PrintSkippedSpace;
                  PrintTextObj(wpobjReference,
                    aTag.ParamString('name'),
                    aTag.ParamString('text'),
                    false,
                    false,
                    false);
                end
                else if aTag.NameEqual('pagebreak') then //WPTOOLS-HTML-EXTENSION
                begin
                  FNextParNeedsPageBreak := TRUE;
                end;
      end else
            //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            //+++++++++++++++++++++++++++++++++++++++++++ OPEN ++++++++++++++++
            //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        if aTag.Typ = wpXMLOpeningTag then
        begin
              // Style attached ? ----------------------------------------------
          if not (loIgnoreStyleParameter in FLoadHTMLOptions) then
          begin
            s := aTag.ParamString('style', '');
            if s <> '' then
            begin
              style := TWPCSSParserStyleWP.Create(Self);
              if aTag.NameEqual('span') or (aTag.NameEqual('font')) then style.IsCharStyle := TRUE;
              style.AsString := s;
            end;
          end;
              // ---------------------------------------------------------------
          if aTag.NameEqual('html') then
          begin
            FIgnoreText := (loIgnoreTextOutsideOfBodyTag in FLoadHTMLOptions) or
              OptOnlyInBodyTag;
          end else
            if aTag.NameEqual('head') then
            begin
              FIgnoreText := TRUE;
              FReadingHead := TRUE;
            end else
{$IFDEF WPHTMLEXT}
              if aTag.NameEqual('header') then
              begin
                AttrClear;
                ProcessElement(aTag, wpIsHeader, FWorkRTFData.UsedForSectionID);
                s := aTag.ParamString('style', '');
                if s <> '' then
                begin
                  onecssstyle := TWPCSSParserStyle.Create;
                  if sect = nil then sect := FRTFDataCollection.Header;
                  try
                    onecssstyle.AsString := s;
                    for i := 0 to onecssstyle.ElementCount - 1 do
                      case onecssstyle.Elements[i].CSS of
                        wpcss_margin_top:
                          begin
                            Sect.Select := Sect.Select + [wpsec_Margins];
                            Sect.MarginHeader := onecssstyle.Elements[i].GetTwipValue(0, sect.MarginHeader);
                          end;
                      end;
                  finally
                    onecssstyle.Free;
                  end;
                end;
              // ---------------------------------------------------------------
              end else if aTag.NameEqual('footer') then
              begin
                AttrClear;
                ProcessElement(aTag, wpIsFooter, FWorkRTFData.UsedForSectionID);
                s := aTag.ParamString('style', '');
                if s <> '' then
                begin
                  onecssstyle := TWPCSSParserStyle.Create;
                  if sect = nil then sect := FRTFDataCollection.Header;
                  try
                    onecssstyle.AsString := s;
                    for i := 0 to onecssstyle.ElementCount - 1 do
                      case onecssstyle.Elements[i].CSS of
                        wpcss_margin_Bottom:
                          begin
                            Sect.Select := Sect.Select + [wpsec_Margins];
                            Sect.MarginFooter := onecssstyle.Elements[i].GetTwipValue(0, sect.MarginFooter);
                          end;
                      end;
                  finally
                    onecssstyle.Free;
                  end;
                end;
              // ---------------------------------------------------------------
              end else
{$ENDIF}

                  if aTag.NameEqual('textbox') then
                  begin
{$IFNDEF NO_TEXTBOXES}
                    CheckDivPar;
                    PrintSkippedSpace;
                    aImageObj := PrintTextObj(wpobjImage,
                      aTag.ParamString('name', 'TOBJ' + IntToStr(GetTickCount)), '', false, false, false);
                    aImageObj.Width := aTag.ParamValue('w', 1440);
                    aImageObj.Height := aTag.ParamValue('h', 1440);
                    aImageObj.RelX := aTag.ParamValue('x', 0);
                    aImageObj.RelY := aTag.ParamValue('y', 0);
                    aImageObj.Mode := [wpobjRelativeToParagraph];
                    aImageObj.ObjRef := TWPORTFTextBox.Create(RTFDataCollection);
                    (aImageObj.ObjRef as TWPORTFTextBox).ObjName := aImageObj.Name;
{$ENDIF}
                    AttrClear;
                    ProcessElement(aTag, wpIsOwnerSelected, 0, aImageObj.Name);
                  end else
                    if aTag.NameEqual('textboxcode') then
                    begin
                      FSkipMode := TRUE;
                      FSkipEnd := 'textboxcode';
                    end else
                      if FReadingHead and aTag.NameEqual('title') then
                      begin
                        FReadingVariable := TRUE;
                        FReadingVariableName := 'Title';
                        FReadingVariableTag := 'title'; // lowercase !
                        FReadStringBuffer.Clear;
                      end else
                        if aTag.NameEqual('script') then
                        begin
                          FReadingVariable := TRUE;
                          FReadingVariableName := 'Script_' + aTag.ParamString('language', 'JavaScript');
                          FReadingVariableTag := 'script'; // lowercase !
                          FReadStringBuffer.Clear;
                 // unless we find this we pass all characters untranslated
                          EscapeCloseTag := '</script';
                          EscapeCloseTagActive := TRUE;
                        end else
                          if aTag.NameEqual('style') then
                          begin
                            FReadingStyle := TRUE;
                            FReadingVariable := TRUE;
                            FReadingVariableName := '_STLYESHEET_';
                            FReadingVariableTag := 'style'; // lowercase !
                            FReadStringBuffer.Clear;
                 // unless we find this we pass all characters untranslated
                            EscapeCloseTag := '</style';
                            EscapeCloseTagActive := TRUE;
                          end else
                            if aTag.NameEqual('link') then //------------- Load CSS File -----
                            begin
                              LoadLINK(aTag);
                            end else //-------------------------------------------------------
                              if aTag.NameEqual('noframes') then
                              begin
                                FIgnoreText := FALSE;
                                FHasSPC := FALSE;
                                FLoadingNoFramesOnly := TRUE;
                              end else
                                if aTag.NameEqual('textobj') then
                                begin
                                  CheckDivPar;
                                  PrintSkippedSpace;
                                  FOpenTextObj := PrintTextObj(wpobjTextObject,
                                    aTag.ParamString('name', ''), aTag.ParamString('source', ''),
                                    false, false, false);
                                  FOpenTextObj.IParam :=
                                    aTag.ParamValue('iparam', 0); ;
                                  FReadingVariable := TRUE;
                                end
                                else if aTag.NameEqual('body') then
                                begin
                                  FIgnoreText := FALSE;
                                  FHasSPC := FALSE;
                                // V5.21.3: We don't use this anymore since we have applied it earlier
                                //  bodystyle := FRTFProps.ParStyles.FindTextStyle('BODY', '');
                                  if not FLoadBodyOnly then
                                  begin
                                    if aTag.HasParam('BASEFONT') then
                                      RTFDataCollection.ANSITextAttr.SetFontName(
                                        aTag.ParamString('BASEFONT', ''));
                                   // bgcolor, background
                                  end;
                                  AttrClear
                                end else
                                  if aTag.NameEqual('ol') or aTag.NameEqual('ul') then
                                  begin
{$IFDEF DIVTREE}
                                    aTag.SavedPar := FCurrentParagraph;
                                    aTag.SavedLevel := FParLevel;
                                    NewParagraph.AClass := aTag.Name;
{$ENDIF}
                            // UL in <P> tag
                                    if (FCurrentParagraph <> nil) and (FCurrentParagraph.CharCount > 0) then
                                    begin
                                      if paprIsTable in FCurrentParagraph.prop then
                                        NewChildParagraph
                                      else Self.NewParagraph;
                                      NoNewParagraph := TRUE;
                                    end;

                                    SetLength(CurrNumberStyles, Length(CurrNumberStyles) + 1);
                                    currnumstyle := 0;
                                    if aTag.NameEqual('ul') then
                                    begin
                                      inc(bulletlevel);
                                     // Here we could load from a different list of
                                     // bulletfonnts + characters
                                      s := BulletFont;
                                      currnumstyle := FRTFProps.NumberStyles.AddNumberStyle(
                                        wp_bullet,
                                        BulletChar,
                                        '',
                                        s,
                                        360, 0,
                                        false, 0, 0);
                                    end
                                    else
                                    begin
                                      s := aTag.ParamString('type');
                                      if s <> '' then
                                        case s[1] of
                                          'A': fnummode := wp_lg_a;
                                          'a': fnummode := wp_a;
                                          'I': fnummode := wp_lg_i;
                                          'i': fnummode := wp_i;
                                        else fnummode := wp_1;
                                        end else fnummode := wp_1;
                                      inc(numberlevel);
                                      currnumstyle := -FRTFProps.NumberStyles.AddNumberStyle(
                                        fnummode,
                                        '',
                                        ')',
                                        '',
                                        360, 0,
                                        false, 0, 0);
                                    end;
                                    CurrNumberStyles[Length(CurrNumberStyles) - 1] := currnumstyle;
                                  end else
                                    if aTag.NameEqual('head') or aTag.NameEqual('script') then
                                    begin
                                      FReadingHead := TRUE;
                                    end
                                    else if ParAllowed and (aTag.NameEqual('div') or aTag.NameEqual('center')) then
                                    begin
{$IFDEF DIVTREE}
                                      aTag.SavedPar := FCurrentParagraph;
                                      aTag.SavedLevel := FParLevel;

                                      if not NoNewParagraph or (FCurrentParagraph = nil) then
                                        NewParagraph;
                                      FCurrentParagraph.AClass := aTag.Name;

                                      InitStandardProps(FCurrentParagraph, aTag.Name, aTag.ParamString('class'),
                                        aTag.ParamString('id'), 0);
                                      ApplyAttribs(aTag, FCurrentParagraph);
{$ELSE}
                                      inc(FDivStackCount);
                                      if FDivStackCount >= Length(FDivStack) then
                                        SetLength(FDivStack, Length(FDivStack) + 10);
                                      FDivStack[FDivStackCount] := TWPTextStyle.Create(FRTFProps);
                                      FNeedDivParagraph := (FCurrentParagraph = nil) or
                                        (FCurrentParagraph.CharCount > 0) or
                                        (FCurrentParagraph.ParagraphType in [wpIsTable, wpIsTableRow]) or
                                        (not (paprIsTable in FCurrentParagraph.prop)
                                        and not NoNewParagraph); //V5.18.3

                                      NoNewParagraph := FALSE;

                                      InitStandardProps(FDivStack[FDivStackCount], aTag.Name, aTag.ParamString('class'), aTag.ParamString('id'), 0);

                                      //V5.37 - get parameters for first line. Usually DIV paragraphs
                                      //are assigned when first used (they are not nested)
                                      if FCurrentParagraph.PrevPar=nil then
                                      begin
                                         FCurrentParagraph.Style := FDivStack[FDivStackCount].Style;
                                         FCurrentParagraph.ACopy(FDivStack[FDivStackCount],0,255);
                                      end;

                                      //V5.40 moved down
                                      ApplyAttribs(aTag, FDivStack[FDivStackCount]);

{$ENDIF}
                                      if aTag.NameEqual('center') then
                                      begin
                                        FCurrentParagraph.ASet(WPAT_Alignment, Integer(paralCenter));
                                      end;

                                    //V5.21 - work with one <div> tag inside a table cell
                                      if (paprIsTable in FCurrentParagraph.prop) and
                                        aTag.NameEqual('div') then
                                      begin
                                        s := aTag.ParamString('align');
                                        if (s <> '') then
                                        begin
                                          if (CompareText(s, 'left') = 0) then
                                            FCurrentParagraph.ASet(WPAT_Alignment, Integer(paralLeft))
                                          else if (CompareText(s, 'center') = 0) then
                                            FCurrentParagraph.ASet(WPAT_Alignment, Integer(paralCenter))
                                          else if (CompareText(s, 'right') = 0) then
                                            FCurrentParagraph.ASet(WPAT_Alignment, Integer(paralRight))
                                          else if (CompareText(s, 'justify') = 0) then
                                            FCurrentParagraph.ASet(WPAT_Alignment, Integer(paralBlock));
                                        end;
                                      end;

                                    end else
                                      if aTag.NameEqual('code')
{$IFNDEF IGNOREblockquote} or aTag.NameEqual('blockquote'){$ENDIF}
{$IFNDEF IGNOREFORM} or aTag.NameEqual('form'){$ENDIF}
                                      then
                                      begin
                                        if not ParAllowed or (FInBlockQuote and aTag.NameEqual('blockquote')) then
                                        begin
                                   // IGNORE
                                        end else
                                        begin
                                          if aTag.NameEqual('blockquote') then FInBlockQuote := TRUE;
                                          aTag.SavedPar := FCurrentParagraph;
                                          aTag.SavedLevel := FParLevel;
                                          NewChildParagraph;
                                          FCurrentParagraph.AClass := aTag.Name;

                                          NoNewParagraph := FALSE;
                                        end;
                                      end
                                      else

                                        if ParAllowed and (aTag.NameEqual('p')
                                          or aTag.NameEqual('h1')
                                          or aTag.NameEqual('h2')
                                          or aTag.NameEqual('h3')
                                          or aTag.NameEqual('h4')
                                          or aTag.NameEqual('h5')
                                          or aTag.NameEqual('h6')
                                          or aTag.NameEqual('li'))
                                          then
                                        begin
                                         // This is an error in the HTML file, <p> tag on <table> or <tr> level
                                     {   if (FCurrentParagraph <> nil) and
                                          (FCurrentParagraph.ParagraphType in [wpIsTable, wpIsTableRow]) then
                                        begin
                                          FNewRowInClosePar := FCurrentParagraph.ParagraphType = wpIsTable;
                                          goto CreateNewCell;
                                        end;  }

                                          AttrClear;
                                          FNeedDivParagraph := FALSE;
                                          if paprIsTable in FCurrentParagraph.prop then //V5.19.0 (FCurrentTable <> nil) and (FCurrentTable.FInCell) then
                                          begin
                                            if not FLastWasTD or
                                              (FCurrentParagraph.CharCount > 0) then
                                            begin
                                              NewChildParagraph;
                                              FCurrentTable.FInCell := FALSE;
                                            end;
                                          end
                                          else
                                            if (FCurrentParagraph = nil) or
                                              (FCurrentParagraph.ParagraphType = wpIsTable) or //V5.35.5
                                              not NoNewParagraph then Self.NewParagraph;

                                          FCurrentParagraph.ClearProps;

                                          FLastWasTD := FALSE;
                // -------------------------------------------------------------
                                          FCurrentParagraph.AClass := aTag.Name;

                                          AttrClear;
                                          InitStandardProps(FCurrentParagraph, aTag.Name,
                                            aTag.ParamString('class'), aTag.ParamString('id'), 0);
                                          ApplyAttribs(aTag);

                                          if (paprIsTable in FCurrentParagraph.prop) and
                                            (FCurrentTable <> nil) and FCurrentTable.FTableHasBorder then
                                            FCurrentParagraph.ASet(WPAT_BorderFlags, WPBRD_DRAW_All4); //V5.19.0

                                          if aTag.NameEqual('li') then
                                          begin
{$IFNDEF DONT_LOAD_LI_INDENTS}
                                            FCurrentParagraph.ASet(WPAT_IndentLeft, 360 * (numberlevel + bulletlevel));
                                            FCurrentParagraph.ASet(WPAT_IndentFirst, -360);
{$ENDIF}
                                            if Length(CurrNumberStyles) > 0 then
                                            begin
                                              FCurrentParagraph.ASet(WPAT_NumberSTYLE,
                                                Abs(CurrNumberStyles[Length(CurrNumberStyles) - 1]));
                                              if CurrNumberStyles[Length(CurrNumberStyles) - 1] < 0 then
                                                FCurrentParagraph.ASet(WPAT_NumberLevel, numberlevel);
                                            end;
                                          end;
                // -------------------------------------------------------------
                                          NoNewParagraph := FALSE;
                                          FHasSPC := FALSE;
                                          FNoText := FALSE;
                                          FNLIsNotSPC := TRUE; //5.17.3
                                        end
                                        else if aTag.NameEqual('table') then
                                        begin
                                          FNoText := TRUE;
                                          FTableIsClosed := FALSE;
                                          if (FCurrentParagraph <> nil) and
                                            (FCurrentParagraph.ParagraphType = wpIsTableRow) then
                                          begin
                                            NewChildParagraph;
                                            FCurrentTable.FInCell := TRUE;
                                            include(FCurrentParagraph.prop, paprIsTable);
                                          end;
{$IFDEF DIVTREE}
                                          aTag.SavedPar := FCurrentParagraph;
                                          aTag.SavedLevel := FParLevel;
                                          if not MakeTable then // not child!
                                          begin
                                            aTag.SavedPar := FCurrentParagraph;
                                            aTag.SavedLevel := FParLevel;
                                          end;
{$ELSE}
                                          MakeTable;
{$ENDIF}

                                          include(FCurrentParagraph.prop, paprReadFromHTML);
                                          InitStandardProps(FCurrentParagraph, aTag.Name,
                                            aTag.ParamString('class'), aTag.ParamString('id'), 0);
                                          ApplyAttribs(aTag, FCurrentParagraph);

                // -------------------------------------------------------------
                                          s := aTag.ParamString('width', ''); 
                                          if s <> '' then
                                          begin
                                            val := Pos('%', s);
                                            if val > 0 then
                                            begin
                                              val := StrToIntDef(Copy(s, 1, val - 1), 0);
                                              if val > 0 then
                                                FCurrentParagraph.ASet(WPAT_BoxWidth_PC, val * 100);
                                            end else
                                            begin
                                              val := StrToIntDef(s, 0);
                                              if val > 0 then
                                                FCurrentParagraph.ASet(WPAT_BoxWidth,
                                                  MulDiv(val, 1440, CSSPixelsPerInch));
                                            end;
                                            FCurrentParagraph.ASetAdd(WPAT_USEHTMLSYNTAX, WPSYNTAX_WIDTH);
                                          end;

                                          FCurrentParagraph.ADel(WPAT_Alignment);
                                          FCurrentParagraph.ADel(WPAT_VertAlignment);
                                          val := aTag.ParamValue('border', 0);
                                          if val > 0 then
                                          begin
                                            FCurrentTable.FTableHasBorder := true;
                                            FCurrentParagraph.ASet(WPAT_BorderWidth, MulDiv(val, 1440, CSSPixelsPerInch));
                                          end;
                                          ApplyAttribs(aTag, FCurrentParagraph, TRUE);
               // -------------------------------------------------------------

                                          s := aTag.ParamString('style', '');
                                          if s <> '' then
                                          begin
                                            onecssstyle := TWPCSSParserStyle.Create(self);
                                            try
                                              onecssstyle.AsString := s;
                                              for i := 0 to onecssstyle.ElementCount - 1 do
                                                if onecssstyle.Elements[i].AtomCount > 0 then
                                                  case onecssstyle.Elements[i].CSS of
                                                    wpcss_width:
                                                      begin
                                                        if (onecssstyle.Elements[i].Atoms[0].Typ = wp_PHValue) then
                                                        begin
                                                          val := Round(onecssstyle.Elements[i].Atoms[0].fValue);
                                                          if (val > 0) and (val <= 100) then
                                                          begin
                                                            FCurrentParagraph.ASet(WPAT_BoxWidth_PC, val * 100);
                                                            FCurrentParagraph.ADel(WPAT_BoxWidth);
                                                            FCurrentParagraph.ASetDel(WPAT_USEHTMLSYNTAX, WPSYNTAX_WIDTH);
                                                          end;
                                                        end else
                                                        begin
                                                          val := onecssstyle.Elements[i].Atoms[0].AsTwips;
                                                          if val > 0 then
                                                          begin
                                                            FCurrentParagraph.ASet(WPAT_BoxWidth, val);
                                                            FCurrentParagraph.ADel(WPAT_BoxWidth_PC);
                                                            FCurrentParagraph.ASetDel(WPAT_USEHTMLSYNTAX, WPSYNTAX_WIDTH);
                                                          end;
                                                        end;
                                                      end;
                                                  end;
                                            finally
                                              onecssstyle.Free;
                                            end
                                          end; // if s
                                        end
                                        else if aTag.NameEqual('tr') then
                                        begin
                                          if FCurrentParagraph = nil then
                                          begin
                                            NewParagraph;
                                         { FCurrentParagraph.ASetColor(WPAT_BGColor, clRed);
                                          FCurrentParagraph.SetText('[ERROR]'); }
                                          end;
{$IFDEF DIVTREE}
                                          aTag.SavedPar := FCurrentParagraph;
                                          aTag.SavedLevel := FParLevel;
{$ENDIF}

                                          if FCurrentTable = nil then
                                          begin
                                            MakeTable;
                                          end;
                                          FNoText := TRUE;
                                          if FCurrentParagraph.ParagraphType <> wpIsTable then
                                            FCurrentParagraph := FCurrentTable.FTable;
                                          NewChildParagraph;
                                          FCurrentParagraph.ParagraphType := wpIsTableRow;
                                          include(FCurrentParagraph.prop, paprReadFromHTML);
                                          FCurrentTable.ColNr := 0;
                                          FCurrentTable.ColSpan := 0;
                                          CheckRowSpan;
                                          FCurrentTable.FInCell := FALSE;
                                          InitStandardProps(FCurrentParagraph, 'tr',
                                            aTag.ParamString('class'), aTag.ParamString('id'), 0);
                                          if style <> nil then
                                            style.ApplyToPar(FRTFProps, FCurrentParagraph, 0);
                                        end
                                        else if aTag.NameEqual('td') or aTag.NameEqual('th') or aTag.NameEqual('tdx') then
                                        begin
{$IFDEF DIVTREE}
                                          aTag.SavedPar := FCurrentParagraph;
                                          aTag.SavedLevel := FParLevel;
                                          NoNewParagraph := FALSE;
{$ENDIF}

                                          FNewRowInClosePar := FALSE;
                                          FNeedDivParagraph := FALSE;
                                          CreateNewCell:

                                          FLastWasTD := TRUE;
                                          AttrClear;
                                          if FCurrentTable = nil then
                                          begin
                                            NewParagraph;
                                         { FCurrentParagraph.ASetColor(WPAT_BGColor, clRed);
                                          FCurrentParagraph.SetText('[ERROR]'); }
                                          end
                                          else
                                          begin
                                            if (FCurrentParagraph.ParagraphType <> wpIsTableRow) and (FCurrentParagraph.ParentRow <> nil) then
                                            begin
                                            //V5.24.3 - locate parent row if this is a child paragraph of a cell
                                              if paprIsTable in FCurrentParagraph.ParentPar.prop then
                                                FCurrentParagraph := FCurrentParagraph.ParentRow
                                              else
                                              begin
                                                FCurrentParagraph := FCurrentTable.FTable;
                                                if FCurrentParagraph.LastChild <> nil then
                                                  FCurrentParagraph := FCurrentParagraph.LastChild;
                                              end;
                                            end
                                            else if (FCurrentParagraph.ParagraphType <> wpIsTableRow) and
                                              (FCurrentParagraph.ParentPar <> nil) and
                                              (FCurrentParagraph.ParentPar.ParagraphType = wpIsTable) then
                                            begin
                                              FCurrentParagraph := FCurrentParagraph.ParentPar;
                                              FRTFDataCollection.StatusMsg(WPST_ReadInfo, 'Forgotten <TR>');
                                            end;

                                            if FCurrentTable.FTable <> FCurrentParagraph.ParentTable then
                                            begin
                                              FRTFDataCollection.StatusMsg(WPST_ReadInfo, 'Wrong Table closings');
                                            end;

                                            ClosePreviousColumn;
                                            FHasSPC := FALSE;
                                            if FCurrentParagraph.ParagraphType = wpIsTable then
                                            begin
                                              NewChildParagraph;
                                              FCurrentParagraph.ParagraphType := wpIsTableRow;
                                              include(FCurrentParagraph.prop, paprReadFromHTML);
                                            end;

                                            if FCurrentParagraph.ParagraphType = wpIsTableRow then
                                            begin
                                              NewChildParagraph;
                                              FCurrentTable.FInCell := TRUE;
                                              include(FCurrentParagraph.prop, paprIsTable);
                                            end else self.NewParagraph;

                                            if aTag.NameEqual('th') then
                                            begin
                                              include(FCurrentParagraph.prop, paprIsHeader);
                                            end;

                                            InitStandardProps(FCurrentParagraph, aTag.Name,
                                              aTag.ParamString('class'), aTag.ParamString('id'), 0);

                                            if FCurrentTable.FTableHasBorder then
                                              FCurrentParagraph.ASet(WPAT_BorderFlags, WPBRD_DRAW_All4);

                                            FCurrentTable.colspan := aTag.ParamValue('colspan', 1) - 1;
                                            FCurrentTable.RowSpan[FCurrentTable.ColNr] := aTag.ParamValue('rowspan', 1) - 1;

                                            s := aTag.ParamString('width', ''); 
                                            if s <> '' then
                                            begin
                                              val := Pos('%', s);
                                              if val > 0 then
                                              begin
                                                val := StrToIntDef(Copy(s, 1, val - 1), 0);
                                                if val > 0 then
                                                begin
                                                  FCurrentParagraph.ASet(WPAT_COLWIDTH_PC, val * 100);
                            // FCurrentParagraph.ASetColor(WPAT_FGColor, clLime);
                                                end;
                                              end else
                                              begin
                                                val := StrToIntDef(s, 0);
                                                if val > 0 then
                                                begin
                                                  FCurrentParagraph.ASet(WPAT_COLWIDTH,
                                                    MulDiv(val, 1440, CSSPixelsPerInch));
                          // FCurrentParagraph.ASetColor(WPAT_FGColor, clYellow);
                                                end;
                                              end;
                                            end;

                // DEFAULT vertical "middle" for table cells
                // -------------------------------------------------------------
{$IFDEF HTML_CELLS_VALIGN_MIDDLE}
                                            FCurrentParagraph.ASet(WPAT_VertAlignment, 1);
{$ENDIF}
                // -------------------------------------------------------------
                                            ApplyAttribs(aTag);
                // -------------------------------------------------------------
                                            inc(FCurrentTable.ColNr);
                                          end;
                                          FNoText := FALSE;
                // read Par Props
                                        end
                                        else if aTag.NameEqual('pre') then
                                        begin
                                          if (FCurrentParagraph = nil) or
                                            (FCurrentParagraph.ColCount = 0) then
                                            NewParagraph;
                                          FReadingPRE := TRUE;
                                          AttrClear;
                                          Attr.SetFontName('Courier New');
                                          Attr.SetFontSize(10);
                                        end
                                        else if aTag.NameEqual('b') then
                                        begin
                                          PrintSkippedSpace;
                                          Attr.IncludeStyle(afsBold);
                                        end
                                        else if aTag.NameEqual('strong') then
                                        begin
                                          PrintSkippedSpace;
                                          Attr.IncludeStyle(afsBold);
                                        end
                                        else if aTag.NameEqual('em') then
                                        begin
                                          PrintSkippedSpace;
                                          Attr.IncludeStyle(afsItalic);
                                        end
                                        else if aTag.NameEqual('i') then
                                        begin
                                          PrintSkippedSpace;
                                          Attr.IncludeStyle(afsItalic);
                                        end
                                        else if aTag.NameEqual('s') then
                                        begin
                                          PrintSkippedSpace;
                                          Attr.IncludeStyle(afsStrikeOut);
                                        end
                                        else if aTag.NameEqual('sub') then
                                        begin
                                          PrintSkippedSpace;
                                          Attr.IncludeStyle(afsSub);
                                          Attr.ExcludeStyle(afsSuper);
                                        end
                                        else if aTag.NameEqual('super') or aTag.NameEqual('sup') then
                                        begin
                                          PrintSkippedSpace;
                                          Attr.IncludeStyle(afsSuper);
                                          Attr.ExcludeStyle(afsSub);
                                        end
                                        else if aTag.NameEqual('u') then
                                        begin
                                          PrintSkippedSpace;
                                          Attr.IncludeStyle(afsUnderline);
                                        end
                                        else if aTag.NameEqual('font') or
                                          (aTag.NameEqual('span')
                                          and (
                                          (OptNoSpanObjects or (loDoNotCreateSPANObjects in FLoadHTMLOptions))
                                          and not OptIgnoreSpan
                                          and not (loIgnoreSPANTag in FLoadHTMLOptions))) then
                                        begin
                                          if FFontStackCount >= Length(FFontStack) then
                                            SetLength(FFontStack, FFontStackCount + 10);
                                          Attr.GetCA(FFontStack[FFontStackCount]);
                                          inc(FFontStackCount);
                                          PrintSkippedSpace;
                                          s := aTag.ParamString('class', '');
                                          if s <> '' then
                                          begin
                                            TxtStyle := FRTFProps.ParStyles.FindTextStyle(s);
                                            if TxtStyle <> nil then
                                            begin
                                              Attr.Assign(TxtStyle);
                                            end;
                                          end;

                  // Yes, the FONT tag may also have a style!
                                          if style <> nil then
                                          begin
                                            Attr.GetCa(NewCa);
                                            style.ApplyToAttr(FRTFProps, NewCa);
                                            Attr.SetCa(NewCa);
                                          end;

                                    // Syntax:
                                    // size=2   or,
                                    // size=7pt
                                          s := aTag.ParamString('size', '');
                                          if s <> '' then
                                          begin
                                            val := Pos('pt', s);
                                            if val > 0 then
                                            begin
                                              val := StrToIntDef(Copy(s, 1, val - 1), 0);
                                              if val <> 0 then
                                                Attr.SetFontSize(val);
                                            end else
                                            begin
                                              val := aTag.ParamValue('size', 0);
                                              if val <> 0 then // <Font Size=N>
                                                case val of
                                                  1: Attr.SetFontSize(8);
                                                  2: Attr.SetFontSize(10);
                                                  3: Attr.SetFontSize(12);
                                                  4: Attr.SetFontSize(14);
                                                  5: Attr.SetFontSize(18);
                                                  6: Attr.SetFontSize(24);
                                                  7: Attr.SetFontSize(36);
                                                end;
                                            end;
                                          end;

                                          s := aTag.ParamString('color', '');
                                          if s <> '' then
                                            Attr.SetColorString(s);

                                      // "bgcolor" is not standard!
                                          s := aTag.ParamString('bgcolor', '');
                                          if s <> '' then
                                            Attr.SetBGColorString(s);

                                          s := aTag.ParamString('face', '');
                                          if s <> '' then
                                            Attr.SetFontName(s);
                                        end

                                        else if aTag.NameEqual('mergefield') then
                                        begin
                                          CheckDivPar;
                                          PrintSkippedSpace;
                 // This tag is only imported, never saved
                                          FLastMergeTag := PrintTextObj(
                                            wpobjMergeField,
                                            aTag.ParamString('name', ''),
                                            aTag.ParamString('command', ''),
                                            true, false, false).NewTag;
                                        end
                                        else if aTag.NameEqual('a') then // Open <A>
                                        begin
                                          s := aTag.ParamString('name', '');
                                          if s <> '' then
                                            objtype := wpobjBookmark
                                          else
                                          begin
                                            objtype := wpobjHyperlink;
                                            s := aTag.NormalizedParamString('href', '');
                                          end;
                                          CheckDivPar;
                                          PrintSkippedSpace;
                                          if objtype = wpobjBookmark then
                                          aLinkObj := PrintTextObj(objtype,
                                            s, // name
                                            aTag.ParamString('title', ''), // source
                                            true,
                                            false,
                                            false)
                                          else
                                          aLinkObj := PrintTextObj(objtype,
                                            aTag.ParamString('title', ''), // name
                                            s, // source
                                            true,
                                            false,
                                            false);
                                          aLinkObj.NewTag;
                                          FAObjectList.Add(aLinkObj);
                                          // the A tag may also have a style!
                                          if style <> nil then
                                          begin
                                            aLinkObj.MakeStyle(true); // Creates 'Style' element
                                            style.ApplyToPar(FRTFProps, aLinkObj.Style);
                                          end;

                                  // --- CLASS -> StyleName
                                          s := aTag.ParamString('class', '');
                                          if s <> '' then aLinkObj.StyleName := s
                                          else
                                          begin
                                            s := aTag.ParamString('id', '');
                                            if s <> '' then aLinkObj.StyleName := aTag.Name + '#' + s;
                                          end;
                                        end else if aTag.NameEqual('span') then // Close <span>
                                        begin
                                          if not OptIgnoreSpan and not (loIgnoreSPANTag in FLoadHTMLOptions) then
                                          begin
                                            CheckDivPar;
                                            PrintSkippedSpace;

                                            aSpanObj := PrintTextObj(wpobjSPANStyle,
                                              aTag.ParamString('name', ''), // span with name ?
                                              aTag.ParamString('style', ''),
                                              true,
                                              false,
                                              false);
                                            aSpanObj.NewTag;
                                            if style <> nil then
                                            begin
                                              aSpanObj.MakeStyle(true); // Creates 'Style' element
                                              style.ApplyToPar(FRTFProps, aSpanObj.Style);
                                            end;

                                  // --- CLASS -> StyleName
                                            s := aTag.ParamString('class', '');
                                            if s <> '' then aSpanObj.StyleName := s
                                            else
                                            begin
                                              s := aTag.ParamString('id', '');
                                              if s <> '' then aSpanObj.StyleName := aTag.Name + '#' + s;
                                            end;

                                            FSpanObjectList.Add(aSpanObj);
                                          end;
                                        end;
        end
        else
            //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            //+++++++++++++++++++++++++++++++++++++++++++ CLOSE ++++++++++++++++
            //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
          if aTag.Typ = wpXMLClosingTag then
          begin
                // This code reads text which was collected in the FReadStringBuffer
            if FReadingVariable and aTag.NameEqual(FReadingVariableTag) then
            begin
              if FReadingVariableName = '_STLYESHEET_' then
              begin
                if not (loIgnoreEmbeddedScript in FLoadHTMLOptions) then
                begin
                  StyleString := FReadStringBuffer.GetString;

                  if StyleString <> '' then
                  begin
                    cssparser.AsString := StyleString;
                    AddStyles;
                  end;
                end;

              end else // Load "RTF" Variables
                if not FReadingScript or not (loIgnoreEmbeddedScript in FLoadHTMLOptions) then
                begin
                  RTFDataCollection.RTFVariables.Strings[FReadingVariableName] :=
                    FReadStringBuffer.GetString;
                end;
              FReadStringBuffer.Clear;
              FReadingVariable := FALSE;
            end
            else if aTag.NameEqual('html') then
            begin
              FIgnoreText := loIgnoreTextOutsideOfHTMLTag in FLoadHTMLOptions;
            end else
{$IFDEF WPHTMLEXT}
              if aTag.NameEqual('header') or aTag.NameEqual('footer') then
              begin
                SelectRTFData(wpIsBody, wpraOnAllPages, '');
                FCurrentParagraph := FWorkRTFData.LastPar.LastInnerChild;
              end else
{$ENDIF}
                if aTag.NameEqual('textbox') then
                begin
                  SelectRTFData(wpIsBody, wpraOnAllPages, '');
                  FCurrentParagraph := FWorkRTFData.LastPar.LastInnerChild;
                end else
                  if aTag.NameEqual('noframes') and FLoadingNoFramesOnly then
                  begin
                    FIgnoreText := loIgnoreTextOutsideOfBodyTag in FLoadHTMLOptions;
                    FLoadingNoFramesOnly := FALSE;
                  end else
                    if aTag.NameEqual('textobj') then
                    begin
                      if FOpenTextObj <> nil then
                        FOpenTextObj.Params := FReadStringBuffer.GetString;
                      FReadStringBuffer.Clear;
                      FReadingVariable := FALSE;
                      FOpenTextObj := nil
                    end else
                      if aTag.NameEqual('body') then
                      begin
                        FIgnoreText := loIgnoreTextOutsideOfBodyTag in FLoadHTMLOptions;
                      end else
                        if aTag.NameEqual('ol') then
                        begin
{$IFDEF DIVTREE}
                          ParLevelUp;
{$ENDIF}

                          if numberlevel > 0 then dec(numberlevel);
                          if Length(CurrNumberStyles) > 0 then
                            SetLength(CurrNumberStyles, Length(CurrNumberStyles) - 1);
                        end else
                          if aTag.NameEqual('ul') then
                          begin
                            if bulletlevel > 0 then dec(bulletlevel);
                            if Length(CurrNumberStyles) > 0 then
                              SetLength(CurrNumberStyles, Length(CurrNumberStyles) - 1);
                          end else
                            if aTag.NameEqual('head') then
                            begin
                              FReadingHead := FALSE;
                            end else
                              if aTag.NameEqual('style') then
                              begin
                                FReadingStyle := FALSE;
                    //see RTF Varaiables above
                              end else
                                if aTag.NameEqual('script') then
                                begin
                                  FReadingScript := FALSE;
                   // see RTF Variables above
                                end
                                else if aTag.NameEqual('div') or aTag.NameEqual('center') then
                                begin
{$IFDEF DIVTREE}
                                  FCurrentParagraph := aTag.SavedPar;
                                  FParLevel := aTag.SavedLevel;
{$ELSE}
                                  if FDivStackCount >= 0 then
                                  begin
                                    FreeAndNil(FDivStack[FDivStackCount]);
                                    dec(FDivStackCount);
                                  end;
                                  FNeedDivParagraph := FALSE;
{$ENDIF}
                                end
                                else
                                  if aTag.NameEqual('code')
{$IFNDEF IGNOREblockquote} or aTag.NameEqual('blockquote'){$ENDIF}
{$IFNDEF IGNOREFORM} or aTag.NameEqual('form'){$ENDIF}
                                  then
                                  begin
                                    if aTag.NameEqual('blockquote') then
                                      FInBlockQuote := FALSE;

{$IFDEF DIVTREE}
                                    FCurrentParagraph := aTag.SavedPar;
                                    FParLevel := aTag.SavedLevel;
{$ENDIF}
                                  end
                                  else if
                                    (FCurrentParagraph <> nil) and not (FCurrentParagraph.ParagraphType in [wpIsTableRow, wpIsTable]) and (//V5.24.3 - ignore </p> in row or table
                                    aTag.NameEqual('p')
                                    or aTag.NameEqual('h1')
                                    or aTag.NameEqual('h2')
                                    or aTag.NameEqual('h3')
                                    or aTag.NameEqual('h4')
                                    or aTag.NameEqual('h5')
                                    or aTag.NameEqual('h6')
                                    or aTag.NameEqual('li'))
                                    then
                                  begin
{$IFNDEF DIVTREE}
                                    if FNewRowInClosePar then
                                    begin
                                      FNewRowInClosePar := FALSE;
                                      goto CloseRow;
                                    end;

                                    if not NoNewParagraph then
                                    begin
                                      if (FCurrentTable <> nil) and (FCurrentParagraph <> nil) and (paprIsTable in FCurrentParagraph.prop) then //V5.19.0 (FCurrentTable.FInCell) then
                                      begin
                                        NewChildParagraph
                                      end else
                                      begin
                                         NewParagraph;
                                         FAutoCreatedParagraph := FCurrentParagraph;  //V5.36.1
                                      end;
                                      NoNewParagraph := TRUE;
                                    end;
{$ENDIF}
                                    FHasSPC := FALSE;
                                    FNLIsNotSPC := TRUE; //5.17.3
                                  end
                                  else
                                    if aTag.NameEqual('pre') then
                                    begin
                                      FReadingPRE := FALSE;
                                      AttrClear;
                                    end
                                    else if aTag.NameEqual('b') then
                                      Attr.ExcludeStyle(afsBold)
                                    else if aTag.NameEqual('strong') then
                                      Attr.ExcludeStyle(afsBold)
                                    else if aTag.NameEqual('em') then
                                      Attr.ExcludeStyle(afsItalic)
                                    else if aTag.NameEqual('i') then
                                      Attr.ExcludeStyle(afsItalic)
                                    else if aTag.NameEqual('s') then
                                      Attr.ExcludeStyle(afsStrikeOut)
                                    else if aTag.NameEqual('sub') then
                                    begin
                                      Attr.ExcludeStyle(afsSub);
                                    end
                                    else if aTag.NameEqual('super') or aTag.NameEqual('sup') then
                                    begin
                                      Attr.ExcludeStyle(afsSuper);
                                    end
                                    else if aTag.NameEqual('u') then
                                      Attr.ExcludeStyle(afsUnderline)
                                    else if aTag.NameEqual('font') or
                                      ((aTag.NameEqual('span')
                                      and (loDoNotCreateSPANObjects in FLoadHTMLOptions)
                                      and not OptIgnoreSpan
                                      and not (loIgnoreSPANTag in FLoadHTMLOptions))) then
                                    begin
                                      if FFontStackCount > 0 then
                                      begin
                                        dec(FFontStackCount);
                                        Attr.SetCA(FFontStack[FFontStackCount]);
                                      end;
                                    end
                                    else if aTag.NameEqual('td') or aTag.NameEqual('th') or aTag.NameEqual('tdx') then
                                    begin

                                      if FCurrentParagraph.ParentRow <> nil then
                                      begin
                                        FCurrentParagraph := FCurrentParagraph.ParentRow;
                  //FCurrentParagraph.AdjustTableRow;
                                      end;
                                      ClosePreviousColumn;
{$IFDEF DIVTREE}
                                      FCurrentParagraph := aTag.SavedPar;
                                      FParLevel := aTag.SavedLevel;
{$ENDIF}
                                      FNoText := TRUE;
                                    end
                                    else if aTag.NameEqual('tr') then
                                    begin
                                      CloseRow:
                                      if (FCurrentParagraph.ParagraphType = wpIsTable) and
                                        (FCurrentParagraph.ParentPar = nil) then
                                      begin
                                     // Duplicated \tr - is ignored
                                        FNoText := TRUE;
                                      end else
                                      begin
                                        if (FCurrentParagraph.ParagraphType <> wpIsTableRow) and
                                          (FCurrentParagraph.ParentRow <> nil) then
                                        begin
                                          FCurrentParagraph := FCurrentParagraph.ParentRow;
                                          FRTFDataCollection.StatusMsg(WPST_ReadInfo, 'missing </TD> or </TH>');
                                        end;

                                        ClosePreviousColumn;

                                        if FCurrentParagraph.ParagraphType = wpIsTableRow then
                                          FCurrentParagraph.AdjustTableRow;
                                        if (FCurrentTable <> nil) then
                                          FCurrentParagraph := FCurrentTable.FTable;
                                        FNoText := TRUE;
                                      end;

{$IFDEF DIVTREE}
                                      FCurrentParagraph := aTag.SavedPar;
                                      FParLevel := aTag.SavedLevel;
{$ENDIF}

                                    end
                                    else if aTag.NameEqual('table') then
                                    begin
                                      if FCurrentParagraph.ParagraphType = wpIsTableRow then
                                      begin
                                        FRTFDataCollection.StatusMsg(WPST_ReadInfo, '</tr> is missing');
                                        ClosePreviousColumn;
                                        if FCurrentParagraph.ParagraphType = wpIsTableRow then
                                          FCurrentParagraph.AdjustTableRow;
                                        if (FCurrentTable <> nil) then
                                          FCurrentParagraph := FCurrentTable.FTable;
                                        FNoText := TRUE;
                                      end else
                                        if FCurrentParagraph.ParagraphType = wpIsTable then //V5.25 - repair empty tables
                                        begin
                                          if (FCurrentParagraph.ChildPar = nil) or
                                            (FCurrentParagraph.ChildPar.ParagraphType <> wpIsTableRow) then
                                            FCurrentParagraph.ParagraphType := wpIsSTDPar;
                                        end else
                                        begin
                                          FRTFDataCollection.StatusMsg(WPST_ReadInfo, '</Table> is not in correct level');
                                          if FCurrentParagraph.ParentRow <> nil then
                                          begin
                                            FCurrentParagraph := FCurrentParagraph.ParentRow;
                                            FCurrentParagraph.AdjustTableRow;
                                          end;
                                          if FCurrentParagraph.ParentTable <> nil then
                                            FCurrentParagraph := FCurrentParagraph.ParentTable;
                                        end;
                                      FNoText := TRUE;
                                      PopTable;
{$IFDEF DIVTREE}
                                      FCurrentParagraph := aTag.SavedPar;
                                      FParLevel := aTag.SavedLevel;
                                      if not (paprIsTable in FCurrentParagraph.prop) then
                                      begin
                                        Self.NewParagraph;
                                        NoNewParagraph := TRUE;
                                        FAutoCreatedParagraph := FCurrentParagraph;

                                      end else
                                      begin
                                        FNeedAutoPar := TRUE; // Create a paragraph after the table
                                      (*
                                        Self.NewChildParagraph;  // Create a paragraph after the table
                                        NoNewParagraph := TRUE;
                                        FAutoCreatedParagraph := FCurrentParagraph;
{$IFDEF TBLDEBUG}
                                        FCurrentParagraph.SetText('---------CELL after table');
{$ENDIF}
                                      *)
                                      end;
{$ELSE}
                                      if FCurrentParagraph.ParentPar <> nil then
                                      begin
                                        NoNewParagraph := FALSE;
                                        NewParagraph;
                                        NoNewParagraph := TRUE;
                                      end
                                      else
                                      begin
                                        ParLevelUp;
                                        FTableIsClosed := TRUE;
                                      end;
{$ENDIF}
                                    end

                                    else if aTag.NameEqual('mergefield') then
                                    begin
                                      CheckDivPar;
                                      PrintSkippedSpace;
                                    // This tag is only imported, never saved
                                      PrintTextObj(
                                        wpobjMergeField,
                                        '',
                                        '',
                                        true, true, false).SetTag(FLastMergeTag);
                                      FLastMergeTag := 0;
                                    end
                                    else
                                      if aTag.NameEqual('a') and (FAObjectList.Last <> nil) then // Close <A>
                                      begin
                                        CheckDivPar;
                                        PrintSkippedSpace;
                                        PrintTextObj(
                                          TWPTextObj(FAObjectList.Last).ObjType,
                                          TWPTextObj(FAObjectList.Last).Name,
                                          TWPTextObj(FAObjectList.Last).Source,
                                          true,
                                          true,
                                          false).SetTag(TWPTextObj(FAObjectList.Last).Tag);
                                        FAObjectList.Delete(FAObjectList.Count - 1);
                                      end
                                      else if aTag.NameEqual('span') and (FSpanObjectList.Last <> nil) then // Close <span>
                                      begin
                                        if not OptIgnoreSpan and not (loIgnoreSPANTag in FLoadHTMLOptions) then
                                        begin
                                          CheckDivPar;
                                          PrintSkippedSpace;
                                          PrintTextObj(
                                            wpobjSPANStyle,
                                            '',
                                            '',
                                            true,
                                            true,
                                            false).SetTag(TWPTextObj(FSpanObjectList.Last).Tag);
                                        end;
                                        FSpanObjectList.Delete(FSpanObjectList.Count - 1);
                                      end;
          end;
          FLastTagName := aTag.Name;
    finally
      // NO!!!! aTag.Free;
      style.Free;
      style := nil;
    end;
  end;
   // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
var aTag, aTag2: TWPCustomHTMLTag;
  i, j: Integer;
  bbCode: AnsiString;
  IsUNI: Boolean;
label ProcessHTTag;
begin
  Result := inherited Parse(datastream);
{$IFDEF WPHTMLEXT}sect := nil; {$ENDIF}
  FLastTagName := '';
  CSSPixelsPerInch := WPScreenPixelsPerInch;
  FNoText := FALSE;
  ReadEntity := FALSE;
  FReadingHead := FALSE;
  FNewRowInClosePar := FALSE;
  FReadingStyle := FALSE;
  FReadingScript := FALSE;
  FReadingPRE := FALSE;
  FLoadingNoFramesOnly := FALSE;
  EscapeCloseTag := '';
  EscapeCloseTagActive := FALSE;
  FStyleTemplates := TStringList.Create;
  FAObjectList := TWPTextObjList.Create;
  FTagStack := TList.Create;
  FLastMergeTag := 0;
  FSpanObjectList := TWPTextObjList.Create;
  SetLength(FDivStack, 10);
  body_sty := nil;
  table_sty := nil;
  CurrNumberStyles := nil;
  FDivStackCount := -1;
  FParLevel := 0;
  FNeedDivParagraph := FALSE;
  cssparser := TWPCSSParser.Create(TWPCSSParserStyleWP,Self);
  FFontStack := nil;
  FFontStackCount := 0;
  FSkipMode := FALSE;
  FSkipEnd := '';
  bulletlevel := 0;
  numberlevel := 0;
  FIgnoreText := (loIgnoreTextOutsideOfHTMLTag in FLoadHTMLOptions)
    or (loIgnoreTextOutsideOfBodyTag in FLoadHTMLOptions);

  FReadingVariable := FALSE;
  FReadingVariableTag := '';
  FReadingVariableName := '';
  FReadStringBuffer := TWPStringBuilder.Create;

  if not FLoadBodyOnly then
  begin
    FRTFDataCollection.Header.LeftMargin := 360;
    FRTFDataCollection.Header.RightMargin := 360;
    FRTFDataCollection.Header.TopMargin := 360;
    FRTFDataCollection.Header.BottomMargin := 360;
  end;
  FLastWasTD := FALSE;

  // DONT Clear the attribute if we are using SelectionAsString!
  if not FLoadBodyOnly then
    AttrClear;

  try
    Entity := '';
    ret := wpNoError;
    try
   // We select the body to ad the data
      SelectRTFData(wpIsBody, wpraIgnored, '');
   // and create the first paragraph
      NewParagraph;
      NoNewParagraph := TRUE;
      V := 0;
      FAutoCreatedParagraph := FCurrentParagraph;
      repeat
        IsUNI := FALSE;
        ch := ReadChar;
        // http://fundementals.sourceforge.net/cUnicodeCodecs.html
        if FOptUTF8 and (ch >= $80) then // UTF8...
        begin
          if ch and $C0 = $80 then
          begin
            // UTF8Sequence := 1;
          end;
          if ch and $20 = 0 then // 2-byte sequence
          begin
            UTF8Sequence := 2;
            V := ch and $1F;
          end else
            if ch and $10 = 0 then // 3-byte sequence
            begin
              UTF8Sequence := 3;
              V := ch and $0F;
            end else
              if ch and $08 = 0 then // 4-byte sequence (max needed for Unicode $0-$1FFFFF)
              begin
                UTF8Sequence := 4;
                V := ch and $07;
              end else
              begin
                UTF8Sequence := 1;
                // error
              end;
          for I := 1 to UTF8Sequence - 1 do
          begin
            D := ReadChar;
            if D and $C0 <> $80 then // following byte must start with 10xxxxxx
            begin
              // UTF8Sequence := 1;
              break;
            end;
            V := (V shl 6) or (D and $3F); // decode 6 bits
          end;
          Ch := V;
          IsUNI := true;
        end;

        if ch <= 0 then break
        else
          // Optional - accept CR (#13) to create new paragraph
          if FOptuseCR and not FTempIgnoreOptuseCR and (ch = 13) then
          begin
            NewParagraph;
          end else
          // Optional - handle BB codes (in [)
            if FOptuseBBCodes and (ch = Integer('[')) then
            begin
              bbCode := ReadLine(']');
              aTag := nil;
              if bbCode = '' then // Incorrect BB syntax
                PrintAChar('[')
              else
                if not ProcessBBCode(bbCode, aTag) then // Unknown BB code
                begin
                  PrintAChar('[');
                  PrintAString(bbCode);
                  PrintAChar(']');
                end else if aTag <> nil then
                  goto ProcessHTTag;
              ch := 0;
            end else
      // Support entities without closing ";" ----------------------------------
              if ReadEntity then
              begin
                if (ch = Integer(';')) or (ch <= 32) then
                begin
                  if not FIgnoreText then
                  begin
                    CheckDivPar;
                    PrintAChar('&');
                    for ch2 := 1 to Length(Entity) do
                      PrintAChar(Entity[ch2]);
                  end;
                  ReadEntity := FALSE;
                end
                else
                begin
                  Entity := Entity + AnsiChar(ch);
                  ch2 := WPTranslateEntity(Entity); 
                  if ch2 > 0 then
                  begin
                    if not FIgnoreText then
                    begin
                      CheckDivPar;
                      PrintWideChar(ch2);
                    end;
                    Entity := '';
                    ch := ReadChar;
                    if ch <> Integer(';') then UnReadChar;
                    ReadEntity := FALSE;
                  end;

                  continue;
                end;
              end;
      // -----------------------------------------------------------------------
        if EscapeCloseTagActive then
        begin
          if lowercase(Char(ch)) = EscapeCloseTag[1] then
          begin
            i := 2;
            while i < Length(EscapeCloseTag) do
            begin
              ch2 := ReadChar;
              if lowercase(Char(ch2)) <> EscapeCloseTag[i] then break;
              inc(i);
            end;
            if i = Length(EscapeCloseTag) then
            begin
              UnReadChar(Length(EscapeCloseTag) - 1);
              EscapeCloseTagActive := FALSE;
            end
            else
            begin
              UnReadChar(1);
              for ch := 1 to i do
                FReadStringBuffer.AppendChar(EscapeCloseTag[ch]);
            end;
          end else
          begin
            FReadStringBuffer.AppendChar(AnsiChar(ch));
          end;
        end else
          if ch = Integer('&') then
          begin
            if FHasSPC then
            begin
              PrintAChar(#32);
              FHasSPC := FALSE;
            end;
            ch := ReadChar;
            if ch = Integer('#') then
            begin
              ch := ReadInteger;
              if (ch > 0) and not FIgnoreText then PrintWideChar(ch);
              ch := ReadChar;
              if ch <> Integer(';') then UnReadChar;
            end else
            begin
              UnReadChar;
              ReadEntity := TRUE;
              Entity := '';
            end;
          end
      // ---------------- Read Tag ---------------------------------------------
          else if (ch = Integer('<')) and not FOptIgnoreSTDHTML then
          begin
            aTag := TWPCustomHTMLTag.ReadCreate(Self);

            ProcessHTTag: // GOTO FROM BB CODE!!!

            // In HTML the "/" for this tags is usually not used
            if (aTag.Typ = wpXMLOpeningTag) and
              (aTag.NameEqual('img') or
              aTag.NameEqual('br') or
              aTag.NameEqual('meta') or
              aTag.NameEqual('input') or
              aTag.NameEqual('pagenr') or
              aTag.NameEqual('tab') or
              aTag.NameEqual('page') or //HTMLVIEW allows <page>
              aTag.NameEqual('pagecount') or
              aTag.NameEqual('hr')
{$IFDEF WPHTMLEXT}
              or aTag.NameEqual('page') or aTag.NameEqual('section')
              or aTag.NameEqual('textfile')
{$ENDIF}
              ) then
              aTag.Typ := wpXMLClosedTag;

            if FSkipMode then
            begin
              if (aTag.Typ = wpXMLClosingTag) and
                aTag.NameEqual(FSkipEnd) then FSkipMode := FALSE;
              continue;
            end;

            if aTag.NameEqual('tbody') then // Ignore TBODY
            begin
              aTag.Free;
              aTag := nil;
            end else
              if aTag.NameEqual('center') and not ParAllowed then // Ignore <CENTER> in TABLE, TR
              begin
                if (aTag.Typ = wpXMLOpeningTag) and
                  (FCurrentParagraph <> nil) and
                  (FCurrentParagraph.ParentTable <> nil)
                  then
                  FCurrentParagraph.ParentTable.ASet(WPAT_Box_Align, WPBOXALIGN_HCENTERTEXT);
                aTag.Free;
                aTag := nil;
              end else
                if aTag.Typ = wpXMLClosingTag then
                begin
                  j := FTagStack.Count - 1;
                  while j >= 0 do
                  begin
                    aTag2 := TWPCustomHTMLTag(FTagStack[j]);
                // Don't go too far!
                    if aTag2.NameEqual('tr') and not aTag.NameEqual('tr') and
                      not aTag.NameEqual('table') then
                    begin
                      j := -1; // IGNORE!
                      break;
                    end;
                    if aTag2.NameEqual('table') and not aTag.NameEqual('table') then
                    begin
                      j := -1; // IGNORE!
                      break;
                    end;
                    if aTag2.NameEqual('div') and
                      not aTag.NameEqual('div') and //V5.20.9
                      not aTag.NameEqual('table')
                      and not aTag.NameEqual('td')
                      and not aTag.NameEqual('th')
                      and not aTag.NameEqual('tr') then
                    begin
                      j := -1; // IGNORE!
                      break;
                    end;
                    if TWPCustomHTMLTag(FTagStack[j]).NameEqual(aTag.LowercaseName) then break;
                    dec(j);
                  end;
                  if j >= 0 then
                  begin
                    i := FTagStack.Count - 1;
                    if j < i then
                    begin
                   // Missing close tags!!!
                      Entity := '';
                    end;
                    while i >= j do
                    begin
                      TWPCustomHTMLTag(FTagStack[i]).Typ := wpXMLClosingTag;
                      ProcessTag(TWPCustomHTMLTag(FTagStack[i]));
                      TWPCustomHTMLTag(FTagStack[i]).Free;
                      FTagStack.Delete(i);
                      dec(i);
                    end;
                  end else
                  begin
                 // Ignored Closing TAG!!!
                    Entity := '';
                  end;
                  aTag.Free;

                end else if aTag.Typ = wpXMLOpeningTag then
                begin
                // P, H1 .. are all closed by the next P, DIV, H1 ect
                  if aTag.NameEqual('div') or aTag.NameEqual('p')
                    or aTag.NameEqual('h1')
                    or aTag.NameEqual('h2')
                    or aTag.NameEqual('h3')
                    or aTag.NameEqual('h4')
                    or aTag.NameEqual('h5')
                    or aTag.NameEqual('h6')
                    or aTag.NameEqual('li') then
                  begin
                 { debug! if FCurrentParagraph.HasText('Alle') then
                  begin
                     j := 0;
                  end;  }
                    j := FTagStack.Count - 1;

                    while j >= 0 do
                    begin
                      aTag2 := TWPCustomHTMLTag(FTagStack[j]);
                      if aTag2.NameEqual('tr') or
                        aTag2.NameEqual('ul') or
                        aTag2.NameEqual('ol') or
                        aTag2.NameEqual('div') or
                        aTag2.NameEqual('table') or
                        aTag2.NameEqual('td') or
                        aTag2.NameEqual('th') then
                      begin
                        j := -1; // don't goo too far!
                        break;
                      end;
                      if aTag2.NameEqual('p')
                        or aTag2.NameEqual('h1')
                        or aTag2.NameEqual('h2')
                        or aTag2.NameEqual('h3')
                        or aTag2.NameEqual('h4')
                        or aTag2.NameEqual('h5')
                        or aTag2.NameEqual('h6')
                        or aTag2.NameEqual('li')
                        then break;
                      dec(j);
                    end;
                    if j > -1 then
                    begin
                      i := FTagStack.Count - 1;
                      while i >= j do
                      begin
                        TWPCustomHTMLTag(FTagStack[i]).Typ := wpXMLClosingTag;
                        ProcessTag(TWPCustomHTMLTag(FTagStack[i]));
                        TWPCustomHTMLTag(FTagStack[i]).Free;
                        FTagStack.Delete(i);
                        dec(i);
                      end;
                    end;
                  end;
                  FTagStack.Add(aTag);
                  ProcessTag(aTag);
                end
                else // Closed TAG
                begin
                  ProcessTag(aTag);
                  aTag.Free;
                end;
          end else
          begin
            if FReadingVariable then
              FReadStringBuffer.AppendChar(AnsiChar(ch))
            else
              if not FReadingHead and not FIgnoreText and
              // IGNORE CHARS IN TABLES
              (FNeedDivParagraph or (FCurrentParagraph = nil) or
                (FTableIsClosed and (FCurrentParagraph.ParagraphType = wpIsTable)) or //V5.24.3
                not (FCurrentParagraph.ParagraphType in [wpIsTable, wpIsTableRow]))
                then
              begin
                if FReadingPRE and (ch = 13) then
                  NewParagraph
                else
                  if (ch > 32) or (FReadingPRE and (ch <> 10)) then
                  begin
                    FNLIsNotSPC := FALSE;
                    NoNewParagraph := FALSE;
                    CheckDivPar;
                    //V5.24.3 If necessary create a new paragraph AFTER the table
                    if FCurrentParagraph.ParagraphType = wpIsTable then NewParagraph;

                    if FHasSPC then
                    begin
                      // ALL SPACES AT THE BEGINNING OF THE PARAGRAPH ARE IGNORED!
                      if not FCurrentParagraph.Empty([wpobjMergeField, wpobjHyperlink,
                        wpobjBookmark, wpobjTextProtection,
                          wpobjSPANStyle, wpobjCode], true) then
                        PrintAChar(#32);
                      FHasSPC := FALSE;
                    end;
                    if IsUNI then
                    begin
                      if (ch = $BD) and (OptCodePage <> 1252) then
                      begin
                        PrintWideChar(ch); //V5.24.2  - must be 1/2
                      end else
                        PrintWideChar(ch); //V5.24.2
                    end
                    else PrintAChar(AnsiChar(ch), OptCodePage);
                  end
                  else if ch = 32 then
                  begin
                    FHasSPC := TRUE;
                  end
                  else if (ch < 32) and not FNLIsNotSPC then
                  begin
                    FHasSPC := TRUE;
                  end;
              end;
          end;
      until ret <> wpNoError;
      ResetReadBuffer;

      while FCurrentTable <> nil do
        PopTable;
    except
      FReadingError := TRUE;
      raise;
    end;
   // Left over space ?
    if FHasSPC then
    begin
      PrintAChar(#32);
      FHasSPC := FALSE;
    end;

    // Remove additional Paragraph at end - V5.18.3
    if NoNewParagraph and (FCurrentParagraph <> nil)
      and (FCurrentParagraph.ParagraphType = wpIsSTDPar)
      and (FCurrentParagraph.CharCount = 0)
      and (FCurrentParagraph.Cell = nil) then
      FCurrentParagraph.DeleteParagraph;

  finally
    for j := 0 to FStyleTemplates.Count - 1 do
      TWPTextStyle(FStyleTemplates.Objects[j]).Free;
    for j := 0 to Length(FDivStack) - 1 do
      TWPTextStyle(FDivStack[j]).Free;
    FDivStack := nil;
    for j := 0 to FTagStack.Count - 1 do
      TObject(FTagStack[j]).Free;
    FTagStack.Free;
    FReadStringBuffer.Free;
    FAObjectList.Free;
    FSpanObjectList.Free;
    body_sty.Free;
    table_sty.Free;
    cssparser.Free;
    FStyleTemplates.Free;
    FFontStack := nil;
    CurrNumberStyles := nil;
    FFontStackCount := 0;
  end;
end;

initialization

  if GlobalWPToolsCustomEnviroment <> nil then
  begin
    GlobalWPToolsCustomEnviroment.RegisterReader([TWPHTMLReader]);
    GlobalWPToolsCustomEnviroment.RegisterWriter([TWPHTMLWriter]);
  end;

{$WARNINGS ON}
end.

