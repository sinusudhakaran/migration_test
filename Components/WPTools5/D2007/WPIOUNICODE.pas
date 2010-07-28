{:: This unit contains the reader and writer classes to support ANSI (*.TXT) files }
{$IFNDEF CLRUNIT} unit WPIOUNICODE;
{$ELSE} unit WPTools.IO.UNICODE; {$ENDIF}
//******************************************************************************
// WPTools V5 - THE word processing component for VCL and .NET
// Copyright (C) 2004 by WPCubed GmbH and Julian Ziersch, all rights reserved
// WEB: http://www.wpcubed.com   mailto: support@wptools.de
//******************************************************************************
// WPIOUNICODE - WPTools 5 RTF UNICODE text writer and reader
// use option -LittleEndian to load/save unicode with natural high/low byte order
// otherwise the standard Intel low/high byte order is used
//******************************************************************************

{ Example: This code will create a WideString from contents of editor
  var w : WideString;  s : string;

  s := WPRichText1.AsANSIString('UNICODE',false,false);
  SetLength(w, Length(s) div 2);
  Move(s[1],w[1],Length(s));
  -------------------------------------------------------------------- }  

interface
{$I WPINC.INC}

uses  Classes, Sysutils, WPRTEDefs;

type
TWPUNITextReader = class(TWPCustomTextReader)  { from WPTools.RTE.Defs }
private
  FLittleEndian : Boolean; // usually FALSE!
public
  procedure SetOptions(optstr: string);  override;
protected
  class function UseForFilterName(const Filtername : String) : Boolean; override;
public
  function Parse(datastream : TStream) : TWPRTFDataBlock; override;
end;

TWPUNITextWriter = class(TWPCustomTextWriter)  { from WPTools.RTE.Defs }
public
     procedure SetOptions(optstr: string); override;
protected
    class function UseForFilterName(const Filtername: string): Boolean; override; // RTF, HTML or classname
public
    function WriteHeader: Boolean; override;
    function WriteChar(aChar : Word) : Boolean; override;
    function WriteCell(cellpar: TParagraph; Style: TWPTextStyle; start: Boolean): Boolean; override;
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


procedure TWPUNITextWriter.SetOptions(optstr: string);
var i: Integer; aoptstr: string;
begin
  i := Pos('-', optstr);
  if i > 0 then
  begin
    aoptstr := lowercase(Copy(optstr, i, Length(optstr) - i + 1)) + ',';
    if Pos('-littleendian,', aoptstr) > 0 then
       LittleEndian := TRUE;
  end;
  inherited SetOptions(optstr);
end;

function TWPUNITextWriter.WriteHeader: Boolean;
begin
  Result := inherited WriteHeader;
  FNeedEndPar := TRUE;
end;

function TWPUNITextWriter.WriteCell(cellpar: TParagraph; Style: TWPTextStyle; start: Boolean): Boolean; 
begin
  if not start then
  begin
     if cellpar.NextPar=nil then
     begin
         WriteWideChar(#13);
         WriteWideChar(#10);
     end
     else  WriteWideChar(#9);
  end;
  Result := TRUE;
end;

function TWPUNITextWriter.WriteParagraphEnd(par : TParagraph;
       ParagraphType : TWPParagraphType; NeedNL :Boolean): Boolean;
begin
  if NeedNL and (par.next<>nil) then
  begin
     WriteWideChar(#13);
     Result := WriteWideChar(#10);
  end else Result := TRUE;
end;

function TWPUNITextWriter.WriteChar(aChar : Word) : Boolean;
begin
   Result := WriteWideChar(WideChar(aChar));
end;

{ ----------------------------------------------------------------------------- }

class function TWPUNITextReader.UseForFilterName(const Filtername : String) : Boolean;
begin
   Result := inherited UseForFilterName(Filtername) or (CompareText( Filtername, 'UNICODE' )=0);
end;

procedure TWPUNITextReader.SetOptions(optstr: string);
var i: Integer; aoptstr: string;
begin
  i := Pos('-', optstr);
  if i > 0 then
  begin
    aoptstr := lowercase(Copy(optstr, i, Length(optstr) - i + 1)) + ',';
    if Pos('-bigendian,', aoptstr) > 0 then
       FLittleEndian := TRUE;
  end;
  inherited SetOptions(optstr);
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
      if FLittleEndian then
           UnicodeChar := ReadWideCharLittleEndian
      else UnicodeChar := ReadWideChar;
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
