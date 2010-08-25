unit wpManHeadFoot;
{ -------------------------------------------------------------------
  Manage Header and footer Dialog
  Copyright (C) 2005 by WPCubed GmbH, www.wpcubed.com
  -------------------------------------------------------------------
  Latest change: Use TWPCustomRTFedit, added property PossibleRanges
  ------------------------------------------------------------------- }

interface
{$I WPINC.INC}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, WPRTEPaint, WPUtil
{$IFDEF WPTOOLS5}
  , WPRTEDefs, WPCTRMemo, Buttons;
{$ELSE}
  , WPRich, WPDefs, WPrtfTXT, WpWinCtr, Buttons;
{$ENDIF}

type
  TWPPagePropertyRanges = set of TWPPagePropertyRange;
  {:: Dialog to alow the creation and deletion of header and footer texts in WPTools.

  You can use it like this:
  <code>
  ManHeadFoot : TWPManageHeaderFooter; // global variable

  if ManHeadFoot=nil then
    ManHeadFoot := TWPManageHeaderFooter.Create(Self);
  ManHeadFoot.WPRichText := WPRichText1;
  ManHeadFoot.PossibleRanges :=  [wpraOnAllPages, wpraOnOddPages, wpraOnEvenPages, wpraOnFirstPage]
  ManHeadFoot.Show;
  </code>
  or you can use the new component <see class="TWPManageHeaderFooterDlg">.
  }
  TWPManageHeaderFooter = class(TWPShadedForm)
{$IFNDEF T2H}
    OptionsBut: TButton;
    CloseButton: TButton;
    PopupMenu1: TPopupMenu;
    AllHeaderFooter: TListBox;
    AddHeader: TButton;
    AddFooter: TButton;
    PageLayoutMode: TSpeedButton;
    NormalMode: TSpeedButton;
    GotoBody: TButton;
    SaveLoadHeaderOrFooter: TPopupMenu;
    LoadText1: TMenuItem;
    SaveText1: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Copy: TMenuItem;
    InsertText1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    Delete1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AddHeaderClick(Sender: TObject);
    procedure EdHeaderClick(Sender: TObject);
    procedure DeleteTextClick(Sender: TObject);
    procedure ShowBodyClick(Sender: TObject);
    procedure PageLayoutModeClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure LoadText1Click(Sender: TObject);
    procedure SaveText1Click(Sender: TObject);
    procedure CopyClick(Sender: TObject);
    procedure InsertText1Click(Sender: TObject);
    procedure OptionsButClick(Sender: TObject);
    procedure AllHeaderFooterMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    FWPRichText: TWPCustomRTFedit;
    StoredLayoutMode: TWPLayoutMode;
    StartLayoutMode: TWPLayoutMode;
    FCopyText: string;
    bAutoLayout: Boolean;
    FPossibleRanges : TWPPagePropertyRanges;
    procedure SetPossibleRanges(x : TWPPagePropertyRanges);
    procedure InitMenu;
    procedure Init;
    function  IndexOfID(ID: Integer): Integer;
    procedure MenuClickClick(Sender: TObject);
    procedure SetFocusInWPT;
  public
    constructor Create(aOwner : TComponent); Override;
{$ENDIF}
  public
    {:: Please assign the editor which has to be modified to this property.  }
    property WPRichText: TWPCustomRTFedit read
      FWPRichText write FWPRichText;
    {:: This property controls which header/footer kinds can be created.
    Example:
      PossibleRanges :=  [wpraOnAllPages, wpraOnOddPages, wpraOnEvenPages, wpraOnFirstPage]; }
    property PossibleRanges : TWPPagePropertyRanges read
        FPossibleRanges write SetPossibleRanges;
  end;

  {:: This dialog object makes it easy to modify the header and footer
  in the editor. }
  TWPManageHeaderFooterDlg = class(TWPCustomAttrDlg)
  private
    FManHeadFoot: TWPManageHeaderFooter;
    FPossibleRanges : TWPPagePropertyRanges;
  public
    constructor Create(aOwner : TComponent);  override;
    destructor Destroy; override;
    function Execute: Boolean; override;
    procedure Close; override;
  published
    property EditBox;
    property PossibleRanges : TWPPagePropertyRanges read FPossibleRanges write FPossibleRanges;
  public
    property ManHeadFoot: TWPManageHeaderFooter read FManHeadFoot;
  end;

