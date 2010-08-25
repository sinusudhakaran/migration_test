unit WPGutter;
{ -----------------------------------------------------------------------------
  WPGutter for WPTools 5
  Copyright (C) 2002 by wpcubed GmbH      -   Author: Julian Ziersch
  info: http://www.wptools.de                 mailto:support@wptools.de
  *****************************************************************************
  TextProcessor Gutter
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }
interface

{$I WPINC.INC}

{.$DEFINE BOLDCURRPAR} // When displaying line numbers display current line BOLD!

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ExtCtrls, WPRTEDEfs, WPRTEPaint, WPCtrMemo, WPCTRRich;

type
  // the same order is used in the gutter images, They are defined to be 10x10 images
  TWPGutterImage = (wpgiHasClosedChildren, wpgiHasOpenChildren,
    wgpiArrowDown, wgpiArrowLeft,
    wgpiIndexParagraph,
    wgpiStdParagraph,
    wgpiProtected, wgpiNotProtected,
    wgpiHasStyle,
    wgpiLevel0, wgpiLevel1, wgpiLevel2, wgpiLevel3, wgpiLevel4, wgpiLevel5, wgpiLevel6,
    wgpiLevel7, wgpiLevel8, wgpiLevel9,
    wpgiCursor,
    wpgiComment, wpgiBookmark    );
  TWPGutterImages = set of TWPGutterImage;

  {$IFNDEF T2H}
  TWPGutterItem = class(TObject)
  public
    y: Integer; // Y - Position
    elements: array[0..2] of Integer; // -1 or Integer(TWPGutterImage)
    parnum : Integer;
    autoid : TParagraph;
  end;
  {$ENDIF}

  TWPOnItemClick = procedure(Sender : TObject; parnum : Integer; typ : TWPGutterImage; var done : Boolean) of Object;

  TWPCalcLineNumberEvent = procedure(Sender : TObject; par : TParagraph; posinpar, linenr : Integer; var text : String) of Object;

  {:: You can use the 'gutter' to display line numbers or mark the
  current position with an arrow. It is also useful to show a + and - sign
  to expand and collapse WPReporter groups.
  <br> Usually the gutter is created
  on the left side of the TWPRichText component. In the WPRichText
  component set the property WPGutter to activate the attached gutter control. }
  TWPGutter = class(TWPCustomGutter)
  {$IFNDEF T2H}
  private
    FPaintImages, FPaintImagesSecond, FPaintImagesThird: TWPGutterImages;
    FItemList: TList;
    FActiveParagraph : TParagraph;
    FActiveFirstParagraph : TParagraph;
    FOnItemClick : TWPOnItemClick;
    FActive: Boolean;
    FShowLineNumbers : Boolean;
    FActiveItemYPos, FActiveItem, FActiveColumn: Integer;
    FActiveImages: TWPGutterImages;
    FColumnWidth: Integer;
    FUseNumLevel : Boolean;
    FOnCalcLineNumber : TWPCalcLineNumberEvent;
    procedure PaintItem(row, col: Integer; active: Boolean);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
  protected
    function GetParItem(par: TParagraph; OfSelection: TWPGutterImages): Integer; virtual;
    procedure ChangeCurrentPar; override;
    procedure ChangeDisplay; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Click; override;
  {$ENDIF}
  published
    // We support 3 columns in the gutter
    property PaintImages: TWPGutterImages read FPaintImages write FPaintImages;
    property PaintImagesSecond: TWPGutterImages read FPaintImagesSecond write FPaintImagesSecond;
    property PaintImagesThird: TWPGutterImages read FPaintImagesThird write FPaintImagesThird;
    property ActiveImages: TWPGutterImages read FActiveImages write FActiveImages;
    property UseNumLevel : Boolean read FUseNumLevel write FUseNumLevel default TRUE;
    property ShowLineNumbers : Boolean read FShowLineNumbers write FShowLineNumbers default FALSE;
    property OnItemClick : TWPOnItemClick read FOnItemClick write FOnItemClick;
    property OnCalcLineNumber : TWPCalcLineNumberEvent read FOnCalcLineNumber write FOnCalcLineNumber;
    property Align;
    // property Alignment;
    {$IFDEF DELPHI4}
    property Anchors;
    property Constraints;
    {$ENDIF}
    // property AutoSize;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    // property BiDiMode;
    property BorderWidth;
    property BorderStyle;
    // property Caption;
    property Color;
    property ParentColor;
    property Font;
    property Ctl3D;
    {$IFDEF DELPHI5}
    property UseDockManager default True;
    property DockSite;
    property DragKind;
    {$ENDIF}
    property DragCursor;
    property DragMode;
    property Enabled;
    // property FullRepaint;
    // property Font;
    // property Locked;
    // property ParentBiDiMode;
    // property ParentColor;
    property ParentCtl3D;
    // property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    // property TabOrder;
    // property TabStop;
    property Visible;
    property OnClick;
    {$IFDEF DELPHI5}
    property OnCanResize;
    property OnConstrainedResize;
    property OnContextPopup;
    property OnDockDrop;
    property OnDockOver;
    property OnGetSiteInfo;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
    property OnEndDock;
    property OnEndDrag;
    {$ENDIF}
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

