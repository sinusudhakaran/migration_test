{$IFNDEF CLRUNIT}unit WPIOWPTools;
{$ELSE}unit WPTools.IO.WPTools; {$ENDIF}
//******************************************************************************
// WPTools V5 - THE word processing component for VCL and .NET
// Copyright (C) 2004-2008 by WPCubed GmbH and Julian Ziersch, all rights reserved
// WEB: http://www.wpcubed.com   mailto: support@wptools.de
//******************************************************************************

//TODO: Load Stream RTFVariables

{-$DEFINE SAVE_ALL_NUMSTYLES_WPT}// if defined ALL number styles are saved. Can be set by formatstring -AllNumberstyles
{.$DEFINE DONT_LOAD_STYLES_FOR_OBJECTS} //OFF: only SPAN objects may use class and style parameters
{.$DEFINE DONTMAPNUMBERS} //OFF: don't map numbers (new feature V5.22.2)
{.DEFINE DONTLOAD_HIDDEN} // Do not load the paprHidden flag

interface
{$I WPINC.INC}


{$IFDEF VER200} //For now - special adaption will be in V6
  {$WARNINGS OFF}
{$ENDIF}


uses Classes, Sysutils, WPRTEDefs, Graphics, Dialogs;

{$IFDEF T2H}
type
 {:: This class is used to read text which was saved in "WPTOOLS" format. This class is
 used when the format name (property TextLoadFormat) is "WPTOOLS" or "WPT" .

 To avoid loading of KeepN falg use "-ignorekeepn"
 }
  TWPTOOLSReader = class(TWPCustomTextReader);
 {:: This class is used to save text in "WPTOOLS" format. This class is
 used when the format name (property TextSaveFormat) is "WPTOOLS" or "WPT".
 To create abbreviated style strings use the option "-abbreviated,",
 to avoid saving the section page information use "-nosectiondata,".
 <br>
 The "WPTOOLS" format makes it easy to concat text parts to create a big new text.
 If the text parts should be created as new sections (which implies a pagebreak)
 the tag &lt;newsection/&gt; can be used before the string.
 Using &lt;newsection pagebreak=0/&gt; no page break will be inserted
 <br>
 <code>
  WPAll.AsString :=
   '<newsection/>' + WP1.AsANSIString('WPTOOLS')
   +'<newsection/>' + WP2.AsANSIString('WPTOOLS')
   +'<newsection/>' + WP3.AsANSIString('WPTOOLS');
 </code>
  }
  TWPTOOLSWriter = class(TWPCustomTextWriter);
{$ELSE}

type
  TWPTOOLSReader = class(TWPCustomTextReader) { from WPTools.RTE.Defs }
  private
    FCharAttrNr: array of Integer;
    FParStyleNr: array of TWPTextStyle;
  protected
    class function UseForFilterName(const Filtername: string): Boolean; override;
    class function UseForContents(const First500Char: AnsiString): Boolean; override;
  public
    procedure SetOptions(optstr: string); override;
    function Parse(datastream: TStream): TWPRTFDataBlock; override;
  end;

  TWPTOOLSWriter = class(TWPCustomTextWriter) { from WPTools.RTE.Defs }
  protected
    FAllElements: Boolean;
    FSavedStyles: Integer;
    FSavedCharStyles: TList;
    FOptAllNumberstyles : Boolean;
    FOpenObjects: TList;
    FOptAppreviated: Boolean;
    FOptNoSectionData: Boolean;
    FCharAttr: TWPStoredCharAttrInterface;
    class function UseForFilterName(const Filtername: string): Boolean; override; // RTF, HTML or classname
    function WriteElementStart(RTFData: TWPRTFDataBlock): Boolean; override;
    function WriteElementEnd(RTFData: TWPRTFDataBlock): Boolean; override;
    function WriteHyphen: Boolean; override;
    function SaveStyle(aStyle: TWPRTFStyleElement): Integer;
    function PrepareCharAttr(CharAttrIndex: Cardinal): Integer;
  public
    constructor Create(RTFDataCollection: TWPRTFDataCollection); override;
    destructor Destroy; override;
    procedure SetOptions(optstr: string); override;
    function WriteFooter: Boolean; override;
    function WriteHeader: Boolean; override;
    function WriteChar(aChar: Word): Boolean; override;
    function WriteParagraphStart(
      par: TParagraph;
      ParagraphType: TWPParagraphType;
      Style: TWPTextStyle): Boolean; override;
    function WriteLevelEnd(par: TParagraph): Boolean; override;
    function WriteParagraphEnd(par: TParagraph;
      ParagraphType: TWPParagraphType; NeedNL: Boolean): Boolean; override;
    function WriteObject(txtobj: TWPTextObj; par: TParagraph; posinpar: Integer): Boolean; override;

    function UpdateCharAttr(CharAttrIndex: Cardinal): Boolean; override;
    property OptAllNumberstyles : Boolean read FOptAllNumberstyles write FOptAllNumberstyles;
  end;

implementation

{ ----------------------------------------------------------------------------- }

constructor TWPTOOLSWriter.Create(RTFDataCollection: TWPRTFDataCollection);
begin
  inherited Create(RTFDataCollection);
  FSavedStyles := 0;
  FSavedCharStyles := TList.Create;
  FOptNoSectionData := false;
  FOptAppreviated := FALSE;
  FCharAttr := TWPStoredCharAttrInterface.Create(RTFDataCollection);
  FDontSeparateTables := TRUE;
  FOpenObjects := TList.Create;
  {$IFDEF SAVE_ALL_NUMSTYLES_WPT}
  FOptAllNumberstyles := true;
  {$ENDIF}
end;


destructor TWPTOOLSWriter.Destroy;
begin
  FSavedCharStyles.Free;
  FCharAttr.Free;
  FOpenObjects.Free;
  inherited Destroy;
end;

procedure TWPTOOLSWriter.SetOptions(optstr: string);
var i: Integer;
  aoptstr: string;
begin
  i := Pos('-', optstr);
  if i > 0 then
  begin
    aoptstr := lowercase(Copy(optstr, i, Length(optstr) - i + 1)) + ',';
    FOptAppreviated := Pos('-abbreviated,', aoptstr) > 0;
    FOptNoSectionData := Pos('-nosectiondata,', aoptstr) > 0;
    FOptAllNumberstyles := Pos('-allnumberstyles,', aoptstr) > 0;
  end else
  begin
    FOptAppreviated := FALSE;
    FOptNoSectionData := FALSE;
  end;
  inherited SetOptions(optstr);
end;

class function TWPTOOLSWriter.UseForFilterName(const Filtername: string): Boolean;
begin
  Result := inherited UseForFilterName(Filtername) or (CompareText(Filtername, 'WPTOOLS') = 0)
    or (CompareText(Filtername, 'WPT') = 0);
end;