var
  WPManageHeaderFooter: TWPManageHeaderFooter;

// HFRangeNames - now loaded from WPPagePropertyRangeNames
// WPPagePropertyKinds - now loaded from WPPagePropertyKindNames
// See 'Localisation' demo to localize

(*
const  HFRangeNames : array[TWPPagePropertyRange] of string =
  ('all pages',
    'odd pages',
    'even pages',
    'first page only',
    'last page only',
    'not on first or last pages',
    'not on last page',
    'named',
    'disabled',
    'not on first page'); *)


implementation



{$R *.dfm}

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


    constructor TWPManageHeaderFooterDlg.Create(aOwner : TComponent);
    begin
      inherited Create(aOwner);
      FPossibleRanges :=
         [wpraOnAllPages, wpraOnOddPages, wpraOnEvenPages, wpraOnFirstPage,
          wpraOnLastPage, wpraNotOnFirstAndLastPages, wpraNotOnLastPage];
      FManHeadFoot := nil;
    end;

    destructor TWPManageHeaderFooterDlg.Destroy;
    begin
      FreeAndNil(FManHeadFoot);
      inherited Destroy;
    end;

    function TWPManageHeaderFooterDlg.Execute: Boolean;
    begin
      if FManHeadFoot=nil then
      FManHeadFoot := TWPManageHeaderFooter.Create(Self);
      FManHeadFoot.WPRichText := EditBox;
      FManHeadFoot.PossibleRanges := PossibleRanges;
      FManHeadFoot.Show;
      if FCreateAndFreeDialog then FreeAndNil(FManHeadFoot) else
         FManHeadFoot.Show;
      Result := TRUE;
    end;

    procedure TWPManageHeaderFooterDlg.Close;
    begin
       if FManHeadFoot<>nil then
       begin
         FManHeadFoot.Close;
         FreeAndNil(FManHeadFoot);
       end;
    end;

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

constructor TWPManageHeaderFooter.Create(aOwner : TComponent);
begin
  inherited Create(aOwner);
  FPossibleRanges :=
    [wpraOnAllPages, wpraOnOddPages, wpraOnEvenPages, wpraOnFirstPage,
      wpraOnLastPage, wpraNotOnFirstAndLastPages, wpraNotOnLastPage];
end;