implementation

{$R WPGUTTER.RES}

var
  TheGutterImages, TheGutterImagesActive: TBitmap;


function TWPGutter.GetParItem(par: TParagraph; OfSelection: TWPGutterImages): Integer;
var
  i: TWPGutterImage;
  l : Integer;
begin
  Result := -1;
  if par <> nil then
  begin
    // Cursor has priority !
    if (wpgiCursor in OfSelection) and (par = FActiveFirstParagraph) then
       Result := Integer(wpgiCursor)
    else
    for i := Low(TWPGutterImage) to High(TWPGutterImage) do
    begin
      if i in OfSelection then
        case i of
          wpgiHasClosedChildren, wgpiArrowDown:
            begin
              if {(par.ParagraphType in [wpIsXMLTopLevel, wpIsXMLSubLevel,
                                wpIsXMLDataLevel,wpIsReportGroup]) and}
                  (par.ChildPar <> nil) and (paprIsCollapsed in par.prop) then Result := Integer(i);
            end;
          wpgiHasOpenChildren, wgpiArrowLeft:
            begin
              if {(par.ParagraphType in [wpIsXMLTopLevel, wpIsXMLSubLevel,
                                wpIsXMLDataLevel,wpIsReportGroup]) and}
                 (par.ChildPar <> nil) and not (paprIsCollapsed in par.prop) then Result := Integer(i);
            end;
          {  wgpiArrowDown;
            begin
            end;
            wgpiArrowLeft:
            begin
            end;  }
          wgpiIndexParagraph:
            begin
              if par.AGetDef(WPAT_ParIsOutline,0)<>0 then Result := Integer(i);
            end;
          wgpiStdParagraph:
            begin
              if par.AGetDef(WPAT_ParIsOutline,0)=0 then Result := Integer(i);
            end;
          wgpiProtected:
            begin
              if par.AGetDef(WPAT_ParProtected,0)<>0 then Result := Integer(i);
            end;
          wgpiNotProtected:
            begin
              if par.AGetDef(WPAT_ParProtected,0)=0 then Result := Integer(i);
            end;
          wgpiHasStyle:
            begin
              if par.Style<>0 then Result := Integer(i);
            end;
          wgpiLevel0, wgpiLevel1, wgpiLevel2, wgpiLevel3, wgpiLevel4, wgpiLevel5, wgpiLevel6, wgpiLevel7, wgpiLevel8, wgpiLevel9:
            begin
              if FUseNumLevel then
              begin
                 l := par.AGetDef(WPAT_NumberLEVEL,0);
                 if (l mod 9) = Integer(i)-Integer(wgpiLevel0) then
                 begin
                    if (i<>wgpiLevel0) or (par.AGetDef(WPAT_NumberStyle,0)<>0) then Result := Integer(i);
                 end;
              end {
              else if (par^.level < 0) and (par^.level > -11) and
                (-par^.level - Integer(wgpiLevel0) - 1 = Integer(i)) then
                Result := Integer(i) } ;
            end;
          wpgiComment:
            begin
              // if paprHasDescription in par^.prop then Result := Integer(i);
            end;
          wpgiBookmark:
            begin
              if par.HasObjects(false, [wpobjBookmark]) then
                 Result := Integer(i);
            end;
        {  wpgiCursor:  already handled !
            begin
              if par = FEditBox.Memo.active_paragraph then Result := Integer(i);
            end;   }
        end;
      if Result >= 0 then break;
    end;
  end;
