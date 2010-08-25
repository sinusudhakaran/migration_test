{******************************************************************************}
{                                                                              }
{                               GmRtfFuncs.pas                                 }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmRtfFuncs;

interface

uses Windows, Classes, stdctrls, Graphics, RichEdit, GmTypes, comctrls, Forms,
  Dialogs, GmResource;

{$I GMPS.INC}


  function CreateTRichEdit: TRichEdit;
  function GetLastOffset(ARichEdit: TCustomMemo; TextInfo: TGetTextLengthEx): integer;
  function GetRtfText(ARichEdit: TCustomMemo): string;
  function IsRichEdit98(ARichEdit: TCustomMemo): Boolean;
  function IsRxRichEdit(ARichEdit: TCustomMemo): Boolean;

  procedure GetRtfTextStream(ARichEdit: TCustomMemo; Stream: TStream);
  function GetTextLength(ACustomMemo: TCustomMemo): integer;

  procedure InsertRtfStream(ARichEdit: TCustomMemo; Stream: TStream);
  procedure InsertRtfText(ARichEdit: TCustomMemo; Text: string);

implementation


uses GmPreview, Controls, Messages, Printers, SysUtils, GmFuncs;

//------------------------------------------------------------------------------

{function IsTRxRichEdit(ARichEdit: TObject): Boolean;
var
  AClass: string;
begin
  AClass := LowerCase(ARichEdit.ClassName);
  Result := (AClass = 'trxrichedit') or
            (AClass = 'tjvxrichedit');
end;

function IsTRichEdit98(ARichEdit: TObject): Boolean;
var
  AClass: string;
begin
  AClass := LowerCase(ARichEdit.ClassName);
  Result := (AClass = 'trichedit98');
end;  }

//------------------------------------------------------------------------------

type TEditStreamCallBack = function (dwCookie: Longint; pbBuff: PByte;
cb: Longint; var pcb: Longint): {$IFDEF VER100} DWORD; stdcall; {$ELSE}
                                {$IFDEF VER120} DWORD; stdcall; {$ELSE}
                                                Integer; stdcall;
                                {$ENDIF} {$ENDIF}

TEditStream = record
  dwCookie: Longint;
  dwError: Longint;
  pfnCallback: TEditStreamCallBack;
end;

function EditStreamInCallback(dwCookie: Longint; pbBuff: PByte;
cb: Longint; var pcb: Longint): {$IFDEF VER110} DWORD; stdcall; {$ELSE}
                                {$IFDEF VER120} DWORD; stdcall; {$ELSE}
                                                Integer; stdcall;
                                {$ENDIF} {$ENDIF}
var
  theStream: TStream;
  dataAvail: LongInt;
