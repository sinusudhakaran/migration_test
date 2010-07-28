unit WPAction;
{ -----------------------------------------------------------------------------
  WPAction  - Copyright (C) 2002 by wpcubed GmbH    -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  WPTools 5+6 Action Classes
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }
  // Last Update 30.11.2006 - see DONT_REPORT_DEFAULT_ATTR
  // Support for DevExpress ExpressBars by Michael Booth. Many Thanks!
  // add $define USEEXPRESSBARS to your Project options and do a BuildAll


interface

{$I WPINC.INC}

{$DEFINE NO_AT_FONTS} // wpfla_No_AT_Fonts (only WP6)


{$IFDEF WPDEMO}{$UNDEF USETBX}{$UNDEF USEEXPRESSBARS}{$ENDIF}

uses Controls, SysUtils, Messages, Windows, Classes, ActnList,
  StdCtrls, Forms, WPCtrMemo, WPCtrRich, WPRTEDefs, TypInfo, WPActnStr,
  {$IFDEF WPXPRN} WPX_Printers, WPX_Dialogs {$ELSE} Printers, Dialogs {$ENDIF}
{$IFDEF USETBX}
  ,Graphics, TB2Item, TBXExtItems, TBX, TBXThemes, TBXLists
{$ENDIF}
{$IFDEF USEEXPRESSBARS}
  ,Graphics, dxBar, dxBarExtItems
{$ENDIF};

{$IFNDEF VER130}
{$IFDEF USETBX}
{$MESSAGE Warn '*** TBX (Toolbar 2000) included due to compiler symbol "USETBX"'}
{$ENDIF}
{$IFDEF USEEXPRESSBARS}
{$MESSAGE Warn '*** DevExpress ExpressBars included due to compiler symbol "USEDEVEXPRESS"'}
{$ENDIF}
{$ENDIF}

{$IFDEF USECPP}{$DEFINE USECLNAME}{$ENDIF} // Enricos suggestion to avoid C++ Error

type

  TWPComboBoxStyle =
    (cbsStandard,
    cbsPrinterFonts,
    cbsScreenFonts,
    cbsAnyFonts,
    cbsTrueTypeFonts,
    cbsFontSize,
    cbsFontSizeManual,
    cbsColor,
    cbsBKColor,
    cbsParColor,
    cbsHtmlFontSize,
    cbsParAlignment,
    cbsStyleNames,
    cbsStyleNamesEx);

  TWPToolsCustomActionEvent = procedure(Action: TObject; var Ignore: Boolean) of object;

  TWPToolsCustomAction = class(TWPToolsBasicCustomAction)
  private
{$IFNDEF T2H}
    FStyle: TWPToolsActionStyle;
    FDontChangeImageIndex: Boolean;
    FBeforeExecute: TWPToolsCustomActionEvent;
    FAfterExecute: TNotifyEvent;
    FUseOwnCaption: Boolean;
    procedure SetControl(Value: TWPCustomRichText);
    procedure SetStyle(x: TWPToolsActionStyle);
  protected
    function GetControl(Target: TObject): TWPCustomRichText; virtual;
    function GetParam: string; virtual;
    procedure SetRTFEdit(edit: TWPCustomRichText); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    property Style: TWPToolsActionStyle read FStyle write SetStyle;
{$ENDIF}
  public
{$IFNDEF T2H}
    constructor CreateStyled(aOwner: TComponent; aStyle: TWPToolsActionStyle);
    destructor Destroy; override;
    function HandlesTarget(Target: TObject): Boolean; override;
    function Execute: Boolean; override;
    procedure UpdateTarget(Target: TObject); override;
    procedure UpdateCaption; override;
    property Control: TWPCustomRichText read FControl write SetControl;
{$ENDIF}
  published
    property UseOwnCaption: Boolean read FUseOwnCaption write FUseOwnCaption;
    property UseOwnImageIndex: Boolean read FDontChangeImageIndex write FDontChangeImageIndex;
    property BeforeExecute: TWPToolsCustomActionEvent read FBeforeExecute write FBeforeExecute;
    property AfterExecute: TNotifyEvent read FAfterExecute write FAfterExecute;
{$IFNDEF T2H}
    property Caption;
    property Checked;
    property Enabled;
    property HelpContext;
    property Hint;
    property ImageIndex;
    property ShortCut;
    property Visible;
    // property OnExecute;
    property OnHint;
    // property OnUpdate;
{$ENDIF}
  end;


  TWPToolsCustomEditContolAction = class(TWPToolsCustomAction)
  protected
{$IFNDEF T2H}
    FAttachedControl: TComponent;
    FAttachedControlStyle: TWPComboBoxStyle;
{$IFDEF USETBX}
    FUpdating: Boolean;
    FOldPopup: procedure(Sender: TTBCustomItem; FromLink: Boolean) of object;
    procedure DoChange(Sender: TObject; const Text: string);
    procedure DoPopup(Sender: TTBCustomItem; FromLink: Boolean);
    procedure OnDrawItem(Sender: TTBXCustomList; ACanvas: TCanvas;
      ARect: TRect; AIndex, AHoverIndex: Integer; var DrawDefault: Boolean);
{$ENDIF}
{$IFDEF USEEXPRESSBARS}
    FUpdating: Boolean;
    FOldDropDown: procedure(Sender: TObject) of object;
    procedure DoChange(Sender: TObject);
    procedure DoDropDown(Sender: TObject);
{$ENDIF}
    procedure SetAttachedControl(x: TComponent);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetRTFEdit(edit: TWPCustomRichText); override;
    procedure Attach;
    procedure Detach;
    procedure DoComboClick(Sender: TObject);
    procedure SetAttachedControlStyle(x: TWPComboBoxStyle);
  public
    function Update: Boolean; override;
{$ENDIF}
  published
    property AttachedControl: TComponent read FAttachedControl write SetAttachedControl;
    property AttachedControlStyle: TWPComboBoxStyle read FAttachedControlStyle write SetAttachedControlStyle;
  end;

  TWPToolsAction = class(TWPToolsCustomAction)
  published
    property Style;
  end;
{$IFNDEF T2H}
  TWPAZoomOut = class(TWPToolsCustomAction)
  public constructor Create(AOwner: TComponent); override; end;
  TWPAZoomIn = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPABBottom = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPABInner = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPABLeft = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPABAllOff = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPABAllOn = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPABOuter = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPABRight = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPABTop = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPABullets = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  {$IFNDEF LEGACT}TWPACancel = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;{$ENDIF}
  TWPACenter = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAClose = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPACopy = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPACreateTable = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPACut = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPADecIndent = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  {$IFNDEF LEGACT}TWPADelete = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;{$ENDIF}
  TWPACombineCell = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  {$IFNDEF LEGACT}TWPAAdd = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;{$ENDIF}
  TWPADelRow = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  {$IFNDEF LEGACT}TWPAEdit = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;{$ENDIF}
  {$IFNDEF LEGACT}TWPAExit = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end; {$ENDIF}
  TWPASearch = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAFitHeight = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAFitWidth = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPASellAll = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAHidden = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAIncIndent = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPASplitCells = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAInsRow = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAItalic = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPABold = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAJustified = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPALeft = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAProtected = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPANew = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  {$IFNDEF LEGACT}TWPANext = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;{$ENDIF}
  TWPANorm = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPANumbers = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAOpen = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAPaste = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  {$IFNDEF LEGACT}TWPAOK = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end; {$ENDIF}
  TWPAUndo = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  {$IFNDEF LEGACT}TWPAToEnd = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;{$ENDIF}
 {$IFNDEF LEGACT} TWPAToStart = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;{$ENDIF}
  {$IFNDEF LEGACT}TWPABack = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;{$ENDIF}
  TWPAPrint = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAPriorPage = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAPrinterSetup = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPANextPage = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAReplace = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPARight = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  {$IFNDEF LEGACT}TWPARTFCode = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;{$ENDIF}
  TWPASave = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAHideSelection = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPASelectColumn = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPASelectRow = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAFindNext = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPASpellcheck = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPASpellAsYouGo = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAStartThesaurus = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;

  TWPAUnderline = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAStrikeout = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPASubscript = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPASuperscript = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;

  {$IFDEF WP6}
  TWPAUppercase = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;

  TWPASmallCaps = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  {$ENDIF}

  TWPAInsCol = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPADelCol = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAPrintDia = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;


   // New V4 Actions
  TWPADeleteText = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPARedo = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;

  TWPAInsertNumber = class(TWPToolsCustomAction)
  private
    FFieldType: TWPTextFieldType;
  protected function GetParam: string; override;
  public constructor Create(aOwner: TComponent); override;
  published property FieldType: TWPTextFieldType read FFieldType write FFieldType;
  end;
  TWPAInsertField = class(TWPToolsCustomAction)
  private
    FFieldName: string;
  protected function GetParam: string; override;
  public constructor Create(aOwner: TComponent); override;
  published property FieldName: string read FFieldName write FFieldName;
  end;

  TWPAIsOutlineMode = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAInOutlineUp = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
  TWPAInOutlineDown = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;

  TWPAEditHyperlink = class(TWPToolsCustomAction)
  public constructor Create(aOwner: TComponent); override; end;
{$ENDIF}

  TWPTBCustomCombo = class(TComboBox)
  protected
    _OnClick: TNotifyEvent;
    FLockUpdate: Boolean;
  public
    FRtfEdit: TWPCustomRTFEdit;
  end;

