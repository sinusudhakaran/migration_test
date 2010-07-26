unit HTMLUtils;

interface

uses
  Classes,
  ComCtrls;

const
  cHTMLPrnHeaderHeader =
    '<html>' + #13#10 +
    '<head>' + #13#10 +
    '<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">' + #13#10 +
    '<meta name=Generator content="BankLink internal print engine">' + #13#10 +
    '<!-- BLPrn_BankLinkPrint -->'; // A "signature" of BankLink print format. Do not print in text mode without it!

  cHTMLPrnStyleDef =
    '<style type="text/css">' + #13#10 +
    '<!--' + #13#10 +
    '  body  {font-size: 12.0pt; line-height: 1.0}' + #13#10 +
    // "margin-left: 80.0pt" - can be added here to make displayed version better resamble the original. Currently absent to make the document more managable.
  '  big   {font-size: 15.0pt; line-height: 1.0}' + #13#10 +
    // "line-height: 1.0" in every style definition is needed by Netscape
  '  tt    {font-size: 12.0pt; line-height: 1.0}' + #13#10 +
    '  small {font-size: 10.0pt; font-family: monospace; line-height: 1.0}' + #13#10 +
    '  code  {font-size: 8.0pt; font-family: "Lucida Console",monospace; line-height: 1.0}' + #13#10
    + // used as a "very small" font
  '  hr    {color: #eee; height: 4}' + #13#10 + // shows where pagebreak is
  '-->' + #13#10 +
    '</style>';

  cHTMLPrnHeaderTrailer =
    '</head>';

  cHTMLPrnBodyHeader =
    '<body>' + #13#10 +
    '<p><nobr>';

  cHTMLPrnBodyTrailer =
    '</nobr></p>' + #13#10 +
    '</body>' + #13#10 +
    '</html>';

procedure ConvertPrintTagsToHTML(const inFileName, outFileName, aTitle: string);
procedure ConvertPrintTagsToHTML_Stream(inStream, outStream: TStream; const inFileName, aTitle:
  string);

function ConvertRTFToHTML(const RTF: string): string;
function ConvertRichEditToHTML(ARichEdit: TRichEdit): string;

implementation

uses
  SysUtils,
  StreamIO,
  Graphics,
  Forms;

procedure ConvertPrintTagsToHTML_TextFile(var inFile, outFile: TextFile; const inFileName, aTitle:
  string);
