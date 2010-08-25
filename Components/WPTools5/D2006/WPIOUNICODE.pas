{:: This unit contains the reader and writer classes to support ANSI (*.TXT) files }
{$IFNDEF CLRUNIT} unit WPIOUNICODE;
{$ELSE} unit WPTools.IO.UNICODE; {$ENDIF}
//******************************************************************************
// WPTools V5 - THE word processing component for VCL and .NET
// Copyright (C) 2004 by WPCubed GmbH and Julian Ziersch, all rights reserved
// WEB: http://www.wpcubed.com   mailto: support@wptools.de
//******************************************************************************
// WPIOANSI - WPTools 5 RTF UNICODE text writer and reader
//******************************************************************************

interface
{$I WPINC.INC}

uses  Classes, Sysutils, WPRTEDefs;

type
TWPUNITextReader = class(TWPCustomTextReader)  { from WPTools.RTE.Defs }
protected
  class function UseForFilterName(const Filtername : String) : Boolean; override;
public
  function Parse(datastream : TStream) : TWPRTFDataBlock; override;
end;

TWPUNITextWriter = class(TWPCustomTextWriter)  { from WPTools.RTE.Defs }
protected
    class function UseForFilterName(const Filtername: string): Boolean; override; // RTF, HTML or classname
public
    function WriteHeader: Boolean; override;
    function WriteChar(aChar : WideChar) : Boolean; override;
    function WriteParagraphEnd(par : TParagraph;
       ParagraphType : TWPParagraphType; NeedNL :Boolean): Boolean; override;
end;

implementation

{ ----------------------------------------------------------------------------- }

class function TWPUNITextWriter.UseForFilterName(const Filtername : String) : Boolean;
begin
   Result := inherited UseForFilterName(Filtername) or (CompareText( Filtername, 'UNICODE' )=0)
     or (CompareText( Filtername, 'UNI' )=0);
end;

function TWPUNITextWriter.WriteHeader: Boolean;
begin
  Result := inherited WriteHeader;
  FNeedEndPar := TRUE;
end;

function TWPUNITextWriter.WriteParagraphEnd(par : TParagraph;
       ParagraphType : TWPParagraphType; NeedNL :Boolean): Boolean;
begin
  if NeedNL then
  begin
     WriteWideChar(#13);
     Result := WriteWideChar(#10);
  end else Result := TRUE;
end;

function TWPUNITextWriter.WriteChar(aChar : WideChar) : Boolean;
begin
   Result := WriteWideChar(aChar);
end;

{ ----------------------------------------------------------------------------- }

class function TWPUNITextReader.UseForFilterName(const Filtername : String) : Boolean;
begin
   Result := inherited UseForFilterName(Filtername) or (CompareText( Filtername, 'UNICODE' )=0);
end;

function TWPUNITextReader.Parse(datastream : TStream) : TWPRTFDataBlock;
var
 UnicodeChar  :Integer;
 ret : TWPToolsIOErrCode;
begin
  Result := inherited Parse(datastream);
  ret    := wpNoError;
  try
   // We select the body to ad the data
   SelectRTFData(wpIsBody,wpraIgnored,'');
   // and create the first paragraph
   NewParagraph;
   repeat
      UnicodeChar := ReadWideChar;
      if UnicodeChar<0 then break
      else
      if UnicodeChar=12 then
      begin
         if loANSIFormfeedCode in FLoadOptions then
         begin
           if FCurrentParagraph.CharCount>0 then NewParagraph;
           include(FCurrentParagraph.prop,paprNewPage);
         end;
      end else
      if UnicodeChar=13  then NewParagraph
      else if UnicodeChar<>10  then
      begin
        PrintWideChar(UnicodeChar);
      end;
   until ret<>wpNoError;
   ResetReadBuffer;
  except
    FReadingError := TRUE;
    raise;
 end;
end;

initialization

  if GlobalWPToolsCustomEnviroment<>nil then
  begin
     GlobalWPToolsCustomEnviroment.RegisterReader([TWPUNITextReader]);
     GlobalWPToolsCustomEnviroment.RegisterWriter([TWPUNITextWriter]);
  end;
     
end.