procedure WPTInitFonts;
function WPTGetFontType(const FontName: string): Boolean;


   // Increment this to load new language strings
var WPToolsCustomActionLanguage: string = 'WPTools/Actions';

implementation

var FAllActions: TList;
  FAllTTF, FAllNonTTF: TStringList;

function EnumFontsProc(var LogFont: TLogFont; var TextMetric: TTextMetric;
  FontType: Integer; Data: Pointer): Integer; stdcall;
begin
  if FontType = TRUETYPE_FONTTYPE then
    FAllTTF.Add(StrPas(LogFont.lfFaceName))
  else FAllNonTTF.Add(StrPas(LogFont.lfFaceName));
  Result := 1;
end;

procedure WPTInitFonts;
var
  DC: HDC;
  LFont: TLogFont;
begin
  if FAllTTF = nil then
  begin
    if FAllTTF = nil then FAllTTF := TStringList.Create;
    if FAllNonTTF = nil then FAllNonTTF := TStringList.Create;
    DC := GetDC(0);
    try
      FillChar(LFont, sizeof(LFont), 0);
      LFont.lfCharset := DEFAULT_CHARSET;
      EnumFontFamiliesEx(DC, LFont, @EnumFontsProc, 0, 0);
    finally
      ReleaseDC(0, DC);
    end;
  end;
end;

function WPTGetFontType(const FontName: string): Boolean;
var
  Metrics: TTextMetric;
  lf: TLogFont;
  oldFont, newFont: HFont;
  dc: HDC;
  afontname: string;
begin
  if FAllTTF = nil then FAllTTF := TStringList.Create;
  if FAllNonTTF = nil then FAllNonTTF := TStringList.Create;

  afontname := lowercase(FontName);

  if FAllTTF.IndexOf(afontname) >= 0 then begin Result := TRUE; exit; end;
  if FAllNonTTF.IndexOf(afontname) >= 0 then begin Result := FALSE; exit; end;

  with lf do
  begin
    lfHeight := 10;
    lfWidth := 10;
    lfEscapement := 0;
    lfWeight := FW_REGULAR;
    lfItalic := 0;
    lfUnderline := 0;
    lfStrikeOut := 0;
    lfCharSet := DEFAULT_CHARSET;
    lfOutPrecision := OUT_DEFAULT_PRECIS;
    lfClipPrecision := CLIP_DEFAULT_PRECIS;
    lfQuality := DEFAULT_QUALITY;
    lfPitchAndFamily := DEFAULT_PITCH or FF_DONTCARE;
    StrPCopy(lfFaceName, FontName);
  end;
  Result := TRUE;
  newFont := CreateFontIndirect(lf);
  if newfont <> 0 then
  begin
    dc := GetDC(0);
    try
      oldFont := SelectObject(dc, newFont);
      if oldfont <> 0 then
      begin
        if GetTextMetrics(dc, Metrics) then
        begin
          Result := (Metrics.tmPitchAndFamily and TMPF_TRUETYPE) <> 0;
        end;
        SelectObject(dc, oldFont);
      end;
      DeleteObject(newFont);
    finally
      ReleaseDC(0, dc);
    end;
  end;

  if Result then FAllTTF.Add(afontname)
  else FAllNonTTF.Add(afontname);
