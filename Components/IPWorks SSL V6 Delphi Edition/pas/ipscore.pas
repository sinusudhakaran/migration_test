
unit ipscore;

interface

uses

{$IFDEF CLR}
  System.Reflection, System.Runtime.CompilerServices,
{$ELSE}
{$ENDIF}
  WinTypes, Windows, SysUtils, Classes {$IFDEF LINUX}, Qt, Libc{$ELSE}{$ENDIF};



{$WARNINGS OFF}

type
{$IFDEF LINUX}	
  BOOL = LongBool;
  TNotified = procedure(Socket: Integer) of Object;
  TipwSocketNotifier = class (TObject)
  private
    HookRead, HookWrite, HookException: QObject_hookH;
    HandleRead, HandleWrite, HandleException: QObjectH;
    OnNotified: TNotified;
  public
    constructor Create(Socket: TSocket; Mask: Integer = $FFFF; Notified: TNotified = nil);
    destructor Destroy; override;
    procedure ActivatedHook(Socket: Integer); cdecl;
    procedure DestroyedHookRead; cdecl;
    procedure DestroyedHookWrite; cdecl;
    procedure DestroyedHookException; cdecl;
  end;
{$ENDIF}
  TipsCore = class;
  TAbout = {$IFDEF CLR}TObject{$ELSE}Longint{$ENDIF};
  EIPWorksSSL = class(Exception)
    public
      Code: integer;
      constructor CreateCode(err: integer; desc: string);
  end;

  TipsCore = class(TComponent)
  private
  
  protected

    function ThrowCoreException(err: integer; const desc: string): EIPWorksSSL; virtual;
    function AboutReadNoop: TAbout;
    procedure AboutWriteNoop(NewVal: TAbout);

    procedure AboutDlg; virtual;

    procedure SetNoopString(x: String);
    procedure SetNoopAnsiString(x: AnsiString);
    procedure SetNoopInteger(x: Integer);
    procedure SetNoopLongint(x: Longint);
    procedure SetNoopBoolean(x: Boolean);

    procedure TreatErr(Err: integer; const desc: string);
    
  public
    constructor Create(AOwner: TComponent); override;

  published
    property About: TAbout read AboutReadNoop write AboutWriteNoop stored False;
  end;

  procedure Register;


{$IFNDEF CLR}
{$IFNDEF LINUX}
	function IsWinNT : boolean;
	function IPWorksSSLLoadDRU(FileBuffer: Pointer; var EntryPoint: Pointer): Pointer;
	function IPWorksSSLFindFunc(pBaseAddress: Pointer; FuncName: PChar): Pointer;
	function IPWorksSSLFreeDRU(BaseAddress: Pointer; EntryPoint: Pointer): Boolean;
{$ENDIF LINUX}
{$ENDIF}



implementation

uses
 	{$IFDEF LINUX}QDialogs{$ELSE}{$IFDEF CLR}Borland.Vcl.Dialogs{$ELSE}Dialogs{$ENDIF}{$ENDIF};

const
  FD_READ     = $01;
  FD_WRITE    = $02;
  FD_OOB      = $04;
  FD_ACCEPT   = $08;
  FD_CONNECT  = $10;
  FD_CLOSE    = $20;


