(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is TurboPower OfficePartner
 *
 * The Initial Developer of the Original Code is
 * TurboPower Software
 *
 * Portions created by the Initial Developer are Copyright (C) 2000-2002
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

{$I OPDEFINE.INC}

{$IFDEF DCC6ORLATER}
  {$WARN SYMBOL_DEPRECATED OFF}
{$ENDIF}

unit OpDesign;

interface

uses
  {$IFDEF DCC6ORLATER}
    DesignIntf, DesignEditors, VCLEditors, RTLConsts
  {$ELSE}
    DsgnIntf
  {$ENDIF}, Classes, OpShared, OpExcel, OpWord,
  OpOutlk, OpPower, OpModels, Windows, TypInfo, OpMSO;


type
  TOpNestedCollectionEditor = class(TPropertyEditor)
  public
    function GetAttributes : TPropertyAttributes; override;
    function GetValue : string; override;
    procedure Edit; override;
  end;

  TOpModelProperty = class(TComponentProperty)
  private
    FOldStrProc: TGetStrProc;
    procedure FilterModels(const S: String);
  public
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  TOpOfficeFileProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TOpOfficeAssistantProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TOpMachineNameProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TOpOfficeComponentInfo = class(TComponentEditor)
  public
    function GetVerbCount: Integer; override;
    function GetVerb(index: Integer): string; override;
    procedure ExecuteVerb(index: Integer); override;
    procedure Edit; override;
  end;

procedure Register;

implementation

uses OpColEd, OpAbout, SysUtils, ShlObj, Forms,
     Dialogs, OpConst, OpDbOfc, OpDbOlk;



type
  TSHGetSpecialFolderLocation = function (hwndOwner: HWND; nFolder: Integer;
    var ppidl: PItemIDList): HResult; stdcall;

var
  Shell32Handle: HMODULE;
  DynSHGetSpecialFolderLocation: TSHGetSpecialFolderLocation;

{ TOpNestedCollectionEditor }

procedure TOpNestedCollectionEditor.Edit;
var
  Component : TComponent;
begin
  if GetComponent(0) is TOpNestedCollectionItem then
  begin
    Component := TOpNestedCollectionItem(GetComponent(0)).RootComponent
  end
  else
    Component := GetComponent(0) as TComponent;

  TfrmCollectionEditor.CreateEditor(Designer,Component,TCollection(GetOrdValue));
end;

function TOpNestedCollectionEditor.GetAttributes: TPropertyAttributes;
begin
  result := [paDialog, paReadOnly];
end;

function TOpNestedCollectionEditor.GetValue: string;
begin
  result := '(Nested Collection)' ;
end;


{ TOpModelProperty }

procedure TOpModelProperty.FilterModels(const S: String);
begin
  if not((GetComponent(0) as TComponent).Name = S) then
    FOldStrProc(S);
end;

procedure TOpModelProperty.GetValues(Proc: TGetStrProc);
begin
  FOldStrProc := Proc;
  Designer.GetComponentNames(GetTypeData(GetPropType),FilterModels);
end;


{ TOpOfficeFileProperty }

procedure TOpOfficeFileProperty.Edit;
var
  Comp: TPersistent;
  FileFilter, DefExt: string;
begin
  with TOpenDialog.Create(nil) do
    try
      Comp := GetComponent(0);
      if not (Comp is TOpOfficeComponent) then
        if Comp is TOpNestedCollectionItem then
          Comp := TOpNestedCollectionItem(Comp).RootComponent;
      if Comp is TOpOfficeComponent then
      begin
        TOpOfficeComponent(Comp).GetFileInfo(FileFilter, DefExt);
        Filter := FileFilter;
        DefaultExt := DefExt;
      end
      else begin
        Filter:= 'All Files|*.*';
        DefaultExt:= '';
      end;
      FileName:= GetStrValue;
      if Execute then
        SetStrValue(FileName);
    finally
      Free;
    end;
end;

function TOpOfficeFileProperty.GetAttributes: TPropertyAttributes;
begin
  result:= [paDialog];
end;


{ TOpMachineNameProperty }

procedure TOpMachineNameProperty.Edit;
var
  BrowseInfo: TBrowseInfo;
  ItemIDList: PItemIDList;
  MachineName: array[0..MAX_PATH] of Char;
  Title: string;
  WindowList: Pointer;
  Result: Boolean;
begin
  if (@DynSHGetSpecialFolderLocation = nil) or
    Failed(DynSHGetSpecialFolderLocation(Application.Handle, CSIDL_NETWORK,
    ItemIDList)) then
    raise Exception.Create('Machine Name Dialog not supported');
  FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
  BrowseInfo.hwndOwner := Application.Handle;
  BrowseInfo.pidlRoot := ItemIDList;
  BrowseInfo.pszDisplayName := MachineName;
  Title := 'Select Machine Name';
  BrowseInfo.lpszTitle := PChar(Pointer(Title));
  BrowseInfo.ulFlags := BIF_BROWSEFORCOMPUTER;
  WindowList := DisableTaskWindows(0);
  try
    Result := SHBrowseForFolder(BrowseInfo) <> nil;
  finally
    EnableTaskWindows(WindowList);
  end;
  if Result then SetValue(MachineName);
end;

function TOpMachineNameProperty.GetAttributes: TPropertyAttributes;
begin
  result:= [paDialog];
end;

{ TOpOfficeComponentInfo }

procedure TOpOfficeComponentInfo.ExecuteVerb(index: Integer);
var
  frmAbout : TFrmAbout;
begin
  frmAbout := TfrmAbout.Create(nil);
  try
    frmAbout.ShowModal;
  finally
    frmAbout.Free;
  end;
end;

procedure TOpOfficeComponentInfo.Edit;
begin
  if (Component is TOpExcel) then
    TfrmCollectionEditor.CreateEditor(Designer,Component,TOpExcel(Component).Workbooks)
  else
    if (Component is TOpWord) then
      TfrmCollectionEditor.CreateEditor(Designer,Component,TOpWord(Component).Documents)
    else
      if (Component is TOpPowerPoint) then
        TfrmCollectionEditor.CreateEditor(Designer,Component,TOpPowerPoint(Component).Presentations);
end;

function TOpOfficeComponentInfo.GetVerb(index: Integer): string;
begin
  Result := 'Application Info...';
end;

function TOpOfficeComponentInfo.GetVerbCount: Integer;
begin
  Result := 1;
end;

{ TOpOfficeAssistantProperty }

procedure TOpOfficeAssistantProperty.Edit;
var
  Comp: TPersistent;
  FileFilter, DefExt: string;
begin
  with TOpenDialog.Create(nil) do
    try
      Comp := GetComponent(0);
      if (Comp is TOpAssistant) then
      begin
        TOpAssistant(Comp).GetFileInfo(FileFilter, DefExt);
        Filter := FileFilter;
        DefaultExt := DefExt;
      end
      else begin
        Filter:= 'All Files|*.*';
        DefaultExt:= '';
      end;
      FileName:= GetStrValue;
      if Execute then
        SetStrValue(FileName);
    finally
      Free;
    end;
end;

function TOpOfficeAssistantProperty.GetAttributes: TPropertyAttributes;
begin
  result:= [paDialog];
end;

procedure Register;
begin
  RegisterComponents('OfficePartner', [TOpExcel, TOpWord, TOpOutlook,
    TOpPowerPoint, TOpEventModel, TOpDataSetModel, TOpContactsDataSet, TOpAssistant]);
  RegisterPropertyEditor(TypeInfo(TOpNestedCollection), TPersistent, '',
    TOpNestedCollectionEditor);
  RegisterPropertyEditor(TypeInfo(TFileName), TOpAssistant, '',
    TOpOfficeAssistantProperty);
  RegisterPropertyEditor(TypeInfo(TFileName), TOpWordDocument, 'DocFile',
    TOpOfficeFileProperty);
  RegisterPropertyEditor(TypeInfo(TFileName), TOpExcelWorkbook, 'FileName',
    TOpOfficeFileProperty);
  RegisterPropertyEditor(TypeInfo(TFileName), TOpPresentation, 'PresentationFile',
    TOpOfficeFileProperty);
  RegisterPropertyEditor(TypeInfo(WideString), TOpOfficeComponent, 'MachineName',
    TOpMachineNameProperty);
  RegisterPropertyEditor(TypeInfo(TOpDataSetModel), TOpDataSetModel, 'DetailModel',TOpModelProperty);
  RegisterComponentEditor(TOpOfficeComponent,TOpOfficeComponentInfo);
end;

initialization
  Shell32Handle := LoadLibrary('Shell32.dll');
  if Shell32Handle = 0 then RaiseLastWin32Error;
  @DynSHGetSpecialFolderLocation := GetProcAddress(Shell32Handle,
    'SHGetSpecialFolderLocation');
finalization
  if Shell32Handle <> 0 then FreeLibrary(Shell32Handle);
end.