end;

constructor TWPGutter.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FUseNumLevel := TRUE;
  FItemList := TList.Create;
  DoubleBuffered := TRUE;
  if TheGutterImages = nil then
  begin
    TheGutterImages := TBitmap.Create;
    TheGutterImages.LoadFromResourceName(Hinstance, 'WPGUT_IMAGES');
  end;
  if TheGutterImagesActive = nil then
  begin
    TheGutterImagesActive := TBitmap.Create;
    TheGutterImagesActive.LoadFromResourceName(Hinstance, 'WPGUT_AIMAGES');
  end;
  ControlStyle := ControlStyle - [csAcceptsControls, csSetCaption];
  // Color := TheGutterImages.Canvas.Pixels[0, 0];
  Color := clWhite;
  Height := 100;
  Width := 16;
  Font.Name := 'Arial'; // TT for zooming !
  Font.Size := 10;
  // 1. Group - paragraph, +, - and index
  PaintImages := [wpgiHasClosedChildren, wpgiHasOpenChildren, wgpiIndexParagraph];
  ActiveImages := [wpgiHasClosedChildren, wpgiHasOpenChildren,
    wgpiArrowDown, wgpiArrowLeft, wgpiIndexParagraph, wgpiStdParagraph,
    wgpiProtected, wgpiNotProtected, wgpiHasStyle, wpgiComment, wpgiBookmark];
  PaintImagesSecond := [wpgiCursor];
  FColumnWidth := 10;
  BorderStyle := bsNone;
  BevelInner := bvNone;
  BevelOuter := bvNone;
  {$IFNDEF VER100}
  {$IFNDEF VER110}
  DoubleBuffered := TRUE;
  {$ENDIF}
  {$ENDIF}
end;

destructor TWPGutter.Destroy;
var
  i: Integer;
begin
  for i := 0 to FItemList.Count - 1 do TObject(FItemList[i]).Free;
  FItemList.Free;
  inherited Destroy;
end;

// Paints only images which can switch state in FActiveImages

procedure TWPGutter.PaintItem(row, col: Integer; active: Boolean);
var
  item: TWPGutterItem;
  source: TBitmap;
  num, xpos: Integer;
begin
  if (row >= 0) and (row < FItemList.Count) and (col >= 0) and (col <= 2) then
  begin
    item := TWPGutterItem(FItemList[row]);
    num := item.elements[col];
    if (num >= 0) and (TWPGutterImage(num) in FActiveImages) then
    begin
      if active then
        source := TheGutterImagesActive
      else source := TheGutterImages;
      xpos := col * FColumnWidth;
      Canvas.CopyRect(Rect(xpos, item.y, xpos + 10, item.y + 10),
        source.Canvas,
        Rect(num * 10, 0, num * 10 + 10, 10));
    end;
  end;
end;

procedure TWPGutter.Paint;
var
  ny, y, i, h, row, typ, x, linnr: Integer;
  par: TParagraph;
  lin : PTLine;
  // Column 0..2, ypos any, num : 0..wpgiCurrent
  procedure PaintImage(COLUMN, YPOS, NUM: INTEGER);
  var
    xpos: Integer;
    item: TWPGutterItem;
  begin
    if row >= FItemList.Count then
    begin
      item := TWPGutterItem.Create;
      item.elements[0] := -1;
      item.elements[1] := -1;
      item.elements[2] := -1;
      FItemList.Add(item);
    end else item := TWPGutterItem(FItemList[row]);
    item.y := ypos;
    item.parnum := par.Number;
    item.autoid := par;
    item.elements[column] := num;
    xpos := column * FColumnWidth;
    Canvas.CopyRect(Rect(xpos, ypos, xpos + 10, ypos + 10),
      TheGutterImages.Canvas,
      Rect(num * 10, 0, num * 10 + 10, 10));
  end;
  var px,py,pw,ph, aLineOffset : Integer;
  aText : String;