{$IFNDEF CLR}
type
  PShort = ^Short;
  TShortArr = array of Short;
  PShortArr = ^TShortArr;
  TDWORDArr = array of DWORD;
  PDWORDArr = ^TDWORDArr;

  // PE file header structures used to parse the dll for correct dll loading.
  // For detailed infromation about this sructures refer to MSDN library

  TIIDUnion = record
    case Integer of
      0: (Characteristics: DWORD);
      1: (OriginalFirstThunk: DWORD);
  end;

  TImgSecHdrMisc = record
    case Integer of
      0: (PhysicalAddress: DWORD);
      1: (VirtualSize: DWORD);
  end;

  _IMAGE_SECTION_HEADER = record
    Name: array[0..IMAGE_SIZEOF_SHORT_NAME - 1] of Byte;
    Misc: TImgSecHdrMisc;
    VirtualAddress: DWORD;
    SizeOfRawData: DWORD;
    PointerToRawData: DWORD;
    PointerToRelocations: DWORD;
    PointerToLinenumbers: DWORD;
    NumberOfRelocations: WORD;
    NumberOfLinenumbers: WORD;
    Characteristics: DWORD;
  end;

  IMAGE_SECTION_HEADER = _IMAGE_SECTION_HEADER;
  PIMAGE_SECTION_HEADER = ^IMAGE_SECTION_HEADER;

  PIMAGE_IMPORT_DESCRIPTOR = ^IMAGE_IMPORT_DESCRIPTOR;
  _IMAGE_IMPORT_DESCRIPTOR = record
    Union: TIIDUnion;
    TimeDateStamp: DWORD;
    ForwarderChain: DWORD;
    Name: DWORD;
    FirstThunk: DWORD;
  end;
  IMAGE_IMPORT_DESCRIPTOR = _IMAGE_IMPORT_DESCRIPTOR;

  PIMAGE_THUNK_DATA32 = ^IMAGE_THUNK_DATA32;
  _IMAGE_THUNK_DATA32 = record
    case Integer of
      0: (ForwarderString: DWORD);
      1: (Function_: DWORD);
      2: (Ordinal: DWORD);
      3: (AddressOfData: DWORD);
  end;
  IMAGE_THUNK_DATA32 = _IMAGE_THUNK_DATA32;

  PIMAGE_IMPORT_BY_NAME = ^IMAGE_IMPORT_BY_NAME;
  _IMAGE_IMPORT_BY_NAME = record
    Hint: WORD;
    Name: array[0..0] of Byte;
  end;
  IMAGE_IMPORT_BY_NAME = _IMAGE_IMPORT_BY_NAME;

  PIMAGE_EXPORT_DIRECTORY = ^IMAGE_EXPORT_DIRECTORY;
  _IMAGE_EXPORT_DIRECTORY = record
    Characteristics: DWORD;
    TimeDateStamp: DWORD;
    MajorVersion: WORD;
    MinorVersion: WORD;
    Name: DWORD;
    Base: DWORD;
    NumberOfFunctions: DWORD;
    NumberOfNames: DWORD;
    AddressOfFunctions: DWORD;
    AddressOfNames: DWORD;
    AddressOfNameOrdinals: DWORD;
  end;

  IMAGE_EXPORT_DIRECTORY = _IMAGE_EXPORT_DIRECTORY;
  PIMAGE_NT_HEADERS = ^_IMAGE_NT_HEADERS;
  TEntryPointProc = function(hinstDll: HINST; fdwReason: DWORD; lpvREserved: Pointer): Boolean; stdcall; // the dll entry point procedure type
{$ENDIF}


constructor TipsCore.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure Register;
begin

end;

function TipsCore.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EIPWorksSSL.CreateCode(err, desc)
end;

