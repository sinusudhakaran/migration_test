unit wpDefEditor;
(*******************************************************************************
 * WPTools V5+6 - THE word processing component for VCL
 * Copyright (C) 2004 by WPCubed GmbH and Julian Ziersch, all rights reserved
 * St. Ingbert Str. 30, 81541 Munich, Germany
 * Tel.: +49-89-49053501, Fax.: 49-89-49053504
 * WEB: http://www.wpcubed.com   mailto: support@wptools.de
 *******************************************************************************
  PREDEFINED EDITOR
 ******************************************************************************)

  //16.10.2008

interface

{$I WPINC.INC}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  {$IFDEF WPXPRN} WPX_Dialogs, {$ELSE} Dialogs, {$ENDIF}
  Menus, ComCtrls, WPCTRRich, wpDefActions, ExtCtrls, WPRuler,
  WPRTEDefs, WPCTRMemo, Buttons, WPTbar, WPPanel, WPStyles, WP1Style, StdCtrls, WPRTEPaint, wpgutter,  WPAction
{$IFDEF WPREPORTER}
  , WPRTEReport
{$ENDIF};

type
  {:: This is the default editor of WPTools 5. It is used by the IDE but can also be used
  in your application whenever you need a popup editor for formatted text.
  <br>
  Simply create an instance of the form<br>
  <b>editor := TWPToolsEditor.Create(nil);</b><br>
  and display it with<br>
  <b>editor.Show;</b><br>
  <br>
  If you need to load text you can access the internal TWPRichText:<br>
  editor.WPRichText1.LoadFromFile(...)<br>
  You can also access the menu which is hosted by the action data module:<br>
  editor.WPDefAct.Info1.OnClick := MyOwnInfoDialogProcedure;
  }

  TWPToolsEditor = class(TForm)
  {$IFNDEF T2H}
    StatusBar1: TStatusBar;
    EditorParent1: TPanel;
    WPRichText1: TWPRichText;
    WPRuler1: TWPRuler;
    WPVertRuler1: TWPVertRuler;
    ToolPanel1: TPanel;
    RightToolPanel1: TPanel;
    WPToolPanel1: TWPToolPanel;
    WPComboBox1: TWPComboBox;
    WPComboBox2: TWPComboBox;
    WPComboBox3: TWPComboBox;
    WPComboBox4: TWPComboBox;
    WPComboBox5: TWPComboBox;
    WPToolButton1: TWPToolButton;
    WPToolButton2: TWPToolButton;
    WPToolButton3: TWPToolButton;
    WPToolButton4: TWPToolButton;
    WPToolButton5: TWPToolButton;
    WPToolButton6: TWPToolButton;
    WPToolButton7: TWPToolButton;
    WPToolButton8: TWPToolButton;
    WPToolButton9: TWPToolButton;
    WPToolButton10: TWPToolButton;
    WPToolButton11: TWPToolButton;
    WPToolButton12: TWPToolButton;
    WPToolButton13: TWPToolButton;
    WPToolButton14: TWPToolButton;
    WPToolButton15: TWPToolButton;
    BorderParent: TWPToolPanel;
    WPToolButton17: TWPToolButton;
    WPToolButton18: TWPToolButton;
    WPToolButton19: TWPToolButton;
    WPToolButton20: TWPToolButton;
    WPToolButton21: TWPToolButton;
    WPToolButton22: TWPToolButton;
    WPToolButton23: TWPToolButton;
    WPToolButton24: TWPToolButton;
    BorderButtonSwitch: TWPToolButton;
    Label1: TLabel;
    OKButton: TButton;
    CanvelButton: TButton;
    SizeCombo: TWPComboBox;
    procedure BorderButtonSwitchClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure WPRichText1OpenDialog(Sender: TObject;
      DiaType: TWPCustomRtfEditDialog; var ResultValue: Boolean);
    procedure WPRichText1TextObjectDblClick(Sender: TWPCustomRtfEdit;
      pobj: TWPTextObj; obj: TWPObject; var ignore: Boolean);
  private
{$IFDEF WPREPORTER}
    FWPSuperMerge: TWPSuperMerge;
    FWPReportDest: TWPRichText;
{$ENDIF}
    FWPDefAct: TWPDefAct;
    FReportDatabases : String;
    procedure GetToolsEditor(Sender: TObject; var wp: TWPCustomRichText);
  {$ENDIF}
  public
    // This functions are used when this editor is used as property editor
    procedure GetFromRTFText( Source : TWPRTFBlobContents);
    procedure SetToRTFText( Dest : TWPRTFBlobContents);
{$IFDEF WPREPORTER}
    procedure WPSuperMergeMailMergeGetText(Sender: TObject;
      const inspname: string; Contents: TWPMMInsertTextContents);
    procedure WPSuperMergeBeforeProcessGroup(
      Sender: TWPSuperMerge; Band: TWPBand; Count: Integer;
      var CustomData: TObject; var ProcessGroup, IsLastRun: Boolean);
{$ENDIF}
    {:: This property provides access to the default action
    data module used by the editor }
    property WPDefAct: TWPDefAct read FWPDefAct write FWPDefAct;
    property StatusBar: TStatusBar read StatusBar1 write StatusBar1;
    property EditorParent: TPanel read EditorParent1 write EditorParent1;
    property WPRichText: TWPRichText read WPRichText1 write WPRichText1;
    property WPRuler: TWPRuler read WPRuler1 write WPRuler1;
    property WPVertRuler: TWPVertRuler read WPVertRuler1 write WPVertRuler1;
    property ToolPanel: TPanel read ToolPanel1 write ToolPanel1;
    property RightToolPanel: TPanel read RightToolPanel1 write RightToolPanel1;
    property WPToolPanel: TWPToolPanel read WPToolPanel1 write WPToolPanel1;
    {:: This string is assigned to the databases property of the <see class="TWPSuperMerge"> component
    once the editor is created with WPReporter support }
    property ReportDatabases : String read FReportDatabases write FReportDatabases;
{$IFDEF WPREPORTER}
    property WPSuperMerge: TWPSuperMerge read FWPSuperMerge write FWPSuperMerge;
    property WPReportDest: TWPRichText read FWPReportDest write FWPReportDest;
{$ELSE}
{$IFDEF T2H}
    property WPSuperMerge: TWPSuperMerge read FWPSuperMerge write FWPSuperMerge;
    property FWPReportDest: TWPRichText read FWPReportDest write FWPReportDest;
{$ENDIF}
{$ENDIF}
  end;

