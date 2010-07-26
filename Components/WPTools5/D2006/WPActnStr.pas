unit WPActnStr;
{ -----------------------------------------------------------------------------
  WPAction  - Copyright (C) 2002 by wpcubed GmbH    -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  WPTools5 Action Strings. They are used to label the actions and the toolbar
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

interface

{$I WPINC.INC}

uses Sysutils, Typinfo, Classes, WPRTEDefs, WPCtrMemo, WPCtrRich;

{$I WPMSG.INC} // WP_RTFEDIT_CHANGED & co

type
  { Actions in the order of the gylphs in the file wptbpic.bmp }
  TWPToolsActionStyle = (
    wpaZoomOut, wpaZoomIn, wpaBBottom, wpaBInner, wpaBLeft,
    wpaBAllOff, wpaBAllOn, wpaBOuter, wpaBRight, wpaBTop,
    wpaBullets, wpaCancel, wpaCenter, wpaClose, wpaCopy,
    wpaCreateTable, wpaCut, wpaDecIndent, wpaDelete, wpaCombineCell,
    wpaAdd, wpaDelRow, wpaEdit, wpaExit, wpaSearch,
    wpaFitHeight, wpaFitWidth, wpaSellAll, wpaHidden, wpaIncIndent,
    wpaSplitCells, wpaInsRow, wpaItalic, wpaBold, wpaJustified,
    wpaLeft, wpaProtected, wpaNew, wpaNext, wpaNorm,
    wpaNumbers, wpaOpen, wpaPaste, wpaOK, wpaUndo,
    wpaToEnd, wpaToStart, wpaBack, wpaPrint, wpaPriorPage,
    wpaPrinterSetup, wpaNextPage, wpaReplace, wpaRight, wpaRTFCode,
    wpaSave, wpaHideSelection, wpaSelectColumn, wpaSelectRow, wpaFindNext,
    wpaSpellcheck, wpaUnderline, wpaStrikeout, wpaSubscript, wpaSuperscript,
    wpaInsCol, wpaDelCol, wpaPrintDialog,
    // New in V4
    wpaDeleteText, wpaRedo,
    wpaInsertNumber, wapInsertField,
    wpaIsOutline, wpaOutlineUp, wpaOutlineDown,
    wpaEditHyperlink, wpaHyperlinkStyle, wpaSpellAsYouGo, wpaStartThesaurus,
    // This 6 Actions are actually Comboboxes! and have no buttons
    wpaFontSelection, wpaFontSizeSelection, wpaFontColorSelection,
    wpaFontBKColorSelection, wpaParColorSelection, wpaParStyleSelection,
    // NEw in V4.06
    // WPI_CO_PARPROTECT, WPI_CO_PARKEEP
    wpaParProtect, wpaParKeep
    );


  TWPToolsActionStrings = record c: string; h: string; end;

// This methods make it possible to read the hint and the caption for a certain command
function  WPGetActionHintCap(Group, Command: Integer; var Caption, Hint: string): Boolean;
procedure WPGetActionHintCaption(Style: TWPToolsActionStyle; var Caption, Hint: string);
procedure WPGetActionCommandGroup(Style: TWPToolsActionStyle; var Command, Group: Integer);

procedure WPTools_SaveActionStrings;
procedure WPTools_LoadActionStrings;


// This function pointer have to be set to update the toolbuttons
var
  WPRefreshActionStrings: procedure;

implementation

uses WPUtil;

// This constants are used to map Actions to toolbar Icon Groups/Commands
// We are using this Group/Command set for 2 reasons:
// 1. compatibility to old version
// 2. ordering of the commands into groups

const
  allwpcom_gr: array[TWPToolsActionStyle] of Integer =
  (
    WPI_GR_PRINT, WPI_GR_PRINT, WPI_GR_TABLE, WPI_GR_TABLE, WPI_GR_TABLE,
    WPI_GR_TABLE, WPI_GR_TABLE, WPI_GR_TABLE, WPI_GR_TABLE, WPI_GR_TABLE,
    //10
    WPI_GR_OUTLINE, WPI_GR_DATA, WPI_GR_ALIGN, WPI_GR_DISK, WPI_GR_EDIT,
    WPI_GR_TABLE, WPI_GR_EDIT, WPI_GR_OUTLINE, WPI_GR_DATA, WPI_GR_TABLE,
    //20
    WPI_GR_DATA, WPI_GR_TABLE, WPI_GR_DATA, WPI_GR_DISK, WPI_GR_EDIT,
    WPI_GR_PRINT, WPI_GR_PRINT, WPI_GR_EDIT, WPI_GR_STYLE, WPI_GR_OUTLINE,
    //30
    WPI_GR_TABLE, WPI_GR_TABLE, WPI_GR_STYLE, WPI_GR_STYLE, WPI_GR_ALIGN,
    WPI_GR_ALIGN, WPI_GR_STYLE, WPI_GR_DISK, WPI_GR_DATA, WPI_GR_STYLE,
    //40
    WPI_GR_OUTLINE, WPI_GR_DISK, WPI_GR_EDIT, WPI_GR_DATA, WPI_GR_EDIT,
    WPI_GR_DATA, WPI_GR_DATA, WPI_GR_DATA, WPI_GR_PRINT, WPI_GR_PRINT,
    //50
    WPI_GR_PRINT, WPI_GR_PRINT, WPI_GR_EDIT, WPI_GR_ALIGN, WPI_GR_STYLE,
    WPI_GR_DISK, WPI_GR_EDIT, WPI_GR_TABLE, WPI_GR_TABLE, WPI_GR_EDIT,
    //60
    WPI_GR_EDIT, WPI_GR_STYLE, WPI_GR_STYLE, WPI_GR_STYLE, WPI_GR_STYLE,
    WPI_GR_TABLE, WPI_GR_TABLE, WPI_GR_PRINT,

    // 68 - new in V4
    WPI_GR_EDIT, WPI_GR_EDIT,
    WPI_GR_EXTRA, WPI_GR_EXTRA,
    WPI_GR_OUTLINE, WPI_GR_OUTLINE, WPI_GR_OUTLINE, //  wpaIsOutline, wpaOutlineUp, wpaOutlineDown
    WPI_GR_EXTRA, WPI_GR_STYLE,
    WPI_GR_EDIT, WPI_GR_EDIT, // wpaSpellAsYouGo, wpaStartThesaurus,
    // This 6 Actions are actually Comboboxes!
    WPI_GR_DROPDOWN,WPI_GR_DROPDOWN,WPI_GR_DROPDOWN,WPI_GR_DROPDOWN,
       WPI_GR_DROPDOWN,WPI_GR_DROPDOWN,

    // V4.06 WPI_CO_PARPROTECT, WPI_CO_PARKEEP
    WPI_GR_PARAGRAPH, WPI_GR_PARAGRAPH
    );

  allwpcom_num: array[TWPToolsActionStyle] of Integer =
  (
    WPI_CO_ZoomOut, WPI_CO_ZoomIn, WPI_CO_BBottom, WPI_CO_BInner, WPI_CO_BLeft,
    WPI_CO_BAllOff, WPI_CO_BAllOn, WPI_CO_BOuter, WPI_CO_BRight, WPI_CO_BTop,
    //10
    WPI_CO_Bullets, WPI_CO_Cancel, WPI_CO_Center, WPI_CO_Close, WPI_CO_Copy,
    WPI_CO_CreateTable, WPI_CO_Cut, WPI_CO_PriorLevel, WPI_CO_Del, WPI_CO_CombineCell,
    //20
    WPI_CO_Add, WPI_CO_DelRow, WPI_CO_Edit, WPI_CO_Exit, WPI_CO_Find,
    WPI_CO_FitHeight, WPI_CO_FitWidth, WPI_CO_SelAll, WPI_CO_HIDDEN, WPI_CO_NextLevel,
    //30
    WPI_CO_SplitCell, WPI_CO_InsRow, WPI_CO_Italic, WPI_CO_Bold, WPI_CO_Justified,
    WPI_CO_Left, WPI_CO_PROTECTED, WPI_CO_New, WPI_CO_Next, WPI_CO_Normal,
    //40
    WPI_CO_Numbers, WPI_CO_Open, WPI_CO_Paste, WPI_CO_Post, WPI_CO_Undo,
    WPI_CO_ToEnd, WPI_CO_ToStart, WPI_CO_Prev, WPI_CO_Print, WPI_CO_PriorPage,
    //50
    WPI_CO_PrintSetup, WPI_CO_NextPage, WPI_CO_Replace, WPI_CO_Right, WPI_CO_RTFCODE,
    WPI_CO_Save, WPI_CO_HideSel, WPI_CO_SelCol, WPI_CO_SelRow, WPI_CO_FindNext,
    //60
    WPI_CO_SpellCheck, WPI_CO_Under, WPI_CO_StrikeOut, WPI_CO_SUB, WPI_CO_SUPER,
    WPI_CO_INSCOL, WPI_CO_DELCOL, WPI_CO_PrintDialog,

    // 68 - new in V4
    WPI_CO_DeleteText, WPI_CO_Redo,
    WPI_CO_InsertNumber, WPI_CO_InsertField,
    WPI_CO_IsOutline, WPI_CO_OutlineUp, WPI_CO_OutlineDown,
    WPI_CO_EditHyperlink, WPI_CO_HYPERLINK,
    WPI_CO_SpellAsYouGo, WPI_CO_Thesaurus, // wpaSpellAsYouGo, wpaStartThesaurus,
    // This 6 Actions are actually Comboboxes!
    Integer(wptName), Integer(wptSize), Integer(wptColor),
    Integer(wptBkColor), Integer(wptParColor), Integer(wpaParStyleSelection),

    // V4.06
    WPI_CO_PARPROTECT, WPI_CO_PARKEEP
    );

var // The default captions
  allwpcom_captions: array[TWPToolsActionStyle] of string =
  (
    'Zoom Out', 'Zoom In', 'Bottom Borders', 'Inner Borders', 'Left Borders',
    'Switch Borders Off', 'Switch Borders On', 'Outer Borders', 'Right Borders', 'Top Borders',
    //10
    'Bullets', 'Cancel', 'Center', 'Close', 'Copy',
    'Create Table', 'Cut', 'Prior Level', 'Del', 'Combine Cells',
    //20
    'Add', 'Delete Row', 'Edit', 'Exit', 'Find',
    'Fit to Pageheight', 'Fit to Pagewidth', 'Select All', 'Hidden', 'Next Level',
    //30
    'Split Cell', 'Insert Row', 'Italic', 'Bold', 'Justified',
    'Left', 'Protected', 'New', 'Next', 'Normal',
    //40
    'Numbers', 'Open', 'Paste', 'Post', 'Undo',
    'To End', 'To Start', 'Previous', 'Print', 'Prior Page',
    //50
    'Printer Setup', 'Next Page', 'Replace', 'Right', 'RTF-Code',
    'Save', 'Hide Selection', 'Select Column', 'Select Row', 'Find Next',
    //60
    'Spellcheck', 'Underlined', 'Strike Out', 'Subscript', 'Superscript',
    'Insert Column', 'Delete Column', 'Print Dialog',

    // 68 - new in V4
    'Delete Text', 'Redo',
    'Insert Number', 'Insert Field',
    'Include in Outline', 'Outline Level Up', 'Outline Level Down',
    'Edit Hyperlink', 'Hyperlink Style',
    'Spell-As-You-Go', 'Thesaurus',
    // This 6 Actions are actually Comboboxes!
    'Font Name', 'Font Size', 'Font Color',
    'Character Background', 'Paragraph Background', 'Paragraph Style',
    // V4.06
    'Protect Paragraph', 'Keep Paragraph together'
    );

  allwpcom_hints: array[TWPToolsActionStyle] of string;
  // -----------------------------------------------------------------------------
  // -----------------------------------------------------------------------------
  // -----------------------------------------------------------------------------

function WPGetActionHintCap(Group, Command: Integer; var Caption, Hint: string): Boolean;
var
  Style: TWPToolsActionStyle;
begin
  Result := FALSE;
  Caption := '';
  Hint := '';
  for Style := Low(TWPToolsActionStyle) to High(TWPToolsActionStyle) do
    if (allwpcom_gr[Style] = Group) and (allwpcom_num[Style] = Command) then
    begin
      Caption := allwpcom_captions[Style];
      Hint := allwpcom_hints[Style];
      Result := TRUE;
      exit;
    end;
end;

procedure WPGetActionHintCaption(Style: TWPToolsActionStyle; var Caption, Hint: string);
begin
  Caption := allwpcom_captions[Style];
  Hint := allwpcom_hints[Style];
end;

procedure WPGetActionCommandGroup(Style: TWPToolsActionStyle; var Command, Group: Integer);
begin
  Command := allwpcom_num[Style];
  Group := allwpcom_gr[Style];   
end;

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

procedure WPTools_SaveActionStrings;
var
  i: TWPToolsActionStyle;
  lst: TStringList;
  typ: Pointer;
begin
  typ := TypeInfo(TWPToolsActionStyle);
  if (typ <> nil) and Assigned(WPLangInterface) then
  begin
    lst := TStringList.Create;
    try
      for i := Low(TWPToolsActionStyle) to High(TWPToolsActionStyle) do
      begin
        lst.Clear;
        lst.Add('C=' + allwpcom_captions[i]);
        lst.Add('H=' + allwpcom_captions[i]); //NOT: allwpcom_hints
        WPLangInterface.SaveStrings('WPAction/' + GetEnumName(typ, Integer(i)), lst, 0);
      end;
    finally
      lst.Free;
    end;
  end;
end;

procedure WPTools_LoadActionStrings;
var
  i: TWPToolsActionStyle;
  lst: TStringList;
  a: Integer;
  typ: Pointer;
  st : string;
begin
  typ := TypeInfo(TWPToolsActionStyle);
  if (typ <> nil) and Assigned(WPLangInterface) then
  begin
    lst := TStringList.Create;
    try
      for i := Low(TWPToolsActionStyle) to High(TWPToolsActionStyle) do
      begin
        lst.Clear;
        st := GetEnumName(typ, Integer(i));
        if WPLangInterface.LoadStrings('WPAction/' + st, lst, a) then
        begin
          allwpcom_captions[i] := lst.Values['C'];
          allwpcom_hints[i] := lst.Values['H'];
        end;
      end;
    finally
      lst.Free;
    end;
    // ---- fresh the display up
    if assigned(WPRefreshActionStrings) then WPRefreshActionStrings;
  end;
end;

var a : TWPToolsActionStyle;

initialization
  // Make sure we have our default hints !
  a := Low(allwpcom_hints);
  while true do
  begin
     allwpcom_hints[a] := allwpcom_captions[a];
     if a=High(allwpcom_hints) then break;
     inc(a);
  end;

finalization

end.

