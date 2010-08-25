unit WPWordConv;
{ -----------------------------------------------------------------------------
  WPTools Version 4 + 5
  WPWordConv - Copyright (C) 2002, 2004 by wpcubed GmbH  and Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  TWPWordConverter - Exports the text in a TWPRichText using the
  installed Word Converter files
  See also: http://support.microsoft.com/support/kb/articles/q111/7/16.asp
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }
  //NEW: try different convertes used for the same doc type - see bCheckAllConverters

interface

{$IFDEF CLR}
 ------------  This unit cannot be used with Delphi 8!
{$ENDIF}

{$I WPINC.INC}

{-> $IFDEF NOWPTOOLS no wptools units are used. You can use the converter
                     to load DOC into a RTF stream:

var stream : TMemoryStream;
    converter : TWPWordConverter;
begin
  converter := TWPWordConverter.Create(nil);
  stream    := nil;
  try
     converter.GetConverterNames(nil,wpcnvImport);
     stream := converter.GetRTFStream(Edit1.Text);
     if stream=nil then ShowMessage('cannot convert')
     else
     begin
       stream.SaveToFile(Edit2.Text);
       ShowMessage('Created: ' +  Edit2.Text);
     end;
  finally
     stream.Free;
     converter.Free;
  end;
end;

-------------------------------------------------------------------------------- }

uses Sysutils, Forms, Windows, Graphics, Classes, Dialogs
  {$IFNDEF NOWPTOOLS}
    {$IFDEF WPTOOLS5}
     , WPRTEDefs, WPCTRMemo, WPCTRRich
    {$ELSE}
     , WPDefs, WPRich, WPWinCTR
    {$ENDIF}
  {$ENDIF};

type
  TWPWordConverterMode = (wpcnvImport, wpcnvExport);

  TWPWordConverterError =
    (fceSuccess, fceUserFileOpen, fceFileRead, fceFileOpen, fceWriteErr,
    fceInvalData, fceOpenException, fceWriteException, fceOutOfMemory,
    fceBogusDoc, fceOutOfDiskSpace, fceDocTooLarge, fceNotUsed, fceUserAbort, fceCannotLoadCNV);

  TWPWordConverter = class(TComponent)
  private
  {$IFNDEF NOWPTOOLS}
    FSource: TWPCustomRtfEdit;
  {$ENDIF}
    FConverters: TStringList;
    FFormat: Integer;
    FInsert, FSelection: Boolean;
  {$IFNDEF NOWPTOOLS}
    procedure SetSource(x: TWPCustomRtfEdit);
  {$ENDIF}
    function GetAsString: string;
    procedure SetAsString(const x: string);
    function GetConverters: TStrings;
  protected
    FDestStream: TStream;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Write(Dest: TStream); virtual;
    procedure Read(Source: TStream); virtual;
    function MakeFilterText(list: TStrings): string;
    procedure GetConverterNames(list: TStrings; mode: TWPWordConverterMode);
    {$IFNDEF NOWPTOOLS}
    function LoadFromFile(const filename: string): Boolean;
    function SaveToFile(const filename: string): Boolean;
    {$ENDIF}
    function GetRTFStream(const filename: string) : TMemoryStream;        
    function Convert(const InputFile: string; Output: TMemoryStream; mode: TWPWordConverterMode; format: Integer): TWPWordConverterError;
  published
  {$IFNDEF NOWPTOOLS}
    property Source: TWPCustomRtfEdit read FSource write SetSource;
  {$ENDIF}
    property AsString: string read GetAsString write SetAsString;
    property Converters: TStrings read GetConverters;
    property Format: Integer read FFormat write FFormat;
    property InsertLoad: Boolean read FInsert write FInsert;
    property SelectionSave: Boolean read FSelection write FSelection;
  end;

const
  ConvRegisteryKeyImport = 'SOFTWARE\Microsoft\Shared Tools\Text Converters\Import';
  ConvRegisteryKeyExport = 'SOFTWARE\Microsoft\Shared Tools\Text Converters\Export';

implementation