end;

procedure TWPToolsCustomEditContolAction.SetAttachedControlStyle(x: TWPComboBoxStyle);
begin
  FAttachedControlStyle := x;
  if x in [cbsPrinterFonts,
    cbsScreenFonts,
    cbsAnyFonts,
    cbsTrueTypeFonts] then WPTInitFonts;
end;

procedure TWPToolsCustomEditContolAction.DoComboClick(Sender: TObject);
begin
{$IFDEF USECLNAME}
  if CompareText(Sender.ClassName, 'TWPTBCustomCombo') = 0 then
{$ELSE}
  if Sender is TWPTBCustomCombo then
{$ENDIF}
    TWPTBCustomCombo(Sender).FRtfEdit := Control;
end;

procedure TWPToolsCustomEditContolAction.Attach;
begin
  // --------------------------------------- attach to TWPTBCustomCombo
  if (FAttachedControl <> nil) and
{$IFDEF USECLNAME}
  (CompareText(FAttachedControl.ClassName, 'TWPTBCustomCombo') = 0)
{$ELSE}
  (FAttachedControl is TWPTBCustomCombo)
{$ENDIF}
  then
  begin
    TWPTBCustomCombo(FAttachedControl)._OnClick := DoComboClick;
  end;
  // --------------------------------------- attach to TTBXComboBoxItem (TBX)
{$IFDEF USETBX}
  if (FAttachedControl <> nil) and
{$IFDEF USECLNAME}
  (CompareText(FAttachedControl.ClassName, 'TTBXComboBoxItem') = 0)
{$ELSE}
  (FAttachedControl is TTBXComboBoxItem)
{$ENDIF}
  then
  begin
    FOldPopup := TTBXComboBoxItem(FAttachedControl).OnPopup;
    TTBXComboBoxItem(FAttachedControl).OnPopup := DoPopup;
  end;
{$ENDIF}
 // --------------------------------------- attach to TdxBarCombo (DevEx)
{$IFDEF USEEXPRESSBARS}
  if (FAttachedControl <> nil) and
{$IFDEF USECLNAME}
  (CompareText(FAttachedControl.ClassName, 'TdxBarCombo') = 0) or
  (CompareText(FAttachedControl.ClassName, 'TdxBarFontNameCombo') = 0)
{$ELSE}
  (FAttachedControl is TdxBarCustomCombo)
{$ENDIF}
  then
  begin
    FOldDropDown := TdxBarCustomCombo(FAttachedControl).OnDropDown;
    TdxBarCustomCombo(FAttachedControl).OnDropDown := DoDropDown;
  end;
{$ENDIF}
end;


procedure TWPToolsCustomEditContolAction.Detach;
begin
  // --------------------------------------- detach from TWPTBCustomCombo
  if (FAttachedControl <> nil) and
{$IFDEF USECLNAME}
  (CompareText(FAttachedControl.ClassName, 'TWPTBCustomCombo') = 0)
{$ELSE}
  (FAttachedControl is TWPTBCustomCombo)
{$ENDIF}
  then
  begin
    TWPTBCustomCombo(FAttachedControl)._OnClick := nil;
  end;
  // --------------------------------------- detach from TTBXComboBoxItem
{$IFDEF USETBX}
  if (FAttachedControl <> nil) and
{$IFDEF USECLNAME}
  (CompareText(FAttachedControl.ClassName, 'TTBXComboBoxItem') = 0)
{$ELSE}
  (FAttachedControl is TTBXComboBoxItem)
{$ENDIF}
  then
  begin
    TTBXComboBoxItem(FAttachedControl).OnPopup := FOldPopup;
  end;
{$ENDIF}
  // --------------------------------------- detach from TdxBarCombo
{$IFDEF USEEXPRESSBARS}
  if (FAttachedControl <> nil) and
{$IFDEF USECLNAME}
  (CompareText(FAttachedControl.ClassName, 'TdxBarCombo') = 0) or
  (CompareText(FAttachedControl.ClassName, 'TdxBarFontNameCombo') = 0)
{$ELSE}
  (FAttachedControl is TdxBarCustomCombo)
{$ENDIF}
  then
  begin
    TdxBarCustomCombo(FAttachedControl).OnDropDown := FOldDropDown;
  end;
{$ENDIF}
end;

{$IFDEF USETBX}

procedure TWPToolsCustomEditContolAction.OnDrawItem(Sender: TTBXCustomList; ACanvas: TCanvas;
  ARect: TRect; AIndex, AHoverIndex: Integer; var DrawDefault: Boolean);
begin
  {$IFDEF WP6}
  if (Sender is TTBXStringList) and
      (FAttachedControlStyle in
     [cbsPrinterFonts,
    cbsScreenFonts,
    cbsAnyFonts,
    cbsTrueTypeFonts]) then
  begin
    if TTBXStringList(Sender).Strings[AIndex]=WPFontListAssignSeperator then
    begin
      ACanvas.FillRect(ARect);
      ACanvas.Moveto( ARect.Left, (ARect.Top + ARect.Bottom ) div 2 );
      ACanvas.Lineto( ARect.Right, (ARect.Top + ARect.Bottom ) div 2 );
      DrawDefault := false;
    end else DrawDefault := true;
  end
  else
  {$ENDIF}
  DrawDefault := true;
end;

procedure TWPToolsCustomEditContolAction.DoChange(Sender: TObject; const Text: string);
var fs: Single;
  typ: TWpSelNr;
