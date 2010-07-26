unit WPSpell_link;
{ ------------------------------------------------------------------------------
  WPSpell Support for WPTools V4.x and WPTools 5.x
  ------------------------------------------------------------------------------
  Add this unit to your application which utilizes the word processor WPTools Version 4.
  You will also need to add a TWPSpellController to the form.

  The spellcheck actions installed by WPTools will then work automatically.
  No further installation code is required.

  The new WPTools version supports WYSIWYG page layout view, RTF reporting,
  optional export to PDF,  header and footer, manual hyphenation, tabstops,
  paragraph alignment etc etc.

  You can download and evaluate WPTools at: http://www.wptools.de/
  ------------------------------------------------------------------------------ }

// Latest Update: 18.3.2006

interface

{$I WPSpell_INC.INC}
{$IFNDEF T2H}{$I WPINC.INC}{$ENDIF}

{-$DEFINE WPHasGetParXYBaselineScreen}// WPTools 5.15.5 or later

uses Classes, Sysutils, Windows, Forms, Controls, StdCtrls, Dialogs, Menus, Math
{$IFDEF WPSPELL_DEMO}
  , WPSpell_DemoDLL
{$ELSE}
  , WPSpell_Controller
{$ENDIF}
  , WPSpell_StdForm, WPSpell_Language
{$IFDEF WPTOOLS5}
  , WPCtrMemo, WPRTEPaint, WPRTEDefs, WPUtil
{$ELSE}
  , WPRich, WPWinCtr, WPRtfTxt, WPDefs
{$ENDIF};


type
  TWPToolsSpellInterface = class(TWPSpellInterface)
  private
    FSelStart, FSelEnd: Integer;
    FLastSpellControl: TControl;
    FChanged, FIsOK: Boolean;
    FCheckedWord: string;
    FSpellForm: TWPSpellForm;
    FSpellPopupMenu: TPopupMenu;
{$IFDEF WPTOOLS5}
    FCurrEdit: TWPCustomRtfEdit;
{$ENDIF}
    function GetSpellForm: TWPSpellForm;
    function GetSpellPopupMenu: TPopupMenu;
    procedure SubIgnore(const aWord, ReplaceStr: string; all, replace: Boolean);
  protected
{$IFDEF WPTOOLS5}
    procedure DoMouseDownRight(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer; par: TParagraph;
      posinpar: Integer; Pos: Integer; len: Integer; var text: string;
      var atr: Cardinal; var Abort: Boolean);
    procedure DoSpellCheckWord(Sender: TObject; var Word: WideString;
      var Res: TSpellCheckResult; var Hyphen: TSpellCheckHyphen;
      par: TParagraph; posinpar: Integer);
{$ELSE}
    procedure DoMouseDownRight(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      pos: Longint; len: Integer; var text: string; var atr: TAttr);
    procedure DoSpellCheckWord(Sender: TObject; word: string; var res: TSpellCheckResult; var hypen:
      TSpellCheckHyphen);
{$ENDIF}
    function PreparePopup(current_word: string; SpellPopupMenu: TPopupMenu; list: TStrings): Boolean; virtual;
    procedure DoWordPopupClick(Sender: TObject);
    procedure DoWordPopupOptions(Sender: TObject);
    procedure DoWordPopupLanguage(Sender: TObject);
    procedure DoWordPopupIgnoreClick(Sender: TObject);
    procedure DoWordPopupIgnoreAllClick(Sender: TObject);
    procedure DoWordPopupAddClick(Sender: TObject);
    procedure SetSpellAsYouGoIsActive(x: Boolean); override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure DoSpellCheck(Sender: TObject; Mode: TWPStartSpellcheckMode);
    procedure SpellCheck(ThisControl: TControl; mode: TWPSpellCheckStartMode); override;
    function Changing: Boolean; override;
    procedure Changed; override;
    procedure Ignore(const aWord: string); override;
    procedure IgnoreAll(const aWord: string); override;
    procedure Replace(const aWord, ReplaceWord: string); override;
    procedure ReplaceAll(const aWord, ReplaceWord: string); override;
    procedure StartNextWord; override;
    function GetNextWord(var languageid: Integer): string; override;
    procedure MoveCursor; override;
    procedure SaveState; override;
    function RestoreState: Boolean; override;
    function GetScreenXYWH(var X, Y, W, H: Integer): Boolean; override;
    procedure ToStart; override;
    procedure SelectLanguageFromHere(LanguageID: Integer); override;
    function GetDefaultLanguageID: Integer; override;
    procedure DoSpellAsYouGo; override;
    property SpellForm: TWPSpellForm read GetSpellForm;
    property SpellPopupMenu: TPopupMenu read GetSpellPopupMenu;
  end;

// interface functions to work with WPTools (by wpcubed GmbH)
var
  WPSpellCheckInterface: TWPToolsSpellInterface;
// The ' and - sing can be part of a word if between characters
// You can also modiufy the array WPWordDelimiter
  WPSpellApMinusIsWord: Boolean = true;

implementation

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

constructor TWPToolsSpellInterface.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
{$IFDEF WPTOOLS5}
  _SupportAutoCorrect := TRUE;
{$ELSE}
  _SupportAutoCorrect := FALSE;
{$ENDIF}
end;

destructor TWPToolsSpellInterface.Destroy;
begin
  FreeAndNil(FSpellForm);
  FreeAndNil(FSpellPopupMenu);
  inherited Destroy;
end;

function TWPToolsSpellInterface.GetSpellForm: TWPSpellForm;
begin
  if not assigned(FSpellForm) then
  begin
    FSpellForm := TWPSpellForm.Create(nil); // cannot be 'Application' !
    FSpellForm.FormStyle := fsStayOnTop; //<--- STAY ON TOP!
    FSpellForm.SpellInterface := Self;
  end;
  Result := FSpellForm;
end;

function TWPToolsSpellInterface.GetSpellPopupMenu: TPopupMenu;
begin
  if not assigned(FSpellPopupMenu) then
    FSpellPopupMenu := TPopupMenu.Create(nil);
  Result := FSpellPopupMenu;
end;

