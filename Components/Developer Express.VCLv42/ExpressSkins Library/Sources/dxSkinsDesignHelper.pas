{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{                    ExpressSkins Library                            }
{                                                                    }
{       Copyright (c) 2006-2009 Developer Express Inc.               }
{       ALL RIGHTS RESERVED                                          }
{                                                                    }
{   The entire contents of this file is protected by U.S. and        }
{   International Copyright Laws. Unauthorized reproduction,         }
{   reverse-engineering, and distribution of all or any portion of   }
{   the code contained in this file is strictly prohibited and may   }
{   result in severe civil and criminal penalties and will be        }
{   prosecuted to the maximum extent possible under the law.         }
{                                                                    }
{   RESTRICTIONS                                                     }
{                                                                    }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES            }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE     }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS    }
{   LICENSED TO DISTRIBUTE THE EXPRESSSKINS AND ALL ACCOMPANYING     }
{   VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY.              }
{                                                                    }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED       }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE         }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE        }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT   }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                       }
{                                                                    }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON        }
{   ADDITIONAL RESTRICTIONS.                                         }
{                                                                    }
{********************************************************************}

unit dxSkinsDesignHelper;

{$I cxVer.inc}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxLookAndFeels, cxLookAndFeelPainters, cxClasses, StdCtrls,
  ToolIntf, ExptIntf, ToolsApi, CheckLst, ExtCtrls, Menus;

type
  TdxSkinsUnitsState = (susDisabled, susEnabled, susUndefined);

  { TdxSkinsUnitStateListItem }

  TdxSkinsUnitStateListItem = class(TObject)
  private
    FName: string;
    FState: TdxSkinsUnitsState;
    FUnitName: string;
    function GetEnabled: Boolean;
  public
    constructor Create(const AUnitName, AName: string);

    property Enabled: Boolean read GetEnabled;
    property Name: string read FName;
    property State: TdxSkinsUnitsState read FState write FState;
    property UnitName: string read FUnitName;
  end;

  { TdxSkinsUnitStateList }

  TdxSkinsUnitStateList = class(TcxIUnknownObject, IcxLookAndFeelPainterListener)
  private
    FEnabled: Boolean;
    FInitialized: Boolean;
    FList: TcxObjectList;
    function GetCount: Integer;
    function GetCurrentProjectFileName: string;
    function GetHasUndefinedItems: Boolean;
    function GetItem(AIndex: Integer): TdxSkinsUnitStateListItem;
    function GetNeedShowConfirmation: Boolean;
    function GetSkinsConfigFileName: string;
  protected
    procedure Finalize;
    procedure Initialize;
    // IcxLookAndFeelPainterListener
    procedure PainterChanged(APainter: TcxCustomLookAndFeelPainterClass);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function FindItemByName(const AName: string;
      var AItem: TdxSkinsUnitStateListItem): Boolean;
    procedure LoadSettings;
    procedure RefreshUnitsList;
    procedure SaveSettings;
    procedure UpdateActiveProjectSettings;

    property Count: Integer read GetCount;
    property CurrentProjectFileName: string read GetCurrentProjectFileName;
    property Enabled: Boolean read FEnabled write FEnabled;
    property HasUndefinedItems: Boolean read GetHasUndefinedItems;
    property Initialized: Boolean read FInitialized;
    property Item[Index: Integer]: TdxSkinsUnitStateListItem read GetItem;
    property NeedShowConfirmation: Boolean read GetNeedShowConfirmation;
    property SkinsConfigFileName: string read GetSkinsConfigFileName;
  end;

  { TdxSkinsProjectOptionsMenuExpert }

  TdxSkinsProjectOptionsMenuExpert = class(TObject)
  private
    FMenuItem: TMenuItem;
    function GetProjectMenuItem: TMenuItem;
    procedure DoMenuItemClick(Sender: TObject);
  protected
    function CalcMenuItemPosition(AParent: TMenuItem): Integer;
    function CreateMenuItem(AParent: TMenuItem): TMenuItem;
    function FindMenuItemByName(AParent: TMenuItem; const AName: string): TMenuItem;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    property MenuItem: TMenuItem read FMenuItem;
    property ProjectMenuItem: TMenuItem read GetProjectMenuItem;
  end;

  { TdxSkinsDesignHelper }

  TdxSkinsDesignHelper = class(TcxIUnknownObject,
    IOTAModuleNotifier, IOTANotifier, IOTAIDENotifier)
  private
    FActiveProject: IOTAProject;
    FActiveProjectNotifierID: Integer;
    FMenuExpert: TdxSkinsProjectOptionsMenuExpert;
    FServicesNotifierID: Integer;
    procedure SetActiveProject(AProject: IOTAProject);
  protected
    function RegisterModuleNotifier(AModule: IOTAModule): Integer;
    procedure RegisterIDENotifier;
    procedure UnregisterIDENotifier;
    procedure UnregisterModuleNotifier(AModule: IOTAModule; ID: Integer);
    procedure UpdateMenuItemState;
    // IOTAModuleNotifier
    function CheckOverwrite: Boolean;
    procedure ModuleRenamed(const NewName: string);
    // IOTANotifier
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    // IOTAIDENotifier
    procedure AfterCompile(Succeeded: Boolean);
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
    procedure FileNotification(NotifyCode: TOTAFileNotification;
      const FileName: string; var Cancel: Boolean);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    property ActiveProject: IOTAProject read FActiveProject write SetActiveProject;
    property MenuExpert: TdxSkinsProjectOptionsMenuExpert read FMenuExpert;
  end;

  { TdxSkinsDesignHelperForm }

  TdxSkinsDesignHelperForm = class(TForm)
    bCancel: TButton;
    bOk: TButton;
    bSelectAll: TButton;
    bSelectNone: TButton;
    bvFrame: TBevel;
    cbSkinsAutoFilling: TCheckBox;
    CheckListBoxHolder: TBevel;
    Image: TImage;
    lbNotes: TLabel;
    lbSkins: TLabel;
    pbFrame: TPaintBox;
    plNotes: TPanel;
    procedure bSelectAllClick(Sender: TObject);
    procedure cbSkinsAutoFillingClick(Sender: TObject);
    procedure pbFramePaint(Sender: TObject);
  private
    CheckListBox: TCheckListBox;
    procedure ApplySettings(ADropToDefault: Boolean);
    procedure PopulateList;
  public
    constructor Create(AOwner: TComponent); override;
    class procedure Execute;
    function IsShortCut(var Message: TWMKey): Boolean; override;
  end;

