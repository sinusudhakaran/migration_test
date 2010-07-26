unit WPPDFWP;
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// wPDF PDF Support Component. Utilized PDF Engine DLL
// ------------------------------------------------------------------
// Version 2.45, 2004 Copyright (C) by wpCubed GmbH, Munich
// You may integrate this component into your EXE but never distribute
// the licensecode, sourcecode or the object files.
// ------------------------------------------------------------------
// Info: www.wptools.de
// 8.7.2004: Added Support for WPTools 5. (todo: links, outlines)
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

{ -------------------------------------------------------------------
    If you use WPTools Version 3 please make sure symbol WPV4 is
    NOT DEFINED in the project or in the file "WPINC.INC"
  ------------------------------------------------------------------- }

{$I WPINC.INC}
{$I wpdf_inc.inc}
{$DEFINE WPTOOLS_411d}
{.$DEFINE WPDFJPEG}
{$DEFINE CONVERTTOMETA} // to embed metafile as vectors. MUST BE ACTIVE

{$S+}
{$D+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
{$IFDEF WPTools5}
  WPCTRMemo, WPRTEDefs, WPRTEPaint
{$ELSE}
  WPrtfTXT, WPrtfIO, WPWinCtr, WPDefs, WPrtfPA, WPObj
{$IFDEF WPDFJPEG}, wpJpgObj{$ENDIF}
{$ENDIF}
{$IFDEF WPDF_SOURCE}, WPPDFR1_src{$ELSE}, WPPDFR1{$ENDIF}
{$IFNDEF INTWPSWITCH}, WPT2PDFDLL{$ENDIF};

{.$D-}
{.$S-}
{.$DEFINE PARLIN}


type
  TWPPDFPrintPageEvent = procedure(Sender: TObject; Number, FromPos, Length: Integer
{$IFDEF PARLIN}
    ; par: PTParagraph; lin: PTLine
{$ENDIF}
    ) of object;

  TWPPDFPrintObjectEvent = procedure(Sender: TWPCustomPDFExport;
    Memo: {$IFDEF WPTOOLS5}TWPRTFEnginePaint{$ELSE}TWPRTFTextPaint{$ENDIF};
    PObj: {$IFDEF WPTOOLS5}TWPTextObj{$ELSE}PTTextObj{$ENDIF};
    Obj: TWPObject;
    R: TRect;
    var Abort: Boolean) of object;

  TWPPDFPrintOutlineEvent = procedure(Sender: TWPCustomPDFExport;
    Memo: {$IFDEF WPTOOLS5}TWPRTFEnginePaint{$ELSE}TWPRTFTextPaint{$ENDIF};
    par: {$IFDEF WPTOOLS5}TParagraph{$ELSE}PTParagraph{$ENDIF};
{$IFDEF WPTOOLS5}posinpar: Integer{$ELSE}lin: PTLine{$ENDIF};
    var Caption: string;
    var level: Integer;
    var Abort: Boolean) of object;

  TWPPDFPrintLineEvent = procedure(
    par: {$IFDEF WPTOOLS5}TParagraph{$ELSE}PTParagraph{$ENDIF};
{$IFDEF WPTOOLS5}posinpar: Integer{$ELSE}lin: PTLine{$ENDIF};
    var NewBookmark, NewOutline: string; var outlinelevel: Integer);

  TWPPDFExport = class(TWPCustomPDFExport)
  private
    FSource: TWPCustomRtfEdit;
    FOutlineNr : array[0..10] of Integer;
    FLastOutlineNr : Integer;
 {$IFNDEF WPTOOLS5}
    Flastlevel: Integer;
 {$ENDIF}
    FReplaceBullets: Boolean;
    FOnBeforePrintPage: TWPPDFPrintPageEvent;
    FOnAfterPrintPage: TWPPDFPrintPageEvent;
    FOnPrintObject: TWPPDFPrintObjectEvent;
    FOnPrintOutline: TWPPDFPrintOutlineEvent;
    FAutoOutlineLevels: Boolean; // Order I) 1) a)
    FConvertMetafileToBitmaps: Boolean;
  protected
    procedure PreparePage(pageno: Integer; var init: TWPPDF_InitRec; ResX, ResY: Integer); override;
  public
{$IFNDEF T2H}
    procedure BeginDoc; override;
    procedure EndDoc; override;
{$ENDIF}
    procedure Print;
    procedure Execute;
    procedure PrintPages(f, t: Integer);
    property AutoOutlineLevels: Boolean read FAutoOutlineLevels write FAutoOutlineLevels;
  published
    property Source: TWPCustomRtfEdit read FSource write FSource;
    property OnBeforePrintPage: TWPPDFPrintPageEvent read FOnBeforePrintPage write FOnBeforePrintPage;
    property OnAfterPrintPage: TWPPDFPrintPageEvent read FOnAfterPrintPage write FOnAfterPrintPage;
    property OnPrintObject: TWPPDFPrintObjectEvent read FOnPrintObject write FOnPrintObject;
    property OnPrintOutline: TWPPDFPrintOutlineEvent read FOnPrintOutline write FOnPrintOutline;
{$IFNDEF T2H}
    property Filename;
    property EncodeStreamMethod;
    property ReplaceBullets: Boolean read FReplaceBullets write FReplaceBullets default FALSE;
    property ConvertMetafileToBitmaps: Boolean read FConvertMetafileToBitmaps write FConvertMetafileToBitmaps default FALSE;
    property CompressStreamMethod;
    property ConvertJPEGData;
    property Info;
    property CreateThumbnails;
    property CreateOutlines;
    property ExcludedFonts;
    property BeforeBeginDoc;
    property PageMode;
    property FontMode;
    property Encryption;
    property UserPassword;
    property OwnerPassword;
    property InMemoryMode;
    property ExtraMessages;
    property HeaderFooterColor;
    property InputfileMode;
    property InputFile;
    property OnUpdateGauge;
    property OnError;
{$ENDIF}
  end;

var
  WPDFOnPrintLine: TWPPDFPrintLineEvent;
procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('wPDF', [TWPPDFExport]);
end;


procedure TWPPDFExport.BeginDoc;
begin
  FSizeAttr := SizeOf(TAttr);
  FSizeParagraph := SizeOf(TParagraph);
  FSizeLine := SizeOf(TLine);
  inherited BeginDoc;
end;

procedure TWPPDFExport.EndDoc;
begin
  inherited EndDoc;
  if FSource <> nil then FSource.Invalidate;
end;

procedure TWPPDFExport.Print;
begin
  PrintPages(0, MaxInt);
end;

procedure TWPPDFExport.Execute;
begin
  PrintPages(0, MaxInt);
end;

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// CODE FOR WPTOOLS 5
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
{$IFDEF WPTOOLS5}

procedure TWPPDFExport.PrintPages(f, t: Integer);
var i, w, j, aPrevious, aParent, o, o2, h, FromPos, Length: Integer;
  usewater: string;
  list : TWPParagraphPosList;
  par : TParagraph;
  xres, yres : Integer;
begin
  if (FSource = nil) then
    raise PDFException.Create('No text source was specified!');
  begin
    usewater := '';
    if not FPrinting then
    begin
      BeginDoc;
      for i:=0 to High(FOutlineNr)-1 do FOutlineNr[i] := 0;
      FLastOutlineNr := 0;
      if FLastError = 0 then
      try
        PrintPages(f, t);
      finally
        EndDoc;
      end;
    end
    else if {$IFNDEF WPDF_SOURCE}(pdf_env <> nil) and {$ENDIF}(FPrinting = TRUE) then
      try
        if f < 0 then f := 0;
        i := FSource.PageCount;
        if t >= i then t := i - 1;
        if t < 0 then t := 0;
        for i := f to t do
        begin
          if FAbort then break;
          usewater := PrepareWatermark(FLastWidth, FLastHeight, Fpage_xres, Fpage_yres);
          FStartPageAtOnce := FALSE;
          FKeepInitValues := FALSE; // TRUE;

          // V2.60 - new way to read page size
          w := MulDiv(FSource.Memo._PaintPages[i].WidthTw,WPScreenPixelsPerInch,1440);
          h := MulDiv(FSource.Memo._PaintPages[i].HeightTw,WPScreenPixelsPerInch,1440);
          if (w=0) or (h=0) then
          begin
           w := Round( FSource.Memo.PaintPageWidth[i] / FSource.Memo.CurrentZooming );
           h := Round( FSource.Memo.PaintPageHeight[i] / FSource.Memo.CurrentZooming );
          end;
          xres := FSource.Memo.RTFData.RTFProps.FFontXPixelsPerInch;
          yres := FSource.Memo.RTFData.RTFProps.FFontYPixelsPerInch;
          StartPage(
            MulDiv(w, xres, WPScreenPixelsPerInch),
            MulDiv(h, yres, WPScreenPixelsPerInch),
            xres, yres, 0);

         // StartPage( w, h, WPScreenPixelsPerInch, WPScreenPixelsPerInch, 0 );
       
          try
            if assigned(FOnBeforePrintPage) then
            begin
              FromPos := 0; //TODO
              Length := 0; //TODO
              FOnBeforePrintPage(Self, i, FromPos, Length
{$IFDEF PARLIN}
                , nil, 0
{$ENDIF}
                );
              CloseCanvas;
              InitDC;
            end;

            if FCreateOutlines then
            begin
               list := TWPParagraphPosList.Create;
               try
                  FSource.Memo.ParagraphsOnPage(i,list);
                  for j:=0 to list.Count-1 do
                  begin
                     par :=  list[j];
                     if par.AGetInherited(WPAT_ParIsOutline,o) and (o<>0) then
                     begin
                       // Optionally: - use the number level to indent!
                       if (o<2) and par.AGetInherited(WPAT_NumberLevel, o2) and (o2>0) then
                          o := o2;


                        // Limited to 10 outline levels
                        if o>10 then o:=10;

                        // Create sub levels
                        if o>FLastOutlineNr then
                        begin
                          aParent := FOutlineNr[FLastOutlineNr];
                          // Fill with empty branches
                          while FLastOutlineNr<o-1 do
                          begin
                            inc(FLastOutlineNr);
                            aParent := SetOutlineXY('',
                              MulDiv( FSource.Header.LeftMargin, 72, 1440),
                              MulDiv( list.Y[j], 72, 1440), 0, aParent);
                          end;
                          FLastOutlineNr := o;
                          aPrevious := 0;
                       end else
                       begin
                         // Append to last branch
                         aParent := 0;
                         FLastOutlineNr := o;
                         aPrevious := FOutlineNr[FLastOutlineNr];   
                       end;

                       FOutlineNr[FLastOutlineNr] :=
                        SetOutlineXY(par.GetText(false,true),
                           MulDiv( FSource.Header.LeftMargin, 72, 1440),
                           MulDiv( list.Y[j], 72, 1440),
                           aPrevious, aParent
                           );

                     end;
                  end;
               finally
                  list.Free;
               end;
            end;   

         // Use 0 as w and h to let the function calculate the width and height
         // Note: "wppInPaintForwPDF" defined since WPTools 5.10.5
         // replace it with [] if unknown!
           FSource.Memo.PaintRTFPage(i, 0, 0, 0, 0, Canvas, [wppInPaintForwPDF],
              xres, yres ,
              -1, -1,
              [wpNoViewPortAPI]
             );

            if assigned(FOnAfterPrintPage) then
            begin
              InitDC;
              FromPos := 0; //TODO
              Length := 0; //TODO
              FOnAfterPrintPage(Self, i, FromPos, Length
{$IFDEF PARLIN}
                , nil, 0
{$ENDIF});
            end;
            if usewater <> '' then UseWatermark(usewater);
            if assigned(FOnUpdateGauge) and (FInternPageCount > 0) then
              FOnUpdateGauge(Self, MulDiv(FInternPageNumber, 100, FInternPageCount));
          finally
            EndPage;
          end;
        end;
      finally

      end;
    end;
end;


procedure TWPPDFExport.PreparePage(pageno: Integer; var init: TWPPDF_InitRec; ResX, ResY: Integer);
var
{$IFNDEF WPTOOLS5}
  par: PTParagraph;
  lin: PTLine;
{$ENDIF}
  r: Integer;
begin
  inherited PreparePage(pageno, init, ResX, ResY);
  if FSource <> nil then
  begin
    if ResX = 0 then ResX := 72;
    if ResY = 0 then ResY := 72;
    r := 1440;
    init.pagew := MulDiv(FSource.Header._Layout.paperw, ResX, r);
    init.pageh := MulDiv(FSource.Header._Layout.paperh, ResY, r);
    init.xres := ResX;
    init.yres := ResY;
    FLastWidth := init.pagew;
    FLastHeight := init.pageh;
    FStartPageAtOnce := TRUE;
    FInit := init;
  end
  else
    FStartPageAtOnce := FALSE;
end;

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// CODE FOR WPTOOLS 3 AND WPTOOLS 4
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


{$ELSE}
var
  gl_CreateOutlines, gl_AutoOutlineLevels: Boolean;
  gl_LastLevel0, gl_LastLevel1, gl_LastLevel2,
    gl_XResolution, gl_YResolution: Integer;
  gl_ReplaceBullets: Boolean;

function WPPDFDrawChar(Sender: TObject; p: PWPDrawTextEventPar;
  prect: PRect; str: PChar; Count: Integer; pwidth: PInteger): boolean; far;
var
  WPPDFExport: TWPPDFExport;
{$IFNDEF WPDF_SOURCE}
  link: TWPPDF_LinkDef;
  wpdf_current_env: Pointer;
{$ENDIF}
  outlinelevel, i, level: Integer;
  rec: TRect;
  abort: Boolean;
  bMustResetFontWidthMult, FUsedWidths: Boolean;
  s, NewOutline, NewBookmark, aCaption: string;
  widths: array[0..300] of Integer; // used for char output
  paa: PTAttr;
  pcc: PChar;
  pobj: PTTextObj;
  function WPPDF_XPOS(val: Integer): Integer;
  begin
    Result := val; // {x+} MulDiv(val, 72, gl_XResolution); // WPT4, was 1440);
  end;
  function WPPDF_YPOS(val: Integer): Integer;
  begin
    Result := val; // {y+} MulDiv(val, 72, gl_YResolution); // WPT4, was 1440);
  end;
begin
  s := '';
  NewOutline := '';
  NewBookmark := '';
  FUsedWidths := FALSE;
  bMustResetFontWidthMult := FALSE;

  WPPDFExport := TWPPDFExport((Sender as TWPRTFTextPaint).AnyObject);
{$IFNDEF WPDF_SOURCE}
  wpdf_current_env := WPPDFExport.dll_pdf_env;
  if wpdf_current_env <> nil then
{$ELSE}if WPPDFExport.Printing then {$ENDIF}
  begin
    if (p^.Mode = wdtStartLine) then
    begin

{ ------------------------------------------------------------------------
    If you use WPTools Version 3 please make sure symbol WPV4 is
    NOT DEFINED in the project or in the file "WPINC.INC"
  ------------------------------------------------------------------------ }

{$IFDEF WPV4}
      if (p^.lin <> nil) and (p^.lin^.pa <> nil) then
      begin
      // Only version 4.11d and later
{$IFDEF xxWPTOOLS_411d}
        if ((p^.res and 8) = 8) then
        begin
          paa := p^.linpa;
        end else
{$ENDIF}
        // ----------------------------
          paa := p^.lin^.pa; // else
        pcc := p^.lin^.pc;
        for i := 1 to p^.lin^.plen do
        begin
          if pcc^ = TextObjCodeOpening then
          begin
            Pobj := TWPRTFTextPaint(Sender).TxtObjLst.Reference[paa^.tag];
            if (Pobj <> nil) and (Pobj^.typextra = Integer(wpcoBookMark)) and (Pobj^.cName <> '') then
            begin
{$IFDEF WPDF_SOURCE}
              WPPDFExport.SetBookmark(Pobj^.cName, prect^.Left, p^.Baseline - p^.lin^.height);
{$ELSE}
              FillChar(link, SizeOf(TWPPDF_LinkDef), 0);
              link.x := WPPDF_XPOS(prect^.Left);
              link.y := WPPDF_YPOS(p^.Baseline - p^.lin^.height);
              StrPLCopy(link.destname, Pobj^.cName, 255);
              WPPDF_Action(wpdf_current_env, WPPDF_SETNAME, 0, @link);
{$ENDIF}
            end;
          end;
          inc(pcc);
          inc(paa);
        end;
      end;
{$ENDIF}
      // -----------------------------------------------------------------------
      if assigned(WPDFOnPrintLine) and not (paprWasProcessed in p^.Par^.prop) then
      begin
        outlinelevel := 0;
        WPDFOnPrintLine(p^.Par, p^.lin, NewBookmark, NewOutline, outlinelevel);
        if NewBookmark <> '' then
        begin
{$IFDEF WPDF_SOURCE}
          WPPDFExport.SetBookmark(NewBookmark, prect^.Left, p^.Baseline - p^.lin^.height);
{$ELSE}
          FillChar(link, SizeOf(TWPPDF_LinkDef), 0);
          link.x := WPPDF_XPOS(prect^.Left);
          link.y := WPPDF_YPOS(p^.Baseline - p^.lin^.height);
          StrPLCopy(link.destname, NewBookmark, 255);
          WPPDF_Action(wpdf_current_env, WPPDF_SETNAME, 0, @link);
{$ENDIF}
        end;
        if NewOutline <> '' then
        begin
{$IFDEF WPDF_SOURCE}
          if outlinelevel = 1 then
            gl_LastLevel1 := WPPDFExport.SetOutlineXY(NewOutline, prect^.Left, p^.Baseline - p^.lin^.height,
              0, gl_LastLevel0)
          else if outlinelevel >= 2 then
            gl_LastLevel2 := WPPDFExport.SetOutlineXY(NewOutline, prect^.Left, p^.Baseline - p^.lin^.height,
              0, gl_LastLevel1)
          else gl_LastLevel0 := WPPDFExport.SetOutlineXY(NewOutline, prect^.Left, p^.Baseline - p^.lin^.height,
              0, 0);
{$ELSE}
          FillChar(link, SizeOf(TWPPDF_LinkDef), 0);
          link.x := WPPDF_XPOS(prect^.Left);
          link.y := WPPDF_YPOS(p^.Baseline - p^.lin^.height);
          StrPLCopy(link.Caption, NewOutline, 255);
          if outlinelevel = 1 then
          begin
            link.level := gl_LastLevel0;
            link.levelmode := WPOut_SetAsChild;
            gl_LastLevel1 := WPPDF_Action(wpdf_current_env, WPPDF_SETOUTLINE, 0, @link);
          end
          else if outlinelevel >= 2 then
          begin
            link.level := gl_LastLevel1;
            link.levelmode := WPOut_SetAsChild;
            gl_LastLevel2 := WPPDF_Action(wpdf_current_env, WPPDF_SETOUTLINE, 0, @link);
          end
          else
          begin
            link.level := 0;
            link.levelmode := WPOut_SetLevel;
            gl_LastLevel0 := WPPDF_Action(wpdf_current_env, WPPDF_SETOUTLINE, 0, @link);
          end;
{$ENDIF}
        end;
        include(p^.Par^.prop, paprWasProcessed);
      end;

      if not (paprWasProcessed in p^.Par^.prop) and
        gl_CreateOutlines and (p^.Par <> nil) and
        (paprIsOutline in p^.Par^.prop) and not p^.isSpecial and
        (p^.lin^.plen > 0) then
      begin
        if gl_AutoOutlineLevels then
        begin
          aCaption := TWPRTFTextPaint(Sender).GetParText(p^.par);
          if aCaption <> '' then
          begin
            if aCaption[1] in ['1'..'9'] then
            begin
              gl_LastLevel1 := WPPDFExport.SetOutlineXY(aCaption,
                prect^.Left, p^.Baseline - p^.lin^.height, 0, gl_LastLevel0);
            end
            else if aCaption[1] in ['a'..'z'] then
            begin
              gl_LastLevel2 := WPPDFExport.SetOutlineXY(aCaption,
                prect^.Left, p^.Baseline - p^.lin^.height, 0, gl_LastLevel1);
            end
            else
            begin
              gl_LastLevel0 := WPPDFExport.SetOutlineXY(aCaption,
                prect^.Left, p^.Baseline - p^.lin^.height, 0, 0);
            end;
          end;
        end
        else
        begin
{$IFNDEF WPDF_SOURCE}
          level := 0;
          aCaption := TWPRTFTextPaint(Sender).GetParText(p^.par);
          Abort := FALSE;
          if assigned(WPPDFExport.FOnPrintOutline) then
          begin
            WPPDFExport.FOnPrintOutline(WPPDFExport,
              TWPRTFTextPaint(Sender),
              p^.Par,
              p^.lin,
              aCaption,
              Level,
              Abort);
          end;
          if not Abort then
          begin
            link.levelmode := WPOut_SetLevel;
            // Calculate the relative level
            link.level := level - WPPDFExport.Flastlevel;
            WPPDFExport.Flastlevel := level;
            StrPLCopy(link.caption, aCaption, 255);
            // gl_LastLevel0 := WPPDF_Action(wpdf_current_env, WPPDF_SETOUTLINE, 0, @link);

            gl_LastLevel0 := WPPDFExport.SetOutlineXY(link.caption,
              prect^.Left, p^.Baseline - p^.lin^.height, 0, 0);

          end;
{$ENDIF}
        end;
        // add the outline!
        // Do not check for outlines again!
        include(p^.Par^.prop, paprWasProcessed);
      end;
    end;
    // -------------------------------------------------------------------------
    // Preprocess (get text width) - for wPDF Version 2 ------------------------
    // -------------------------------------------------------------------------

    if (p^.Mode = wdtChar) then // and (p^.lin <> nil) and (p^.lin^.pa <> nil) and (count < 300) then
    begin
      if (p^.pa <> nil) and (p^.pa^.BGColor <> 0) then
        with TWPRTFTextPaint(Sender).Header.FPaletteEntries[p^.pa^.BGColor] do
          p^.ParColor := TColor(RGB(peRed, peGreen, peBlue))
      else
        p^.ParColor := $1FFFFFFF; // = clNone

      if (p^.lin <> nil) and (p^.lin^.pa <> nil) and (count < 300)
        and (p^.Options <> 15) // defined in WPTools V4.09e
{$IFNDEF WPV4}
      and ((p^.pos > 0) or (p^.lin^.pc^ = str^)) // Workaround to detetect fields 99% in WPTools 3
{$ENDIF}
      then
      begin
        paa := p^.lin^.pa;
        inc(paa, p^.pos);
        for i := 0 to count - 1 do
        begin
          widths[i] := paa^.Width;
          inc(paa);
        end;
        p^.buffer := @widths[0];
        p^.buftype := 345612; // magic!
        FUsedWidths := TRUE;
      end else if (count < 300) and (str <> nil) then // Calculate the width
      begin
        pcc := str;
        for i := 0 to count - 1 do
        begin
          widths[i] := TWPRTFTextPaint(Sender).toCanvas.TextWidth(pcc^);
          inc(pcc);
        end;
        p^.buffer := @widths[0];
        p^.buftype := 345612; // magic!
        FUsedWidths := TRUE;
      end;
    end
    else
      FUsedWidths := FALSE;

    // -------------------------------------------------------------------------
    // Check for Hyperlinks ----------------------------------------------------
    // -------------------------------------------------------------------------

    if (p^.Mode = wdtChar) and (p^.pa <> nil) and (afsHyperlink in p^.pa^.Style)
      and (Count > 0) then
    begin
      s := TWPRTFTextPaint(Sender)._InternReadHyperlinkURL(p);
      if s <> '' then
      begin
        {FillChar(link, SizeOf(TWPPDF_LinkDef), 0);
        link.x := WPPDF_XPOS(prect^.Left);
        link.y := WPPDF_YPOS(prect^.Top);
        link.w := WPPDF_XPOS(prect^.Right) - link.x;
        link.h := WPPDF_YPOS(prect^.Bottom) - link.y;
        StrPLCopy(link.destname, s, 255);
        WPPDF_Action(wpdf_current_env, WPPDF_SETLINK, 0, @link);}
        WPPDFExport.SetLinkArea(s, prect^);
      end;
    end;

    // -------------------------------------------------------------------------
    // Check for V3 Bookmarks --------------------------------------------------
    // -------------------------------------------------------------------------
{$IFNDEF WPV4}
    if (p^.Mode = wdtChar) and (p^.pa <> nil) and (afsBookmark in p^.pa^.Style) then
    begin
      s := TWPRTFTextPaint(Sender)._InternReadBookmark(p);
      if s <> '' then
      begin
        {FillChar(link, SizeOf(TWPPDF_LinkDef), 0);
        link.x := WPPDF_XPOS(prect^.Left);
        link.y := WPPDF_YPOS(p^.Baseline - p^.lin^.height);
        StrPLCopy(link.destname, s, 255);
        WPPDF_Action(wpdf_current_env, WPPDF_SETNAME, 0, @link); }
        WPPDFExport.SetLinkArea(s, prect^);
      end;
      if s = #1 then exit;
    end;
{$ENDIF}

    // -------------------------------------------------------------------------
    // Paint Graphic and TextObjects (requires WPTools V4.09e or higher) -------
    // -------------------------------------------------------------------------

    if (p^.Mode = wdtObj) and (p^.current_ptr <> nil) then
    begin
       // Execute OBJECT event
      if assigned(WPPDFExport.FOnPrintObject) then
      begin
        abort := FALSE;
        rec.Left := prect^.Left;
        rec.Top := prect^.Top;
        rec.Right := prect^.Left +
          MulDiv(PTTextObj(p^.current_ptr)^.w,
          TWPRTFTextPaint(Sender).Header.FXPixelsPerInch,
          1440);
        rec.Bottom := prect^.Top +
          MulDiv(PTTextObj(p^.current_ptr)^.h,
          TWPRTFTextPaint(Sender).Header.FYPixelsPerInch,
          1440);
        WPPDFExport.FOnPrintObject(WPPDFExport, TWPRTFTextPaint(Sender),
          PTTextObj(p^.current_ptr), TWPObject(PTTextObj(p^.current_ptr)^.obj),
          rec, abort);
        if abort then exit;
      end;
       // Create Link if Object has an URL
      if (PTTextObj(p^.current_ptr)^.obj <> nil) and
        (TWPObject(PTTextObj(p^.current_ptr)^.obj).URL <> '') then
      begin
        rec.Left := MulDiv(prect^.Left, WPPDFExport.XPixelsPerInch, TWPRTFTextPaint(Sender).Header.FXPixelsPerInch);
        rec.Top := MulDiv(prect^.Top, WPPDFExport.YPixelsPerInch, TWPRTFTextPaint(Sender).Header.FYPixelsPerInch);
        rec.Right := rec.Left +
          MulDiv(PTTextObj(p^.current_ptr)^.w, WPPDFExport.XPixelsPerInch, 1440);
        rec.Bottom := rec.Top + MulDiv(PTTextObj(p^.current_ptr)^.h, WPPDFExport.YPixelsPerInch, 1440);
        WPPDFExport.SetLinkArea(TWPObject(PTTextObj(p^.current_ptr)^.obj).URL, rec);
      end;


      if PTTextObj(p^.current_ptr)^.obj is TWPOHorzLine then
      begin
        rec.Left := MulDiv(
          TWPRTFTextPaint(Sender).Header.LeftMargin + p^.Par^.indentleft,
          TWPRTFTextPaint(Sender).Header.FXPixelsPerInch,
          1440);
        rec.Top := prect^.Top;
        rec.Right := MulDiv(
          TWPRTFTextPaint(Sender).Header.PageWidth -
          (TWPRTFTextPaint(Sender).Header.RightMargin + p^.Par^.indentright),
          TWPRTFTextPaint(Sender).Header.FXPixelsPerInch,
          1440);
        rec.Bottom := prect^.Top +
          MulDiv(PTTextObj(p^.current_ptr)^.h,
          TWPRTFTextPaint(Sender).Header.FYPixelsPerInch,
          1440);
        if rec.Bottom < rec.Top + 1 then
          rec.Bottom := rec.Top + 1;
        WPPDFExport.Canvas.Brush.Color := p^.Color;
             //TWPOHorzLine(PTTextObj(p^.current_ptr)^.obj).Color;
        WPPDFExport.Canvas.Brush.Style := bsSolid;
        WPPDFExport.Canvas.FillRect(rec);
        WPPDFExport.Canvas.Brush.Style := bsClear;
        exit;
      end
{$IFDEF WPDFJPEG}
      else if PTTextObj(p^.current_ptr)^.obj is TWPOJpgImage then
      begin
        if TWPOJpgImage(PTTextObj(p^.current_ptr)^.obj).IsGrayScale then
          p^.buftype := 7;
      end
{$ENDIF};
    end;

    // -------------------------------------------------------------------------
    // Check for Metafiles (requires WPTools V4.09e or higher) -----------------
    // -------------------------------------------------------------------------
{$IFDEF CONVERTTOMETA}
    if (p^.Mode = wdtObj) and (p^.graphic <> nil) and (p^.graphic is TMetafile)
      and not WPPDFExport.ConvertMetafileToBitmaps then
    begin
      rec.Left := prect^.Left;
      rec.Top := prect^.Top;
      rec.Right := prect^.Left +
        MulDiv(PTTextObj(p^.current_ptr)^.w,
        TWPRTFTextPaint(Sender).Header.FXPixelsPerInch,
        1440);
      rec.Bottom := prect^.Top +
        MulDiv(PTTextObj(p^.current_ptr)^.h,
        TWPRTFTextPaint(Sender).Header.FYPixelsPerInch,
        1440);
      WPPDFExport.Canvas.StretchDraw(rec, p^.graphic);
      exit;
    end;
{$ENDIF}

    rec := prect^;

    if gl_ReplaceBullets and (count = 1) and (str <> nil) and (StrIComp(p^.FontForText, 'WingDings') = 0) then
    begin
      StrPCopy(p^.FontForText, 'Arial');
      str^ := #149;
    end;

{$IFDEF WPDF_SOURCE}
    Result := WPPDFExport._WPPDF_WPTEXEC(p, @rec, str, count, pwidth);
{$ELSE}
    Result := _WPPDF_WPTEXEC(wpdf_current_env, p, @rec, str, count, pwidth);
{$ENDIF}

    if FUsedWidths then
    begin
      p^.buffer := nil;
      p^.buftype := 0; // magic!
    end;
{$IFNDEF WPDF_SOURCE}
    if bMustResetFontWidthMult then WPPDF_SetIProp(wpdf_current_env, WPPDF_FontWidthMult, 100);
{$ENDIF}
  end
  else
    Result := TRUE;
end;


procedure TWPPDFExport.PrintPages(f, t: Integer);
var
  i: Integer;
  SetFixed: Boolean;
  FromPos, Length: Integer;
  par: PTparagraph;
  lin: PTline;
  usewater: string;
begin
  if (FSource = nil) then
    raise PDFException.Create('No text source was specified!');

{$IFNDEF WPV4}
  if FSource.ScreenResMode <> rm1440 then
    raise PDFException.Create('Please select ScreenResMode=rm1440 in object ' + FSource.Name);
{$ENDIF}
  if (Source <> nil) and (Source.Memo.FPaintMode = [prWait]) then // workaround for WPTools V.09 and earlier
    Source.Memo.PaintMode := [];

  FInternPageCount := FSource.Memo.GetPageCount;
  FSource.Memo.TxtObjClearGraphicIDs;
{$IFNDEF WPV4}
  FDefaultXRes := 1440;
  FDefaultYRes := 1440;
{$ELSE}
  FDefaultXRes := FSource.Header.FFontXPixelsPerInch; //V2 otherwise 72
  FDefaultYRes := FSource.Header.FFontYPixelsPerInch; //V2
{$ENDIF}
  try
    usewater := '';
    if not FPrinting then
    begin
      BeginDoc;
      if FLastError = 0 then
      try
        PrintPages(f, t);
      finally
        EndDoc;
      end;
    end
    else if {$IFNDEF WPDF_SOURCE}(pdf_env <> nil) and {$ENDIF}(FPrinting = TRUE) then
    begin
      Flastlevel := 0;
      FSource.Memo.AnyObject := Self;
      gl_LastLevel0 := 0;
      gl_LastLevel1 := 0;
      gl_LastLevel2 := 0;
      gl_ReplaceBullets := FReplaceBullets;
{$IFDEF WPV4} // WPTools4
      gl_XResolution := FDefaultXRes;
      gl_YResolution := FDefaultYRes;
{$ELSE}
      gl_XResolution := 1440;
      gl_YResolution := 1440;
{$ENDIF}
      Fpage_xres := gl_XResolution;
      Fpage_yres := gl_YResolution;
      fillchar(Finit, SizeOf(Finit), 0);
      PreparePage(-1, Finit, Fpage_xres, Fpage_yres);
      Finit.specialcolor := FHeaderFooterColor;
      Finit.thumbnails := CreateThumbnails;

      gl_CreateOutlines := FCreateOutlines;
      gl_AutoOutlineLevels := FAutoOutlineLevels;
      try
        FSource.Memo.WPDrawTextEvent := TWPDrawTextEvent(@WPPDFDrawChar);
        if f < 0 then f := 0;
        i := FSource.Memo.GetPageCount;
        if t >= i then t := i - 1;
        if t < 0 then t := 0;
        for i := f to t do
        begin
          if FAbort then break;
          usewater := PrepareWatermark(FLastWidth, FLastHeight, Fpage_xres, Fpage_yres);
          FStartPageAtOnce := FALSE;
          FKeepInitValues := TRUE;
          InternStartPage(true, '', Finit.pagew, Finit.pageh, Finit.xres, Finit.yres, FInit.rotation);

          FromPos := 0;
          Length := 0;
          if assigned(FOnBeforePrintPage) or assigned(FOnAfterPrintPage) then
          begin
            FSource.Memo.GetPageStart(i, par, lin, FromPos);
            Length := FSource.Memo.GetPageLength(par, lin);
          end;
          if assigned(FOnBeforePrintPage) then
          begin
            FSource.Memo.WPDrawTextEvent := nil;
            FOnBeforePrintPage(Self, i, FromPos, Length
{$IFDEF PARLIN}
              , par, lin
{$ENDIF}
              );
            FSource.Memo.WPDrawTextEvent := TWPDrawTextEvent(@WPPDFDrawChar);
            FSource.Memo.left_offset := 0;
            CloseCanvas;
            InitDC;
          end;
          if usewater <> '' then UseWatermark(usewater);
          try
            // set a fixed pagenumber
            if (FPageCount <> 0) and not FSource.Memo.FIX_Active then
            begin
              FSource.Memo.FIX_TotalPages := FPageCount;
              FSource.Memo.FIX_CurrentPage := FInternPageNumber;
              FSource.Memo.FIX_Active := TRUE;
              SetFixed := TRUE;
            end
            else
              SetFixed := FALSE;
            // Print this page
{$IFDEF WPV4}
            FSource.Printparameter.PrintPageOnCanvas(
              wpdf_canvas, Rect(0, 0,
              MulDiv(FSource.Header.LayoutPIX.paperw, FInit.xres, FSource.Header.FFontXPixelsPerInch), //WPT4, was 0
              MulDiv(FSource.Header.LayoutPIX.paperh, FInit.yres, FSource.Header.FFontYPixelsPerInch)), // was 0
              i, [ppmInternPrintPageOnly], 100);
{$ELSE}
            FSource.Printparameter.PrintPageOnCanvas(
              wpdf_canvas, Rect(0, 0,
              MulDiv(FSource.Header.LayoutPIX.paperw, FInit.xres, 0), //WPT4, was 0
              MulDiv(FSource.Header.LayoutPIX.paperh, FInit.yres, 0)), // was 0
              i, [ppmInternPrintPageOnly], 100);
{$ENDIF}

            // Reset the fixed number setting
            if SetFixed then
            begin
              FSource.Memo.FIX_TotalPages := 0;
              FSource.Memo.FIX_CurrentPage := 0;
              FSource.Memo.FIX_Active := FALSE;
            end;
            if assigned(FOnUpdateGauge) and (FInternPageCount > 0) then
              FOnUpdateGauge(Self, MulDiv(FInternPageNumber, 100, FInternPageCount));
          except
            EndPage;
            raise;
          end;
          if assigned(FOnAfterPrintPage) then
          begin
            InitDC;
            FSource.Memo.WPDrawTextEvent := nil;
            FOnAfterPrintPage(Self, i, FromPos, Length
{$IFDEF PARLIN}
              , par, lin
{$ENDIF});
            FSource.Memo.WPDrawTextEvent := TWPDrawTextEvent(@WPPDFDrawChar);
            FSource.Memo.left_offset := 0;
          end;
          EndPage;
        end;
      finally
        FSource.Memo.WPDrawTextEvent := nil;
        FSource.Memo.AnyObject := nil;
        FStartPageAtOnce := FALSE;
      end;
    end;
  except
    FLastError := 1;
    raise;
  end;
end;

procedure TWPPDFExport.PreparePage(pageno: Integer; var init: TWPPDF_InitRec; ResX, ResY: Integer);
var
  par: PTParagraph;
  lin: PTLine;
  r: Integer;
begin
  inherited PreparePage(pageno, init, ResX, ResY);
  if FSource <> nil then
  begin
    par := FSource.Memo.FirstPar; // active_paragraph;
    while par <> nil do
    begin
      lin := par^.line;
      while lin <> nil do
      begin
        exclude(lin^.state, listWasProcessed); lin := lin^.next;
      end;
      exclude(par^.prop, paprWasProcessed); par := par^.next;
    end;
    // Some initialisation code ----------------------------------------------
    FSource.Memo.left_offset := 0;
    FSource.Refresh;
    // -----------------------------------------------------------------------
    fillchar(init, SizeOf(init), 0);
    {  r := FSource.Memo.Header.FFontXPixelsPerInch;
      if r=0 then }
    if ResX = 0 then ResX := 72;
    if ResY = 0 then ResY := 72;
    r := 1440;
    init.pagew := MulDiv(FSource.Memo.Header._Layout.paperw, ResX, r);
    init.pageh := MulDiv(FSource.Memo.Header._Layout.paperh, ResY, r);
    init.xres := ResX;
    init.yres := ResY;
    FLastWidth := init.pagew;
    FLastHeight := init.pageh;
    FStartPageAtOnce := TRUE;
    FInit := init;
  end
  else
    FStartPageAtOnce := FALSE;
end;

{$ENDIF}

end.