procedure TWPToolsSpellInterface.SpellCheck(ThisControl: TControl; mode: TWPSpellCheckStartMode);
begin
  Control := ThisControl as TWPCustomRtfEdit;
  if mode = wpCheckFromStart then TWPCustomRtfEdit(Control).CPPosition := 0;
  SpellForm.SpellCheck(TWPCustomRtfEdit(Control));
end;

procedure TWPToolsSpellInterface.DoSpellCheck(Sender: TObject; Mode: TWPStartSpellcheckMode);
begin
  // TWPStartSpellcheckMode = (wpStartSpellCheck, wpStartThesuarus, wpStartSepllAsYouGo, wpStopSpellAsYouGo);
  if Sender is TWPCustomRtfEdit then
    case Mode of
      wpStartSpellCheck:
        begin
          Control := TWPCustomRtfEdit(Sender);
          SpellForm.SpellCheck(TWPCustomRtfEdit(Sender));
        end;
      // wpStartThesuarus:
      wpStartSpellAsYouGo:
        begin
          Control := TWPCustomRtfEdit(Sender);
          SpellAsYouGoIsActive := TRUE;
        end;
      wpStopSpellAsYouGo:
        begin
          Control := TWPCustomRtfEdit(Sender);
          SpellAsYouGoIsActive := FALSE;
        end;
{$IFDEF WPTOOLS5}
      wpShowSpellCheckSetup:
        begin
          Control := TWPCustomRtfEdit(Sender);
          Configure;
        end;
{$ENDIF}
    end;
end;

function TWPToolsSpellInterface.Changing: Boolean;
begin
  Result := TRUE;
end;

procedure TWPToolsSpellInterface.Changed;
begin
end;

{$IFDEF WPTOOLS5}

procedure TWPToolsSpellInterface.SubIgnore(const aWord, ReplaceStr: string;
  all, replace: Boolean);
var par: TParagraph;
  i, l, j, st: Integer;
  b, cont, UpdateAtOnce: Boolean;
  w: WideString;
  a: Cardinal;
  sels, sele: Integer;
  FFirstReplace: TParagraph;
  FFirstReplaceP: Integer;
begin
  w := aWord;
  UpdateAtOnce := FALSE;
  FFirstReplace := nil;
  FFirstReplaceP := 0;
  if all then
    SpellController.IgnoreWord(aWord);
  l := Length(aWord);
  if replace or SpellAsYouGoIsActive then
    if Control is TWPCustomRtfEdit then
    begin
      if TWPCustomRtfEdit(Control).IsSelected then
      begin
        sels := TWPCustomRtfEdit(Control).TextCursor.DropMarkerAtSelStart;
        sele := TWPCustomRtfEdit(Control).TextCursor.DropMarkerAtSelEnd;
      end else
      begin
        sels := 0;
        sele := 0;
      end;

      par := TWPCustomRtfEdit(Control).ActiveParagraph;

      // Store this paragraph for UNDO
      if wpActivateUndo in TWPCustomRtfEdit(Control).EditOptions then
        TWPCustomRtfEdit(Control).HeaderFooter.StartUndolevel;


      st := TWPCustomRtfEdit(Control).ActivePosInPar - l;
      if st < 0 then st := 0;
      while par <> nil do
      begin
        i := st;
        cont := TRUE;
        // The WFLG_NoProof option was added in WPTools V5.18.5 ----------------
        // WPAT_ParFlags=127, WPFLG_NOPROOF=4
        if (par.AGetDef(127, 0) and 4) <> 0 then begin st := 0; par := par.next; continue; end else
        // ---------------------------------------------------------------------
          while i <= par.CharCount - l do
          begin
            if par.IsWordDelimiter(i - 1) and par.IsWordDelimiter(i + l) then
            begin
              cont := FALSE;
              b := TRUE;
              for j := 0 to l - 1 do
                if par.CharItem[j + i] <> w[j + 1] then
                begin
                  b := FALSE;
                  break;
                end;
              if b then
              begin

                if wpActivateUndo in TWPCustomRtfEdit(Control).EditOptions then
                  TWPCustomRtfEdit(Control).HeaderFooter.UndoBufferSaveTo(
                    par, wpuReplaceParText, wputAny, i, false);

                if FFirstReplace = nil then
                begin
                  FFirstReplace := par;
                  if not replace then
                    FFirstReplaceP := j + i
                  else FFirstReplaceP := Length(ReplaceStr) + i;
                end;
                if replace then
                begin
                  a := par.CharAttr[i] and (not cafsMisSpelled) or cafsWasChecked;
                  par.DeleteChars(i, l);
                  if ReplaceStr <> '' then
                    par.Insert(i, ReplaceStr, a);
                  UpdateAtOnce := TRUE;
                end else
                begin
                  for j := 0 to l - 1 do
                    par.CharAttr[j + i] :=
                      par.CharAttr[j + i] and (not cafsMisSpelled) or cafsWasChecked;
                end;
              end;
            end;
            if not all and not cont then break;
            inc(i);
          end;
        if not all then break;
        par := par.next;
      end;

      if wpActivateUndo in TWPCustomRtfEdit(Control).EditOptions then
        TWPCustomRtfEdit(Control).HeaderFooter.EndUndolevel;

      if sels <> 0 then
        TWPCustomRtfEdit(Control).TextCursor.SelectMarker(sels, sele);


      if FFirstReplace <> nil then
        TWPCustomRtfEdit(Control).TextCursor.MoveTo(FFirstReplace, FFirstReplaceP)
      {else if TWPCustomRtfEdit(Control).IsSelected then
         while not TWPCustomRtfEdit(Control).ActiveParagraph.IsWordDelimiter(
              TWPCustomRtfEdit(Control).ActivePosInPar
            ) and TWPCustomRtfEdit(Control).CPMoveNext do };

      TWPCustomRtfEdit(Control).TextCursor.CollectAllMarker;
      if UpdateAtOnce then
        TWPCustomRtfEdit(Control).DelayedReformat
      else TWPCustomRtfEdit(Control).DelayedInvalidate;
    end;
end;
{$ELSE} // WPTOOLS 4

