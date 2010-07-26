{*********************************************************************}
{ TAdvDirectoryEdit                                                   }
{ for Delphi & C++Builder                                             }
{ version 1.1                                                         }
{                                                                     }
{ written by                                                          }
{  TMS Software                                                       }
{  copyright © 2002 - 2006                                            }
{  Email : info@tmssoftware.com                                       }
{  Web : http://www.tmssoftware.com                                   }
{                                                                     }
{ The source code is given as is. The author is not responsible       }
{ for any possible damage done due to the use of this code.           }
{ The component can be freely used in any application. The source     }
{ code remains property of the author and may not be distributed      }
{ freely as such.                                                     }
{*********************************************************************}

unit AdvDirectoryEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, AdvEdBtn, AdvEdit;

{$I TMSDEFS.INC}

type
  TDirectoryShowEvent = procedure(Sender: TObject; var InitialPath: string) of object;

  TDialogCloseEvent = procedure(Sender: TObject; NewDirectory: string; OK: boolean) of object;

  TAdvDirectoryEdit = class(TAdvEditBtn)
  private
    { Private declarations }
    FDummy: Byte;
    FOnClickBtn:TNotifyEvent;
    FOnValueValidate: TValueValidateEvent;
    FBrowseDialogText: string;
    FAllowNewFolder: Boolean;
    FOnShowDirectory: TDirectoryShowEvent;
    FOnDialogClose: TDialogCloseEvent;
  protected
    { Protected declarations }
    procedure BtnClick (Sender: TObject); override;
    procedure ValueValidate(Sender: TObject; Value: String; Var IsValid: Boolean); Virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function IsValidDirectory: Boolean;
    procedure ClickButton;
  published
    property AutoThousandSeparator: Byte read FDummy;
    property AllowNewFolder: Boolean read FAllowNewFolder write FAllowNewFolder default True;
    property BrowseDialogText:string read FBrowseDialogText write FBrowseDialogText;
    property EditAlign: Byte read FDummy;
    property EditType: Byte read FDummy;
    property ExcelStyleDecimalSeparator: Byte read FDummy;
    property PasswordChar: Byte read FDummy;
    property Precision: Byte read FDummy;
    property Signed: Byte read FDummy;
    property ShowURL: Byte read FDummy;
    property URLColor: Byte read FDummy;
    property OnClickBtn: TNotifyEvent read FOnClickBtn;
    property OnDialogClose: TDialogCloseEvent read FOnDialogClose write FOnDialogClose;
    property OnValueValidate: TValueValidateEvent read fOnValueValidate;
    property OnShowDirectoryDialog: TDirectoryShowEvent read FOnShowDirectory write FOnShowDirectory;
  end;

implementation

uses
 {$WARNINGS OFF}
 // avoid platform specific warning
  FileCtrl, ShlObj, ActiveX;
 {$WARNINGS ON}

const
  BIF_NONEWFOLDERBUTTON = $0200;
  BIF_NEWDIALOGSTYLE    = $0040;

{$R *.RES}

constructor TAdvDirectoryEdit.Create(AOwner: TComponent);
begin
  Inherited;
  Glyph.LoadFromResourceName (HInstance, 'AdvDirectoryEdit');
  Button.OnClick := BtnClick;
  Inherited OnValueValidate := ValueValidate;
  ButtonWidth := 18;
  FBrowseDialogText := 'Select Directory';
  FAllowNewFolder := True;
end;

{$IFNDEF DELPHI5_LVL}
function ExcludeTrailingBackslash(DirName: string): string;
begin
  if Length(DirName) > 0 then
  begin
    if (DirName[Length(DirName)] in ['\','/']) then
      Delete(DirName,Length(DirName),1);
  end;
  Result := DirName;
end;
{$ENDIF}

function AdvDirectoryEditCallBack (Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer; stdcall;
var
  Temp: String;
  pt: TPoint;
  r: TRect;
begin
  if uMsg = BFFM_INITIALIZED then
  begin
    with TAdvDirectoryEdit (lpData) Do
    begin
      {$WARNINGS OFF}
      // avoid platform specific warning
      if Text = '' then
        Temp := GetCurrentDir
      else
        Temp := ExcludeTrailingBackslash (Text);
      {WARNINGS ON}

      SendMessage (Wnd, BFFM_SETSELECTION, 1, Integer(PChar(Temp)));

      with TAdvDirectoryEdit(lpData) do
      begin
        pt := Point(0,Height);
        pt := ClientToScreen(pt);
        GetWindowRect(Wnd,r);

        if pt.X + (r.Right - r.Left) > Screen.DesktopWidth then
          pt.X := pt.X - (r.Right - r.Left);

        if pt.Y + (r.Bottom - r.Top) < Screen.DesktopHeight then
          SetWindowPos(wnd,HWND_NOTOPMOST,pt.X,pt.Y,0,0,SWP_NOSIZE or SWP_NOZORDER)
        else
          SetWindowPos(wnd,HWND_NOTOPMOST,pt.X,pt.Y - (r.Bottom - r.Top) - Height,0,0,SWP_NOSIZE or SWP_NOZORDER)
      end;
    end;
  end;
  Result := 0;
end;

procedure TAdvDirectoryEdit.BtnClick (Sender: TObject);
var
  bi: TBrowseInfo;
  iIdList: PItemIDList;
  ResStr: array[0..MAX_PATH] of char;
  MAlloc: IMalloc;
  InitDir: string;
  res: boolean;

  // BIF_NONEWFOLDERBUTTON
begin
  FillChar(bi, sizeof(bi), #0);

  with bi do
  begin
    if Text <> '' then
      InitDir := Text
    else
      InitDir := GetCurrentDir;

    if Assigned(FOnShowDirectory) then
      FOnShowDirectory(Self, InitDir);

    StrPCopy(ResStr,InitDir);

    hwndOwner := Parent.Handle;
    pszDisplayName := ResStr;

    lpszTitle := PChar(FBrowseDialogText);

    ulFlags := BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE;
    
    if not FAllowNewFolder then
      ulFlags := ulFlags or BIF_NONEWFOLDERBUTTON;

    lpfn := AdvDirectoryEditCallBack;
    lParam := Integer(Self);
  end;

  iIdList := Nil;
  try
    iIdList := SHBrowseForFolder(bi);
  except
  end;

  if iIdList <> Nil then
  begin
    try
      FillChar(ResStr,sizeof(ResStr),#0);
      res := SHGetPathFromIDList (iIdList, ResStr);

      if Assigned(OnDialogClose) then
        OnDialogClose(self, ResStr, res);

      if res then
      begin
        if Text <> StrPas(ResStr) then
        begin
          Text := StrPas(ResStr);
          Modified := True;
        end;
      end;
    finally
      SHGetMalloc(MAlloc);
      Malloc.Free(iIdList);
    end;
  end;
end;

procedure TAdvDirectoryEdit.ValueValidate(Sender: TObject; Value: String; Var IsValid: Boolean);
begin
  IsValid := DirectoryExists (Value);
end;

function TAdvDirectoryEdit.IsValidDirectory: Boolean;
begin
  Result := DirectoryExists (Text);
  IsError := not Result;

end;

procedure TAdvDirectoryEdit.ClickButton;
begin
  BtnClick(self);
end;

procedure TAdvDirectoryEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = VK_F4 then
    BtnClick(Self);
end;

end.