begin
  if (FAttachedControl = Sender) and (FControl <> nil) and not FUpdating then
  begin
    case FAttachedControlStyle of
      cbsPrinterFonts,
        cbsScreenFonts,
        cbsTrueTypeFonts:
        if Screen.Fonts.IndexOf(Text) >= 0 then
          FControl.CurrAttr.FontName := Text;

      cbsFontSize,
        cbsHtmlFontSize, cbsFontSizeManual:
        begin
          if Text <> '' then
          try
            if Trim(Text) = '' then fs := 0
            else fs := StrToFloat(Trim(Text));
            FControl.CurrAttr.Size := fs;
          except
          end;
        end;
      cbsParAlignment:
        begin
          if CompareText(Text, WPLoadStr(meDiaAlLeft)) = 0 then
            FControl.CurrAttr.Alignment := paralLeft
          else if CompareText(Text, WPLoadStr(meDiaAlCenter)) = 0 then
            FControl.CurrAttr.Alignment := paralCenter
          else if CompareText(Text, WPLoadStr(meDiaAlRight)) = 0 then
            FControl.CurrAttr.Alignment := paralRight
          else if CompareText(Text, WPLoadStr(meDiaAlJustified)) = 0 then
            FControl.CurrAttr.Alignment := paralBlock;
        end;
      cbsStyleNames, cbsStyleNamesEx:
        begin
          typ := wptStyleNames;
          FControl.OnToolBarSelection(Self, typ, Text, 0);
        end;
    end;
  end;
end;

