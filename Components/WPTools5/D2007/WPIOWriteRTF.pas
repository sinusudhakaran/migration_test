{:: This unit contains the reader and writer classes to support ANSI (*.TXT) files }
unit WPIOWriteRTF;

//******************************************************************************
// WPTools V5 - THE word processing component for VCL and .NET
// Copyright (C) 2004 by WPCubed GmbH and Julian Ziersch, all rights reserved
// WEB: http://www.wpcubed.com   mailto: support@wptools.de
//******************************************************************************
// WPIOWriteRTF - WPTools 5 RTF writer
// This RTF writer has been optimized to write compact and simple RTF code
// which does not make heavy use of groups
//******************************************************************************

interface
{$I WPINC.INC}

{.$DEFINE SIMPLE_AS_OLDPN}// OFF!  - pntext instead listtext
{.$DEFINE SAVEMODE}//OFF!  - Save Additional \pard and \plain
{.$DEFINE RTFCOMPACT}//OFF! -  = 2 bytes / par
{.$DEFINE IGNOREIMAGES}//OFF!
{.$DEFINE ASCIIRTF}//OFF
{.$DEFINE IGNOREALLOBJECTS}//OFF!
{.$DEFINE DEBUGSAVE}//OFF!
{.DEFINE SUPPRESS_PAR_AFTER_TEXT}//OFF - don't write \par after the text. (Required by Word)
{$DEFINE ASTERIX_FOR_SPECIAL_FIELDS} // Writhe /*company
{$DEFINE NEWCELLMERGE} //ON:V5.20.8
{$DEFINE NODOLLARINFONTNAMES} //ON: Correct 'Arial$xxxx'
{$DEFINE SAVEFONTCHARSETS} //ON!
{$DEFINE PARSTYLE_SAVEMODE} //ON! V5.17.4
{.$DEFINE CLOSEFIED_AFTER_LAST_PAR}//OFF when the text closes with a merge field put the \par
// INSIDE this field. This in facts appends a paragraph when opening the file in Word.
{-$DEFINE DONT_WRITE_PARSTYLE_ATTR}// experimental, OFF!
{$DEFINE SAVE_CHARSTYLES} //ON!  to disable use '-NoCharStyles'
{.$DEFINE SKIP_LIST_WITH_LS0}// some RTF reader crash with this setting
{.$DEFINE USE_WPTOOLS3_PROTECT}//OFF, (on in reader) use \shad to define protected text

{$IFDEF VER200} //For now - special adaption will be in V6
  {$WARNINGS OFF}
{$ENDIF}

uses Classes, Sysutils, WPRTEDefs, Graphics, Windows {MulDiv};