begin
  // Initialze our memory
  for i := 0 to FItemList.Count - 1 do
  begin
    for y := 0 to 2 do
      TWPGutterItem(FItemList[i]).elements[y] := -1;
    TWPGutterItem(FItemList[i]).parnum := 0;
    TWPGutterItem(FItemList[i]).y := -MaxInt;
  end;

  // Paint all items and store the position
  if FEditBox <> nil then
  begin
    Canvas.Font.Assign(Font);
    Canvas.Brush.Style := bsClear;
    FActiveParagraph := FEditBox.ActiveParagraph;
    if (FActiveParagraph<>nil) and (FActiveParagraph.ParentRow<>nil) then
         FActiveFirstParagraph := FActiveParagraph.ParentRow.ColFirst
    else FActiveFirstParagraph := FActiveParagraph;
    if FShowLineNumbers and (FEditBox.Zooming<100) then
        Canvas.Font.Height := MulDiv(Canvas.Font.Height,FEditBox.Zooming,100);
    h := Canvas.TextHeight('1');
    y := -h;
    par := FEditBox.TopVisiblepar;
    
    row := 0;
    while par <> nil do
    begin

    if FShowLineNumbers then
    begin
       linnr := par.LineStartNr+1;
    end else linnr := 0;

      typ := GetParItem(par, FPaintImages);

      FEditBox.GetTextScreenRect(par,0,px,py,pw,ph);

      // inc(py, (ph mod 12) div 2);

      x := 1;
      if typ >= 0 then
      begin
        PaintImage(0, py, typ);
      end;
      if FPaintImages<>[] then x := 12;

      typ := GetParItem(par, FPaintImagesSecond);
      if typ >= 0 then
      begin
        PaintImage(1, py, typ);
      end;
      if FPaintImagesSecond<>[] then x := 22;

      typ := GetParItem(par, FPaintImagesThird);
      if typ >= 0 then
      begin
        PaintImage(2, py, typ);
      end;
      if FPaintImagesThird<>[] then x := 22;

      if FShowLineNumbers and
         (par.ParagraphType in [wpIsSTDPar,wpIsHTML_DIV,wpIsHTML_LI,
                   wpIsHTML_CODE,wpIsXMLTag,wpIsXMLComment]) then
      begin
        lin := 0;
        while lin<par.LineCount do
        begin
          aLineOffset := par.LineOffset(lin);
          FEditBox.GetTextScreenRect(par,aLineOffset ,px,ny,pw,ph);
          if ny>=y-2 then
          begin
             {$IFDEF BOLDCURRPAR}
             if par = FActiveParagraph then
                  Canvas.Font.Style := [fsBold]
             else Canvas.Font.Style := [];
             {$ENDIF}
             aText := IntToStr(linnr);
             if assigned(FOnCalcLineNumber) then
                FOnCalcLineNumber(Self, par, aLineOffset, lin, aText );
             Canvas.TextOut(x, ny, aText);
             y := ny+h;
          end;
          inc(linnr);
          inc(lin);
        end;
      end;
      inc(row);

      if {(par.ParagraphType in [wpIsXMLTopLevel, wpIsXMLSubLevel,
                                wpIsXMLDataLevel,wpIsReportGroup]) and }
         (paprIsCollapsed in par.prop) then
         par := par.NextPar
      else par := par.nextpardown;

      if (par = nil) or
        (py > FEditBox.Height) then break;
    end;
  end;
  // Delete unnecessary memory entries
  i := FItemList.Count - 1;
  while i > row do
  begin
    TObject(FItemList[i]).Free;
    FItemList.Delete(i);
    dec(i);
  end;
end;

procedure TWPGutter.ChangeCurrentPar;
begin

end;

procedure TWPGutter.ChangeDisplay;
begin
  invalidate;
end;

