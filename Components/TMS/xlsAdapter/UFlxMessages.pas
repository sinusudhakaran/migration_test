unit UFlxMessages;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}
{$IFDEF LINUX}{$INCLUDE ../FLXCONFIG.INC}{$ELSE}{$INCLUDE ..\FLXCONFIG.INC}{$ENDIF}

interface
uses {$IFNDEF LINUX} Windows, {$ENDIF}
     {$IFDEF ConditionalExpressions}{$if CompilerVersion >= 14} variants, varutils, {$IFEND}{$ENDIF} //Delphi 6 or above
     {$IFNDEF ConditionalExpressions}ActiveX,{$ENDIF} //Delphi 5
     Classes, SysUtils;

const
  FLX_VAR_LOCALE_USER_DEFAULT = $400;

resourcestring
  FieldStr='##';
  DataSetStr='__';
  VarStr='#.';

  StrOpen='<';
  StrClose='>';


  ExtrasDelim='...';
  MarkedRowStr='...delete row...';  //Remember to change ExtrasDelim if changing this
  HPageBreakStr='...page break...'; //Remember to change ExtrasDelim if changing this
  FullDataSetStr='*';
  MainTxt='MAIN'; //This is not strictly necessary... just for checking the template
  RecordCountPrefix='RC_';

  DefaultDateTimeFormat='mm/dd/yyyy hh:mm';

  FlexCelVersion='2.6.26';
{$IFDEF SPANISH}
  {$INCLUDE FlxSpanish.inc}
{$ELSE}
{$IFDEF FRENCH}
  {$INCLUDE FlxFrench.inc}
{$ELSE}
{$IFDEF ITALIAN}
  {$INCLUDE FlxItalian.inc}
{$ELSE}
{$IFDEF ROMANIAN}
  {$INCLUDE FlxRomanian.inc}
{$ELSE}
{$IFDEF PORTUGUESEBR}
  {$INCLUDE FlxPortugueseBR.inc}
{$ELSE}
{$IFDEF CHINESE}
  {$INCLUDE FlxChinese.inc}
{$ELSE}
{$IFDEF RUSSIAN}
  {$INCLUDE FlxRussian.inc}
{$ELSE}
{$IFDEF GERMAN}
  {$INCLUDE FlxGerman.inc}
{$ELSE}
{$IFDEF POLISH}
  {$INCLUDE FlxPolish.inc}
{$ELSE}
{$IFDEF FINNISH}
  {$INCLUDE FlxFinnish.inc}
{$ELSE}
  {$INCLUDE FlxEnglish.inc}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}

  xls_Emf='EMF';
  xls_Wmf='WMF';
  xls_Jpeg='JPEG';
  xls_Png='PNG';

  FlexCelTempPrefix = 'flx';