function dxSkinsListFilter(const ASkinName: string): Boolean;
function dxSkinsUnitStateList: TdxSkinsUnitStateList;
procedure dxSkinsShowProjectOptionsDialog;
implementation

{$R *.dfm}

{$R dxSkinsDesignHelper.res}

uses
  IniFiles, dxSkinsLookAndFeelPainter, dxSkinsStrs;

const
  //don't localize!
  sdxSkinsCfgExt = '.skincfg';
  sdxSkinsCfgSection = 'ExpressSkins';
  sdxSkinsMenuItemGlyphResName = 'DXSKINSDESIGNHELPERICON';
  sdxSkinsRegProjectState = 'Enabled';

  sdxSkinCheckListBoxHint =
    'Select skins in this list to make them available' + #13#10 +
    'within the project. Selecting skins automatically adds' + #13#10 +
    'corresponding skin units to the ''uses'' clause.' + #13#10 +
    'New skins added to the project are highlighted in bold.';
  sdxEnableSkinSupportHint =
    'Check this option to enable skins within the current project.' + #13#10 +
    'If enabled, all required skin painter units will be automatically' + #13#10 +
    'added to the ''uses'' clause.';
  sdxSkinsMenuItemCaption = '&Modify Skin Options';

  BoolToUnitState: array[Boolean] of TdxSkinsUnitsState = (susDisabled, susEnabled);

type

  { TdxSkinsCheckListBox }

  TdxSkinsCheckListBox = class(TCheckListBox)
  private
    FAllowBoldSelection: Boolean;
  protected
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    //
    property AllowBoldSelection: Boolean read FAllowBoldSelection write FAllowBoldSelection;
  end;