procedure TWPToolsCustomEditContolAction.DoPopup(Sender: TTBCustomItem; FromLink: Boolean);
var i: Integer;
begin
  if (FAttachedControl = nil) then exit
  else if {$IFDEF USECLNAME}
  (CompareText(FAttachedControl.ClassName, 'TTBXComboBoxItem') = 0)
{$ELSE}
  (FAttachedControl is TTBXComboBoxItem)
{$ENDIF} then
  begin
    TTBXComboBoxItem(FAttachedControl).OnChange := DoChange;
    case FAttachedControlStyle of
      cbsPrinterFonts,
        cbsScreenFonts:
        begin
          if not WPNoPrinterInstalled and (Printer.Printers.Count > 0) and
            (FAttachedControlStyle = cbsPrinterFonts)
            then begin
            try TTBXComboBoxItem(FAttachedControl).Strings.Assign(Printer.Fonts);
            except TTBXComboBoxItem(FAttachedControl).Strings.Assign(Screen.Fonts);
            end;
          end else TTBXComboBoxItem(FAttachedControl).Strings.Assign(Screen.Fonts);

          {$IFDEF WP6} // Insert Faves
             if FControl<>nil then
             begin
                FControl.FontListAssign( TTBXComboBoxItem(FAttachedControl).Strings,
                   [wpfla_Favorites,wpfla_InsertAtStart,wpfla_Seperator{$IFDEF NO_AT_FONTS},wpfla_No_AT_Fonts{$ENDIF}] );
             TTBXComboBoxItem(FAttachedControl).OnDrawItem := OnDrawItem;
                //TTBXComboBoxItem(FAttachedControl).Style := csOwnerDrawFixed;

             end;
          {$ENDIF}


        // TTBXComboBoxItem(FAttachedControl).OnDrawItem := OnDrawItem;
        // Style := csOwnerDrawFixed;
        end;
      cbsTrueTypeFonts:
        begin
          TTBXComboBoxItem(FAttachedControl).Strings.Assign(Screen.Fonts);
          for i := TTBXComboBoxItem(FAttachedControl).Strings.Count - 1 downto 0 do
            if not WPTGetFontType(TTBXComboBoxItem(FAttachedControl).Strings[i]) then TTBXComboBoxItem(FAttachedControl).Strings.Delete(i);
        //
        // Style := csOwnerDrawFixed;

          {$IFDEF WP6} // Insert Faves
             if FControl<>nil then
             begin
                FControl.FontListAssign( TTBXComboBoxItem(FAttachedControl).Strings,
                   [wpfla_Favorites,wpfla_InsertAtStart,wpfla_Seperator{$IFDEF NO_AT_FONTS},wpfla_No_AT_Fonts{$ENDIF}] );
                TTBXComboBoxItem(FAttachedControl).OnDrawItem := OnDrawItem;
             end;
          {$ENDIF}


        end;
      cbsFontSize:
        begin
          TTBXComboBoxItem(FAttachedControl).Strings.Clear;
          for i := 6 to 72 do TTBXComboBoxItem(FAttachedControl).Strings.Add(#32 + InttoStr(i));
        // OnDrawItem := ListBoxDrawItem;
        // Style := csOwnerDrawFixed;
        end;
      cbsHtmlFontSize:
        begin
          TTBXComboBoxItem(FAttachedControl).Strings.Clear;
               // 8,10,12,14,18,24,36 (see unit WPWrtHT)
          TTBXComboBoxItem(FAttachedControl).Strings.Add(#32 + '8');
          TTBXComboBoxItem(FAttachedControl).Strings.Add(#32 + '10');
          TTBXComboBoxItem(FAttachedControl).Strings.Add(#32 + '12');
          TTBXComboBoxItem(FAttachedControl).Strings.Add(#32 + '14');
          TTBXComboBoxItem(FAttachedControl).Strings.Add(#32 + '18');
          TTBXComboBoxItem(FAttachedControl).Strings.Add(#32 + '24');
          TTBXComboBoxItem(FAttachedControl).Strings.Add(#32 + '36');
        // OnDrawItem := ListBoxDrawItem;
        // Style := csOwnerDrawFixed;
        end;
      cbsFontSizeManual:
        begin
        // OnDrawItem := ListBoxDrawItem;
        // Style := csOwnerDrawFixed;
        end;
      cbsColor, cbsBKColor, cbsParColor:
        begin
          // NOT SUPPORTED - USE THE BUTTONS
        end;
      cbsParAlignment:
        begin
          TTBXComboBoxItem(FAttachedControl).Strings.Clear;
          TTBXComboBoxItem(FAttachedControl).Strings.Add(WPLoadStr(meDiaAlLeft));
          TTBXComboBoxItem(FAttachedControl).Strings.Add(WPLoadStr(meDiaAlCenter));
          TTBXComboBoxItem(FAttachedControl).Strings.Add(WPLoadStr(meDiaAlRight));
          TTBXComboBoxItem(FAttachedControl).Strings.Add(WPLoadStr(meDiaAlJustified));
        end;
      cbsStyleNames, cbsStyleNamesEx:
        begin
          TTBXComboBoxItem(FAttachedControl).Strings.Clear;
          if (FControl <> nil) then
            FControl.Memo.RTFData.RTFProps.ParStyles.GetStringList(TTBXComboBoxItem(FAttachedControl).Strings, true);
        end;
    end;
  end;
end;
{$ENDIF}  // UseTBX

{$IFDEF USEEXPRESSBARS}

procedure TWPToolsCustomEditContolAction.DoChange(Sender: TObject);
var fs: Single;
  typ: TWpSelNr;
  Text : string;
begin
  if (FAttachedControl = Sender) and (FControl <> nil) and not FUpdating then
  begin
    Text := TdxBarCustomCombo(Sender).Text;

    case FAttachedControlStyle of
      cbsPrinterFonts,
        cbsScreenFonts,
        cbsTrueTypeFonts:
        if Screen.Fonts.IndexOf(Text) >= 0 then
          FControl.CurrAttr.FontName := Text;

      cbsFontSize,
        cbsHtmlFontSize, cbsFontSizeManual:
        begin
          if Text <> '' then
          try
            if Trim(Text) = '' then fs := 0
            else fs := StrToFloat(Trim(Text));
            FControl.CurrAttr.Size := fs;
          except
          end;
        end;
      cbsParAlignment:
        begin
          if CompareText(Text, WPLoadStr(meDiaAlLeft)) = 0 then
            FControl.CurrAttr.Alignment := paralLeft
          else if CompareText(Text, WPLoadStr(meDiaAlCenter)) = 0 then
            FControl.CurrAttr.Alignment := paralCenter
          else if CompareText(Text, WPLoadStr(meDiaAlRight)) = 0 then
            FControl.CurrAttr.Alignment := paralRight
          else if CompareText(Text, WPLoadStr(meDiaAlJustified)) = 0 then
            FControl.CurrAttr.Alignment := paralBlock;
        end;
      cbsStyleNames, cbsStyleNamesEx:
        begin
          typ := wptStyleNames;
          FControl.OnToolBarSelection(Self, typ, Text, 0);
        end;
    end;
  end;
end;

procedure TWPToolsCustomEditContolAction.DoDropDown(Sender: TObject);
var i: Integer;
begin
  if (FAttachedControl = nil) then exit
  else if {$IFDEF USECLNAME}
  (CompareText(FAttachedControl.ClassName, 'TdxBarCombo') = 0) or
  (CompareText(FAttachedControl.ClassName, 'TdxBarFontNameCombo') = 0)
{$ELSE}
  (FAttachedControl is TdxBarCustomCombo)
{$ENDIF} then
  begin
    TdxBarCustomCombo(FAttachedControl).OnChange := DoChange;

    if {$IFDEF USECLNAME}
    (CompareText(FAttachedControl.ClassName, 'TdxBarCombo') = 0)
{$ELSE}
    (FAttachedControl is TdxBarCombo)
{$ENDIF} then
    begin
      case FAttachedControlStyle of
        cbsPrinterFonts,
          cbsScreenFonts:
          begin
            if not WPNoPrinterInstalled and (Printer.Printers.Count > 0) and
              (FAttachedControlStyle = cbsPrinterFonts)
              then begin
              try TdxBarCombo(FAttachedControl).Items.Assign(Printer.Fonts);
              except TdxBarCombo(FAttachedControl).Items.Assign(Screen.Fonts);
              end;
            end else TdxBarCombo(FAttachedControl).Items.Assign(Screen.Fonts);

          // TdxBarCombo(FAttachedControl).OnDrawItem := OnDrawItem;
          // Style := csOwnerDrawFixed;
          end;
        cbsTrueTypeFonts:
          begin
            TdxBarCombo(FAttachedControl).Items.Assign(Screen.Fonts);
            for i := TdxBarCombo(FAttachedControl).Items.Count - 1 downto 0 do
              if not WPTGetFontType(TdxBarCombo(FAttachedControl).Items[i]) then TdxBarCombo(FAttachedControl).Items.Delete(i);
          // OnDrawItem := ListBoxDrawItem;
          // Style := csOwnerDrawFixed;
          end;
        cbsFontSize:
          begin
            TdxBarCombo(FAttachedControl).Items.Clear;
            for i := 6 to 72 do TdxBarCombo(FAttachedControl).Items.Add(#32 + InttoStr(i));
          // OnDrawItem := ListBoxDrawItem;
          // Style := csOwnerDrawFixed;
          end;
        cbsHtmlFontSize:
          begin
            TdxBarCombo(FAttachedControl).Items.Clear;
                 // 8,10,12,14,18,24,36 (see unit WPWrtHT)
            TdxBarCombo(FAttachedControl).Items.Add(#32 + '8');
            TdxBarCombo(FAttachedControl).Items.Add(#32 + '10');
            TdxBarCombo(FAttachedControl).Items.Add(#32 + '12');
            TdxBarCombo(FAttachedControl).Items.Add(#32 + '14');
            TdxBarCombo(FAttachedControl).Items.Add(#32 + '18');
            TdxBarCombo(FAttachedControl).Items.Add(#32 + '24');
            TdxBarCombo(FAttachedControl).Items.Add(#32 + '36');
          // OnDrawItem := ListBoxDrawItem;
          // Style := csOwnerDrawFixed;
          end;
        cbsFontSizeManual:
          begin
          // OnDrawItem := ListBoxDrawItem;
          // Style := csOwnerDrawFixed;
          end;
        cbsColor, cbsBKColor, cbsParColor:
          begin
            // NOT SUPPORTED - USE THE BUTTONS
          end;
        cbsParAlignment:
          begin
            TdxBarCombo(FAttachedControl).Items.Clear;
            TdxBarCombo(FAttachedControl).Items.Add(WPLoadStr(meDiaAlLeft));
            TdxBarCombo(FAttachedControl).Items.Add(WPLoadStr(meDiaAlCenter));
            TdxBarCombo(FAttachedControl).Items.Add(WPLoadStr(meDiaAlRight));
            TdxBarCombo(FAttachedControl).Items.Add(WPLoadStr(meDiaAlJustified));
          end;
        cbsStyleNames, cbsStyleNamesEx:
          begin
            TdxBarCombo(FAttachedControl).Items.Clear;
            if (FControl <> nil) then
              FControl.Memo.RTFData.RTFProps.ParStyles.GetStringList(TdxBarCombo(FAttachedControl).Items, true);
          end;
      end;
    end;
  end;
end;
{$ENDIF} // USEEXPRESSBARS



procedure TWPToolsCustomEditContolAction.SetAttachedControl(x: TComponent);
begin
  Detach;
  FAttachedControl := x;
  if FAttachedControl <> nil then
  begin
    FAttachedControl.FreeNotification(Self);
    Attach;
  end;
end;

procedure TWPToolsCustomEditContolAction.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (FAttachedControl <> nil) and
      (AComponent = FAttachedControl) then FAttachedControl := nil;
  end;
end;

function TWPToolsCustomEditContolAction.Update: Boolean;
begin
  Result := TRUE;
end;

procedure TWPToolsCustomEditContolAction.SetRTFEdit(edit: TWPCustomRichText);
var i : Integer;
 {$IFDEF DONT_REPORT_DEFAULT_ATTR}
{$IFDEF USETBX} var fnt : TFontName; aSize : Single; {$ENDIF}
{$ENDIF}
{$IFDEF USEEXPRESSBARS}var fnt : TFontName; aSize : Single; Color : TColor; {$ENDIF}
begin
  inherited SetRTFEdit(Edit);
  if FAttachedControl <> nil then
  begin
{$IFDEF USETBX}
    if (edit <> nil) and
{$IFDEF USECLNAME}
    (CompareText(FAttachedControl.ClassName, 'TTBXComboBoxItem') = 0)
{$ELSE}
    (FAttachedControl is TTBXComboBoxItem)
{$ENDIF}
    then
    begin
      FUpdating := TRUE;
      try
        case FAttachedControlStyle of
          cbsPrinterFonts,
            cbsScreenFonts, cbsTrueTypeFonts: //V5.19.2 - clear the font combo
            begin
            // Not required aynmore since it is dealt with in WPCtrRich, GetFontName
            // DONT_REPORT_DEFAULT_ATTR should be NOT defined normally !
            {$IFDEF DONT_REPORT_DEFAULT_ATTR}
              if Edit.IsSelected then
              begin
                if not Edit.SelectedTextAttr.GetFontName(fnt) then
                  TTBXComboBoxItem(FAttachedControl).Text := ''
                else TTBXComboBoxItem(FAttachedControl).Text := fnt;
              end else
              {$ENDIF}
              TTBXComboBoxItem(FAttachedControl).Text := edit.CurrAttr.FontName;
            end;
          cbsFontSize, cbsHtmlFontSize, cbsFontSizeManual:
          begin
            // Not required aynmore since it is dealt with in WPCtrRich, GetFontName
            // DONT_REPORT_DEFAULT_ATTR should be NOT defined normally !
            {$IFDEF DONT_REPORT_DEFAULT_ATTR}
              if Edit.IsSelected then //V5.19.5
            begin
               if not Edit.SelectedTextAttr.GetFontSize(aSize) then
                  TTBXComboBoxItem(FAttachedControl).Text := ''
                else TTBXComboBoxItem(FAttachedControl).Text := FloatToStr(aSize);
            end else
            {$ENDIF}
            if edit.CurrAttr.Size = 0 then
              TTBXComboBoxItem(FAttachedControl).Text := ''
            else TTBXComboBoxItem(FAttachedControl).Text :=
              FloatToStr(edit.CurrAttr.Size);
          end;
          cbsColor, cbsBKColor, cbsParColor:
            begin
          // NOT SUPPORTED - USE THE BUTTONS
            end;
          cbsParAlignment:
            begin
              if edit.AGet(WPAT_Alignment, i) then
                TTBXComboBoxItem(FAttachedControl).Text := WPLoadStr(TWPVCLString(Integer(meDiaAlLeft) + i))
            // paralLeft, paralCenter, paralRight, paralBlock
            // --> meDiaAlLeft, meDiaAlCenter, meDiaAlRight, meDiaAlJustified,
              else TTBXComboBoxItem(FAttachedControl).Text := '';
            end;
          cbsStyleNames, cbsStyleNamesEx:
            begin
              if edit.ActiveStyleName = '' then
                TTBXComboBoxItem(FAttachedControl).Text :=
                  WPLoadStr(meUndefinedStyle)
              else TTBXComboBoxItem(FAttachedControl).Text := edit.CurrAttr.StyleName;
            end;
        end;
      finally
        FUpdating := FALSE;
      end;
    end else
{$ENDIF}
// -----------------------------------------------------------------------------
{$IFDEF USEEXPRESSBARS}
    if (edit <> nil) and
{$IFDEF USECLNAME}
    (CompareText(FAttachedControl.ClassName, 'TdxBarCombo') = 0) or
    (CompareText(FAttachedControl.ClassName, 'TdxBarFontNameCombo')
{$ELSE}
    (FAttachedControl is TdxBarCustomCombo)
{$ENDIF}
    then
    begin
      FUpdating := TRUE;
      try
        case FAttachedControlStyle of
          cbsPrinterFonts,
            cbsScreenFonts, cbsTrueTypeFonts: //V5.19.2 - clear the font combo
            begin
              if Edit.IsSelected then
              begin
                if not Edit.SelectedTextAttr.GetFontName(fnt) then
                  TdxBarCustomCombo(FAttachedControl).Text := ''
                else TdxBarCustomCombo(FAttachedControl).Text := fnt;
              end else TdxBarCustomCombo(FAttachedControl).Text := edit.CurrAttr.FontName;
            end;
          cbsFontSize, cbsHtmlFontSize, cbsFontSizeManual:
          begin
            if Edit.IsSelected then //V5.19.5
            begin
               if not Edit.SelectedTextAttr.GetFontSize(aSize) then
                  TdxBarCustomCombo(FAttachedControl).Text := ''
                else TdxBarCustomCombo(FAttachedControl).Text := FloatToStr(aSize);
            end else
            if edit.CurrAttr.Size = 0 then
              TdxBarCustomCombo(FAttachedControl).Text := ''
            else TdxBarCustomCombo(FAttachedControl).Text :=
              FloatToStr(edit.CurrAttr.Size);
          end;
          cbsColor:
            begin
              Edit.CurrentCharAttr.getColor(Color);
              TdxBarColorCombo(FAttachedControl).Color:=Color;
            end;
          cbsBKColor:
            begin
              Edit.CurrentCharAttr.GetBGColor(Color);
              TdxBarColorCombo(FAttachedControl).Color:=Color;
            end;
          cbsParColor:
            begin
              if Edit.CurrentCharAttr.AGet(WPAT_BGColor, i) then
                  TdxBarColorCombo(FAttachedControl).Color := Edit.NrToColor(i);
            end;
          cbsParAlignment:
            begin
              if edit.AGet(WPAT_Alignment, i) then
                TdxBarCustomCombo(FAttachedControl).Text := WPLoadStr(TWPVCLString(Integer(meDiaAlLeft) + i))
            // paralLeft, paralCenter, paralRight, paralBlock
            // --> meDiaAlLeft, meDiaAlCenter, meDiaAlRight, meDiaAlJustified,
              else TdxBarCustomCombo(FAttachedControl).Text := '';
            end;
          cbsStyleNames, cbsStyleNamesEx:
            begin
              if edit.ActiveStyleName = '' then
                TdxBarCustomCombo(FAttachedControl).Text :=
                  WPLoadStr(meUndefinedStyle)
              else TdxBarCustomCombo(FAttachedControl).Text := edit.CurrAttr.StyleName;
            end;
        end;
      finally
        FUpdating := FALSE;
      end;
    end else
{$ENDIF}
// -----------------------------------------------------------------------------
      if FAttachedControl is TWinControl then
        SendMessage(
          TWinControl(FAttachedControl).Handle,
          WP_RTFEDIT_CHANGED, 0, Cardinal(FControl))
      else if FAttachedControl is TCustomControl then
        SendMessage(
          TCustomControl(FAttachedControl).Handle,
          WP_RTFEDIT_CHANGED, 0, Cardinal(FControl));
  end;
end;

constructor TWPToolsCustomAction.CreateStyled(aOwner: TComponent; aStyle: TWPToolsActionStyle);
begin
  inherited Create(aOwner);
  FAllActions.Add(Self);
  Style := aStyle;
end;

destructor TWPToolsCustomAction.Destroy;
var i: Integer;
begin
  i := FAllActions.IndexOf(Self);
  if i >= 0 then FAllActions.Delete(i);
  inherited Destroy;
end;

procedure TWPToolsCustomAction.SetStyle(x: TWPToolsActionStyle);
begin
  FStyle := x;
  if not FDontChangeImageIndex then ImageIndex := Integer(x);
  WPGetActionCommandGroup(FStyle, FNr, FGroup);
  UpdateCaption;
end;

function TWPToolsCustomAction.GetControl(Target: TObject): TWPCustomRichText;
begin
  Result := Target as TWPCustomRichText;
end;

function TWPToolsCustomAction.GetParam: string;
begin
  Result := '';
end;

function TWPToolsCustomAction.HandlesTarget(Target: TObject): Boolean;
begin
  Result := ((Control <> nil) and (Target = Control) or
    (Control = nil) and (Target is TWPCustomRichText)) and
    TWPCustomRichText(Target).Focused;
end;

function TWPToolsCustomAction.Execute: Boolean;
var stat: TWpSelNr; Ignore: Boolean;
begin
  Ignore := FALSE;
  if Assigned(FBeforeExecute) then FBeforeExecute(Self, Ignore);
  if not Ignore and (Control <> nil) then
  begin  
    if Checked then stat := wptIconDeSel else stat := wptIconSel;
    try
      Control.OnToolBarIconSelection(Self, stat, GetParam, FGroup, FNR, 0);
      Result := TRUE;
    except
      on e:Exception do
      begin
         if Caption<>'' then
              ShowMessage( Caption + ':' + #10 + e.Message)
         else ShowMessage( e.Message);
         Result := FALSE;
      end;
    end;
    if Result and assigned(FAfterExecute) then FAfterExecute(Self);
  end else Result := FALSE;
end;

procedure TWPToolsCustomAction.SetRTFEdit(edit: TWPCustomRichText);
begin
  FControl := edit;
end;

procedure TWPToolsCustomAction.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = Control) then Control := nil;
end;

procedure TWPToolsCustomAction.UpdateTarget(Target: TObject);
begin
  // Status nach Liste in WPRichText ermitteln
  // Enabled := GetControl(Target).SelLength > 0;
end;

procedure TWPToolsCustomAction.UpdateCaption;
var aCap, aHint: string;
begin
  aCap := '';
  aHint := '';
  if not FUseOwnCaption then
  begin
    WPGetActionHintCaption(Fstyle, aCap, aHint);
    Caption := aCap;
    Hint := aHint;
  end;
end;

procedure TWPToolsCustomAction.SetControl(Value: TWPCustomRichText);
begin
  if Value <> FControl then
  begin
    FControl := Value;
    if Value <> nil then Value.FreeNotification(Self);
  end;
end;

   { All Action classes -----------------------------------}

constructor TWPAZoomOut.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaZoomOut); end;

constructor TWPAZoomIn.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaZoomIn); end;

constructor TWPABBottom.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaBBottom); end;

constructor TWPABInner.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaBInner); end;

constructor TWPABLeft.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaBLeft); end;

constructor TWPABAllOff.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaBAllOff); end;

constructor TWPABAllOn.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaBAllOn); end;

constructor TWPABOuter.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaBOuter); end;

constructor TWPABRight.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaBRight); end;

constructor TWPABTop.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaBTop); end;

constructor TWPABullets.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaBullets); end;

{$IFNDEF LEGACT}constructor TWPACancel.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaCancel); end;{$ENDIF}

constructor TWPACenter.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaCenter); end;

constructor TWPAClose.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaClose); end;

constructor TWPACopy.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaCopy); end;

constructor TWPACreateTable.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaCreateTable); end;

constructor TWPACut.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaCut); end;