type
  TClientAnchor= packed record
    Flag,
    Col1, Dx1, Row1, Dy1,
    Col2, Dx2, Row2, Dy2: word;
  end;
  PClientAnchor = ^TClientAnchor;

  WidestringArray=array of widestring;
  WideCharArray=array of widechar;
  BooleanArray = Array of Boolean;


  TPrinterDriverSettings = record
    OperatingEnviroment: word;

    //When OperatingEnviroment=0 (windows) you can cast this Data to a DevMode struct.
    Data: array of byte;
  end;

  TExcelPaperSize = integer;

  const
       Date1904Diff = 4 * 365 + 2;

        /// <summary>Not defined.</summary>
        TExcelPaperSize_Undefined=0;
        ///<summary>Letter - 81/2"" x 11""</summary>
        TExcelPaperSize_Letter=1;
        ///<summary>Letter small - 81/2"" x 11""</summary>
        TExcelPaperSize_Lettersmall=2;
        ///<summary>Tabloid - 11"" x 17""</summary>
        TExcelPaperSize_Tabloid=3;
        ///<summary>Ledger - 17"" x 11""</summary>
        TExcelPaperSize_Ledger=4;
        ///<summary>Legal - 81/2"" x 14""</summary>
        TExcelPaperSize_Legal=5;
        ///<summary>Statement - 51/2"" x 81/2""</summary>
        TExcelPaperSize_Statement=6;
        ///<summary>Executive - 71/4"" x 101/2""</summary>
        TExcelPaperSize_Executive=7;
        ///<summary>A3 - 297mm x 420mm</summary>
        TExcelPaperSize_A3=8;
        ///<summary>A4 - 210mm x 297mm</summary>
        TExcelPaperSize_A4=9;
        ///<summary>A4 small - 210mm x 297mm</summary>
        TExcelPaperSize_A4small=10;
        ///<summary>A5 - 148mm x 210mm</summary>
        TExcelPaperSize_A5=11;
        ///<summary>B4 (JIS) - 257mm x 364mm</summary>
        TExcelPaperSize_B4_JIS=12;
        ///<summary>B5 (JIS) - 182mm x 257mm</summary>
        TExcelPaperSize_B5_JIS=13;
        ///<summary>Folio - 81/2"" x 13""</summary>
        TExcelPaperSize_Folio=14;
        ///<summary>Quarto - 215mm x 275mm</summary>
        TExcelPaperSize_Quarto=15;
        ///<summary>10x14 - 10"" x 14""</summary>
        TExcelPaperSize_s10x14=16;
        ///<summary>11x17 - 11"" x 17""</summary>
        TExcelPaperSize_s11x17=17;
        ///<summary>Note - 81/2"" x 11""</summary>
        TExcelPaperSize_Note=18;
        ///<summary>Envelope #9 - 37/8"" x 87/8""</summary>
        TExcelPaperSize_Envelope9=19;
        ///<summary>Envelope #10 - 41/8"" x 91/2""</summary>
        TExcelPaperSize_Envelope10=20;
        ///<summary>Envelope #11 - 41/2"" x 103/8""</summary>
        TExcelPaperSize_Envelope11=21;
        ///<summary>Envelope #12 - 43/4"" x 11""</summary>
        TExcelPaperSize_Envelope12=22;
        ///<summary>Envelope #14 - 5"" x 111/2""</summary>
        TExcelPaperSize_Envelope14=23;
        ///<summary>C - 17"" x 22""</summary>
        TExcelPaperSize_C=24;
        ///<summary>D - 22"" x 34""</summary>
        TExcelPaperSize_D=25;
        ///<summary>E - 34"" x 44""</summary>
        TExcelPaperSize_E=26;
        ///<summary>Envelope DL - 110mm x 220mm</summary>
        TExcelPaperSize_EnvelopeDL=27;
        ///<summary>Envelope C5 - 162mm x 229mm</summary>
        TExcelPaperSize_EnvelopeC5=28;
        ///<summary>Envelope C3 - 324mm x 458mm</summary>
        TExcelPaperSize_EnvelopeC3=29;
        ///<summary>Envelope C4 - 229mm x 324mm</summary>
        TExcelPaperSize_EnvelopeC4=30;
        ///<summary>Envelope C6 - 114mm x 162mm</summary>
        TExcelPaperSize_EnvelopeC6=31;
        ///<summary>Envelope C6/C5 - 114mm x 229mm</summary>
        TExcelPaperSize_EnvelopeC6_C5=32;
        ///<summary>B4 (ISO) - 250mm x 353mm</summary>
        TExcelPaperSize_B4_ISO=33;
        ///<summary>B5 (ISO) - 176mm x 250mm</summary>
        TExcelPaperSize_B5_ISO=34;
        ///<summary>B6 (ISO) - 125mm x 176mm</summary>
        TExcelPaperSize_B6_ISO=35;
        ///<summary>Envelope Italy - 110mm x 230mm</summary>
        TExcelPaperSize_EnvelopeItaly=36;
        ///<summary>Envelope Monarch - 37/8"" x 71/2""</summary>
        TExcelPaperSize_EnvelopeMonarch=37;
        ///<summary>63/4 Envelope - 35/8"" x 61/2""</summary>
        TExcelPaperSize_s63_4Envelope=38;
        ///<summary>US Standard Fanfold - 147/8"" x 11""</summary>
        TExcelPaperSize_USStandardFanfold=39;
        ///<summary>German Std. Fanfold - 81/2"" x 12""</summary>
        TExcelPaperSize_GermanStdFanfold=40;
        ///<summary>German Legal Fanfold - 81/2"" x 13""</summary>
        TExcelPaperSize_GermanLegalFanfold=41;
        ///<summary>B4 (ISO) - 250mm x 353mm</summary>
        TExcelPaperSize_B4_ISO_2=42;
        ///<summary>Japanese Postcard - 100mm x 148mm</summary>
        TExcelPaperSize_JapanesePostcard=43;
        ///<summary>9x11 - 9"" x 11""</summary>
        TExcelPaperSize_s9x11=44;
        ///<summary>10x11 - 10"" x 11""</summary>
        TExcelPaperSize_s10x11=45;
        ///<summary>15x11 - 15"" x 11""</summary>
        TExcelPaperSize_s15x11=46;
        ///<summary>Envelope Invite - 220mm x 220mm</summary>
        TExcelPaperSize_EnvelopeInvite=47;
        ///<summary>Undefined - </summary>
        ///<summary>Letter Extra - 91/2"" x 12""</summary>
        TExcelPaperSize_LetterExtra=50;
        ///<summary>Legal Extra - 91/2"" x 15""</summary>
        TExcelPaperSize_LegalExtra=51;
        ///<summary>Tabloid Extra - 1111/16"" x 18""</summary>
        TExcelPaperSize_TabloidExtra=52;
        ///<summary>A4 Extra - 235mm x 322mm</summary>
        TExcelPaperSize_A4Extra=53;
        ///<summary>Letter Transverse - 81/2"" x 11""</summary>
        TExcelPaperSize_LetterTransverse=54;
        ///<summary>A4 Transverse - 210mm x 297mm</summary>
        TExcelPaperSize_A4Transverse=55;
        ///<summary>Letter Extra Transv. - 91/2"" x 12""</summary>
        TExcelPaperSize_LetterExtraTransv=56;
        ///<summary>Super A/A4 - 227mm x 356mm</summary>
        TExcelPaperSize_SuperA_A4=57;
        ///<summary>Super B/A3 - 305mm x 487mm</summary>
        TExcelPaperSize_SuperB_A3=58;
        ///<summary>Letter Plus - 812"" x 1211/16""</summary>
        TExcelPaperSize_LetterPlus=59;
        ///<summary>A4 Plus - 210mm x 330mm</summary>
        TExcelPaperSize_A4Plus=60;
        ///<summary>A5 Transverse - 148mm x 210mm</summary>
        TExcelPaperSize_A5Transverse=61;
        ///<summary>B5 (JIS) Transverse - 182mm x 257mm</summary>
        TExcelPaperSize_B5_JIS_Transverse=62;
        ///<summary>A3 Extra - 322mm x 445mm</summary>
        TExcelPaperSize_A3Extra=63;
        ///<summary>A5 Extra - 174mm x 235mm</summary>
        TExcelPaperSize_A5Extra=64;
        ///<summary>B5 (ISO) Extra - 201mm x 276mm</summary>
        TExcelPaperSize_B5_ISO_Extra=65;
        ///<summary>A2 - 420mm x 594mm</summary>
        TExcelPaperSize_A2=66;
        ///<summary>A3 Transverse - 297mm x 420mm</summary>
        TExcelPaperSize_A3Transverse=67;
        ///<summary>A3 Extra Transverse - 322mm x 445mm</summary>
        TExcelPaperSize_A3ExtraTransverse=68;
        ///<summary>Dbl. Japanese Postcard - 200mm x 148mm</summary>
        TExcelPaperSize_DblJapanesePostcard=69;
        ///<summary>A6 - 105mm x 148mm</summary>
        TExcelPaperSize_A6=70;
        ///<summary>Letter Rotated - 11"" x 81/2""</summary>
        TExcelPaperSize_LetterRotated=75;
        ///<summary>A3 Rotated - 420mm x 297mm</summary>
        TExcelPaperSize_A3Rotated=76;
        ///<summary>A4 Rotated - 297mm x 210mm</summary>
        TExcelPaperSize_A4Rotated=77;
        ///<summary>A5 Rotated - 210mm x 148mm</summary>
        TExcelPaperSize_A5Rotated=78;
        ///<summary>B4 (JIS) Rotated - 364mm x 257mm</summary>
        TExcelPaperSize_B4_JIS_Rotated=79;
        ///<summary>B5 (JIS) Rotated - 257mm x 182mm</summary>
        TExcelPaperSize_B5_JIS_Rotated=80;
        ///<summary>Japanese Postcard Rot. - 148mm x 100mm</summary>
        TExcelPaperSize_JapanesePostcardRot=81;
        ///<summary>Dbl. Jap. Postcard Rot. - 148mm x 200mm</summary>
        TExcelPaperSize_DblJapPostcardRot=82;
        ///<summary>A6 Rotated - 148mm x 105mm</summary>
        TExcelPaperSize_A6Rotated=83;
        ///<summary>B6 (JIS) - 128mm x 182mm</summary>
        TExcelPaperSize_B6_JIS=88;
        ///<summary>B6 (JIS) Rotated - 182mm x 128mm</summary>
        TExcelPaperSize_B6_JIS_Rotated=89;
        ///<summary>12x11 - 12"" x 11""</summary>
        TExcelPaperSize_s12x11=90;

