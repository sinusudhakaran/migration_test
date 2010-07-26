unit WPTExpert;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, WPRTEPaint, WPRTEDefs, WPCTRMemo, StdCtrls;

type
  TWPQuickConfig = class(TForm)
    PageControl1: TPageControl;
    Panel1: TPanel;
    Button3: TButton;
    TabSheet1: TTabSheet;
    Memo1: TMemo;
    PreviewButton: TButton;
    ApplyButton: TButton;
    ClassSelect: TRadioGroup;
    Scroll: TCheckBox;
    HideMailMerge: TCheckBox;
    SupUndo: TCheckBox;
    ImageDragDrop: TCheckBox;
    MovableImages: TCheckBox;
    Bevel1: TBevel;
    Extras: TCheckBox;
    Label1: TLabel;
    DontAddExternalFontLeading: TCheckBox;
    procedure Button3Click(Sender: TObject);
    procedure PreviewButtonClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    EditBox: TWPCustomRTFEdit;
  end;

var
  WPQuickConfig: TWPQuickConfig;

implementation

{$R *.dfm}

procedure TWPQuickConfig.Button3Click(Sender: TObject);
begin
  Close;
end;

procedure TWPQuickConfig.PreviewButtonClick(Sender: TObject);
var apply: Boolean;
  s: string;
