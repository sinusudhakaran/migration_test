{:: This unit contains the reader and writer classes to support ANSI (*.TXT) files }
{$IFNDEF CLRUNIT}unit WPIOHTTAGS;
{$ELSE}unit WPTools.IO.HTTAGS; {$ENDIF}
//******************************************************************************
// WPTools V5 - THE word processing component for VCL and .NET
// Copyright (C) 2004 by WPCubed GmbH and Julian Ziersch, all rights reserved
// WEB: http://www.wpcubed.com   mailto: support@wptools.de
//******************************************************************************
// WPIOHTTags - WPTools 5 HTML Tag Reader
//
// (Replaces WPTools 4 unit wpRDtags)
//******************************************************************************

interface
{$I WPINC.INC}

uses Classes, Sysutils, WPRTEDefs, Graphics;

{$IFDEF T2H}
type
 {:: This class is used to read text which was saved in HTML format.
  It will not interpret the HTML tags but creat objects to display them.
  Please note that any hard paragraph breaks are not used in this mode.<br>
  To select this reader please choose 'HTMLTAGS' in the property TextLoadFormat.
  To display the tags the reader creates objects of the type 'wpobjSPANStyle.
  The setting 'Style' is not used.
 }
  TWPHTMLTagReader = class(TWPCustomTextReader);
 {:: This class is used to save text which was loaded using the TWPHTMLTagReader }
  TWPHTMLTagWriter = class(TWPCustomTextWriter);
{$ELSE}

type
  TWPHTMLTagReader = class(TWPCustomTextReader) { from WPTools.RTE.Defs }
  protected
    class function UseForFilterName(const Filtername: string): Boolean; override;
  public
    function Parse(datastream: TStream): TWPRTFDataBlock; override;
  end;

  TWPHTMLTagWriter = class(TWPCustomTextWriter) { from WPTools.RTE.Defs }
  protected
    class function UseForFilterName(const Filtername: string): Boolean; override; // RTF, HTML or classname
  public
    function WriteChar(aChar: WideChar): Boolean; override;
    function WriteObject(txtobj: TWPTextObj; par: TParagraph; posinpar: Integer): Boolean; override;

  end;

implementation

{ ----------------------------------------------------------------------------- }

class function TWPHTMLTagWriter.UseForFilterName(const Filtername: string): Boolean;
begin
  Result := inherited UseForFilterName(Filtername) or (CompareText(Filtername, 'HTMLTAGS') = 0);
end;

function TWPHTMLTagWriter.WriteChar(aChar: WideChar): Boolean;
var c: AnsiChar;
begin
  c := AnsiChar(aChar);
  Result := fpout.Write(c, 1) = 1;
end;

function TWPHTMLTagWriter.WriteObject(txtobj: TWPTextObj; par: TParagraph; posinpar: Integer): Boolean;
begin

end;

{ ----------------------------------------------------------------------------- }

class function TWPHTMLTagReader.UseForFilterName(const Filtername: string): Boolean;
begin
  Result := inherited UseForFilterName(Filtername) or (CompareText(Filtername, 'HTMLTAGS') = 0);
end;

function TWPHTMLTagReader.Parse(datastream: TStream): TWPRTFDataBlock;
var
  ch, ch2, i: Integer;
  Entity, EscapeCloseTag: string;
  ret: TWPToolsIOErrCode;
  FReadStringBuffer: TWPStringBuilder;
  ReadEntity, FIgnoreText, FReadingPRE, FReadingHead, EscapeCloseTagActive, FReadingVariable: Boolean;
  aTag: TWPCustomHTMLTag;
  aSpanObj : TWPTextObj;
begin
  Result := inherited Parse(datastream);
  ret := wpNoError;
  ReadEntity := FALSE;
  FIgnoreText := FALSE;
  EscapeCloseTagActive := FALSE;
  FReadingVariable := FALSE;
  FReadingHead := FALSE;
  Entity := '';
  EscapeCloseTag := '';
  FReadStringBuffer := TWPStringBuilder.Create;
  try
    try
   // We select the body to ad the data
      SelectRTFData(wpIsBody, wpraIgnored, '');
   // and create the first paragraph
      NewParagraph;
      repeat
        ch := ReadChar;
        if ch <= 0 then break
        else
      // Support entities without closing ";" ----------------------------------
          if ReadEntity then
          begin
            if (ch = Integer(';')) or (ch <= 32) then
            begin
              if not FIgnoreText then
              begin
                PrintAChar('&');
                for ch2 := 1 to Length(Entity) do
                  PrintAChar(Entity[ch2]);
              end;
              ReadEntity := FALSE;
            end
            else
            begin
              Entity := Entity + AnsiChar(ch);
              ch2 := WPTranslateEntity(Entity); //<-- Translate &uml; , &gt; etc.
              if ch2 > 0 then
              begin
                if not FIgnoreText then
                begin
                  PrintWideChar(WideChar(ch2));
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
            FReadStringBuffer.AppendChar(Char(ch));
          end;
        end else
          if ch = Integer('&') then
          begin
            ch := ReadChar;
            if ch = Integer('#') then
            begin
              ch := ReadInteger;
              if (ch > 0) and not FIgnoreText then PrintWideChar(WideChar(ch));
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
            try
            aSpanObj := PrintTextObj(wpobjSPANStyle,
                                          aTag.Name,
                                          Trim(TrimRight(aTag.Text)),
                                          (aTag.Typ in [wpXMLOpeningTag, wpXMLClosingTag]) and
                                          not (aTag.NameEqual('hr') or
                                               aTag.NameEqual('br') or
                                               aTag.NameEqual('img') ),
                                          aTag.Typ = wpXMLClosingTag,
                                          false);
            if ((aTag.Typ = wpXMLClosingTag) and
                 (aTag.NameEqual('table') or
                  aTag.NameEqual('tr') or
                  aTag.NameEqual('p')))or
                ((aTag.Typ = wpXMLOpeningTag) and
                 aTag.NameEqual('table')) then NewParagraph;

            finally
              aTag.Free;
            end;
          end
          else
          if FReadingVariable then
               FReadStringBuffer.AppendChar(Char(ch))
          else
          if not FReadingHead and not FIgnoreText and not
               (FCurrentParagraph.ParagraphType in [wpIsTable, wpIsTableRow]) then
          if FReadingPRE and (ch = 13) then
               NewParagraph
          else if (ch <> 13) and (ch>0)and (ch <> 10) then
               PrintAChar(Char(ch));
      until ret <> wpNoError;
      ResetReadBuffer;
    except
      FReadingError := TRUE;
      raise;
    end;
  finally
    FReadStringBuffer.Free;
  end;
end;



initialization

  if GlobalWPToolsCustomEnviroment <> nil then
  begin
    GlobalWPToolsCustomEnviroment.RegisterReader([TWPHTMLTagReader]);
    GlobalWPToolsCustomEnviroment.RegisterWriter([TWPHTMLTagWriter]);
  end;

{$ENDIF T2H}

end.

