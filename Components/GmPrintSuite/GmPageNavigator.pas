{******************************************************************************}
{                                                                              }
{                             GmPageNavigator.pas                              }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmPageNavigator;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Buttons, GmPreview, GmClasses, GmConst, GmTypes;

{$I GMPS.INC}

type
  TGmButtonGroup = (gmNavigateGroup, gmEditGroup, gmZoomGroup, gmFitPageGroup, gmUnknownGroup);

  TGmNavigateBtn = (gmFirstPage, gmPrevPage, gmNextPage, gmLastPage,
    gmAddPage, gmDeletePage, gmClear, gmZoomIn, gmZoomOut, gmActualSize,
    gmFitWidth, gmFitHeight, gmFitWholePage);

  TGmNavButtonSet = set of TGmNavigateBtn;

const
  DEFAULT_HINTS: array[TGmNavigateBtn] of string = ('First Page',
                                                    'Previous Page',
                                                    'Next Page',
                                                    'Last Page',
                                                    'Add Page',
                                                    'Delete Current Page',
                                                    'Clear',
                                                    'Zoom In',
                                                    'Zoom Out',
                                                    'Actual Size',
                                                    'Fit Width',
                                                    'Fit Height',
                                                    'Fit Whole Page');
type
  TGmGetNavButtonHint     = procedure(Sender: TObject; Button: TGmNavigateBtn; var Hint: string) of object;
  TGmClickNavButtonEvent  = procedure(Sender: TObject; Button: TGmNavigateBtn) of object;

  TGmPageNavigator = class;

  TGmNavButton = class(TSpeedButton)
  private
    FButtonKind: TGmNavigateBtn;
    FPageNavigator: TGmPageNavigator;
    procedure SetButtonKind(Value: TGmNavigateBtn);
  protected
    property ButtonKind: TGmNavigateBtn read FButtonKind write SetButtonKind;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  // *** TGmPageNavigator ***

  TGmPageNavigator = class(TGmWinControl)
  private
    FAutoSize: Boolean;
    FBorderWidth: integer;
    FBtnHeight: integer;
    FBtnWidth: integer;
    FFlat: Boolean;
    FGroupButtons: Boolean;
    FGroupSpacing: integer;
    FPreview: TGmPreview;
    FShowButtonHints: Boolean;
    FVisibleButtons: TGmNavButtonSet;
    // events...
    FOnClickNavButton: TGmClickNavButtonEvent;
    FOnGetButtonHint: TGmGetNavButtonHint;
    function BevelWidth: integer;
    function GetTotalWidth: integer;
    {$IFDEF DELPHI3}
    procedure AdjustSize;
    {$ENDIF}
    procedure FreeButtons;
    procedure RedrawButtons;
    procedure SetBorderWidth(Value: integer);
    procedure SetBtnHeight(AHeight: integer);
    procedure SetBtnWidth(AWidth: integer);
    procedure SetFlat(AValue: Boolean);
    procedure SetGroupButtons(Value: Boolean);
    procedure SetGroupSpacing(Value: integer);
    procedure SetPreview(APreview: TGmPreview);
    procedure SetShowButtonHints(Value: Boolean);
    procedure SetVisibleButtons(AButtons: TGmNavButtonSet);
    procedure UpdateButtonStates;
  protected
    procedure ButtonClicked(Sender: TObject);
    procedure BeginUpdate(var Message: TMessage); message GM_BEGINUPDATE;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure EndUpdate(var Message: TMessage); message GM_ENDUPDATE;
    procedure Loaded; override;
    procedure NumPagesChanged(var Message: TMessage); message GM_PAGE_COUNT_CHANGED;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure PageChanged(var Message: TMessage); message GM_PAGE_NUM_CHANGED;
    procedure PreviewUpdated(var Message: TMessage); message GM_PREVIEW_UPDATED;
    procedure PreviewZoomChanged(var Message: TMessage); message GM_PREVIEW_ZOOM_CHANGED;
    procedure NavigatorResize(var Message: TMessage); message WM_SIZE;
    procedure SetAutoSize(Value: Boolean); {$IFDEF D6+} override; {$ENDIF}
    procedure SetCaption(var Message: TMessage); message WM_SETTEXT;
  public
    Buttons: array[TGmNavigateBtn] of TGmNavButton;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property AutoSize: Boolean read FAutoSize write SetAutoSize default False;
    property BorderWidth: integer read FBorderWidth write SetBorderWidth default 8;
    property ButtonHeight: integer read FBtnHeight write SetBtnHeight default 34;
    property ButtonWidth: integer read FBtnWidth write SetBtnWidth default 34;
    property Flat: Boolean read FFlat write SetFlat default False;
    property GroupButtons: Boolean read FGroupButtons write SetGroupButtons default True;
    property GroupSpacing: integer read FGroupSpacing write SetGroupSpacing default 8;
    property Preview: TGmPreview read FPreview write SetPreview;
    property ShowButtonHints: Boolean read FShowButtonHints write SetShowButtonHints default True;
    property VisibleButtons: TGmNavButtonSet read FVisibleButtons write SetVisibleButtons
      default [gmFirstPage, gmPrevPage, gmNextPage, gmLastPage,
               gmAddPage, gmDeletePage, gmClear, gmZoomIn, gmZoomOut, gmActualSize,
               gmFitWidth, gmFitHeight, gmFitWholePage];
    // events...
    property OnClickButton: TGmClickNavButtonEvent read FOnClickNavButton write FOnClickNavButton;
    property OnGetButtonHint: TGmGetNavButtonHint read FOnGetButtonHint write FOnGetButtonHint;
  end;