constructor TWPADecIndent.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaDecIndent); end;

{$IFNDEF LEGACT}constructor TWPADelete.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaDelete); end; {$ENDIF}

constructor TWPACombineCell.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaCombineCell); end;

{$IFNDEF LEGACT}constructor TWPAAdd.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaAdd); end;{$ENDIF}

constructor TWPADelRow.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaDelRow); end;

{$IFNDEF LEGACT}constructor TWPAEdit.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaEdit); end;{$ENDIF}

{$IFNDEF LEGACT}constructor TWPAExit.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaExit); end;{$ENDIF}

constructor TWPASearch.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaSearch); end;

constructor TWPAFitHeight.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaFitHeight); end;

constructor TWPAFitWidth.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaFitWidth); end;

constructor TWPASellAll.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, {$IFNDEF LEGACT}wpaSellAll{$ELSE}wpaSelAll{$ENDIF}); end;

constructor TWPAHidden.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaHidden); end;

constructor TWPAIncIndent.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaIncIndent); end;

constructor TWPASplitCells.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaSplitCells); end;

constructor TWPAInsRow.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaInsRow); end;

constructor TWPAItalic.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaItalic); end;

constructor TWPABold.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaBold); end;

constructor TWPAJustified.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaJustified); end;

constructor TWPALeft.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaLeft); end;