procedure TWPToolsSpellInterface.SubIgnore(const aWord, ReplaceStr: string; all, replace: Boolean);
  function IsWordDelimiter(lin: PTLine; pos: Integer): Boolean;
  var p: PChar;
  begin
    if (lin = nil) or (pos < 0) or (pos >= lin^.plen) then Result := TRUE
    else
    begin
      p := lin^.pc;
      inc(p, pos);
      Result := WPWordDelimiterArray[p^];
    end;
  end; // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
var
  par: PTParagraph;
  lin: PTLine;
  pc, p1, p2: PChar;
  pa, pa1, pa2: PTAttr;
  cp, l, lr, cc: Integer;
  a: TAttr;
  parmod, txtmod: Boolean;
begin
  l := Length(aWord);
  lr := Length(ReplaceStr);
  if l > 0 then
  begin
    if all then
    begin
      par := TWPCustomRichtext(Control).FirstPar;
      lin := par^.line;
      cp := 0;
    end else if TWPCustomRichtext(Control).Memo.block_s_par <> nil then
    begin
      par := TWPCustomRichtext(Control).Memo.block_s_par;
      lin := TWPCustomRichtext(Control).Memo.block_s_lin;
      cp := TWPCustomRichtext(Control).Memo.block_s_cp;
    end else
    begin
      par := TWPCustomRichtext(Control).ActivePar;
      lin := TWPCustomRichtext(Control).ActiveLine;
      cp := TWPCustomRichtext(Control).Memo.cursor_pos;
    end;
    pc := lin^.pc;
    l := Length(aWord);
    inc(pc, cp);
    parmod := FALSE;
    txtmod := FALSE;
    while par <> nil do
    begin
      if (cp < lin^.plen - l + 1)
        and IsWordDelimiter(lin, cp + l)
        and IsWordDelimiter(lin, cp - 1)
        and (StrlIComp(PChar(aWord), pc, l) = 0)
        then
      begin
        pa := lin^.pa;
        inc(pa, cp);
        parmod := replace;
        if not replace or (lr = l) then
          for cc := 1 to l do
          begin
            exclude(pa^.style, afsMisspelled);
            include(pa^.style, afsWasChecked);
            inc(cp);
            if replace then pc^ := ReplaceStr[cc]; // Quick Replace
            inc(pc);
            inc(pa);
          end else // Complicated Replace
        begin
          a := pa^;
          exclude(a.style, afsMisspelled);
          include(a.style, afsWasChecked);
          TWPCustomRichtext(Control).Memo.ReAllocLine(lin, lin^.plen - l + lr + 4);
          pa := lin^.pa;
          inc(pa, cp);
          pc := lin^.pc;
          inc(pc, cp);
          if lr > l then
          begin
            pa1 := lin^.pa; inc(pa1, lin^.plen + (lr - l));
            pa2 := lin^.pa; inc(pa2, lin^.plen);
            p1 := lin^.pc; inc(p1, lin^.plen + (lr - l));
            p2 := lin^.pc; inc(p2, lin^.plen);
            for cc := 1 to lin^.plen - cp - l + 1 do
            begin
              p1^ := p2^;
              pa1^ := pa2^;
              dec(p1);
              dec(p2);
              dec(pa1);
              dec(pa2);
            end;
          end
          else
          begin
            pa1 := pa; inc(pa1, lr);
            pa2 := pa; inc(pa2, l);
            p1 := pc; inc(p1, lr);
            p2 := pc; inc(p2, l);
            for cc := 1 to lin^.plen - cp - l + 1 do
            begin
              p1^ := p2^;
              pa1^ := pa2^;
              inc(p1);
              inc(p2);
              inc(pa1);
              inc(pa2);
            end;
          end;
          if (TWPCustomRichtext(Control).Memo.active_line = lin) and
            (TWPCustomRichtext(Control).Memo.cursor_pos = cp + l) then
            TWPCustomRichtext(Control).Memo.cursor_pos := cp + lr;
          lin^.plen := lin^.plen - l + lr;

          for cc := 1 to lr do
          begin
            inc(cp);
            pc^ := ReplaceStr[cc]; // Quick Replace
            pa^ := a;
            inc(pc);
            inc(pa);
          end;
        end;
      end;
      if not all then break;
      if cp < lin^.plen then
      begin
        inc(cp);
        inc(pc);
      end
      else if lin^.next <> nil then
      begin
        lin := lin^.next;
        cp := 0;
        pc := lin^.pc;
      end else if par^.next <> nil then
      begin
        if parmod then
        begin
          TWPCustomRichtext(Control).Memo.InitializePar(par);
          TWPCustomRichtext(Control).Memo.ReformatPar(par);
          txtmod := TRUE;
        end;
        par := par^.next;
        lin := par^.line;
        cp := 0;
        pc := lin^.pc;
      end else break;
    end;
  end;

  if parmod then
  begin
    TWPCustomRichtext(Control).Memo.InitializePar(par);
    txtmod := TRUE;
  end;
  if txtmod then
  begin
    TWPCustomRichtext(Control).Memo.SetTopOffset;
  end;
  if all then TWPCustomRichtext(Control).Invalidate;
end;
{$ENDIF}

procedure TWPToolsSpellInterface.Ignore(const aWord: string);
begin
{$IFDEF WPTOOLS5}
  if FSelStart > 0 then
  begin
    //(Control as TWPCustomRtfEdit).TextCursor.GotoMarker(true, FSelStart);
    (Control as TWPCustomRtfEdit).TextCursor.CollectMarker(FSelStart);
    FSelStart := 0;
  end;
{$ENDIF}
  SubIgnore(aWord, '', false, false);
end;

procedure TWPToolsSpellInterface.IgnoreAll(const aWord: string);
begin
{$IFDEF WPTOOLS5}
  if FSelStart > 0 then
  begin
    (Control as TWPCustomRtfEdit).TextCursor.GotoMarker(true, FSelStart);
    FSelStart := 0;
  end;
{$ENDIF}
  SpellController.IgnoreWord(aWord);
  SubIgnore(aWord, '', true, false);
end;

procedure TWPToolsSpellInterface.Replace(const aWord, ReplaceWord: string);
begin
  if Changing then
  begin
    SubIgnore(aWord, ReplaceWord, false, true);
    Changed;
  end;
end;