var
  SkinsDesignHelper: TdxSkinsDesignHelper;
  SkinsUnitsStateList: TdxSkinsUnitStateList;

function dxSkinsUnitStateList: TdxSkinsUnitStateList;
begin
  if SkinsUnitsStateList = nil then
    SkinsUnitsStateList := TdxSkinsUnitStateList.Create;
  Result := SkinsUnitsStateList;
end;

function dxSkinsGetCurrentProjectFileName: string;
var
  AProject: IOTAProject;
begin
  if Assigned(ToolServices) then
    Result := ToolServices.GetProjectName
  else
  begin
    AProject := GetActiveProject;
    if AProject = nil then
      Result := ''
    else
    begin
      Result := AProject.FileName;
      AProject := nil;
    end;
  end;
end;

procedure dxSkinsShowProjectOptionsDialog;
begin
  TdxSkinsDesignHelperForm.Execute;
end;

function dxSkinsListFilter(const ASkinName: string): Boolean;
var
  AItem: TdxSkinsUnitStateListItem;
begin
  Result := dxSkinsUnitStateList.Enabled and
    dxSkinsUnitStateList.FindItemByName(ASkinName, AItem) and AItem.Enabled;
end;

{ TdxSkinsUnitStateList }

constructor TdxSkinsUnitStateList.Create;
begin
  FEnabled := True;
  FList := TcxObjectList.Create;
  GetExtendedStylePainters.AddListener(Self);
  RefreshUnitsList;
end;

destructor TdxSkinsUnitStateList.Destroy;
begin
  Finalize;
  FList.Clear;
  GetExtendedStylePainters.RemoveListener(Self);
  FreeAndNil(FList);
  inherited Destroy;
end;

procedure TdxSkinsUnitStateList.Finalize;
begin
  FInitialized := False;
end;

procedure TdxSkinsUnitStateList.Initialize;
begin
  FInitialized := True;
end;

function TdxSkinsUnitStateList.FindItemByName(const AName: string;
  var AItem: TdxSkinsUnitStateListItem): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
  begin
    Result := SameText(AName, Item[I].Name);
    if Result then
    begin
      AItem := Item[I];
      Break;
    end;
  end;
end;

function TdxSkinsUnitStateList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TdxSkinsUnitStateList.GetHasUndefinedItems: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
  begin
    Result := Item[I].State = susUndefined;
    if Result then
      Break;
  end;
end;

function TdxSkinsUnitStateList.GetItem(AIndex: Integer): TdxSkinsUnitStateListItem;
begin
  Result := TdxSkinsUnitStateListItem(FList.Items[AIndex]);
end;

function TdxSkinsUnitStateList.GetNeedShowConfirmation: Boolean;
begin
  Result := Enabled and HasUndefinedItems;
end;

function TdxSkinsUnitStateList.GetSkinsConfigFileName: string;
begin
  Result := ChangeFileExt(CurrentProjectFileName, sdxSkinsCfgExt);
end;

function TdxSkinsUnitStateList.GetCurrentProjectFileName: string;
begin
  Result := dxSkinsGetCurrentProjectFileName;
end;

procedure TdxSkinsUnitStateList.LoadSettings;
var
  AConfig: TIniFile;
  AItem: TdxSkinsUnitStateListItem;
  I: Integer;
begin
  if FileExists(CurrentProjectFileName) then
  begin
    if FileExists(SkinsConfigFileName) then
      Initialize;
      
    AConfig := TIniFile.Create(SkinsConfigFileName);
    try
      FEnabled := AConfig.ReadBool(sdxSkinsCfgSection, sdxSkinsRegProjectState, True);
      for I := 0 to Count - 1 do
      begin
        AItem := Item[I];
        if AConfig.ValueExists(sdxSkinsCfgSection, AItem.UnitName) then
          AItem.State := BoolToUnitState[
            AConfig.ReadBool(sdxSkinsCfgSection, AItem.UnitName, True)]
        else
          AItem.State := susUndefined;
      end;
    finally
      AConfig.Free;
    end;
  end;
end;