const
  ConvErrorStrings: array[0..14] of string =
  ('Unknown Format',
    'Could not open user file',
    'Error during read',
    'Error opening conversion file',
    'Error during write',
    'Invalid data in conversion file',
    'Error opening exception file',
    'Error writing exception file',
    'Out of memory',
    'Invalid document',
    'Out of space on output',
    'Conversion file too large for target',
    'Internal Error',
    'Conversion canceled by user',
    'Unknown Fileformat');


  // Tool to read description from converter DLL. Thanks to Alessandro Fragnani de Morais

function GetFileDescription(sAppNamePath: string): string;
var
  VerSize: integer;
  VerBuf: PChar;
  VerBufValue: pointer;
  {$IFDEF DELPHI4}
  VerBufLen: cardinal;
  VerHandle: cardinal;
  {$ELSE}
  VerBufLen: Integer;
  VerHandle: Integer;
  {$ENDIF}
  VerKey: string;
  function GetInfo(ThisKey: string): string;
  begin
    Result := '';
    VerKey := '\StringFileInfo\' + IntToHex(loword(integer(VerBufValue^)), 4) +
      IntToHex(hiword(integer(VerBufValue^)), 4) + '\' + ThisKey;
    if VerQueryValue(VerBuf, PChar(VerKey), VerBufValue, VerBufLen) then
      Result := StrPas(VerBufValue);
  end;   
  function QueryValue(ThisValue: string): string;
  begin
    Result := '';
    if GetFileVersionInfo(PChar(sAppNamePath), VerHandle, VerSize, VerBuf) and
      VerQueryValue(VerBuf, '\VarFileInfo\Translation', VerBufValue, VerBufLen) then
      Result := GetInfo(ThisValue);
  end;
begin
  if sAppNamePath = '' then
    sAppNamePath := Application.ExeName;
  VerSize := GetFileVersionInfoSize(PChar(sAppNamePath), VerHandle);
  VerBuf := AllocMem(VerSize);
  Result := '';
  try
    // fCompanyName := QueryValue('CompanyName');
    Result := QueryValue('FileDescription');
    // fBuildVersion := QueryValue('BuildVersion');
    // fFileVersion := QueryValue('FileVersion');
    // fInternalName := QueryValue('InternalName');
    // fLegalCopyRight := QueryValue('LegalCopyRight');
    // fLegalTradeMark := QueryValue('LegalTradeMark');
    // fOriginalFileName := QueryValue('OriginalFileName');
    // fProductName := QueryValue('ProductName');
    // fProductVersion := QueryValue('ProductVersion');
    // fComments := QueryValue('Comments');
  finally
    FreeMem(VerBuf, VerSize);
  end;
  if Pos('Word', Result) > 0 then
  begin
    Result := Copy(Result, Pos('Word', Result), Length(Result));
  end;
end;

// Housekeeping ---------------------------------------------------------------
{$IFNDEF NOWPTOOLS}
procedure TWPWordConverter.SetSource(x: TWPCustomRtfEdit);
begin
  FSource := x;
  if Assigned(FSource) then
  begin
    FSource.FreeNotification(Self);
  end;
end;
{$ENDIF}

constructor TWPWordConverter.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FConverters := TStringList.Create;
  FFormat := -1;
end;

destructor TWPWordConverter.Destroy;
begin
  inherited Destroy;
  FConverters.Free;
end;

procedure TWPWordConverter.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  {$IFNDEF NOWPTOOLS}
  if (Operation = opRemove) and (AComponent <> nil) then
  begin
    if (AComponent = FSource) then FSource := nil;
  end;
  {$ENDIF}
end;

function TWPWordConverter.GetAsString: string;
var
  s: TMemoryStream;
begin
  Result := '';
  s := TMemoryStream.Create;
  try
    Write(s);
    SetString(Result, PChar(s.Memory), s.Size);
  finally
    s.Free;
  end;
end;

procedure TWPWordConverter.SetAsString(const x: string);
var
  s: TMemoryStream;
  l: Integer;
begin
  s := TMemoryStream.Create;
  try
    l := Length(x);
    s.SetSize(l);
    Move(PChar(x)^, PChar(s.Memory)^, l);
    s.Write(PChar(x)^, Length(x));
    s.Position := 0;
    Read(s);
  finally
    s.Free;
  end;