(*var
  InsertAttr: TAttr;
begin
  if Changing then
  begin
    with Control as TWPCustomRtfEdit do
    begin
      InsertAttr := Attr;
      ClearSelection;
      InsertTextAtCP(PChar(ReplaceWord), @InsertAttr);
      Refresh;
    end;
    Changed;
  end;
end;
*)

procedure TWPToolsSpellInterface.ReplaceAll(const aWord, ReplaceWord: string);
begin
  if Changing then
    SubIgnore(aWord, ReplaceWord, true, true);
end;

procedure TWPToolsSpellInterface.StartNextWord;
begin
{$IFDEF WPTOOLS5}
  (Control as TWPCustomRtfEdit).Spell_FromCursorPos;
{$ELSE}
  (Control as TWPCustomRichText).Spell_FromCursorPos;
{$ENDIF}
end;

{$IFDEF WPTOOLS5}

function TWPToolsSpellInterface.GetNextWord(var languageid: Integer): string;
var par: TParagraph;
  pos, l: Integer;
  edit: TWPCustomRtfEdit;
  fr: Boolean;
  c: WideChar;
begin
  fr := WPSpellApMinusIsWord; // languageid = 1036;
  languageid := 0;
  edit := (Control as TWPCustomRtfEdit);
  par := Edit.TextCursor.active_paragraph;
  pos := Edit.TextCursor.active_posinpar;
  l := 0;
  while par <> nil do
  begin
    if (par.AGetDef(127, 0) and 4)=0 then // WPAT_ParFlags=127, WPFLG_NOPROOF=4
    begin
      while (pos < par.CharCount) and par.IsWordDelimiter(pos) do inc(pos);
      if pos < par.CharCount then
      begin
        l := 0;
        while pos + l < par.CharCount do
        begin
          if par.IsWordDelimiter(pos + l) then
          begin
            c := par.CharItem[pos + l];
            if (not fr or ((c <> '-') and (c <> #39))) then break;
          end;
          inc(l);
        end;
        if fr then while (l > 0) and par.IsWordDelimiter(pos + l-1) do dec(l);
        if l > 1 then break;
      end;
    end;
    par := par.next;
    pos := 0;
  end;

  if (par <> nil) and (l > 0) then
  begin
    Edit.TextCursor.SpeedSelectFromTo(par, pos, par, pos + l);
    Result := par.GetSubText(pos,l);
    Edit.TextCursor.active_paragraph := par;
    Edit.TextCursor.active_posinpar := pos+l;
    Edit.ShowCursor;
  end else begin Edit.TextCursor.HideSelection; Result := ''; end;


(* repeat
    Result := '';
    with Edit.TextCursor do
    begin
      if active_paragraph <> nil then
      begin
        while IsWordDelimiter and MoveNext(1) do ;
        if not IsWordDelimiter then
        begin
          par1 := active_paragraph;
          pos1 := active_posinpar;
          while not IsWordDelimiter or (fr and ((Edit.CPChar = '-') or (Edit.CPChar = #39))) do
          begin
            Result := Result + Edit.CPChar;
            MoveNext(1);
          end;
          if fr then
            while (active_posinpar > pos1) and
              active_paragraph.IsWordDelimiter(active_posinpar - 1) do dec(active_posinpar);
          if (pos1>=par1.CharCount) then begin par1 := par1.next; pos1 := 0; end;
          SpeedSelectFromTo(par1, pos1, active_paragraph, active_posinpar);
        end;
      end; }
    end;
  // The WFLG_NoProof option was added in WPTools V5.18.5 ----------------
  // WPAT_ParFlags=127, WPFLG_NOPROOF=4
  until (Result = '') or (((Control as TWPCustomRtfEdit).ActiveParagraph.AGetDef(127, 0) and 4) = 0);
  *)

end;

{$ELSE}

function TWPToolsSpellInterface.GetNextWord(var languageid: Integer): string;
begin
  languageid := 0;
  (Control as TWPCustomRichText).HideSelection;
  Result := TWPCustomRichText(Control).Spell_GetNextWord;
end;
{$ENDIF}



procedure TWPToolsSpellInterface.MoveCursor;
begin
{$IFDEF WPTOOLS5}
  (Control as TWPCustomRtfEdit).Spell_SelectWord;
{$ELSE}
  (Control as TWPCustomRichText).Spell_SelectWord;
{$ENDIF}
end;


procedure TWPToolsSpellInterface.SaveState;
begin
{$IFDEF WPTOOLS5}
  if FSelStart > 0 then
    (Control as TWPCustomRtfEdit).TextCursor.CollectMarker(FSelStart);
  FSelStart := (Control as TWPCustomRtfEdit).TextCursor.DropMarkerAtSelStart;
  FSelEnd := (Control as TWPCustomRtfEdit).TextCursor.DropMarkerAtSelEnd;
{$ENDIF}
end;

function TWPToolsSpellInterface.RestoreState: Boolean;
begin
{$IFDEF WPTOOLS5}
  if FSelStart > 0 then
  begin
    Result := (Control as TWPCustomRtfEdit).TextCursor.SelectMarker(FSelStart, FSelEnd);
    (Control as TWPCustomRtfEdit).TextCursor.CollectMarker(FSelStart);
    FSelStart := 0;
  end
  else Result := FALSE;
{$ELSE}
  REsult := TRUE;
{$ENDIF}
end;

function TWPToolsSpellInterface.GetScreenXYWH(var X, Y, W, H: Integer): Boolean;
var
{$IFDEF WPTOOLS5}
  r: TRect;
{$ELSE}
  p: TPoint;
{$ENDIF}
begin
  with Control as TWPCustomRtfEdit do
  begin
{$IFDEF WPTOOLS5}
    r := SelRect;
    x := r.Left;
    y := r.Top;
    w := r.Right - r.Left;
    h := r.Bottom - r.Top;
{$ELSE}
    p.x := 0;
    p.y := 0;
    if memo.block_e_lin <> nil then
      p.y := memo.TwipToScreen(memo.block_e_lin^.y_start
        + memo.block_e_lin^.height - memo.Top_Offset);
    p := ClientToScreen(p);
    x := p.X;
    y := p.Y;
    w := 0;
    h := 0;
{$ENDIF}
  end;
  Result := TRUE;
end;

procedure TWPToolsSpellInterface.ToStart;
begin
  with Control as TWPCustomRtfEdit do
  begin
    CPPosition := 0;
    SetSelPosLen(0, 0{$IFDEF WPTOOLS5}, true{$ENDIF});
  end;
end;

procedure TWPToolsSpellInterface.SelectLanguageFromHere(LanguageID: Integer);
begin
    // Insert lanuage marker
end;

function TWPToolsSpellInterface.GetDefaultLanguageID: Integer;
begin
  Result := 0;
end;

{$IFNDEF WPTOOLS5} // Spell_RemoveMarkers for WPTools 4

procedure Spell_RemoveMarkers(memo: TWPCustomRtfEdit);
var par: PTParagraph;
  lin: PTLine;
  pa: PTAttr;
  i: Integer;
begin
  par := memo.memo.FirstPar;
  while par <> nil do
  begin
    lin := par^.line;
    while lin <> nil do
    begin
      pa := lin^.pa;
      for i := 1 to lin^.plen do
      begin
        exclude(pa^.style, afsMisspelled);
        exclude(pa^.style, afsWasChecked);
        inc(pa);
      end;
      lin := lin^.next;
    end;
    par := par^.next;
  end;
end;
{$ENDIF}

procedure TWPToolsSpellInterface.DoSpellAsYouGo;
begin
  if SpellAsYouGoIsActive and (Control <> nil) then
  begin
{$IFDEF WPTOOLS5}
    TWPCustomRtfEdit(Control).Spell_RemoveMarkers;
    TWPCustomRtfEdit(Control).Memo._3RDPartyOnSpellCheckWord := Self.DoSpellCheckWord;
    TWPCustomRtfEdit(Control)._3RDParty_OnMouseDownWord := Self.DoMouseDownRight;
    TWPCustomRtfEdit(Control).Refresh(true);
{$ELSE}
    Spell_RemoveMarkers(TWPCustomRtfEdit(Control));
    TWPCustomRtfEdit(Control).OnMouseDownRight := Self.DoMouseDownRight;
    TWPCustomRtfEdit(Control).OnSpellCheckWord := Self.DoSpellCheckWord;
    TWPCustomRtfEdit(Control).RefreshExt(true);
{$ENDIF}
    FLastSpellControl := Control;
  end else if not SpellAsYouGoIsActive and (Control <> nil) then
  begin
{$IFDEF WPTOOLS5}
    TWPCustomRtfEdit(Control).Spell_RemoveMarkers;
    TWPCustomRtfEdit(Control).Memo._3RDPartyOnSpellCheckWord := nil;
    TWPCustomRtfEdit(Control)._3RDParty_OnMouseDownWord := nil;
    TWPCustomRtfEdit(Control).Refresh(true);
{$ELSE}
    Spell_RemoveMarkers(TWPCustomRtfEdit(Control));
    TWPCustomRtfEdit(Control).OnMouseDownRight := nil;
    TWPCustomRtfEdit(Control).OnSpellCheckWord := nil;
    TWPCustomRtfEdit(Control).Repaint;
{$ENDIF}
  end;
end;

procedure TWPToolsSpellInterface.SetSpellAsYouGoIsActive(x: Boolean);
begin
  if (SpellAsYouGoIsActive <> x) or (FLastSpellControl <> Control) then
  begin
    inherited SetSpellAsYouGoIsActive(x);
    if Control <> nil then
    begin
      if x then
      begin
{$IFDEF WPTOOLS5}
        TWPCustomRtfEdit(Control).Spell_RemoveMarkers;
        TWPCustomRtfEdit(Control).Memo._3RDPartyOnSpellCheckWord := Self.DoSpellCheckWord;
        TWPCustomRtfEdit(Control)._3RDParty_OnMouseDownWord := Self.DoMouseDownRight;
        TWPCustomRtfEdit(Control).Refresh(true);
{$ELSE}
        TWPCustomRtfEdit(Control).OnMouseDownRight := Self.DoMouseDownRight;
        TWPCustomRtfEdit(Control).OnSpellCheckWord := Self.DoSpellCheckWord;
{$ENDIF}
      end else
      begin
{$IFDEF WPTOOLS5}
        TWPCustomRtfEdit(Control).Memo._3RDPartyOnSpellCheckWord := nil;
        TWPCustomRtfEdit(Control)._3RDParty_OnMouseDownWord := nil;
        TWPCustomRtfEdit(Control).Spell_RemoveMarkers;
{$ELSE}
        TWPCustomRtfEdit(Control).OnMouseDownRight := nil;
        TWPCustomRtfEdit(Control).OnSpellCheckWord := nil;
{$ENDIF}
      end;
    end;
    FLastSpellControl := Control;
  end;
end;

{$IFDEF WPTOOLS5}

procedure TWPToolsSpellInterface.DoSpellCheckWord(Sender: TObject; var Word: WideString;
  var Res: TSpellCheckResult; var Hyphen: TSpellCheckHyphen;
  par: TParagraph; posinpar: Integer);
var Mode: TWPInDictionaryMode;
  SpellRes: TWPInDictionaryResult;
  fr: Boolean;
  l, opos: Integer;
begin
  Mode := [wpAutoOpenDictionaries, wpInCheckSpellAsYouGo];
  Res := [];
  fr := WPSpellApMinusIsWord;
  opos := posinpar;

  if fr then
  begin
    if ((par.ANSIChr[posinpar - 1] = #39) or (par.ANSIChr[posinpar - 1] = '-')) and
      not par.IsWordDelimiter(posinpar - 2) then
      while not par.IsWordDelimiter(posinpar - 1) or
        ((par.ANSIChr[posinpar - 1] = #39) or (par.ANSIChr[posinpar - 1] = '-')) do
        dec(posinpar);
    l := 0;
    while not par.IsWordDelimiter(posinpar + l) or
      ((par.ANSIChr[posinpar + l] = #39) or (par.ANSIChr[posinpar + l] = '-')) do
    begin
      inc(l);
    end;
    while par.IsWordDelimiter(posinpar + l - 1) and (l > 0) do dec(l);
    Word := par.GetSubText(posinpar, l);
  end else l := Length(Word);


  if {$IFDEF IGNOREONECHARS}(Length(Word) > 1) and {$ENDIF}
  not SpellController.InDictionary(word, Mode, SpellRes) then
  begin
     // Autocorrect only possible with WPTools 5
    if ((SpellController.OptionFlags and WPSPELLOPT_AUTOCORRECT_CAPS) <> 0) and
      (wpNeedCapital in SpellRes)
      and (par.RTFData.DataCollection.Cursor.active_paragraph = par) and
      (par.RTFData.DataCollection.Cursor.active_posinpar <= posinpar + Length(Word) + 1) and
      (par.RTFData.DataCollection.Cursor.active_posinpar >= posinpar - 1)
      then
    begin
      if (Word[1] >= 'a') and (Word[1] <= 'z') then
      begin
        Word[1] := WideChar(Integer(Word[1]) - 32);
        res := [spReplaceWord];
      end
      else res := [spMisSpelled];
    end
    else if
      ((SpellController.OptionFlags and WPSPELLOPT_AUTOCORRECT_LIST) <> 0) and
      (wpNeedAutoReplace in SpellRes) and
      (par.RTFData.DataCollection.Cursor.active_paragraph = par) and
      (par.RTFData.DataCollection.Cursor.active_posinpar <= posinpar + Length(Word) + 1) and
      (par.RTFData.DataCollection.Cursor.active_posinpar >= posinpar - 1) then
    begin
      Word := SpellController.AutoReplacedWord;
      res := [spReplaceWord];
    end
    else
    begin
      res := [spMisSpelled];
      if opos > posinpar then
      begin
        while opos < posinpar + l do
        begin
          par.CharAttr[opos] := par.CharAttr[opos] or cafsMisSpelled;
          inc(opos);
        end;
      end;
    end;
  end;
end;

{$ELSE} // WPTools 4

procedure TWPToolsSpellInterface.DoSpellCheckWord(Sender: TObject; word: string; var res: TSpellCheckResult; var hypen:
  TSpellCheckHyphen);
var Mode: TWPInDictionaryMode;
  SpellRes: TWPInDictionaryResult;
begin
  Mode := [wpAutoOpenDictionaries, wpInCheckSpellAsYouGo];
  Res := [];
  if {$IFDEF IGNOREONECHARS}(Length(Word) > 1) and {$ENDIF}
  not SpellController.InDictionary(word, Mode, SpellRes) then
  begin
    res := [spMisSpelled];
  end;
end;
{$ENDIF}

function TWPToolsSpellInterface.PreparePopup(
  current_word: string;
  SpellPopupMenu: TPopupMenu; list: TStrings): Boolean;
var i: Integer;
  m, m2: TMenuItem;
begin
  Result := TRUE;
  m := nil;
  for i := 0 to Min(3, list.Count - 1) do
  begin
    m := TMenuItem.Create(SpellPopupMenu);
    m.Caption := list[i];
    m.OnClick := DoWordPopupClick;
    SpellPopupMenu.Items.Add(m);
  end;

  if (m <> nil) and (list.Count > 4) then
  begin
    m2 := TMenuItem.Create(m);
    m2.Caption := '...';
    SpellPopupMenu.Items.Add(m2);
    for i := 4 to list.Count - 1 do
    begin
      m := TMenuItem.Create(m2);
      m.Caption := list[i];
      m.OnClick := DoWordPopupClick;
      m2.Add(m);
    end;
  end;

    // Separator
  m := TMenuItem.Create(SpellPopupMenu);
  m.Caption := '-';
  m.Enabled := FALSE;
  SpellPopupMenu.Items.Add(m);

    // Ignore ...
  m := TMenuItem.Create(SpellPopupMenu);
  m.Caption := cLabels[WPSpellCurrentLabelLanguage][tbtnSkip];
  m.OnClick := DoWordPopupIgnoreClick;
  SpellPopupMenu.Items.Add(m);

    // Ignore ...
  m := TMenuItem.Create(SpellPopupMenu);
  m.Caption := cLabels[WPSpellCurrentLabelLanguage][tbtnSkipAll];
  m.OnClick := DoWordPopupIgnoreAllClick;
  SpellPopupMenu.Items.Add(m);

    // Add
  m := TMenuItem.Create(SpellPopupMenu);
  m.Caption := Format(cLabels[WPSpellCurrentLabelLanguage][tlblAddMesg], [current_word]);
  m.OnClick := DoWordPopupAddClick;
  SpellPopupMenu.Items.Add(m);

    // Separator
  m := TMenuItem.Create(SpellPopupMenu);
  m.Caption := '-';
  m.Enabled := FALSE;
  SpellPopupMenu.Items.Add(m);

    // Configure
  m := TMenuItem.Create(SpellPopupMenu);
  m.Caption := cLabels[WPSpellCurrentLabelLanguage][tbtnConfigure];
  m.OnClick := DoWordPopupOptions;
  SpellPopupMenu.Items.Add(m);

    // Configure
  m := TMenuItem.Create(SpellPopupMenu);
  m.Caption := cLabels[WPSpellCurrentLabelLanguage][tlblLanguageMenu];
  SpellPopupMenu.Items.Add(m);

  for i := 0 to SpellController.LanguageIDCount - 1 do
  begin
    m2 := TMenuItem.Create(m);
    m2.Caption := SpellController.LanguageName[i];
    m2.Tag := SpellController.LanguageID[i];
    if m2.Tag = SpellController.CurrentLanguage then
      m2.Checked := TRUE;
    m2.OnClick := DoWordPopupLanguage;
    m.Add(m2);
  end;

  if assigned(FAfterCreatePopup) then
    FAfterCreatePopup(Self, SpellPopupMenu);

  SpellController.DoAfterCreatePopup(Self, SpellPopupMenu);
end;


// Creates popup menu with possible alternatives
{$IFDEF WPTOOLS5}

procedure TWPToolsSpellInterface.DoMouseDownRight(
  Sender: TObject;
  Button: TMouseButton;
  Shift: TShiftState;
  X, Y: Integer;
  par: TParagraph;
  posinpar: Integer;
  Pos: Integer;
  len: Integer;
  var text: string;
  var atr: Cardinal;
  var Abort: Boolean);
var list: TStringList;
  i, j: Integer;
  r: TRect;
  LineData: TWPVirtPageImageLineRef;
  fr: Boolean;
  p: TPoint;
  curr_word: string;
begin
  if ((atr and cafsMisSpelled) = 0) or (Button <> mbRight) then exit;

  for i := SpellPopupMenu.Items.Count - 1 downto 0 do
    SpellPopupMenu.Items[i].Destroy;
{$IFNDEF OLDDELPHI}
  // SpellPopupMenu.AutoHotkeys := maManual;
  SpellPopupMenu.AutoHotkeys := maAutomatic;
{$ENDIF}
  fr := WPSpellApMinusIsWord;
  SpellController.DoBeforeCreatePopup(Self, SpellPopupMenu);

  if assigned(FBeforeCreatePopup) then
    FBeforeCreatePopup(Self, SpellPopupMenu);

  Abort := TRUE;
  TWPCustomRtfEdit(sender).TextCursor.DisableTextSelection := TRUE;

  if fr then
  begin
    if ((par.ANSIChr[posinpar - 1] = #39) or (par.ANSIChr[posinpar - 1] = '-')) and
      not par.IsWordDelimiter(posinpar - 2) then
      while not par.IsWordDelimiter(posinpar - 1) or
        ((par.ANSIChr[posinpar - 1] = #39) or (par.ANSIChr[posinpar - 1] = '-')) do
      begin
        dec(posinpar);
        dec(pos);
      end;
    len := 0;
    while not par.IsWordDelimiter(posinpar + len) or
      ((par.ANSIChr[posinpar + len] = #39) or (par.ANSIChr[posinpar + len] = '-')) do
    begin
      inc(len);
    end;
    while par.IsWordDelimiter(posinpar + len - 1) and (len > 0) do dec(len);
    curr_word := par.GetSubText(posinpar, len);
  end else curr_word := text;

  (Sender as TWPCustomRtfEdit).SetSelPosLen(Pos, Length(curr_word));


  (* This code works with WPTools 5 prior to V5.15.5: *)
{$IFNDEF WPHasGetParXYBaselineScreen}
  r := (Sender as TWPCustomRtfEdit).SelRect;
  j := par.LineOfPos(posinpar);
  i := par.Lines[j].PageNum;
  j := par.RTFData.Pages[i].LineNrFromParLin(par, j);
  if par.RTFData.Pages[i].GetLine(j, LineData) then
    inc(r.Top, Round(LineData.tybase * (Sender as TWPCustomRtfEdit).Memo.CurrentZooming
      * WPScreenPixelsPerInch / par.RTFData.Pages[i].YPixelsPerInch));
  p.X := r.Left;
  p.Y := r.Top;
{$ELSE} // new code
  (Sender as TWPCustomRtfEdit).GetParXYBaselineScreen(par, posinpar, p.X, p.Y);
{$ENDIF}
  inc(p.Y, 4);

  FCurrEdit := (Sender as TWPCustomRtfEdit);
  p := TControl(Sender).ClientToScreen(p);

  FCheckedWord := curr_word;
  FChanged := FALSE;
  FIsOk := FALSE;
  list := TStringList.Create;
  SpellController.Suggest(curr_word, list, 15);
  if list <> nil then
  try
    PreparePopup(curr_word, SpellPopupMenu, list);
    SpellPopupMenu.Popup(p.x, p.y);
    // Execute the OnClick !
    Application.ProcessMessages;
    // Changed ?
    if FChanged then
    begin
      // Store this paragraph for UNDO
      if wpActivateUndo in TWPCustomRtfEdit(Control).EditOptions then
      begin
        TWPCustomRtfEdit(Control).HeaderFooter.NewUndolevel;
        TWPCustomRtfEdit(Control).HeaderFooter.UndoBufferSaveTo(
          par, wpuReplaceParText, wputAny, 0, false);
      end;
      if fr then
      begin
        TWPCustomRtfEdit(Sender).SaveChanging;
        par.Replace(posinpar, len, FCheckedWord);
        TWPCustomRtfEdit(Sender).TextCursor.block_s_posinpar := posinpar;
        TWPCustomRtfEdit(Sender).TextCursor.block_e_posinpar := posinpar + Length(FCheckedWord);
        TWPCustomRtfEdit(Sender).TextCursor.active_posinpar := posinpar + Length(FCheckedWord);
        TWPCustomRtfEdit(Sender).DelayedReformat;
      end
      else text := FCheckedWord;
      FIsOk := TRUE;
    end;

    if FIsOk then
    begin
      atr := atr and not cafsMisSpelled or cafsWasChecked;
      for i := posinpar to posinpar + Length(curr_word) do
        par.CharAttr[i] := par.CharAttr[i] and not cafsMisSpelled or cafsWasChecked;
    end;
  finally
    list.Free;
    TWPCustomRtfEdit(Sender).TextCursor.DisableTextSelection := FALSE;
  end;
end;

{$ELSE} // ------------------------ WPTOOLS 4

procedure TWPToolsSpellInterface.DoMouseDownRight(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y:
  Integer;
  pos: Longint; len: Integer; var text: string; var atr: TAttr);
var list: TStringList;
  i, j: Integer;
  m, m2: TMenuItem;
  p: TPoint;
begin
  if not (afsMisSpelled in atr.Style) or (Button <> mbRight) then exit;
  for i := SpellPopupMenu.Items.Count - 1 downto 0 do
    SpellPopupMenu.Items[i].Destroy;
{$IFNDEF OLDDELPHI}
  SpellPopupMenu.AutoHotkeys := maAutomatic;
{$ENDIF}
  SpellController.DoBeforeCreatePopup(Self, SpellPopupMenu);
  if assigned(FBeforeCreatePopup) then
    FBeforeCreatePopup(Self, SpellPopupMenu);
  (Sender as TWPCustomRtfEdit).SetSelPosLen(Pos, Length(Text));
  with TWPCustomRtfEdit(sender).Memo do
  begin
    p.X := Get_X_from_Cp(block_s_par, block_s_lin, block_s_cp) + left_offset;
    p.Y := Get_Y_from_Lin(block_s_lin) - top_offset + 16;
  end;
  p := TControl(Sender).ClientToScreen(p);
  m := nil;
  FCheckedWord := text;
  FChanged := FALSE;
  FIsOk := FALSE;
  list := TStringList.Create;
  SpellController.Suggest(text, list, 15);
  if list <> nil then
  try
    PreparePopup(text, SpellPopupMenu, list);
    SpellPopupMenu.Popup(p.x, p.y);
    // Execute the OnClick !
    Application.ProcessMessages;
    // Changed ?
    if FChanged then
    begin
      text := FCheckedWord;
      FIsOk := TRUE;
    end;

    if FIsOk then
    begin
      Exclude(Atr.Style, afsMisSpelled);
      Include(Atr.Style, afsWasChecked);
    end;
  finally
    list.Free;
  end;
end;
{$ENDIF}

procedure TWPToolsSpellInterface.DoWordPopupOptions(Sender: TObject);
begin
  Configure;
end;

procedure TWPToolsSpellInterface.DoWordPopupLanguage(Sender: TObject);
begin
  if SpellController.CurrentLanguage <> (Sender as TMenuItem).Tag then
  begin
    SpellController.CurrentLanguage := (Sender as TMenuItem).Tag;
    UpdateSpellAsYouGo;
  end;
end;

procedure TWPToolsSpellInterface.DoWordPopupClick(Sender: TObject);
var i, l: Integer;
begin
  FChanged := TRUE;
  FCheckedWord := (Sender as TMenuItem).Caption;
  l := 0;
  for i := 1 to Length(FCheckedWord) do
    if FCheckedWord[i] <> '&' then
    begin
      inc(l);
      FCheckedWord[l] := FCheckedWord[i];
    end;
  SetLength(FCheckedWord, l);
end;

procedure TWPToolsSpellInterface.DoWordPopupIgnoreClick(Sender: TObject);
begin
  FIsOK := TRUE;
  if (Control <> nil) and TWPCustomRtfEdit(Control).IsSelected then
    TWPCustomRtfEdit(Control).CPPosition := TWPCustomRtfEdit(Control).SelStart;
  Ignore(FCheckedWord);
  if Control <> nil then
  begin
    TWPCustomRtfEdit(Control).HideSelection;
     // TWPCustomRtfEdit(Control).Repaint;
  end;
end;


procedure TWPToolsSpellInterface.DoWordPopupIgnoreAllClick(Sender: TObject);
begin
  if (Control <> nil) and TWPCustomRtfEdit(Control).IsSelected then
    TWPCustomRtfEdit(Control).CPPosition := TWPCustomRtfEdit(Control).SelStart;
  IgnoreAll(FCheckedWord);
  if Control <> nil then
    TWPCustomRtfEdit(Control).HideSelection;
end;

procedure TWPToolsSpellInterface.DoWordPopupAddClick(Sender: TObject);
begin
  if (Control <> nil) and TWPCustomRtfEdit(Control).IsSelected then
    TWPCustomRtfEdit(Control).CPPosition := TWPCustomRtfEdit(Control).SelStart;
  IgnoreAll(FCheckedWord);
  SpellController.AddWord(FCheckedWord, '', wpUserAdded);
  if Control <> nil then
    TWPCustomRtfEdit(Control).HideSelection;
end;

{$IFDEF WPTOOLS5}

function DoWPGetSpellCurrentLabelLanguage: TWPSLanguages;
var s: string;
  c: Integer;
begin
  Result := WPSpellCurrentLabelLanguage;
  if assigned(WPLangInterface) then
  begin
    if WPLangInterface.LoadString('WPLocalizeLanguage', s, c) then
    begin
{$IFDEF SupportEnglish}if (s = 'EN') or (s = 'US') then begin Result := lgEnglish; exit; end; {$ENDIF}
{$IFDEF SupportSpanish}if s = 'ES' then begin Result := lgSpanish; exit; end; {$ENDIF}
{$IFDEF SupportItalian}if s = 'IT' then begin Result := lgItalian; exit; end; {$ENDIF}
{$IFDEF SupportFrench}if s = 'FR' then begin Result := lgFrench; exit; end; {$ENDIF}
{$IFDEF SupportGerman}if s = 'DE' then begin Result := lgGerman; exit; end; {$ENDIF}
{$IFDEF SupportDutch}if s = 'NL' then begin Result := lgDutch; exit; end; {$ENDIF}
{$IFDEF SupportPortogese}if s = 'BR' then begin Result := lgPortogese; exit; end; {$ENDIF}
    end;
  end;
end;
{$ENDIF}

initialization
  WPSpellCheckInterface := TWPToolsSpellInterface.Create(nil);
  // This is a global event triggered by WPTools
{$IFDEF WPTOOLS5}
  if (GlobalWPToolsCustomEnviroment <> nil) and
    (GlobalWPToolsCustomEnviroment is TWPToolsEnviroment) then
  begin
    TWPToolsEnviroment(GlobalWPToolsCustomEnviroment).SpellEngine := WPSpellCheckInterface;
    TWPToolsEnviroment(GlobalWPToolsCustomEnviroment).SpellEngine_OnStartSpellcheck
      := WPSpellCheckInterface.DoSpellCheck;
  end;
  WPGetSpellCurrentLabelLanguage := DoWPGetSpellCurrentLabelLanguage;
{$ELSE}
  WPONStartSpellcheck := WPSpellCheckInterface.DoSpellCheck;
{$ENDIF}

finalization
{$IFDEF WPTOOLS5}
  if (GlobalWPToolsCustomEnviroment <> nil) and
    (GlobalWPToolsCustomEnviroment is TWPToolsEnviroment) then
  begin
    TWPToolsEnviroment(GlobalWPToolsCustomEnviroment).SpellEngine := nil;
    TWPToolsEnviroment(GlobalWPToolsCustomEnviroment).SpellEngine_OnStartSpellcheck := nil;
  end;
  WPGetSpellCurrentLabelLanguage := nil;
{$ELSE}
  WPONStartSpellcheck := nil;
{$ENDIF}
  WPSpellCheckInterface.Free;
  WPSpellCheckInterface := nil;
end.