const
  DefColWidthAdapt: integer=Round(256*8/7);  //font used here is 8 pixels wide, not 7

  //Printer Options
  fpo_LeftToRight = $01;  //Print over, then down
  fpo_Orientation = $02;  //0= landscape, 1=portrait
  fpo_NoPls       = $04;  //if 1, then PaperSize, Scale, Res, VRes, Copies, and Landscape data have not been obtained from the printer, so they are not valid.
  fpo_NoColor     = $08;  //1= Black and white
  fpo_Draft       = $10;  //1= Draft quality
  fpo_Notes       = $20;  //1= Print Notes
  fpo_NoOrient    = $40;  //1=orientation not set
  fpo_UsePage     = $80;  //1=use custom starting page number.

  /// <summary>
  /// List of internal range names.
  /// On Excel, internal range names like "Print_Range" are stored as a 1 character string.
  /// This is the list of the names and their value.
  /// </summary>
  InternalNameRange_Consolidate_Area  = char($00);
  InternalNameRange_Auto_Open         = char($01);
  InternalNameRange_Auto_Close        = char($02);
  InternalNameRange_Extract           = char($03);
  InternalNameRange_Database          = char($04);
  InternalNameRange_Criteria          = char($05);
  InternalNameRange_Print_Area        = char($06);
  InternalNameRange_Print_Titles      = char($07);
  InternalNameRange_Recorder          = char($08);
  InternalNameRange_Data_Form         = char($09);
  InternalNameRange_Auto_Activate     = char($0A);
  InternalNameRange_Auto_Deactivate   = char($0B);
  InternalNameRange_Sheet_Title       = char($0C);