procedure TdxSkinsUnitStateList.PainterChanged(APainter: TcxCustomLookAndFeelPainterClass);
begin
  RefreshUnitsList;
end;

procedure TdxSkinsUnitStateList.RefreshUnitsList;
var
  AExtendedStylePainters: TcxExtendedStylePainters;
  AItem: TdxSkinsUnitStateListItem;
  APainter: TcxCustomLookAndFeelPainterClass;
  I: Integer;
begin
  FList.Clear;
  AExtendedStylePainters := GetExtendedStylePainters;
  for I := 0 to AExtendedStylePainters.Count - 1 do
  begin
    APainter := AExtendedStylePainters.Painters[I];
    if APainter.InheritsFrom(TdxSkinLookAndFeelPainter) then
    begin
      AItem := TdxSkinsUnitStateListItem.Create(
        TdxSkinLookAndFeelPainterClass(APainter).InternalUnitName,
        AExtendedStylePainters.Names[I]);
      AItem.State := susUndefined;
      FList.Add(AItem);
    end;
  end;
  LoadSettings;
end;

procedure TdxSkinsUnitStateList.SaveSettings;
var
  AConfig: TIniFile;
  I: Integer;
begin
  if Initialized and FileExists(CurrentProjectFileName) then
  begin
    AConfig := TIniFile.Create(SkinsConfigFileName);
    try
      try
        AConfig.WriteBool(sdxSkinsCfgSection, sdxSkinsRegProjectState, Enabled);
        for I := 0 to Count - 1 do
          with Item[I] do
            AConfig.WriteBool(sdxSkinsCfgSection, UnitName, Enabled);
      except
        on EIniFileException do
        else
          raise;
      end;
    finally
      AConfig.Free;
    end;
  end;
end;

procedure TdxSkinsUnitStateList.UpdateActiveProjectSettings;
begin
  LoadSettings;
  if NeedShowConfirmation then
    dxSkinsShowProjectOptionsDialog;
end;

{ TdxSkinsUnitStateListItem }

constructor TdxSkinsUnitStateListItem.Create(const AUnitName, AName: string);
begin
  FName := AName;
  FUnitName := AUnitName;
end;

function TdxSkinsUnitStateListItem.GetEnabled: Boolean;
begin
  Result := State <> susDisabled;
end;

{ TdxSkinsCheckListBox }

procedure TdxSkinsCheckListBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  Canvas.Font.Assign(Font);
  if (dxSkinsUnitStateList.Item[Index].State = susUndefined) and AllowBoldSelection then
    Canvas.Font.Style := [fsBold];
  if odSelected in State then
    Canvas.Font.Color := clHighlightText;
  inherited DrawItem(Index, Rect, State);
end;

{ TdxSkinsDesignHelperForm }

constructor TdxSkinsDesignHelperForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CheckListBox := TdxSkinsCheckListBox.Create(Self);
  CheckListBox.Parent := Self;
  CheckListBox.Hint := sdxSkinCheckListBoxHint;
  CheckListBox.BoundsRect := CheckListBoxHolder.BoundsRect;
  TdxSkinsCheckListBox(CheckListBox).AllowBoldSelection :=
    FileExists(dxSkinsUnitStateList.SkinsConfigFileName);

  cbSkinsAutoFilling.Hint := sdxEnableSkinSupportHint;
  cbSkinsAutoFilling.Checked := dxSkinsUnitStateList.Enabled;
  cbSkinsAutoFillingClick(nil);
  PopulateList;                         
end;

class procedure TdxSkinsDesignHelperForm.Execute;
begin
  with TdxSkinsDesignHelperForm.Create(nil) do
  try
    dxSkinsUnitStateList.Initialize;
    ApplySettings(ShowModal <> mrOk);
    dxSkinsUnitStateList.SaveSettings;
  finally
    Free;
  end;
end;

procedure TdxSkinsDesignHelperForm.ApplySettings(ADropToDefault: Boolean);
var
  AItem: TdxSkinsUnitStateListItem;
  I: Integer;