var
  WPToolsEditor: TWPToolsEditor; 

implementation

{$R *.dfm}

procedure TWPToolsEditor.FormCreate(Sender: TObject);
begin
  WPDefAct:= TWPDefAct.Create(Self);
{$IFDEF WPREPORTER}
  FWPSuperMerge := TWPSuperMerge.Create(nil);
  FWPSuperMerge.DataBases := FReportDatabases;
  FWPSuperMerge.OnMailMergeGetText := WPSuperMergeMailMergeGetText;
  FWPSuperMerge.BeforeProcessGroup := WPSuperMergeBeforeProcessGroup;
  FWPReportDest := TWPRichText.CreateDynamic;
  FWPReportDest.InsertPointAttr.Hidden := TRUE;
  FWPSuperMerge.SetSourceDest(WPRichText1.Memo.RTFData, FWPReportDest.Memo.RTFData);
{$ENDIF}
  Menu := WPDefAct.MainMenu;
  WPRichText1.GraphicPopupMenu := WPDefAct.GraphicPopupMenu;

  // Standard attr in Word
  WPRichText1.DefaultAttr.SetFontName('Times New Roman');
  WPRichText1.DefaultAttr.SetFontSize(11);
end;

procedure TWPToolsEditor.FormDestroy(Sender: TObject);
begin
  WPRichText1.ActionList := nil;