constructor TWPAProtected.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaProtected); end;

constructor TWPANew.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaNew); end;

{$IFNDEF LEGACT}constructor TWPANext.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaNext); end; {$ENDIF}

constructor TWPANorm.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaNorm); end;

constructor TWPANumbers.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaNumbers); end;

constructor TWPAOpen.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaOpen); end;

constructor TWPAPaste.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaPaste); end;

{$IFNDEF LEGACT}constructor TWPAOK.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaOK); end;{$ENDIF}

constructor TWPAUndo.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaUndo); end;

{$IFNDEF LEGACT}constructor TWPAToEnd.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaToEnd); end;{$ENDIF}

{$IFNDEF LEGACT}constructor TWPAToStart.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaToStart); end;{$ENDIF}

{$IFNDEF LEGACT}constructor TWPABack.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaBack); end;{$ENDIF}

constructor TWPAPrint.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaPrint); end;

constructor TWPAPriorPage.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaPriorPage); end;

constructor TWPAPrinterSetup.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaPrinterSetup); end;

constructor TWPANextPage.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaNextPage); end;

constructor TWPAReplace.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaReplace); end;

constructor TWPARight.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaRight); end;

{$IFNDEF LEGACT}constructor TWPARTFCode.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaRTFCode); end;{$ENDIF}

