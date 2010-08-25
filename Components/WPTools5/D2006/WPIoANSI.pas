{:: This unit contains the reader and writer classes to support ANSI (*.TXT) files }
{$IFNDEF CLRUNIT} unit WPIOANSI;
{$ELSE} unit WPTools.IO.ANSI; {$ENDIF}
//******************************************************************************
// WPTools V5 - THE word processing component for VCL and .NET
// Copyright (C) 2004 by WPCubed GmbH and Julian Ziersch, all rights reserved
// WEB: http://www.wpcubed.com   mailto: support@wptools.de
//******************************************************************************
// WPIOANSI - WPTools 5 RTF ANSI text writer and reader
//
// (Replaces WPTools 4 units WPRead2 and WPWrite2)
//******************************************************************************

interface
{$I WPINC.INC}

// Activate enhancement to read special commands starting with rdEscapeCode.
// in this example we recognize
// \b for bold text and \n for standard text.
{.$DEFINE READ_ESC_EXAMPLE}

uses  Classes, Windows, Sysutils, WPRTEDefs, Graphics;

 {$IFDEF T2H} 
 type 
 {:: This class is used to read text which was saved in ANSI format. This class is 
 used when the format name (property TextLoadFormat) is "ANSI" or "TXT" }
 TWPTextReader = class(TWPCustomTextReader); 
 {:: This class is used to save text in ANSI format. This class is 
 used when the format name (property TextSaveFormat) is "ANSI" or "TXT" }
 TWPTextWriter = class(TWPCustomTextWriter) ;
 {$ELSE}

type
TWPTextReader = class(TWPCustomTextReader)  { from WPTools.RTE.Defs }
protected
  function  ParseEscapeCode(ch:Integer) :TWPToolsIOErrCode; virtual;
  class function UseForFilterName(const Filtername : String) : Boolean; override;
public
  function Parse(datastream : TStream) : TWPRTFDataBlock; override;
end;

TWPTextWriter = class(TWPCustomTextWriter)  { from WPTools.RTE.Defs }
protected
    class function UseForFilterName(const Filtername: string): Boolean; override; // RTF, HTML or classname
public
    function WriteChar(aChar : WideChar) : Boolean; override;
    function WriteParagraphStart(
      par: TParagraph;
      ParagraphType: TWPParagraphType;
      Style: TWPTextStyle): Boolean; override;
    function WriteParagraphEnd(par : TParagraph;
       ParagraphType : TWPParagraphType; NeedNL :Boolean): Boolean; override;
end;

implementation

const
  EscapeCode = '\';

{ ----------------------------------------------------------------------------- }

class function TWPTextWriter.UseForFilterName(const Filtername : String) : Boolean;
begin
   Result := inherited UseForFilterName(Filtername) or (CompareText( Filtername, 'ANSI' )=0)
     or (CompareText( Filtername, 'TXT' )=0);  //V5.18.4
end;

function TWPTextWriter.WriteParagraphStart(
      par: TParagraph;
      ParagraphType: TWPParagraphType;
      Style: TWPTextStyle): Boolean;
begin
  if not (par.ParagraphType in [wpIsTable, wpIsTableRow,
            wpIsXMLTopLevel, wpIsXMLSubLevel, wpIsReportGroup]) and
               (par.next<>nil) then
                FNeedEndPar := TRUE
  else          FNeedEndPar := FALSE;
  Result := TRUE;
end;

function TWPTextWriter.WriteParagraphEnd(par : TParagraph;
       ParagraphType : TWPParagraphType; NeedNL :Boolean): Boolean;