implementation

{$R PageNavRes.RES}

function ButtonGroup(AButton: TGmNavigateBtn): TGmButtonGroup;
begin
  case AButton of
    gmFirstPage,
    gmPrevPage,
    gmNextPage,
    gmLastPage    : Result := gmNavigateGroup;
    gmAddPage,
    gmDeletePage,
    gmClear       : Result := gmEditGroup;
    gmZoomIn,
    gmZoomOut,
    gmActualSize  : Result := gmZoomGroup;
    gmFitWidth,
    gmFitHeight,
    gmFitWholePage: Result := gmFitPageGroup;
  else
    Result := gmUnknownGroup;
  end;
end;

constructor TGmNavButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csDesignInteractive];
  FPageNavigator := TGmPageNavigator(AOwner);
end;

procedure TGmNavButton.SetButtonKind(Value: TGmNavigateBtn);
begin
  FButtonKind := Value;
  case Value of
    gmFirstPage   : Glyph.LoadFromResourceName(HInstance, 'FIRST');
    gmPrevPage    : Glyph.LoadFromResourceName(HInstance, 'PREV');
    gmNextPage    : Glyph.LoadFromResourceName(HInstance, 'NEXT');
    gmLastPage    : Glyph.LoadFromResourceName(HInstance, 'LAST');
    gmZoomIn      : Glyph.LoadFromResourceName(HInstance, 'ZOOMIN');
    gmZoomOut     : Glyph.LoadFromResourceName(HInstance, 'ZOOMOUT');
    gmActualSize  : Glyph.LoadFromResourceName(HInstance, 'ACTUALSIZE');
    gmAddPage     : Glyph.LoadFromResourceName(HInstance, 'ADDPAGE');
    gmDeletePage  : Glyph.LoadFromResourceName(HInstance, 'DELETEPAGE');
    gmClear       : Glyph.LoadFromResourceName(HInstance, 'CLEAR');
    gmFitWidth    : Glyph.LoadFromResourceName(HInstance, 'FITWIDTH');
    gmFitHeight   : Glyph.LoadFromResourceName(HInstance, 'FITHEIGHT');
    gmFitWholePage: Glyph.LoadFromResourceName(HInstance, 'FITWHOLEPAGE');
  end;
end;

//------------------------------------------------------------------------------

constructor TGmPageNavigator.Create(AOwner: TComponent);
var
  ICount: TGmNavigateBtn;
begin
  inherited Create(AOwner);
  for ICount := Low(Buttons) to High(Buttons) do
  begin
    Buttons[ICount] := TGmNavButton.Create(Self);
    Buttons[ICount].ButtonKind := ICount;
    Buttons[ICount].OnClick := ButtonClicked;
    Buttons[ICount].Hint := DEFAULT_HINTS[ICount];
    Buttons[ICount].ShowHint := True;
    Buttons[ICount].PopupMenu := PopupMenu;
  end;
  {$IFDEF D4+}
  BevelInner := bvNone;
  BevelOuter := bvNone;
  {$ENDIF}
  BorderWidth := 6;
  Caption := '';
  FAutoSize := False;
  FBtnHeight := 34;
  FBtnWidth := 34;
  FFlat := False;
  FGroupButtons := True;
  FGroupSpacing := 8;
  FShowButtonHints := True;
  FVisibleButtons := [gmFirstPage, gmPrevPage, gmNextPage, gmLastPage,
                      gmAddPage, gmDeletePage, gmClear, gmZoomIn, gmZoomOut, gmActualSize,
                      gmFitWidth, gmFitHeight, gmFitWholePage];
  Width := GetTotalWidth+18;
  Height := FBtnHeight+16;
  UpdateButtonStates; 
end;

destructor TGmPageNavigator.Destroy;
begin
  if Assigned(FPreview) then FPreview.RemoveAssociatedComponent(Self);
  FreeButtons;
  inherited Destroy;
end;

procedure TGmPageNavigator.FreeButtons;
var
  ICount: TGmNavigateBtn;
