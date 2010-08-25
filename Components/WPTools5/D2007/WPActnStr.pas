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
{-$DEFINE LEGACT} // remove legacy commands

type
  { Actions in the order of the gylphs in the file wptbpic.bmp }
  TWPToolsActionStyle = (
    wpaZoomOut, wpaZoomIn, wpaBBottom, wpaBInner, wpaBLeft,
    wpaBAllOff, wpaBAllOn, wpaBOuter, wpaBRight, wpaBTop,
    wpaBullets, {$IFNDEF LEGACT}wpaCancel,{$ENDIF} wpaCenter, wpaClose, wpaCopy,
    wpaCreateTable, wpaCut, wpaDecIndent, {$IFNDEF LEGACT}wpaDelete,{$ENDIF}
    wpaCombineCell,
    {$IFNDEF LEGACT}wpaAdd,{$ENDIF} wpaDelRow, {$IFNDEF LEGACT}wpaEdit, wpaExit, {$ENDIF}wpaSearch,
    wpaFitHeight, wpaFitWidth,
    {$IFNDEF LEGACT}wpaSellAll,{$ELSE}wpaSelAll,{$ENDIF}
    wpaHidden, wpaIncIndent,
    wpaSplitCells, wpaInsRow, wpaItalic, wpaBold, wpaJustified,
    wpaLeft, wpaProtected, wpaNew, {$IFNDEF LEGACT}wpaNext,{$ENDIF} wpaNorm,
    wpaNumbers, wpaOpen, wpaPaste, {$IFNDEF LEGACT}wpaOK,{$ENDIF} wpaUndo,
    {$IFNDEF LEGACT}wpaToEnd, wpaToStart, wpaBack,{$ENDIF}
    wpaPrint, wpaPriorPage,
    wpaPrinterSetup, wpaNextPage, wpaReplace, wpaRight,
    {$IFNDEF LEGACT}wpaRTFCode,{$ENDIF}
    wpaSave, wpaHideSelection, wpaSelectColumn, wpaSelectRow, wpaFindNext,
    wpaSpellcheck, wpaUnderline, wpaStrikeout, wpaSubscript, wpaSuperscript, wpaUppercase, wpaSmallCaps,
    wpaInsCol, wpaDelCol, wpaPrintDialog,
    // New in V4
    wpaDeleteText, wpaRedo,
    wpaInsertNumber, wapInsertField,
    wpaIsOutline, wpaOutlineUp, wpaOutlineDown,
    wpaEditHyperlink, {$IFNDEF LEGACT}wpaHyperlinkStyle,{$ENDIF} wpaSpellAsYouGo, wpaStartThesaurus,
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
procedure WPSetActionHintCaption(Style: TWPToolsActionStyle; const Caption, Hint: string);
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
    WPI_GR_OUTLINE, {$IFNDEF LEGACT}WPI_GR_DATA,{$ENDIF} WPI_GR_ALIGN, WPI_GR_DISK, WPI_GR_EDIT,
    WPI_GR_TABLE, WPI_GR_EDIT, WPI_GR_OUTLINE, {$IFNDEF LEGACT}WPI_GR_DATA,{$ENDIF} WPI_GR_TABLE,
    //20
    {$IFNDEF LEGACT}WPI_GR_DATA,{$ENDIF} WPI_GR_TABLE, {$IFNDEF LEGACT}WPI_GR_DATA, WPI_GR_DISK,{$ENDIF}WPI_GR_EDIT, 
    WPI_GR_PRINT, WPI_GR_PRINT, WPI_GR_EDIT, WPI_GR_STYLE, WPI_GR_OUTLINE,
    //30
    WPI_GR_TABLE, WPI_GR_TABLE, WPI_GR_STYLE, WPI_GR_STYLE, WPI_GR_ALIGN,
    WPI_GR_ALIGN, WPI_GR_STYLE, WPI_GR_DISK, {$IFNDEF LEGACT}WPI_GR_DATA,{$ENDIF} WPI_GR_STYLE,
    //40
    WPI_GR_OUTLINE, WPI_GR_DISK, WPI_GR_EDIT, {$IFNDEF LEGACT}WPI_GR_DATA,{$ENDIF} WPI_GR_EDIT,
    {$IFNDEF LEGACT}WPI_GR_DATA, WPI_GR_DATA, WPI_GR_DATA,{$ENDIF} WPI_GR_PRINT, WPI_GR_PRINT,
    //50
    WPI_GR_PRINT, WPI_GR_PRINT, WPI_GR_EDIT, WPI_GR_ALIGN, {$IFNDEF LEGACT}WPI_GR_STYLE,{$ENDIF}
    WPI_GR_DISK, WPI_GR_EDIT, WPI_GR_TABLE, WPI_GR_TABLE, WPI_GR_EDIT,
    //60
    WPI_GR_EDIT, WPI_GR_STYLE, WPI_GR_STYLE, WPI_GR_STYLE, WPI_GR_STYLE, WPI_GR_STYLE, WPI_GR_STYLE,
    WPI_GR_TABLE, WPI_GR_TABLE, WPI_GR_PRINT,

    // 68 - new in V4
    WPI_GR_EDIT, WPI_GR_EDIT,
    WPI_GR_EXTRA, WPI_GR_EXTRA,
    WPI_GR_OUTLINE, WPI_GR_OUTLINE, WPI_GR_OUTLINE, //  wpaIsOutline, wpaOutlineUp, wpaOutlineDown
    WPI_GR_EXTRA, {$IFNDEF LEGACT}WPI_GR_STYLE,{$ENDIF}
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
    WPI_CO_Bullets, {$IFNDEF LEGACT}WPI_CO_Cancel,{$ENDIF} WPI_CO_Center, WPI_CO_Close, WPI_CO_Copy,
    WPI_CO_CreateTable, WPI_CO_Cut, WPI_CO_PriorLevel, {$IFNDEF LEGACT}WPI_CO_Del,{$ENDIF} WPI_CO_CombineCell,
    //20
    {$IFNDEF LEGACT}WPI_CO_Add,{$ENDIF} WPI_CO_DelRow, {$IFNDEF LEGACT}WPI_CO_Edit, WPI_CO_Exit, {$ENDIF}WPI_CO_Find,
    WPI_CO_FitHeight, WPI_CO_FitWidth, WPI_CO_SelAll, WPI_CO_HIDDEN, WPI_CO_NextLevel,
    //30
    WPI_CO_SplitCell, WPI_CO_InsRow, WPI_CO_Italic, WPI_CO_Bold, WPI_CO_Justified,
    WPI_CO_Left, WPI_CO_PROTECTED, WPI_CO_New, {$IFNDEF LEGACT}WPI_CO_Next,{$ENDIF} WPI_CO_Normal,
    //40
    WPI_CO_Numbers, WPI_CO_Open, WPI_CO_Paste, {$IFNDEF LEGACT}WPI_CO_Post,{$ENDIF} WPI_CO_Undo,
    {$IFNDEF LEGACT}WPI_CO_ToEnd, WPI_CO_ToStart, WPI_CO_Prev,{$ENDIF} WPI_CO_Print, WPI_CO_PriorPage,
    //50
    WPI_CO_PrintSetup, WPI_CO_NextPage, WPI_CO_Replace, WPI_CO_Right,
    {$IFNDEF LEGACT}WPI_CO_RTFCODE,{$ENDIF}
    WPI_CO_Save, WPI_CO_HideSel, WPI_CO_SelCol, WPI_CO_SelRow, WPI_CO_FindNext,
    //60
    WPI_CO_SpellCheck, WPI_CO_Under, WPI_CO_StrikeOut, WPI_CO_SUB, WPI_CO_SUPER, WPI_CO_UPPERCASE, WPI_CO_SMALLCAPS,
    WPI_CO_INSCOL, WPI_CO_DELCOL, WPI_CO_PrintDialog,

    // 68 - new in V4
    WPI_CO_DeleteText, WPI_CO_Redo,
    WPI_CO_InsertNumber, WPI_CO_InsertField,
    WPI_CO_IsOutline, WPI_CO_OutlineUp, WPI_CO_OutlineDown,
    WPI_CO_EditHyperlink, {$IFNDEF LEGACT}WPI_CO_HYPERLINK,{$ENDIF}
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
    'Bullets', {$IFNDEF LEGACT}'Cancel',{$ENDIF} 'Center', 'Close', 'Copy',
    'Create Table', 'Cut', 'Prior Level', {$IFNDEF LEGACT}'Del',{$ENDIF} 'Combine Cells',
    //20
    {$IFNDEF LEGACT}'Add',{$ENDIF} 'Delete Row', {$IFNDEF LEGACT}'Edit', 'Exit', {$ENDIF}'Find',
    'Fit to Pageheight', 'Fit to Pagewidth', 'Select All', 'Hidden', 'Next Level',
    //30
    'Split Cell', 'Insert Row', 'Italic', 'Bold', 'Justified',
    'Left', 'Protected', 'New', {$IFNDEF LEGACT}'Next',{$ENDIF} 'Normal',
    //40
    'Numbers', 'Open', 'Paste', {$IFNDEF LEGACT}'Post',{$ENDIF} 'Undo',
    {$IFNDEF LEGACT}'To End', 'To Start', 'Previous',{$ENDIF} 'Print', 'Prior Page',
    //50
    'Printer Setup', 'Next Page', 'Replace', 'Right', {$IFNDEF LEGACT}'RTF-Code',{$ENDIF}
    'Save', 'Hide Selection', 'Select Column', 'Select Row', 'Find Next',
    //60
    'Spellcheck', 'Underlined', 'Strike Out', 'Subscript', 'Superscript', 'Uppercase', 'Smallcaps', 
    'Insert Column', 'Delete Column', 'Print Dialog',

    // 68 - new in V4
    'Delete Text', 'Redo',
    'Insert Number', 'Insert Field',
    'Include in Outline', 'Outline Level Up', 'Outline Level Down',
    'Edit Hyperlink', {$IFNDEF LEGACT}'Hyperlink Style', {$ENDIF}
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

procedure WPSetActionHintCaption(Style: TWPToolsActionStyle; const Caption, Hint: string);
begin
  allwpcom_captions[Style] := Caption;
  allwpcom_hints[Style] := Hint;
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