constructor TWPASave.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaSave); end;

constructor TWPAHideSelection.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaHideSelection); end;

constructor TWPASelectColumn.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaSelectColumn); end;

constructor TWPASelectRow.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaSelectRow); end;

constructor TWPAFindNext.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaFindNext); end;

constructor TWPASpellcheck.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaSpellcheck); end;

constructor TWPASpellAsYouGo.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaSpellAsYouGo); end;

constructor TWPAStartThesaurus.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaStartThesaurus); end;

constructor TWPAUnderline.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaUnderline); end;

constructor TWPAStrikeout.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaStrikeout); end;

constructor TWPASubscript.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaSubscript); end;

constructor TWPASuperscript.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaSuperscript); end;

constructor TWPAInsCol.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaInsCol); end;

constructor TWPADelCol.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaDelCol); end;

constructor TWPAPrintDia.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaPrintDialog); end;

   // **************************************************************************
   // New V4 Actions ***********************************************************
   // **************************************************************************

constructor TWPADeleteText.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaDeleteText); end;

constructor TWPARedo.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaRedo); end;

constructor TWPAInsertNumber.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaInsertNumber); end;

function TWPAInsertNumber.GetParam: string;
begin Result := WPTextFieldNames[FFieldType]; end;

constructor TWPAInsertField.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wapInsertField); end;

function TWPAInsertField.GetParam: string;
begin Result := FFieldName; end;

constructor TWPAIsOutlineMode.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaIsOutline); end;

constructor TWPAInOutlineUp.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaOutlineUp); end;

constructor TWPAInOutlineDown.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaOutlineDown); end;

constructor TWPAEditHyperlink.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaEditHyperlink); end;

   // **************************************************************************
   // New V6 Actions ***********************************************************
   // **************************************************************************

{$IFDEF WP6}
constructor TWPAUppercase.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaUppercase); end;

constructor TWPASmallCaps.Create(aOwner: TComponent);
begin inherited CreateStyled(aOwner, wpaSmallCaps); end;

{$ENDIF}


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
var prev_WPRefreshActionStrings: procedure;

procedure doWPRefreshActionStrings;
var a: Integer;
begin
  for a := 0 to FAllActions.Count - 1 do
    TWPToolsCustomAction(FAllActions[a]).UpdateCaption;
  if assigned(prev_WPRefreshActionStrings) then prev_WPRefreshActionStrings;
end;

initialization
  FAllActions := TList.Create;
  prev_WPRefreshActionStrings := WPRefreshActionStrings;
  WPRefreshActionStrings := Addr(doWPRefreshActionStrings);

finalization
  FAllActions.Free;
  FAllTTF.Free;
  FAllNonTTF.Free;
  WPRefreshActionStrings := prev_WPRefreshActionStrings;

end.

