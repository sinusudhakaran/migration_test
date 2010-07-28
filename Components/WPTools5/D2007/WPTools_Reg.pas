unit WPTools_Reg;
{ -----------------------------------------------------------------------------
  WpTools  - Copyright (C) 2004 by wpcubed GmbH      -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  No part of this library may be distributed as source or as part of any
  module, component, activeX or vcl.
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

  {xx$DEFINE NODsgnIntf}
  {xx$DEFINE NODB}

interface
{$I WPINC.INC}

{$IFDEF WPQUICK4}{$DEFINE WPQUICK}{$ENDIF}

{$IFDEF WPPDFEX}
{$I wpdf_inc.inc} // to embedd wPDF directly in WPTools package
{$IFDEF WPQUICk}{$DEFINE WPDF_QR}{$ENDIF}
{$ENDIF}

{$IFDEF VER130}
{$UNDEF DELPHI6ANDUP} // Delphi 5 or BCB5
{$ENDIF}

{$DEFINE IWPGUTTER}

uses
  Windows, WPRteDefs, SysUtils, Dialogs, Classes, ActnList, WPUtil, WPRTEPaint, WPCTRRich, WPCtrMemo, WPCTRLabel,
  wptexpert, wppanel, wptbar, wpruler, wpaction, WPCTRStyleCol, WPCtrPrint, WPDefActions,
  WPWordConv,
{$IFDEF IWPGUTTER}wpgutter, {$ENDIF}
// -----------------------------------------------------------------------------
{$IFDEF WPPDFEX}{$IFDEF WPDF_SOURCE} WPPDFR1_src {$ELSE} WPPDFR1 {$ENDIF},
                WPPDFPRP, WPPDFR2, WPPDFWP,
                {$IFDEF WPDF_QR}wppdfQR, {$ENDIF}
{$ENDIF} // wPDF Support - PDF export from WPTools
// -----------------------------------------------------------------------------
 {$IFDEF WPQUICK} WPQuickR,
   {$IFNDEF NODB} WPDQuick, {$ENDIF}
 {$ENDIF}
// -----------------------------------------------------------------------------
  // Dialogs:
  WPPrvFrm, Wpspdlg1, WPParPrp, WPStrDlg, WPParBrd, Wppagprp, WPTabDlg, WPTblDlg,
  WPBltDlg, WPSymDlg, wpstyles, wp1style, wpDefEditor, Forms,
  wpManHeadFoot
{$IFNDEF NODsgnIntf}
{$IFDEF DELPHI6ANDUP}, DesignIntf, DesignEditors{$ELSE}, DsgnIntf{$ENDIF},WPPrButt
{$ENDIF}
{$IFNDEF NODB}
,WPDBRich
{$ENDIF}
// -----------------------------------------------------------------------------
{$IFDEF WP6}
,WPSymDlgEx
{$ENDIF}
// -----------------------------------------------------------------------------
{$IFDEF WPREPORTER}
,WPRTEReport, WPRepED, WPEval, WPTblCalc {$IFNDEF NODB}, WPDBEval {$ENDIF}
{$ENDIF}
// -----------------------------------------------------------------------------
{$IFDEF WPSPELL}
,WPSpell_Controller
{$ENDIF}
// -----------------------------------------------------------------------------
{$IFDEF WPDEMO} 
  , wpshared
{$ELSE}
{$IFDEF INCLUDE_WPSHARED}
  ,wpshared
{$ENDIF}
{$ENDIF}
// -----------------------------------------------------------------------------
{$IFDEF INCLUDE_WPFORM} // Compile in WPFORM
  ,wpf_reg, wpf_engl, wpfrtf5
{$ENDIF}
  ;


{$IFNDEF NODsgnIntf}
type
  TWPRTFTextEdit = class(TComponentEditor)
  public
    procedure Edit; override;
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  TRtfTextProperty = class(TPropertyEditor)
  private
    RtfTextDlg: TWPToolsEditor;
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
    procedure SetValue(const Value: string); override;
    function GetValue: string; override;
  end;

  TWPStylesProperty = class(TPropertyEditor)
  private
     // FormDlg : TWPFormDesigner;
  public
    destructor Destroy; override;
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
    procedure SetValue(const Value: string); override;
    function GetValue: string; override;
  end;

  TWPStyleCollectEdit = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  {$IFDEF WP6}
  TWPCustomAttrDlgEdit = class(TComponentEditor)
  public
    function GetVerbCount: Integer;
    function GetVerb(Index: Integer): string;
    function GetAttributes: TPropertyAttributes;
    procedure Edit; override;
  end;
  {$ENDIF}
{$ENDIF}


procedure Register;

implementation

{$IFNDEF NODsgnIntf}uses WPSplash; {$ENDIF}

{$IFDEF WP6}
{$R WPToRes6.RES}
{$ELSE}
{$R WPToRes.RES}
{$ENDIF}
{$IFDEF WPREPORTER}{$R WPReport.RES}{$ENDIF}
{$IFDEF WPPDFEX}
{$R WPPDFREG.RES}
{$ENDIF}


procedure Register;
begin

{$IFDEF WPPDFEX}
  RegisterComponents('wPDF', [TWPPDFExport]);
  RegisterComponents('wPDF', [TWPPDFPrinter, TWPPDFProperties]);
{$IFDEF PDFIMPORT}
  RegisterComponents('wPDF', [TWPDFPagesImport]);
{$ENDIF}
{$IFDEF WPDF_QR}
  RegisterComponents('wPDF', [TQRwPDFFilter]);
{$ENDIF}
{$ENDIF}

  RegisterComponents('WPTools', [TWPDefaultActions, TWPPaintEngine, TWPRTFStorage, TWPRichText,
    TWPRichTextLabel, TWPPreview, TWPSuperPrint]);

{$IFNDEF NODB}
  RegisterComponents('WPTools', [TDBWPRichText, TWPMMDataProvider]);
{$ENDIF}

 {$IFDEF WPQUICK}
   RegisterComponents('WPTools', [TWPQuickPrint]);
   {$IFNDEF NODB}
   RegisterComponents('WPTools', [TWPDBQuickPrint]);
   {$ENDIF}
 {$ENDIF}

  RegisterComponents('WPTools',
    [{$IFDEF USEWPRESCOMP}TWPResLabel, TWPResCheckBox, {$ENDIF}
    TWPValueEdit, TWPShadedPanel, TWPContainer, TWPWallPaper]);
  RegisterComponents('WPTools', [TWPToolBar, TWPToolPanel, TWPComboBox, TWPToolButton,
    TWPRuler, TWPVertRuler, TWPStyleCollection]);

  RegisterComponents('WPTools', [TWPPreviewDlg, TWPPagePropDlg, TWPManageHeaderFooterDlg, TWPParagraphPropDlg,
    TWPParagraphBorderDlg, TWPStyleDlg, TWPOneStyleDlg, TWPTabDlg, TWPSymbolDlg,
      TWPTableDlg, TWPBulletDlg, TWPSpellCheckDlg, TWPStringDlg]);

{$IFDEF WP6}
RegisterComponents('WPTools', [TWPSymbolDlgEx]);
{$ENDIF}

RegisterComponents('WPTools', [TWPTableDlg, TWPBulletDlg, TWPSpellCheckDlg, TWPStringDlg]);

{$IFDEF IWPGUTTER}RegisterComponents('WPTools', [TWPGutter]); {$ENDIF}

{$IFDEF WPREPORTER}
  RegisterComponents('WPReporter',
    [TWPSuperMerge, TWPReportBandsDialog,
    TWPFormulaInterface, TWPEvalEngine{$IFNDEF NODB}, TDBWPEvalEngine{$ENDIF}]);
{$ENDIF}


  // -------------- Editors  ---------------------------------------------------
{$IFNDEF NODsgnIntf}
  RegisterPropertyEditor(TypeInfo(TWPRTFBlobContents), TWPCustomRtfEdit, 'RtfText', TRtfTextProperty);
  RegisterPropertyEditor(TypeInfo(TWPRTFBlobContents), TWPRichTextLabel, 'RtfText', TRtfTextProperty);
  RegisterPropertyEditor(TypeInfo(TWPRTFBlobContents), TWPRtfStorage, 'RtfText', TRtfTextProperty);
 {$IFDEF WPQUICK4}
   RegisterPropertyEditor(TypeInfo(TWPRTFBlobContents), TWPQuickPrint, 'RtfText', TRtfTextProperty);
 {$ENDIF}
  RegisterComponentEditor(TWPRichTextLabel, TWPRTFTextEdit);
  RegisterComponentEditor(TWPCustomRtfEdit, TWPRTFTextEdit);
  RegisterComponentEditor(TWPRtfStorage, TWPRTFTextEdit);
  RegisterComponentEditor(TWPStyleCollection, TWPStyleCollectEdit);
  {$IFDEF WP6}
  RegisterComponentEditor(TWPSymbolDlgEx, TWPCustomAttrDlgEdit);
  RegisterComponentEditor(TWPSymbolDlg, TWPCustomAttrDlgEdit);
  RegisterComponentEditor(TWPTableDlg, TWPCustomAttrDlgEdit);
  RegisterComponentEditor(TWPBulletDlg, TWPCustomAttrDlgEdit);
  {$ENDIF}
  RegisterPropertyEditor(TypeInfo(TWPSpeedButtonStyle), TWPToolButton, 'StyleName', TWPSpeedButtonProperty);
{$ENDIF}
  // -------------- Action Classes ---------------------------------------------
  RegisterActions('WPT_COMBOS', [TWPToolsCustomEditContolAction], nil);


  RegisterActions('WPT_Print', [TWPAZoomOut, TWPAZoomIn, TWPAFitHeight, TWPAFitWidth, TWPAPrint,
    TWPAPrinterSetup, TWPAPriorPage, TWPANextPage], nil);
  RegisterActions('WPT_Edit', [TWPAUndo, TWPARedo, TWPACopy, TWPACut, TWPAPaste, TWPASearch, TWPAReplace, TWPASellAll,
    TWPAHideSelection, {TWPAFindNext,} TWPASpellcheck, TWPASpellAsYouGo, TWPAStartThesaurus, TWPADeleteText], nil);
  RegisterActions('WPT_Table', [TWPABBottom, TWPABRight, TWPABLeft, TWPABTop, TWPABAllOff, TWPABAllOn, TWPADelRow,
    TWPABInner, TWPABOuter, TWPACreateTable, TWPACombineCell, TWPASplitCells,
      TWPAInsRow, TWPASelectColumn, TWPASelectRow, TWPAInsCol, TWPADelCol], nil);
  RegisterActions('WPT_ParAttr', [TWPALeft, TWPACenter, TWPARight, TWPAJustified, TWPABullets, TWPANumbers,
    TWPADecIndent, TWPAIncIndent], nil);
  RegisterActions('WPT_Outlines', [TWPAIsOutlineMode, TWPAInOutlineUp, TWPAInOutlineDown], nil);
  RegisterActions('WPT_CharAttr', [TWPANorm, TWPABold, TWPAItalic, TWPAProtected, TWPAHidden, TWPARTFCode,
    TWPAUnderline, TWPAStrikeout, TWPASubscript, TWPASuperscript], nil);
  RegisterActions('WPT_File', [TWPAOpen, TWPASave, TWPAExit, TWPAClose, TWPANew], nil);
  RegisterActions('WPT_Data', [TWPACancel, TWPADelete, TWPAAdd, TWPAEdit, TWPANext,
    TWPABack, TWPAOK, TWPAToEnd, TWPAToStart], nil);
  RegisterActions('WPT_WithParam', [TWPAInsertNumber, TWPAInsertField, TWPAEditHyperlink], nil);

end;

{$IFNDEF NODsgnIntf}

procedure WPToolsInfo;
begin
  with TWPSplashForm.Create(Application) do
  begin
    InfoLabel.Caption := 'Version ' + WPToolsVersion;
{$IFDEF WPDEMO}
    TopInfo.Caption := 'EVALUATION VERSION';
{$ENDIF}
    ShowModal;
    // Free on Close !
  end;
end;

function TRtfTextProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

procedure TRtfTextProperty.SetValue(const Value: string);
var
  ed: TPersistent;
begin
  if CompareText(Value, 'empty!') = 0 then
  begin
    ed := GetComponent(0);
    if ed <> nil then
    begin
      if ed is TWPCustomRtfEdit then
      begin(ed as TWPCustomRtfEdit).RtfText.Clear;
        Modified;
        (ed as TWPCustomRtfEdit).Invalidate;
      end
      else if ed is TWPCustomRtfLabel then
      begin(ed as TWPCustomRtfLabel).RtfText.Clear;
        Modified;
        (ed as TWPCustomRtfLabel).Invalidate;
      end
      else if ed is TWPRtfStorage then
      begin(ed as TWPRtfStorage).RtfText.Clear;
        Modified;
      end
{$IFDEF WPQUICK}
      else if ed is TWPQuickPrint then
      begin(ed as TWPQuickPrint).RtfText.Clear;
        Modified;
      end
{$ENDIF}
        ;
    end;
  end;
end;

function TRtfTextProperty.GetValue: string;
var
  ed: TPersistent;
begin
  Result := 'empty. [V' + WPToolsVersion + ']';
{$IFDEF WPDEMO}
  Result := Result + ' DEMO';
{$ELSE}
{$IFDEF WPREPORTER}
{$IFDEF WPREPORTDEMO}
  Result := Result + ' WPREPORTER DEMO';
{$ELSE}
  Result := Result + ' BUNDLE';
{$ENDIF}
{$ENDIF WPREPORTER}
{$ENDIF WPDEMO}
  ed := GetComponent(0);
  if ed <> nil then
  begin
    if ed is TWPCustomRtfEdit then
      Result := (ed as TWPCustomRtfEdit).RTFText.GetDescription
    else if ed is TWPCustomRtfLabel then
      Result := (ed as TWPCustomRtfLabel).RTFText.GetDescription
    else if ed is TWPRtfStorage then
      Result := (ed as TWPRtfStorage).RTFText.GetDescription
{$IFDEF WPQUICK}
    else if ed is TWPQuickPrint then
      Result := (ed as TWPQuickPrint).RTFText.GetDescription
{$ENDIF}
      ;
  end;
end;

procedure TRtfTextProperty.Edit;
var
  ed: TPersistent;
begin
  try
    RtfTextDlg := TWPToolsEditor.Create(nil);
    RtfTextDlg.WPDefAct.OnInfo := WPToolsInfo;
    RtfTextDlg.WPDefAct.InsertFormField1.Visible := TRUE;
    RtfTextDlg.ToolPanel.Visible := TRUE;
    ed := GetComponent(0);
    if ed <> nil then
    begin
      if ed is TWPCustomRtfEdit then
      begin
        RtfTextDlg.WPRichText1.Header.Assign((ed as TWPCustomRtfEdit).Header);
        RtfTextDlg.GetFromRTFText((ed as TWPCustomRtfEdit).RtfText);
      end
      else if ed is TWPCustomRtfLabel then
      begin
        RtfTextDlg.WPRichText1.Header.Assign((ed as TWPCustomRtfLabel).RTFData.Header);
        RtfTextDlg.GetFromRTFText((ed as TWPCustomRtfLabel).RtfText);
      end
      else if ed is TWPRtfStorage then
        RtfTextDlg.GetFromRTFText((ed as TWPRtfStorage).RtfText)
{$IFDEF WPQUICK}
      else if ed is TWPQuickPrint then
      begin
        RtfTextDlg.GetFromRTFText((ed as TWPQuickPrint).RtfText);
        RtfTextDlg.WPRichText1.Header.SetPageWH(
         MulDiv( (ed as TWPQuickPrint).Width, 1440, WPScreenPixelsPerInch),
         $FFFF
           );
      end;
{$ENDIF}
        ;
    end;
     // RtfTextDlg.RtfTextEdit.LayoutMode := wplayNormal;
    if RtfTextDlg.ShowModal = IDOK then
    begin
      ed := GetComponent(0);
      if ed <> nil then
      begin
        if ed is TWPCustomRtfEdit then
        begin
          RtfTextDlg.SetToRTFText((ed as TWPCustomRtfEdit).RtfText);
          (ed as TWPCustomRtfEdit).Header.SetDefaultWH(RtfTextDlg.WPRichText1.Header); //V5.12.5
          (ed as TWPCustomRtfEdit).ReformatAll;
        end
        else if ed is TWPCustomRtfLabel then
        begin
          RtfTextDlg.SetToRTFText((ed as TWPCustomRtfLabel).RtfText);
          (ed as TWPCustomRtfLabel).RTFData.Header.SetDefaultWH(RtfTextDlg.WPRichText1.Header); //V5.12.5
          (ed as TWPCustomRtfLabel).ReformatAll;
        end
        else if ed is TWPRtfStorage then
        begin
          RtfTextDlg.SetToRTFText((ed as TWPRtfStorage).RtfText);
        end
{$IFDEF WPQUICK}
        else if ed is TWPQuickPrint then
          RtfTextDlg.SetToRTFText((ed as TWPQuickPrint).RtfText)
{$ENDIF}
          ;
        Modified;
      end;
    end;
  finally
    RtfTextDlg.Free;
  end;
end;

// -------------------------------------------------------------------- TEXT ---

procedure TWPRTFTextEdit.Edit;
begin
  ExecuteVerb(1);
end;

procedure TWPRTFTextEdit.ExecuteVerb(Index: Integer);
var
  ed: TPersistent;
  RtfTextDlg: TWPToolsEditor;
  function GetRTFText: TWPRTFBlobContents;
  begin
    if ed is TWPCustomRtfEdit then
      Result := (ed as TWPCustomRtfEdit).RtfText
    else if ed is TWPCustomRtfLabel then
      Result := (ed as TWPCustomRtfLabel).RtfText
    else if ed is TWPRtfStorage then
      Result := (ed as TWPRtfStorage).RtfText
{$IFDEF WPQUICK}
    else if ed is TWPQuickPrint then
      Result := (ed as TWPQuickPrint).RtfText
{$ENDIF}
    else raise Exception.Create('Wrong Control for Command');
  end;
var wp: TWPCustomRtfEdit;
  dia: TWPPagePropDlg;
begin
  RtfTextDlg := nil;
  ed := Component;
  if Index = 1 then
  try
    RtfTextDlg := TWPToolsEditor.Create(nil);
    RtfTextDlg.WPDefAct.OnInfo := WPToolsInfo;
    RtfTextDlg.WPDefAct.InsertFormField1.Visible := TRUE;
    RtfTextDlg.ToolPanel.Visible := TRUE;
    if ed <> nil then
    begin
      RtfTextDlg.GetFromRTFText(GetRTFText);
      if ed is TWPCustomRtfEdit then
        RtfTextDlg.WPRichText1.Header.Assign(
          TWPCustomRtfEdit(ed).Header
          );
    end;

    if RtfTextDlg.ShowModal = IDOK then
    begin
      ed := Component;
      if ed <> nil then
      begin
        RtfTextDlg.SetToRTFText(GetRTFText);
        if ed is TWPCustomRtfEdit then
          TWPCustomRtfEdit(ed).Header.SetDefaultWH(RtfTextDlg.WPRichText1.Header);
      end;
    end;
    Designer.Modified;
  finally
    RtfTextDlg.Free;
  end
  else if Index = 2 then
  begin
    with TOpenDialog.Create(nil) do
    try
      Filter := WPLoadStr(meFilter);
      if execute then
        GetRTFText.LoadFromFile(FileName);
      if ed is TWPCustomRtfEdit then
      begin
        (ed as TWPCustomRtfEdit).RtfText.Apply;
        (ed as TWPCustomRtfEdit).ReformatAll;
      end
      else if ed is TWPCustomRtfLabel then
      begin
        (ed as TWPCustomRtfLabel).RtfText.Apply;
        (ed as TWPCustomRtfLabel).ReformatAll;
      end;
    finally
      Free;
    end;
    Designer.Modified;
  end
  else if Index = 3 then
  begin
    with TSaveDialog.Create(nil) do
    try
      Filter := WPLoadStr(meFilter);
      if execute then
        GetRTFText.SaveToFile(FileName);
    finally
      Free;
    end;
    Designer.Modified;
  end
  else if Index = 4 then
  begin
    if MessageDlg('Clear the text?', mtConfirmation, [mbYes, mbNo], 0) = idYes then
    begin
      GetRTFText.Clear;
      if ed is TWPCustomRtfEdit then
      begin
        (ed as TWPCustomRtfEdit).Clear;
        (ed as TWPCustomRtfEdit).Invalidate;
      end
      else if ed is TWPCustomRtfLabel then
      begin
        (ed as TWPCustomRtfLabel).Clear;
        (ed as TWPCustomRtfLabel).Invalidate;
      end;
    end;
  end
  else if Index = 5 then // Change Page Size (Current and Default)
  begin
    wp := TWPCustomRtfEdit.CreateDynamic;
    if ed is TWPCustomRtfEdit then
      TWPCustomRtfEdit(ed).Header._Layout :=
        TWPCustomRtfEdit(ed).Header._Layout
    else if ed is TWPCustomRtfLabel then
      TWPCustomRtfLabel(ed).Header._Layout :=
        TWPCustomRtfLabel(ed).Header._Layout;

    dia := TWPPagePropDlg.Create(nil);
    dia.Options := [];
    dia.EditBox := wp;
    try
      if dia.Execute then
      begin
        if ed is TWPCustomRtfEdit then
        begin
          TWPCustomRtfEdit(ed).Header._Layout := wp.Header._Layout;
          TWPCustomRtfEdit(ed).Header.RecalcLayout;
             { TWPCustomRtfEdit(ed).Header.Landscape := FALSE;
              TWPCustomRtfEdit(ed).Header.SetPageWH(
                  wp.Header.PageWidth, wp.Header.PageHeight,
                  wp.Header.LeftMargin, wp.Header.TopMargin,
                  wp.Header.RightMargin, wp.Header.BottomMargin);
              TWPCustomRtfEdit(ed).Header.MarginHeader := wp.Header.MarginHeader;
              TWPCustomRtfEdit(ed).Header.MarginFooter := wp.Header.MarginFooter;
              TWPCustomRtfEdit(ed).Header.Landscape := wp.Header.Landscape;
             }
          TWPCustomRtfEdit(ed).Header.SetDefaultWH(wp.Header);

          TWPCustomRtfEdit(ed).ReformatAll(false, false);
        end
        else if ed is TWPCustomRtfLabel then
        begin
          TWPCustomRtfLabel(ed).Header._Layout := wp.Header._Layout;
          TWPCustomRtfLabel(ed).Header.RecalcLayout;
             { TWPCustomRtfLabel(ed).Header.Landscape := FALSE;
              TWPCustomRtfLabel(ed).Header.SetPageWH(
                  wp.Header.PageWidth, wp.Header.PageHeight,
                  wp.Header.LeftMargin, wp.Header.TopMargin,
                  wp.Header.RightMargin, wp.Header.BottomMargin);
              TWPCustomRtfLabel(ed).Header.MarginHeader := wp.Header.MarginHeader;
              TWPCustomRtfLabel(ed).Header.MarginFooter := wp.Header.MarginFooter;
              TWPCustomRtfLabel(ed).Header.Landscape := FALSE;
                  wp.Header.Landscape;  }

          TWPCustomRtfLabel(ed).Header.DefaultLandscape := wp.Header.Landscape;
          TWPCustomRtfLabel(ed).Header.DefaultPageWidth := wp.Header.PageWidth;
          TWPCustomRtfLabel(ed).Header.DefaultPageHeight := wp.Header.PageHeight;
          TWPCustomRtfLabel(ed).Header.DefaultLeftMargin := wp.Header.LeftMargin;
          TWPCustomRtfLabel(ed).Header.DefaultTopMargin := wp.Header.TopMargin;
          TWPCustomRtfLabel(ed).Header.DefaultRightMargin := wp.Header.RightMargin;
          TWPCustomRtfLabel(ed).Header.DefaultBottomMargin := wp.Header.BottomMargin;
          TWPCustomRtfLabel(ed).Header.DefaultMarginHeader := wp.Header.MarginHeader;
          TWPCustomRtfLabel(ed).Header.DefaultMarginFooter := wp.Header.MarginFooter;
          TWPCustomRtfLabel(ed).ReformatAll(false, false);
          TWPCustomRtfLabel(ed).Invalidate;
        end;
      end;
    finally
      dia.Free;
      wp.Free;
    end;
  end else
  if (Index=6) then
  begin
     if not (ed is TWPCustomRtfEdit) then
        ShowMessage('QuickConfig is only supported for editors!') else
     with TWPQuickConfig.Create(nil) do
     try
        EditBox := ed as TWPCustomRtfEdit;
        ShowModal;
     finally
        Free;
     end;
  end;
end;

function TWPRTFTextEdit.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'WPTools by WPCubed GmbH, V' + #32 + WPToolsVersion;
    1: Result := 'Edit the Text';
    2: Result := 'Load the Text';
    3: Result := 'Save the Text';
    4: Result := 'Clear the Text';
    5: Result := 'Change Page Size (Current and Default)';
    6: Result := 'QuickConfig (FormatOptions, EditOptions, LayoutMode)'
  else Result := '';
  end;
end;

function TWPRTFTextEdit.GetVerbCount: Integer;
begin
  Result := 6;
  if Component is TWPCustomRichText then inc(Result);
end;

// ------------------------------------------------------- STYLE COLLECTION ----

function TWPStyleCollectEdit.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TWPStyleCollectEdit.ExecuteVerb(Index: Integer);
var
  ed: TPersistent;
  StyleDlg: TWPStyleDlg;
begin
  if Index = 0 then
  begin
    StyleDlg := TWPStyleDlg.Create(nil);
    try
      ed := Component;
      if (ed <> nil) and (ed is TWPStyleCollection) then
      begin
        StyleDlg.StyleCollection := (ed as TWPStyleCollection);
        StyleDlg.Execute;
        Designer.Modified;
      end;
    finally
      StyleDlg.Free;
    end;
  end;
end;

function TWPStyleCollectEdit.GetVerb(Index: Integer): string;
begin
  if Index = 0 then Result := 'Edit Styles';
end;

function TWPStylesProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

procedure TWPStylesProperty.SetValue(const Value: string);
begin

end;

function TWPStylesProperty.GetValue: string;
begin
  Result := 'Paragraph Styles';
end;

destructor TWPStylesProperty.Destroy;
begin
  inherited Destroy;
end;

procedure TWPStylesProperty.Edit;
var
  ed: TPersistent;
  StyleDlg: TWPStyleDlg;
begin
  StyleDlg := TWPStyleDlg.Create(nil);
  try
    ed := GetComponent(0);
    if (ed <> nil) and (ed is TWPStyleCollection) then
    begin
      StyleDlg.StyleCollection := (ed as TWPStyleCollection);
      StyleDlg.Execute;
      Modified;
    end;
  finally
    StyleDlg.Free;
  end;
end;

  {$IFDEF WP6}
  function TWPCustomAttrDlgEdit.GetVerbCount: Integer;
begin
  Result := 1;
end;

  function TWPCustomAttrDlgEdit.GetVerb(Index: Integer): string;
begin
  if Index = 0 then Result := 'Preview Dialog';
end;

function TWPCustomAttrDlgEdit.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

  procedure TWPCustomAttrDlgEdit.Edit;
  var
  ed: TPersistent;
  begin
  try
    ed := GetComponent;
    if (ed <> nil) and (ed is TWPCustomAttrDlg) then
    begin
      TWPCustomAttrDlg(ed).Execute;
    end;
  except
  end;
end;
  {$ENDIF}


{$ENDIF NODsgnIntf}


end.