begin
  if not ADropToDefault then
    dxSkinsUnitStateList.Enabled := cbSkinsAutoFilling.Checked;
    
  for I := 0 to CheckListBox.Count - 1 do
  begin
    AItem := dxSkinsUnitStateList.Item[I];
    if ADropToDefault then
      AItem.State := BoolToUnitState[AItem.Enabled]
    else
      AItem.State := BoolToUnitState[CheckListBox.Checked[I]];
  end;
end;

function TdxSkinsDesignHelperForm.IsShortCut(var Message: TWMKey): Boolean;
begin
  Result := Message.CharCode = VK_ESCAPE;
  if Result then
    PostMessage(Handle, WM_CLOSE, 0, 0)
  else
    Result := inherited IsShortCut(Message);
end;

procedure TdxSkinsDesignHelperForm.PopulateList;
var
  I: Integer;
begin
  dxSkinsUnitStateList.LoadSettings;
  CheckListBox.Items.BeginUpdate;
  try
    CheckListBox.Items.Clear;
    for I := 0 to dxSkinsUnitStateList.Count - 1 do
      with dxSkinsUnitStateList.Item[I] do
      begin
        CheckListBox.Items.Add(Name);
        CheckListBox.Checked[I] := Enabled;
      end;
  finally
    CheckListBox.Items.EndUpdate;
  end;
end;

procedure TdxSkinsDesignHelperForm.cbSkinsAutoFillingClick(Sender: TObject);
begin
  bSelectAll.Enabled := cbSkinsAutoFilling.Checked;
  bSelectNone.Enabled := cbSkinsAutoFilling.Checked;
  CheckListBox.Enabled := cbSkinsAutoFilling.Checked;
end;

procedure TdxSkinsDesignHelperForm.bSelectAllClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to CheckListBox.Count - 1 do
    CheckListBox.Checked[I] := TComponent(Sender).Tag = 1;
end;

procedure TdxSkinsDesignHelperForm.pbFramePaint(Sender: TObject);
begin
  pbFrame.Canvas.Pen.Color := clBtnShadow;
  pbFrame.Canvas.Brush.Color := clInfoBk;
  pbFrame.Canvas.Rectangle(pbFrame.ClientRect);
end;

{ TdxSkinsProjectOptionsMenuExpert }

constructor TdxSkinsProjectOptionsMenuExpert.Create;
begin
  FMenuItem := CreateMenuItem(ProjectMenuItem);
end;

destructor TdxSkinsProjectOptionsMenuExpert.Destroy;
begin
  FreeAndNil(FMenuItem);
  inherited Destroy;
end;

function TdxSkinsProjectOptionsMenuExpert.CalcMenuItemPosition(AParent: TMenuItem): Integer;
var
  AItem: TMenuItem;
begin
  AItem := FindMenuItemByName(AParent, 'ProjectOptionsItem');
  if AItem = nil then
    Result := AParent.Count - 1
  else
    Result := AParent.IndexOf(AItem);
end;

function TdxSkinsProjectOptionsMenuExpert.CreateMenuItem(AParent: TMenuItem): TMenuItem;
begin
  Result := nil;
  if Assigned(AParent) then
  begin
    Result := TMenuItem.Create(nil);
    Result.Caption := sdxSkinsMenuItemCaption;
    Result.OnClick := DoMenuItemClick;
    Result.Bitmap.LoadFromResourceName(HInstance, sdxSkinsMenuItemGlyphResName);
    if AParent.GetImageList <> nil then
      Result.ImageIndex := AParent.GetImageList.AddMasked(Result.Bitmap, clFuchsia);
    AParent.Insert(CalcMenuItemPosition(AParent), Result);
  end;
end;

procedure TdxSkinsProjectOptionsMenuExpert.DoMenuItemClick(Sender: TObject);
begin
  dxSkinsShowProjectOptionsDialog;
end;

function TdxSkinsProjectOptionsMenuExpert.FindMenuItemByName(
  AParent: TMenuItem; const AName: string): TMenuItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to AParent.Count - 1 do
    if SameText(AParent.Items[I].Name, AName) then
    begin
      Result := AParent.Items[I];
      Break;
    end;
end;