var
  ColMult:extended=256/7; //36.6;
  RowMult:extended=15;


type
  TColorPaletteRange=1..56;

  TXlsCellRange=record
    Left, Top, Right, Bottom: integer;
  end;

  {$IFNDEF ConditionalExpressions}     //delphi 5
  TSize = tagSIZE;
  {$ENDIF}


  /// <summary>
  /// An Excel named range.
  /// </summary>
  TXlsNamedRange=record
    /// <summary>
    /// The name of the range.
    /// </summary>
    Name: string;

    /// <summary>
    /// This is a formula defining the range. It can be used to define complex ranges.
    /// For example you can use "=Sheet1!$A1:$B65536,Sheet1!$A1:$IV2".
    /// </summary>
    /// <remarks>
    /// Do not use ranges like "A:B" this is not supported by FlexCel. Always use the full name (A1:B65536).
    /// </remarks>
    RangeFormula: string;

    /// <summary>
    /// Options of the range as an integer.
    /// Bit   Mask   Description
    ///   0  0001h   = 1 if the name is hidden
    ///   1  0002h   = 1 if the name is a function
    ///   2  0004h   = 1 if the name is a Visual Basic procedure
    ///   3  0008h   = 1 if the name is a function or command name on a macro sheet
    ///   4  0010h   = 1 if the name contains a complex function
    ///   5  0020h   = 1 if the name is a built-in name. (NOTE: When setting a built in named range, this bit is automatically set)
    /// </summary>
    OptionFlags: integer;

    /// <summary>
    /// The sheet index for the name (1 based). A named range can have the same name than other
    /// as long as they are on different sheets. The default value(0) means a global named range, not tied to
    /// any specific sheet.
    /// </summary>
    NameSheetIndex: integer;
  end;

  //Clears the named range.
  procedure InitializeNamedRange(var NamedRange: TXlsNamedRange);

  type
  TXlsMargins=packed record  //C++ builder gets this struct wrong if we use a normal record.
    Left, Top, Right, Bottom: extended;
    Header, Footer: extended;
  end;

  TXlsSheetVisible=
    (sv_Visible, sv_Hidden, sv_VeryHidden);

  TRTFRun= record
    FirstChar: word;
    FontIndex: word;
  end;

  TRTFRunList= array of TRTFRun;

  TRichString= record
    Value: widestring;
    RTFRuns: TRTFRunList;
  end;

  THyperLinkType=
    (hl_URL, hl_LocalFile, hl_UNC, hl_CurrentWorkbook);

  THyperLink= record
    LinkType: THyperLinkType;
    Description: widestring;
    TargetFrame: widestring;
    TextMark: widestring;
    Text: widestring;
    Hint: widestring;
  end;