begin
  for ICount := Low(Buttons) to High(Buttons) do
    Buttons[ICount].Free;
end;

function TGmPageNavigator.BevelWidth: integer;
begin
  if BorderStyle = bsSingle then Result := 4 else Result := 0;
  Inc(Result, 2*BorderWidth);
end;

function TGmPageNavigator.GetTotalWidth: integer;
var
  ICount: TGmNavigateBtn;
  LastGroup: TGmButtonGroup;
begin
  Result := 0;
  LastGroup := gmUnknownGroup;
  for ICount := Low(Buttons) to High(Buttons) do
  begin
    if (ICount in FVisibleButtons) then
    begin
      if LastGroup = gmUnknownGroup then LastGroup := ButtonGroup(ICount);
      Inc(Result, FBtnWidth);
      if (LastGroup <> ButtonGroup(ICount)) and (FGroupButtons) then
        Inc(Result, FGroupSpacing);
      LastGroup := ButtonGroup(ICount);
    end;
  end;
end;

procedure TGmPageNavigator.RedrawButtons;
var
  ICount: TGmNavigateBtn;
  InternalWidth: integer;
  AOrigin: TPoint;
  CurrentX: integer;
  LastGroup: TGmButtonGroup;
begin
  if not HasParent then Exit;
  InternalWidth := GetTotalWidth;

  AOrigin.x := (ClientWidth - InternalWidth) div 2;
  AOrigin.y := ((ClientHeight - FBtnHeight) div 2);
  if AOrigin.x < 0 then AOrigin.x := 0;
  if AOrigin.y < 0 then AOrigin.y := 0;
  CurrentX := AOrigin.x;
  LastGroup := gmNavigateGroup;
  for ICount := Low(Buttons) to High(Buttons) do
  begin
    if (ICount in FVisibleButtons) then
    begin
      if FGroupButtons then
      begin
        if (LastGroup <> ButtonGroup(Buttons[ICount].ButtonKind)) and (CurrentX > 0) then
          Inc(CurrentX, FGroupSpacing);
      end;
      Buttons[ICount].Height := FBtnHeight;
      Buttons[ICount].Width := FBtnWidth;
      Buttons[ICount].Flat := FFlat;
      Buttons[ICount].Left := CurrentX;
      Buttons[ICount].Top := AOrigin.y;
      Inc(CurrentX, FBtnWidth);
      Buttons[ICount].Parent := Self;
      LastGroup := ButtonGroup(Buttons[ICount].ButtonKind);
    end
    else
      Buttons[ICount].Left := Width+1;
  end;
  if FAutoSize then
  begin
    Width  := InternalWidth+BevelWidth;
    Height := FBtnHeight+BevelWidth;
  end;     
end;

procedure TGmPageNavigator.SetAutoSize(Value: Boolean);
begin
  if FAutoSize = Value then Exit;
  FAutoSize := Value;
  RedrawButtons;
end;

procedure TGmPageNavigator.SetCaption(var Message: TMessage);
begin
	//
end;

procedure TGmPageNavigator.SetBorderWidth(Value: integer);
begin
  if FBorderWidth = Value then Exit;
  FBorderWidth := Value;
  RedrawButtons;
end;

procedure TGmPageNavigator.SetBtnHeight(AHeight: integer);
begin
  if FBtnHeight = AHeight then Exit;
  FBtnHeight := AHeight;
  RedrawButtons;
end;

procedure TGmPageNavigator.SetBtnWidth(AWidth: integer);
begin
  if FBtnWidth = AWidth then Exit;
  FBtnWidth := AWidth;
  RedrawButtons;
end;

procedure TGmPageNavigator.SetFlat(AValue: Boolean);
begin
  if FFlat = AValue then Exit;
  FFlat := AValue;
  RedrawButtons;
end;

procedure TGmPageNavigator.SetGroupButtons(Value: Boolean);
begin
  if Value = FGroupButtons then Exit;
  FGroupButtons := Value;
  RedrawButtons;
end;

procedure TGmPageNavigator.SetGroupSpacing(Value: integer);
begin
  if Value = FGroupSpacing then Exit;
  FGroupSpacing := Value;
  RedrawButtons;
end;

procedure TGmPageNavigator.SetPreview(APreview: TGmPreview);
begin
  if Assigned(FPreview) then FPreview.RemoveAssociatedComponent(Self);
  FPreview := APreview;
  if Assigned(FPreview) then FPreview.AddAssociatedComponent(Self);
  UpdateButtonStates;
end;

procedure TGmPageNavigator.SetShowButtonHints(Value: Boolean);
var
  ICount: TGmNavigateBtn;
begin
  if Value = FShowButtonHints then Exit;
  for ICount := Low(Buttons) to High(Buttons) do
    Buttons[ICount].ShowHint := Value;
  FShowButtonHints := Value;