function TWPTOOLSWriter.WriteElementStart(RTFData: TWPRTFDataBlock): Boolean;
begin
 //- we write ALL elements first!
  if FAllElements or
    not (RTFData.Kind in [wpIsFootnote, wpIsLoadedBody, wpIsDeleted]) and
    (not (RTFData.Kind in [wpIsOwnerSelected]) or (RTFData.Range <> wpraNamed)) and //V5.19.2 Save when required!
    ((RTFData.Kind = wpIsBody) or not OptOnlyBody) then
 // if FWrittenBody or (RTFData.Kind=wpIsHeader) then
  begin
    WriteString('<element');

    if RTFData.UsedForSectionID <> 0 then
    begin
      WriteString(' section=');
      WriteInteger(RTFData.UsedForSectionID);
    end;

    if RTFData.Name <> '' then
    begin
      WriteString(' name="');
      WriteHTMLString(RTFData.Name);
      WriteString('"');
    end;

    if RTFData.Readonly then
      WriteString(' readonly=1');

    WriteString(' kind="');
    WriteString(WPPagePropertyKinds[RTFData.Kind]);
    WriteString('" Range="');
    WriteString(WPPagePropertyRanges[RTFData.Range]);
    WriteString('">' + #13 + #10);
    Result := TRUE;


  end else Result := FALSE;
end;

function TWPTOOLSWriter.WriteElementEnd(RTFData: TWPRTFDataBlock): Boolean;
var i: Integer;
begin
  i := FOpenObjects.Count - 1;
  while (i >= 0) do // V5.13.5 - close all open objects!
  begin
    WriteString('<END Tag=');
    WriteInteger(TWPTextObj(FOpenObjects[i]).Tag);
    WriteString('/>');
    dec(i);
  end;
  FOpenObjects.Clear;
  Result := WriteString('</element>' + #13 + #10);
end;

function TWPTOOLSWriter.WriteHyphen: Boolean;
begin
  Result := WriteString('<hy/>');
end;

function TWPTOOLSWriter.WriteFooter: Boolean;
var i: Integer;
begin
  i := FOpenObjects.Count - 1;
  Result := TRUE;
  while (i >= 0) do // V5.13.5 - close all open objects!
  begin
    WriteString('<END Tag=');
    WriteInteger(TWPTextObj(FOpenObjects[i]).Tag);
    if not WriteString('/>') then
      Result := FALSE;
    dec(i);
  end;
  Result := Result and inherited WriteFooter;
end;

function TWPTOOLSWriter.WriteHeader: Boolean;
var i: Integer;
  nsty: TWPRTFNumberingStyle;
  sect: TWPRTFSectionProps;
  s: string;
  par: TParagraph;
  j, last_a, a: Integer;
begin
  Result := WriteString('<!WPTools_Format V=518/>' + #13 + #10); // V5.13.5
  FOpenObjects.Clear;
  if not OptNoPageInfo and
    not (soNoPageFormatInRTF in FStoreOptions) then
  begin
    // -------------------------------------------------------------------------
    WriteString('<GlobalPageFormat wpcss="');
    WriteString(FRTFDataCollection.Header.AGetWPSS);
    WriteString('"/>');
    // -------------------------------------------------------------------------
  end;

  if not OptNoDefaultFont then //V5.18.5
  begin
    // Also write the standard font --------------------------------------------
    WriteString('<StandardFont wpcss="');
    s := FRTFDataCollection.ANSITextAttr.AGetWPSS;
    if not FRTFDataCollection.ANSITextAttr.AGet(WPAT_CharFont, i) then
      s := s + 'CharFont:' + #39 + DefaultFontName + #39 + ';'; //V5.19.0, was #36!
    if not FRTFDataCollection.ANSITextAttr.AGet(WPAT_CharFontSize, i) then
      s := s + 'CharFontSize:' + IntToStr(DefaultFontSize * 100) + ';';
    WriteString(s);
    WriteString('"/>');
  end;

  // Save All Sections  -------~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if not (soNoPageFormatInRTF in FStoreOptions) and
    not FOptNoSectionData and
    not OptNoPageInfo then
  begin
    for i := 0 to FRTFDataCollection.SectionPropertyCount - 1 do
    begin
      sect := FRTFDataCollection.SectionProperty[i];
      WriteString(#13 + #10 + '<SectionPageFormat id=');
      WriteInteger(sect.SectionID);
      WriteString(' wpcss="');
      WriteString(sect.AGetWPSS);
      WriteString('"/>');
    end;
  end;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  // Save RTF Variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if not OptNoVariables and
    not (soNoRTFVariables in FStoreOptions) and
    (RTFDataCollection.RTFVariables.Count > 0) then
  begin
    WriteString(#13 + #10 + '<variables>');
    for i := 0 to RTFDataCollection.RTFVariables.Count - 1 do
    begin
      WriteString(#13 + #10 + '<variable name="');
      WriteString(RTFDataCollection.RTFVariables[i].Name);
      WriteString('"');
      if RTFDataCollection.RTFVariables[i].Mode = wpxText then
      begin
        WriteString(' data="ansi" text="');
        WriteHTMLString(RTFDataCollection.RTFVariables[i].Text);
        WriteString('"/>');
      end else
      begin
        WriteString(' data="binary">');
        WriteString(#13 + #10 + '<!--');
        WriteBase64Encoded(RTFDataCollection.RTFVariables[i].Data);
        WriteString('--></variable>');
      end;
    end;
    WriteString('</variables>');
  end;

  // Save Numberstyles ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if not OptNoNumStyles and not OptBaseText then
  begin
    if OptAllNumberstyles then
    begin
    for i := 0 to RTFProps.NumberStyles.Count - 1 do
      RTFProps.NumberStyles.Items[i]._RTF_ID := -1;
    end else
    begin
    for i := 0 to RTFProps.NumberStyles.Count - 1 do
      if wpAlwaysSaveInWPT in RTFProps.NumberStyles.Items[i].Locked then
        RTFProps.NumberStyles.Items[i]._RTF_ID := -1
      else RTFProps.NumberStyles.Items[i]._RTF_ID := 0;

    // First make sure all number styles we are USING in any styles are saved! (use -1 to force)
    // Check all paragraph styles
    last_a := -1;
    for i := 0 to RTFProps.ParStyles.Count - 1 do
      if RTFProps.ParStyles[i].TextStyle.AGet(WPAT_NumberSTYLE, a) and (a <> last_a) then
      begin
        last_a := a;
        for j := 0 to RTFProps.NumberStyles.Count - 1 do
          if RTFProps.NumberStyles[j].Number = a then
          begin
            RTFProps.NumberStyles.Items[j]._RTF_ID := -1; // SAVE IT!!!
            break
          end;
      end;

    // Check all paragraphs
    par := RTFDataCollection.FirstPar;
    while par <> nil do
    begin
      if par.AGet(WPAT_NumberSTYLE, a) and (a <> last_a) then
      begin
        last_a := a;
        for j := 0 to RTFProps.NumberStyles.Count - 1 do
          if RTFProps.NumberStyles[j].Number = a then
          begin
            RTFProps.NumberStyles.Items[j]._RTF_ID := -1; // SAVE IT!!!
            break
          end;
      end;
      par := par.globalnext;
    end;
    end;

    // Now save it, complete groups, no duplicates except for USES number styles
    WriteString(#13 + #10 + '<numberstyles>');
    for i := 0 to RTFProps.NumberStyles.Count - 1 do
      if RTFProps.NumberStyles.Items[i]._RTF_ID < 0 then // <0 !  V5.19.4
      begin
        nsty := RTFProps.NumberStyles.Items[i];
        nsty._RTF_ID := nsty.ID;
    // Make sure that we only save one instance of a group/LevelInGroup

        if (nsty.Group <> 0) and not OptAllNumberstyles then
        begin
          for a := i + 1 to RTFProps.NumberStyles.Count - 1 do
            if (RTFProps.NumberStyles.Items[a].Group = nsty.Group) and
              (RTFProps.NumberStyles.Items[a].LevelInGroup = nsty.LevelInGroup) then
              if RTFProps.NumberStyles.Items[a]._RTF_ID = 0 then // no forced
                RTFProps.NumberStyles.Items[a]._RTF_ID := nsty.ID;
        end;

        WriteString('<nstyle id=');
        WriteInteger(nsty.ID);
        if nsty.Group <> 0 then
        begin
          WriteString(' group=');
          WriteInteger(nsty.Group);
        end;
        if nsty.LevelInGroup <> 0 then
        begin
          WriteString(' level=');
          WriteInteger(nsty.LevelInGroup);
        end;
        if nsty.Name <> '' then
        begin
          WriteString(' name="');
          WriteHTMLString(nsty.Name);
          WriteString('"');
        end; 
        WriteString(' wpsty=[[');
        WriteHTMLString(nsty.TextStyle.AGetWPSS(false, true, true, false, false));
        WriteString(']]/>' + #13 + #10);
      end;
    WriteString('</numberstyles>');
  end;

  // Save All Paragraph Styles ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if not OptNoStyles and not OptBaseText then
  begin
    WriteString(#13 + #10 + '<stylesheet>');
    for i := 0 to RTFProps.ParStyles.Count - 1 do
      RTFProps.ParStyles.Items[i]._RTF_ID := 0;
    for i := 0 to RTFProps.ParStyles.Count - 1 do
      SaveStyle(RTFProps.ParStyles.Items[i]);
    WriteString('</stylesheet>');
  end;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



end;

function TWPTOOLSWriter.SaveStyle(aStyle: TWPRTFStyleElement): Integer;
var base_sty, a: Integer;
  numsty: TWPRTFStyleElement;
begin
  if aStyle = nil then
    Result := 0
  else if aStyle._RTF_ID > 0 then
    Result := aStyle._RTF_ID
  else
  begin
    if (aStyle.TextStyle.Style <> 0) then
      base_sty := SaveStyle(aStyle.TextStyle.ABaseStyleElement)
    else base_sty := 0;

    inc(FSavedStyles);
    Result := FSavedStyles;
    aStyle._RTF_ID := Result;

    WriteString('<pstyle');
    if aStyle.Name <> '' then
    begin
      WriteString(' name="');
      WriteHTMLString(aStyle.Name);
      WriteString('"');
    end;
    WriteString(' nr=');
    WriteInteger(Result);
    if base_sty <> 0 then
    begin
      WriteString(' base=');
      WriteInteger(base_sty);
    end;
    if aStyle.IsDefault then
      WriteString(' default=1');
    if aStyle.NextStyleName <> '' then
    begin
      WriteString(' next="');
      WriteHTMLString(aStyle.NextStyleName);
      WriteString('"');
    end;

    // -------- FIX the NumberStyle reference to _RTF_ID -----------------------
    if aStyle.TextStyle.AGet(WPAT_NumberSTYLE, a) then
    begin
      numsty := RTFProps.NumberStyles.GetStyle(a);
      if (numsty <> nil) and (numsty.ID <> a) then
        aStyle.TextStyle.ASet(WPAT_NumberSTYLE, numsty._RTF_ID);
    end;
    // -------------------------------------------------------------------------

    if FOptAppreviated then
    begin
      WriteString(' wsty=[[');
      WriteHTMLString(aStyle.TextStyle.AGetWPSS(false, true, true, false, true));
    end else
    begin
      WriteString(' wpsty=[[');
      WriteHTMLString(aStyle.TextStyle.AGetWPSS(false, true, true, false, false));
    end;

    WriteString(']]/>' + #13 + #10);
  end;
end;

function TWPTOOLSWriter.WriteParagraphStart(
  par: TParagraph; ParagraphType: TWPParagraphType;
  Style: TWPTextStyle): Boolean;
var s: string;
  sty, mode, a, lCS, i: Integer;
  numsty: TWPRTFStyleElement;
  band: TCustomParagraphObj;
  bands, bands2: string;
begin
  last_charattr_index := Cardinal(-1);
  // Save Style: ---------------------------------------------------------------
  if not OptNoStyles and not OptBaseText and (par.Style <> 0) then
  begin
    sty := SaveStyle(par.ABaseStyleElement);
  end
  else sty := 0;
  // Save CS Style: ------------------------------------------------------------
  if par.LoadedCharAttr > 0 then
  begin
    lCS := PrepareCharAttr(par.LoadedCharAttr);
  end else lCS := 0;

  // ---------------------------------------------------------------------------
  WriteString('<');
  if paprIsTable in par.prop then
  begin
    if soWriteCellsAsParagraphs in FStoreOptions then
      WriteString('div')
    else if paprIsHeader in par.prop then
      WriteString('th')
    else
      WriteString('td');
  end
  else
  begin
    WriteString(WPParagraphTypeNames[ParagraphType]);
    { if not (par.ParagraphType in
            [wpIsXMLTopLevel, wpIsXMLSubLevel, wpIsReportGroup]) then
        FNeedEndPar  := TRUE;  }
  end;

  // Loaded Character Style!
  if lCS > 0 then
  begin
    WriteString(' cs=');
    WriteInteger(lCS);
  end;

  // Write Important Paragraph Props - the other are auto created
  mode := 0;
  if paprIsPositioned in par.prop then mode := mode or 1;
  if paprColMerge in par.prop then mode := mode or 2;
  if paprRowMerge in par.prop then mode := mode or 4;
  if paprIsHeader in par.prop then mode := mode or 8;
  if paprIsFooter in par.prop then mode := mode or 16;
  if paprReadFromHTML in par.prop then mode := mode or 32;
  if not OptNoPageBreaks and (paprNewPage in par.prop) then mode := mode or 64;
  if paprPagenrRestart in par.prop then mode := mode or 128;
  if paprInActive in par.prop then mode := mode or 256;
  if paprIsCollapsed in par.prop then mode := mode or 512;
  if paprRightToLeft in par.prop then mode := mode or 1024;
  if paprNewColumn in par.prop then mode := mode or 2048;
  {$IFNDEF DONTLOAD_HIDDEN}
  if paprHidden in par.prop then mode := mode or 4096; //V5.24.1
  {$ENDIF}


  if mode <> 0 then
  begin
    WriteString(' mode=');
    WriteInteger(mode);
  end;

  // ----- SECTION ID ----------------------------------------------------------
  if (paprNewSection in par.prop) and (par.SectionID <> 0) then
  begin
    WriteString(' section=');
    WriteInteger(par.SectionID);
  end;

  // ----- name and base style -------------------------------------------------
  if par.Name <> '' then
  begin
    WriteString(' name="');
    WriteHTMLString(par.Name);
    WriteString('"');
  end;

  // Save 'class' if OptBaseText is active!
  if OptBaseText and (par.Style <> 0) then
  begin
    WriteString(' class="');
    WriteString(par.ABaseStyleName);
    WriteString('"');
  end else
    if sty > 0 then
    begin
      WriteString(' base=');
      WriteInteger(sty);
    end;

  // -------- FIX the NumberStyle reference to _RTF_ID -----------------------
  if par.AGet(WPAT_NumberSTYLE, a) then
  begin
    numsty := RTFProps.NumberStyles.GetStyle(a);
    if (numsty <> nil) and (numsty.ID <> a) then
      par.ASet(WPAT_NumberSTYLE, numsty._RTF_ID);
  end;
  // -------------------------------------------------------------------------


  if par.ParagraphType in [wpIsReportGroup, wpIsReportHeaderBand,
    wpIsReportDataBand, wpIsReportFooterBand] then
  begin
    band := par.ParagraphObjFind(WPPAROBJ_WPBAND);
    if par.AGet(WPAT_BANDPAR_STR, i) then bands := par.ANumberToString(i)
    else bands := '';
    if band <> nil then
    begin
      bands2 := band.AsString;
      if bands2 <> bands then
        par.ASet(WPAT_BANDPAR_STR, par.AStringToNumber(bands2));
{$IFDEF GROUPVAR}
      par.ASet(WPAT_BANDPAR_VAR, par.AStringToNumber(band.ExtraAsString));
{$ENDIF}
    end;
  end;


  // -------- WPSTYLE ----------------------------------------------------------
  s := par.AGetWPSS(false, true, true, false, FOptAppreviated);
  if s <> '' then
  begin
    if FOptAppreviated then
      WriteString(' wsty=[[')
    else WriteString(' wpsty=[[');
    WriteHTMLString(s);
    Result := WriteString(']]>');
  end else Result := WriteString('>');
end;

function TWPTOOLSWriter.WriteChar(aChar: Word): Boolean;
begin
  Result := WriteHTMLChar(WideChar(aChar));
end;

function TWPTOOLSWriter.WriteLevelEnd(par: TParagraph): Boolean;
begin
  if (par.ParagraphType in [wpIsXMLTopLevel, wpIsXMLSubLevel, wpIsReportGroup]) then
    Result := WriteString('</' + WPParagraphTypeNames[par.ParagraphType] + '>' + #13 + #10)
  else Result := TRUE;
end;

function TWPTOOLSWriter.WriteParagraphEnd(par: TParagraph;
  ParagraphType: TWPParagraphType; NeedNL: Boolean): Boolean;
begin
  if (par.ParagraphType in [wpIsXMLTopLevel, wpIsXMLSubLevel, wpIsReportGroup]) then Result := TRUE
  else
  begin
    WriteString('</');
    if paprIsTable in par.prop then
    begin
      if soWriteCellsAsParagraphs in FStoreOptions then
        WriteString('div')
      else if paprIsHeader in par.prop then
        WriteString('th')
      else
        WriteString('td');
    end
    else WriteString(WPParagraphTypeNames[ParagraphType]);
    Result := WriteString('>' + #13 + #10);
  end;
end;

function TWPTOOLSWriter.WriteObject(txtobj: TWPTextObj; par: TParagraph; posinpar: Integer): Boolean;
var mem: TMemoryStream;
  sty: TWPRTFStyleElement;
  // stynr: Integer;
  stylename: string;
  DontSave: Boolean;
  procedure WriteObjProps;
  var s: string;
  begin
    if txtobj.StyleName <> '' then
    begin
      WriteString(#32 + 'class="');
      WriteString(txtobj.StyleName);
      WriteString('"');
    end;

  { Saved as WPCSS!
    if txtobj.Params <> '' then
    begin
      WriteString(#32 + 'params="');
      WriteHTMLString(txtobj.Params);
      WriteString('"');
    end;

    if txtobj.Extra <> nil then
    begin
    WriteString(' extra="');
    WriteHTMLString(txtobj.Extra.Text);
    WriteString('"');
    end;  }

    if txtobj.Style <> nil then
    begin
      s := txtobj.Style.AGetWPSS(true, true, true);
      if s <> '' then
      begin
        WriteString(' style="');
        WriteHTMLString(s);
        WriteString('"');
      end;
    end;

    WriteString(' wpsty=[[');
    WriteHTMLString(txtobj.AGetWPSS(true));
    WriteString(']]');
  end;
var i: Integer;
begin
 { if (txtobj.ObjType = wpobjSPANStyle) then stylename := txtobj.Name
  else }
  if txtobj.ObjType = wpobjImage then
  begin
    if OptNoImages then
    begin
      Result := TRUE;
      exit;
    end;
    DontSave := FALSE;
    RTFDataCollection.PrepareImageforSaving(Self, txtobj, DontSave);
    if DontSave then
    begin
      Result := TRUE;
      exit;
    end;
  end;

  // Save the style definition which is used by Object
  stylename := txtobj.StyleName;
  if not OptNoStyles and not OptBaseText and (stylename <> '') then
  begin
    sty := RTFProps.ParStyles.GetStyle(stylename);
    SaveStyle(sty);
  end;

  // Now save the object itself
{$IFDEF WPPREMIUM}
  if (txtobj.ObjType = wpobjFootnote) and (txtobj.Source = '') then
  begin
    _rtfdataobj := RTFDataCollection.Find(wpIsFootnote, wpraOnAllPages, txtobj.Name);
    if _rtfdataobj <> nil then
    begin
      WriteString('<foot>'); // Standard Type
      PushBLOCK;
      WriteBody;
      PopBLOCK;
      Result := WriteString('</foot>');
    end else Result := FALSE;
    exit;
  end else
 { if (txtobj.ObjType = wpobjImage) and (txtobj.ObjRef<>nil) then
  begin
    _rtfdataobj := RTFDataCollection.Find(wpIsOwnerSelected, wpraNamed, txtobj.Name);
    if _rtfdataobj <> nil then
    begin
      FAllElements := TRUE;
      WriteElementStart(_rtfdataobj);
      PushBLOCK;
      WriteBody;
      PopBLOCK;
      Result := WriteElementEnd(_rtfdataobj);
      FAllElements := FALSE;
    end else Result := FALSE;
    // NO!!! exit;
  end else }
{$ENDIF}
    if (wpobjUsedPairwise in txtobj.Mode) and (wpobjIsOpening in txtobj.Mode) then
    begin
      Result := WriteString('<begin Tag=');
      WriteInteger(txtobj.Tag);
      WriteObjProps;
      FOpenObjects.Add(txtobj);
    end
    else if (wpobjUsedPairwise in txtobj.Mode) and (wpobjIsClosing in txtobj.Mode) then
    begin
      i := FOpenObjects.Count - 1;
      while (i >= 0) and (TWPTextObj(FOpenObjects[i]).Tag <> txtobj.Tag) do dec(i);
      if i >= 0 then
      begin
        FOpenObjects.Delete(i);
        Result := WriteString('<end Tag=');
        WriteInteger(txtobj.Tag);
      // Don't write props ...
      end else
      begin
        Result := TRUE; // DO NOT WRITE ORPHAN CLOSE
        exit;
      end;
    end
    else
    begin
      Result := WriteString('<txtobj');
      WriteObjProps
    end;

  // The character can be useful
  WriteString(' ch=');
  WriteInteger(Integer(par.CharItem[posinpar]));

  // Binary Object data
  if txtobj.ObjRef = nil then
    WriteString('/>' + #13 + #10) // No binary data
  else
    if txtobj.ObjRef <> nil then
    begin
      mem := TMemoryStream.Create;
      try
        txtobj.ObjRef.SaveVCL(mem, Self);
        begin
          WriteString(' data="wpvcl-binary"');
          WriteString(' type="' + txtobj.ObjRef.ClassName + '">');

      // -----------------------------------------------------------------------
      // Write the object data inside of a comment - so simple HTML index services
      // are able to ignore the data. When reading the data we accept all inbetween
      // the txtobj tags as base64 data until we find "-->".
      // -----------------------------------------------------------------------
      // This is the 'WPTools' binary format incl all properties
          WriteString(#13 + #10 + '<!--');
          if not WriteBase64Encoded(mem) then Result := FALSE;
          WriteString('-->' + #13 + #10);
      // -----------------------------------------------------------------------
        end;
        WriteString('</txtobj>');
      finally
        mem.Free;
      end;
    end;
end;

function TWPTOOLSWriter.PrepareCharAttr(CharAttrIndex: Cardinal): Integer;
var sty: Integer; aStyleSheet: Integer; s: string;
begin
{$IFDEF CLR}
  sty := FSavedCharStyles.IndexOf(IntPtr.Create(CharAttrIndex)) + 1;
{$ELSE}
  sty := FSavedCharStyles.IndexOf(Pointer(CharAttrIndex)) + 1;
{$ENDIF}
  if sty = 0 then
  begin
    FCharAttr.CharAttr := CharAttrIndex;
    if FCharAttr.AGet(WPAT_CharStyleSheet, aStyleSheet) then
    begin
{$IFDEF USE_CHARSTYLES}
      aStyleSheet := SaveStyle(RTFProps.CharStyles.GetStyle(aStyleSheet));
{$ELSE}
      aStyleSheet := SaveStyle(RTFProps.ParStyles.GetStyle(aStyleSheet));
{$ENDIF}
    end else aStyleSheet := 0;

{$IFDEF CLR}
    FSavedCharStyles.Add(IntPtr.Create(CharAttrIndex));
{$ELSE}
    FSavedCharStyles.Add(Pointer(CharAttrIndex));
{$ENDIF}
    sty := FSavedCharStyles.Count;
    WriteString('<cs nr=');
    WriteInteger(sty);

    if aStyleSheet > 0 then
    begin
      WriteString(' base=');
      WriteInteger(aStyleSheet);
    end;
    if OptNoafsProtected then FCharAttr.ExcludeStyle(afsProtected);
    s := FCharAttr.AGetWPSSNoCharSheets(FOptAppreviated);
    if s <> '' then
    begin
      if FOptAppreviated then
      begin
        WriteString(' wsty=[[');
        WriteHTMLString(s);
        WriteString(']]');
      end else
      begin
        WriteString(' wpsty=[[');
        WriteHTMLString(s);
        WriteString(']]');
      end;
    end;
    WriteString('/>');
  end;
  Result := sty;
end;

function TWPTOOLSWriter.UpdateCharAttr(CharAttrIndex: Cardinal): Boolean;
var sty: Integer;
begin
  sty := PrepareCharAttr(CharAttrIndex);
  WriteString('<c nr=');
  WriteInteger(sty);
  WriteString('/>');
  Result := TRUE;
end;

{ ----------------------------------------------------------------------------- }

class function TWPTOOLSReader.UseForFilterName(const Filtername: string): Boolean;
begin
  Result := inherited UseForFilterName(Filtername) or (CompareText(Filtername, 'WPT') = 0)
    or (CompareText(Filtername, 'WPTOOLS') = 0);
end;

class function TWPTOOLSReader.UseForContents(const First500Char: AnsiString): Boolean;
begin
  if Pos('<!WPTools_Format', First500Char) > 0 then Result := TRUE
  else Result := FALSE;
end;

procedure TWPTOOLSReader.SetOptions(optstr: string);
(* var i: Integer;
  aoptstr: string;  *)
begin
(* Read a property from format string:
   Example:
  i := Pos('-', optstr);
  if i > 0 then
  begin
    aoptstr := lowercase(Copy(optstr, i, Length(optstr) - i + 1)) + ',';
    if Pos('-ignorekeepn,', aoptstr) > 0 then
       FOptIgnoreKeepN := TRUE;
  end;   *)
  inherited SetOptions(optstr);
end;

function TWPTOOLSReader.Parse(datastream: TStream): TWPRTFDataBlock;
type
  TWPObjectMap = record
    LoadTag, IsTag: Integer;
    obj: TWPTextObj;
  end;
  TWPSectionMap = record
    id, loadid: Integer;
  end;
var s : string;
  Entity : AnsiString;
  ch, ch2, i, a, j, mode, section, aa: Integer;
  aTag: TWPCustomHTMLTag;
  Par: TParagraph;
  FSkipUntilENDElement: Boolean;
  FSkipUntilName: string;
  FLastMergeTag: Integer;
  ReadEntity, FReadParSty: Boolean;
  ParagraphType: TWPParagraphType;
  TextStyle: TWPTextStyle;
  TextStyleEle: TWPRTFStyleElement;
  aKind: TWPPagePropertyKind;
  //aRange: TWPPagePropertyRange;
  obj, currtxtobj: TWPTextObj;
  currtxtobj_data, currtxtobj_type, aName: string;
  base64: TMemoryStream;
  ReadBase64: Boolean;
  b: Byte;
  FObjectMap: array of TWPObjectMap;
  FSectionTranslate: array of TWPSectionMap;
  FObjectMapMax, FObjectMapCount: Integer;
  numsty : TWPRTFNumberingStyle;
  oldnumsty : TWPRTFStyleElement;
  sect: TWPRTFSectionProps;
begin
  Result := inherited Parse(datastream);
  Entity := '';
  FLastMergeTag := 0;
  SetLength(FCharAttrNr, 1000);
  SetLength(FParStyleNr, 1000);
  FObjectMapMax := 1000;
  SetLength(FObjectMap, 1000);
  FObjectMapCount := 0;
  SetLength(FSectionTranslate, 0);
  ReadEntity := FALSE;
  currtxtobj := nil;
  currtxtobj_data := '';
  currtxtobj_type := '';
  FSkipUntilENDElement := FALSE;
  FSkipUntilName := 'element';
  base64 := TMemoryStream.Create;
  ReadBase64 := FALSE;

  //V5.13.5 - protect fonts etc
  if (loIgnoreFontSize in FLoadOptions) or OptIgnoreFontSize then
    Attr.IgnoredAttr := Attr.IgnoredAttr or BitMask[WPAT_CHARFONTSIZE];
  if (loIgnoreFonts in FLoadOptions) or OptIgnoreFonts then
    Attr.IgnoredAttr := Attr.IgnoredAttr or BitMask[WPAT_CHARFONT];

  try
   // We select the body to ad the data
    SelectRTFData(wpIsBody, wpraIgnored, '');
    repeat
      ch := ReadChar;
      if ch <= 0 then break
      else
       //--------------------------- embedded binary data as Base64 ------------
        if ReadBase64 then
        begin
          // Inside thge Base64 element we expect "</" to end the stream abd
          // ignore any other characters which are not in the base64 alphabet,
          // such as NL, CR and the optional comment markers <!-- and -->
          if WPInBase64Alphabet[ch] then
          begin
            b := Byte(ch);
            base64.Write(b, 1);
          end
          else
            if ch = Integer('<') then
            begin
              ch := ReadChar;
              if ch = Integer('/') then
              begin
                ReadBase64 := FALSE;
                UnreadChar(2);
                // next round we will find the end tag and process 'base64'
              end else UnreadChar;
            end;
          continue;
        end else
      // Support entities without closing ";" ----------------------------------
          if ReadEntity then
          begin
            if (ch = Integer(';')) or (ch <= 32) then
            begin
              PrintAChar('&');
              for ch2 := 1 to Length(Entity) do
                PrintAChar(Entity[ch2]);
              ReadEntity := FALSE;
            end
            else
            begin
              Entity := Entity + AnsiChar(ch);
              ch2 := WPTranslateEntity(Entity); 
              if ch2 > 0 then
              begin
                PrintWideChar(ch2);
                Entity := '';
                ch := ReadChar;
                if ch <> Integer(';') then UnReadChar;
                ReadEntity := FALSE;
              end;
              continue;
            end;
          end;
      // -----------------------------------------------------------------------
      if not FSkipUntilENDElement and (ch = Integer('&')) then
      begin
        ch := ReadChar;
        if ch = Integer('#') then
        begin
          ch := ReadInteger;
          if ch > 0 then PrintWideChar(ch);
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
      else if ch = Integer('<') then
      begin
        aTag := TWPCustomHTMLTag.ReadCreate(Self);

        if FSkipUntilENDElement then
        begin
          if (aTag.Typ = wpXMLClosingTag) and
            (aTag.NameEqual(FSkipUntilName)) then
            FSkipUntilENDElement := FALSE
          else
          begin
            aTag.Free;
            continue;
          end;
        end;
        try
{$IFDEF WPDEBUG}
          if aTag.NameEqual('dix') then
          begin
            aTag.SetName('div');
          end;
{$ENDIF}


          if aTag.Typ = wpXMLClosedTag then
          begin
            if aTag.NameEqual('newsection') then //V5.12.5 - start a new section
            begin
              if (FCurrentParagraph = nil) or not FCurrentParagraph.Empty([], false) then
                NewParagraph;
              if not OptNoPageBreaks and
                 (aTag.ParamValue('pagebreak', 1) = 1) and
                (FCurrentParagraph.prev <> nil) then
                include(FCurrentParagraph.prop, paprNewPage);
              FCurrentSectionProps := FCurrentParagraph.StartNewSection;
              include(FCurrentParagraph.prop, paprCanRemoveInAppend);
            end
            else if not OptNoPageInfo and
              not FLoadBodyOnly and aTag.NameEqual('globalpageformat')
              and not (loIgnorePageSize in FLoadOptions)
              then
            begin
              if FCurrentSectionProps <> nil then
                FCurrentSectionProps.ASetWPSS(aTag.ParamString('wpcss'))
              else FRTFDataCollection.Header.ASetWPSS(aTag.ParamString('wpcss'));
            end
            else if not FClipboardOperation //V5.18.5
              and not OptNoDefaultFont and aTag.NameEqual('standardfont')
              then
            begin
              s := aTag.ParamString('wpcss');
              for i := 1 to Length(s) do if s[i] = #36 then
                begin
                 //V5.19.0 Repair wrongly written files (by WPTools 5.18) ------
                 // wpcss="CharFont:'Arial$;CharFontSize:';CharFontSize:'1100$;"
                  j := Length(s);
                  if (j > 2) and (s[j - 1] = '$') then
                  begin
                    while (j > i) and (s[j] <> ':') do dec(j);
                    if j > i then s := Copy(s, 1, i - 1) + '''' + ';CharFontSize:' + Copy(s, j + 2, Length(s) - j - 3);
                  end;
                  break;
                end;
              FRTFDataCollection.ANSITextAttr.ASetWPSS(s);
            end
            else
              if not FLoadBodyOnly and aTag.NameEqual('sectionpageformat')
                and not (loIgnorePageSize in FLoadOptions)
                and not OptNoPageInfo
                then
              begin
                sect := FRTFDataCollection.AddSectionProps;
                sect.ASetWPSS(aTag.ParamString('wpcss'));
                SetLength(FSectionTranslate, Length(FSectionTranslate) + 1);
                FSectionTranslate[Length(FSectionTranslate) - 1].id := sect.SectionID;
                FSectionTranslate[Length(FSectionTranslate) - 1].loadid := aTag.ParamValue('id', -1);
              end else
                if aTag.NameEqual('c') then
                begin
                  i := aTag.ParamValue('nr', 0);
                  if i < Length(FCharAttrNr) then
                    Attr.SetKnownCharAttr(FCharAttrNr[i]);
                end else
                  if aTag.NameEqual('hy') then
                    FLastWasHyphen := TRUE
                  else
                    if aTag.NameEqual('variable') then // Load Text Varaiable
                    begin
                      if not OptNoVariables
                        and not (loDontLoadRTFVariables in FLoadOptions)
                        and not OptDontAddRTFVariables
                        and not FClipboardOperation then
                        RTFDataCollection.RTFVariables.AddString(
                          aTag.ParamString('name', ''),
                          aTag.NormalizedParamString('text', ''),
                          false);
                    end else

                      if aTag.NameEqual('nstyle') then // Load Number Style
                      begin
                        i := aTag.ParamValue('id', 0);
                        if i > 0 then
                        begin
                          {$IFNDEF DONTMAPNUMBERS}
                          numsty := TWPRTFNumberingStyle(RTFProps.NumberStyles.Add());
                          {$ELSE}
                          numsty := TWPRTFNumberingStyle(RTFProps.NumberStyles._Add(i));
                          {$ENDIF}
                          numsty.Group := aTag.ParamValue('group', 0);
                          numsty.LevelInGroup := aTag.ParamValue('level', 0);
                          numsty.Name := aTag.NormalizedParamString('name', '');

                          s := aTag.NormalizedParamString('wsty', '');
                          if s <> '' then
                            numsty.TextStyle.ASetWPSS(s, false, true)
                          else
                          begin
                            s := aTag.NormalizedParamString('wpsty', '');
                            if s <> '' then
                              numsty.TextStyle.ASetWPSS(s, false, false);
                          end;
                          {$IFNDEF DONTMAPNUMBERS}
                          oldnumsty := RTFProps.NumberStyles.FindEqual( numsty );
                          if oldnumsty<>nil then
                          begin
                             AddNumMap(i,oldnumsty.ID);
                             numsty.Free;
                          end else AddNumMap(i,numsty.ID);
                          {$ENDIF}
                        end;
                      end
{$IFNDEF IGNORE_PSTYLE}
                      else if aTag.NameEqual('pstyle') and not OptOnlyBody then
                      begin
                        i := aTag.ParamValue('nr', 0);
                        if i >= Length(FParStyleNr) then
                          SetLength(FParStyleNr, i + 100);
                        aName := aTag.NormalizedParamString('name', '');
                        TextStyleEle := FRTFProps.ParStyles.FindStyle(aName);
                        if TextStyleEle <> nil then
                          TextStyle := TextStyleEle.TextStyle else TextStyle := nil;
                        // TextStyle := FRTFProps.ParStyles.FindTextStyle(aName);
                        FParStyleNr[i] := TextStyle;

                        if (TextStyleEle = nil) or
                          not (loDontOverwriteExistingStyles in FLoadOptions)
                          then
                        begin
                          if (TextStyleEle = nil) and not OptNoStyles and
                            not (loIgnoreUnknownStyles in FLoadOptions) and
                            not (loIgnoreStylesheet in FLoadOptions) then
                          begin
                            TextStyleEle := FRTFProps.ParStyles.Add(aName);
                            TextStyle := TextStyleEle.TextStyle; // FRTFProps.ParStyles.AddStyle(aName);
                            FParStyleNr[i] := TextStyle;
                          end;

                          if (TextStyleEle <> nil) and
                            not OptNoStyles and
                            not (loIgnoreStylesheet in FLoadOptions) then
                          begin
                            s := aTag.NormalizedParamString('wsty', '');
                            if s <> '' then
                              TextStyle.ASetWPSS(s, false, true)
                            else
                            begin
                              s := aTag.NormalizedParamString('wpsty', '');
                              if s <> '' then
                                TextStyle.ASetWPSS(s, false, false);
                            end;

                            if TextStyle.AGet(WPAT_NumberSTYLE, a) then
                                  TextStyle.ASet(WPAT_NumberSTYLE, NumMap(a));   

                            i := aTag.ParamValue('base', 0);
                            if i < Length(FParStyleNr) then
                              TextStyle.ABaseStyle := FParStyleNr[i];
                            i := aTag.ParamValue('default', 0);
                            if i > 0 then
                              TextStyleEle.IsDefault := TRUE;
                            s := aTag.NormalizedParamString('next', ''); //V5.20.7
                            if s <> '' then //V5.20.7
                              TextStyleEle.NextStyleName := s; //V5.20.7

                          end;

                        end;
                      end
{$ENDIF}
                      else
                        if aTag.NameEqual('cs') then
                        begin
                          s := aTag.NormalizedParamString('wsty', '');
                          if s <> '' then
                            Attr.ASetWPSS(s, false, true)
                          else
                          begin
                            s := aTag.NormalizedParamString('wpsty', '');
                            if s <> '' then
                              Attr.ASetWPSS(s, false, false)
                            else Attr.Clear; //V5.17.3
                          end;
                            // Base Style --------------------------------------
                          i := aTag.ParamValue('base', 0);
                          if (i > 0) and (i < Length(FParStyleNr)) then
                          begin
                            Attr.SetCharStyleSheet(FParStyleNr[i]);
                          end;
                            // ------------- cs number -------------------------
                          i := aTag.ParamValue('nr', 0);
                          if i >= Length(FCharAttrNr) then
                            SetLength(FCharAttrNr, i + 512);
                          FCharAttrNr[i] := Attr.CharAttr;
                        end
                        else
                          if aTag.NameEqual('begin') then // Just a single object, no data
                          begin
                            obj := TWPTextObj.Create;
                            try
                              obj.ASetWPSS(aTag.NormalizedParamString('wpsty', ''));
                              PrintAChar(AnsiChar(aTag.ParamValue('ch', Integer(TextObjCode))));
                              FCurrentParagraph.ObjectIndex[FCurrentParagraph.CharCount - 1] :=
                                obj.Attach(FCurrentParagraph);
                              obj.Mode := obj.Mode + [wpobjUsedPairwise, wpobjIsOpening];


{$IFDEF DONT_LOAD_STYLES_FOR_OBJECTS}
                              if obj.ObjType = wpobjSPANStyle then
{$ENDIF}
                              begin
                                obj.StyleName := aTag.ParamString('class', '');

                                s := aTag.NormalizedParamString('style', '');
                                if s <> '' then
                                begin
                                  obj.MakeStyle(true);
                                  obj.Style.ASetWPSS(s, false, false);
                                end;

                                s := aTag.NormalizedParamString('wpsty', '');
                                if s <> '' then
                                begin
                                  obj.MakeStyle(true);
                                  obj.Style.ASetWPSS(s, false, true);
                                end;
                              end;

                              // 'params' has priority over 'wpsty' !
                              if aTag.HasParam('params') then
                                obj.Params := aTag.NormalizedParamString('params', '');

                              aa := aTag.ParamValue('Tag');
                              if FObjectMapCount = FObjectMapMax then
                              begin
                                inc(FObjectMapMax, 1000);
                                SetLength(FObjectMap, FObjectMapMax);
                              end;
                              obj.NewTag;
                              FObjectMap[FObjectMapCount].LoadTag := aa;
                              FObjectMap[FObjectMapCount].IsTag := obj.Tag;
                              FObjectMap[FObjectMapCount].obj := obj;
                              inc(FObjectMapCount);
                            except
                              obj.Free;
                            end;
                          end
                          else if aTag.NameEqual('end') then // Just a single object, no data
                          begin
                            aa := aTag.ParamValue('Tag');
                            i := FObjectMapCount - 1;
                            while i >= 0 do
                            begin
                              if FObjectMap[i].LoadTag = aa then
                              begin
                                obj := TWPTextObj.Create;
                                if FCurrentParagraph = nil then
                                begin
                                  NewParagraph;
                                end;
                                PrintAChar(AnsiChar(aTag.ParamValue('ch', Integer(TextObjCode))));
                                FCurrentParagraph.ObjectIndex[FCurrentParagraph.CharCount - 1] :=
                                  obj.Attach(FCurrentParagraph);
                                obj.SetTag(FObjectMap[i].IsTag);
                            // Only set a few properties
                                obj._SetObjType(FObjectMap[i].Obj.ObjType);
                                obj.Mode := FObjectMap[i].Obj.Mode
                                  - [wpobjIsOpening] + [wpobjUsedPairwise, wpobjIsClosing];
                                obj.Name := FObjectMap[i].Obj.Name;
                                obj.Source := FObjectMap[i].Obj.Source;
                                if i=FObjectMapCount - 1 then //V5.40
                                   dec(FObjectMapCount);
                                break;
                              end;
                              dec(i);
                            end;


                          end
                          else if aTag.NameEqual('txtobj') and (FCurrentParagraph <> nil) then // Just a single object, no data
                          begin
                            obj := TWPTextObj.Create;
                            try
                              s := aTag.NormalizedParamString('wpsty', '');
                              obj.ASetWPSS(s);
                              PrintAChar(AnsiChar(aTag.ParamValue('ch', Integer(TextObjCode))));
                              FCurrentParagraph.ObjectIndex[FCurrentParagraph.CharCount - 1] :=
                                obj.Attach(FCurrentParagraph);


                              s := aTag.NormalizedParamString('class', '');
                              obj.StyleName := s;

                              s := aTag.NormalizedParamString('style', '');
                              if s <> '' then
                              begin
                                obj.MakeStyle(true);
                                obj.Style.ASetWPSS(s);
                              end;

                              s := aTag.NormalizedParamString('extra', '');
                              if s <> '' then
                              begin
                                obj.MakeExtra(true);
                                obj.Extra.Text := s;
                              end;

                    // Handle Opening/Closing !
                              if (wpobjUsedPairwise in obj.Mode) then
                              begin
                                aa := aTag.ParamValue('Tag');
                                if aa > 0 then
                                begin
                                  if wpobjIsOpening in obj.Mode then
                                  begin
                                    if FObjectMapCount = FObjectMapMax then
                                    begin
                                      inc(FObjectMapMax, 1000);
                                      SetLength(FObjectMap, FObjectMapMax);
                                    end;
                                    obj.NewTag;
                                    FObjectMap[FObjectMapCount].LoadTag := aa;
                                    FObjectMap[FObjectMapCount].IsTag := obj.Tag;
                                  end else
                                    if wpobjIsClosing in obj.Mode then
                                    begin
                                      i := FObjectMapCount - 1;
                                      while i >= 0 do
                                      begin
                                        if FObjectMap[i].LoadTag = aa then
                                        begin
                                          obj.SetTag(FObjectMap[i].IsTag);
                                          break;
                                        end;
                                        dec(i);
                                      end;
                                    end;
                                end;
                              end;
                            except
                              obj.Free;
                            end;
                          end;
          end
          else if aTag.Typ = wpXMLOpeningTag then
          begin
            FReadParSty := FALSE;
            if aTag.NameEqual('element') then
            begin
              section := aTag.ParamValue('section', 0);
              s := aTag.ParamString('kind', '');
              aKind := Low(TWPPagePropertyKind);
              while aKind < High(TWPPagePropertyKind) do
              begin
                if CompareText(WPPagePropertyKinds[aKind], s) = 0 then break;
                inc(aKind);
              end;
              // Skip header and footer
              if (FLoadBodyOnly or
                (loIgnoreHeaderFooter in FLoadOptions) or
                OptOnlyBody) and
                ((aKind = wpIsHeader) or (aKind = wpIsFooter)) then
              begin
                FSkipUntilENDElement := TRUE;
                FSkipUntilName := 'element';
              end else // Select the element
              begin
                if not ProcessElement(aTag, aKind, section) then
                  ShowMessage('Wrong parameters for <Element>');

             { s := aTag.ParamString('range', '');
                aRange := High(TWPPagePropertyRange);
                while aRange > Low(TWPPagePropertyRange) do
                begin
                  if CompareText(WPPagePropertyRanges[aRange], s) = 0 then break;
                  dec(aRange);
                end;
                if (CompareText(WPPagePropertyRanges[aRange], s) <> 0) then
                begin
                  ShowMessage('Wrong parameters for <Element>');
                  aRange := wpraIgnored;
                end;

                if (FCurrentSectionProps <> nil) and
                  (FCurrentSectionProps.SectionID > 0) then
                begin
                  SelectRTFData(FRTFDataCollection.Append(aKind, aRange, aTag.NormalizedParamString('name', '')));
                  FWorkRTFData.UsedForSectionID := FCurrentSectionProps.SectionID;
                end
                else if section <> 0 then
                begin
                  FWorkRTFData := FRTFDataCollection.Append(aKind, aRange, aTag.NormalizedParamString('name', ''));
                  FCurrentParagraph := nil;
                  FParLevel := 0;
                end else
                  SelectRTFData(aKind, aRange, aTag.NormalizedParamString('name', ''));

                if aTag.ParamValue('readonly', 0) <> 0 then
                  FWorkRTFData.Readonly := TRUE;  }

                for i := 0 to Length(FSectionTranslate) - 1 do
                  if FSectionTranslate[i].loadid = section then
                  begin
                    FWorkRTFData.UsedForSectionID := FSectionTranslate[i].id;
                    break;
                  end;
              end;
            end
{$IFDEF WPPREMIUM}
            else if aTag.NameEqual('foot') then
            begin
              obj := PrintTextObj(wpobjFootnote, '', '', false, false, false);
              obj.ASetWPSS(aTag.NormalizedParamString('wpsty', ''));
              obj.Name := RTFDataCollection.UniqueName(wpIsFootnote, 'FOOT_');
              FWorkRTFData := FRTFDataCollection.Append(wpIsFootnote, wpraOnAllPages, obj.Name);
              FCurrentParagraph := nil;
              FParLevel := 0;
            end
{$ELSE}
            else if aTag.NameEqual('foot') then
            begin
              FSkipUntilENDElement := TRUE;
              FSkipUntilName := 'foot';
            end
{$ENDIF}
            else if aTag.NameEqual('th') then
            begin
              NewChildParagraph;
              FCurrentParagraph._DefaultHeight := 10;
              include(FCurrentParagraph.prop, paprIsTable);
              include(FCurrentParagraph.prop, paprIsHeader);
              FReadParSty := TRUE;
            end
            else if aTag.NameEqual('td') then
            begin
                // If there is a TD outside of TR!!! - keep document usable!----
              if (FCurrentParagraph = nil) or
                (FCurrentParagraph.ParagraphType <> wpIsTableRow) then
              begin
                if (FCurrentParagraph.ParentRow <> nil) then
                begin
                  FCurrentParagraph := FCurrentParagraph.ParentRow;
                  RTFDataCollection.StatusMsg(WPST_Loading, 'WPTOOLS READER: </TD> missing');
                end else
                begin
                  RTFDataCollection.StatusMsg(WPST_Loading, 'WPTOOLS READER: <TR> missing');
                  if FCurrentParagraph = nil then
                  begin
                    NewParagraph;
                    FCurrentParagraph.ParagraphType := wpIsTable;
                  end;
                  if FCurrentParagraph.ParagraphType = wpIsTable then
                  begin
                    NewChildParagraph;
                    FCurrentParagraph.ParagraphType := wpIsTableRow;
                  end;
                end;
              end;
                // -------------------------------------------------------------
              NewChildParagraph;
              FCurrentParagraph._DefaultHeight := 10;
              include(FCurrentParagraph.prop, paprIsTable);
              FReadParSty := TRUE;
            end
            else if aTag.NameEqual('mergefield') then
            begin
                 // This tag is only imported, never saved
              FLastMergeTag := PrintTextObj(
                wpobjMergeField,
                aTag.ParamString('name', ''),
                aTag.ParamString('command', ''),
                true, false, false).NewTag;
            end
            else if aTag.NameEqual('txtobj') then // Just a single object, no data
            begin
              currtxtobj := TWPTextObj.Create;
              try
                currtxtobj.ASetWPSS(aTag.NormalizedParamString('wpsty', ''));
                PrintAChar(AnsiChar(aTag.ParamValue('anchor', Integer(TextObjCode))));
                FCurrentParagraph.ObjectIndex[FCurrentParagraph.CharCount - 1] :=
                  currtxtobj.Attach(FCurrentParagraph);
                currtxtobj_data := aTag.ParamString('data', '');
                currtxtobj_type := aTag.ParamString('type', '');
                base64.Clear;
                if Pos('-embedded', currtxtobj_data) > 0 then
                begin
                  ReadStream(base64, StrToIntDef(aTag.ParamString('size'), 0), false);
                  ReadBase64 := FALSE;
                end else ReadBase64 := TRUE;
              except
                FreeAndNil(currtxtobj);
              end;
            end
            else if aTag.NameEqual('variable') then // Load Stream Variable
            begin
                 //TODO
            end
            else // --------------------- any other tag ----------------------
              for ParagraphType := Low(TWPParagraphType) to High(TWPParagraphType) do
                if aTag.NameEqual(WPParagraphTypeNames[ParagraphType]) then
                begin
                  // Loads a new paragraph
                  NewChildParagraph;
                  if FCurrentParagraph <> nil then
                  begin
                    FCurrentParagraph._DefaultHeight := 10;
                    FCurrentParagraph.ParagraphType := ParagraphType;
                  end;
                  FReadParSty := TRUE;
                  break;
                end;

            if FReadParSty and (FCurrentParagraph <> nil) then
            begin
              Attr.Clear;

              // Load default CharAttr for par ---------------------------------
              i := aTag.ParamValue('cs', 0);
              if i <> 0 then
              begin
                if i < Length(FCharAttrNr) then
                  FCurrentParagraph.LoadedCharAttr := FCharAttrNr[i];
              end;

              // Read Important Paragraph Props - the other are auto created
              mode := aTag.ParamValue('mode', 0);
              if (mode and 1) <> 0 then include(FCurrentParagraph.prop, paprIsPositioned);
              if (mode and 2) <> 0 then include(FCurrentParagraph.prop, paprColMerge);
              if (mode and 4) <> 0 then include(FCurrentParagraph.prop, paprRowMerge);
              if (mode and 8) <> 0 then include(FCurrentParagraph.prop, paprIsHeader);
              if (mode and 16) <> 0 then include(FCurrentParagraph.prop, paprIsFooter);
              if (mode and 32) <> 0 then include(FCurrentParagraph.prop, paprReadFromHTML);
              if not OptNoPageBreaks and ((mode and 64) <> 0) then include(FCurrentParagraph.prop, paprNewPage);
              if (mode and 128) <> 0 then include(FCurrentParagraph.prop, paprPagenrRestart);
              if (mode and 256) <> 0 then include(FCurrentParagraph.prop, paprInActive);
              if (mode and 512) <> 0 then include(FCurrentParagraph.prop, paprIsCollapsed);
              if (mode and 1024) <> 0 then include(FCurrentParagraph.prop, paprRightToLeft);
              if (mode and 2048)<>0 then include(FCurrentParagraph.prop, paprNewColumn);
              if (mode and 4096)<>0 then include(FCurrentParagraph.prop, paprHidden);

              // ----- SECTION ID ----------------------------------------------------------
              section := aTag.ParamValue('section', -1);
              if section >= 0 then
              begin
                for i := 0 to Length(FSectionTranslate) - 1 do
                  if FSectionTranslate[i].loadid = section then
                  begin
                    include(FCurrentParagraph.prop, paprNewSection);
                    FCurrentParagraph.SectionID := FSectionTranslate[i].id;
                    break;
                  end;
              end;

              // Read WPCSS
              s := aTag.NormalizedParamString('wsty', '');
             // FCurrentParagraph.AClear; 
              if s <> '' then
                FCurrentParagraph.ASetWPSS(s, false, true)
              else
              begin
                s := aTag.NormalizedParamString('wpsty', '');
                if s <> '' then
                  FCurrentParagraph.ASetWPSS(s, false, false);
              end;

              if FCurrentParagraph.AGet(WPAT_NumberSTYLE, a) then
                 FCurrentParagraph.ASet(WPAT_NumberSTYLE, NumMap(a));


              // Remove some unwanted flags: -----------------------------------
              if OptIgnoreKeepN then
                FCurrentParagraph.ADel(WPAT_ParKeepN);

              // ---------------------------------------------------------------

              if not OptNoStyles and not OptBaseText then
              begin
                i := aTag.ParamValue('base', 0);
                if i < Length(FParStyleNr) then
                  FCurrentParagraph.ABaseStyle := FParStyleNr[i];
              end;

              FCurrentParagraph.Name := aTag.ParamString('name', '');

              aName := aTag.ParamString('class', '');
              if aName <> '' then
                FCurrentParagraph.ABaseStyleName := aName;

            end;
          end else
            if aTag.Typ = wpXMLClosingTag then //+++++++++++++++++++++++++++++++++++++++++++ CLOSE
            begin

              if aTag.NameEqual('table') then
              begin
                if (FCurrentParagraph <> nil) and
                  (FCurrentParagraph.ParagraphType <> wpIsTable) then
                begin
                  par := FCurrentParagraph;
                  FCurrentParagraph := FCurrentParagraph.ParentTable;
                  if (par.ParagraphType = wpIsTableRow) and
                    (par.ChildPar = nil) then par.DeleteParagraph; // Empty Row !!
                end;
              end;

              if aTag.NameEqual('td') then
              begin
                if FCurrentParagraph <> nil then
                begin
                  Par := FCurrentParagraph.ParentRow;
                  if par <> nil then
                    FCurrentParagraph := par
                  else
                  begin
                    //V5.17: we are not in a table cell!
                    RTFDataCollection.StatusMsg(WPST_Loading, 'WPTOOLS READER: <TD> missing');
                    // FCurrentParagraph := FCurrentParagraph.ParentPar;
                  end;
                end;
              end
              else if aTag.NameEqual('mergefield') then
              begin
                 // This tag is only imported, never saved
                PrintTextObj(
                  wpobjMergeField,
                  '',
                  '',
                  true, true, false).SetTag(FLastMergeTag);
                FLastMergeTag := 0;
              end
              // Close the object data -----------------------------------------
              else if aTag.NameEqual('txtobj') then
              begin
                if currtxtobj <> nil then
                begin
                  if CompareText(Copy(currtxtobj_data, 1, 12), 'wpvcl-binary') = 0 then
                  begin
                    if OptNoImages then
                    begin
                      currtxtobj.Free;
                      FCurrentParagraph.DeleteMarkedChar;
                    end else
                    begin
                      if Pos('embedded', currtxtobj_data) > 0 then currtxtobj.LoadVCLBinary(currtxtobj_type, base64)
                      else currtxtobj.LoadVCLBase64(currtxtobj_type, base64);
                      if (currtxtobj.ObjRef <> nil) and (currtxtobj.ObjRef.StreamName <> '') then
                      begin
                        RTFDataCollection.RequestHTTPImage(Self, FLoadPath, currtxtobj.ObjRef.StreamName, currtxtobj);
                      end;
                    end;
                  end;
                  base64.Clear;
                  currtxtobj := nil;
                end;
              end
              else if aTag.NameEqual('variable') then // Load Stream Variable
              begin
                 //TODO
              end
              else // Close any other tag --------------------------------------
              begin
                for ParagraphType := Low(TWPParagraphType) to High(TWPParagraphType) do
                  if aTag.NameEqual(WPParagraphTypeNames[ParagraphType]) then
                  begin
                    if FCurrentParagraph <> nil then
                      FCurrentParagraph := FCurrentParagraph.ParentPar;
                  end
                  else if aTag.NameEqual('element') then
                  begin
                    SelectRTFData(wpIsBody, wpraOnAllPages, '');
                  end
                  else if aTag.NameEqual('foot') then
                  begin
                    SelectRTFData(wpIsBody, wpraOnAllPages, '');
                    FCurrentParagraph := FWorkRTFData.LastPar.LastInnerChild;
                  end;
              end;
            end;
        finally
          aTag.Free;
        end;
      end else if not FSkipUntilENDElement and (FCurrentParagraph <> nil) and (ch >= 32) then
      begin
        PrintAChar(AnsiChar(ch));
      end;
    until false;
    ResetReadBuffer;
  finally
    FCharAttrNr := nil;
    FParStyleNr := nil;
    FObjectMap := nil;
    FSectionTranslate := nil;
    base64.Free;
  end;
end;

initialization

  if GlobalWPToolsCustomEnviroment <> nil then
  begin
    GlobalWPToolsCustomEnviroment.RegisterReader([TWPTOOLSReader]);
    GlobalWPToolsCustomEnviroment.RegisterWriter([TWPTOOLSWriter]);
  end;

{$ENDIF}

end.