begin
  if NeedNL then
       Result := WriteString(#13+#10)
  else Result := TRUE;
end;

// AV? -> rewritten to use WideCharToMultiByte directly
function TWPTextWriter.WriteChar(aChar : WideChar) : Boolean;
var c : AnsiChar;
    i, l : Integer;
    DefaultChar : Char;
    b : Boolean;
    buffer : array[0..11] of AnsiChar;
begin
   if (Integer(aChar)<256) and ((FOptCodePage<0) or (FOptCodePage=1252)) then
   begin
     c := AnsiChar(aChar);
     Result := WriteString(c);
   end else
   begin
      // was: Result := WriteString(WPWideStringToANSI(FOptCodePage,aChar));
      DefaultChar := '?';
      l := WideCharToMultiByte(   // requires Windows in uses
        FOptCodePage,
        WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
        @aChar, 1,
        @buffer[0], 10,
        @DefaultChar, @b);
      for i:=0 to l-1 do
        WriteString(buffer[i]);
      Result := TRUE;
   end;
end;


{ ----------------------------------------------------------------------------- }

class function TWPTextReader.UseForFilterName(const Filtername : String) : Boolean;
begin
   Result := inherited UseForFilterName(Filtername) or (CompareText( Filtername, 'ANSI' )=0);
end;

function TWPTextReader.Parse(datastream : TStream) : TWPRTFDataBlock;
var
 ch  :Integer;
 ret : TWPToolsIOErrCode;
begin
  Result := inherited Parse(datastream);
  ret    := wpNoError;
  try
   // We select the body to ad the data
   SelectRTFData(wpIsBody,wpraIgnored,'');
   // and create the first paragraph
   NewParagraph;
   if DestParagraphStyle<>nil then  //V5.15.5
      FCurrentParagraph.ACopy(DestParagraphStyle,WPAT_FirstCharAttr,WPAT_LastCopiedParProp);
   repeat
      ch := ReadChar;
      if ch<0 then break
      else
      if ch=12 then
      begin
         if loANSIFormfeedCode in FLoadOptions then
         begin
           if FCurrentParagraph.CharCount>0 then NewParagraph;
           include(FCurrentParagraph.prop,paprNewPage);
         end;
      end else
      if ch=13  then
      begin
          NewParagraph;
          if DestParagraphStyle<>nil then //V5.15.5
             FCurrentParagraph.ACopy(DestParagraphStyle,WPAT_FirstCharAttr,WPAT_LastCopiedParProp);
      end
      else if ch=Integer(EscapeCode) then ParseEscapeCode(ch)
    { ---just a demo---
      else if ch=Integer('b') then
      begin
         Attr.IncludeStyle(afsBold);
         PrintAChar(Char(ch));
         Attr.ExcludeStyle(afsBold);
      end
      else if ch=Integer('r') then
      begin
         Attr.SetColor(clRed);
         PrintAChar(Char(ch));
         Attr.SetColor(clBlack);
      end  }
      else if ch<>10 then PrintAChar(Char(ch), FOptCodePage);
   until ret<>wpNoError;
   ResetReadBuffer;
  except
    FReadingError := TRUE;
    raise;
 end;
end;

// -----------------------------------------------------------------------------
// this is the function you may change to modify Attr using simple ESC codes
// -----------------------------------------------------------------------------

function  TWPTextReader.ParseEscapeCode(ch:Integer) :TWPToolsIOErrCode;
{$IFNDEF READ_ESC_EXAMPLE}
begin
    PrintAChar(Char(ch));
    Result := wpNoError;
end;
{$ELSE}
var c  : Integer;
    s  : string;
begin
   s := '';
   repeat
     c  := ReadChar;
     if (c<=32) then
     begin
        if c<>32 then unReadChar; // - only if you want this space!
        break;
     end else
     begin
       s := s + Char(c);
     end;
   until false;
   // process 's'
   if s='b' then include(Attr.Style,afsBold)
   else if s='n' then exclude(Attr.Style,afsBold);
   Result := wpNoError;
end;
{$ENDIF}

initialization

  if GlobalWPToolsCustomEnviroment<>nil then
  begin
     GlobalWPToolsCustomEnviroment.RegisterReader([TWPTextReader]);
     GlobalWPToolsCustomEnviroment.RegisterWriter([TWPTextWriter]);
  end;
  
  {$ENDIF T2H} 
     
end.