end;

procedure TGmPageNavigator.SetVisibleButtons(AButtons: TGmNavButtonSet);
var
  ICount: TGmNavigateBtn;
begin
  FVisibleButtons := AButtons;
  for ICount := Low(Buttons) to High(Buttons) do
    Buttons[ICount].Visible := (ICount in FVisibleButtons);
  RedrawButtons;
end;

procedure TGmPageNavigator.UpdateButtonStates;
var
  ICount: TGmNavigateBtn;
begin
  if not Assigned(FPreview) then
  begin
    for ICount := Low(TGmNavigateBtn) to High(TGmNavigateBtn) do
      Buttons[ICount].Enabled := False;
    Exit;
  end;
  Buttons[gmFirstPage].Enabled  := (FPreview.CurrentPageNum > 1);
  Buttons[gmPrevPage].Enabled   := (FPreview.CurrentPageNum > 1);
  Buttons[gmNextPage].Enabled   := (FPreview.CurrentPageNum < FPreview.NumPages);
  Buttons[gmLastPage].Enabled   := (FPreview.CurrentPageNum < FPreview.NumPages);
  Buttons[gmAddPage].Enabled    := True;
  Buttons[gmDeletePage].Enabled := True;
  Buttons[gmClear].Enabled      := True;
  Buttons[gmZoomIn].Enabled     := (FPreview.Zoom < FPreview.MaxZoom);
  Buttons[gmZoomOut].Enabled    := (FPreview.Zoom > FPreview.MinZoom);
  Buttons[gmActualSize].Enabled := True;
  Buttons[gmFitHeight].Enabled  := True;
  Buttons[gmFitWidth].Enabled   := True;
  Buttons[gmFitWholePage].Enabled := True;
end;


//------------------------------------------------------------------------------

procedure TGmPageNavigator.CMColorChanged(var Message: TMessage);
begin
  inherited;
  {$IFDEF D4+}
  Perform(CM_BORDERCHANGED, 0, 0);
  {$ENDIF}
end;

procedure TGmPageNavigator.ButtonClicked(Sender: TObject);
var
  ButtonKind: TGmNavigateBtn;
begin
  if not Assigned(FPreview) then Exit;
  ButtonKind := (Sender as TGmNavButton).ButtonKind;
  case ButtonKind of
    gmFirstPage   : FPreview.FirstPage;
    gmPrevPage    : FPreview.PrevPage;
    gmNextPage    : FPreview.NextPage;
    gmLastPage    : FPreview.LastPage;
    gmAddPage     : FPreview.NewPage;
    gmDeletePage  : FPreview.DeleteCurrentPage;
    gmClear       : FPreview.Clear;
    gmZoomIn      : FPreview.ZoomIn;
    gmZoomOut     : FPreview.ZoomOut;
    gmActualSize  : FPreview.Zoom := 100;
    gmFitWidth    : FPreview.FitWidth;
    gmFitHeight   : FPreview.FitHeight;
    gmFitWholePage: FPreview.FitWholePage;
  end;
  if Assigned(FOnClickNavButton) then FOnClickNavButton(Self, ButtonKind);
end;

procedure TGmPageNavigator.BeginUpdate(var Message: TMessage);
begin
  Enabled := False;
end;

procedure TGmPageNavigator.EndUpdate(var Message: TMessage);
begin
  if not FPreview.IsUpdating then
  begin
    Enabled := True;
    UpdateButtonStates;
  end;
end;

procedure TGmPageNavigator.Loaded;
var
  ICount: TGmNavigateBtn;
  ButtonHint: string;
begin
  inherited Loaded;
  if Assigned(FOnGetButtonHint) then
  begin
    for ICount := Low(Buttons) to High(Buttons) do
    begin
      ButtonHint := Buttons[ICount].Hint;
      FOnGetButtonHint(Self, ICount, ButtonHint);
      Buttons[ICount].Hint := ButtonHint;
    end;
  end;
  RedrawButtons;
  UpdateButtonStates;
end;

procedure TGmPageNavigator.NumPagesChanged(var Message: TMessage);
begin
  UpdateButtonStates;
end;

procedure TGmPageNavigator.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FPreview) then Preview := nil;
end;

procedure TGmPageNavigator.PageChanged(var Message: TMessage);
begin
  UpdateButtonStates;
end;

procedure TGmPageNavigator.PreviewUpdated(var Message: TMessage);
begin
  UpdateButtonStates;
end;

procedure TGmPageNavigator.PreviewZoomChanged(var Message: TMessage);
begin
  UpdateButtonStates;
end;

procedure TGmPageNavigator.NavigatorResize(var Message: TMessage);
begin
  inherited;
  RedrawButtons;
end;

//------------------------------------------------------------------------------

end.