var
  line: string;
  lineLen: integer;
  currPos: integer;

  procedure WriteOut(aStr: string);
  begin
    write(outFile, aStr);
  end;

  procedure WriteLnOut(aStr: string);
  begin
    write(outFile, aStr + #13#10); // normal writeln on a file open on stream will insert LF only
  end;

  function convertSpec(const c: char): string;
  begin
    if c = '"' then
      result := '&quot;'
    else
      if c = '&' then
        result := '&amp;'
      else
        if c = '<' then
          result := '&lt;'
        else
          if c = '>' then
            result := '&gt;'
          else
            result := c;
  end;

  function NextTag(var aTag, aText: string): boolean;
    // returns True on end of line
  begin
    aTag := '';
    aText := '';
    result := False;
    if (currPos <= lineLen) and (line[currPos] = '<') then // this tag
      begin
        inc(currPos);
        while (currPos <= lineLen) and (line[currPos] <> '>') do
          begin
            if (line[currPos] >= ' ') and (line[currPos] < #160) then // just in case...
              if line[currPos] = '<' then
                aTag := aTag + '&lt;'
              else
                aTag := aTag + line[currPos]
            else
              aTag := aTag + ' ';
            inc(currPos);
          end;
        if (currPos <= lineLen) and (line[currPos] = '>') then
          inc(currPos)
        else
          aTag := ''; // tag is invalid
        aTag := LowerCase(aTag);
      end;
    if (currPos > lineLen) then // tag ends the line
      begin
        result := True;
        exit;
      end;
    if (currPos <= lineLen) and (line[currPos] = '<') then // next tag found
      exit;
    while (currPos <= lineLen) and (line[currPos] <> '<') do
      begin
        if (line[currPos] > ' ') and (line[currPos] <= #160) then
          aText := aText + convertSpec(line[currPos])
        else
          if line[currPos] = ' ' then
            aText := aText + #160 // replace spaces with no-break spaces
          else
            aText := aText + ' '; // just in case we get rubbish here
        inc(currPos);
      end;
    result := (currPos > lineLen);
  end;

var
  lastNewTag, lastOldTag: string;
  outStr: string;
  newTag, oldTag, docText: string;
  isLast: boolean;
  eqPos: integer;
begin
  WritelnOut(cHTMLPrnHeaderHeader);
  WritelnOut('<!-- BLPrn_Margin_Left=8 -->');
  // left margin for text printing only. Number of Courier 10 characters to be inserted
  WritelnOut('<!-- Converted from old print format on: ' + DateTimeToStr(Now) + ' -->');
  WritelnOut('<!-- Input file name: ' + StringReplace(inFileName, '''', '&quot;', [rfReplaceAll]) + ' -->');
  WritelnOut('<title>' + aTitle + '</title>');
  WritelnOut(cHTMLPrnStyleDef);
  WritelnOut(cHTMLPrnHeaderTrailer);
  WritelnOut(cHTMLPrnBodyHeader);

  lastNewTag := '';
  lastOldTag := '';
  while not eof(inFile) do
    begin
      readln(inFile, line);
      lineLen := length(line);
      if line <> '' then
        begin
          if LowerCase(trim(line)) = '<l8>' then // make exception for single "small" line feed
            begin
              WritelnOut('<code><br></code>');
            end
          else
            begin
              currPos := 1;
              repeat
                isLast := NextTag(oldTag, docText);
                newTag := '';
                outStr := '';

                if (oldTag = 'reset') then // internal tags - only for printing
                  begin
                    WritelnOut('<!-- BLPrn_Reset -->');
                    oldTag := LastOldTag;
                  end;
                if (oldTag = 'newpage') then
                  begin
                    WritelnOut('<!-- BLPrn_NewPage --><hr>');
                    // horizontal line is not supposed to be printed. It just marks a page break in preview.
                    oldTag := LastOldTag;
                  end;
                if (oldTag = 'a4') then
                  begin
                    WritelnOut('<!-- BLPrn_Size=A4 -->');
                    oldTag := LastOldTag;
                  end;
                if (oldTag = 'lower') then
                  begin
                    WritelnOut('<!-- BLPrn_Tray=Lower -->');
                    oldTag := LastOldTag;
                  end;
                if (oldTag = 'upper') then
                  begin
                    WritelnOut('<!-- BLPrn_Tray=Upper -->');
                    oldTag := LastOldTag;
                  end;
                if (oldTag = 'portrait') then
                  begin
                    WritelnOut('<!-- BLPrn_Orientation=Portrait -->');
                    oldTag := LastOldTag;
                  end;
                if (oldTag = 'landscape') then
                  begin
                    WritelnOut('<!-- BLPrn_Orientation=Landscape -->');
                    oldTag := LastOldTag;
                  end;
                if (copy(oldTag, 1, 14) = 'document title') then
                  begin
                    eqPos := Pos('=', oldTag);
                    if eqPos > 0 then
                      WritelnOut('<!-- BLPrn_DocumentTitle="' + Copy(oldTag, eqPos + 1, 255) +
                        '" -->'); // many documents can be present in one file
                    oldTag := LastOldTag;
                  end;
                if (oldTag = 'l6') or (oldTag = 'l8') then // LPI tags can be completely ignored
                  oldTag := LastOldTag;

                LastOldTag := oldTag;

                if (oldTag = 'lmp') or (oldTag = 'normal') then
                  // these are the same as default settings
                  oldTag := '';
                if (oldTag = 'p10') or (oldTag = 'lm') then
                  newTag := 'tt';
                if oldTag = 'p12' then
                  newTag := 'small';
                if oldTag = 'p17' then
                  newTag := 'code';
                if oldTag = 'lmpb' then
                  newTag := 'b';
                if oldTag = 'big' then
                  newTag := 'big';

                lastNewTag := newTag;

                if isLast and (not eof(inFile)) then
                  docText := docText + '<br>'; // do not insert additional line breaks

                if (newTag <> '') and (docText <> '') then
                  outStr := '<' + newTag + '>';
                if (docText <> '') then
                  outStr := outStr + docText;
                if (newTag <> '') and (docText <> '') then
                  outStr := outStr + '</' + newTag + '>';

                if outStr <> '' then
                  if isLast then // to make HTML code resamble original more
                    WritelnOut(outStr)
                  else
                    WriteOut(outStr);
              until isLast;
            end
        end
      else
        if (not eof(inFile)) then // do not insert additional line breaks
          begin
            outStr := '<br>';
            if lastNewTag <> '' then
              outStr := '<' + lastNewTag + '>' + outStr + '</' + lastNewTag + '>';
            WritelnOut(outStr);
          end;
    end;

  WritelnOut(cHTMLPrnBodyTrailer);
end;

procedure ConvertPrintTagsToHTML(const inFileName, outFileName, aTitle: string);
var
  inFile, outFile: TextFile;
begin
  AssignFile(inFile, inFileName);
  AssignFile(outFile, outFileName);
  Reset(inFile);
  Rewrite(outFile);
  try
    ConvertPrintTagsToHTML_TextFile(inFile, outFile, inFileName, aTitle);
  finally
    CloseFile(outFile);
    CloseFile(inFile);
  end
end;

procedure ConvertPrintTagsToHTML_Stream(inStream, outStream: TStream; const inFileName, aTitle:
  string);
var
  inFile, outFile: TextFile;
begin
  AssignStream(inFile, inStream);
  AssignStream(outFile, outStream);
  Reset(inFile);
  Rewrite(outFile);
  try
    ConvertPrintTagsToHTML_TextFile(inFile, outFile, inFileName, aTitle);
  finally
    CloseFile(outFile);
    CloseFile(inFile);
  end
end;

type
  TTextAttrBuf =
    class(TObject)
  public
    Color: TColor;
      Name: TFontName;
    Pitch: TFontPitch; // (fpDefault, fpVariable, fpFixed);
    Size: Integer; // Font size in points
    Style: TFontStyles; // (fsBold, fsItalic, fsUnderline, fsStrikeOut);
    procedure Assign(Source: TTextAttributes);
    function IsEqual(Source: TTextAttrBuf): Boolean;
  end;

procedure TTextAttrBuf.Assign(Source: TTextAttributes);
begin
  Color := Source.Color;
  Name := Source.Name;
  Pitch := Source.Pitch;
  Size := Source.Size;
  Style := Source.Style;
end;

function TTextAttrBuf.IsEqual(Source: TTextAttrBuf): Boolean;
begin
  if (Color = Source.Color) and
    (Name = Source.Name) and
    (Pitch = Source.Pitch) and
    (Size = Source.Size) and
    (Style = Source.Style) then
    IsEqual := True
  else
    IsEqual := False;
end;

function HtmlSizeFromSize(Size: Integer): string;
begin
  if Size <= 7 then
    HtmlSizeFromSize := '-2'
  else
    if Size <= 9 then
      HtmlSizeFromSize := '-1'
    else
      if Size <= 11 then
        HtmlSizeFromSize := '+0'
      else
        if Size <= 15 then
          HtmlSizeFromSize := '+1'
        else
          if Size <= 19 then
            HtmlSizeFromSize := '+2'
          else
            if Size <= 25 then
              HtmlSizeFromSize := '+3'
            else
              HtmlSizeFromSize := '+4'
end;

function SizeFromHtmlSize(Size: string): Integer;
begin
  if Size = '-2' then
    SizeFromHtmlSize := 6
  else
    if Size = '-1' then
      SizeFromHtmlSize := 8
    else
      if Size = '+0' then
        SizeFromHtmlSize := 10
      else
        if Size = '+1' then
          SizeFromHtmlSize := 14
        else
          if Size = '+2' then
            SizeFromHtmlSize := 18
          else
            if Size = '+3' then
              SizeFromHtmlSize := 24
            else
              if Size = '+4' then
                SizeFromHtmlSize := 36
              else
                SizeFromHtmlSize := 10;
end;

function HtmlAttribFromText(VorAttr, NachAttr: TTextAttrBuf): string;
const
  StdColor = clBlack;
  StdVar = 'Times New Roman';
  StdFix = 'Courier New';
  StdSize = 10;
var
  ResStr: string;
  RGB, HtmlRGB: LongInt;
begin
  ResStr := '';
  if (([fsBold] * VorAttr.Style) = []) and (([fsBold] * NachAttr.Style) <> []) then
    ResStr := ResStr + ''
  else
    if (([fsBold] * VorAttr.Style) <> []) and (([fsBold] * NachAttr.Style) = []) then
      ResStr := ResStr + '';
  if (([fsItalic] * VorAttr.Style) = []) and (([fsItalic] * NachAttr.Style) <> []) then
    ResStr := ResStr + ''
  else
    if (([fsItalic] * VorAttr.Style) <> []) and (([fsItalic] * NachAttr.Style) = []) then
      ResStr := ResStr + '';
  if (([fsUnderline] * VorAttr.Style) = []) and (([fsUnderline] * NachAttr.Style) <> []) then
    ResStr := ResStr + ''
  else
    if (([fsUnderline] * VorAttr.Style) <> []) and (([fsUnderline] * NachAttr.Style) = []) then
      ResStr := ResStr + '';
  if (VorAttr.Color <> NachAttr.Color) then
    begin
      RGB := ColorToRGB(NachAttr.Color);
      // The value $00FF0000 pure blue,
      //           $0000FF00 pure green, and
      //           $000000FF pure red.
      // HTML COLOR=#rrggbb

      HtmlRGB := ((RGB and $FF) shl 16) or // red
      (RGB and $FF00) or // green
      ((RGB and $FF0000) shr 16); // blue
      if (VorAttr.Color <> StdColor) and (NachAttr.Color = StdColor) then
        ResStr := ResStr + '</FONT>'
      else
        if (VorAttr.Color <> StdColor) and (NachAttr.Color <> StdColor) then
          ResStr := ResStr + '</FONT>' + Format('<FONT COLOR="#%6.6x">', [HtmlRGB])
        else
          if (VorAttr.Color = StdColor) and (NachAttr.Color <> StdColor) then
            ResStr := ResStr + Format('<FONT COLOR="#%6.6x">', [HtmlRGB]);
    end;
  if (VorAttr.Name <> NachAttr.Name) then
    begin
      if (VorAttr.Name = StdFix) then
        ResStr := ResStr + ''
      else
        if (VorAttr.Name <> StdVar) then
          ResStr := ResStr + '</FONT>';
      if (NachAttr.Name = StdFix) then
        ResStr := ResStr + ''
      else
        if (NachAttr.Name <> StdVar) then
          ResStr := ResStr + '<FONT FACE="' + NachAttr.Name + '">';
    end;
  if (VorAttr.Size <> NachAttr.Size) then
    begin
      if (VorAttr.Size <> StdSize) then
        ResStr := ResStr + '</FONT>';
      if (NachAttr.Size <> StdSize) then
        ResStr := ResStr + '<FONT SIZE="' + HtmlSizeFromSize(NachAttr.Size) + '">';
    end;
  Result := ResStr;
end;

function ConvertRTFToHTML(const RTF: string): string;
type
  THTMLTagState = (htsNotActivated, htsMustActivate,
    htsActivated, htsMustDeactivate);

  THTMLTagType = (hftNone, hftBold, hftUnderline, hftItalics,
    hftFont, hftParagraph);
  THTMLTagTypes = set of THTMLTagType;

  THTMLBulletType = (hbtNone, hbtListOpen, hbtListItemOpen, hbtListItemClose,
    hbtListClose, hbtBreak);

  TRTFFontState = record
    FontTable: Boolean;
    ColorTable: Boolean;
    FontList, ColorList: TStringList;
  end;

  TRTFParagraphFormat = record
    Alignment: TAlignment;
    Bullets: THTMLBulletType;
    Written: Boolean;
  end;

  TRTFTextFormat = record
    WriteFont: Boolean;
    DefaultFont: Integer;
    Font: Integer;
    FontSize: Integer;
    Color: Integer;
    Bold: THTMLTagState;
    Italics: THTMLTagState;
    Underline: THTMLTagState;
    Written: Boolean;
  end;

var
  Index: Integer; // index of the current character
  RTFParagraphFormat: TRTFParagraphFormat; //paragraph formatting record
  RTFTextFormat: TRTFTextFormat; //text formatting record
  RTFFontState: TRTFFontState; //font state record

  HTMLTagOrder: array[0..4] of THTMLTagType; //ordered array of tags
  Keyword, FullKeyword: string; //current and full RTF tag
  ActiveTags: THTMLTagTypes; //active formatting tags

  Group: Integer; //current number of groups the code is nested in
  FColor: string[10]; //RTF color information
  FFont: string[63]; //RTF font information

  procedure AddTagType(AHTMLTagType: THTMLTagType);
    {adds the current tag type to the tag array}
  var
    i: Integer;
  begin
    for i := 0 to High(HTMLTagOrder) do //loop through the array
      if HTMLTagOrder[i] = AHTMLTagType then //the tag type is already in
        Exit; //since the tag type is already there, do not add again

    //the most recent tags are in the front of the array
    for i := High(HTMLTagOrder) downto 0 do //loop from last to first
      if HTMLTagOrder[i] = hftNone then
        begin //empty space in array
          HTMLTagOrder[i] := AHTMLTagType; //set the empty entry to the tag type
          Exit; //finished, so exit
        end;
  end;

  procedure InsertTag(AHTMLTagType: THTMLTagType; var S: string);
    {Inserts the necessary tag into S --
     If UpdateArray is True, the array will be updated to include this entry}
  begin
    case AHTMLTagType of
      hftBold: //add a bold tag
        begin
          S := S + '<B>';
          RTFTextFormat.Bold := htsActivated; //update the text format record
        end;
      hftItalics: //add an italics tag
        begin
          S := S + '<I>';
          RTFTextFormat.Italics := htsActivated; //update text format record
        end;
      hftUnderline: //add an underline tag
        begin
          S := S + '<U>';
          RTFTextFormat.Underline := htsActivated; //update text format record
        end;
      hftFont: //add a font tag
        begin
          with RTFTextFormat do //create font tag with current font info
            S := S + '<FONT FACE="' + RTFFontState.FontList[Font] +
              '" COLOR="' + RTFFontState.ColorList[Color] +
              '" SIZE="' + IntToStr(FontSize) + '">';
        end;
      hftParagraph: //add a paragraph tag
        begin
          case RTFParagraphFormat.Alignment of //create aligned paragraph tag
            taLeftJustify: S := S + #13#10'<P>';
            taRightJustify: S := S + #13#10'<P ALIGN=RIGHT>';
            taCenter: S := S + #13#10'<P ALIGN=CENTER>';
          end;
        end;
    end;

    AddTagType(AHTMLTagType); //update the array
  end;

  procedure WriteEndTag(AHTMLTagType: THTMLTagType; var S: string);
    {Writes the end tag of the tag type into S and updates the record--
     ***Methods should call WriteEndTags instead, because this method does not
     update the array of tags.}
  begin
    case AHTMLTagType of
      hftBold: //write bold end tag
        begin
          S := S + '</B>';
          RTFTextFormat.Bold := htsNotActivated; //update format record
        end;
      hftItalics: //write italics end tag
        begin
          S := S + '</I>';
          RTFTextFormat.Italics := htsNotActivated; //update format record
        end;
      hftUnderline: //write underline end tag
        begin
          S := S + '</U>';
          RTFTextFormat.Underline := htsNotActivated; //update format record
        end;
      hftFont: //write font end tag
        begin
          S := S + '</FONT>';
        end;
      hftParagraph: //write paragraph end tag
        begin
          S := S + '</P>'#13#10#13#10;
        end;
    end;
  end;

  procedure WriteEndTags(var S: string; AExcludeTags: THTMLTagTypes);
    {Writes the end tags for all items in the array except for those excluded}
  var
    i: Integer;
  begin
    for i := 0 to High(HTMLTagOrder) do //loop through the array
      if not (HTMLTagOrder[i] in AExcludeTags) then
        begin //not excluded
          WriteEndTag(HTMLTagOrder[i], S); //write the end tag into S
          HTMLTagOrder[i] := hftNone; //reset the entry in the array
        end;
  end;

  procedure WriteChar(C: Char);
    {Processes the character to HTML and writes the character to the result--
     This method also checks to see if text and paragraph tags must be inserted}
  var
    S: string; //temporary string
  begin
    Application.ProcessMessages; //allow the application to process
    S := ''; //initialize the return string

    if (not RTFParagraphFormat.Written) or (not RTFTextFormat.Written) then
      //either the paragraph format or text format will be changed--
      //must keep track of the current format tags in order to deactivate,
      //add other tags, and reactivate
      with RTFTextFormat do
        begin
          ActiveTags := []; //initialize
          if Bold = htsActivated then //Bold is staying activated
            ActiveTags := ActiveTags + [hftBold]; //add Bold to set
          if Italics = htsActivated then //Italics is staying activated
            ActiveTags := ActiveTags + [hftItalics]; //add Italics to set
          if Underline = htsActivated then //Underline is staying activated
            ActiveTags := ActiveTags + [hftUnderline]; //add Underline to set
        end;

    with RTFParagraphFormat do //write the necessary paragraph tags
      if not Written then
        begin //changes must be made
          WriteEndTags(S, []); //close all open tags

          //write the proper paragraph tags
          case Bullets of
            hbtNone: //a new paragraph must be created
              begin
                InsertTag(hftParagraph, S); //insert new paragraph tag
                RTFTextFormat.WriteFont := True; //will add the new font tag
                RTFTextFormat.Written := False; //must write text format tags
              end;

            hbtListOpen: //start a list
              begin
                S := S + #13#10'<UL>'; //write the tag
                RTFTextFormat.WriteFont := True; //will add the new font tag
                RTFTextFormat.Written := False; //must write text format tags
              end;

            hbtListItemOpen: //add a new list item
              begin
                S := S + #13#10#9'<LI>'; //write the tag
                RTFTextFormat.WriteFont := True; //will add the new font tag
                RTFTextFormat.Written := False; //must write text format tags
              end;

            hbtListItemClose: //close a list item
              begin
                S := S + '</LI>'; //write the close list item tag
              end;

            hbtListClose: //close a list
              begin
                S := S + #13#10'</UL>'#13#10; //write the close list tag
                Bullets := hbtNone; //set paragraph formatting to standard (<P>)
              end;

            hbtBreak: //break -- not currently used
              begin
                S := S + '<BR>'#13#10#160#32#160#32#160; //insert a break
                Bullets := hbtNone; //set paragraph formatting to standard (<P>)
              end;
          end;

          Written := True; //flag -- the paragraph tags have been written
        end; { RTFParagraphFormat }

    with RTFTextFormat do //now write any necessary text format tags
      if (not Written) and //changes must be made
      (RTFParagraphFormat.Bullets <> hbtListOpen) then
        begin
          WriteEndTags(S, [hftFont, hftParagraph]); //write format end tags

          if WriteFont then
            begin //the font has changed--must write font
              WriteEndTags(S, [hftParagraph]); //close the font tag if necessary
              InsertTag(hftFont, S); //insert the new font tag
              WriteFont := False; //flag -- font has been written
            end;

          if (hftBold in ActiveTags) or (Bold = htsMustActivate) then
            //Bold is either currently active or must be activated
            InsertTag(hftBold, S); //insert the Bold tag
          if (hftItalics in ActiveTags) or (Italics = htsMustActivate) then
            //Italics is either currently active or must be activated
            InsertTag(hftItalics, S); //insert the Italics tag
          if (hftUnderline in ActiveTags) or (Underline = htsMustActivate) then
            //Underline is either currently active or must be activated
            InsertTag(hftUnderline, S); //insert the Underline tag

          Written := True; //flag -- text formatting tags have been handled
        end;

    //Now write the characters and tags
    case C of
      #0: Result := Result + S; // Writes pending codes only
      #9: Result := Result + S + #9; // Writes tab char
      '>': Result := Result + S + '&gt'; // Writes "greater than"
      '<': Result := Result + S + '&lt'; // Writes "less than"
    else
      Result := Result + S + C; // Writes the passed character
    end;
  end; { WriteChar }

  function Resolve(C: Char): Integer;
    {Converts the character to its integer value --
     used to decode \'## to an ansi-Value }
  begin
    case Byte(C) of
      48..57: Result := Byte(C) - 48;
      65..70: Result := Byte(C) - 55;
    else
      Result := 0;
    end;
  end; { resolve }

  function GetFullKeyword(ARTF: string; StartPos: Integer): string;
    {Returns the entire keyword for a particular key--keys are separated by ' '}
  begin
    Delete(ARTF, 1, StartPos - 1); //remove all text before the key
    Result := Copy(ARTF, 1, Pos(' ', ARTF) - 1); //return all text before ' '
  end;

  function TagInKeyword(ARTFTag: string): Boolean;
    {Returns true if a particular tag is in the current keyword (e.g. '\b')}
  begin
    Result := Pos(ARTFTag, FullKeyword) > 0; //return true if substring found
  end;

  function CollectCode(I: Integer): Integer;
    {Parses and handles the RTF code beginning at position I to convert to HTML}
  var
    Value: string;
    A: Integer;
  begin
    Keyword := ''; //initialize the keyword

    // First - check if Keyword is any "special" Keyword or is a normal one ...
    case RTF[i + 1] of //look at the current character
      '*':
        begin // Ignore all code until the end of the Group
          a := Group; //get the current embedded Group count
          repeat //loop through each character
            case RTF[i] of
              '{': Inc(Group); //another Group is opened -- increment count
              '}': Dec(Group); //a Group is closed -- decrement embedded count
            end;
            Inc(i); //go to the next character
          until (Group + 1) = a; //until the start of another Group is found
          Result := i - 1; //return the position of the Group start
        end;

      #39:
        begin // Decode hex Value
          WriteChar(Char(Resolve(UpCase(RTF[i + 2])) * 16 +
            Resolve(UpCase(RTF[i + 3]))));
          Inc(i, 3); //go three spaces ahead
          Result := i; //return the next position
        end;
      '\', '{', '}':
        begin // Return special character
          WriteChar(RTF[i + 1]); //write the character
          Inc(i); //go to the next character
          Result := i; //return the next character
        end;

    else
      begin //must be a keyword
        repeat //get the keyword
          Keyword := Keyword + RTF[i]; //add the next character to the keyword
          Inc(i); //go to the next character
        until (RTF[i] in ['{', '\', '}', ' ', ';', '-', '0'..'9']); //end of keyword

        // Second - get any Value following ...
        Value := ''; //initialize the value
        while (RTF[i] in ['a'..'z', '-', '0'..'9']) do
          begin //value exists
            Value := Value + RTF[i]; //add the character to value
            Inc(i); //go to the next character
          end;

        while (RTF[i] in ['{', '}', ';', ' ']) do //character can be ignored
          Inc(i); //ignore the current character

        Result := i - 1; //return position of previous character

        // Check which Keyword it is and perform the necessary functionality--
        // Tested--Using IF THEN ELSE is 10% more efficient than calling EXIT

        if Keyword = '\par' then //New paragraph or bullet item
          with RTFParagraphFormat do
            begin
              Written := False; //update the HTML tags
              if Bullets = hbtListItemOpen then
                begin //list item currently open
                  Bullets := hbtListItemClose; //must close the list item
                  WriteChar(#0); //write the change
                end
            end

        else
          if Keyword = '\f' then //font change
            case RTFFontState.FontTable of
              True: //must add the current font to the font list
                begin
                  FFont := ''; //initialize current font
                  while RTF[i] <> ' ' do // Ignore font family info, etc.
                    Inc(i);

                  Inc(i); //go to next character
                  while RTF[i] <> ';' do
                    begin //Read font name until ';'
                      FFont := FFont + RTF[i]; //add character to font name
                      Inc(i); //go to the next character
                    end;
                  Dec(Group); //finished a Group, so close it
                  Result := i + 1; //Move one beyond Group end
                  RTFFontState.FontList.Add(FFont); //Add font name to font list
                end;

              False:
                with RTFTextFormat do
                  begin //Use name already in font list
                    a := StrToIntDef(Value, 0); //get index of font in font list
                    if Font <> a then
                      begin //Font has changed--must make HTML tag
                        WriteFont := True; //must write the new font
                        Written := False; //have not written new text formatting yet
                        Font := a; //set the index of the current font
                      end;
                  end;
            end

          else
            if Keyword = '\plain' then //original text format
              with RTFTextFormat do
                begin //must reset all text attributes
                  FullKeyword := GetFullKeyword(RTF, i); //get full keyword
                  if (Color <> 0) and (not TagInKeyword('\cf')) then
                    begin
                      //the current color is not the default color, and the color will
                      //not be updated in this keyword--must reset color and write font
                      Color := 0; //reset the color
                      WriteFont := True; //must write the new font
                      Written := False; //have not written the new text formatting yet
                      WriteChar(#0); //write the new tags
                    end
                  else
                    begin //the color does not need to be updated
                      if (bold = htsActivated) {and (not TagInKeyword('\b'))} then
                        //Bold is no longer active, so it must be deactivated
                        Bold := htsMustDeactivate; //deactivate Bold
                      if (Italics = htsActivated) {and (not TagInKeyword('\i'))} then
                        //Italics is no longer active, so it must be deactivated
                        Italics := htsMustDeactivate; //deactivate Italics
                      if (Underline = htsActivated) {and (not TagInKeyword('\ul'))} then
                        //Underline is no longer active, so it must be deactivated
                        Underline := htsMustDeactivate; //deactivate Underline

                      if (Bold = htsMustDeactivate) or (Italics = htsMustDeactivate) or
                        (Underline = htsMustDeactivate) then
                        begin
                          //one or more attributes have changed--must write the new tags
                          Written := False; //have not written new text formatting yet
                          WriteChar(#0); //write the new tags
                        end
                      else //no attributes have changed -- no need to write anything
                        WriteFont := False; //do not update the font
                    end;
                end

            else
              if Keyword = '\fs' then //modify the font size
                with RTFTextFormat do
                  begin
                    case StrToIntDef(Value, 11) div 2 of
                      1..5: a := 1; //set an appropriate font size
                      6..9: a := 2;
                      10..11: a := 3;
                      12..13: a := 4;
                      14..15: a := 5;
                    else
                      a := 6;
                    end;
                    if a <> FontSize then
                      begin //the font size has changed
                        FontSize := a; //set the new font size
                        Written := False; //have not written the new font size yet
                        WriteFont := True; //write the new font
                      end;
                  end

              else
                if Keyword = '\tab' then //tab character
                  WriteChar(#9) //send a tab character--displayed as a space in HTML

                else
                  if Keyword = '\ul' then
                    begin //Underline is activated
                      with RTFTextFormat do
                        if Underline = htsNotActivated then
                          begin //must activate Underline
                            Underline := htsMustActivate; //activate Underline
                            Written := False; //have not written new attribute yet
                          end;
                    end
                  else
                    if Keyword = '\b' then
                      begin //Bold is activated
                        with RTFTextFormat do
                          if Bold = htsNotActivated then
                            begin //must activate Bold
                              Bold := htsMustActivate; //activate Bold
                              Written := False; //have not written new attribute yet
                            end;
                      end
                    else
                      if Keyword = '\i' then
                        begin //Italics is activated
                          with RTFTextFormat do
                            if Italics = htsNotActivated then
                              begin //must activate Italics
                                Italics := htsMustActivate; //activate Italics
                                Written := False; //have not written new attribute yet
                              end;
                        end

                      else
                        if Keyword = '\cf' then //font color has been changed
                          with RTFTextFormat do
                            begin
                              a := StrToIntDef(Value, 0); //get index of color in the color list
                              if Color <> a then
                                begin //the color has changed
                                  Color := a; //set the new color
                                  Written := False; //have not written the new color yet
                                  WriteFont := True; //write the new font
                                end;
                            end

                        else
                          if Keyword = '\qc' then
                            begin //paragraph must be centered
                              with RTFParagraphFormat do
                                if Bullets = hbtNone then
                                  begin
                                    Alignment := taCenter; //align the paragraph to center
                                    Written := False; //alignment has not been written yet
                                  end;
                            end
                          else
                            if Keyword = '\qr' then
                              begin //paragraph must be right-aligned
                                with RTFParagraphFormat do
                                  if Bullets = hbtNone then
                                    begin
                                      Alignment := taRightJustify; //align the paragraph to right
                                      Written := False; //alignment has not been written yet
                                    end;
                              end
                            else
                              if Keyword = '\pntext' then //Start bullet list item
                                with RTFParagraphFormat do
                                  begin
                                    Written := False; //have not written the bullet tag yet
                                    Bullets := hbtListItemOpen;
                                    //the current item is a new list item
                                    a := Group; //get current embedded group count
                                    repeat //go through the RTF until a group is closed
                                      case RTF[i] of
                                        '{': Inc(Group); //new group to open--increment Group
                                        '}': Dec(Group); //group is closed--decrement Group
                                      end;
                                      Inc(i); //go to the next character
                                    until (Group + 1) = a;
                                    //until the end of a group has been reached
                                    Result := i - 1; //go to the end of the group
                                  end

                              else
                                if Keyword = '\fi' then //a bullet list must be started
                                  with RTFParagraphFormat do
                                    begin
                                      Written := False; //bullet tag has not been written
                                      Bullets := hbtListOpen;
                                      //the current bullet type is an open list
                                      WriteChar(#0); //write the open list tag
                                    end

                                else
                                  if Keyword = '\pard' then //end of paragraph / bullet list
                                    with RTFParagraphFormat do
                                      begin
                                        Alignment := taLeftJustify;
                                        //reset the paragraph alignment to left
                                        Written := False;
                                        //have not written the paragraph change yet
                                        if Bullets <> hbtNone then
                                          begin //currently in an open bullet list
                                            Bullets := hbtListClose; //close the bullet list
                                            WriteChar(#0); //write the close list tag
                                          end;
                                      end

                                  else
                                    if Keyword = '\red' then //setting red color
                                      FColor := '#' + IntToHex(StrToIntDef(Value, 255), 2)
                                        //Get red color
                                    else
                                      if Keyword = '\green' then //setting green color
                                        FColor := FColor + IntToHex(StrToIntDef(Value, 255), 2)
                                          //Get color
                                      else
                                        if Keyword = '\blue' then
                                          begin //setting blue color--finished
                                            FColor := FColor + IntToHex(StrToIntDef(Value, 255),
                                              2);
                                            //Get color
                                            RTFFontState.ColorList.Add(FColor);
                                            //Add RGB to the color list
                                          end

                                        else
                                          if Keyword = '\deff' then //default font index
                                            with RTFTextFormat do
                                              DefaultFont := StrToIntDef(Value, 0)
                                                //set the default font index

                                          else
                                            if Keyword = '\fonttbl' then
                                              //must create an entry in font list
                                              RTFFontState.FontTable := True
                                                //initialize creation of font list
                                            else
                                              if Keyword = '\colortbl' then
                                                //must create a color list
                                                RTFFontState.ColorTable := True
                                                  //must create an entry in color list

                                              else
                                                if Keyword = '\deflang' then
                                                  begin //Update is finished
                                                    RTFFontState.FontTable := False;
                                                    //finished creating font list entry
                                                    with RTFParagraphFormat do
                                                      begin // reset paragraph format
                                                        Alignment := taLeftJustify;
                                                        //reset paragraph alignment to left
                                                        Written := False;
                                                        //have not written new paragraph tags yet
                                                        Bullets := hbtNone;
                                                        //reset bullets to standard paragraphs
                                                      end;
                                                    with RTFTextFormat do
                                                      begin //reset font format
                                                        Font := DefaultFont;
                                                        //set the font index to the default index
                                                        FontSize := 3;
                                                        //reset the font size to default
                                                        Color := 0;
                                                        //reset the color index to the default index
                                                        Bold := htsNotActivated; //initialize bold
                                                        Italics := htsNotActivated;
                                                        //initialize italics
                                                        Underline := htsNotActivated;
                                                        //initialize underline
                                                        Written := False;
                                                        //have not written the new font settings yet
                                                      end;
                                                    RTFFontState.ColorTable := True;
                                                    //must start creating color entry
                                                  end;
      end;
    end;
  end;

  function CleanUp(S: string): string;
    {Occurs when the HTML code has been completed--
     Closes any remaining open tags and returns the updated code}
  begin
    WriteEndTags(S, []);
    Result := S;
  end;

var
  i: Integer;
begin
  try
    for i := 0 to High(HTMLTagOrder) do //loop through entire array
      HTMLTagOrder[i] := hftNone; //initialize the entire array to hftNone

    RTFFontState.FontList := TStringList.Create; //Create font list
    RTFFontState.ColorList := TStringList.Create; //Create color list

    RTFParagraphFormat.Written := True; //initialize
    RTFTextFormat.Written := True; //initialize--will be false on first format

    Index := 0; //initialize the index
    Result := ''; //initialize the result
    repeat
      Inc(Index); //go to the next character
      case RTF[Index] of
        #0..#31: ; //ASCII control characters -- ignore
        '{': Inc(Group); //new group -- increment embedded group count
        '}': Dec(Group); //closed group -- decrement embedded group count
        '\': Index := CollectCode(Index); //RTF keyword--update HTML tags

      else
        begin //a standard character -- just write it to the result
          WriteChar(RTF[Index]); //Write char and any pending HTML codes
          Inc(Index); //Speed-write normal characters until next special one
          while (Index < Length(RTF)) and
            not (RTF[Index] in ['{', '}', '\', '<', '>', #00..#31]) do
            begin
              //have not reached end of RTF yet and current character is standard
              Result := Result + RTF[Index]; //add current character to result
              Inc(Index); //go to next result
            end;
          Dec(Index); //go back one character (incremented one too many times)
        end;
      end;
    until Index = Length(RTF); //until all code has been processed
  finally
    Result := CleanUp(Result); //Return the completed HTML document
    with RTFFontState do
      begin
        FontList.Free; //destroy the font list
        ColorList.Free; //destroy the color list
      end;
  end;
end;

function ConvertRichEditToHTML(ARichEdit: TRichEdit): string;
var
  MS: TMemoryStream;
  RichText: string;
begin
  RichText := '';
  MS := TMemoryStream.Create; //create a memory stream
  try
    ARichEdit.Lines.SaveToStream(MS); //save the RTF text to stream
    RichText := PChar(MS.Memory); //get the resulting text stream
    Result := ConvertRTFToHTML(RichText);
  finally
    MS.Free; //destroy the memory stream
  end;
end;

end.