type
  TOnGetFileNameEvent  = procedure (Sender: TObject; const  FileFormat: integer; var Filename: TFileName) of object;
  TOnGetOutStreamEvent = procedure (Sender: TObject; const  FileFormat: integer; var OutStream: TStream) of object;

  TXlsImgTypes = (xli_Emf, xli_Wmf, xli_Jpeg, xli_Png, xli_Bmp, xli_Unknown);

  VariantArray=Array [0..maxint div sizeof(Variant)-1]of variant;
  ArrayOfVariant=Array of Variant;

  TXlsCellValue= record
    Value: variant;
    XF: integer;
    IsFormula: boolean;
  end;

  {$IFDEF  VER130}
  {$DEFINE NOFORMATSETTINGS}
  {$ENDIF}
  {$IFDEF ConditionalExpressions}{$if CompilerVersion < 15}
  {$DEFINE NOFORMATSETTINGS}
  {$IFEND}{$ENDIF} //Delphi 6

  {$IFDEF NOFORMATSETTINGS}
  TFormatSettings = record
  end;
  {$ENDIF}

  PFormatSettings = ^TFormatSettings;

  TFlxAnchorType=(at_MoveAndResize, at_MoveAndDontResize, at_DontMoveAndDontResize);

  TImageProperties=record
    Col1, dx1, Row1, dy1, Col2, dx2, Row2, dy2:integer;
    FileName: widestring;  //Not really needed to set.
  end;


  function SearchPathStr(const AFileName: String): String;
  {$IFDEF  VER130}
  function IncludeTrailingPathDelimiter(const S: string): string;
  function VarIsClear(const v: variant): boolean;
  function PosEx(const SubStr, S: widestring; Offset: Cardinal): Integer;
  function TryStrToInt(const s: string; var i: integer): boolean;
  function TryStrToFloat(const s: string; var i: extended): boolean;
  {$ENDIF}

  {$IFDEF NOFORMATSETTINGS}
  procedure GetLocaleFormatSettings(LCID: Integer; var FormatSettings: TFormatSettings);
  {$ENDIF}

  procedure EnsureAMPM(var FormatSettings: PFormatSettings);
  function TryStrToFloatInvariant(const s: string; var i: extended): boolean;

  {$IFDEF ConditionalExpressions}{$if CompilerVersion < 15}
  function PosEx(const SubStr, S: widestring; Offset: Cardinal): Integer;
  {$IFEND}{$ENDIF} //Delphi 6


  function WideUpperCase98(const s: widestring):widestring;

  function StringReplaceSkipQuotes(const S, OldPattern, NewPattern: widestring): widestring;
  function FlxTryStrToDateTime(const S: widestring; out Value: TDateTime; var dFormat: widestring; var HasDate, HasTime: boolean; const DateFormat: widestring=''; const TimeFormat: widestring=''): Boolean;
  function TryFormatDateTime(const Fmt: string; value: TDateTime): string;
  function TryFormatDateTime1904(const Fmt: string; value: TDateTime; const Dates1904: boolean): string; overload;
  function TryFormatDateTime1904(const Fmt: string; value: TDateTime; const Dates1904: boolean; const LocalSettings: TFormatSettings): string; overload;

  function OffsetRange(const CellRange: TXlsCellRange; const DeltaRow, DeltaCol: integer): TXlsCellRange;

  //Returns "A" for column 1, "B"  for 2 and so on
  function EncodeColumn(const C: integer): string;

  function GetDefaultLocaleFormatSettings: PFormatSettings;