procedure TWPGutter.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FEditBox) then
  begin
    FEditBox := nil;
    invalidate;
  end;
end;

procedure TWPGutter.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Enabled then
  begin
    FActive := TRUE;
    FActiveItemYPos := -1;
    FActiveItem := -1;
    FActiveColumn := -1;
  end;
end;

procedure TWPGutter.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FActive and (FActiveItem >= 0) and (FActiveColumn >= 0) then
    PaintItem(FActiveItem, FActiveColumn, false);
  FActive := FALSE;
end;

procedure TWPGutter.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TWPGutter.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  i, activerowcol, activerow: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  if FActive then
  begin
    activerowcol := X div FColumnWidth;
    if activerowcol > 2 then activerowcol := -1;
    activerow := -1;
    for i := 0 to FItemList.Count - 1 do
      if (TWPGutterItem(FItemList[i]).y <= y) and
        (TWPGutterItem(FItemList[i]).y + 10 > y) then
      begin
        activerow := i;
        break;
      end;
    if (activerow <> FActiveItem) or (activerowcol <> FActiveColumn) then
    begin
      if (FActiveItem >= 0) and (FActiveColumn >= 0) then
        PaintItem(FActiveItem, FActiveColumn, false);
      if (activerow >= 0) and (activerowcol >= 0) then
        PaintItem(activerow, activerowcol, true);
    end;
    FActiveItem := activerow;
    FActiveColumn := activerowcol;
    FActiveItemYPos := y;
  end;
end;

procedure TWPGutter.Click;
var
  item: TWPGutterItem; typ: TWPGutterImage;  done : Boolean;
begin
  if FActive and (FActiveItem >= 0) and (FActiveColumn >= 0) and
    (FActiveItem < FItemList.Count) and (FEditBox <> nil) then
  begin
    item := TWPGutterItem(FItemList[FActiveItem]);
    if item.elements[FActiveColumn] >= 0 then
    begin
      typ := TWPGutterImage(item.elements[FActiveColumn]);
      done := FALSE;

      if assigned(FOnItemClick) then
           FOnItemClick(Self, item.parnum, typ, done);

      if not done then
      case typ of
        wpgiHasClosedChildren, wgpiArrowDown:
          begin
            if item.autoid<>nil  then
            begin
                exclude( item.autoid.prop, paprIsCollapsed);
                FEditBox.Refresh;
            end;
          end;
        wpgiHasOpenChildren, wgpiArrowLeft:
          begin
            if item.autoid<>nil  then
            begin
                include( item.autoid.prop, paprIsCollapsed);
                FEditBox.Refresh;
            end;
          end;
      {  wgpiArrowDown;
        begin
        end;
        wgpiArrowLeft:
          begin
          end;   }
        wgpiIndexParagraph:
          begin
            FEditBox.CurrAttr.OutlineMode := FALSE;
          end;
        wgpiStdParagraph:
          begin
            FEditBox.CurrAttr.OutlineMode := TRUE;
          end;
        wgpiProtected:
          begin
            FEditBox.CurrAttr.ParProtect := FALSE;
          end;
        wgpiNotProtected:
          begin
            FEditBox.CurrAttr.ParProtect := TRUE;
          end;
        wgpiHasStyle:
          begin
            // Open Style Dialog
          end;
        wgpiLevel0, wgpiLevel1, wgpiLevel2, wgpiLevel3, wgpiLevel4,
        wgpiLevel5, wgpiLevel6, wgpiLevel7, wgpiLevel8, wgpiLevel9:
          begin
            // Nothing
          end;
        wpgiComment:
          begin
            // if paprHasDescription in par^.prop then
            // Change Comment
          end;
        wpgiBookmark:
          begin
            // if paprHasBookmark in par^.prop then
            // Change Bookmark
          end;
        wpgiCursor:
          begin
            //
          end;
      end;
    end;
  end;
end;

procedure TWPGutter.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
end;

initialization
  TheGutterImages := nil;
  TheGutterImagesActive := nil;

finalization
  FreeAndNil(TheGutterImages);
  FreeAndNil(TheGutterImagesActive);


end.