function TdxSkinsProjectOptionsMenuExpert.GetProjectMenuItem: TMenuItem;
var
  AServices: INTAServices;
begin
  if Supports(BorlandIDEServices, INTAServices, AServices) then
    Result := FindMenuItemByName(AServices.MainMenu.Items, 'ProjectMenu')
  else
    Result := nil;
end;

{ TdxSkinsDesignHelper }

constructor TdxSkinsDesignHelper.Create;
begin
  FMenuExpert := TdxSkinsProjectOptionsMenuExpert.Create;
  RegisterIDENotifier;
  ActiveProject := GetActiveProject;
end;

destructor TdxSkinsDesignHelper.Destroy;
begin
  ActiveProject := nil;
  UnregisterIDENotifier;
  FreeAndNil(FMenuExpert);
  inherited Destroy;
end;

// IOTAIDENotifier
procedure TdxSkinsDesignHelper.AfterCompile(Succeeded: Boolean);
begin
end;

procedure TdxSkinsDesignHelper.BeforeCompile(
  const Project: IOTAProject; var Cancel: Boolean);
begin
end;

procedure TdxSkinsDesignHelper.FileNotification(NotifyCode: TOTAFileNotification;
  const FileName: string; var Cancel: Boolean);
begin
  if NotifyCode = ofnActiveProjectChanged then
    ActiveProject := GetActiveProject;
end;

// IOTAModuleNotifier
function TdxSkinsDesignHelper.CheckOverwrite: Boolean;
begin
  Result := True;
end;

procedure TdxSkinsDesignHelper.ModuleRenamed(const NewName: string);
begin
end;

// IOTANotifier
procedure TdxSkinsDesignHelper.AfterSave;
begin
  dxSkinsUnitStateList.SaveSettings;
end;

procedure TdxSkinsDesignHelper.BeforeSave;
begin
end;

procedure TdxSkinsDesignHelper.Destroyed;
begin
  ActiveProject := GetActiveProject;
end;

procedure TdxSkinsDesignHelper.Modified;
begin
end;

procedure TdxSkinsDesignHelper.SetActiveProject(AProject: IOTAProject);
begin
  if AProject <> FActiveProject then
  begin
    UnregisterModuleNotifier(ActiveProject, FActiveProjectNotifierID);
    FActiveProject := AProject;
    FActiveProjectNotifierID := RegisterModuleNotifier(ActiveProject);
    dxSkinsUnitStateList.Finalize;
    dxSkinsUnitStateList.RefreshUnitsList;
    UpdateMenuItemState;
  end;
end;

procedure TdxSkinsDesignHelper.RegisterIDENotifier;
var
  AServices: IOTAServices;
begin
  if Supports(BorlandIDEServices, IOTAServices, AServices) then
    FServicesNotifierID := AServices.AddNotifier(Self)
  else
    FServicesNotifierID := -1;
end;

procedure TdxSkinsDesignHelper.UnregisterIDENotifier;
var
  AServices: IOTAServices;
begin
  if FServicesNotifierID >= 0 then
  begin
    if Supports(BorlandIDEServices, IOTAServices, AServices) then
      AServices.RemoveNotifier(FServicesNotifierID);
    FServicesNotifierID := -1;
  end;
end;

function TdxSkinsDesignHelper.RegisterModuleNotifier(AModule: IOTAModule): Integer;
begin
  if AModule = nil then
    Result := -1
  else
    Result := AModule.AddNotifier(Self);
end;

procedure TdxSkinsDesignHelper.UnregisterModuleNotifier(AModule: IOTAModule; ID: Integer);
begin
  if Assigned(AModule) then
    AModule.RemoveNotifier(ID);
end;

procedure TdxSkinsDesignHelper.UpdateMenuItemState;
begin
  if Assigned(MenuExpert.MenuItem) then
    MenuExpert.MenuItem.Visible := Assigned(ActiveProject);
end;

initialization
  SkinsDesignHelper := TdxSkinsDesignHelper.Create;

finalization
  FreeAndNil(SkinsDesignHelper);
  FreeAndNil(SkinsUnitsStateList);

end.