begin
  theStream := TStream(dwCookie);
  with theStream do
    begin
      dataAvail := Size - Position;
      Result := 0;  {assume everything is ok}
      if dataAvail <= cb then
      begin
        pcb := Read(pbBuff^, dataAvail);
        if pcb <> dataAvail then  {couldn't read req. amount of bytes}
          result := E_FAIL;
      end
      else
      begin
        pcb := Read(pbBuff^, cb);
        if pcb <> cb then
          result := E_FAIL;
      end;
    end;
end;

procedure PutRTFSelection( ARichEdit: TCustomMemo; Stream: TStream);
var
  EditStream: TEditStream;
begin
  with EditStream do
  begin
    dwCookie := Longint(Stream);
    dwError := 0;
    pfnCallback := EditStreamInCallBack;
  end;
  ARichEdit.Perform( EM_STREAMIN, SF_RTF or SFF_SELECTION, longint(@EditStream));
end;

procedure InsertRtfStream(ARichEdit: TCustomMemo; Stream: TStream);
var
  LastParent: TWinControl;
begin
  LastParent := ARichEdit.Parent;
  try
    if ARichEdit.HasParent = False then ARichEdit.Parent := Application.Mainform;
    PutRTFSelection(ARichEdit, Stream);
  finally
    ARichEdit.Parent := LastParent;
  end;
end;

procedure InsertRtfText(ARichEdit: TCustomMemo; Text: string);
var
  AStream: TMemoryStream;
begin
  if IsRxRichEdit(ARichEdit) then
  begin
    ARichEdit.SetSelTextBuf(PChar(Text));
    Exit;
  end
  else
  if Length(Text) > 0 then
  begin
    AStream := TMemoryStream.Create;
    try
      AStream.Write(Text[1], Length(Text));
      AStream.Position := 0;
      PutRTFSelection( ARichEdit, AStream );
    finally
      AStream.Free;
    end;
  end;
end;

function EditStreamOutCallback(dwCookie: Longint; pbBuff: PByte; cb:
Longint; var pcb: Longint): {$IFDEF VER100} DWORD; stdcall; {$ELSE}
                            {$IFDEF VER120} DWORD; stdcall; {$ELSE}
                                            Integer; stdcall;
                            {$ENDIF} {$ENDIF}
var
  theStream: TStream;
begin
  theStream := TStream(dwCookie);
  with theStream do
  begin
    if cb > 0 then
      pcb := Write(pbBuff^, cb);
    Result := 0;
  end;
end;

procedure GetRtfTextStream(ARichEdit: TCustomMemo; Stream: TStream);
var
  EditStream: TEditStream;
begin
  with editstream do
  begin
    dwCookie := Longint(Stream);
    dwError := 0;
    pfnCallback := EditStreamOutCallBack;
  end;
  ARichEdit.Perform( EM_STREAMOUT, SF_RTF, LongInt(@EditStream));
end;

//------------------------------------------------------------------------------

function CreateTRichEdit: TRichEdit;
begin
  Result := TRichEdit.Create(nil);
  Result.Width := 0;
  Result.Height := 0;
  Result.WordWrap := False;
  Result.MaxLength := 1000000;
end;

function GetLastOffset(ARichEdit: TCustomMemo; TextInfo: TGetTextLengthEx): integer;
var
  LastParent: TWinControl;
begin
  if IsRxRichEdit(ARichEdit) then
  begin
    LastParent := ARichEdit.Parent;
    try
      if ARichEdit.HasParent = False then ARichEdit.Parent := Application.Mainform;
      Result := SendMessage(ARichEdit.Handle, EM_GETTEXTLENGTHEX, WParam(@TextInfo), 0);
    finally
      ARichEdit.Parent := LastParent;
    end;
  end
  else
    Result := GetTextLength(ARichEdit);
end;

function GetRtfText(ARichEdit: TCustomMemo): string;
var
  ARtfStringStream: TStringStream;
  LastParent: Pointer;
begin
  LastParent := ARichEdit.Parent;
  try
    if ARichEdit.HasParent = False then ARichEdit.Parent := Application.MainForm;
    ARtfStringStream := TStringStream.Create('');
    try
      GetRtfTextStream(ARichEdit, ARtfStringStream);
      Result := ARtfStringStream.DataString;
    finally
      ARtfStringStream.Free;
    end;
  finally
    ARichEdit.Parent := LastParent;
  end;
end;

function IsRichEdit98(ARichEdit: TCustomMemo): Boolean;
begin
  Result := LowerCase(ARichEdit.ClassName) = 'trichedit98';
end;

function IsRxRichEdit(ARichEdit: TCustomMemo): Boolean;
var
  AClass: string;
begin
  AClass := LowerCase(ARichEdit.ClassName);
  Result := (AClass = 'trxrichedit') or
            (AClass = 'trxdbrichedit') or
            (AClass = 'tjvxrichedit') or
            (AClass = 'tjvxdbrichedit');
end;

function GetTextLength(ACustomMemo: TCustomMemo): integer;
var
  LastParent: TWinControl;
begin
  LastParent := ACustomMemo.Parent;
  try
    if IsRichEdit98(ACustomMemo) then
       ACustomMemo.Parent := Application.MainForm;
    Result := ACustomMemo.GetTextLen;
  finally
    ACustomMemo.Parent := LastParent;
  end;
end;

end.