type
  // Used to store the last used paragraph attributes
  TWPWrtParAttr = record
    Attr: array[WPAT_IndentLeft..WPAT_ShadingType] of Integer;
    Brd: array[WPAT_BorderTypeL..WPAT_BorderColorBar] of Integer;
    BrdFlags: Integer;
  end;

  TWPRTFWriter = class(TWPCustomTextWriter) { from WPTools.RTE.Defs }
  private
{$IFDEF SAVEFONTCHARSETS}
    FontCharAttrMap: array of Integer; // map charattr->font nr
    FontList: TStringList;
{$ENDIF}
    FLastNumberStyle: TWPRTFNumberingStyle;
    FCloseNumberBracket: Boolean;
    FUsedNumberStyles, IndexForWhite: Integer;
    FUsedNumberGroups: array of Integer;
    FUseLSListSyntax: Boolean;
    FOptNoNumberProps: Boolean;
    FOptcellmaxwidth: Boolean;
    FDefaultFontSize: Integer;
    FOptOnlyStandardHeadFoot: Boolean;
    FOptNoCharStyles, FOptNoSpanStyles: Boolean;
    FOptIgnoreTableSETags: Boolean;
    FOptASCIIMode : Boolean;
    FLastParHadStyle: Boolean;
    FLastParStyle: TWPRTFStyleElement;
    FLastOutlineNr: Integer;
    FIgnoreNextPlain: Boolean;
    //FSaveFormattedText: Boolean; // Save WordWrapInformation
    odd_pages_def, even_pages_def: TWPPagePropertyRange;
    TitlePG, FacingPG, SpecialPG: Boolean;
    FCurrCharIndex: Cardinal;
    FCurrCharId: Boolean;
    FCurrParId, FLastWasNoWrap: Boolean;
    FLastWasSLMULT1: Boolean;
{$IFDEF SAVEFONTCHARSETS}
    function FontMap(fontname: string; charset: Integer): Integer;
{$ENDIF}
  protected
    FFieldOpen, FHyperOpen: Integer;
    FInitializeWritingText: string;
    FNeedSpace, FLastWasRTL: Boolean;
    FNeedPlain, FNeedPard: Boolean;
    FWritingTable: Integer;
    FColorMap: array of Integer;
    FCurrCharAttr: array[Boolean] of TWPCharAttr;
    FCurrParAttr: array[Boolean] of TWPWrtParAttr;
  protected
    class function UseForFilterName(const Filtername: string): Boolean; override; // RTF, HTML or classname

    procedure InitializeWriting; override;
    // Overwrite this procedure to write the header information (such as RTF tables ...)
    function WriteHeader: Boolean; override;
    // Write the closing information here
    function WriteFooter: Boolean; override;

    function MakeStringRTFConform(const Str: AnsiString): AnsiString;
    function MakeStringRTFConformW(const Str: WideString): AnsiString;
    function NumberStyleRTFString(NumberStyle: TWPRTFNumberingStyle; num_start: Integer): string;

    // Utility: Write a string followed by an integer value
    function WriteStringAndValue(const s: AnsiString; Value: Integer): Boolean;
    // Write the paragraph properties
    procedure WriteParAttr(ParStyle: TWPTextStyle; UseHistory: Boolean; DoGetInherited: Boolean; const rtftag: AnsiString; ID: Integer; mult: Integer; Checkmode: Boolean; defvalue: Integer = 0);

    function WriteParProps(ParStyle: TWPTextStyle; UseHistory, CellProps, DoGetInherited: Boolean): Boolean;
    // Write Shading Info
    function WriteShading(ParStyle: TWPTextStyle; UseHistory, CellProps, DoGetInherited: Boolean): Boolean;
    // Write a set of border flags
    function WriteBorder(ParStyle: TWPTextStyle; const Prefix: AnsiString; BorderFlags, BorderMask: Integer;
      TypeID, WidthID, ColorID, PaddID: Integer; UseHistory, NewBorder: Boolean): Boolean;
    function WriteObject(txtobj: TWPTextObj; par: TParagraph; posinpar: Integer): Boolean; override;
    function WriteElementStart(RTFData: TWPRTFDataBlock): Boolean; override;
    function WriteElementEnd(RTFData: TWPRTFDataBlock): Boolean; override;
    procedure WritePard;
    procedure WriteACharAttr(SourceStyle: TWPTextStyle;
      var CurrCharAttr, OldCharAttr: TWPCharAttr; WriteCharAttrIndex: Integer;
      DontCompare: Boolean; ThisParHasStyle: Boolean = FALSE; NoDefaultATTR: Boolean = FALSE);
    procedure WriteAStyle(const sty: TWPRTFStyleElement; nr: Integer); // n=-1 to save only props!
    procedure WriteSectionProps(par: TParagraph; NewPage: Boolean);

  public
    constructor Create(RTFDataCollection: TWPRTFDataCollection); override;
    procedure SetOptions(optstr: string); override;
    destructor Destroy; override;
    function WriteHyphen: Boolean; override;
    //:: Write a translated string RTF ESCAPE codes ...



    function WriteTranslatedString(const Str: AnsiString): Boolean; override;
    function WriteChar(aChar: Word): Boolean; override;
    function WriteParagraphStart(
      par: TParagraph;
      ParagraphType: TWPParagraphType;
      Style: TWPTextStyle): Boolean; override;
    function WriteLevelEnd(par: TParagraph): Boolean; override;
    function WriteParagraphEnd(par: TParagraph;
      ParagraphType: TWPParagraphType; NeedNL: Boolean): Boolean; override;
    //:: Write Table Start/End  (if result = false) this table will be ignored
    function WriteTable(tablepar: TParagraph; Style: TWPTextStyle; start: Boolean): Boolean; override;
    //:: Write Row Start/End  (if result = false) this row will be ignored.
    function WriteRow(rowpar: TParagraph; Style: TWPTextStyle; start: Boolean; OnlySelectedCells: Boolean = FALSE): Boolean; override;
    //:: Write Cell Start/End  (if result = false) this cell will be ignored.
    function WriteCell(cellpar: TParagraph; Style: TWPTextStyle; start: Boolean): Boolean; override;
    //:: Writes differences in the character attributes
    function UpdateCharAttr(CharAttrIndex: Cardinal): Boolean; override;
    {:: If this property is true (option: "-nonumberprops") then
       the numbering will be saved as normal text. Number styles will not
       be saved either. }
    property OptNoNumberProps: Boolean read FOptNoNumberProps write FOptNoNumberProps;
    {:: If this property is set (option: "-cellmaxwidth") all columns to
        on the very right side (nested, too) will use the maximum
        text area width. This helps to adjust the width of all tables and
        nested tables for better import in Word }
    property OptCellmaxwidth: Boolean read FOptcellmaxwidth write FOptcellmaxwidth;

    {:: If this property is true the RTF writer will not save header and footer texts which
    range is not defined by the RTF specifications, such as 'on last page'. }
    property OptOnlyStandardHeadFoot: Boolean read FOptOnlyStandardHeadFoot write FOptOnlyStandardHeadFoot;
    {:: If this property is true embedded span styles will not be saved as objects.
        Only the properties will be saved. }
    property OptNoSpanStyles: Boolean read FOptNoSpanStyles write FOptNoSpanStyles;
    {:: Don't write character styles (\cs). Use format string -nocharstyles. }
    property OptNoCharStyles: Boolean read FOptNoCharStyles write FOptNoCharStyles;
   {:: If this property is true the optional \tblstart and \tblend tags will be NOT written }
    property OptIgnoreTableSETags: Boolean read FOptIgnoreTableSETags write FOptIgnoreTableSETags;
   {:: If this property is true any character >128 will be saved using hex values. Use -asciimode.  }
   property OptASCIIMode  : Boolean read FOptASCIIMode write FOptASCIIMode;

  end;

implementation

uses Math;

constructor TWPRTFWriter.Create(RTFDataCollection: TWPRTFDataCollection);
begin
  inherited Create(RTFDataCollection);
{$IFDEF SAVEFONTCHARSETS}
  FontCharAttrMap := nil;
  FontList := TStringList.Create;
{$ENDIF}
end;

destructor TWPRTFWriter.Destroy;
begin
{$IFDEF SAVEFONTCHARSETS}
  FontCharAttrMap := nil;
  FontList.Free;
{$ENDIF}
  inherited Destroy;
end;

class function TWPRTFWriter.UseForFilterName(const Filtername: string): Boolean;
begin
  Result := inherited UseForFilterName(Filtername)
    or (CompareText(Filtername, 'RTF') = 0)
    or (CompareText(Filtername, 'DOC') = 0);
end;

procedure TWPRTFWriter.WritePard;
begin
  WriteString('\pard');
  if TableLevel > 0 then
    WriteStringAndValue('\intbl\itap', FWritingTable);
  FLastNumberStyle := nil;
  FLastWasNoWrap := FALSE;

  FillChar(FCurrParAttr[FCurrParId], SizeOf(FCurrParAttr[FCurrParId]), 0); //V5.23.7

end;

function TWPRTFWriter.WriteElementStart(RTFData: TWPRTFDataBlock): Boolean;
begin
 //- we write ALL elements first!
  Result := FALSE;
  if (OptOnlyBody or (soNoHeaderText in FStoreOptions)) and
    (RTFData.Kind = wpIsHeader) then exit
  else if (OptOnlyBody or (soNoFooterText in FStoreOptions)) and
    (RTFData.Kind = wpIsFooter) then exit
  else
    if RTFData.Kind = wpIsHeader then
    begin
      if not (soNoWPToolsHeaderFooterRTF in FStoreOptions) and
        not OptOnlyStandardHeadFoot then
      begin
          // First write the element name
        if RTFData.Name <> '' then
        begin
          WriteString('{\*\elementname{');
          WriteTranslatedString(RTFData.Name);
          WriteString('}}');
        end;
        if RTFData.Range = wpraOnFirstPage then
          Result := WriteString('{\headerf{')
        else if RTFData.Range = wpraOnAllPages then
          Result := WriteString('{\header{')
        else if RTFData.Range = wpraOnEvenPages then
          Result := WriteString('{\headerl{') // 5.17.1 was R
        else if RTFData.Range = wpraOnOddPages then
          Result := WriteString('{\headerr{') // 5.17.1 was L
        else Result := WriteString('{\*\wpheader' + IntToStr(Integer(RTFData.Range)) + '{');
      end else
        if TitlePG then
        begin
          if (RTFData.Range = wpraOnFirstPage) then
            Result := WriteString('{\headerf{')
          else if (RTFData.Range = wpraOnAllPages) then
            Result := WriteString('{\headerf{');
        end
        else if FacingPG then
        begin
          if RTFData.Range = odd_pages_def then
            Result := WriteString('{\headerr{')
          else if RTFData.Range = even_pages_def then
            Result := WriteString('{\headerl{');
        end else
          if (RTFData.Range = wpraOnAllPages) then
            Result := WriteString('{\header{');
    end
    else if RTFData.Kind = wpIsFooter then
    begin
      if not (soNoWPToolsHeaderFooterRTF in FStoreOptions) and
        not OptOnlyStandardHeadFoot then
      begin
        if RTFData.Name <> '' then
        begin
          WriteString('{\*\elementname{');
          WriteTranslatedString(RTFData.Name);
          WriteString('}}');
        end;
        if RTFData.Range = wpraOnFirstPage then
          Result := WriteString('{\footerf{')
        else if RTFData.Range = wpraOnAllPages then
          Result := WriteString('{\footer{')
        else if RTFData.Range = wpraOnEvenPages then
          Result := WriteString('{\footerl{') // 5.17.1 was R
        else if RTFData.Range = wpraOnOddPages then
          Result := WriteString('{\footerr{') // 5.17.1 was L
        else Result := WriteString('{\*\wpfooter' + IntToStr(Integer(RTFData.Range)) + '{');
      end else
        if TitlePG then
        begin
          if (RTFData.Range = wpraOnFirstPage) then
            Result := WriteString('{\footerf{')
          else if (RTFData.Range = wpraOnAllPages) then
            Result := WriteString('{\footerf{');
        end
        else if FacingPG then
        begin
          if RTFData.Range = odd_pages_def then
            Result := WriteString('{\footerr{')
          else if RTFData.Range = even_pages_def then
            Result := WriteString('{\footerl{');
        end else
          if (RTFData.Range = wpraOnAllPages) then
            Result := WriteString('{\footer{');
    end else Result := FALSE;
  if RTFData.Readonly then
  begin
    WriteString('\wpreadonly1'); // This is readonly!
    FNeedSpace := TRUE;
  end else FNeedSpace := FALSE;
end;

function TWPRTFWriter.WriteElementEnd(RTFData: TWPRTFDataBlock): Boolean;
begin
  Result := WriteString('}}' + #13 + #10);
  FNeedSpace := FALSE;
  FNeedPard := TRUE;
  FNeedPlain := TRUE;
end;

procedure TWPRTFWriter.WriteParAttr(ParStyle: TWPTextStyle; UseHistory: Boolean; DoGetInherited: Boolean; const rtftag: AnsiString; ID: Integer; mult: Integer; Checkmode: Boolean; defvalue: Integer = 0);
var attrval: Integer;
  gotit: Boolean;
begin
  attrval := 0;
  if DoGetInherited then
    gotit := ParStyle.AGetInherited(ID, attrval)
  else gotit := ParStyle.AGet(ID, attrval);

  if not gotit and (defvalue <> 0) then
  begin
    gotit := TRUE;
    attrval := defvalue;
  end;

  if (gotit or Checkmode) and (not UseHistory or (attrval <> FCurrParAttr[FCurrParId].Attr[ID])) then
  begin
    if mult = 0 then WriteStringAndValue(rtftag, attrval)
    else WriteStringAndValue(rtftag, attrval * mult);
    if UseHistory then FCurrParAttr[FCurrParId].Attr[ID] := attrval;
  end;
end; //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function TWPRTFWriter.WriteParProps(ParStyle: TWPTextStyle; UseHistory, CellProps, DoGetInherited: Boolean): Boolean;

var val, d: Integer;
  ac: AnsiChar;
  tvalue: Integer;
  tkind: TTabKind;
  tfill: TTabFill;
  tcolor: Integer;
  NumberStyle: TWPRTFNumberingStyle;
  procedure WriteListText;
  var
    numtxt: TWPTextStyle;
    fnr, j, font_nr: Integer;
    s: string;
  begin
    WriteString('{');
    if not OptNoNumberProps then
    begin
      {$IFNDEF SIMPLE_AS_OLDPN}
      if (soSaveOldPNNumbering in FStoreOptions) then
      {$ENDIF}
        WriteString('\pntext')
      {$IFNDEF SIMPLE_AS_OLDPN}
      else if not (soDontSaveListStyle in FStoreOptions) then
        WriteString('\listtext')
       {$ENDIF};
    end;

    font_nr := -1;
    if NumberStyle.TextStyle.AGet(WPAT_CharFont, fnr) then
    begin
      s := FRTFProps.Fontname[fnr];
      if not NumberStyle.TextStyle.AGet(WPAT_CharCharset, fnr) then
        fnr := 1; // DEFAULT_CHARSET
{$IFDEF SAVEFONTCHARSETS}
      for j := 0 to FontList.Count - 1 do
        if (FontList.Objects[j] = Pointer(fnr)) and
          (CompareText(s, FontList[j]) = 0) then
        begin
          font_nr := j;
          break;
        end;
{$ENDIF}
      if font_nr >= 0 then WriteStringAndValue('\f', font_nr);
    end;
    d := NumberStyle.TextStyle.AGetDef(WPAT_CharFontSize,
      FCurrCharAttr[FCurrCharId].Values[WPAT_CharFontSize]) div 50;
    if d > 0 then WriteStringAndValue('\fs', d);

    s := TParagraph(ParStyle).GetNumberText(numtxt);
    WriteString(#32);

    // was: WriteString(s);
    for j:=1 to length(s) do
       WriteChar(Word(Integer(s[j])));

    WriteString('\tab}');
    FNeedSpace := FALSE;
  end;
var numlevel, i: Integer;
  SkipNumbering, bHeightGetInherited: Boolean;
begin
  // Numbering -----------------------------------------------------------------
  NumberStyle := RTFProps.NumberStyles.FindParNumberStyle(ParStyle, numlevel, SkipNumbering);

  if NumberStyle <> FLastNumberStyle then
  begin
    if FCloseNumberBracket and (FLastNumberStyle <> nil) then
    begin
      FCloseNumberBracket := FALSE;
      WriteString('}'); // Close previous numbering
      FLastParStyle := nil; //V5.12.5
    end;
    if NumberStyle <> nil then
    begin
      if not OptNoNumberProps then
      begin
      // We save PN numbering. This does not save outline info and is
      // so used for the "simple numbering"
        if (soSaveOldPNNumbering in FStoreOptions)
{$IFDEF SIMPLE_AS_OLDPN}
        or ((NumberStyle.Group = 0) //V5.20.7a
          and (not (ParStyle is TParagraph) //V5.20.8b - Word does not allow those styles in cells!
          or (TParagraph(ParStyle).Cell = nil)))
{$ENDIF}
        then
        begin
          WriteString(
            '{{\*\pn\pnlvlbody' +
            NumberStyleRTFString(
            NumberStyle
            , 0) + '}');
          FNeedSpace := FALSE;
          FCloseNumberBracket := TRUE;
        end
        else // Save new style information, ls + level
          if not (soDontSaveListStyle in FStoreOptions) then
          begin
            WriteStringAndValue('\ls', NumberStyle._RTF_ID);
{$IFNDEF SIMPLE_AS_OLDPN}
            if (NumberStyle.Group > 0)
              or ((NumberStyle.Group = 0) //V5.20.7a
              and (not (ParStyle is TParagraph) //V5.20.8b - Word does not allow those styles in cells!
              or (TParagraph(ParStyle).Cell = nil))) then
{$ENDIF}
            begin
              if NumberStyle.Group > 0 then
                WriteStringAndValue('\ilvl',
                  ParStyle.AGetDef(WPAT_NumberLEVEL, 1) - 1)
              else WriteString('\ilvl0'); // = body
            end;
            if SkipNumbering then WriteString('\pnlvlcont');
            FNeedSpace := TRUE;
          end;
      end;
    end
    else if not (soDontSaveListStyle in FStoreOptions) and
      not (soSaveOldPNNumbering in FStoreOptions) then
    begin
      if not OptNoNumberProps then
      begin
{$IFDEF SKIP_LIST_WITH_LS0}
        WriteString('\ls0\ilvl0');
{$ELSE}
        WritePard;
        FNeedPard := FALSE;
{$ENDIF}
        if SkipNumbering then WriteString('\pnlvlcont');
      end;
    end;

  end;
  // Write the ListText which is ignored
  if not SkipNumbering and (NumberStyle <> nil) and
    not (soDontSaveListText in FStoreOptions) and (ParStyle is TParagraph) then
  begin
    WriteListText;
  end;

  if ParStyle.AGet(WPAT_NumberStart, i) then
  begin
    WriteStringAndValue('\pnstart', i)
  end;

  if SkipNumbering then FLastNumberStyle := nil
  else FLastNumberStyle := NumberStyle;
  // ---------------------------------------------------------------------------
  WriteParAttr(ParStyle, UseHistory, DoGetInherited, '\li', WPAT_IndentLeft, 0, true); // check for 0!
  WriteParAttr(ParStyle, UseHistory, DoGetInherited, '\fi', WPAT_IndentFirst, 0, true); // check for 0!
  WriteParAttr(ParStyle, UseHistory, DoGetInherited, '\ri', WPAT_IndentRight, 0, true); // check for 0!
  WriteParAttr(ParStyle, UseHistory, DoGetInherited and not CellProps, '\sb', WPAT_SpaceBefore, 0, true); // check for 0!
  WriteParAttr(ParStyle, UseHistory, DoGetInherited and not CellProps, '\sa', WPAT_SpaceAfter, 0, true); // check for 0!
  if not OptNoafsProtected and (ParStyle.AGetDef(WPAT_ParProtected, 0) <> 0) then
  begin
    WriteString('\wpparprot1');
    FNeedSpace := TRUE;
  end;

  bHeightGetInherited := DoGetInherited and not CellProps; // Avoid adding space in tables !

  if (bHeightGetInherited and ParStyle.AGetInherited(WPAT_LineHeight, val)) or
    (not bHeightGetInherited and ParStyle.AGet(WPAT_LineHeight, val)) //V5.20.1
    then //V5.19.8: Inherited
  begin
    if (not UseHistory or (val <> FCurrParAttr[FCurrParId].Attr[WPAT_LineHeight])) then
    begin
      WriteStringAndValue('\sl', MulDiv(val, 240, 100));
      WriteString('\slmult1'); //V5.19.3 - the standard is AFTER \sl (WPT can handle both)
      if UseHistory then
      begin
        FCurrParAttr[FCurrParId].Attr[WPAT_LineHeight] := val;
        FLastWasSLMULT1 := TRUE;
      end;
    end;
  end else // ELSE !!!
    if (bHeightGetInherited and ParStyle.AGetInherited(WPAT_SpaceBetween, val)) or
      (not bHeightGetInherited and ParStyle.AGet(WPAT_SpaceBetween, val)) //V5.20.1
      then //V5.19.8: Inherited
    begin
      if (not UseHistory or (val <> FCurrParAttr[FCurrParId].Attr[WPAT_SpaceBetween])) then
      begin
        if not UseHistory then
          WriteString('\slmult0')
        else
          if FLastWasSLMULT1 then
          begin
            WriteString('\slmult0');
            FLastWasSLMULT1 := FALSE;
          end;
        WriteStringAndValue('\sl', val);
        if UseHistory then
          FCurrParAttr[FCurrParId].Attr[WPAT_SpaceBetween] := val;
      end;
    end else
      if UseHistory and ((FCurrParAttr[FCurrParId].Attr[WPAT_SpaceBetween] <> 0) or
        (FCurrParAttr[FCurrParId].Attr[WPAT_LineHeight] <> 0)) then
      begin
      // Default Line Height V5.17
        WriteStringAndValue('\sl', 0);
        FCurrParAttr[FCurrParId].Attr[WPAT_LineHeight] := 0;
        FCurrParAttr[FCurrParId].Attr[WPAT_SpaceBetween] := 0;
      end;

  if CellProps then
  begin
    // CELL Padding
    (*     V5.35.1
    allval := ParStyle.AGetDefInherited(WPAT_PaddingAll, 0);
    WriteParAttr(DoGetInherited, '\clpadfl3\clpadl', WPAT_PaddingLeft, 0, false, allval);
    WriteParAttr(DoGetInherited, '\clpadft3\clpadt', WPAT_PaddingTop, 0, false, allval);
    WriteParAttr(DoGetInherited, '\clpadfr3\clpadr', WPAT_PaddingRight, 0, false, allval);
    WriteParAttr(DoGetInherited, '\clpadfb3\clpadb', WPAT_PaddingBottom, 0, false, allval);
    *)
    // Shading
    (*
    WriteParAttr('\clshdng', WPAT_ShadingValue, 100, false);
    case ParStyle.AGetDef(WPAT_ShadingType, 1000 {WPSHAD_clear} ) of
    //  WPSHAD_clear: WriteString('\clshdnil');
      WPSHAD_bdiag: WriteString('\clbgbdiag');
      WPSHAD_cross: WriteString('\clbgcross');
      WPSHAD_dcross: WriteString('\clbgdcross');
      WPSHAD_dkbdiag: WriteString('\clbgdkbdiag');
      WPSHAD_dkcross: WriteString('\clbgdkcross');
      WPSHAD_dkdcross: WriteString('\clbgdkdcross');
      WPSHAD_dkfdiag: WriteString('\clbgdkfdiag');
      WPSHAD_dkhor: WriteString('\clbgdkhor');
      WPSHAD_dkvert: WriteString('\clbgdkvert');
      WPSHAD_fdiag: WriteString('\clbgfdiag');
      WPSHAD_horiz: WriteString('\clbghoriz');
      WPSHAD_vert: WriteString('\clbgvert');
    end;
    WriteParAttr('\clcfpat', WPAT_FGColor, 0, false);
    WriteParAttr('\clcbpat', WPAT_BGColor, 0, false); *)

    FNeedSpace := TRUE;
    FNeedPard := TRUE;
  end { else
    if ParStyle.AGet(WPAT_FGColor, d) or ParStyle.AGet(WPAT_BGColor, d) then
    begin
    // Shading
      WriteParAttr('\shading', WPAT_ShadingValue, 100, false);
      case ParStyle.AGetDef(WPAT_ShadingType, 1000) of
        WPSHAD_clear: WriteString('\bgbnil');
        WPSHAD_bdiag: WriteString('\bgbdiag');
        WPSHAD_cross: WriteString('\bgcross');
        WPSHAD_dcross: WriteString('\bgdcross');
        WPSHAD_dkbdiag: WriteString('\bgdkbdiag');
        WPSHAD_dkcross: WriteString('\bgdkcross');
        WPSHAD_dkdcross: WriteString('\bgdkdcross');
        WPSHAD_dkfdiag: WriteString('\bgdkfdiag');
        WPSHAD_dkhor: WriteString('\bgdkhor');
        WPSHAD_dkvert: WriteString('\bgdkvert');
        WPSHAD_fdiag: WriteString('\bgfdiag');
        WPSHAD_horiz: WriteString('\bghoriz');
        WPSHAD_vert: WriteString('\bgvert');
      end;
      WriteParAttr('\cfpat', WPAT_FGColor, 0, false);
      WriteParAttr('\cbpat', WPAT_BGColor, 0, false);
      FNeedSpace := TRUE;
      FNeedPard := TRUE;
    end };

  // Save Tabstop
  if ParStyle.TabstopCount > 0 then
  begin
    for d := 0 to ParStyle.TabstopCount - 1 do
    begin
      ParStyle.TabstopGet(d, tvalue, tkind, tfill, tcolor);
      case tkind of
        tkRight: WriteString('\tqr');
        tkCenter: WriteString('\tqc');
        tkDecimal: WriteString('\tqdec');
        tkBarTab: WriteString('\tb');
      end;
      case tfill of
        tkDots: WriteString('\tldot');
        tkMDots: WriteString('\tlmdot');
        tkHyphen: WriteString('\tlhyph');
        tkUnderline: WriteString('\tlul');
        tkTHyphen: WriteString('\tlth');
        tkEqualSig: WriteString('\tleq');
        tkArrow: WriteString('\tlarrow');
      end;
      if tcolor <> 0 then
        WriteStringAndValue('\tbxcolor', tcolor);
      WriteStringAndValue('\tx', tvalue);
      FNeedSpace := TRUE;
    end;
    if (ParStyle is TParagraph) and
      (TParagraph(ParStyle).next <> nil) and
      not TParagraph(ParStyle).TabstopEqual(TParagraph(ParStyle).next) then
      FNeedPard := TRUE;
  end;

  // WPAT_WordSpacing..TODO
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ALIGNMENT
  val := ParStyle.AGetDefInherited(WPAT_Alignment, 0);
  if not UseHistory or (val <> FCurrParAttr[FCurrParId].Attr[WPAT_Alignment]) then
  begin
    case val of
      Integer(paralRight): WriteString('\qr');
      Integer(paralCenter): WriteString('\qc');
      Integer(paralBlock): WriteString('\qj');
    else WriteString('\ql');
    end;
    if UseHistory then
      FCurrParAttr[FCurrParId].Attr[WPAT_Alignment] := val;
    FNeedSpace := TRUE;
  end;

  if not CellProps then
  begin
    val := ParStyle.AGetDefInherited(WPAT_VertAlignment, 0);
    if (not UseHistory or (val <> FCurrParAttr[FCurrParId].Attr[WPAT_VertAlignment])) then
    begin
      case val of
        Integer(paralVertCenter): ac := 'c';
        Integer(paprVertJustified): ac := 'j';
        Integer(paralVertBottom): ac := 'b';
      else ac := 't';
      end;
      WriteString('\vertal');
      WriteString(ac);
      if UseHistory then
        FCurrParAttr[FCurrParId].Attr[WPAT_Alignment] := val;
      FNeedSpace := TRUE;
    end;
  end;

  if ParStyle.AGet(WPAT_ParID, i) then
  begin
    WriteStringAndValue('\wpparid', i);
    FNeedSpace := TRUE;
  end;

  if ParStyle.AGet(WPAT_ParFlags, i) then
  begin
    WriteStringAndValue('\wpparflg', i and $FF);
    FNeedSpace := TRUE;
  end;

  if not OptIgnoreKeepN and // V5.11.2
    ParStyle.AGet(WPAT_ParKeepN, i) and (i <> 0) then
  begin
    WriteString('\keepn');
    FNeedSpace := TRUE;
    FNeedPard := TRUE;
  end
    ; //else
  if ParStyle.AGet(WPAT_ParKeep, i) and (i <> 0) then
  begin
    WriteString('\keep');
    FNeedSpace := TRUE;
  end;

  if ParStyle.AGet(WPAT_NoWrap, i) and (i <> 0) then
  begin
    WriteString('\nowwrap1');
    FNeedSpace := TRUE;
    FNeedPard := TRUE;
    FLastWasNoWrap := TRUE;
  end else if FLastWasNoWrap then
  begin
    WriteString('\nowwrap0');
  end;

  if (ParStyle is TParagraph) and (ParStyle.Name <> '') then // now also used for table names!!!
  begin
    WriteString('{\*\wpparname{');
    WriteTranslatedString(ParStyle.Name);
    WriteString('}}');
    FNeedSpace := FALSE;
  end;

  if ParStyle.AGet(WPAT_PAR_NAME, i) then
  begin
    WriteString('{\*\wpcellname{');
    WriteTranslatedString(ParStyle.ANumberToString(i));
    WriteString('}}');
    FNeedSpace := FALSE;
  end;

  if ParStyle.AGet(WPAT_PAR_COMMAND, i) then
  begin
    WriteString('{\*\wpcellcom{');
    WriteTranslatedString(ParStyle.ANumberToString(i));
    WriteString('}}');
    FNeedSpace := FALSE;
  end;

  if ParStyle.AGet(WPAT_PAR_FORMAT, i) then
  begin
    WriteStringAndValue('\wpcellfrm', i);
    FNeedSpace := TRUE;
  end;

  Result := not FError;
end;

function TWPRTFWriter.WriteShading(ParStyle: TWPTextStyle; UseHistory, CellProps, DoGetInherited: Boolean): Boolean;
var cols: AnsiString;
  OldNeedSpace, FIgnoreShading: Boolean;
  val, ShadVal, ShadingType, FGColor, BGColor, a: Integer;
begin
  if CellProps then // TableStyles: clcbpatraw,  clcfpatraw
    cols := '\clc'
  else cols := '\c';

  if DoGetInherited then
  begin
    FGColor := ParStyle.AGetDefInherited(WPAT_FGColor, 0);
    BGColor := ParStyle.AGetDefInherited(WPAT_BGColor, 0);
    if not ParStyle.AGetInherited(WPAT_ShadingType, ShadingType) then
    begin
      if ParStyle.AGetInherited(WPAT_ShadingValue, a)
        and ((a <> 0) or (FGColor = IndexForWhite)) //V5.18.5
        then
      begin
        ShadingType := WPSHAD_solidfg; // We create '\clshdng', 10000 - ShadVal
      end else ShadingType := -1;
    end;
  end else
  begin
    FGColor := ParStyle.AGetDef(WPAT_FGColor, 0);
    BGColor := ParStyle.AGetDef(WPAT_BGColor, 0);
    if not ParStyle.AGet(WPAT_ShadingType, ShadingType) then
    begin
      if ParStyle.AGet(WPAT_ShadingValue, a)
        and ((a <> 0) or (FGColor = IndexForWhite)) //V5.18.5
        then
      begin
        ShadingType := WPSHAD_solidbg; // We create '\clshdng', 10000 - ShadVal
      end else ShadingType := -1;
    end;
  end;

  if (FGColor <> 0) and (BGColor = 0) and (FGColor <> IndexForWhite) then
  begin
    BGColor := FColorMap[IndexForWhite];
    FCurrParAttr[FCurrParId].Attr[WPAT_FGColor] := 0;
  end
  else if (FGColor = 0) and (BGColor <> 0) then
  begin
   { FGColor := FColorMap[IndexForWhite];
    FCurrParAttr[FCurrParId].Attr[WPAT_BGColor] := 0;  }
  end else
    if (BGColor <> 0) and (FGColor = IndexForWhite) then //V3 saved file (V5.18.9)
    begin
      FGColor := BGColor;
    end;
  val := 0;

  if FGColor < 0 then FGColor := 0;
  if BGColor < 0 then BGColor := 0;

  if (FGColor <> 0) and
    (not UseHistory or (FGColor <> FCurrParAttr[FCurrParId].Attr[WPAT_FGColor])) then
  begin
    WriteString(cols);
    WriteStringAndValue('fpat', FColorMap[FGColor]);
    if UseHistory then
    begin
      FCurrParAttr[FCurrParId].Attr[WPAT_FGColor] := FGColor;
      if FGColor <> 0 then FNeedPard := TRUE;
    end;
    FNeedSpace := TRUE;
    if ShadingType <> WPSHAD_solidbg then
      BGColor := FGColor;
    val := 100;
  end;

  if (BGColor <> 0) and
    (not UseHistory or (BGColor <> FCurrParAttr[FCurrParId].Attr[WPAT_BGColor])) then
  begin
    WriteString(cols);
    WriteStringAndValue('bpat', FColorMap[BGColor]);
    if UseHistory then
    begin
      FCurrParAttr[FCurrParId].Attr[WPAT_BGColor] := BGColor;
      if BGColor <> 0 then FNeedPard := TRUE;
    end;
  end;

  if DoGetInherited and ParStyle.AGetInherited(WPAT_ShadingValue, val) then
    ShadVal := val * 100
  else if ParStyle.AGet(WPAT_ShadingValue, val) then
    ShadVal := val * 100
  else ShadVal := 0;

  if (FGColor <> 0) and (FRTFProps.ColorTable[FGColor] <> clWhite) then
  begin
    if (ShadingType < 0) and (val <> 0) then ShadingType := WPSHAD_solidfg;
  end else if (BGColor <> 0) and (FRTFProps.ColorTable[BGColor] <> clWhite) then
  begin
    if (ShadingType < 0) and (val <> 0) then ShadingType := WPSHAD_solidbg;
  end;

  FIgnoreShading := FALSE;
  if (ShadingType >= 0) and
    (not UseHistory or (ShadingType <> FCurrParAttr[FCurrParId].Attr[WPAT_ShadingType])) then
  begin

    if (ShadingType = WPSHAD_clear) and (ShadVal <> 0) then
      ShadingType := WPSHAD_solidbg; // V5.20.1

    OldNeedSpace := FNeedSpace;
    FNeedSpace := TRUE;
    if CellProps then
      case ShadingType of
        WPSHAD_solidbg: if ShadVal <> 10000 then begin WriteStringAndValue('\clshdng', {10000 - } //V5.19.7
              ShadVal); FIgnoreShading := TRUE; end;
        WPSHAD_solidfg: if ShadVal <> 0 then begin WriteStringAndValue('\clshdng', ShadVal); FIgnoreShading := TRUE; end;
        WPSHAD_clear: WriteString('\clshdnil');
        WPSHAD_bdiag: WriteString('\clbgbdiag');
        WPSHAD_cross: WriteString('\clbgcross');
        WPSHAD_dcross: WriteString('\clbgdcross');
        WPSHAD_dkbdiag: WriteString('\clbgdkbdiag');
        WPSHAD_dkcross: WriteString('\clbgdkcross');
        WPSHAD_dkdcross: WriteString('\clbgdkdcross');
        WPSHAD_dkfdiag: WriteString('\clbgdkfdiag');
        WPSHAD_dkhor: WriteString('\clbgdkhor');
        WPSHAD_dkvert: WriteString('\clbgdkvert');
        WPSHAD_fdiag: WriteString('\clbgfdiag');
        WPSHAD_horiz: WriteString('\clbghoriz');
        WPSHAD_vert: WriteString('\clbgvert');
      else FNeedSpace := OldNeedSpace;
      end
    else case ShadingType of
        WPSHAD_solidbg: begin WriteStringAndValue('\shading', {10000 - } //V5.19.7
              ShadVal); FIgnoreShading := TRUE; end;
        WPSHAD_solidfg: begin WriteStringAndValue('\shading', ShadVal); FIgnoreShading := TRUE; end;
        WPSHAD_clear: WriteString('\bgbnil'); //#RTF
        WPSHAD_bdiag: WriteString('\bgbdiag');
        WPSHAD_cross: WriteString('\bgcross');
        WPSHAD_dcross: WriteString('\bgdcross');
        WPSHAD_dkbdiag: WriteString('\bgdkbdiag');
        WPSHAD_dkcross: WriteString('\bgdkcross');
        WPSHAD_dkdcross: WriteString('\bgdkdcross');
        WPSHAD_dkfdiag: WriteString('\bgdkfdiag');
        WPSHAD_dkhor: WriteString('\bgdkhor');
        WPSHAD_dkvert: WriteString('\bgdkvert');
        WPSHAD_fdiag: WriteString('\bgfdiag');
        WPSHAD_horiz: WriteString('\bghoriz');
        WPSHAD_vert: WriteString('\bgvert');
      else FNeedSpace := OldNeedSpace;
      end;
    if UseHistory then
    begin
      FCurrParAttr[FCurrParId].Attr[WPAT_BGColor] := ShadingType;
     // if not CellProps then
     //   FNeedPard := TRUE;
    end;
  end;

  if ((DoGetInherited and ParStyle.AGetInherited(WPAT_ShadingValue, val)) or //V5.12.5
    (not DoGetInherited and ParStyle.AGet(WPAT_ShadingValue, val))) and
    (not UseHistory or (val <> FCurrParAttr[FCurrParId].Attr[WPAT_ShadingValue])) then
  begin
    if not FIgnoreShading then
    begin
      if CellProps then WriteStringAndValue('\clshdng', val * 100)
      else WriteStringAndValue('\shading', val * 100);

      if UseHistory then
        FCurrParAttr[FCurrParId].Attr[WPAT_ShadingValue] := val;
    end;
  end;

  Result := TRUE;
end;

function TWPRTFWriter.WriteBorder(ParStyle: TWPTextStyle; const Prefix: AnsiString; BorderFlags, BorderMask: Integer;
  TypeID, WidthID, ColorID, PaddID: Integer; UseHistory, NewBorder: Boolean): Boolean;
var TypeVal, WidthVal, ColorVal, sp: Integer;
  st: AnsiString;
begin
  if (BorderFlags and BorderMask) <> 0 then
  begin
    if not (ParStyle.AGet(TypeID, TypeVal) or ParStyle.AGet(WPAT_BorderType, TypeVal)) then
      TypeVal := 0;
    if not (ParStyle.AGet(ColorID, ColorVal)
      or ParStyle.AGet(WPAT_BorderColor, ColorVal)) then
      ColorVal := 0;
    if not (ParStyle.AGet(WidthID, WidthVal)
      or ParStyle.AGet(WPAT_BorderWidth, WidthVal)) then
      WidthVal := 0;
    if not UseHistory or NewBorder or
      ((FCurrParAttr[not FCurrParId].Brd[TypeID] <> TypeVal) or
      (FCurrParAttr[not FCurrParId].Brd[ColorID] <> ColorVal) or
      (FCurrParAttr[not FCurrParId].Brd[WidthID] <> WidthVal)) then
    begin
      case TypeVal of
        WPBRD_SINGLE: st := '\brdrs';
        WPBRD_NONE: st := '\brdrnil';
        WPBRD_DOUBLEW: st := '\brdrth';
        WPBRD_SHADOW: st := '\brdrsh';
        WPBRD_DOUBLE: st := '\brdrdb';
        WPBRD_DOTTED: st := '\brdrdot';
        WPBRD_DASHED: st := '\brdrdash';
        WPBRD_HAIRLINE: st := '\brdrhair';
        WPBRD_INSET: st := '\brdrinset';
        WPBRD_DASHEDS: st := '\brdrdashsm';
        WPBRD_DOTDASH: st := '\brdrdashd';
        WPBRD_DOTDOTDASH: st := '\brdrdashdd';
        WPBRD_OUTSET: st := '\brdroutset';
        WPBRD_TRIPPLE: st := '\brdrtriple';
        WPBRD_THIKTHINS: st := '\brdrtnthsg';
        WPBRD_THINTHICKS: st := '\brdrthtnsg';
        WPBRD_THINTHICKTHINS: st := '\brdrtnthtnsg';
        WPBRD_THICKTHIN: st := '\brdrtnthmg';
        WPBRD_THINTHIK: st := '\brdrthtnmg';
        WPBRD_THINTHICKTHIN: st := '\brdrtnthtnmg';
        WPBRD_THICKTHINL: st := '\brdrtnthlg';
        WPBRD_THINTHICKL: st := '\brdrthtnlg';
        WPBRD_THINTHICKTHINL: st := '\brdrtnthtnlg';
        WPBRD_WAVY: st := '\brdrwavy';
        WPBRD_DBLWAVY: st := '\brdrwavydb';
        WPBRD_STRIPED: st := '\brdrdashdotstr';
        WPBRD_EMBOSSED: st := '\brdremboss';
        WPBRD_ENGRAVE: st := '\brdrengrave';
        WPBRD_FRAME: st := '\brdrframe';
      else st := '\brdrs';
      end;
      WriteString(Prefix); // for example: \brdrl or \clbrdrl or \tsbrdrl
      WriteString(st);
      if (soWriteDefaultBorderProps in FStoreOptions) or (WidthVal <> 0) then WriteStringAndValue('\brdrw', WidthVal);
      if (soWriteDefaultBorderProps in FStoreOptions) or (ColorVal <> 0) then WriteStringAndValue('\brdrcf', FColorMap[ColorVal]);

      if PaddID > 0 then
      begin
        sp := ParStyle.AGetDef(PaddID, 0);
        if sp = 0 then
          sp := ParStyle.AGetDef(WPAT_PaddingAll, 0);
        if sp > 0 then WriteStringAndValue('\brsp', sp);
      end;
      // brsp
      if UseHistory then
      begin
        FCurrParAttr[FCurrParId].Brd[TypeID] := TypeVal;
        FCurrParAttr[FCurrParId].Brd[ColorID] := ColorVal;
        FCurrParAttr[FCurrParId].Brd[WidthID] := WidthVal;
      end;
    end;
  end;
  Result := TRUE;
end;

procedure TWPRTFWriter.WriteSectionProps(par: TParagraph; NewPage: Boolean);
var FSectionProps: TWPRTFSectionProps;
  FOldFWritingTable: Integer;
begin
  WriteString('\sect\sectd');

  if NewPage then WriteString('\sbkpage') else WriteString('\sbknone');

  if wpfSectionsRestartFootnoteNumbers in RTFDataCollection.FormatOptionsEx then
    WriteString('\sftnrestart');

  FSectionProps := RTFDataCollection.GetSectionProps(par.SectionID);

  if (paprPagenrRestart in par.prop) or (wpsec_ResetPageNumber in FSectionProps.Select) then
    WriteString('\pgnrestart');

  if wpsec_PageSize in FSectionProps.Select then
  begin
   { if FSectionProps.Landscape then
      WriteString('\lndscpsxn1')
    else WriteString('\lndscpsxn0');  }

    if FSectionProps.Landscape then //V5.23.7
      WriteString('\lndscpsxn');

    WriteStringAndValue('\pgwsxn', FSectionProps.PageWidth);
    WriteStringAndValue('\pghsxn', FSectionProps.PageHeight);
  end;

  if wpsec_ResetOutlineNums in FSectionProps.Select then
    WriteString('\wpresoutl1');

  if wpsec_Margins in FSectionProps.Select then
  begin
    WriteStringAndValue('\marglsxn', FSectionProps.LeftMargin);
    WriteStringAndValue('\margrsxn', FSectionProps.RightMargin);
    WriteStringAndValue('\margtsxn', FSectionProps.TopMargin);
    WriteStringAndValue('\margbsxn', FSectionProps.BottomMargin);
    WriteStringAndValue('\headery', FSectionProps.MarginHeader);
    WriteStringAndValue('\footery', FSectionProps.MarginFooter);
  end;

  if wpsec_SelectHeaderFooter in FSectionProps.Select then
  begin
    WriteString('\sectionpg');
    if (RTFDataCollection.Find(wpIsHeader, wpraOnFirstPage, '', FSectionProps.SectionID) <> nil) or
      (RTFDataCollection.Find(wpIsFooter, wpraOnFirstPage, '', FSectionProps.SectionID) <> nil) then
    begin
      WriteString('\titlepg');
    end;
  end;

    // if wpsec_paperbin in FSectionProps.Select then
    //        WriteStringValue('\binsxn', FSectionProps.TrayAllPages);
  FOldFWritingTable := FWritingTable;
  FWritingTable := 0;
  WriteElements(par.SectionID); // V5.13.5
  FWritingTable := FOldFWritingTable;

  FNeedSpace := TRUE;
end;

function TWPRTFWriter.WriteParagraphStart(
  par: TParagraph;
  ParagraphType: TWPParagraphType;
  Style: TWPTextStyle): Boolean;
var BrdFlags, i: Integer;
  FNewBorder: Boolean;
  band: TCustomParagraphObj;

  sty: TWPRTFStyleElement;
  CurrCharAttr, OldCharAttr: TWPCharAttr;
  bands: string;
{$IFDEF GROUPVAR} 
  bandsvar: string;
{$ENDIF} 
begin
  Result := TRUE;
{$IFDEF SAVEMODE}
  FCurrCharIndex := $FFFFFFFF;
  FCurrCharId := FALSE;
{$ENDIF}

  if (paprNewSection in par.prop) and
    (par.SectionID <> FGlobalSectionID) and
    not OptNoPageInfo and
    not (soNoPageFormatInRTF in FStoreOptions) and
    not (soNoSectionFormatInRTF in FStoreOptions) then
  begin
    WriteSectionProps(par, (paprNewPage in par.prop) and not OptNoPageBreaks);
  end else
    if (paprNewPage in par.prop) and not OptNoPageBreaks then
    begin
      Result := WriteString('\page');
      FNeedSpace := TRUE;
    end;

  if par.ParagraphType in [wpIsReportGroup, wpIsReportHeaderBand,
    wpIsReportDataBand, wpIsReportFooterBand] then
  begin
    band := par.ParagraphObjFind(WPPAROBJ_WPBAND);
    if band <> nil then
    begin
      bands := band.AsString;
      if not par.AGet(WPAT_BANDPAR_STR, i) or
        (par.ANumberToString(i) <> bands) then
        par.ASet(WPAT_BANDPAR_STR,
          par.AStringToNumber(bands));
{$IFDEF GROUPVAR} //WP6
      bandsvar := band.ExtraAsString;
{$ENDIF} 
    end
    else
    begin
      if par.AGet(WPAT_BANDPAR_STR, i) then
        bands := par.ANumberToString(i)
      else bands := '';
{$IFDEF GROUPVAR} 
      if par.AGet(WPAT_BANDPAR_VAR, i) then
        bandsvar := par.ANumberToString(i)
      else bandsvar := '';
{$ENDIF} 
    end;
    if bands <> '' then
    begin
      WriteString('{\*\wpmergepar{');
      WriteString(bands);
      WriteString('}}');
    end;
{$IFDEF GROUPVAR} 
    if bandsvar <> '' then
    begin
      WriteString('{\*\wpmergevar{');
      WriteString(bandsvar);
      WriteString('}}');
    end;
{$ENDIF} 
    WriteString('\wpmergestart');
    FNeedSpace := TRUE;
  end;
  sty := FRTFProps.ParStyles.GetStyle(par.style);

  if (FLastParStyle <> sty) or (par.CharCount = 0) then
  begin
    if sty = nil then FNeedPlain := TRUE;
    FNeedPard := TRUE;
  end;

  if not par.AGet(WPAT_BorderFlags, BrdFlags) then BrdFlags := 0;
  FNewBorder := BrdFlags <> FCurrParAttr[not FCurrParId].BrdFlags;
  if FNeedPard or FNewBorder then
  begin
    if FLastNumberStyle <> nil then
    begin
      if FCloseNumberBracket then
      begin
        WriteString('}');
        FCloseNumberBracket := FALSE;
      end;
      FLastNumberStyle := nil;
    end;
    // if not (paprIsTable in par.prop) then
    WritePard; // WriteString('\pard');

    if FNeedPlain then
    begin
      if not FIgnoreNextPlain then
        WriteString('\plain');
      FillChar(OldCharAttr, SizeOf(OldCharAttr), 0);
      OldCharAttr.Values[WPAT_CharFont] := $FFFF;
      FNeedPlain := FALSE;
      FNeedSpace := TRUE;
    end;

    par.AGet(WPAT_BorderFlags, BrdFlags);
    FNewBorder := TRUE;
    FNeedSpace := TRUE;
    FillChar(FCurrParAttr[not FCurrParId], SizeOf(FCurrParAttr[FCurrParId]), 0);
    FNeedPard := FALSE;
    FLastWasSLMULT1 := FALSE;
  end;
  FCurrParAttr[FCurrParId] := FCurrParAttr[not FCurrParId];
  if {not (paprIsTable in par.prop) and}(BrdFlags <> 0) and (par.Cell = nil) then
  begin
    if (BrdFlags and WPBRD_DRAW_Box) <> 0 then
      WriteString('\box\brdrs');
    WriteBorder(par, '\brdrl', BrdFlags, WPBRD_DRAW_Left,
      WPAT_BorderTypeL, WPAT_BorderWidthL, WPAT_BorderColorL,
      WPAT_PaddingLeft, true, FNewBorder);
    WriteBorder(par, '\brdrr', BrdFlags, WPBRD_DRAW_Right,
      WPAT_BorderTypeR, WPAT_BorderWidthR, WPAT_BorderColorR,
      WPAT_PaddingRight, true, FNewBorder);
    WriteBorder(par, '\brdrt', BrdFlags, WPBRD_DRAW_Top,
      WPAT_BorderTypeT, WPAT_BorderWidthT, WPAT_BorderColorT,
      WPAT_PaddingTop, true, FNewBorder);
    WriteBorder(par, '\brdrb', BrdFlags, WPBRD_DRAW_Bottom,
      WPAT_BorderTypeB, WPAT_BorderWidthB, WPAT_BorderColorB,
      WPAT_PaddingBottom, true, FNewBorder);
    FCurrParAttr[FCurrParId].BrdFlags := BrdFlags;
  end;

  if paprHidden in par.prop then
    WriteStringAndValue('\wpparhide', 1);

  if paprRightToLeft in par.prop then
  begin
    WriteString('\rtlpar');
    FLastWasRTL := TRUE;
  end
  else if FLastWasRTL then
  begin
    WriteString('\ltrpar');
    FLastWasRTL := FALSE;
  end;

  if sty <> nil then
  begin
    if not (soNoStyleTable in FStoreOptions) and (sty._RTF_ID > 0) then
    begin
      WriteStringAndValue('\plain\s', sty._RTF_ID);
      FLastParHadStyle := true;
      FIgnoreNextPlain := TRUE;

      FillChar(FCurrCharAttr[not FCurrParId], SizeOf(FCurrCharAttr[not FCurrParId]), 0);

      sty.TextStyle.AGetStyleCharAttr(FCurrCharAttr[FCurrCharId], false, true);

    end;
      // Write The Style Attributes
    // WriteAStyle(sty, -1); V5.12.5  Write Inhgerited BELOW!
  end else
    if FLastParHadStyle then
    begin
      WriteString('\s0');
      FLastParHadStyle := FALSE;
    end;
  FLastParStyle := sty;

  // WriteParProps(par, true, false, true); //V5.12.5
  WriteParProps(par, sty = nil, false, true); //V5.17.3 (no history when styles are saved)

  WriteShading(par, true, false, true); //V5.12.5

  if par.AGetInherited(WPAT_ParIsOutline, FLastOutlineNr) then WriteStringAndValue('\toc', FLastOutlineNr)
  else if (FLastOutlineNr <> 0) then
  begin
    WriteStringAndValue('\toc', 0);
    FLastOutlineNr := 0;
  end;

  if par.AGet(WPAT_MaxLength, i) then
    WriteStringAndValue('\wpmaxpar', i);

  if (soSelectionMarker in FStoreOptions) and not FClipboardOperation then
  begin
    if par = FRTFDataCollection.Cursor.block_s_par then
      WriteStringAndValue('\wpparsel', FRTFDataCollection.Cursor.block_s_posinpar);
    if par = FRTFDataCollection.Cursor.block_e_par then
      WriteStringAndValue('\wpparsel', FRTFDataCollection.Cursor.block_e_posinpar);
    if paprCellIsSelected in par.prop then WriteString('\wpcellsel');
  end;

  FNeedPlain := TRUE;

  if (par.CharCount = 0) and (par.LoadedCharAttr > 0) then
  begin
    FRTFProps.Attributes.GetCharAttr(par.LoadedCharAttr, CurrCharAttr);
    WriteACharAttr(par, CurrCharAttr, OldCharAttr, par.LoadedCharAttr and cafsNONE, true);
  end else last_charattr_index := Cardinal(-1);

  FCurrParId := not FCurrParId;
end;

function TWPRTFWriter.WriteLevelEnd(par: TParagraph): Boolean;
var band: TCustomParagraphObj;
begin
  if (par.ParagraphType = wpIsReportGroup) and
    ((par.NextPar <> nil) or (par.ParentPar <> nil)) then
  begin
    band := par.ParagraphObjFind(WPPAROBJ_WPBAND);
    if band <> nil then
    begin
      WriteString('{\*\wpmergepar{');
      WriteString(band.AsString);
      WriteString('}}');
    end;
    WriteString('\wpmergeend');
    WritePard;
    WriteString('\par' + #13 + #10);
  end;
  Result := TRUE;
end;

function TWPRTFWriter.WriteParagraphEnd(par: TParagraph;
  ParagraphType: TWPParagraphType; NeedNL: Boolean): Boolean;
begin
  Result := TRUE;
  if NeedNL then
  begin
    if (paprIsTable in par.prop) and
      (par.ChildPar <> nil) and
      (par.CharCount = 0) and
      (par.ChildPar.ParagraphType = wpIsTable) then
    begin
      // Hidden par
    end else
    begin
      if (par.NextPar = nil) and (par.ChildPar = nil) and
        (((par.ParentPar <> nil) and
        (par.ParentPar.ParagraphType = wpIsStdPar) and
        (paprIsTable in par.ParentPar.prop)) or (par.RTFData.Kind = wpIsFootnote))
        then
      begin
           // suppress \par in last par of cell
        Result := TRUE;
      end
      else
      begin
        {$IFDEF SUPPRESS_PAR_AFTER_TEXT}
        if par.next<>nil then
        {$ENDIF}
        Result := WriteString('\par');
        if (FFieldOpen > 0) and (par.next = nil) then //V5.20.6
        begin
          dec(FFieldOpen);
          WriteString('}}}');
          FNeedSpace := FALSE;
        end;
      end;
    end;
{$IFNDEF RTFCOMPACT}
    WriteString(#13 + #10);
    FNeedSpace := FALSE;
{$ELSE}
    FNeedSpace := TRUE;
{$ENDIF}
{$IFDEF SAVEMODE}
    FNeedPlain := TRUE;
{$ENDIF}
    // NO: FNeedPard  := TRUE;
  end else Result := TRUE;
end;

//:: Write Table Start/End  (if result = false) this table will be ignored

function TWPRTFWriter.WriteTable(tablepar: TParagraph; Style: TWPTextStyle; start: Boolean): Boolean;
var tbl: Integer;
begin
  if start then
  begin
      // VV5.18.10 - save sections before tables
    if (paprNewSection in tablepar.prop) and
      (tablepar.SectionID <> FGlobalSectionID) and
      not OptNoPageInfo and
      not (soNoPageFormatInRTF in FStoreOptions) and
      not (soNoSectionFormatInRTF in FStoreOptions) then
    begin
      tbl := TableLevel;
      TableLevel := 0;
      WriteSectionProps(tablepar, (paprNewPage in tablepar.prop) and not OptNoPageBreaks);
      TableLevel := tbl;
    end
    else // Word only allows to have page breaks this way
      if (paprNewPage in tablepar.prop) and not OptNoPageBreaks then
      begin
        if (tablepar.ChildPar <> nil) and
          (paprNewSection in tablepar.ChildPar.prop) and
          (tablepar.ChildPar.SectionID <> FGlobalSectionID) and
          not OptNoPageInfo and
          not (soNoPageFormatInRTF in FStoreOptions) and
          not (soNoSectionFormatInRTF in FStoreOptions) then
        begin
          WriteString('\wppage');
        end else
          WriteString('\wpignpar\page\par');
      end;

    if (tablepar.Name <> '') then // now also used for table names!!!
    begin
      WriteString('{\*\wptable{');
      WriteTranslatedString(tablepar.Name);
      WriteString('}}');
    end;

    inc(FWritingTable);
    if not FOptIgnoreTableSETags and tablepar.HasChildren then
    begin
      WriteStringAndValue('\tblstart', FWritingTable); //V5.19.6 --- Here Table starts!
      FNeedSpace := TRUE;
    end;
    FCurrCharIndex := $FFFFFFFF;
    FCurrCharId := FALSE;
    FCurrParId := FALSE;
    FNeedPlain := TRUE;
    FNeedPard := TRUE;
  end else
  begin
    if not FOptIgnoreTableSETags and tablepar.HasChildren then
    begin
      WriteStringAndValue('\tblend', FWritingTable); //V5.19.7 --- Here Table ends!
      FNeedSpace := TRUE;
    end;
    dec(FWritingTable);
    FNeedPlain := TRUE;
    FNeedPard := TRUE;
  end;
  Result := TRUE;
end;

//:: Write Row Start/End  (if result = false) this row will be ignored.

function TWPRTFWriter.WriteRow(rowpar: TParagraph; Style: TWPTextStyle;
  start: Boolean; OnlySelectedCells: Boolean = FALSE): Boolean;

  procedure WriteRowProps;
  var par, refpar, cpar, aPar: TParagraph;
    x, {flags,} wid, nwid, BrdFlags, val, allval: Integer;
    procedure WriteRowAttr(const rtftag: AnsiString; ID: Integer; defval: Integer = 0);
    var attrval: Integer;
    begin
      if rowpar.AGet(ID, attrval) then WriteStringAndValue(rtftag, attrval)
      else if defval <> 0 then WriteStringAndValue(rtftag, defval);
    end;
  begin
    allval := rowpar.AGetDef(WPAT_PaddingAll, 0);
    // ROW Padding
    WriteRowAttr('\trpaddfl3\trpaddl', WPAT_PaddingLeft, allval);
    WriteRowAttr('\trpaddft3\trpaddt', WPAT_PaddingTop, allval);
    WriteRowAttr('\trpaddfr3\trpaddr', WPAT_PaddingRight, allval);
    WriteRowAttr('\trpaddfb3\trpaddb', WPAT_PaddingBottom, allval);
    // Spacing
    WriteRowAttr('\trspdfl3\trspdl', WPAT_CELLSPACEL);
    WriteRowAttr('\trspdft3\trspdt', WPAT_CELLSPACET);
    WriteRowAttr('\trspdfr3\trspdr', WPAT_CELLSPACER);
    WriteRowAttr('\trspdfb3\trspdb', WPAT_CELLSPACEB);
    // Border
    if not rowpar.AGet(WPAT_BorderFlags, BrdFlags) then BrdFlags := 0;
    if BrdFlags <> 0 then
    begin
      WriteBorder(rowpar, '\trbrdrl', BrdFlags, WPBRD_DRAW_Left,
        WPAT_BorderTypeL, WPAT_BorderWidthL, WPAT_BorderColorL, 0, false, true);
      WriteBorder(rowpar, '\trbrdrr', BrdFlags, WPBRD_DRAW_Right,
        WPAT_BorderTypeR, WPAT_BorderWidthR, WPAT_BorderColorR, 0, false, true);
      WriteBorder(rowpar, '\trbrdrt', BrdFlags, WPBRD_DRAW_Top,
        WPAT_BorderTypeT, WPAT_BorderWidthT, WPAT_BorderColorT, 0, false, true);
      WriteBorder(rowpar, '\trbrdrb', BrdFlags, WPBRD_DRAW_Bottom,
        WPAT_BorderTypeB, WPAT_BorderWidthB, WPAT_BorderColorB, 0, false, true);
      WriteBorder(rowpar, '\trbrdrv', BrdFlags, WPBRD_DRAW_InsideV,
        WPAT_BorderTypeV, WPAT_BorderWidthV, WPAT_BorderColorV, 0, false, true);
      WriteBorder(rowpar, '\trbrdrh', BrdFlags, WPBRD_DRAW_InsideH,
        WPAT_BorderTypeH, WPAT_BorderWidthH, WPAT_BorderColorH, 0, false, true);
    end;

    // Width of this ROW, first check ROW, then Parent Table!
    if FOptcellmaxwidth then
    begin
        // no  trwWidth
      WriteString('\trftsWidth2\trwWidth5000');
    end else
      if (rowpar.AGet(WPAT_BoxWidth, val) or
        rowpar.ParentPar.AGet(WPAT_BoxWidth, val)) and (val > 20) then
      begin
        WriteStringAndValue('\trftsWidth', 3);
        WriteStringAndValue('\trwWidth', val); // Twips
      end else
        if rowpar.ParentPar.AGet(WPAT_BoxWidth_PC, val) and (val > 20) then
        begin
          WriteStringAndValue('\trftsWidth', 2);
          WriteStringAndValue('\trwWidth', val div 2); // We work with /100, RTF /200
        end else
        begin
          val := rowpar.AGetDef(WPAT_BoxWidth_PC, 10000);
          WriteStringAndValue('\trftsWidth', 2);
          WriteStringAndValue('\trwWidth', val div 2); // We work with /100, RTF /50
        end;

    par := rowpar.ChildPar;

{$IFNDEF NEWCELLMERGE}
    if paprColMergeFirst in rowpar.prop then
    begin
      col := rowpar.ChildrenCount;
      refpar := rowpar.ParentTable.ChildPar;
      while (refpar <> nil) and not (paprColMergeFirst in refpar.prop) and
        (refpar.ChildrenCount <> col) do
        refpar := refpar.NextPar;
      if refpar <> nil then refpar := refpar.ChildPar;
    end else {$ENDIF}refpar := nil;

{$IFNDEF CELLX_EXCLUDES_TRLEFT}
    x := rowpar.ParentTable.AGetDef(WPAT_BoxMarginLeft, 0); // ok
{$ELSE}
    x := 0;
{$ENDIF}

    while par <> nil do
    begin
      if not OnlySelectedCells or (paprCellIsSelected in par.prop) then
      begin
        if refpar <> nil then aPar := refpar else aPar := par;

        wid := 0;
        if aPar.AGet(WPAT_COLWIDTH, wid) then
        begin
          if (paprColMerge in par.prop) or ((par.NextPar <> nil) and (paprColMerge in par.NextPar.prop)) then
          begin
             // V5.20.1 in merged cells keep width !
          end else
            if MulDiv(par.FIsWidth, 1440, FRTFProps.FFontXPixelsPerInch) > wid then
              wid := MulDiv(par.FIsWidth, 1440, FRTFProps.FFontXPixelsPerInch);
        end else
          if not (paprColMerge in par.prop) then //V5.15.6
          begin
            if aPar.AGet(WPAT_COLWIDTH_PC, wid) then
            begin
              if aPar.FIsWidth > 0 then
                wid := MulDiv(par.FIsWidth, 1440, FRTFProps.FFontXPixelsPerInch)
              else wid := 720;
            end else
              if aPar.FIsWidth > 0 then
                wid := MulDiv(par.FIsWidth, 1440, FRTFProps.FFontXPixelsPerInch)
              else wid := 720;
          end;

        nwid := -1;
        if FOptcellmaxwidth then //V5.20.7a
        begin
          cpar := aPar;
          while (cpar <> nil) and (cpar.NextPar = nil) do
          begin
            cpar := cpar.ParentCell;
          end;
          if cpar = nil then
          begin
            nwid := RTFDataCollection.Header.PageWidth -
              RTFDataCollection.Header.LeftMargin -
              RTFDataCollection.Header.RightMargin - x;
            if nwid > 0 then wid := nwid;
          end;
        end;

        inc(x, wid);
        if not par.AGet(WPAT_BorderFlags, BrdFlags) then BrdFlags := 0;
        if BrdFlags <> 0 then
        begin
          WriteBorder(par, '\clbrdrb', BrdFlags, WPBRD_DRAW_Bottom,
            WPAT_BorderTypeB, WPAT_BorderWidthB, WPAT_BorderColorB, 0, false, true);
          WriteBorder(par, '\clbrdrr', BrdFlags, WPBRD_DRAW_Right,
            WPAT_BorderTypeR, WPAT_BorderWidthR, WPAT_BorderColorR, 0, false, true);
          WriteBorder(par, '\clbrdrt', BrdFlags, WPBRD_DRAW_Top,
            WPAT_BorderTypeT, WPAT_BorderWidthT, WPAT_BorderColorT, 0, false, true);
          WriteBorder(par, '\clbrdrl', BrdFlags, WPBRD_DRAW_Left,
            WPAT_BorderTypeL, WPAT_BorderWidthL, WPAT_BorderColorL, 0, false, true);
        end;
        WriteShading(par, false, true, false);

        if (nwid > 0) then
        begin
          if aPar.AGet(WPAT_COLWIDTH_PC, val) and (val <> 0) then
          begin
            WriteStringAndValue('\clftsWidth', 2);
            WriteStringAndValue('\clwWidth', val div 2); // V5.12.2
          end else
          begin
            WriteStringAndValue('\clftsWidth', 3);
            WriteStringAndValue('\clwWidth', wid); // Twips
          end;
        end else
          if aPar.AGet(WPAT_COLWIDTH, val) then // and (val > 20) then
          begin
            WriteStringAndValue('\clftsWidth', 3);
            WriteStringAndValue('\clwWidth', wid); // Twips
          end else
            if aPar.AGet(WPAT_COLWIDTH_PC, val) and (val <> 0) then
            begin
              WriteStringAndValue('\clftsWidth', 2);
              WriteStringAndValue('\clwWidth', val div 2); // V5.12.2
            end else
              if aPar._IsWidthTw > 0 then
              begin
                WriteStringAndValue('\clftsWidth', 3);
                WriteStringAndValue('\clwWidth', aPar._IsWidthTw); // Twips
              end else
                WriteStringAndValue('\clftsWidth', 1); // AUTO!!!

      // The X Offset

        if paprRowMerge in par.prop then
          WriteString('\clvmrg')
        else if paprRowMergeFirst in par.prop then
          WriteString('\clvmgf');

        if paprColMerge in par.prop then
          WriteString('\clmrg')
        else if paprColMergeFirst in par.prop then
          WriteString('\clmgf');

        if (paprRowMerge in par.prop)
{$IFNDEF NEWCELLMERGE} or (paprColMerge in par.prop){$ENDIF}
        then
        begin
          refpar := par.StartSpan;
          if refpar = nil then refpar := par;
        end
        else refpar := par;

        // Padding
        val := refpar.AGetDefInherited(WPAT_PaddingAll, 0);
        WriteParAttr(refpar, false, false, '\clpadfl3\clpadl', WPAT_PaddingLeft, 0, false, val);
        WriteParAttr(refpar, false, false, '\clpadft3\clpadt', WPAT_PaddingTop, 0, false, val);
        WriteParAttr(refpar, false, false, '\clpadfr3\clpadr', WPAT_PaddingRight, 0, false, val);
        WriteParAttr(refpar, false, false, '\clpadfb3\clpadb', WPAT_PaddingBottom, 0, false, val);

        // Verticla Alignment
        val := refpar.AGetDefInherited(WPAT_VertAlignment, 0);
        case val of
          Integer(paralVertCenter): WriteString('\clvertalc');
          Integer(paprVertJustified): WriteString('\clvertalj');
          Integer(paralVertBottom): WriteString('\clvertalb');
        else WriteString('\clvertalt');
        end;
        FNeedSpace := TRUE;

        WriteStringAndValue('\cellx', x);
      end;
      par := par.NextPar;
      if refpar <> nil then refpar := refpar.NextPar;
    end;
  end;
var val, val1, val2: Integer;
begin
  if start then
  begin
    if FWritingTable > 1 then
    begin
      WriteString('{');
      FNeedSpace := FALSE;
    end
    else
    begin
      if rowpar.PrevPar = nil then
      begin
        if FLastNumberStyle <> nil then
        begin
          if FCloseNumberBracket then
          begin
            WriteString('}');
            FCloseNumberBracket := FALSE;
          end;
          FLastNumberStyle := nil;
        end;
        FNeedPard := TRUE;
      end;

      if (paprNewSection in rowpar.prop) and
        (rowpar.SectionID <> FGlobalSectionID) and
        not OptNoPageInfo and
        not (soNoPageFormatInRTF in FStoreOptions) and
        not (soNoSectionFormatInRTF in FStoreOptions) then
      begin
        WriteSectionProps(rowpar, not OptNoPageBreaks and ((paprNewPage in rowpar.prop) or rowpar.HasProp(paprNewPage)));
      end else
      // Word only allows to have page breaks this way
        if not OptNoPageBreaks and ((paprNewPage in rowpar.prop) or rowpar.HasProp(paprNewPage)) then
        begin
          // "\page\par" creates a new page and paragraph in word
          //NO!! WriteString('\page\par'); // V5.11.2
          WriteString('\wpignpar\page\par'); // V5.18.10, wprowpage next 'par' will be ignored!
        end;

      WriteString('{\trowd');

      WriteStringAndValue('\trleft',
        rowpar.ParentTable.AGetDef(WPAT_BoxMarginLeft, 0));

    { Height of a table row in twips. When 0, the height is sufficient
      for all the text in the line; when positive, the height is guaranteed
      to be at least the specified height; when negative, the absolute value
      of the height is used, regardless of the height of the text in the line. }

      if rowpar.AGet(WPAT_BoxMinHeight, val) then //V5.24.4 - exchanged
        WriteStringAndValue('\trrh', val)
      else
        if rowpar.AGet(WPAT_BoxMaxHeight, val) then
          WriteStringAndValue('\trrh', -val);

      if paprIsHeader in rowpar.prop then
        WriteString('\trhdr');
      if paprIsFooter in rowpar.prop then
        WriteString('\trfooter'); //#RTF!
      if paprIsCollapsed in rowpar.prop then
        WriteString('\trhidden'); //#RTF!

      if rowpar.AGet(WPAT_PaddingLeft, val1) and
        rowpar.AGet(WPAT_PaddingRight, val2) and
        (val1 = val2) then
      begin
        WriteStringAndValue('\trgaph', val1);
      end;

      FNeedSpace := TRUE;
      WriteRowProps;
    end;
  end else
  begin
    if FWritingTable = 1 then
    begin
      WriteString('\row}');
      FNeedSpace := FALSE;
    end
    else
    begin
      if not (soNoNoNestTableText in FStoreOptions) then
      begin
       // WriteString('{\nonesttables\par}');
      end;
      WriteString('{\*\nesttableprops\trowd');

      WriteStringAndValue('\trleft',
        rowpar.ParentTable.AGetDef(WPAT_BoxMarginLeft, 0));
      if rowpar.AGet(WPAT_BoxMaxHeight, val) then
        WriteStringAndValue('\trrh', -val)
      else if rowpar.AGet(WPAT_BoxMinHeight, val) then
        WriteStringAndValue('\trrh', val);

      if paprIsHeader in rowpar.prop then
        WriteString('\trhdr');
      if paprIsFooter in rowpar.prop then
        WriteString('\trfooter'); //#RTF!
      if paprIsCollapsed in rowpar.prop then
        WriteString('\trhidden'); //#RTF!

      FNeedSpace := TRUE;
      WriteRowProps;
      WriteString('\nestrow}');
      WriteString('}');
      FNeedSpace := FALSE;
    end;
  {  if not FOptIgnoreTableSETags and (rowpar.NextPar=nil) then
    begin
       WriteStringAndValue('\tblend', FWritingTable);
       FNeedSpace := TRUE;
    end; }
  end;
  Result := TRUE;
end;

//:: Write Cell Start/End  (if result = false) this cell will be ignored.

function TWPRTFWriter.WriteCell(cellpar: TParagraph; Style: TWPTextStyle; start: Boolean): Boolean;
var sty: TWPRTFStyleElement;
  CurrCharAttr, OldCharAttr: TWPCharAttr;
begin
  if start then
  begin
    WritePard;
{$IFDEF DEBUGSAVE}WriteString(#13 + #10); {$ENDIF}
    sty := FRTFProps.ParStyles.GetStyle(cellpar.style);
    if sty <> nil then
    begin
      if not (soNoStyleTable in FStoreOptions) and (sty._RTF_ID > 0) then
      begin
        WriteStringAndValue('\plain\s', sty._RTF_ID);
        FLastParHadStyle := true;
        FIgnoreNextPlain := TRUE;
      end;
      // Write The Style Attributes
      // WriteAStyle(sty, -1);  V5.12.5 Write Inhgerited below!!!

      FIgnoreNextPlain := TRUE;
    end;

    // AUTO WIDTH
    {
    if not cellpar.AGet(WPAT_COLWIDTH,d) and not cellpar.AGet(WPAT_COLWIDTH_PC,d) then
      WriteString('\faauto');
    }

    WriteParProps(cellpar, false, true, true);

    FNeedSpace := TRUE;
    if sty <> nil then FNeedPlain := FALSE
    else FNeedPlain := TRUE;
    FCurrCharIndex := $FFFFFFFF;
    FCurrCharId := FALSE;
    WriteShading(cellpar, false, true, false);

    FNeedPlain := TRUE;

    if (cellpar.CharCount = 0) and (cellpar.ChildPar = nil) and
      (cellpar.LoadedCharAttr > 0) then
    begin
      FRTFProps.Attributes.GetCharAttr(cellpar.LoadedCharAttr, CurrCharAttr);
      WriteACharAttr(cellpar, CurrCharAttr, OldCharAttr, cellpar.LoadedCharAttr and cafsNONE, true);
      last_charattr_index := cellpar.LoadedCharAttr;
    end else last_charattr_index := Cardinal(-1);

    // WriteString('{');
  end else
  begin
    if FWritingTable = 1 then
    begin
      WriteString('\cell');
      FNeedSpace := TRUE;
    end
    else
    begin
      if not (soNoNoNestTableText in FStoreOptions) then
      begin
      //  WriteString('{\nonesttables\tab}');
      end;
      WriteString('\nestcell');
      FNeedSpace := TRUE;
    end;
    // WriteString('}');
{$IFDEF DEBUGSAVE}WriteString(#13 + #10); {$ENDIF}
    // We need to start with plain and pard since the followiung comes after a closing "}"
    FNeedPlain := TRUE;
    FNeedPard := TRUE;
    FLastNumberStyle := nil;
  end;
  Result := TRUE;
end;

function TWPRTFWriter.UpdateCharAttr(CharAttrIndex: Cardinal): Boolean;
var sty: TWPTextStyle; a: Integer;
begin
  if not (soNoCharacterAttributes in FStoreOptions) then
  begin
    sty := WritingParStyle; 
    FRTFProps.Attributes.GetCharAttr(CharAttrIndex, FCurrCharAttr[FCurrCharId]);

    // If font has changed to undefined than we need default font!    //V5.18.5
    if ((FCurrCharAttr[FCurrCharId].MaskHash and BitMask[WPAT_CharFont]) = 0) and
      ((FCurrCharAttr[not FCurrCharId].Values[WPAT_CharFont]) <> 0)
      then
    begin
      if (sty = nil) or not sty.AGet(WPAT_CharFont, a) then a := 0; //V5.18.6
      FCurrCharAttr[FCurrCharId].Values[WPAT_CharFont] := a;
      FCurrCharAttr[FCurrCharId].MaskHash := FCurrCharAttr[FCurrCharId].MaskHash or BitMask[WPAT_CharFont];
    end;

    // If font-size has changed to undefined than we need default font!  //V5.18.5
    if (not ParStart //V5.19.3a
      or (WritingPar = nil) or not WritingPar.AGet(WPAT_CharFontSize, a)) and //V5.19.3a
      ((FCurrCharAttr[FCurrCharId].MaskHash and BitMask[WPAT_CharFontSize]) = 0) and
      ((FCurrCharAttr[not FCurrCharId].Values[WPAT_CharFontSize]) <> FDefaultFontSize)
      then
    begin
      if (sty = nil) or not sty.AGet(WPAT_CharFontSize, a) then a := FDefaultFontSize; //V5.18.6
      FCurrCharAttr[FCurrCharId].Values[WPAT_CharFontSize] := a;
      FCurrCharAttr[FCurrCharId].MaskHash := FCurrCharAttr[FCurrCharId].MaskHash or BitMask[WPAT_CharFontSize];
    end;

    if ParStart then
    begin
      if (WritingPar <> nil) then
      begin
        if sty <> nil then
        begin
{$IFNDEF DONT_WRITE_PARSTYLE_ATTR}
          FCurrCharAttr[not FCurrCharId].Values[WPAT_CharStyleOn] :=
            sty.AGetDef(WPAT_CharStyleOn, 0);
          FCurrCharAttr[not FCurrCharId].Values[WPAT_CharStyleMask] :=
            sty.AGetDef(WPAT_CharStyleMask, 0);
          FCurrCharAttr[not FCurrCharId].Values[WPAT_UnderlineMode] :=
            sty.AGetDef(WPAT_UnderlineMode, 0);
{$ENDIF}
        end;
      end;
      ParStart := FALSE;
    end
{$IFDEF PARSTYLE_SAVEMODE}
    else
    begin
      sty := WritingParStyle; 
    end;
{$ENDIF};

    WriteACharAttr(WritingPar,
      FCurrCharAttr[FCurrCharId], FCurrCharAttr[not FCurrCharId],
      CharAttrIndex and cafsNONE, false, sty <> nil);

    FCurrCharAttr[not FCurrCharId] := FCurrCharAttr[FCurrCharId];

    FCurrCharId := not FCurrCharId;
    FCurrCharIndex := CharAttrIndex;
  end;
  Result := TRUE;
end;

{$IFDEF SAVEFONTCHARSETS}

function TWPRTFWriter.FontMap(fontname: string; charset: Integer): Integer;
var j: Integer;
begin
  Result := 0;
  for j := 0 to FontList.Count - 1 do
    if (FontList.Objects[j] = Pointer(charset)) and
      (CompareText(fontname, FontList[j]) = 0) then
    begin
      Result := j;
      break;
    end;
end;
{$ENDIF}

procedure TWPRTFWriter.SetOptions(optstr: string);
var i: Integer;
  aoptstr: string;
begin
  i := Pos('-', optstr);
  if i > 0 then
  begin
    aoptstr := lowercase(Copy(optstr, i, Length(optstr) - i + 1)) + ',';
    FOptNoNumberProps := Pos('-nonumberprops,', aoptstr) > 0;
    FOptcellmaxwidth := Pos('-cellmaxwidth,', aoptstr) > 0;
    FOptOnlyStandardHeadFoot := Pos('-onlystandardheadfoot,', aoptstr) > 0;
    FOptNoSpanStyles := Pos('-nospanstyles,', aoptstr) > 0;
    FOptNoCharStyles := Pos('-nocharstyles,', aoptstr) > 0;
    FOptIgnoreTableSETags := (Pos('-ignoretablesetags,', aoptstr) > 0);
    FOptASCIIMode := (Pos('-asciimode,', aoptstr) > 0);
  end;
  inherited SetOptions(optstr);
{$IFDEF IGNORE_TBLTAGS}
  OptIgnoreTableSETags := TRUE;
{$ENDIF}
{$IFDEF ASCIIRTF}
  FOptASCIIMode := true;
{$ENDIF}
end;

// Write the character attribute set. If WriteCharAttrIndex=-1
// we are writing the attributes of a style (SourceStyle).
// In this case ignore 'CurrCharAttr'.  Otherwise this is a paragraph with text

procedure TWPRTFWriter.WriteACharAttr(SourceStyle: TWPTextStyle;
  var CurrCharAttr, OldCharAttr: TWPCharAttr; WriteCharAttrIndex: Integer;
  DontCompare: Boolean; ThisParHasStyle: Boolean = FALSE; NoDefaultATTR: Boolean = FALSE);
var bits, oldbits: Integer; FUnderlineSimple, FUnderlineOff: Boolean;
  function WriteCharProperty(const RTFTag: AnsiString;
    PropId, DefValue: Integer; IsColor: Boolean;
    DontCheckNull: Boolean = FALSE): Boolean;
  var hasprop: Boolean;
  begin
    Result := FALSE;
    if (WriteCharAttrIndex >= 0) and
      ((CurrCharAttr.MaskHash and BitMask[PropId]) <> 0) then
    begin
      if DontCompare or (CurrCharAttr.Values[PropId] <> OldCharAttr.Values[PropId])
        or ((OldCharAttr.MaskHash and BitMask[PropId]) = 0) //V5.18.1
        then
      begin
        if IsColor then WriteStringAndValue(RTFTag, FColorMap[CurrCharAttr.Values[PropId]])
        else WriteStringAndValue(RTFTag, CurrCharAttr.Values[PropId]);
        Result := TRUE;
      end;
    end
    else
    begin
{$IFDEF DONT_WRITE_PARSTYLE_ATTR}if (WriteCharAttrIndex < 0) and {$ELSE}if {$ENDIF}
      (SourceStyle <> nil) then
        hasprop := SourceStyle.AGetInherited(PropId, DefValue)
      else hasprop := FALSE;
      if (hasprop and ((SourceStyle <> nil) or (WriteCharAttrIndex < 0))) or
        ((OldCharAttr.MaskHash and BitMask[PropId]) <> 0) and
        (OldCharAttr.Values[PropId] <> 0) and
        (OldCharAttr.Values[PropId] <> DefValue) then
      begin
        if IsColor then WriteStringAndValue(RTFTag, FColorMap[DefValue])
        else WriteStringAndValue(RTFTag, DefValue);
        OldCharAttr.Values[PropId] := DefValue;
        Result := TRUE;
      end;
    end;
  end;
var FontSize, j, c, submask, font_nr: Integer; fl: Single;
  sty: TWPRTFStyleElement;
  s: string;

begin
  if FNeedPlain then
  begin
    if not FIgnoreNextPlain then
      WriteString('\plain');

    FillChar(OldCharAttr, SizeOf(OldCharAttr), 0);
    // if (_rtfdataobj=nil) or (_rtfdataobj.Kind=wpIsBody) then
    // The following line disturbs saving of text boxes
    // FillChar(CurrCharAttr,SizeOf(CurrCharAttr),0); //V5.19.2  commented out: //V5.19.3a

    DontCompare := not ThisParHasStyle; // V5.17.3 TRUE;
    FNeedPlain := FALSE;
    FNeedSpace := TRUE;
  end;
  FIgnoreNextPlain := FALSE;

{$IFDEF SAVE_CHARSTYLES}
  // Character Stylesheet ------------------------------------------------------
  if ((CurrCharAttr.MaskHash and BitMask[WPAT_CharStyleSheet]) <> 0) and
    (CurrCharAttr.Values[WPAT_CharStyleSheet] <> 0) then
  begin
     // Uses paragraph styles by default. 'CharStyles' are not supported
{$IFDEF USE_CHARSTYLES}
    sty := RTFProps.CharStyles.GetStyle(CurrCharAttr.Values[WPAT_CharStyleSheet]);
{$ELSE}
    sty := RTFProps.ParStyles.GetStyle(CurrCharAttr.Values[WPAT_CharStyleSheet]);
{$ENDIF}
    if sty <> nil then
    begin
      if not OptNoCharStyles then // Optionally do not *save* CS tag
        WriteStringAndValue('\cs', sty._RTF_ID);
      sty.TextStyle.AGetCharProps(FCurrCharAttr[FCurrCharId], true, true);
      FNeedPlain := TRUE;
      WriteCharAttrIndex := -1;
    end;
  end;
{$ENDIF}

{$IFDEF SAVEFONTCHARSETS}
  font_nr := -1;
  //------>> WPAT_CharCharset --- (Use font mapping for font/charset combination), alternatively \cchs
  if (CurrCharAttr.MaskHash and (BitMask[WPAT_CharFont]) <> 0) and
    (((CurrCharAttr.Values[WPAT_CharFont] <> OldCharAttr.Values[WPAT_CharFont]) or
    (SourceStyle <> nil) //V5.15.5
    )
    or ((CurrCharAttr.MaskHash and (BitMask[WPAT_CharCharset]) <> 0) and
    (CurrCharAttr.Values[WPAT_CharCharset] <> OldCharAttr.Values[WPAT_CharCharset])))
    then
  begin
    if WriteCharAttrIndex >= 0 then
    begin
      font_nr := FontCharAttrMap[WriteCharAttrIndex];
      if (font_nr < 0) and (CurrCharAttr.Values[WPAT_CharFont] = 0) then
        font_nr := 0; //V5.18.5
    end
    else
    begin
      if (CurrCharAttr.MaskHash and BitMask[WPAT_CharCharset]) <> 0 then
        c := CurrCharAttr.Values[WPAT_CharCharset]
      else c := 1; // DEFAULT_CHARSET;
      s := FRTFProps.Fontname[CurrCharAttr.Values[WPAT_CharFont]];
      for j := 0 to FontList.Count - 1 do
        if (FontList.Objects[j] = Pointer(c)) and
          (CompareText(s, FontList[j]) = 0) then
        begin
          font_nr := j;
          break;
        end;
    end;
  end;

{$IFDEF DONT_WRITE_PARSTYLE_ATTR}if (WriteCharAttrIndex < 0) and {$ELSE}if {$ENDIF}
  (SourceStyle <> nil) and ((font_nr < 0) or (WriteCharAttrIndex <= 0)) and
    SourceStyle.AGetInherited(WPAT_CharFont, j) then
  begin
    if not SourceStyle.AGetInherited(WPAT_CharCharset, c) or (c < 0) then
      c := 1; // DEFAULT_CHARSET;

    CurrCharAttr.Values[WPAT_CharFont] := j;
    CurrCharAttr.Values[WPAT_CharCharset] := c;

    s := FRTFProps.Fontname[j];
    for j := 0 to FontList.Count - 1 do
      if (FontList.Objects[j] = Pointer(c)) and
        (CompareText(s, FontList[j]) = 0) then
      begin
        font_nr := j;
        break;
      end;
  end;
  if font_nr >= 0 then
    WriteStringAndValue('\f', font_nr);
{$ELSE}
  font_nr := -1;
    // locate entry in font string list!
  if WriteCharAttrIndex >= 0 then
    font_nr := CurrCharAttr.Values[WPAT_CharFont];

  if (SourceStyle <> nil)
    and not NoDefaultATTR and
    ((font_nr <= 0) or (WriteCharAttrIndex <= 0)) and
    SourceStyle.AGetInherited(WPAT_CharFont, j) then
  begin
    CurrCharAttr.Values[WPAT_CharFont] := j;
    font_nr := j;
  end;
  if font_nr >= 0 then
    WriteStringAndValue('\f', font_nr);
{$ENDIF}
  FontSize := -1;

  if (CurrCharAttr.MaskHash and (BitMask[WPAT_CharFontSize]) = BitMask[WPAT_CharFontSize]) then
    FontSize := CurrCharAttr.Values[WPAT_CharFontSize]
  else if not NoDefaultATTR then
  begin
    if (SourceStyle = nil) or
      not SourceStyle.AGetInherited(WPAT_CharFontSize, FontSize)
      then
    begin
      if RTFDataCollection.ANSITextAttr.GetFontSize(fl) then
        FontSize := Round(fl * 100)
      else FontSize := DefaultFontSize * 100; // 11pt = RTF Default
    end;
    CurrCharAttr.Values[WPAT_CharFontSize] := FontSize;
  end;

  if (FontSize > 0) and (FontSize <> OldCharAttr.Values[WPAT_CharFontSize]) then
  begin
    WriteStringAndValue('\fs', FontSize div 50);
  end;

  WriteCharProperty('\cf', WPAT_CharColor, 0, true, SourceStyle <> nil); //DontCheckNull=true

{$IFDEF WRITEHIGHLIGHT} // word does not use CB !
  if WriteCharProperty('\highlight', WPAT_CharBGColor, 0, true, SourceStyle <> nil) then
    FNeedPlain := TRUE; // highlight cannot be switched off (Alessandro Fragnani)
{$ELSE}
  WriteCharProperty('\cb', WPAT_CharBGColor, 0, true, SourceStyle <> nil);
{$ENDIF}
  WriteCharProperty('\charscalex', WPAT_CharWidth, 100, false);

  if (CurrCharAttr.MaskHash and (BitMask[WPAT_CharLevel]) = BitMask[WPAT_CharLevel]) and
    (CurrCharAttr.Values[WPAT_CharLevel] <> OldCharAttr.Values[WPAT_CharLevel])
    then
  begin
    if CurrCharAttr.Values[WPAT_CharLevel] > $8000 then
      WriteStringAndValue('\dn', CurrCharAttr.Values[WPAT_CharLevel] - $8000)
    else WriteStringAndValue('\up', CurrCharAttr.Values[WPAT_CharLevel]);
  end else
    if (OldCharAttr.MaskHash and (BitMask[WPAT_CharLevel]) = BitMask[WPAT_CharLevel]) and
      (OldCharAttr.Values[WPAT_CharLevel] <> 0) then
    begin
      if OldCharAttr.Values[WPAT_CharLevel] > $8000 then
        WriteString('\dn0')
      else WriteString('\up0');
    end;

  if (CurrCharAttr.MaskHash and (BitMask[WPAT_CharSpacing]) = BitMask[WPAT_CharSpacing]) and
    (CurrCharAttr.Values[WPAT_CharSpacing] <> OldCharAttr.Values[WPAT_CharSpacing])
    then
  begin
    if CurrCharAttr.Values[WPAT_CharSpacing] >= $8000 then
    begin
      WriteStringAndValue('\expnd', -(CurrCharAttr.Values[WPAT_CharSpacing] - $8000) div 55);
      WriteStringAndValue('\expndtw', -(CurrCharAttr.Values[WPAT_CharSpacing] - $8000));
    end
    else
    begin
      WriteStringAndValue('\expnd', CurrCharAttr.Values[WPAT_CharSpacing] div 5);
      WriteStringAndValue('\expndtw', CurrCharAttr.Values[WPAT_CharSpacing]);
    end;
  end else
    if (OldCharAttr.MaskHash and (BitMask[WPAT_CharLevel]) <> 0) and
      (OldCharAttr.Values[WPAT_CharSpacing] <> 0) then
    begin
      WriteString('\expnd0\expndtw0');
    end;

  if (CurrCharAttr.MaskHash and (BitMask[WPAT_CharEffect]) <> 0) and
    (CurrCharAttr.Values[WPAT_CharEffect] <> OldCharAttr.Values[WPAT_CharEffect])
    then
  begin
    j := CurrCharAttr.Values[WPAT_CharEffect] and WPEFF_CUSTOMMASK;
    if j <> 0 then
      WriteStringAndValue('\wpcustcs', j);
    j := CurrCharAttr.Values[WPAT_CharEffect];

    if (j and WPEFF_SHADOW) <> 0 then WriteString('\shad1');
    if (j and WPEFF_INSET) <> 0 then WriteString('\embo1');
    if (j and WPEFF_OUTSET) <> 0 then WriteString('\impr1');
    if (j and WPEFF_OUTLINE) <> 0 then WriteString('\outl');
    j := (j and WPEFF_ANIMMask) div WPEFF_ANIMbit1;
    if j <> 0 then WriteStringAndValue('\animtext', j);

    FNeedSpace := TRUE;
    FNeedPlain := TRUE;
  end;

  if (CurrCharAttr.MaskHash and BitMask[WPAT_CharStyleON]) = 0 then //V5.17.2
    bits := 0
  else bits := CurrCharAttr.Values[WPAT_CharStyleON];

  // Add the styles from the paragraph
  oldbits := OldCharAttr.Values[WPAT_CharStyleON];
  submask := 0;

  if (SourceStyle <> nil) and
    SourceStyle.AGetInherited(WPAT_CharStyleON, j) then
  begin
    bits := bits or (j and not CurrCharAttr.Values[WPAT_CharStyleMask]);
    if ThisParHasStyle and (j <> 0) and
      ((CurrCharAttr.MaskHash and BitMask[WPAT_CharStyleMASK]) <> 0) then
    begin
      submask := CurrCharAttr.Values[WPAT_CharStyleMASK]
        and not CurrCharAttr.Values[WPAT_CharStyleON];
    end;
  end;

  FUnderlineOff := FALSE;
  FUnderlineSimple := FALSE;
  if (bits <> oldbits) or (submask <> 0) then
  begin
    if ((submask and WPSTY_BOLD) <> 0) then
    begin WriteString('\b0'); FNeedSpace := TRUE; end else
      if ((bits and WPSTY_BOLD) = WPSTY_BOLD) <>
        ((oldbits and WPSTY_BOLD) = WPSTY_BOLD)
        then
      begin
        if (bits and WPSTY_BOLD) = WPSTY_BOLD then
          WriteString('\b')
        else WriteString('\b0');
        FNeedSpace := TRUE;
      end;

    if ((submask and WPSTY_ITALIC) <> 0) then
    begin WriteString('\i0'); FNeedSpace := TRUE; end else
      if ((bits and WPSTY_ITALIC) = WPSTY_ITALIC) <>
        ((oldbits and WPSTY_ITALIC) = WPSTY_ITALIC)
        then
      begin
        if (bits and WPSTY_ITALIC) = WPSTY_ITALIC then
          WriteString('\i')
        else WriteString('\i0');
        FNeedSpace := TRUE;
      end;

    if ((submask and WPSTY_STRIKEOUT) <> 0) then
    begin WriteString('\strike0'); FNeedSpace := TRUE; end else
      if ((bits and WPSTY_STRIKEOUT) = WPSTY_STRIKEOUT) <>
        ((oldbits and WPSTY_STRIKEOUT) = WPSTY_STRIKEOUT)
        then WriteStringAndValue('\strike', Ord((bits and WPSTY_STRIKEOUT) = WPSTY_STRIKEOUT));

    if ((submask and WPSTY_DBLSTRIKEOUT) <> 0) then
    begin WriteString('\striked0'); FNeedSpace := TRUE; end else
      if ((bits and WPSTY_DBLSTRIKEOUT) = WPSTY_DBLSTRIKEOUT) <>
        ((oldbits and WPSTY_DBLSTRIKEOUT) = WPSTY_DBLSTRIKEOUT)
        then WriteStringAndValue('\striked', Ord((bits and WPSTY_DBLSTRIKEOUT) = WPSTY_DBLSTRIKEOUT));

    if ((submask and WPSTY_DBLSTRIKEOUT) <> 0) then
    begin WriteString('\ulnone0'); FNeedSpace := TRUE; end else
      if ((bits and WPSTY_UNDERLINE) = WPSTY_UNDERLINE) <>
        ((oldbits and WPSTY_UNDERLINE) = WPSTY_UNDERLINE)
        then
      begin
        if (bits and WPSTY_UNDERLINE) <> 0 then
        begin
          WriteString('\ul');
          FNeedSpace := TRUE;
          FUnderlineSimple := TRUE;
        end
        else FUnderlineOff := TRUE;
      end;

    if ((bits and WPSTY_DBLSTRIKEOUT) = WPSTY_DBLSTRIKEOUT) <>
      ((oldbits and WPSTY_DBLSTRIKEOUT) = WPSTY_DBLSTRIKEOUT)
      then WriteStringAndValue('\striked', Ord((bits and WPSTY_DBLSTRIKEOUT) = WPSTY_DBLSTRIKEOUT))
    else if ((bits and WPSTY_UNDERLINE) = WPSTY_STRIKEOUT) <>
      ((oldbits and WPSTY_UNDERLINE) = WPSTY_STRIKEOUT)
      then WriteStringAndValue('\strike', Ord((bits and WPSTY_STRIKEOUT) = WPSTY_STRIKEOUT));

    if (bits and (WPSTY_SUPERSCRIPT + WPSTY_SUBSCRIPT)) <>
      (oldbits and (WPSTY_SUPERSCRIPT + WPSTY_SUBSCRIPT)) then
    begin
      if (bits and WPSTY_SUPERSCRIPT) <> 0 then WriteString('\super1')
      else if (bits and WPSTY_SUBSCRIPT) <> 0 then WriteString('\sub1')
      else WriteString('\nosupersub1');
      FNeedSpace := TRUE;
    end;

    if ((submask and WPSTY_HIDDEN) <> 0) then
    begin WriteString('\v0'); FNeedSpace := TRUE; end else
      if ((bits and WPSTY_HIDDEN) <> 0) <> ((oldbits and WPSTY_HIDDEN) <> 0)
        then WriteStringAndValue('\v', Ord((bits and WPSTY_HIDDEN) <> 0));

    if ((bits and WPSTY_UPPERCASE) <> 0) <> ((oldbits and WPSTY_UPPERCASE) <> 0)
      then WriteStringAndValue('\caps', Ord((bits and WPSTY_UPPERCASE) <> 0));
    if ((bits and WPSTY_SMALLCAPS) <> 0) <> ((oldbits and WPSTY_SMALLCAPS) <> 0)
      then WriteStringAndValue('\scaps', Ord((bits and WPSTY_SMALLCAPS) <> 0));

    if ((bits and WPSTY_LOWERCASE) <> 0) <> ((oldbits and WPSTY_LOWERCASE) <> 0)
      then WriteStringAndValue('\lower', Ord((bits and WPSTY_LOWERCASE) <> 0)); 
    if ((bits and WPSTY_BUTTON) <> 0) <> ((oldbits and WPSTY_BUTTON) <> 0)
      then WriteStringAndValue('\wpbut', Ord((bits and WPSTY_BUTTON) <> 0)); 
    if not OptNoafsProtected then
    begin
{$IFDEF USE_WPTOOLS3_PROTECT} // Use the \shad TAG
      if ((bits and WPSTY_PROTECTED) <> 0) <> ((oldbits and WPSTY_PROTECTED) <> 0)
        then WriteStringAndValue('\shad', Ord((bits and WPSTY_PROTECTED) <> 0)); // Shaded or protected Text
{$ELSE}
      if ((bits and WPSTY_PROTECTED) <> 0) <> ((oldbits and WPSTY_PROTECTED) <> 0)
        then WriteStringAndValue('\wpprot', Ord((bits and WPSTY_PROTECTED) <> 0)); // Shaded or protected Text
{$ENDIF}
    end;
    if ((bits and WPSTY_USERDEFINED) <> 0) <> ((oldbits and WPSTY_USERDEFINED) <> 0)
      then WriteStringAndValue('\wpuser', Ord((bits and WPSTY_USERDEFINED) <> 0)); 

  end;
  WriteCharProperty('\wphigh', WPAT_CharHighlight, 0, false); 

  // We can refine the underline mode - but we may nbot switch it off!
  if (CurrCharAttr.MaskHash and (BitMask[WPAT_UnderlineMode]) <> 0) and
    (CurrCharAttr.Values[WPAT_UnderlineMode] <> OldCharAttr.Values[WPAT_UnderlineMode])
    then
  begin
    FUnderlineOff := FALSE;
    case CurrCharAttr.Values[WPAT_UnderlineMode] of
      WPUND_Standard: if not FUnderlineSimple then WriteString('\ul');
      WPUND_Dotted: WriteString('\uld');
      WPUND_Dashed: WriteString('\uldash');
      WPUND_Dashdotted: WriteString('\uldashd');
      WPUND_Dashdotdotted: WriteString('\uldashdd');
      WPUND_Double: WriteString('\uldb');
      WPUND_Heavywave: WriteString('\ulhwave');
      WPUND_Longdashed: WriteString('\ulldash');
      WPUND_Thick: WriteString('\ulth');
      WPUND_Thickdotted: WriteString('\ulthd');
      WPUND_Thickdashed: WriteString('\ulthdash');
      WPUND_Thickdashdotted: WriteString('\ulthdashd');
      WPUND_Thickdashdotdotted: WriteString('\ulthdashdd');
      WPUND_Thicklongdashed: WriteString('\ulthldash');
      WPUND_Doublewave: WriteString('\ululdbwave');
      WPUND_WordUnderline: WriteString('\ulw');
      WPUND_wave: WriteString('\ulwave');
      WPUND_curlyunderline: WriteString('\ulcurly');
      WPUND_NoLine: if not FUnderlineSimple then WriteString('\ulnone');
    else
      if not FUnderlineSimple then FUnderlineOff := TRUE;
    end;
    FNeedSpace := TRUE;
  end
  else if not FUnderlineSimple and
    (OldCharAttr.MaskHash and (BitMask[WPAT_UnderlineMode]) <> 0) and
    (OldCharAttr.Values[WPAT_UnderlineMode] <> 0)
    then FUnderlineOff := TRUE;

  if FUnderlineOff then
  begin
    WriteString('\ulnone');
    FNeedSpace := TRUE;
  end
  else
  begin
    WriteCharProperty('\ulc', WPAT_UnderlineColor, 0, true);
    // FNeedSpace := TRUE;
  end;

  if (CurrCharAttr.MaskHash and (BitMask[WPAT_TextLanguage]) <> 0) and
    (CurrCharAttr.Values[WPAT_TextLanguage] <> OldCharAttr.Values[WPAT_TextLanguage])
    then
  begin
    WriteStringAndValue('\lang', CurrCharAttr.Values[WPAT_TextLanguage]);
    FNeedSpace := TRUE;
  end;
end;

{ Tbis is called BEFORE the character with the hyphen marker }

function TWPRTFWriter.WriteHyphen: Boolean;
begin
  Result := WriteString('\-');
end;

// Use this procedure to *initialize* (but not write!)  font and color tables

procedure TWPRTFWriter.InitializeWriting;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure CheckNumberStyle(par: TWPTextStyle);
  var NumberStyle: TWPRTFNumberingStyle;
    l, j, numlevel: Integer;
    found, SkipNumbering: Boolean;
  begin
    NumberStyle := RTFProps.NumberStyles.FindParNumberStyle(par, numlevel, SkipNumbering);
    if (NumberStyle <> nil) and not NumberStyle.Used then
    begin
      if NumberStyle.Group > 0 then
      begin
        found := FALSE;
        l := Length(FUsedNumberGroups);
        for j := 0 to l - 1 do
          if FUsedNumberGroups[j] = NumberStyle.Group then
          begin
            found := TRUE;
            break;
          end;
        if not found then
        begin
          SetLength(FUsedNumberGroups, l + 1);
          FUsedNumberGroups[l] := NumberStyle.Group;
          NumberStyle.Used := TRUE;
        end;
      end else
      begin
        inc(FUsedNumberStyles);
        NumberStyle.Used := TRUE;
      end;
    end;
  end;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure CheckRTFData(data: TWPRTFDataBlock);
  var par: TParagraph;
    sty: TWPRTFStyleElement;
    last: Integer;
  begin
    if (data <> nil) and not data.Empty then
    begin
      par := data.FirstPar;
      last := -1;
      while par <> nil do
      begin
        CheckNumberStyle(par);
        if not (soNoStyleTable in FStoreOptions) and (par.Style <> last) then
        begin
          last := par.Style;
          sty := FRTFProps.ParStyles.GetStyle(last);
          if sty <> nil then
            sty._RTF_ID := 1; // Mark it to be used
        end;
        par := par.next;
      end;
    end;
  end;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure Mark(style: TWPRTFStyleElement);
  begin
    if (style <> nil) and (style._RTF_ID <= 1) then // NO Recursion!
    begin
      CheckNumberStyle(style.TextStyle);
      style._RTF_ID := 2;
       // Mark the base styles, too!
      if style.TextStyle.Style <> 0 then
        Mark(FRTFProps.ParStyles.GetStyle(style.TextStyle.Style));
       // Mark Next Styles, too!
      if style.NextStyleName <> '' then
        Mark(FRTFProps.ParStyles.GetStyle(style.NextStyleName));
    end;
  end;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
var stynr, i: Integer;
begin
  FUsedNumberStyles := 0;
  FUsedNumberGroups := nil;
  FInitializeWritingText := '';
  // Only save the section 0 at start!
  FGlobalSectionID := 0;

  if (FRTFData <> nil) and not FRTFData.Empty and
    (FRTFData.Firstpar <> nil) and
    (paprNewSection in FRTFData.Firstpar.prop) then
    FGlobalSectionID := FRTFData.Firstpar.SectionID;

  // Init the style lists
  for i := 0 to FRTFProps.NumberStyles.Count - 1 do
    FRTFProps.NumberStyles[i].Used := FALSE;

  // All styles, not only used
  if soAllStylesInCollection in FStoreOptions then
    for i := 0 to FRTFProps.ParStyles.Count - 1 do
    begin
      if FRTFProps.ParStyles[i].Name <> '' then
        FRTFProps.ParStyles[i]._RTF_ID := 1
      else FRTFProps.ParStyles[i]._RTF_ID := 0;
    end

  // onyl used styles
  else for i := 0 to FRTFProps.ParStyles.Count - 1 do
      FRTFProps.ParStyles[i]._RTF_ID := 0;

  CheckRTFData(FRTFData);
  // Make sure we save the numberstyles which are used by paragraph styles!
  // sty._RTF_ID = 0 --> unused
  // sty._RTF_ID = 1 --> used
  // sty._RTF_ID = 2 --> used in par or as base style
  if not (soNoStyleTable in FStoreOptions) and not OptNoStyles then
  begin
    for i := 0 to FRTFProps.ParStyles.Count - 1 do
      if FRTFProps.ParStyles[i]._RTF_ID = 1 then
        Mark(FRTFProps.ParStyles[i]);
    // INIT ALL NUMBERS!
    stynr := 0;
    for i := 0 to FRTFProps.ParStyles.Count - 1 do
      if FRTFProps.ParStyles[i]._RTF_ID > 0 then
      begin
        inc(stynr);
        FRTFProps.ParStyles[i]._RTF_ID := stynr;
      end;
  end;

{$IFDEF SAVEFONTCHARSETS}
  SetLength(FontCharAttrMap, FRTFProps.Attributes.CharAttrCount + 1);
  FRTFProps.Attributes.GetFontCharsetList(FRTFDataCollection,
    FontList, FontCharAttrMap);
{$ENDIF}
end;

// Overwrite this procedure to write the header information (such as RTF tables ...)

procedure TWPRTFWriter.WriteAStyle(const sty: TWPRTFStyleElement; nr: Integer);
var n: Integer;
  charattr, oldattr: TWPCharAttr;
  ele: TWPRTFStyleElement;
  str: string;
begin
  if sty <> nil then
  begin
    if nr >= 0 then
    begin
      WriteStringAndValue(#13 + #10 + '{\s', nr);
      Assert(nr = sty._RTF_ID, 'stylesheet out of sync - ' + IntToStr(nr));
      sty._RTF_ID := nr;
    end;
      // Write the data --------------------------------------------------
    WriteParProps(sty.TextStyle, false, false, false);
    WriteShading(sty.TextStyle, false, false, false);
    if sty.TextStyle.AGet(WPAT_ParIsOutline, n) then WriteStringAndValue('\toc', n);
      // Write Char Attr

    FillChar(oldattr, SizeOf(oldattr), 0);

    sty.TextStyle.AGetStyleCharAttr(charattr, false, true);
    WriteACharAttr(sty.TextStyle, charattr, oldattr, -1, true);
      // Write references ------------------------------------------------
    if nr >= 0 then
    begin
      if sty.IsDefault then
        WriteStringAndValue('\sdefault', 1); //V5.17.5  - #RTF!
      if (sty.TextStyle.Style <> 0) then
      begin
        ele := FRTFProps.ParStyles.GetStyle(sty.TextStyle.Style);
        if (ele <> nil) and (ele._RTF_ID > 0) then
          WriteStringAndValue('\sbasedon', ele._RTF_ID);
      end;
      str := sty.NextStyleName;
      if (str <> '') then
      begin
        ele := FRTFProps.ParStyles.GetStyle(str);
        if (ele <> nil) and (ele._RTF_ID > 0) then
          WriteStringAndValue('\snext', ele._RTF_ID);
      end;
      WriteString(#32);
      WriteTranslatedString(sty.Name);
      WriteString(';}');
    end;
  end;
end;

function TWPRTFWriter.WriteHeader: Boolean;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure WriteFontSet(const name: string; charset, number: Integer);
  var j: Integer;
  begin
    if RTFProps._FontIsSymbol(name) then charset := 2; // Otherwise WordPad does not render correctly
    WriteString('{\f'); { Fontnumber }
    WriteInteger(number); { \fontfamily }
   { case (FRTFProps.Fontfamily[index] and $F0) of
      FF_DECORATIVE: WriteString('\fdecor');
      FF_MODERN: WriteString('\fmodern');
      FF_SCRIPT: WriteString('\fscript');
      FF_SWISS:  WriteString('\swiss');
    else  }
    WriteString('\fnil');
   // end;
    { \fcharset }
    WriteStringAndValue('\fcharset', charset);
    WriteString(#32);
{$IFDEF NODOLLARINFONTNAMES}
    j := Pos('$', name);
    if j <= 0 then WriteString(name)
    else WriteString(Trim(Copy(name, 1, j - 1)));
{$ELSE}
    WriteString(name);
{$ENDIF}
    WriteString(';}');
  end;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure WriteRGB(aColor: TColor);
  var rgbvalue: Integer;
  begin
    rgbvalue := ColorToRGB(aColor);
    WriteString(Format('\red%d\green%d\blue%d;',
      [(rgbvalue) and 255, (rgbvalue shr 8) and 255, (rgbvalue shr 16) and 255]));
  end;
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure WriteNumberListStyle(NumberStyle: TWPRTFNumberingStyle; NumInGroup: Integer);
  var shortstr: string;
    d: Integer;
    wide: WideString;
    i: Integer;
  begin
    WriteString('\listlevel\leveljc0\levelfollow0\levelstartat1\levelspace0\levelindent');
    WriteInteger(NumberStyle.Indent);
    case NumberStyle.Style of
      wp_1: shortstr := '\levelnfc0';
      wp_lg_i: shortstr := '\levelnfc1';
      wp_i: shortstr := '\levelnfc2';
      wp_lg_a: shortstr := '\levelnfc3';
      wp_a: shortstr := '\levelnfc4';
      wp_bullet: shortstr := '\levelnfc23'; // bullet
    else
      shortstr := '\levelnfc23'; // no number=bullet
    end;
    WriteString(shortstr);
    if (NumberStyle.IndentFirst <> 0) or (NumberStyle.IndentLeft <> 0) then
    begin
      WriteStringAndValue('\fi', NumberStyle.IndentFirst);
      WriteStringAndValue('\li', NumberStyle.IndentLeft);
    end;

    if NumberStyle.TextStyle.AGet(WPAT_Number_STARTAT, d) and (d > 0) then
      WriteStringAndValue('\levelstartat', d);

    if NumberStyle.TextStyle.AGet(WPAT_NumberTEXT, d) then
    begin
      wide := NumberStyle.TextStyle.ANumberToString(d);
      shortstr := '';
      for d := 1 to Length(wide) do
        if wide[d] < #10 then
          shortstr := shortstr + '\' + #39 + IntToHex(d, 2);
      WriteString('{\leveltext\' + #39);
      WriteString(IntToHex(Length(wide), 2));
      WriteString(MakeStringRTFConformW(wide));
      WriteString(';}');
      WriteString('{\levelnumbers ' + shortstr + ';}');
    end else
    begin
      shortstr :=
        MakeStringRTFConform(NumberStyle.TextB) +
        '\' + #39 + IntToHex(NumInGroup - 1, 2) +
        MakeStringRTFConform(NumberStyle.TextA);
      WriteString('{\leveltext\' + #39 + IntToHex(1 + Length(NumberStyle.TextB)
        + Length(NumberStyle.TextA), 2) + shortstr + ';}');

      WriteString('{\levelnumbers\' + #39 +
        IntToHex(Length(NumberStyle.TextB) + 1, 2) + ';}');
    end;

            // ... \fi-360\li720\jclisttab\tx720
    if NumberStyle.Font <> '' then
{$IFDEF SAVEFONTCHARSETS}
      WriteString('\f' + IntToStr(FontMap(NumberStyle.Font,
        NumberStyle.TextStyle.AGetDef(WPAT_CharCharset, 1))));
{$ELSE}
      WriteString('\f' + IntToStr({FontMap[}FRTFProps.AddFontName(NumberStyle.Font) {]}));
{$ENDIF}
    if NumberStyle.Size <> 0 then
      WriteString('\fs' + IntToStr(NumberStyle.Size * 2));
    if NumberStyle.TextStyle.AGet(WPAT_CharColor, i) then
      WriteStringAndValue('\cf', i);
    if NumberStyle.TextStyle.AGet(WPAT_CharBGColor, i) then
      WriteStringAndValue('\cb', i);
    if NumberStyle.UsePrev then
      WriteString('\levelprev1');
  end;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
var a, stynr, i, l, n: Integer;
  rtfv: TWPRTFExtraDataItem;
  b: Boolean;
  s: string;
  NumberStyle: TWPRTFNumberingStyle;
  FHeaderProps: TWPRTFSectionProps;
const
  CPropSubTypes: array[TWPRTFExtraSubType] of string = ('30', '30', '3', '11', '64');
begin
   // We check for attribute change our own way

  if not RTFDataCollection.ANSITextAttr.AGet(WPAT_CharFontSize, FDefaultFontSize) then
    FDefaultFontSize := DefaultFontSize * 100; //V5.18.5

  WriterModes := [];
  FCurrCharIndex := $FFFFFFFF;
  FWritingTable := 0;
  IndexForWhite := FRTFProps.AddColor(clWhite);
  SetLength(FColorMap, FRTFProps.NumPaletteEntries + 1);
  FNeedEndPar := TRUE;
  Result := inherited WriteHeader;
   // --------------------------------------------------------------------------
   // Start Tags
  if not (soNoRTFStartTags in FStoreOptions) and not OptNoStartTags then
  begin
    WriteString('{\rtf1\ansi\deff0');
    if not (soUseUnicode in FStoreOptions) then
      WriteStringAndValue('\uc1\ansicpg', OptCodePage);
    WriteStringAndValue('\deftab', FRTFDataCollection.Header.DefaultTabstop);
  end;
   // --------------------------------------------------------------------------
   // Font Table
  if not (soNoFontTable in FStoreOptions) then
  begin
    WriteString('{\fonttbl');
{$IFDEF SAVEFONTCHARSETS}
    for i := 0 to FontList.Count - 1 do
      WriteFontSet(FontList[i], Integer(FontList.Objects[i]), i);
{$ELSE}
    for i := 0 to FRTFProps.FontMaxAnz - 1 do
      if FRTFProps.Fontname[i] <> '' then
        WriteFontSet(FRTFProps.Fontname[i], 1, i); // charset = 1!
{$ENDIF}
    WriteString('}');
  end;
   // --------------------------------------------------------------------------
   // Color Table - first check if we need the color table and initialize the mapping
   // (If we don't write color table we still write the colors!)
  l := 0;
  for i := 0 to FRTFProps.NumPaletteEntries do
  begin
    if FRTFProps.FPaletteEntriesUsed[i] then inc(l);
    FColorMap[i] := i;
  end;
  if (l > 0) and not (soNoColorTableInRTF in FStoreOptions) then
  begin
    WriteString('{\colortbl');
    l := 0;
    for i := 0 to FRTFProps.NumPaletteEntries do
      if FRTFProps.FPaletteEntriesUsed[i] then
      begin
        FColorMap[i] := l;
        WriteRGB(FRTFProps.FPaletteEntries[i]);
        inc(l);
      end;
    WriteString('}');
    FNeedSpace := FALSE;
  end;
   // --------------------------------------------------------------------------
  {if (soWordwrapInformation in FStoreOptions) and not FClipboardOperation then
  begin
    FSaveFormattedText := TRUE;
    WriteString('\wpformatted1');
  end else FSaveFormattedText := FALSE; }
   // --------------------------------------------------------------------------

  if FGlobalSectionID > 0 then
  begin
    FHeaderProps := RTFDataCollection.GetSectionProps(FGlobalSectionID);
    // FWriteSection := TRUE;
  end
  else FHeaderProps := FRTFDataCollection.Header;

  if not (soNoPageFormatInRTF in FStoreOptions) then
  begin
    if FHeaderProps.Landscape then
      WriteString('\landscape');

    if FHeaderProps.MarginMirror then
      WriteString('\margmirror');

    WriteStringAndValue('\wpprheadfoot',
      Integer(RTFDataCollection.PrintParameter.PrintHeaderFooter));

    if FWriteSection then
      WriteString('\pgwsxn')
    else
      WriteString('\paperw');
    WriteInteger(FHeaderProps.PageWidth);
    if FWriteSection then
      WriteString('\pghsxn')
    else
      WriteString('\paperh');
    WriteInteger(FHeaderProps.PageHeight);
    // NOT: PageHeight));
    if FWriteSection then s := 'sxn' else s := '';

    WriteString('\margl' + s);
    WriteInteger(FHeaderProps.LeftMargin);
    WriteString('\margr' + s);
    WriteInteger(FHeaderProps.RightMargin);
    WriteString('\margt' + s);
    WriteInteger(FHeaderProps.TopMargin);
    WriteString('\margb' + s);
    WriteInteger(FHeaderProps.BottomMargin);
    WriteString('\headery');
    WriteInteger(FHeaderProps.MarginHeader);
    WriteString('\footery');
    WriteInteger(FHeaderProps.MarginFooter);    
    
  end;

  // --------------------------------------------------------------------------
  WriteString(FInitializeWritingText);
  // --------------------------------------------------------------------------

  if not OptOnlyBody and // V5.12.1
    not (soNoHeaderText in FStoreOptions) then
  begin
    SpecialPG := (
      (FRTFDataCollection.Find(wpIsHeader, wpraOnLastPage, '', FGlobalSectionID) <> nil) or
      (FRTFDataCollection.Find(wpIsFooter, wpraOnLastPage, '', FGlobalSectionID) <> nil) or
      (FRTFDataCollection.Find(wpIsHeader, wpraNotOnFirstAndLastPages, '', FGlobalSectionID) <> nil) or
      (FRTFDataCollection.Find(wpIsFooter, wpraNotOnFirstAndLastPages, '', FGlobalSectionID) <> nil));
    if SpecialPG then // -----------  Special RTF Code --------------------------
    begin
      odd_pages_def := wpraOnLastPage;
      even_pages_def := wpraNotOnFirstAndLastPages;
    end
    else
    begin // ---------- Standard RTF Code ---------------------------------------
      odd_pages_def := wpraOnOddPages;
      even_pages_def := wpraOnEvenPages;
    end;
    TitlePG := (FRTFDataCollection.FindSpecialTextRange(wpraOnFirstPage, wpIsHeader, '', FGlobalSectionID) <> nil) or
      (FRTFDataCollection.FindSpecialTextRange(wpraOnFirstPage, wpIsFooter, '', FGlobalSectionID) <> nil)
      or (FRTFDataCollection.FindSpecialTextRange(wpraNotOnFirstPage, wpIsHeader, '', FGlobalSectionID) <> nil) //V5.18.8
      or (FRTFDataCollection.FindSpecialTextRange(wpraNotOnFirstPage, wpIsFooter, '', FGlobalSectionID) <> nil)
      ;
    FacingPG := SpecialPG or
      (FRTFDataCollection.Find(wpIsHeader, odd_pages_def, '', FGlobalSectionID) <> nil) or
      (FRTFDataCollection.Find(wpIsHeader, even_pages_def, '', FGlobalSectionID) <> nil) or
      (FRTFDataCollection.Find(wpIsFooter, odd_pages_def, '', FGlobalSectionID) <> nil) or
      (FRTFDataCollection.Find(wpIsFooter, even_pages_def, '', FGlobalSectionID) <> nil);
    WriteString('\endnhere\sectdefaultcl');
    if SpecialPG then WriteString('\wpspecialhf');
    if TitlePG then WriteString('\titlepg');
    if FacingPG then WriteString('\facingp');
  end;

   // --------------------------------------------------------------------------
 {if (soWriteBackgroundImageInRTF in FStoreOptions) then
  begin
     // WriteBackgroundImage;
  end; }

  // --------------------------------------------------------------------------
  // "Generator" RTF Item - can be important for future import + debugging.
  // Disable at your own risk with                WPToolsRTFGenerator := ''
  // --------------------------------------------------------------------------
  if WPToolsRTFGenerator <> '' then
  begin
    WriteString('{\*\generator ');
    WriteString(WPToolsRTFGenerator);
{$IFDEF WPPREMIUM}WriteString('-PRM'); {$ENDIF}

    WriteString(';}');
  end;

  // --------------------------------------------------------------------------
  // INFO Items, RTFVariables
  // --------------------------------------------------------------------------

  if not (soNoRTFVariables in StoreOptions) and not OptNoVariables then
  begin
    // -------- Save Standard RTF Variables ------------------------------------
    b := TRUE;
    for i := 0 to RTFDataCollection.RTFVariables.Count - 1 do
    begin
      rtfv := RTFDataCollection.RTFVariables.Items[i];
      if (rtfv.Mode = wpxText) and (wpxSaveToRTF in rtfv.Options)
        and rtfv.IsStandardRTFInfo // the others are saved as 'userprops'
        and (rtfv.Text <> '') then
      begin
        s := Lowercase(rtfv.Name);
{$IFNDEF NOTIG_DATABASEINFO}
        if (s = 'databases') and
          (rtfv.Text = 'DATA,LOOP10,LOOP100') then
        begin
          // Ignore the strings mistakenly created by wptools property editor
        end else
{$ENDIF}
        // DO NOT SAVE THE GENERATOR FROM THE RTFVARIABLES
        // SINCE WE HAVE TO SAVE WPToolsRTFGenerator! Otherwise
        // we cannot react on certain versions!
          if s <> 'generator' then
          begin
            if b then
            begin
              WriteString('{\info');
              b := FALSE;
            end;
            {$IFNDEF ASTERIX_FOR_SPECIAL_FIELDS}
            if (s = 'manager') or (s = 'company') or (s = 'category') or (s = 'hlinkbase') then
              s := '{\' + s + #32
            else
            {$ENDIF}
            s := '{\*\' + s + #32;
            WriteString(s);
            WriteTranslatedString(rtfv.Text);
            WriteString('}' + #13 + #10);
          end;

      end;
    end;
    if not b then WriteString('}');
    // -------------------------------------------------------------------------
    // ------ V5.11.2 - Save UserProps -----------------------------------------
    // -------------------------------------------------------------------------
    b := TRUE;
    for i := 0 to RTFDataCollection.RTFVariables.Count - 1 do
    begin
      rtfv := RTFDataCollection.RTFVariables.Items[i];
      if (rtfv.Mode = wpxText) and (wpxSaveToRTF in rtfv.Options)
        and not rtfv.IsStandardRTFInfo // THESE are saved as 'userprops'
        and (rtfv.Text <> '') then
      begin
        s := Lowercase(rtfv.Name);
        if b then
        begin
          WriteString('{\*\userprops ');
          b := FALSE;
        end;
        WriteString('{\propname ' + s + '}\proptype' + CPropSubTypes[rtfv.SubType] + '{\staticval ');
        WriteTranslatedString(rtfv.Text);
        WriteString('}' + #13 + #10);
      end;
    end;
    if not b then
    begin
      WriteString('}');
    end;
    // -------------------------------------------------------------------------
    // ------ V5.12.1 - Save binary vars ---------------------------------------
    // -------------------------------------------------------------------------
    b := TRUE;
    for i := 0 to RTFDataCollection.RTFVariables.Count - 1 do
    begin
      rtfv := RTFDataCollection.RTFVariables.Items[i];
      if (rtfv.Mode = wpxData) and (wpxSaveToRTF in rtfv.Options)
        and (rtfv.Data <> nil) then
      begin
        s := Lowercase(rtfv.Name);
        if b then
        begin
          WriteString('{\*\wpbininfo');
          b := FALSE;
        end;
        WriteString('{\wpbinname ' + s + '}\proptype' + CPropSubTypes[rtfv.SubType] + '{\wpbindata ');
        WriteHexEncoded(rtfv.Data, 0);
        WriteString('}' + #13 + #10);
      end;
    end;
    if not b then
    begin
      WriteString('}');
    end;
  end;

  // --------------------------------------------------------------------------
  // NEW STYLE Outline Table
  // - detect the groups and single styles which are actually used
  // - write the table + overrides
  // - use in paragraphs by simple reference \ls
  // --------------------------------------------------------------------------
  if not OptNoNumStyles and
    not OptNoNumberProps and
    not (soDontSaveListStyle in FStoreOptions) and
    not (soSaveOldPNNumbering in FStoreOptions) and
    ((FUsedNumberStyles > 0) or (FUsedNumberGroups <> nil)) then
  begin
    WriteString('{\*\listtable');

    n := 1;
    // First Save the groups - this way the index of the group entry
    // in FUsedNumberGroups reflects the \ls number
    for a := 0 to Length(FUsedNumberGroups) - 1 do
      if FRTFProps.NumberStyles.InitGroupArray(FUsedNumberGroups[a]) > 0 then
      begin
        WriteString('{\list\listtemplateid');
        WriteInteger(n);
        WriteString(#13 + #10);
        for i := 1 to 9 do
        begin
          NumberStyle := FRTFProps.NumberStyles.GroupItems[i];
          if NumberStyle <> nil then
          begin
            WriteString('{');
            NumberStyle._RTF_ID := n;
            WriteNumberListStyle(NumberStyle, i);
            WriteString('}' + #13 + #10);
          end;

        end;
        WriteStringAndValue('\listid', n);
        WriteString('}');
        inc(n);
      end;

    // Then save simple list items
    if FUsedNumberStyles > 0 then
      for a := 0 to FRTFProps.NumberStyles.Count - 1 do
      begin
        NumberStyle := FRTFProps.NumberStyles[a];
        if NumberStyle.Used and (NumberStyle.Group = 0) then
        begin
          NumberStyle._RTF_ID := n;
          WriteString('{\list\listtemplateid');
          WriteInteger(n);
          WriteString('\listsimple{');
          WriteNumberListStyle(NumberStyle, 1);
          WriteStringAndValue('}\listid', n);
          WriteString('}');
          inc(n);
        end;
      end;
    WriteString('}'); // listtable
    // Save Listoverride Table - we are simply mapping ls to listid
    WriteString('{\*\listoverridetable');
    for a := 1 to n - 1 do
    begin
      WriteStringAndValue('{\listoverride\listid', a);
      WriteStringAndValue('\listoverridecount0\ls', a);
      WriteString('}');
    end;
    WriteString('}'); // listoverridetable
    FUseLSListSyntax := TRUE; // Saves \ls1\ilvlN
  end;

    // ------------- Write the Style Sheet -------------------------------------

  if not OptNoStyles and
    not (soNoStyleTable in FStoreOptions) and (RTFProps.ParStyles.Count > 0) then
  begin
    if soAllStylesInCollection in FStoreOptions then stynr := 1
    else
    begin
      stynr := 0;
      for a := 0 to RTFProps.ParStyles.Count - 1 do
        if RTFProps.ParStyles.Items[a]._RTF_ID > 0 then
        begin
          stynr := 1;
          break;
        end;
    end;
    if stynr > 0 then
    begin
      WriteString('{\stylesheet');
      stynr := 0;
      for a := 0 to RTFProps.ParStyles.Count - 1 do
        if (RTFProps.ParStyles.Items[a]._RTF_ID > 0) // ONLY IF USED !!!!
         { ((soAllStylesInCollection in FStoreOptions)
            and (RTFProps.ParStyles.Items[a].Name <> '')) }then
        begin
          inc(stynr);
          WriteAStyle(RTFProps.ParStyles.Items[a], stynr);
        end;
      WriteString('}' + #13 + #10);
    end;
  end;

  (* OBSOLETE:  save old list style
  else
    if not (soNoOutlineStyleTable in FStoreOptions)
      and not (soOnlyNumberCompatibilityText in FStoreOptions)
    then
    begin
      WriteString('\sectd' + #13 + #10);

      // We currently only save the number style '1'
      if FRTFProps.NumberStyles.InitGroupArray(1) > 0 then
        for i := 1 to 9 do
          if FRTFProps.NumberStyles.GroupItems[i] <> nil then
          begin
            WriteString('{\*\pnseclvl'
              + IntToStr(i)
              + NumberStyleRTFString(FRTFProps.NumberStyles.GroupItems[i], 0));
          end;
    end; *)

  WriteString('{');
  FNeedSpace := FALSE;
end;

// Write the text as defined by par_s and/or

function TWPRTFWriter.WriteFooter: Boolean;
begin
  if FLastNumberStyle <> nil then
  begin
    if FCloseNumberBracket then
    begin
      WriteString('}');
      FCloseNumberBracket := FALSE;
    end;
    FLastNumberStyle := nil;
  end;
  WriteString('}');
  if not (soNoRTFStartTags in FStoreOptions) and not OptNoStartTags then
  begin
    WriteString('}');
    FNeedSpace := FALSE;
  end;

{$IFDEF SAVEFONTCHARSETS}
  SetLength(FontCharAttrMap, 0);
  FontList.Clear;
{$ENDIF}
  Result := inherited WriteFooter;
end;

function TWPRTFWriter.WriteObject(txtobj: TWPTextObj; par: TParagraph; posinpar: Integer): Boolean;
var bin: TMemoryStream;
  DontSave, AllowBinary: Boolean;
  SaveObj, ImageObj: TWPObject;
  sty: TWPRTFStyleElement;
  oldattr, charattr: TWPCharAttr;
  i: Integer;
  LinkedToFile: string;
begin
{$IFDEF IGNOREALLOBJECTS}
  Result := TRUE;
  exit;
{$ENDIF}
  AllowBinary := not OptNoBinary and
    (soWriteObjectsAsRTFBinary in FStoreOptions)
    and (RTFDataCollection.WriteObjectMode <> wobStandardNoBinary)
    and (RTFDataCollection.WriteObjectMode <> wobRTFNoBinary);
  if txtobj.IParam <> 0 then
  begin
    WriteStringAndValue('\wpiparam', txtobj.IParam);
  end;
  if txtobj.Frame <> [] then
  begin
    i := 0;
    if wpframeFine in txtobj.Frame then inc(i);
    if wpframe1pt in txtobj.Frame then inc(i, 2);
    if wpframe2pt in txtobj.Frame then inc(i, 4);
    if wpframeShadow in txtobj.Frame then inc(i, 8);
    WriteStringAndValue('\wpframeparam', i);
  end;
  // ---------------------------------------------------------------------------
  i := 0;
  if wpobjObjectUnderText in txtobj.Mode then inc(i, 1);
  if wpobjPositionAtRight in txtobj.Mode then inc(i, 2);
  if wpobjPositionAtCenter in txtobj.Mode then inc(i, 4);
  if wpobjPositionInMargin in txtobj.Mode then inc(i, 8);
  if wpobjLockedPos in txtobj.Mode then inc(i, 16);
  if wpobjSizingDisabled in txtobj.Mode then inc(i, 32);
  if wpobjSizingAspectRatio in txtobj.Mode then inc(i, 64);
  if wpobjReadSourceFromEmbeddedText in txtobj.Mode then inc(i, 128);
  if i > 0 then WriteStringAndValue('\wpmodeparam', i);
  // ---------------------------------------------------------------------------
  case txtobj.ObjType of
    wpobjMergeField:
      begin
     // Name=fieldname, Source=Command A field (used to be Insertpoint - now always use Start/End !
        if wpobjIsOpening in txtobj.Mode then
        begin
          if wpobjWithinEditable in txtobj.Mode then
            WriteString('{\formfield')
          else WriteString('{\field');
          // This is a table of contents! ------------------------------------
          if (txtobj.Name = WPTOC_FIELDNAME) then
          begin
            WriteString('{\*\fldinst{TOC');
            WriteString(' \\h');
          end else
          // This is a merge field -------------------------------------------
          begin
            WriteString('{\*\fldinst{MERGEFIELD' + #32);
            if Pos(#32, txtobj.Name) > 0 then
              WriteTranslatedString('"' + txtobj.Name + '"')
            else WriteTranslatedString(txtobj.Name);
          end;
          if txtobj.Source <> '' then
          begin
            WriteString(#32);
            WriteTranslatedString(txtobj.Source);
          end;
          WriteString('}}');
          if txtobj.Params <> '' then
          begin
            WriteString('{\*\wpfldparam{');
            WriteTranslatedString(txtobj.Params);
            WriteString('}}');
          end;
          WriteString('{\fldrslt{');
          FNeedSpace := FALSE;
          inc(FFieldOpen);
        end else
          if wpobjIsClosing in txtobj.Mode then
          begin
{$IFDEF CLOSEFIED_AFTER_LAST_PAR}
            // Special Case - we are at the very end of the last paragraph
            if (posinpar < par.CharCount - 1) and (par.next = nil) then //V5.20.6
            begin
               // ignore
            end else
{$ENDIF}
              if (FFieldOpen > 0) then
              begin
                dec(FFieldOpen);
                WriteString('}}}');
                FNeedSpace := FALSE;
              end;
{$IFNDEF CLOSEFIED_AFTER_LAST_PAR}
            // Special Case - we are at the very end of the last paragraph
            if (posinpar < par.CharCount - 1) and (par.next = nil) then //V5.20.6a
            begin
              WriteParProps(par, false, false, true);
               //WriteBorder(par,
            end;
{$ENDIF}
          end;
      end;
    wpobjHyperlink:
      begin
     // Name=Title, Source = HREF, StyleName=class
        if wpobjIsOpening in txtobj.Mode then
        begin
          WriteString('{\field{\*\fldinst{HYPERLINK' + #32);

          // Save Word compatible link option:
          if (txtobj.CParam >= 1000 + Integer('a')) and
            (txtobj.CParam <= 1000 + Integer('z')) then
            WriteString('\\' + Char(txtobj.CParam - 1000) + #32);

          if (txtobj.Source <> '') and (txtobj.Source[1] = '"') then
            WriteTranslatedString(txtobj.Source)
          else
          begin
            WriteString('"');
            WriteTranslatedString(txtobj.Source);
            WriteString('"');
          end;
          WriteString('}}');

          if txtobj.Source <> '' then
          begin
            WriteString('{\*\fldtitle{');
            WriteTranslatedString(txtobj.Source);
            WriteString('}}');
            FNeedSpace := FALSE;
          end;
          WriteString('{\fldrslt{');
          FNeedSpace := FALSE;
          inc(FHyperOpen);
        end else
          if wpobjIsClosing in txtobj.Mode then
          begin
       // Todo - close correct from list !
            if FHyperOpen > 0 then
            begin
              dec(FHyperOpen);
              WriteString('}}}');
              FNeedSpace := FALSE;
            end;
          end;
      end;
    wpobjBookmark:
      begin
       // Name=Title, Source = bookmark Name, StyleName=class
        if wpobjIsOpening in txtobj.Mode then
        begin
          WriteString('{\*\bkmkstart' + #32);
          WriteTranslatedString(txtobj.Name);
          WriteString('}');
          FNeedSpace := FALSE;
        end else if wpobjIsClosing in txtobj.Mode then
        begin
          WriteString('{\*\bkmkend' + #32);
          WriteTranslatedString(txtobj.Name);
          WriteString('}');
          FNeedSpace := FALSE;
        end else // not expected:
        begin
          WriteString('{\*\bkmksingle' + #32);
          WriteTranslatedString(txtobj.Name);
          WriteString('}');
          FNeedSpace := FALSE;
        end;
      end;
    wpobjTextObject:
      if txtobj.Name = 'UNICODEC' then
      begin
        if txtobj.CParam = 2013 then
        begin
          WriteString('\endash');
          FNeedSpace := TRUE;
        end
        else if txtobj.CParam = 2014 then
        begin
          WriteString('\emdash');
          FNeedSpace := TRUE;
        end else
        begin
          WriteStringAndValue('\u', txtobj.CParam);
          WriteString(' ?');
        end;
      end else
      begin
       // A text object field (one char text, such as PAGE), Source=FieldMask
        WriteString('{\field{\*\fldinst{');
        WriteString(txtobj.Name);
        if txtobj.Source <> '' then
        begin
          WriteString(#32);
          WriteTranslatedString(txtobj.Source);
        end;
        WriteString('}}');
        // -------------------------------------------- RESULT STRING
        WriteString('{\*\fldrslt{'); //V5.17.3
        if txtobj.Params <> '' then
        begin
          WriteTranslatedString(txtobj.Params);
        end;
        WriteString('}}');
        // -------------------------------------------- and finished
        WriteString('}');
        FNeedSpace := FALSE;
      end;
    wpobjFootnote: // Write a simple footnote
      begin
        WriteString('{\super ');
        if txtobj.Params = '' then
          WriteString(#32)
        else WriteTranslatedString(Copy(txtobj.Params, 1, 1));
        WriteString('{\*\footnote\pard\plain\widctlpar ');
        WriteTranslatedString(txtobj.Source);
        WriteString('}}');
        FNeedSpace := FALSE;
      end;
    // wpobjPageSize,   // Set a new page size from here
    // wpobjPageProps,
    wpobjReference:
      begin
        WriteString('{\field{\*\fldinst{PAGEREF ');
        WriteString(MakeStringRTFConform(txtobj.Name_Spaces));
        // Ref to page number:
        if Pos('\h', txtobj.Name) = 0 then
          WriteString(' \\h');
        WriteString('}}{\fldrslt{');
        WriteTranslatedString(txtobj.Source);
        WriteString('}}}');
        FNeedSpace := FALSE;
      end;
    wpobjImage:
      begin
{$IFDEF IGNOREIMAGES}
        DontSave := TRUE;
{$ELSE}
        DontSave := FALSE;
{$ENDIF}
        if OptNoImages then DontSave := TRUE;
        LinkedToFile := '';
        PrepareImageforSaving(txtobj, DontSave, LinkedToFile);
        ImageObj := txtobj.ObjRef;
        if not DontSave then
        begin
          if ImageObj = nil then //V5.18.1 - now we can also save empty images
          begin
            SaveObj := TWPTempSaveTextObjHelper.Create(RTFDataCollection);
            SaveObj.Extra := txtobj.AGetWPSS(false);
            ImageObj := SaveObj;
          end else SaveObj := nil;
          try
      // a TWPObject, for HTML images the 'name=ALT tag, Source = file', StyleName=class
      {	1. Now save new	wpobj format }
            if (RTFDataCollection.WriteObjectMode = wobStandard) or
              (RTFDataCollection.WriteObjectMode = wobStandardAndRTF) or
              (RTFDataCollection.WriteObjectMode = wobStandardNoBinary) or
              ((RTFDataCollection.WriteObjectMode <> wobDontSaveImages) and
              not ImageObj.CanSaveAsRTF(txtobj)) then
            begin
              WriteString('{\*\wptools');
              ImageObj.WidthTW := txtobj.Width;
              ImageObj.HeightTW := txtobj.Height;
              if (wpobjRelativeToParagraph in txtobj.Mode) or
                (wpobjRelativeToPage in txtobj.Mode) then
              begin
                WriteStringAndValue('\ppar\wprelx', txtobj.RelX); // -FRTFDataCollection.Header._Layout.margl);
                WriteStringAndValue('\rely', txtobj.RelY);
                WriteStringAndValue('\picwrap', Integer(txtobj.wrap));
              end;

              WriteStringAndValue('\wpomode', Integer(txtobj._ModeToInt));
              WriteStringAndValue('\wpoframe', Integer(txtobj._FrameToInt));

              if txtobj.Name <> '' then //V5.19.1
              begin
                WriteString('{\*\wppicname{');
                WriteTranslatedString(txtobj.Name);
                WriteString('}}');
              end;
              if txtobj.Source <> '' then
              begin
                WriteString('{\*\wppicsource{');
                WriteTranslatedString(txtobj.Source);
                WriteString('}}');
              end;

              WriteString('{');
              bin := TMemoryStream.Create;
              try
                ImageObj.SaveVCL(bin, Self);
                if AllowBinary then
                begin
                  WriteStringAndValue('\bin', bin.Size);
                  WriteString(#32);
                  WriteStream(bin, false);
                end else
                begin
                  WriteHexEncoded(bin);
                end;
              finally
                bin.Free;
              end;
              WriteString('}}');
              FNeedSpace := FALSE;
            end;
            //2. Save Standard RTF ---------------------------------------------
            if ((RTFDataCollection.WriteObjectMode = wobRTF) or
              (RTFDataCollection.WriteObjectMode = wobRTFNoBinary) or
              (RTFDataCollection.WriteObjectMode = wobStandardAndRTF)) and
              ImageObj.CanSaveAsRTF(txtobj) then
            begin
              if txtobj.Name <> '' then //V5.19.1
              begin
                WriteString('{\*\wppicname{');
                WriteTranslatedString(txtobj.Name);
                WriteString('}}');
              end;
              if txtobj.Source <> '' then
              begin
                WriteString('{\*\wppicsource{');
                WriteTranslatedString(txtobj.Source);
                WriteString('}}');
              end;
              ImageObj.WriteRTFData(Self, txtobj, AllowBinary, LinkedToFile);
              ImageObj.WriteRTFDataEnd(Self, txtobj, AllowBinary);
              FNeedSpace := FALSE;
            end;
          finally
            FreeAndNil(SaveObj);
          end;
        end;
      end;
    wpobjHorizontalLine:
      begin
        if txtobj.IParam <> 0 then WriteStringAndValue('\wphzlinc', txtobj.IParam); // Color
        if txtobj.CParam <> 0 then WriteStringAndValue('\wphzlino', txtobj.CParam); // Offsets
        if txtobj.Width <> 0 then WriteStringAndValue('\wphzlinw', txtobj.Width); // Width
        WriteStringAndValue('\wphzlinetw', txtobj.Height); // R10.5 - NEW: wphzlinetw->Twips !!!
      end;
  else // Save ALL other objects
    begin
      if wpobjIsClosing in txtobj.Mode then // Only save the tag ...
      begin
        if txtobj.ObjType = wpobjSPANStyle then
        begin
          FNeedPlain := TRUE;
          if last_charattr_index = 0 then
            UpdateCharAttr(txtobj.ParentPar.CharAttr[txtobj.ParentPosInPar]);
          last_charattr_index := cardinal(-1);
        end;
        if (txtobj.ObjType <> wpobjSPANStyle) or not OptNoSpanStyles then
        begin
          WriteStringAndValue('{\field{\wpfclose', txtobj.Tag);
          WriteString('\*\fldinst{WPTOOLSOBJ}}}');
          FNeedSpace := FALSE;
        end;
      end else
      begin
        if (txtobj.ObjType <> wpobjSPANStyle) or not OptNoSpanStyles then
        begin
          WriteString('{\field{');
          if wpobjIsOpening in txtobj.Mode then
            WriteStringAndValue('\wpfopen', txtobj.Tag);
          WriteString('\*\fldinst{WPTOOLSOBJ ');
          WriteTranslatedString(txtobj.AGetWPSS);
          WriteString('}}}');
          FNeedSpace := FALSE;
        end;
        if txtobj.ObjType = wpobjSPANStyle then
        begin
          if txtobj.Style <> nil then
          begin

            FillChar(oldattr, SizeOf(oldattr), 0);

            txtobj.Style.AGetStyleCharAttr(charattr, false, true);
            WriteACharAttr(nil, charattr, oldattr, -1, true);

            if FNeedSpace then //V5.46.5
              WriteString(#32);
          end else
            if txtobj.StyleName <> '' then
            begin
              sty := RTFProps.ParStyles.FindStyle(txtobj.StyleName);
              if sty <> nil then
              begin

                FillChar(oldattr, SizeOf(oldattr), 0);

                sty.TextStyle.AGetStyleCharAttr(charattr, false, true);
                WriteACharAttr(nil, charattr, oldattr, -1, true);
              end;
            end;
        end;

        FNeedSpace := FALSE;
      end;
    end;
  end;
  Result := TRUE;
end;

function TWPRTFWriter.WriteStringAndValue(const s: AnsiString; Value: Integer): Boolean;
begin
  Result := WriteString(s) and WriteInteger(Value);
  FNeedSpace := TRUE;
end;

function TWPRTFWriter.NumberStyleRTFString(NumberStyle: TWPRTFNumberingStyle; num_start: Integer): string;
var
{$IFNDEF SAVEFONTCHARSETS}BulletFont: Integer; {$ENDIF}
  numstart: string;
begin
  if NumberStyle = nil then
    Result := ''
  else
  begin
    if num_start <= 0 then
      numstart := '1' else
      numstart := IntToStr(num_start);

    case NumberStyle.Style of
      wp_bullet: Result := '\pnlvlblt';
      wp_lg_a: Result := '\pnucltr\pnstart' + numstart;
      wp_a: Result := '\pnlcltr\pnstart' + numstart;
      wp_lg_i: Result := '\pnucrm\pnstart' + numstart;
      wp_i: Result := '\pnlcrm\pnstart' + numstart;
    else
      Result := '\pndec\pnstart' + numstart;
    end;

    if NumberStyle.Font <> '' then
    begin
{$IFDEF SAVEFONTCHARSETS}
      Result := Result + '\pnf' + IntToStr(FontMap(NumberStyle.Font,
        NumberStyle.TextStyle.AGetDef(WPAT_CharCharset, 1)));
{$ELSE}
      BulletFont := FRTFProps.AddFontName(NumberStyle.Font);
      Result := Result + '\pnf' + IntToStr({FontMap[}BulletFont {]});
{$ENDIF}
    end;

    if NumberStyle.Size <> 0 then
      Result := Result + '\pnfs' + IntToStr(NumberStyle.Size * 2);

    if NumberStyle.UsePrev then
      Result := Result + '\pnprev';

    Result := Result + '\pnhang\pnindent' +
      IntToStr(NumberStyle.Indent);

    if NumberStyle.TextB <> '' then
      Result := Result + '{\pntxtb{' + MakeStringRTFConform(NumberStyle.TextB) + '}}'
    else
      Result := Result + '{\pntxtb}';

    if NumberStyle.TextA <> '' then
      Result := Result + '{\pntxta{' + MakeStringRTFConform(NumberStyle.TextA) + '}}'
    else
      Result := Result + '{\pntxta}';
  end;
end;

function TWPRTFWriter.MakeStringRTFConformW(const Str: WideString): AnsiString;
var
  i: Integer;
begin
  Result := '';
  if Str <> '' then
  begin
    for i := 1 to Length(Str) do
    begin
      if (Str[i] = '\') or
        (Str[i] = '{') or
        (Str[i] = '}') then
      begin
        Result := Result + '\' + Char(Str[i]);
      end else
        if Str[i] < #32 then
        begin
          Result := Result + '\' + #39 + IntToHex(Integer(Str[i]), 2);
        end else
          if Str[i] > #255 then
            Result := Result + '\u' + IntToStr(Integer(Str[i])) + #32 + Char(Str[i])
          else
            Result := Result + Char(Str[i]);
    end;
  end;
end;

function TWPRTFWriter.MakeStringRTFConform(const Str: AnsiString): AnsiString;
var
  i, l: Integer;
  s: AnsiString;
begin
  if Str = '' then Result := '' else
  begin
    SetLength(Result, Length(str) * 4);
    l := 1;
    for i := 1 to Length(Str) do
    begin
      if Str[i] in ['\', '{', '}'] then
      begin
        Result[l] := '\';
        inc(l);
      end;

      if Str[i] < #32 then
      begin
        Result[l] := '\';
        inc(l);
        Result[l] := '''';
        inc(l);
        s := IntToHex(Integer(Str[i]), 2);
        Result[l] := s[1];
        inc(l);
        Result[l] := s[2];
        //NO - inc(l); V5.11.2
      end else
        Result[l] := Str[i];
      inc(l);
    end;
    SetLength(Result, l - 1);
  end;
end;

function TWPRTFWriter.WriteTranslatedString(const Str: AnsiString): Boolean;
begin
  Result := WriteString(MakeStringRTFConform(str));
end;



{$O-} //------ No Optimation because of Compiler Bug

function TWPRTFWriter.WriteChar(aChar: Word): Boolean;
var c: AnsiChar;
  usedDefault, bWriteUni: Boolean;
  DefaultChar: Char;
  l,aCharCopyInt : Integer;
  aCharCopy : Word;
  buffer: array[0..11] of Char;
begin
  Result := true;
  if Integer(aChar) = 9 then
  begin
    Result := WriteString('\tab');
    FNeedSpace := TRUE;
  end else
    if Integer(aChar) = 10 then
    begin
      Result := WriteString('\line');
      FNeedSpace := TRUE;
    end else
      if aChar = Integer('\') then
      begin
        Result := WriteString('\\');
        FNeedSpace := FALSE;
      end else
        if aChar = Integer('{') then
        begin
          Result := WriteString('\{');
          FNeedSpace := FALSE;
        end else
          if aChar = Integer('}') then
          begin
            Result := WriteString('\}');
            FNeedSpace := FALSE;
          end else
          begin
            if OptASCIIMode then
                bWriteUni := Integer(aChar) > 127
            else
               bWriteUni := ((OptCodePage<>1252) and (Integer(aChar)>127)) or
                            ((Integer(aChar) >= 188) and (Integer(aChar)<190));

            if not bWriteUni and (Integer(aChar)<256) then
            begin
              c := AnsiChar(aChar);
              if c > #127 then
              begin
                WriteString('\''');
                Result := WriteString(IntToHex(Integer(aChar), 2));
                FNeedSpace := FALSE;
              end else
              begin
                if FNeedSpace then
                begin
                  WriteString(#32);
                  FNeedSpace := FALSE;
                end;
                if c > #0 then
                  Result := WriteString(c)
                else Result := TRUE;
              end;
            end
{$IFDEF ASCIIRTF}
            else if Integer(aChar) < 256 then
            begin
              WriteString('\''');
              Result := WriteString(IntToHex(Integer(aChar), 2));
              FNeedSpace := FALSE;
            end
{$ENDIF}
            else
            begin
              usedDefault := false;
              aCharCopyInt := Integer( aChar ); //Workaround Complier Bug
              aCharCopy := aChar;
              if OptCodePage <> 1252 then // Save using codepage ?
              begin
                DefaultChar := '?';
                l:=WideCharToMultiByte(
                  OptCodePage,
                  WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
                  @aCharCopy, 1,
                  @buffer[0], 0,  //Check for size only
                  @DefaultChar, @usedDefault);
                if not usedDefault and (l>0) then
                  Result := inherited WriteChar(Word(aCharCopyInt))
                else usedDefault := true; // Error, Write \u
              end
              else usedDefault := true; //V5.36.1
              if usedDefault then
              begin
                WriteStringAndValue('\u', aCharCopyInt);
                Result := WriteString(' ?');
              end;
              FNeedSpace := FALSE;
            end;
          end;
end;

initialization

  if GlobalWPToolsCustomEnviroment <> nil then
  begin
    GlobalWPToolsCustomEnviroment.RegisterWriter([TWPRTFWriter]);
  end;

finalization

end.

