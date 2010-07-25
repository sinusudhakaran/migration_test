unit testlookupmainform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    btnTestLookup: TButton;
    btnRetrieveList: TButton;
    btnSetDBLocation: TButton;
    Button4: TButton;
    Label3: TLabel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    txtDll_Location: TEdit;
    txtDBLocation: TEdit;
    Label2: TLabel;
    Edit1: TEdit;
    procedure btnRetrieveListClick(Sender: TObject);
    procedure btnTestLookupClick(Sender: TObject);
    procedure btnSetDBLocationClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
{$R *.dfm}
uses
  IniFiles;
const
 DllName = 'bkLookup.dll';
var
  LookupDllPath : string;

type
  TGetBufferLen = function : LongInt; stdCall;
  TGetList = function ( Buffer : PChar; BufferLen : DWord) : LongBool; stdCall;
  TShowLookup = function ( aHandle : THandle; DefaultCode, SelectedCode : PChar) : LongBool; stdcall;
  TInitAdminLocation = function ( AdminDir : PChar) : LongBool; stdcall;

procedure TForm1.btnRetrieveListClick(Sender: TObject);
var
  Handle : THandle;
  GetBufferLen : TGetBufferLen;
  GetList : TGetList;
  InitAdminLocation : TInitAdminLocation;
  ListLength : integer;
  DelimList : string;
  s : String;
begin
  LookupDllPath := txtDll_Location.Text + DllName;
  Handle := LoadLibrary( PChar(LookupDllPath));
  try
    if Handle <> 0 then
    begin
      @GetBufferLen := GetProcAddress(Handle, 'GetBKClientListBufferLen');
      @GetList := GetProcAddress(Handle, 'GetBKClientList');
      @InitAdminLocation := GetProcAddress(Handle, 'SetBKAdminLocation');
      if (@InitAdminLocation <> nil) and (@GetBufferLen <> nil) and (@GetList <> nil) then
      begin
        s := txtDBLocation.Text;
        if InitAdminLocation( pChar(s)) then
        begin
          ListLength := GetBufferLen;
          if ListLength <> - 1 then
          begin
            SetLength( DelimList, ListLength);
            if GetList( PChar(DelimList), ListLength) then
             ShowMessage( DelimList);
          end;
        end;
      end
      else
        ShowMessage('Error loading functions');

    end
    else
      ShowMessage('LoadLibrary Failed');
  finally
    FreeLibrary(Handle);
  end;
end;

procedure TForm1.btnTestLookupClick(Sender: TObject);
var
  ShowLookup : TShowLookup;
  InitAdminLocation : TInitAdminLocation;
  Handle : THandle;
var
  InCode : string;
  OutCode : string;
  s : string;
begin
  LookupDllPath := txtDll_Location.Text + DllName;
  Handle := LoadLibrary( PChar(LookupDllPath));
  try
    If Handle <> 0 then
    Begin
      @ShowLookup := GetProcAddress(Handle, 'LookupBKClientCode');
      @InitAdminLocation := GetProcAddress(Handle, 'SetBKAdminLocation');
      if (@ShowLookup <> nil) and (@InitAdminLocation <> nil) then
      Begin
        InCode := edit1.text;
        s := txtDBLocation.Text;
        SetLength( OutCode, 10);

        if InitAdminLocation( pChar(s)) then
        begin
          if ShowLookup( Self.Handle, PChar(InCode), PChar(OutCode)) then
          begin
            Edit1.text := OutCode;
          end;
        end;
      end
      else
        ShowMessage('Error loading functions');
    end
    else
      ShowMessage('LoadLibrary Failed');
  finally
    FreeLibrary(Handle);
  end;
end;

procedure TForm1.btnSetDBLocationClick(Sender: TObject);
var
  Handle : THandle;
  GetBufferLen : TGetBufferLen;
  GetList : TGetList;
  InitAdminLocation : TInitAdminLocation;
  ListLength : integer;
  DelimList : string;
  s : String;
begin
  LookupDllPath := txtDll_Location.Text + DllName;

  Handle := LoadLibrary( PChar( LookupDllPath));
  try
    if Handle <> 0 then
    begin
      @GetBufferLen := GetProcAddress(Handle, 'GetBKClientListBufferLen');
      @GetList := GetProcAddress(Handle, 'GetBKClientList');
      @InitAdminLocation := GetProcAddress(Handle, 'SetBKAdminLocation');
      if (@InitAdminLocation <> nil) and (@GetBufferLen <> nil) and (@GetList <> nil) then
      begin
        s := txtDBLocation.Text;
        if InitAdminLocation( pChar(s)) then
        begin
          ShowMessage('Set to ' + s);
        end;
      end
      else
        ShowMessage('Error loading functions');
    end
    else
      ShowMessage('LoadLibrary Failed');
  finally
    FreeLibrary(Handle);
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.FormShow(Sender: TObject);
var
  i : TIniFile;
begin
  i := TIniFile.Create(ChangeFileExt(Application.ExeName,'.INI'));
  try
    txtDll_Location.Text := i.ReadString('Dirs','DllLocation','');
    txtDBLocation.Text := i.ReadString('Dirs','DBLocation','');
  finally
    i.Free;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i : TIniFile;
begin
  i := TIniFile.Create(ChangeFileExt(Application.ExeName,'.INI'));
  try
    i.WriteString('Dirs','DllLocation',txtDll_Location.Text);
    i.WriteString('Dirs','DBLocation',txtDBLocation.Text);
  finally
    i.Free;
  end;
end;

end.