procedure TipsCore.AboutDlg;
{$IFDEF LINUX}
var
	msg: string;
{$ENDIF}
begin
{$IFDEF LINUX}
	msg := 'IP*Works! SSL Kylix Edition Version 6.2 '#10'Copyright (c) 2004 /n software inc. - All rights reserved.';
	msg := msg + #10'For more information, please visit www.nsoftware.com.';
  MessageDlg('IP*Works! SSL V6 ', msg, mtCustom, [mbOk], 0);
{$ELSE}
  ShowMessage('IP*Works! SSL Delphi Edition Version 6.2 '#10'Copyright (c) 2004 /n software inc. - All rights reserved.'#10'For more information, please visit www.nsoftware.com.');
{$ENDIF}
end;

function TipsCore.AboutReadNoop: TAbout;
begin
  if csDesigning in ComponentState
  then Result := {$IFDEF CLR}self{$ELSE}Longint(self){$ENDIF}
  else Result := {$IFDEF CLR}nil{$ELSE}0{$ENDIF};
end;

procedure TipsCore.AboutWriteNoop(NewVal: TAbout);
begin
end;

procedure TipsCore.SetNoopString(x: String);
begin
end;
procedure TipsCore.SetNoopAnsiString(x: AnsiString);
begin
end;
procedure TipsCore.SetNoopInteger(x: Integer);
begin
end;
procedure TipsCore.SetNoopLongint(x: Longint);
begin
end;
procedure TipsCore.SetNoopBoolean(x: Boolean);
begin
end;



constructor EIPWorksSSL.CreateCode(err: integer; desc: string);
begin
  code := err;
  Create(IntToStr(err) + ': ' + desc);
end;

procedure TipsCore.TreatErr(Err: integer; const desc: string);
begin
  raise ThrowCoreException(Err, desc);
end;

{*********************************************************************************}
 
{$IFDEF LINUX}

constructor TipwSocketNotifier.Create(Socket: TSocket; Mask: Integer; Notified: TNotified);
var
  ActivateMethod, DestroyMethod: TMethod;
begin
  OnNotified := Notified;
  QSocketNotifier_activated_Event(ActivateMethod) := ActivatedHook;

  if (Mask and (FD_READ or FD_ACCEPT)) <> 0 then
  begin
    HandleRead := QSocketNotifier_create(Socket, QSocketNotifierType_Read, nil, nil);
    HookRead := QSocketNotifier_hook_create(HandleRead);
    QSocketNotifier_hook_hook_activated(QSocketNotifier_hookH(HookRead), ActivateMethod);
    QObject_destroyed_Event(DestroyMethod) := DestroyedHookRead;
    QObject_hook_hook_destroyed(HookRead, DestroyMethod);
  end;

  if (Mask and (FD_WRITE or FD_CONNECT or FD_CLOSE)) <> 0 then
  begin
    HandleWrite := QSocketNotifier_create(Socket, QSocketNotifierType_Write, nil, nil);
    HookWrite := QSocketNotifier_hook_create(HandleWrite);
    QSocketNotifier_hook_hook_activated(QSocketNotifier_hookH(HookWrite), ActivateMethod);
    QObject_destroyed_Event(DestroyMethod) := DestroyedHookWrite;
    QObject_hook_hook_destroyed(HookWrite, DestroyMethod);
  end;

  if (Mask and (FD_OOB or FD_CONNECT or FD_CLOSE)) <> 0 then
  begin
    HandleException := QSocketNotifier_create(Socket, QSocketNotifierType_Exception, nil, nil);
    HookException := QSocketNotifier_hook_create(HandleException);
    QSocketNotifier_hook_hook_activated(QSocketNotifier_hookH(HookException), ActivateMethod);
    QObject_destroyed_Event(DestroyMethod) := DestroyedHookException;
    QObject_hook_hook_destroyed(HookException, DestroyMethod);
  end;

end;

procedure TipwSocketNotifier.ActivatedHook(Socket: Integer);
begin
  if Assigned(OnNotified) then
    OnNotified(Socket);
end;

procedure TipwSocketNotifier.DestroyedHookRead;
begin
  if HookRead <> nil then
  begin
    QObject_hook_destroy(HookRead);
    HookRead := nil;
  end;
end;

procedure TipwSocketNotifier.DestroyedHookWrite;
begin
  if HookWrite <> nil then
  begin
    QObject_hook_destroy(HookWrite);
    HookWrite := nil;
  end;
end;

procedure TipwSocketNotifier.DestroyedHookException;
begin
  if HookException <> nil then
  begin
    QObject_hook_destroy(HookException);
    HookException := nil;
  end;
end;

destructor TipwSocketNotifier.Destroy;
begin
  {andi: this will call DestroyedHook}
  if HandleRead <> nil then
  begin
    QObject_destroy(HandleRead);
    HandleRead := nil;
  end;
  if HandleWrite <> nil then
  begin
    QObject_destroy(HandleWrite);
    HandleWrite := nil;
  end;
  if HandleException <> nil then
  begin
    QObject_destroy(HandleException);
    HandleException := nil;
  end;
end;

{$ENDIF}

{*********************************************************************************}


{$IFNDEF CLR}

function IsWinNT : Boolean;
var
   osv : TOSVERSIONINFO;
begin
   osv.dwOSVersionInfoSize := sizeOf(OSVERSIONINFO);
   GetVersionEx(osv);
   result := (osv.dwPlatformId = VER_PLATFORM_WIN32_NT);
end;



function IPWorksSSLLoadDRU(FileBuffer: Pointer; var EntryPoint: Pointer): Pointer;
var
  peHeader: PIMAGE_NT_HEADERS;
  peSectHeader: PIMAGE_SECTION_HEADER;
  peSectRelocHeader: PIMAGE_SECTION_HEADER;
  DllBuffer: Pointer;
  DllHandle: THandle;
  TempBuffer: Pointer;
  i: DWORD;
  j: DWORD;
  ImportDesc: PIMAGE_IMPORT_DESCRIPTOR;
  ThunkData: PIMAGE_THUNK_DATA32;
  ImportByName: PIMAGE_IMPORT_BY_NAME;
  AddresOfEntryPoint: DWORD;
  Offset: DWORD;
  Address: PDWORD;
  DllName: PChar;
  DllModule: HMODULE;
  AddresTable: Pointer;
  ProcAddress: Pointer;
  Ordinal: Boolean;
  MoveAddr: Pointer;
begin
  Result := nil;
  peSectRelocHeader := nil;
  if not IsWinNT then begin
  	DllHandle := LoadLibrary(PChar('ipwssl6.dll'));
 	 	if DllHandle = 0 then begin
  		ShowMessage('ipwssl6.dll could not be loaded.  ipwssl6.dll is required for Windows 95/95/Me.');
 	 	end;
 	 	Result := Pointer(DllHandle);
		exit;
  end;
  if Assigned(FileBuffer) then
    begin
      peHeader := PIMAGE_NT_HEADERS(DWORD(FileBuffer) + PDWORD(DWORD(FileBuffer) + $3C)^);
      if (PDWORD(peHeader)^ = $4550) then
        begin
          DllBuffer := VirtualAlloc(nil, peHeader.OptionalHeader.SizeOfImage,
            MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
          if Assigned(DllBuffer) then
            begin
              Move(FileBuffer^, DllBuffer^, peHeader.OptionalHeader.SizeOfHeaders);
              peSectHeader := Pointer(DWORD(@peHeader.OptionalHeader) + peHeader.FileHeader.SizeOfOptionalHeader);
              for i := 0 to Pred(peHeader.FileHeader.NumberOfSections) do
                begin
                  if strcomp(PChar(@peSectHeader.Name), '.reloc') = 0 then
                    peSectRelocHeader := peSectHeader;
                  TempBuffer := Pointer(DWORD(DllBuffer) + peSectHeader.VirtualAddress);
                  MoveAddr := Pointer(DWORD(FileBuffer) + peSectHeader.PointerToRawData);
                  Move(MoveAddr^, TempBuffer^, peSectHeader.SizeOfRawData);
                  peSectHeader := PIMAGE_SECTION_HEADER(DWORD(peSectHeader) + sizeof(IMAGE_SECTION_HEADER));
                end;
              if Assigned(peSectRelocHeader) then
                begin
                  TempBuffer := Pointer(DWORD(FileBuffer) + peSectRelocHeader.PointerToRawData);
                  i := 0;
                  while i < peSectRelocHeader.SizeOfRawData do
                    begin
                      j := 8;
                      while j < PDWORD(DWORD(TempBuffer) + 4)^ do
                        begin
                          if PShort(DWORD(TempBuffer) + j)^ <> 0 then
                            begin
                              Offset := PShort(DWORD(TempBuffer) + j)^ +
                                PDWORD(DWORD(TempBuffer))^ - $3000;
                              Address := PDWORD(DWORD(DllBuffer) + Offset);
                              Address^ := Address^ - peHeader.OptionalHeader.ImageBase + DWORD(DllBuffer);
                            end;
                          Inc(j, 2);
                        end;
                      TempBuffer := Pointer(DWORD(TempBuffer) + PDWORD(DWORD(TempBuffer) + 4)^);
                      i := i + j;
                    end;
                  if peHeader.OptionalHeader.DataDirectory[1].VirtualAddress <> 0 then
                    begin
                      ImportDesc := PIMAGE_IMPORT_DESCRIPTOR(DWORD(DllBuffer) + peHeader.OptionalHeader.DataDirectory[1].VirtualAddress);
                      while (ImportDesc.Union.OriginalFirstThunk <> 0) do
                        begin
                          DllName := PChar(DWORD(DllBuffer) + ImportDesc.Name);
                          AddresTable := Pointer(DWORD(DllBuffer) + ImportDesc.FirstThunk);
                          DllModule := GetModuleHandle(DllName);
                          if DllModule = 0 then
                            begin
                              DllModule := LoadLibrary(DllName);
                              if DllModule = 0 then
                                Exit;
                            end;
                          ThunkData := PIMAGE_THUNK_DATA32(DWORD(DllBuffer) + ImportDesc.Union.OriginalFirstThunk);
                          while PDWORD(ThunkData)^ <> 0 do
                            begin
                              Ordinal := False;
                              i := ThunkData.Ordinal;
                              if ((i and $7FFFFFFF) <> i) then
                                begin
                                  Ordinal := True;
                                  i := i and $7FFFFFFF;
                                end;
                              if not Ordinal then
                                begin
                                  ImportByName := PIMAGE_IMPORT_BY_NAME(DWORD(DllBuffer) + i);
                                  ProcAddress := GetProcAddress(DllModule, PChar(@ImportByName.Name));
                                end
                              else
                                ProcAddress := GetProcAddress(DllModule, PChar(i));
                              PDWORD(AddresTable)^ := DWORD(ProcAddress);
                              AddresTable := PDWORD(DWORD(AddresTable) + sizeof(DWORD));
                              ThunkData := PIMAGE_THUNK_DATA32(DWORD(ThunkData) + sizeof(IMAGE_THUNK_DATA32));
                            end;
                          ImportDesc := PIMAGE_IMPORT_DESCRIPTOR(DWORD(ImportDesc) + sizeof(IMAGE_IMPORT_DESCRIPTOR));
                        end;
                    end;
                end;
              AddresOfEntryPoint := peHeader.OptionalHeader.AddressOfEntryPoint + DWORD(DllBuffer);
              if not TEntryPointProc(AddresOfEntryPoint)(HINST(DllBuffer), DLL_PROCESS_ATTACH, nil) then
                Exit;
              EntryPoint := Pointer(AddresOfEntryPoint);
              Result := DllBuffer;
            end;
        end;
    end;
end;



function IPWorksSSLFreeDRU(BaseAddress: Pointer; EntryPoint: Pointer): Boolean;
begin
  Result := False;
  if not IsWinNT then begin
  	if Assigned(BaseAddress) then FreeLibrary(THandle(BaseAddress));
  	exit;
  end;
  if Assigned(BaseAddress) and Assigned(EntryPoint) then
    if TEntryPointProc(EntryPoint)(HINST(BaseAddress), DLL_PROCESS_DETACH, nil) then
      Result := VirtualFree(BaseAddress, 0, MEM_RELEASE);
end;



function IPWorksSSLFindFunc(pBaseAddress: Pointer; FuncName: PChar): Pointer;
var
  pinth: PIMAGE_NT_HEADERS;
  pied: PIMAGE_EXPORT_DIRECTORY;
  k: Integer;
  FuncAddr: Pointer;
  dwBaseAddress: DWORD;
begin
  FuncAddr := nil;
  if not IsWinNT then begin
  	Result := GetProcAddress(THandle(pBaseAddress), FuncName);
  	exit;
  end;
  dwBaseAddress := DWORD(pBaseAddress);
  if (dwBaseAddress <> 0) then
    begin
      pinth := PIMAGE_NT_HEADERS(dwBaseAddress + PDWORD(dwBaseAddress + $3C)^);
      pied := PIMAGE_EXPORT_DIRECTORY(pinth.OptionalHeader.DataDirectory[0].VirtualAddress + dwBaseAddress);
      for k := 0 to Pred(pied.NumberOfNames) do
      	begin
          if strcomp(PChar(TDWORDArr(pied.AddressOfNames + dwBaseAddress)[k] + dwBaseAddress), FuncName) = 0 then
          	begin
            	FuncAddr := Pointer(TDWORDArr(pied.AddressOfFunctions + dwBaseAddress)
                    [TShortArr(pied.AddressOfNameOrdinals + dwBaseAddress)[k]]);
              FuncAddr := Pointer(DWORD(FuncAddr) + dwBaseAddress);
            end;
        end;
      Result := FuncAddr;
    end;
end;

{$ENDIF}


{$WARNINGS ON}
end.