implementation

function EncodeColumn(const C: integer): string;
var
  Delta: integer;
begin
  Delta:=Ord('Z')-Ord('A')+1;
  if C<=Delta then Result:=chr(Ord('A')+C-1) else
    Result:=EncodeColumn(((C-1) div Delta))+ chr(Ord('A')+(C-1) mod Delta);
end;

{$IFDEF FLX_VCL}
function SearchPathStr(const AFileName: String): String;
var
  FilePart: PChar;
begin
  SetLength(Result, MAX_PATH + 1);

  if SearchPath(nil, PChar(AFileName), '.xls',
                MAX_PATH, PChar(Result), FilePart) <> 0 then
  begin
    SetLength(Result, Length(PChar(Result)));
  end
  else
    Raise Exception.CreateFmt(ErrCantFindFile,[AFileName]);
end; // SearchRecStr
{$ELSE}
function SearchPathStr(const AFileName: String): String;
begin
  //We dont search for templates in linux
  if not FileExists(AFileName) then Raise Exception.CreateFmt(ErrCantFindFile,[AFileName]);
  Result:=AFileName;
end; // SearchRecStr
{$ENDIF}

{$IFDEF  VER130}
function IncludeTrailingPathDelimiter(const S: string): string;
begin
  Result:=IncludeTrailingBackslash(s);
end;

function VarIsClear(const v: variant): boolean;
begin
  Result:=VarIsNull(v);
end;

function TryStrToInt(const s: string; var i: integer): boolean;
var
  errcode: integer;
begin
  val(s, i, errcode);
  Result:= errCode = 0;
end;

function TryStrToFloat(const s: string; var i: extended): boolean;
var
  errcode: integer;
begin
  val(s, i, errcode);
  Result:= errCode = 0;
end;
{$ENDIF}

{$IFDEF NOFORMATSETTINGS}
procedure GetLocaleFormatSettings(LCID: Integer; var FormatSettings: TFormatSettings);
begin
  //Not supported in Delphi 5/6
end;

procedure EnsureAMPM(var FormatSettings: PFormatSettings);
begin
end;
{$ELSE}
procedure EnsureAMPM(var FormatSettings: PFormatSettings);
begin
       //Windows uses empty AM/PM designators as empty. Excel uses AM/PM. This happens for example on German locale.
      if (FormatSettings.TimeAMString = '') then
      begin
        FormatSettings.TimeAMString := 'AM';
      end;
      if (FormatSettings.TimePMString = '') then
      begin
        FormatSettings.TimePMString := 'PM';
      end;
end;
{$ENDIF}

var
  CachedRegionalCulture: TFormatSettings;  //Cached because it is slow.