begin
  apply := Sender = ApplyButton;
  case ClassSelect.ItemIndex of
    0: // Standard Editor (plain text)
      begin
        s := '// Standard Editor (plain text)' + #13 + #10;
        if apply then
        begin
          EditBox.FormatOptions := EditBox.FormatOptions + [wpfIgnoreKeep, wpfIgnoreKeepN, wpDisableAutosizeTables];
          EditBox.FormatOptionsEx := [];
          EditBox.LayoutMode := wplayNormal;
          EditBox.AutoZoom := wpAutoZoomOff;
          EditBox.Zooming := 100;
          EditBox.ProtectedProp := [];
          EditBox.ViewOptions := [wpHideSelectionNonFocussed, wpShowCR, wpShowFF, wpNoEndOfDocumentLine];
        end;
        s := s +
          'EditBox.FormatOptions := EditBox.FormatOptions + [wpfIgnoreKeep, wpfIgnoreKeepN, wpDisableAutosizeTables];' + #13 + #10 +
          'EditBox.FormatOptionsEx := [];' + #13 + #10 +
          'EditBox.LayoutMode := wplayNormal;' + #13 + #10 +
          'EditBox.AutoZoom := wpAutoZoomOff;' + #13 + #10 +
          'EditBox.Zooming := 100;' + #13 + #10 +
          'EditBox.ProtectedProp := [];' + #13 + #10 +
          'EditBox.ViewOptions := [wpHideSelectionNonFocussed,wpShowCR, wpShowFF, wpNoEndOfDocumentLine];' + #13 + #10;
      end;

    1: // Word-Processing Editor (Page Layout, WYSIWYG)
      begin
        s := '// Word-Processing Editor (Page Layout, WYSIWYG)'  + #13 + #10;
        if apply then
        begin
          EditBox.FormatOptions := EditBox.FormatOptions - [wpfIgnoreKeep, wpfIgnoreKeepN] + [wpDisableAutosizeTables];
          EditBox.FormatOptionsEx := [];
          EditBox.LayoutMode := wplayFullLayout;
          EditBox.AutoZoom := wpAutoZoomWidth;
          EditBox.Zooming := 100;
          EditBox.ProtectedProp := [];
          EditBox.ViewOptions := [wpHideSelectionNonFocussed, wpShowCR, wpShowFF];
        end;
        s := s +
          'EditBox.FormatOptions := EditBox.FormatOptions - [wpfIgnoreKeep, wpfIgnoreKeepN] + [wpDisableAutosizeTables];' + #13 + #10 +
          'EditBox.FormatOptionsEx := [];' + #13 + #10 +
          'EditBox.LayoutMode := wplayFullLayout;' + #13 + #10 +
          'EditBox.AutoZoom := wpAutoZoomWidth;' + #13 + #10 +
          'EditBox.Zooming := 100;' + #13 + #10 +
          'EditBox.ProtectedProp := [];' + #13 + #10 +
          'EditBox.ViewOptions := [wpHideSelectionNonFocussed,wpShowCR, wpShowFF];' + #13 + #10;
      end;

    2: // Forms (EditFields)
      begin
        s := '// Forms (EditFields)' + #13 + #10;
        if apply then
        begin
          EditBox.FormatOptions := EditBox.FormatOptions - [wpfIgnoreKeep, wpfIgnoreKeepN] + [wpDisableAutosizeTables];
          EditBox.FormatOptionsEx := [];
          EditBox.LayoutMode := wplayNormal;
          EditBox.AutoZoom := wpAutoZoomWidth;
          EditBox.Zooming := 100;
          EditBox.ProtectedProp := [ppIsInsertpoint, ppAllExceptForEditFields];
          EditBox.ViewOptions := [wpDisableMisspellMarkers, wpDontDrawSectionMarker];
        end;
        s := s +
          'EditBox.FormatOptions := EditBox.FormatOptions - [wpfIgnoreKeep, wpfIgnoreKeepN] + [wpDisableAutosizeTables];' + #13 + #10 +
          'EditBox.FormatOptionsEx := [];' + #13 + #10 +
          'EditBox.LayoutMode := wplayNormal;' + #13 + #10 +
          'EditBox.AutoZoom := wpAutoZoomWidth;' + #13 + #10 +
          'EditBox.Zooming := 100;' + #13 + #10 +
          'EditBox.ProtectedProp := [ppIsInsertpoint,ppAllExceptForEditFields];' + #13 + #10 +
          'EditBox.ViewOptions := [wpDisableMisspellMarkers, wpDontDrawSectionMarker];' + #13 + #10;
      end;

    3: // Full Page Preview (Readonly)
      begin
        s := '// Full Page Preview (Readonly)' + #13 + #10;
        if apply then
        begin
          EditBox.FormatOptions := EditBox.FormatOptions + [wpDisableAutosizeTables];
          EditBox.FormatOptionsEx := [];
          EditBox.LayoutMode := wplayFullLayout;
          EditBox.AutoZoom := wpAutoZoomWidth;
          EditBox.Zooming := 100;
          EditBox.Readonly := TRUE;
          EditBox.EditOptions := [];
          EditBox.ProtectedProp := [];
          EditBox.ViewOptions := [wpDontGrayHeaderFooterInLayout, wpHideSelection, wpDisableMisspellMarkers, wpDontDrawSectionMarker];
        end;
        s := s +
          'EditBox.FormatOptions := EditBox.FormatOptions + [wpDisableAutosizeTables];' + #13 + #10 +
          'EditBox.FormatOptionsEx := [];' + #13 + #10 +
          'EditBox.LayoutMode := wplayFullLayout;' + #13 + #10 +
          'EditBox.AutoZoom := wpAutoZoomWidth;' + #13 + #10 +
          'EditBox.Zooming := 100;' + #13 + #10 +
          'EditBox.Readonly := TRUE;' + #13 + #10 +
          'EditBox.EditOptions := [];' + #13 + #10 +
          'EditBox.ProtectedProp := [];' + #13 + #10 +
          'EditBox.ViewOptions := [wpDontGrayHeaderFooterInLayout,wpHideSelection,wpDisableMisspellMarkers,wpDontDrawSectionMarker];' + #13 + #10;

      end;

    4: // Multi Page Preview (Readonly)
      begin
        s := '// Multi Page Preview (Readonly)' + #13 + #10;
        if apply then
        begin
          EditBox.FormatOptions := EditBox.FormatOptions + [wpDisableAutosizeTables];
          EditBox.FormatOptionsEx := [];
          EditBox.LayoutMode := wplayFullLayout;
          EditBox.AutoZoom := wpAutoZoomAsManyAsPossibleInRow;
          EditBox.Zooming := 33;
          EditBox.Readonly := TRUE;
          EditBox.EditOptions := [];
          EditBox.ProtectedProp := [];
          EditBox.ViewOptions := [wpDontGrayHeaderFooterInLayout,wpHideSelection, wpDisableMisspellMarkers, wpDontDrawSectionMarker];
        end;
        s := s +
          'EditBox.FormatOptions := EditBox.FormatOptions + [wpDisableAutosizeTables];' + #13 + #10 +
          'EditBox.FormatOptionsEx := [];' + #13 + #10 +
          'EditBox.LayoutMode := wplayFullLayout;' + #13 + #10 +
          'EditBox.AutoZoom := wpAutoZoomAsManyAsPossibleInRow;' + #13 + #10 +
          'EditBox.Zooming := 33;' + #13 + #10 +
          'EditBox.Readonly := TRUE;' + #13 + #10 +
          'EditBox.EditOptions := [];' + #13 + #10 +
          'EditBox.ProtectedProp := [];' + #13 + #10 +
          'EditBox.ViewOptions := [wpHideSelection,wpDisableMisspellMarkers,wpDontDrawSectionMarker];' + #13 + #10;

      end;
  end;

  // Some defaults ...
  s := s + 'EditBox.WriteObjectMode := wobRTF; // reduce file size' + #13 + #10;
  if apply then
  begin
     EditBox.WriteObjectMode := wobRTF;
  end;

  if Extras.Checked then
  begin
   if s <> '' then s := s + '// -------------' + #13 + #10;
  // ---------------------------------------------------------------------------
    if Scroll.Checked then
    begin
      if apply then
      begin
        EditBox.ScrollBars := ssBoth;
        EditBox.EditOptions := EditBox.EditOptions - [wpNoHorzScrolling, wpNoHorzScrolling];
      end;
      s := s +
        'EditBox.ScrollBars := ssBoth;' + #13 + #10 +
        'EditBox.EditOptions := EditBox.EditOptions - [wpNoHorzScrolling,wpNoHorzScrolling];' + #13 + #10;
    end else
    begin
      if apply then
      begin
        EditBox.ScrollBars := ssNone;
        EditBox.EditOptions := EditBox.EditOptions + [wpNoHorzScrolling, wpNoHorzScrolling];
      end;
      s := s +
        'EditBox.ScrollBars := ssNone;' + #13 + #10 +
        'EditBox.EditOptions := EditBox.EditOptions + [wpNoHorzScrolling,wpNoHorzScrolling];' + #13 + #10;
    end;
  // ---------------------------------------------------------------------------
    if HideMailMerge.Checked then
    begin
      if apply then
      begin
        EditBox.InsertPointAttr.Hidden := TRUE;
      end;
      s := s +
        'EditBox.InsertPointAttr.Hidden := TRUE;' + #13 + #10;
    end
    else
    begin
      if apply then
      begin
        EditBox.InsertPointAttr.Hidden := FALSE;
        EditBox.InsertPointAttr.CodeOpeningText := #171; // <<
        EditBox.InsertPointAttr.CodeClosingText := #187; // >>
      end;
      s := s +
        'EditBox.InsertPointAttr.Hidden := FALSE;' + #13 + #10 +
        'EditBox.InsertPointAttr.CodeOpeningText := #171; // <<' + #13 + #10 +
        'EditBox.InsertPointAttr.CodeClosingText := #187; // >>  end;' + #13 + #10;
    end;
  // ---------------------------------------------------------------------------
    if SupUndo.Checked then
    begin
      if apply then
      begin
        EditBox.EditOptions := EditBox.EditOptions + [wpActivateUndo, wpActivateUndoHotkey, wpActivateRedo, wpActivateRedoHotkey];
      end;
      s := s +
        'EditBox.EditOptions := EditBox.EditOptions + [wpActivateUndo,wpActivateUndoHotkey,wpActivateRedo,wpActivateRedoHotkey];' + #13 + #10;
    end else
    begin
      if apply then
      begin
        EditBox.EditOptions := EditBox.EditOptions - [wpActivateUndo, wpActivateUndoHotkey, wpActivateRedo, wpActivateRedoHotkey];
      end;
      s := s +
        'EditBox.EditOptions := EditBox.EditOptions - [wpActivateUndo,wpActivateUndoHotkey,wpActivateRedo,wpActivateRedoHotkey];' + #13 + #10;
    end;
  // ---------------------------------------------------------------------------
    if ImageDragDrop.Checked then
    begin
      if apply then
      begin
        EditBox.AcceptFiles := true;
        if MovableImages.Checked then
          EditBox.AcceptFilesOptions := EditBox.AcceptFilesOptions + [wpDropCreatesMovablePageObject] - [wpDropCreatesMovableParObject]
        else EditBox.AcceptFilesOptions := EditBox.AcceptFilesOptions - [wpDropCreatesMovablePageObject, wpDropCreatesMovableParObject];
      end;
      s := s +
        'EditBox.AcceptFiles := true;' + #13 + #10;
      if MovableImages.Checked then
        s := s + 'EditBox.AcceptFilesOptions := EditBox.AcceptFilesOptions + [wpDropCreatesMovablePageObject] - [wpDropCreatesMovableParObject]' + #13 + #10
      else s := s + 'EditBox.AcceptFilesOptions := EditBox.AcceptFilesOptions - [wpDropCreatesMovablePageObject,wpDropCreatesMovableParObject];' + #13 + #10;
    end else
    begin
      if apply then
      begin
        EditBox.AcceptFiles := false
      end;
      s := s +
        'EditBox.AcceptFiles := false' + #13 + #10;
    end;
  // ---------------------------------------------------------------------------
    if DontAddExternalFontLeading.Checked then
    begin
      if apply then
      begin
        EditBox.FormatOptionsEx := EditBox.FormatOptionsEx + [wpDontAddExternalFontLeading];
      end;
      s := s +
        'EditBox.FormatOptionsEx := EditBox.FormatOptionsEx + [wpDontAddExternalFontLeading];' + #13 + #10;
    end else
    begin
      if apply then
      begin
        EditBox.FormatOptionsEx := EditBox.FormatOptionsEx - [wpDontAddExternalFontLeading];
      end;
      s := s +
        'EditBox.FormatOptionsEx := EditBox.FormatOptionsEx - [wpDontAddExternalFontLeading];' + #13 + #10;
    end;   

  end;

  if EditBox.Name<>'' then
     s := StringReplace(s,'EditBox.', EditBox.Name + '.' , [rfReplaceAll]);

  Memo1.Text := s;
end;


end.