{$IFDEF WPREPORTER}
  FWPSuperMerge.Free;
  FWPReportDest.Free;
{$ENDIF}
  WPDefAct.Free;
end;

procedure TWPToolsEditor.FormShow(Sender: TObject);
begin
  WPDefAct.OnGetWPRichText := GetToolsEditor;
  WPRichText1.ActionList := WPDefAct.StdActions;
  WPRichText1.SetFocus;
{$IFDEF WPREPORTER}
  WPDefAct.SuperMerge := FWPSuperMerge;
  WPDefAct.ReportDest := FWPReportDest;
{$ENDIF}
end;

procedure TWPToolsEditor.GetToolsEditor(Sender: TObject; var wp: TWPCustomRichText);
begin
  wp := WPRichText1;
end;

// This functions are used when this editor is used as property editor
procedure TWPToolsEditor.GetFromRTFText( Source : TWPRTFBlobContents);
begin
  WPRichText1.RTFText.Assign(Source);
  WPRichText1.RTFText.Apply;
  if Source.OwnerEngine<>nil then
    WPRichText1.Header.Assign(Source.OwnerEngine.RTFData.Header);
  WPRichText1.CPPosition := 0;
  WPRichText1.DelayedReformat;
end;

procedure TWPToolsEditor.SetToRTFText( Dest : TWPRTFBlobContents);
begin
  WPRichText1.RTFText.Update;
  Dest.Assign(WPRichText1.RTFText);
  Dest.Apply;
  if Dest.OwnerEngine<>nil then
    Dest.OwnerEngine.RTFData.Header.Assign(WPRichText1.Header);
end;

procedure TWPToolsEditor.BorderButtonSwitchClick(Sender: TObject);
begin
  BorderParent.Top := WPToolPanel1.Height;
  BorderParent.Left := Width - BorderParent.Width - 20;
  BorderParent.Visible := BorderButtonSwitch.Down;
end;

procedure TWPToolsEditor.FormResize(Sender: TObject);
begin
  if BorderParent.Visible then
  begin
    BorderParent.Top := WPToolPanel1.Height;
    BorderParent.Left := Width - BorderParent.Width - 20;
  end;
end;


{$IFDEF WPREPORTER}
procedure TWPToolsEditor.WPSuperMergeMailMergeGetText(Sender: TObject;
  const inspname: string; Contents: TWPMMInsertTextContents);
begin
  // Contents.StringValue := DataBase.FieldByName(inspname)
  Contents.StringValue := inspname + IntToStr(Random(100000));
end;

procedure TWPToolsEditor.WPSuperMergeBeforeProcessGroup(
  Sender: TWPSuperMerge; Band: TWPBand; Count: Integer;
  var CustomData: TObject; var ProcessGroup, IsLastRun: Boolean);
begin
  if Band.Alias = 'LOOP10' then
  begin
    IsLastRun := Count = 9;
    ProcessGroup := Count <= 9;
  end else
    if Band.Alias = 'LOOP100' then
    begin
      IsLastRun := Count = 99;
      ProcessGroup := Count <= 99;
    end;
end;
{$ENDIF}

procedure TWPToolsEditor.WPRichText1OpenDialog(Sender: TObject;
  DiaType: TWPCustomRtfEditDialog; var ResultValue: Boolean);
begin
  // Utility procedure to show style dialogs from unit WP1Style
  WPStyleOpenDialog(Self, Sender, DiaType, ResultValue);
end;

procedure TWPToolsEditor.WPRichText1TextObjectDblClick(
  Sender: TWPCustomRtfEdit; pobj: TWPTextObj; obj: TWPObject;
  var ignore: Boolean);
begin
  if pobj.ObjType = wpobjImage then
  begin
    if pobj.ObjRef <> nil then pobj.ObjRef.Edit;
    ignore := TRUE;
  end;
end;

end.