function GetDefaultLocaleFormatSettings: PFormatSettings;
begin
{$IFNDEF NOFORMATSETTINGS}
  if (CachedRegionalCulture.DecimalSeparator = #0) then GetLocaleFormatSettings(-1, CachedRegionalCulture);
{$ENDIF}
  Result:= @CachedRegionalCulture;
end;

function TryStrToFloatInvariant(const s: string; var i: extended): boolean;
var
  errcode: integer;
begin
  val(s, i, errcode);
  Result:= errCode = 0;
end;

{$UNDEF WIDEUPPEROK}
{$IFDEF ConditionalExpressions}
{$if CompilerVersion >= 18}  //Delphi 2006 or newer, this is fixed there.
{$DEFINE WIDEUPPEROK}
{$ifend}
{$ENDIF}

{$IFDEF LINUX}
{$DEFINE WIDEUPPEROK}
{$ENDIF}

{$IFDEF WIDEUPPEROK}
  function WideUpperCase98(const s: widestring):widestring;
  begin
  {$IFDEF LINUX}
    if (Length(s) = 0) then begin Result := '';exit;end; //fix for bug in kylix
  {$ENDIF}
  Result:=WideUpperCase(s);
  end;
{$ELSE}
  function WideUpperCase98(const s: widestring):widestring;
  var
    Len: Integer;
  begin
    Len := Length(S);
    SetString(Result, PWideChar(S), Len);
    if Len > 0 then CharUpperBuffW(Pointer(Result), Len);
    if GetLastError> 0 then result := UpperCase(s);
  end;
{$ENDIF}

//Defined as there is not posex on d5
function PosEx(const SubStr, S: widestring; Offset: Cardinal): Integer;
var
  i,k: integer;
  Equal: boolean;
begin
  i:= Offset;
  Result:=-1;

  while i<=Length(s)-Length(SubStr)+1 do
  begin
    if s[i]=Substr[1] then
    begin
      Equal:=true;
      for k:=2 to Length(Substr) do if s[i+k-1]<>Substr[k] then
      begin
        Equal:=false;
        break;
      end;
      if Equal then
      begin
        Result:=i;
        exit;
      end;
    end;
    inc(i);
  end;
end;

function StartsWith(const SubStr, S: widestring; Offset: integer): boolean;
var
  i: integer;
begin
  Result := false;

  if Offset - 1 + Length(SubStr) > Length(s)  then exit;

  for i := 1 to Length(SubStr) do
  begin
    if S[i + Offset - 1] <> SubStr[i] then exit;
  end;
  Result:= true;
end;

function StringReplaceSkipQuotes(const S, OldPattern, NewPattern: widestring): widestring;
var
  SearchStr, Patt: widestring;
  i,k,z: Integer;
  InQuote: boolean;
begin
  SearchStr := WideUpperCase98(S);
  Patt := WideUpperCase98(OldPattern);

  SetLength(Result, Length(SearchStr)*2);
  InQuote:=false;

  i:=1;k:=1;
  while i<= Length(SearchStr) do
  begin
    if SearchStr[i]='"' then InQuote:= not InQuote;
    if not InQuote and (StartsWith(Patt,SearchStr,i)) then
    begin
       if k+Length(NewPattern)-1>Length(Result) then SetLength(Result, k+Length(NewPattern)+100);
     for z:=1 to Length(NewPattern) do Result[z+k-1]:=NewPattern[z];
      inc(k, Length(NewPattern));
      inc(i, Length(Patt));
    end else
    begin
      if k>Length(Result) then SetLength(Result, k+100);
      Result[k]:=s[i];
      inc(i);
      inc(k);
    end;
  end;

  SetLength(Result, k-1);
end;


function DateIsOk(s: string; const v: TDateTime): boolean;
  //We have an issue with a string like '1.2.3'
  //If we are using german date separator (".") it will be converted to
  //Feb 1, 2003, which is ok. But, if we use another format, windows will think it
  //is a time, and will convert it to 1:02:03 am. That's why we added this 'patch' function.
var
  p: integer;
  i, err, k: integer;
begin
  Result:= true;
  if (Trunc(v)<>0) then exit;
  s:=s+'.';
  for i:=1 to 3 do
  begin
    p:= pos('.',s);
    if p<=0 then
    begin
      if i=3 then Result:=false;
      exit;
    end;
    val(copy(s,1,p-1), k, err);
    if (err<>0) or (k<0) then exit;
    s:=copy(s,p+1,Length(s));
  end;
  if trim(s)<'' then exit;
  Result:=false;
end;

function FlxTryStrToDateTime(const s:widestring; out Value: TDateTime; var dFormat: Widestring; var HasDate, HasTime: boolean; const DateFormat: widestring=''; const TimeFormat: widestring=''): Boolean;
var
  LResult: HResult;
  aDateFormat, aTimeFormat: widestring;
  {$IFNDEF ConditionalExpressions} //Delphi 5
    v1: olevariant;
  {$ENDIF}
begin
  if DateFormat='' then aDateFormat:=ShortDateFormat else aDateFormat:=DateFormat;
  if TimeFormat='' then aTimeFormat:=ShortTimeFormat else aTimeFormat:=TimeFormat;
  aTimeFormat:=StringReplaceSkipQuotes(aTimeFormat,'AMPM','AM/PM'); //Format AMPM is not recognized by Excel. This is harcoded on sysutils
  {$IFNDEF ConditionalExpressions} //Delphi 5. Doesn't work on kylix
    LResult:=VariantChangeType(v1, s, 0, varDate);
    Value:=v1;
  {$ELSE}
    //////////////////////READ THIS!////////////////////////////////////////////////////////////////////////////////////////
    // If you get an error here with Delphi 6, make sure to install ALL latest Delphi 6 update packs, including RTL3 update
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // available from www.borland.com
    LResult := VarDateFromStr(S, FLX_VAR_LOCALE_USER_DEFAULT, 0, Value);
  {$ENDIF}

  Result:=(LResult = 0) and DateIsOk(s,Value);  //VAR_OK doesnt work on D5;

  //We have a problem with the german date separator "." and a.m. or p.m.
  //so we cant just test for a "." inside a formula to know it includes a date.
  HasDate:=(pos('.', s)>0) or (pos('/',s)>0) or (pos('-',s)>0)   //hate to hard-code this values, but I see not other viable way
          or (pos(DateSeparator, s)>0);
  HasDate:= HasDate and (Trunc(Value)>0);
  HasTime:=(pos(':',s)>0) or (pos(TimeSeparator, s)>0);    //Again... hard-coding :-( At least is isolated here

  if not HasDate and not HasTime then Result:=false;  //Things like "1A" are converted to times, even when it doesn't make sense.
  dFormat:='';
  if HasDate then dFormat:=dFormat+aDateFormat;
  if HasTime then
  begin
    if dFormat<>'' then dFormat:=dFormat+' ';
    dFormat:=dFormat+aTimeFormat;
  end;

end;

function TryFormatDateTime(const Fmt: string; value: TDateTime): string;
begin
  try
    Result :=FormatDateTime(Fmt, value);
  except
    Result :='##';
  end;
end;

function TryFormatDateTime1904(const Fmt: string; value: TDateTime; const Dates1904: boolean; const LocalSettings: TFormatSettings): string;
begin
  try
    if (Dates1904) then value:= value + Date1904Diff;
   {$IFDEF  NOFORMATSETTINGS}
    Result :=FormatDateTime(Fmt, value);
   {$ELSE}
    Result :=FormatDateTime(Fmt, value, LocalSettings);
   {$ENDIF}

  except
    Result :='##';
  end;
end;

function TryFormatDateTime1904(const Fmt: string; value: TDateTime; const Dates1904: boolean): string;
begin
  try
    if (Dates1904) then value:= value + Date1904Diff;
    Result :=FormatDateTime(Fmt, value);
  except
    Result :='##';
  end;
end;


function OffsetRange(const CellRange: TXlsCellRange; const DeltaRow, DeltaCol: integer): TXlsCellRange;
begin
  Result:=CellRange;
  inc(Result.Top, DeltaRow);
  inc(Result.Left, DeltaCol);
  inc(Result.Bottom, DeltaRow);
  inc(Result.Right, DeltaCol);
end;

procedure InitializeNamedRange(var NamedRange: TXlsNamedRange);
begin
  NamedRange.Name:='';
  NamedRange.RangeFormula:='';
  NamedRange.OptionFlags:=0;
  NamedRange.NameSheetIndex:=0;
end;

end.