function TWPManageHeaderFooter.IndexOfID(ID: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  if WPRichText <> nil then
    for i := 0 to WPRichText.HeaderFooter.Count - 1 do
      if WPRichText.HeaderFooter.Items[i].ID = ID then
      begin
        Result := i;
        break;
      end;
end;

procedure TWPManageHeaderFooter.SetFocusInWPT;
begin
  if WPRichText.Visible then
  begin
     {$IFNDEF DONT_SELECT_WINDOW}
     Windows.SetFocus( GetParent( WPRichText.Handle ) );
     // WPRichText.Parent.SetFocus;
     WPRichText.SetFocus;
     {$ELSE}
     WPRichText.SetFocus;
     {$ENDIF}    
  end;
end;

procedure TWPManageHeaderFooter.MenuClickClick(Sender: TObject);
var
  item: TWPRTFDataBlock;
begin
  item := WPRichText.HeaderFooter.Get(TWPPagePropertyKind(PopupMenu1.Tag),
    TWPPagePropertyRange((Sender as TMenuItem).Tag), '');
  Init;
  WPRichText.LockScreen;
  try
    if WPRichText.LayoutMode in [wplayNormal,
      wpWordWrapView, wplayShowManualPageBreaks,
      wplayPageGap, wplayExtendedPageGap, wplayShrunkenLayout] then
      WPRichText.DisplayedText := item
    else
    begin
      item.FirstPar; 
      WPRichText.ReformatAll(false, true);
      if not item.IsVisible(WPRichText.Memo) then
      begin
        bAutoLayout := TRUE;
        StoredLayoutMode := WPRichText.LayoutMode;
        NormalMode.Down := TRUE;
        WPRichText.LayoutMode := wplayPageGap;
        WPRichText.DisplayedText := item;
      end;
    end;
    WPRichText.ActiveText := item;
 { old V4 code:
   WPRichText.WorkOnText := wpBody;
   WPRichText.HeaderFooterTextRange := item.Range;
   if item.Kind=wpIsHeader then
        WPRichText.WorkOnText := wpHeader
   else WPRichText.WorkOnText := wpFooter;   }
    WPRichText.ShowCursor;
  finally
    WPRichText.UnlockScreen(false);
  end;
  SetFocusInWPT;
end;

procedure TWPManageHeaderFooter.InitMenu;
var r: TWPPagePropertyRange;
    menu: TMenuItem;
begin
  PopupMenu1.Items.Clear;
  for r := Low(TWPPagePropertyRange) to High(TWPPagePropertyRange) do
  if r in FPossibleRanges then
  begin
    menu := TMenuItem.Create(PopupMenu1);
    menu.Caption :=  WPPagePropertyRangeNames[r];
    menu.OnClick := MenuClickClick;
    menu.Tag := Integer(r);
    PopupMenu1.Items.Add(menu);
  end;
end;

procedure TWPManageHeaderFooter.FormShow(Sender: TObject);

begin
  if WPRichText = nil then raise Exception.Create('property WPRichText has not been assigned');
  StoredLayoutMode := WPRichText.LayoutMode;
  StartLayoutMode := StoredLayoutMode;
{$IFDEF WINCOM}
   LoadLocStrings;
{$ENDIF}
  InitMenu; 
  Init;
end;

procedure TWPManageHeaderFooter.AddHeaderClick(Sender: TObject);
var p: TPoint;
begin
  if Sender = AddHeader then
    PopupMenu1.Tag := Integer(wpIsHeader)
  else PopupMenu1.Tag := Integer(wpIsFooter);
  p := (Sender as TControl).ClientToScreen(Point(0, (Sender as TControl).Height));
  PopupMenu1.Popup(p.x, p.y);
end;

procedure TWPManageHeaderFooter.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TWPManageHeaderFooter.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if WPRichText <> nil then
  begin
    WPRichText.ActiveText := WPRichText.BodyText;
    WPRichText.LayoutMode := StartLayoutMode;
  end;
  Action := caHide;
end;

procedure TWPManageHeaderFooter.SetPossibleRanges(x : TWPPagePropertyRanges);
begin
  if x<>FPossibleRanges then
  begin
     FPossibleRanges := x;
     InitMenu;
  end;
end;

procedure TWPManageHeaderFooter.Init;
var i: Integer;
  s: string;
  iKind: TWPPagePropertyKind;
begin
  AllHeaderFooter.Items.Clear;
  if WPRichText <> nil then
  begin
    for iKind := wpIsHeader to wpIsFooter do
      for i := 0 to WPRichText.HeaderFooter.Count - 1 do
        if WPRichText.HeaderFooter.Items[i].Kind = iKind then
        begin
          s := WPPagePropertyKindNames[iKind] + #32 +
            WPPagePropertyRangeNames[WPRichText.HeaderFooter.Items[i].Range] +
            #32 + WPRichText.HeaderFooter.Items[i].Name;
          if WPRichText.HeaderFooter.Items[i].UsedForSectionID > 0 then
            s := s + ' (' + IntToStr(WPRichText.HeaderFooter.Items[i].UsedForSectionID) + ')';
          if WPRichText.HeaderFooter.Items[i].Readonly then
            s := s + '#';
          AllHeaderFooter.Items.AddObject(s, TObject(WPRichText.HeaderFooter.Items[i].ID));
        end;
    PageLayoutMode.Down :=
      WPRichText.LayoutMode in [wplayShrunkenLayout,
      wplayLayout, wplayFullLayout, wpDualPageView, wpThumbNailView];
    NormalMode.Down := not PageLayoutMode.Down;
  end;
end;

// Select a text from the list to edit. From V4.11b this can be coded much more efficient

procedure TWPManageHeaderFooter.EdHeaderClick(Sender: TObject);
var ind: Integer;
begin
  if AllHeaderFooter.ItemIndex >= 0 then
  begin
    ind := IndexOfID(Integer(AllHeaderFooter.Items.Objects[AllHeaderFooter.ItemIndex]));
    if (ind >= 0) and (WPRichText.HeaderFooter.Items[ind].Readonly) then
      ShowMessage('This text is readonly!')
    else
      if ind >= 0 then
      begin
        if WPRichText.LayoutMode in [wplayNormal,
          wpWordWrapView, wplayShowManualPageBreaks,
          wplayPageGap, wplayExtendedPageGap, wplayShrunkenLayout] then
          WPRichText.DisplayedText := WPRichText.HeaderFooter.Items[ind]
        else
        begin
          if not WPRichText.HeaderFooter.Items[ind].IsVisible(WPRichText.Memo) then
          begin
            bAutoLayout := TRUE;
            StoredLayoutMode := WPRichText.LayoutMode;
            NormalMode.Down := TRUE;
            WPRichText.LayoutMode := wplayPageGap;
            WPRichText.DisplayedText := WPRichText.HeaderFooter.Items[ind];
          end;
        end;
        WPRichText.ActiveText := WPRichText.HeaderFooter.Items[ind];
        WPRichText.ShowCursor;
        SetFocusInWPT;
      end
      else
      begin
        ShowMessage('Cannot find this text');
        Init;
      end;
  end;
  OptionsBut.Enabled := AllHeaderFooter.ItemIndex >= 0;
end;

procedure TWPManageHeaderFooter.DeleteTextClick(Sender: TObject);
var ind: Integer;
begin
  if AllHeaderFooter.ItemIndex >= 0 then
  begin
    ind := IndexOfID(Integer(AllHeaderFooter.Items.Objects[AllHeaderFooter.ItemIndex]));
    if (ind >= 0) and (WPRichText.HeaderFooter.Items[ind].Readonly) then
      ShowMessage('This text is readonly!')
    else
      if ind >= 0 then
      begin
       //was: WPRichText.WorkOnText := wpBody;
        WPRichText.ActiveText := WPRichText.BodyText;
        WPRichText.HeaderFooter.Delete(ind);
        WPRichText.LayoutMode := StoredLayoutMode;
        Init;
        WPRichText.ReformatAll(false, true);
        WPRichText.ReformatAll(false, true);
      end;
  end;
  OptionsBut.Enabled := AllHeaderFooter.ItemIndex >= 0;
  if OptionsBut.Enabled then
    AllHeaderFooter.PopupMenu := SaveLoadHeaderOrFooter
  else AllHeaderFooter.PopupMenu := nil;
end;

procedure TWPManageHeaderFooter.ShowBodyClick(Sender: TObject);
begin

  AllHeaderFooter.ItemIndex := -1;
  if bAutoLayout then
  begin
    WPRichText.LayoutMode := StoredLayoutMode;
    bAutoLayout := FALSE;
  end;
  WPRichText.DisplayedText := WPRichText.BodyText;
  WPRichText.CursorOnText := WPRichText.DisplayedText;
  WPRichText.ShowCursor;
  if WPRichText.HandleAllocated then
  begin
     SetFocusInWPT;
  end;
  Init;
end;

procedure TWPManageHeaderFooter.PageLayoutModeClick(Sender: TObject);
var currrtfdata: TWPRTFDataBlock;
begin
  bAutoLayout := FALSE;
  currrtfdata := WPRichText.CursorOnText;
  if PageLayoutMode.Down then
  begin
    if (WPRichText.LayoutMode in [wplayNormal,
      wpWordWrapView, wplayShowManualPageBreaks,
        wplayPageGap, wplayExtendedPageGap, wplayShrunkenLayout]) and
      (WPRichText.DisplayedText <> nil) and
      (WPRichText.DisplayedText.Kind <> wpIsBody) then
      WPRichText.DisplayedText := WPRichText.BodyText;
    WPRichText.LayoutMode := wplayFullLayout;
  end else
  begin
    if not (WPRichText.LayoutMode in [wplayNormal,
      wpWordWrapView, wplayShowManualPageBreaks,
        wplayPageGap, wplayExtendedPageGap, wplayShrunkenLayout]) then
    begin
      WPRichText.DisplayedText := currrtfdata;
    end;
    WPRichText.LayoutMode := wplayPageGap;
  end;
  WPRichText.ShowCursor;
  SetFocusInWPT;
end;

procedure TWPManageHeaderFooter.FormActivate(Sender: TObject);
var i: Integer;
  currrtfdata: TWPRTFDataBlock;
begin
  Init;
  try
    if (WPRichText <> nil) then
    begin
      currrtfdata := WPRichText.CursorOnText;
      if currrtfdata <> nil then
        for i := 0 to AllHeaderFooter.Items.Count - 1 do
          if Integer(AllHeaderFooter.Items.Objects[i]) = currrtfdata.ID then
          begin
            AllHeaderFooter.ItemIndex := i;
            exit;
          end;
      AllHeaderFooter.ItemIndex := -1;
    end;
  finally
    OptionsBut.Enabled := AllHeaderFooter.ItemIndex >= 0;
    if OptionsBut.Enabled then
      AllHeaderFooter.PopupMenu := SaveLoadHeaderOrFooter
    else AllHeaderFooter.PopupMenu := nil;
  end;
end;

// Loads *only* a header or footer

procedure TWPManageHeaderFooter.LoadText1Click(Sender: TObject);
var currrtfdata: TWPRTFDataBlock;
  f: TFileStream;
begin
  EdHeaderClick(nil);
  if (WPRichText <> nil) then
  begin
    currrtfdata := WPRichText.CursorOnText;
    if (currrtfdata <> nil) and (currrtfdata.Kind in [wpIsHeader, wpIsFooter])
      and not currrtfdata.Readonly then
    begin
      OpenDialog1.Filter := WPLoadStr(meFilter);
      if OpenDialog1.Execute then
      begin
        f := TFileStream.Create(OpenDialog1.FileName, fmOpenRead);
        try
          currrtfdata.RTFtext.LoadFromStream(f);
        finally
          f.Free;
        end;
      end;
    end;
  end;
end;

procedure TWPManageHeaderFooter.SaveText1Click(Sender: TObject);
var currrtfdata: TWPRTFDataBlock;
  f: TFileStream;
begin
  EdHeaderClick(nil);
  if (WPRichText <> nil) then
  begin
    currrtfdata := WPRichText.CursorOnText;
    if (currrtfdata <> nil) and (currrtfdata.Kind in [wpIsHeader, wpIsFooter]) then
    begin
      SaveDialog1.Filter := WPLoadStr(meFilter);
      if SaveDialog1.Execute then
      begin
        f := TFileStream.Create(SaveDialog1.FileName, fmCreate);
        try
          currrtfdata.RTFtext.SaveToStream(f, ExtractFileExt(SaveDialog1.FileName));
        finally
          f.Free;
        end;
      end;
    end;
  end;
end;

procedure TWPManageHeaderFooter.CopyClick(Sender: TObject);
var currrtfdata: TWPRTFDataBlock;
begin
  EdHeaderClick(nil);
  if (WPRichText <> nil) then
  begin
    currrtfdata := WPRichText.CursorOnText;
    FCopyText := currrtfdata.RTFText.AsString;
    InsertText1.Enabled := FCopyText <> '';
  end;
end;

procedure TWPManageHeaderFooter.InsertText1Click(Sender: TObject);
var currrtfdata: TWPRTFDataBlock;
begin
  EdHeaderClick(nil);
  if (WPRichText <> nil) and (FCopyText <> '') then
  begin
    currrtfdata := WPRichText.CursorOnText;
    currrtfdata.RTFText.AsString := FCopyText;
    WPRichText.ReformatAll(false, true);
  end;
end;

procedure TWPManageHeaderFooter.OptionsButClick(Sender: TObject);
var p: TPoint;
  currrtfdata: TWPRTFDataBlock;
  ind: Integer;
begin
  p := (Sender as TControl).ClientToScreen(Point(0, (Sender as TControl).Height));
  currrtfdata := nil;
  if AllHeaderFooter.ItemIndex >= 0 then
  begin
    ind := IndexOfID(Integer(AllHeaderFooter.Items.Objects[AllHeaderFooter.ItemIndex]));
    if (ind >= 0) then currrtfdata := WPRichText.HeaderFooter.Items[ind];
  end;
  Delete1.Enabled := (currrtfdata <> nil) and not (currrtfdata.Readonly);
  LoadText1.Enabled := Delete1.Enabled;
  InsertText1.Enabled := LoadText1.Enabled;
  SaveLoadHeaderOrFooter.Popup(p.x, p.y);
end;

procedure TWPManageHeaderFooter.AllHeaderFooterMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var i : Integer;
begin
  if Button=mbRight then
  begin
     i := AllHeaderFooter.ItemAtPos(Point(x,y),true);
     AllHeaderFooter.ItemIndex := i;
  end;
end;

end.