end;

function TWPWordConverter.GetConverters: TStrings;
begin
  Result := TStrings(FConverters);
end;

// ----------------------------------------------------------------------------
// The Logic ------------------------------------------------------------------
// ----------------------------------------------------------------------------

procedure TWPWordConverter.Write(Dest: TStream);
begin
end;

procedure TWPWordConverter.Read(Source: TStream);
begin
end;

function TWPWordConverter.MakeFilterText(list: TStrings): string;
var
  i, j: Integer;
  t: string;
begin
  Result := '';
  t := '';
  for i := 0 to list.Count - 1 do
  begin
    t := list[i];
    j := Pos('=', t);
    if j > 0 then
    begin
      Result := Result + Copy(t, j + 1, 255);
      if i < list.Count - 1 then Result := Result + '|';
    end;
  end;
end;

// Reads a string list
// Format: pathname = FormatName | Extensions

procedure TWPWordConverter.GetConverterNames(list: TStrings; mode: TWPWordConverterMode);
var
  key, key2: HKEY;
  n, a: Integer;
  buf: array[0..255] of Char;
  s, ConverterName: string;
  size: Integer;
begin
  Converters.Clear;
  if ((mode = wpcnvImport) and (RegOpenKey(HKEY_LOCAL_MACHINE, ConvRegisteryKeyImport, key) = ERROR_SUCCESS)) or
    ((mode = wpcnvExport) and (RegOpenKey(HKEY_LOCAL_MACHINE, ConvRegisteryKeyExport, key) = ERROR_SUCCESS)) then
  begin
    n := 0;
    size := 255;
    while RegEnumKey(key, n, buf, size) = ERROR_SUCCESS do
    begin
      ConverterName := StrPas(Buf);
      if RegOpenKey(key, buf, key2) = ERROR_SUCCESS then
      begin
        size := 255;
        if RegQueryValueEx(key2, 'Path', nil, nil, @buf[0], @size) = ERROR_SUCCESS then
        begin
          ConverterName := StrPas(buf);
        end;
        size := 255;
        if RegQueryValueEx(key2, 'Name', nil, nil, @buf[0], @size) = ERROR_SUCCESS then
        begin
          s := StrPas(buf);
          size := 255;
          if RegQueryValueEx(key2, 'Extensions', nil, nil, @buf[0], @size) = ERROR_SUCCESS then
          begin
            a := 0;
            s := s + '|*.';
            while buf[a] <> #0 do
            begin
              if buf[a] = #32 then
                s := s + ';*.'
              else
                s := s + buf[a];
              inc(a);
            end;
            if list<>nil then
              list.Add(ConverterName + '=' + s);
            Converters.Add(#32 + Uppercase(StrPas(buf)) + '=' + ConverterName);
          end;
        end;
        RegCloseKey(key2);
      end;
      inc(n);
      size := 255;
    end;
    RegCloseKey(key);
  end;
end;

var
  GlobalBuffer: HGLOBAL;
  GlobalOutStream: TStream;
  WritePos: integer = 0; // in Char
  WriteMax: integer = 0; // in Char
  RTFToWrite: PChar;

function WriteCallback(CCH, Percentage: Word): Integer; stdcall;
var
  tempBuf: PChar;
begin
  tempBuf := GlobalLock(GlobalBuffer);
  if CCH > 0 then GlobalOutStream.Write(tempBuf^, CCH);
  GlobalUnlock(GlobalBuffer);
  Result := 0;
end;

function ReadCallback(flags, nPercentComplete: Word): Integer; stdcall;
var
  tempBuf: PChar;
begin
  tempBuf := GlobalLock(GlobalBuffer);
  if writePos < writeMax then
  begin
    if (writeMax - writePos) < 4096 then
      Result := writeMax - writePos
    else
      Result := 4096;
    move((RTFToWrite + WritePos)^, tempBuf^, Result);
    inc(writePos, Result);
  end
  else
    Result := 0;
  GlobalUnlock(GlobalBuffer);
end;

{$IFNDEF NOWPTOOLS}
function TWPWordConverter.LoadFromFile(const filename: string): Boolean;
var
  o: TMemoryStream;
begin
  o := TMemoryStream.Create;
  Result := FALSE;
  try
    if Convert(filename, o, wpcnvImport, FFormat) = fceSuccess then
    begin

      if not FInsert then FSource.Clear;
      o.Position := 0;
      {$IFDEF WPTOOLS5}
      FSource.LoadFromStream(o, 'RTF', true);
      {$ELSE}
      FSource.Memo.LoadFromFileStream(o, FileName);
      if FSource is TWPCustomRichText then
        TWPCustomRichText(FSource).LastFileName := filename;
      {$ENDIF}
      Result := TRUE;
    end;
  finally
    o.Free;
  end;
end;

function TWPWordConverter.SaveToFile(const filename: string): Boolean;
var
  o: TMemoryStream; old: string;
begin
  o := TMemoryStream.Create;
  try
    old := FSource.TextSaveFormat;
    FSource.TextSaveFormat := 'RTF';
    if FSelection then
      FSource.Memo.SaveSelectionToStream(o)
    else
      FSource.SaveToStream(o);
    WritePos := 0;
    WriteMax := o.Size;
    RTFToWrite := o.Memory;
    Result := Convert(filename, o, wpcnvExport, FFormat) = fceSuccess;
  finally
    o.Free;
    RTFToWrite := nil;
    FSource.TextSaveFormat := old;
  end;
end;
{$ENDIF}

function TWPWordConverter.GetRTFStream(const filename: string): TMemoryStream;
begin
  Result := TMemoryStream.Create;
  try
    if Convert(filename, Result, wpcnvImport, FFormat) = fceSuccess then
    begin
      Result.Position := 0;
    end
    else
    begin
      Result.Free;
      Result := nil;
    end;
  except
    Result.Free;
    Result := nil;
  end;
end;

function StringToHandle(const str: string): HGLOBAL;
var
  p: PChar;
begin
  Result := GlobalAlloc(GMEM_MOVEABLE, Length(str) * 2 + 1);
  p := GlobalLock(Result);
  if p <> nil then
  begin
    strpcopy(p, str);
    GlobalUnlock(Result);
  end;
end;

function HandleToString(str: HGLOBAL): string;
var
  p: PChar;
begin
  Result := '';
  p := GlobalLock(str);
  if p <> nil then
  begin
    SetString(Result, p, StrLen(p));
    GlobalUnlock(str);
  end;
end;

function StringToOem(const Oem: string): string;
begin
  SetLength(Result, Length(Oem));
  if Length(Result) > 0
    then CharToOem(PChar(Oem), PChar(Result));
end;


function TWPWordConverter.Convert(const InputFile: string; Output: TMemoryStream;
  mode: TWPWordConverterMode; format: Integer): TWPWordConverterError;
var
  ConverterHandle: DWORD;
  FConverter: string;
  FError: string;
  ghszSubset, ghszFile, ghszConvtrVersion: HGLOBAL;
  result_value, i: Integer;
  bCheckAllConverters: Boolean;
  { FROM MSDN DOC:
    typedef unsigned long (pascal *PFN_RTF_CALLBACK)(int, int);
    extern "C" int pascal InitConverter32(HANDLE, char *);
    extern "C" HANDLE pascal RegisterApp32(unsigned long, void *);
    extern "C" int pascal IsFormatCorrect32(HANDLE, HANDLE);
    extern "C" int pascal ForeignToRtf32(HANDLE, void *, HANDLE, HANDLE, HANDLE, PFN_RTF_CALLBACK);
    extern "C" int pascal RtfToForeign32(HANDLE, LPSTORAGE, HANDLE, HANDLE, PFN_RTF_CALLBACK);     }
  InitConverter: function(ParentWin: THandle; ParentAppName: LPCSTR): integer; stdcall;
  IsFormatCorrect: function(FileName, Desc: HGLOBAL): integer; stdcall;
  ForeignToRtf: function(FileName: HGLOBAL; void: Pointer; Buf, Desc, Subset: HGLOBAL; Callback: Pointer): integer; stdcall;
  RtfToForeign: function(FileName: HGLOBAL; void: Pointer; Buf, Desc: HGLOBAL; Callback: Pointer): integer; stdcall;
begin
  Result := fceCannotLoadCNV;
  if format < 0 then
  begin
    bCheckAllConverters := TRUE;
    format := 0;
  end
  else
    bCheckAllConverters := FALSE;

  repeat
    if bCheckAllConverters then // Unknown!
    begin
      FConverter := Uppercase(ExtractFileExt(InputFile));
      if FConverter[1] = '.' then FConverter[1] := #32;
      while format < FConverters.Count do
      begin
        if Pos(FConverter, FConverters[format]) > 0 then break;
        inc(format);
      end;
      if format = FConverters.Count then exit; //NOT FOUND!
    end;
    FConverter := FConverters[format];
    ghszFile := 0;
    ghszConvtrVersion := 0;
    ghszSubset := 0;
    i := Pos('=', FConverter);
    FConverter := Copy(FConverter, i + 1, 255);
    ConverterHandle := LoadLibrary(PChar(FConverter));
    if ConverterHandle <> 0 then
    try
      @InitConverter := GetProcAddress(ConverterHandle, 'InitConverter32');
      @IsFormatCorrect := GetProcAddress(ConverterHandle, 'IsFormatCorrect32');
      @ForeignToRtf := GetProcAddress(ConverterHandle, 'ForeignToRtf32');
      @RtfToForeign := GetProcAddress(ConverterHandle, 'RtfToForeign32');
      if ((Mode = wpcnvImport) and Assigned(ForeignToRtf) and Assigned(IsFormatCorrect)) or
        ((Mode = wpcnvExport) and Assigned(RtfToForeign)) then
      try
        InitConverter(Application.Handle, PChar(Uppercase(Application.ExeName)));
        GlobalOutStream := Output;
        Output.Clear;
        ghszSubset := StringToHandle('');
        //WAS: ghszConvtrVersion := StringToHandle('Word 97');
        ghszConvtrVersion := StringToHandle(GetFileDescription(FConverter));

        //WAS: ghszFile := StringToHandle(InputFile);
        ghszFile := StringToHandle(StringToOem(InputFile));
        GlobalBuffer := GlobalAlloc(GMEM_FIXED {GHND}, 1024 * 4); // Start with 4K
        FError := '';
        if Mode = wpcnvExport then
        begin
          result_value := RtfToForeign(ghszFile, nil, GlobalBuffer, ghszConvtrVersion, @ReadCallback);
          if result_value <> 0 then
            FError := FError + ConvErrorStrings[abs(result_value)];
        end
        else
        begin
          result_value := IsFormatCorrect(ghszFile, ghszConvtrVersion);
          if result_value = 1 then
          begin
            result_value := ForeignToRtf(ghszFile, nil, GlobalBuffer, ghszConvtrVersion, ghszSubset, @WriteCallback);
            if result_value <> 0 then
            begin
              FError := FError + ConvErrorStrings[abs(result_value)];
              Result := TWPWordConverterError(abs(result_value));
            end
            else
            begin
              bCheckAllConverters := FALSE; // OK, We found what we need
              Result := fceSuccess;
            end;
          end
          else
          begin
            FError := FError + #13 + FConverter + ':' + ConvErrorStrings[0];
            Result := fceInvalData;
          end;
        end;
      finally
        GlobalFree(ghszSubset);
        GlobalFree(ghszConvtrVersion);
        GlobalFree(ghszFile);
        GlobalFree(GlobalBuffer);
      end;
    finally
      FreeLibrary(ConverterHandle);
    end;
    // try next format ...
    if bCheckAllConverters then inc(format);

  until not bCheckAllConverters;
  if (FError <> '') and (Result <> fceSuccess) then
    raise Exception.Create(FError);

end;


// -----------------------------------------------------------------------------
// Attach the converter functionality to a TWPRichText -------------------------
// -----------------------------------------------------------------------------
{$IFNDEF NOWPTOOLS}
function doLoadWithConverter(Source: TWPCustomRichText;
  Insert, Dialog: Boolean; const FileName: string): Boolean;
var
  Converter: TWPWordConverter;
  Filter: TStringList;
  dia: TOpenDialog;
  OldFormat, Ext: string;
begin
  Result := FALSE;
  Converter := TWPWordConverter.Create(nil);
  Filter := TStringList.Create;
  OldFormat := Source.TextLoadFormat;

  if not Dialog then
    dia := nil
  else
  begin
    dia := TOpenDialog.Create(Source);
    dia.InitialDir := FileName;
  end;
  {$IFNDEF WPTOOLS5}
  Source.FUsingConverter := TRUE;
  {$ENDIF}
  try
    Converter.Source := Source;
    Converter.InsertLoad := Insert;
    Converter.GetConverterNames(Filter, wpcnvImport);
    if dia <> nil then
    begin
      dia.Filter := 'RTF Text|*.RTF|HTML Text|*.HTML;*.HTM|ANSI Text|*.TXT;*.*|' // 3 Standard Filter
      + Converter.MakeFilterText(Filter);
      if CompareText(Source.TextLoadFormat, 'HTML') = 0 then
        dia.FilterIndex := 2
      else if CompareText(Source.TextLoadFormat, 'ANSI') = 0 then
        dia.FilterIndex := 3 else
      begin      
        Ext := ExtractFileExt(FileName);
        if (CompareText(Ext, '.HTM')=0) or (CompareText(Ext, '.HTML')=0) then
                 dia.FilterIndex := 2
        else if (CompareText(Ext, '.TXT')=0)  then
                 dia.FilterIndex := 3;
      end;
      dia.Options := [ofNoChangeDir, ofNoReadOnlyReturn, ofHideReadOnly];

      if dia.Execute then
      begin
        //V4.09 auto select correct format
        Ext := ExtractFileExt(dia.FileName);
        if (CompareText(Ext, '.HTM')=0) or (CompareText(Ext, '.HTML')=0) then
                 dia.FilterIndex := 2
        else if (CompareText(Ext, '.TXT')=0)  then
                 dia.FilterIndex := 3;

        if dia.FilterIndex <= 3 then
        begin
          case dia.FilterIndex of
            2: Source.TextLoadFormat := 'HTML';
            3: Source.TextLoadFormat := 'ANSI';
          else
            Source.TextLoadFormat := 'AUTO';
          end;
          {$IFDEF WPTOOLS5}
             Result := Source.LoadFromFile(dia.FileName, not Insert);
          {$ELSE}
          if not Insert then
            Source.LoadFromFileWithClear(dia.FileName)
          else
            Source.LoadFromFile(dia.FileName);
          Result := TRUE;
          {$ENDIF}
        end
        else
        begin
          Source.TextLoadFormat := 'RTF';
          Converter.Format := dia.FilterIndex - 1 - 3;
          Result := Converter.LoadFromFile(dia.FileName);
        end;
      end;
    end
    else
    begin
      Ext := Uppercase(ExtractFileExt(FileName));
      if (Ext = '.TXT') or (Ext = '.RTF') or (Ext = '.HTML') or (Ext = '.HTM') then
      begin
        Source.TextLoadFormat := 'AUTO';
        {$IFDEF WPTOOLS5}
             Result := Source.LoadFromFile(dia.FileName, not Insert);
          {$ELSE}
          if not Insert then
            Source.LoadFromFileWithClear(dia.FileName)
          else
            Source.LoadFromFile(dia.FileName);
          Result := TRUE;
          {$ENDIF}
      end
      else
      begin
        Converter.Format := -1;
        Result := Converter.LoadFromFile(FileName);
      end;
    end;
  finally
    Filter.Free;
    Converter.Free;
    Source.TextLoadFormat := OldFormat;
    {$IFNDEF WPTOOLS5}
    Source.FUsingConverter := FALSE;
    {$ENDIF}
    if dia <> nil then dia.Free;
  end;
end;

function doSaveWithConverter(Source: TWPCustomRichText;
  Selection, Dialog: Boolean; const FileName: string): Boolean;
begin
  // not implemeneted
  Result := FALSE;
end;

initialization
  WPLoadWithConverter := Addr(doLoadWithConverter);
  // WPSaveWithConverter := Addr(doSaveWithConverter);

finalization
  WPLoadWithConverter := nil;
  // WPSaveWithConverter := nil;

{$ENDIF NOWPTOOLS} 

end.

