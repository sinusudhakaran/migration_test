unit WPPrvFrm;
{ -----------------------------------------------------------------------------
  WPTools Version 5
  WPTools - Copyright (C) 2004 by wpcubed GmbH      -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  This unit uses the TWPPreview component to display a page preview
  The dialog for version 4 required a scrollbox, version 5 simply
  uses the TWPPreview component. The TWPFiler is not supported anymore
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, WPUtil,
  Buttons, ComCtrls, WPRTEDefs, WPCTRMemo, WPRTEPaint, WPCTRRich, WPPanel, WPTbar,
  ToolWin, ImgList;

type
  TWPPvZoomMode = (wp500Percent, wp200Percent, wp150Percent, wp100Percent, wp75Percent, wp50Percent,
    wp25Percent,  wp10Percent, wpPvFullWidth,wpPvFullPage, wpPvDoublePage);

  {$IFNDEF T2H}
  TWPPreviewDlg = class;
  TWPPreviewForm = class(TWPShadedForm)
    Timer1: TTimer;
    Panel1: TPanel;
    ZoomValue: TLabel;
    Bevel1: TBevel;
    WPPreview1: TWPPreview;
    ImageList1: TImageList;
    ToolPanel: TPanel;
    cbxZoomModes: TComboBox;
    grpStatusButtons: TToolBar;
    btnClose: TToolButton;
    btnEditMode: TToolButton;
    btnPrint: TToolButton;
    ImageList2: TImageList;
    btnPrintSetup: TToolButton;
    btnSaveExport: TToolButton;
    grpPageButtons: TToolBar;
    btnFirstPage: TToolButton;
    btnPrevPage: TToolButton;
    NumPages: TLabel;
    btnNextPage: TToolButton;
    btnLastPage: TToolButton;
    PageNoParent: TPanel;
    ToolButton2: TToolButton;
    Bevel2: TBevel;
    btnMail: TToolButton;
    btnSavePDF: TToolButton;
    procedure FormActivate(Sender: TObject);
    procedure WPPreview1ChangeOptions(Sender: TObject);
    procedure WPPreview1ChangePagenumber(Sender: TObject);
    procedure WPPreview1Close(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnExitClick(Sender: TObject);
    procedure btnSaveExportClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure NumPagKeyPress(Sender: TObject; var Key: Char);
    procedure btnPrintSetupClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnEditModeClick(Sender: TObject);
    procedure cbxZoomModesChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure cbxZoomModesCloseUp(Sender: TObject);
    procedure btnPrevPageClick(Sender: TObject);
    procedure btnNextPageClick(Sender: TObject);
    procedure btnLastPageClick(Sender: TObject);
    procedure btnFirstPageClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure WPPreview1UpdateExternScrollbar(Sender: TWPCustomRtfEdit;
      ScrollBar: TScrollStyle; Range, Page, Pos: Integer);
  protected
    FMinWidth, FMinHeight: Integer;
    FParentCtrl: TWPPreviewDlg;
    PageNO: TEdit;
    FResizeReorder, FInEditMode, FLockZoom : Boolean;
    function Incr: Integer;
    procedure UpdateCbxZoom;
    procedure WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
  public

  end;
  {$ENDIF}

  TWPPreviewDlgPrepare = procedure(Sender : TWPCustomAttrDlg;
    Dialog  : TWPPreviewForm;
    Preview : TWPPreview) of Object;

  {:: This dialog can be used to display a preview of the text in a TWPRichText or TWPCustomRTFEdit
    component. Simply assign the property 'EditBox'.
    If the editor set the property WordWrap to TRUE the preview dialog will create a temporary
    editor and assign the text. <br>
    You can use the event OnPrepareDlg to modify the dialog on the fly, for example change the
    images (ImageList1) or set hints.<br><br>
    Please place a call to <b>WPPreviewDlg1.Close;</b> in the OnClose event
    of the form which calls the preview dialog to avoid a GPF when closing that form
    while the dialog is still open (it can be non-modal!) }
  TWPPreviewDlg = class(TWPCustomAttrDlg)
  private
  {$IFNDEF T2H}
    dia: TWPPreviewForm;
    FPosition: TPosition;
    FAllowEditMode : Boolean;
    FCaption: string;
    FLeft, FTop, FWidth, FHeight: Integer;
    FOnPrepareDlg : TWPPreviewDlgPrepare;
    FMinWidth, FMinHeight: Integer;
    FWindowState: TWindowState;
    FZoomMode: TWPPvZoomMode;
    FViewOptions : TWPViewOptions;
    FSinglePageMode : Boolean;
    FModal: Boolean;
    FOnPrintClick, FOnSaveClick: TNotifyEvent;
    FDisabledDialogs : TWPCustomRtfEditDialogs;
    procedure SetDisabledDialogs(x : TWPCustomRtfEditDialogs);
    procedure SetSinglePageMode(x : Boolean);
  {$ENDIF}
  protected
  {$IFNDEF T2H}
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  {$ENDIF}
  public
  {$IFNDEF T2H}
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: Boolean; override;
    function CurrentZooming:Integer;
    procedure Close; override;
  {$ENDIF}
  published
    property EditBox;
    //property WPFiler: TWPCustomRTFFiler read FFiler write SetFiler;
    {:: This event can be used to set certain properties in the TWPPreview Component.
    You can use it to modify the ViewOptions. }
    property OnPrepareDlg : TWPPreviewDlgPrepare read FOnPrepareDlg write FOnPrepareDlg;
    property ViewOptions : TWPViewOptions read FViewOptions write FViewOptions;
    property Modal: Boolean read FModal write FModal default TRUE;
    property Caption: string read FCaption write FCaption;
    property DefaultLeft: Integer read FLeft write FLeft;
    property DefaultTop: Integer read FTop write FTop;
    property DefaultPosition: TPosition read FPosition write FPosition;
    property DefaultWidth: Integer read FWidth write FWidth;
    property DefaultHeight: Integer read FHeight write FHeight;
    property MinHeight: Integer read FMinHeight write FMinHeight;
    property MinWidth: Integer read FMinWidth write FMinWidth;
    property ZoomMode: TWPPvZoomMode read FZoomMode write FZoomMode;
    property WindowState: TWindowState read FWindowState write FWindowState;
    property OnSaveClick: TNotifyEvent read FOnSaveClick write FOnSaveClick;
    property OnPrintClick: TNotifyEvent read FOnPrintClick write FOnPrintClick;
    {:: This property selects which buttons should not be displayed in the preview dialog }
    property DisabledDialogs : TWPCustomRtfEditDialogs read FDisabledDialogs write SetDisabledDialogs;
    {:: Use this property to enabled and disable the button to activate edit mode.
        Please note that the preview can only be editable if the editor component
        it is attached to is visible! }
    property AllowEditMode : Boolean read FAllowEditMode write FAllowEditMode default FALSE;
    {:: Use this property if you only want to see one page at a time (like in old preview dialogs) }
    property SinglePageMode : Boolean read FSinglePageMode write SetSinglePageMode default FALSE;

  end;


procedure WPShowPreview(Editor: TWPCustomRTFEdit; modal: Boolean);


implementation

{$R *.DFM}
var
  WPPreviewForm: TWPPreviewForm;

procedure WPShowPreview(Editor: TWPCustomRTFEdit; modal: Boolean);
begin
  if WPPreviewForm = nil then WPPreviewForm := TWPPreviewForm.Create(Application);
  WPPreviewForm.WPPreView1.WPRichText := Editor;
  WPPreviewForm.WPPreView1.AssignPrintProperties(Editor);
  if modal then
  begin
    WPPreviewForm.Close;
    WPPreviewForm.ShowModal;
  end
  else
    WPPreviewForm.Show;
end;

constructor TWPPreviewDlg.Create(AOwner: TComponent);
begin
  inherited Create(AOWner);
  Caption := '';
  DefaultPosition := poScreenCenter;
  MinWidth := 220;
  MinHeight := 220;
  DefaultLeft := 10;
  DefaultTop := 10;
  DefaultWidth := 319;
  DefaultHeight := 426;
  ZoomMode := wp100Percent;
  Modal := TRUE;
  FViewOptions := [wpHideSelection,wpDisableMisspellMarkers,wpDontGrayHeaderFooterInLayout];
  SetDisabledDialogs([]);
end;

procedure TWPPreviewDlg.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
end;

destructor TWPPreviewDlg.Destroy;
begin
  if dia <> nil then
  begin
    dia.FParentCtrl := nil;
    dia.Close;
    dia := nil;
  end;
  inherited Destroy;
end;

function TWPPreviewDlg.CurrentZooming:Integer;
begin
  if(dia<>nil) then Result :=  dia.WPPreview1.Zooming
  else Result := 100;
end;

procedure TWPPreviewDlg.Close; 
begin
  if dia<>nil then
  begin
      dia.Close;
      FreeAndNil(dia);
  end;
end;

procedure TWPPreviewDlg.SetDisabledDialogs(x : TWPCustomRtfEditDialogs);
begin
   FDisabledDialogs := x + [wpStartSave,wpdiaLoad,wpdiaThesaurus,wpdiaFind, wpdiaReplace,
      wpStartPrint, // starts printing without dialog
      wpdiaCanClose, wpStartNewDocument]; 
end;

procedure TWPPreviewDlg.SetSinglePageMode(x : Boolean);
begin
  FSinglePageMode := x;
  if dia<>nil then
  begin
    dia.WPPreview1.SinglePageMode := FSinglePageMode;
  end;
end;

function TWPPreviewDlg.Execute: Boolean;
var
  temp: TWPCustomRtfEdit;
  mem : TMemoryStream;
begin
  Result := FALSE;
  if assigned(FEditBox) then
  begin
    if dia = nil then
      dia := TWPPreviewForm.Create(Self);

    dia.FParentCtrl := Self;

    if Caption <> '' then dia.Caption := Caption;

    if FWindowState = wsMaximized then
    begin
       dia.Position := poDesigned;
       dia.WindowState := wsMaximized;
    end else
    begin
      dia.Position := DefaultPosition;
      dia.WindowState := FWindowState;
    end;
    dia.Left := FLeft;
    dia.Top := FTop;
    dia.Width := FWidth;
    dia.Height := FHeight;
    dia.FMinWidth := FMinWidth;
    dia.FMinHeight := FMinHeight;

    dia.WPPreview1.SinglePageMode := FSinglePageMode;

    dia.btnSaveExport.Visible :=
      (not (wpdiaSaveAs in FDisabledDialogs)
      and ((wpdiaSaveAs in FEditBox.AvailableDialogs)) or Assigned(FOnSaveClick));
    dia.btnPrint.Visible  :=
      (not (wpDiaPrint in FDisabledDialogs)
      and (wpDiaPrint in FEditBox.AvailableDialogs))
      or Assigned(FOnPrintClick);
    dia.btnPrintSetup.Visible  :=
      not (wpdiaPrinterSetup in FDisabledDialogs)
      and (wpdiaPrinterSetup in FEditBox.AvailableDialogs);
    dia.btnSavePDF.Visible  :=
      not (wpdiaSaveAsPDF in FDisabledDialogs)
      and (wpdiaSaveAsPDF in FEditBox.AvailableDialogs);
    dia.btnMail.Visible  :=
      not (wpdiaSendByEMail in FDisabledDialogs)
      and (wpdiaSendByEMail in FEditBox.AvailableDialogs);
    dia.btnEditMode.Visible  := FAllowEditMode;

    if FEditBox.WordWrap then
    begin
      temp := TWPCustomRichText.Create(dia);

      temp.AssignPrintProperties(FEditBox);
      temp.SetBounds(-5, -5, 4, 4);
      temp.Parent := dia;
      temp.ViewOptions := FEditBox.ViewOptions;
      temp.WordWrap := FALSE;
      mem := TMemoryStream.Create;
      try
        FEditBox.SaveToStream(mem, 'WPTOOLS');
        mem.Position := 0;
        temp.LoadFromStream(mem, 'WPTOOLS');
        temp.CPPosition := FEditBox.CPPosition;
      finally
        mem.Free;
      end;
      temp.ReformatAll(false,false);
      dia.WPPreview1.WPRichText := temp;
    end
    else
    begin
      dia.WPPreview1.WPRichText := FEditBox;
      dia.WPPreView1.AssignPrintProperties(FEditBox);
    end;
    dia.Timer1.Enabled := TRUE;

    dia.WPPreview1.ViewOptions := FViewOptions;

    if assigned(FOnPrepareDlg) then
       FOnPrepareDlg(Self, dia, dia.WPPreview1 );

    if FCreateAndFreeDialog or not MayOpenDialog(dia) then
      dia.Free
    else
    try
      if FModal then
      begin
        dia.ShowModal;
        dia := nil;
      end
      else
        dia.Show;
      Result := TRUE;
    finally
      // NO: Done in the form !
      // dia.Free;
      // NO! temp.Free;
    end;
  end;
end;

procedure TWPPreviewForm.FormActivate(Sender: TObject);
begin
  WPPreview1ChangeOptions(Self);
  WPPreview1.invalidate;
end;

procedure TWPPreviewForm.WPPreview1ChangePagenumber(Sender: TObject);
begin
  PageNo.Text := IntToStr(WPPreview1.PageNumber + 1);
  //if FParentCtrl.EditBox<>nil then
  //      NumPages.Caption := '/' + IntToStr(FParentCtrl.EditBox.PageCount) else
  // V5.19.6 now also works in FSinglePageMode:
  NumPages.Caption := '/' + IntToStr(WPPreview1.PageCount);
end;

procedure TWPPreviewForm.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
var
  MinMax: PMinMaxInfo;
begin
  inherited;
  MinMax := Message.MinMaxInfo;
  if FMinWidth > 0 then MinMax^.ptMinTrackSize.X := FMinWidth;
  if FMinHeight > 0 then MinMax^.ptMinTrackSize.Y := FMinHeight;
end;

function TWPPreviewForm.Incr: Integer;
begin
  Result := WPPreview1.Columns;
end;

procedure TWPPreviewForm.WPPreview1ChangeOptions(Sender: TObject);
begin
          (*
  if (ppmStretchWidth in WPPreview1.PrintMode) or
    (ppmStretchHeight in WPPreview1.PrintMode) then
  begin
    ScrollBox1.HorzScrollBar.Visible := FALSE;
    ScrollBox1.VertScrollBar.Visible := FALSE;
    ScrollBox1.HorzScrollBar.Position := 0;
    ScrollBox1.VertScrollBar.Position := 0;
    WPPreview1.BorderStyle := bsNone;
    WPPreview1.SetBounds(0, 0, ScrollBox1.ClientWidth - 1, ScrollBox1.ClientHeight - 1);
  end
  else
  begin
    // 'Landscape' is used here!
    WPPreview1.Width := WPPreview1.CurrentWidth;
    WPPreview1.Height := WPPreview1.CurrentHeight;
    ScrollBox1.HorzScrollBar.Visible := TRUE;
    ScrollBox1.VertScrollBar.Visible := TRUE;
    WPPreview1.BorderStyle := bsSingle;
  end;    *)
end;


{ This is executed when the user clicks on the EXIT or Close button }

procedure TWPPreviewForm.WPPreview1Close(Sender: TObject);
begin
  Close;
end;

procedure TWPPreviewForm.UpdateCbxZoom;
begin
   WPPreview1.Readonly := not FInEditMode;
   WPPreview1.CaretDisabled :=  WPPreview1.Readonly;
   if WPPreview1.Readonly then
   begin
        WPPreview1.ViewOptions :=  WPPreview1.ViewOptions + [wpHideSelection,wpCenterPaintPages];
        WPPreview1.EditOptionsEx := WPPreview1.EditOptionsEx + [wpDisableSelection, wpDisableCaret];
   end
   else
   begin
       WPPreview1.ViewOptions :=  WPPreview1.ViewOptions - [wpHideSelection,wpCenterPaintPages];
       WPPreview1.EditOptionsEx := WPPreview1.EditOptionsEx - [wpDisableSelection, wpDisableCaret];
   end;

   FLockZoom := TRUE;
   if WPPreview1.AutoZoom=wpAutoZoomWidth then
       cbxZoomModes.ItemIndex := 8
   else if (WPPreview1.LayoutMode = wplayFullLayout) and
           (WPPreview1.Columns=2) then
                cbxZoomModes.ItemIndex := 10
   else if (WPPreview1.AutoZoom = wpAutoZoomFullPage) and
           (WPPreview1.Columns=1) then
       cbxZoomModes.ItemIndex := 9
   else cbxZoomModes.Text := IntToStr(WPPreview1.CurrentZooming) + '%';
   FLockZoom := FALSE;
   ZoomValue.Caption := IntToStr(WPPreview1.CurrentZooming) + '%';
end;




procedure TWPPreviewForm.FormShow(Sender: TObject);
begin
  grpPageButtons.Width := ToolButton2.Left + ToolButton2.Width;
    cbxZoomModes.ItemIndex := Integer(FParentCtrl.FZoomMode);
    cbxZoomModesChange(nil);
  UpdateCbxZoom; 
  WPPreview1ChangePagenumber(nil);
  WPPreview1.Paint;
  //WPPreview1.UpdateLayout;
  cbxZoomModes.Left := grpStatusButtons.Width + 1;
end;

procedure TWPPreviewForm.FormDestroy(Sender: TObject);
begin
  if FParentCtrl <> nil then
  begin
    FParentCtrl.dia := nil;
    FParentCtrl.FLeft := Left;
    FParentCtrl.FTop := Top;
    FParentCtrl.FWidth := Width;
    FParentCtrl.FHeight := Height;
    FParentCtrl.FPosition := poDesigned;
  end;
end;

procedure TWPPreviewForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if FParentCtrl <> nil then // Better save ...
  begin
    FParentCtrl.dia := nil;
    FParentCtrl.FLeft := Left;
    FParentCtrl.FTop := Top;
    FParentCtrl.FWidth := Width;
    FParentCtrl.FHeight := Height;
    FParentCtrl.FPosition := poDesigned;
    FParentCtrl := nil;
  end;
  Action := caFree;
end;

procedure TWPPreviewForm.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TWPPreviewForm.btnSaveExportClick(Sender: TObject);
begin
  if assigned(FParentCtrl.FOnSaveClick) then
    FParentCtrl.FOnSaveClick(FParentCtrl)
  else if (FParentCtrl<>nil) and (FParentCtrl.EditBox<>nil) then
     FParentCtrl.EditBox.OpenDialog(wpdiaSaveAs);
  btnSaveExport.Down := FALSE;
end;

type
  TPageNO = class(TEdit)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;

procedure TPageNO.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style and not WS_BORDER;
    Style := Style or ES_RIGHT;
    ExStyle := ExStyle and not WS_EX_CLIENTEDGE;
  end;
end;

procedure TWPPreviewForm.FormCreate(Sender: TObject);
begin
  PageNO := TPageNO.Create(PageNoParent);
  PageNO.Parent := PageNoParent;
  PageNO.Ctl3d := FALSE;
  PageNO.Top := 0;
  PageNO.Height := PageNoParent.Height;
  PageNO.Color := Panel1.Color;
  PageNO.Font.Style := [fsUnderline];
  PageNO.Left := 1;
  PageNo.Width := PageNoParent.Width;
  PageNO.OnKeyPress := NumPagKeyPress;
  WPPreview1.Align := alClient;
  WPPreview1.LayoutMode := wplayFullLayout;
  WPPreview1.Columns := 1;
  WPPreview1.Rows := 1;
  ActiveControl := PageNO;
end;


procedure TWPPreviewForm.NumPagKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  try
    if PageNO.Text = '' then
      WPPreview1.PageNumber := 0
    else
      WPPreview1.PageNumber := StrToInt(PageNO.Text) - 1;
    Key := #0;
    PageNO.SelStart := 10;
  except
  end
  else if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

procedure TWPPreviewForm.btnPrintSetupClick(Sender: TObject);
begin
  FParentCtrl.FEditBox.OpenDialog(wpdiaPrinterSetup);
end;

procedure TWPPreviewForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TWPPreviewForm.btnPrintClick(Sender: TObject);
begin
  if Assigned(FParentCtrl.FOnPrintClick) then
         FParentCtrl.FOnPrintClick(FParentCtrl)
  else   FParentCtrl.FEditBox.OpenDialog(wpdiaPrint);
  btnPrint.Down := FALSE;
end;

procedure TWPPreviewForm.btnEditModeClick(Sender: TObject);
begin
   FInEditMode := not FInEditMode;
   btnEditMode.Down := FInEditMode;
   UpdateCbxZoom;
   WPPreview1.Repaint;
end;

procedure TWPPreviewForm.cbxZoomModesChange(Sender: TObject);
var i, z : Integer;
begin
  if FLockZoom then exit;
  z := StrToIntDef(cbxZoomModes.Text,-1);
  FResizeReorder := FALSE;
  Timer1.Enabled := FALSE;
  for i:=0 to cbxZoomModes.Items.Count-1 do
  begin
    if CompareText( cbxZoomModes.Items[i],cbxZoomModes.Text)=0 then
    begin
      case i of
         0 : z := 500;  // 500%
         1 : z := 200;  // 200%
         2 : z := 150;  // 150%
         3 : z := 100;  // 100%
         4 : z := 75;  // 75%
         5 : z := 50;  // 50%
         6 : z := 25;  // 25%
         7 : z := 10;  // 10%
         8 :  // Page Width
         begin
           WPPreview1.LayoutMode := wplayFullLayout;
           WPPreview1.AutoZoom := wpAutoZoomWidth;
           WPPreview1.Columns := 1;
         end;
         9 :   // Full Page
         begin
           WPPreview1.LayoutMode := wplayFullLayout;
           WPPreview1.AutoZoom := wpAutoZoomFullPage;
           WPPreview1.Columns := 1;
         end;
         10 :   // Two Pages
         begin
           WPPreview1.LayoutMode := wplayFullLayout;
           WPPreview1.AutoZoom := wpAutoZoomFullPage;
           WPPreview1.Columns := 2;
         end;
      end;
      FParentCtrl.ZoomMode := TWPPvZoomMode(i);
      break;
    end;
  end;
  if (z>0) and (z<=10) then
  begin
     WPPreview1.AutoZoom := wpAutoZoomFullPage;
     WPPreview1.LayoutMode := wpThumbNailView;
  end else
  if (z>0) and (z<=50) then
  begin
     WPPreview1.AutoZoom := wpAutoZoomAdjustColumnCount; // wpAutoZoomOff;
     WPPreview1.LayoutMode := wplayFullLayout; 
     WPPreview1.Zooming := z;
    { WPPreview1.Columns := MulDiv( (Width-36) , 1440*(100 div z), Screen.PixelsPerInch) div
        (WPPreview1.Header.PageWidth+360);  }
     FResizeReorder := true;
  end else
  if z>0 then
  begin
     WPPreview1.LayoutMode := wplayFullLayout;
     WPPreview1.AutoZoom := wpAutoZoomOff;
     WPPreview1.Columns := 1;
     WPPreview1.Zooming := z;
  end;
  WPPreview1.PageNumber := WPPreview1.PageNumber;
  WPPreview1.Refresh;
  ZoomValue.Caption := IntToStr(WPPreview1.CurrentZooming) + '%';
end;

procedure TWPPreviewForm.FormResize(Sender: TObject);
begin
  Timer1.Enabled := FResizeReorder;
  ZoomValue.Caption := IntToStr(WPPreview1.CurrentZooming) + '%';
  
end;

procedure TWPPreviewForm.cbxZoomModesCloseUp(Sender: TObject);
begin
   WPPreview1.SetFocus;
end;

procedure TWPPreviewForm.btnPrevPageClick(Sender: TObject);
begin
  WPPreview1.PageNumber := WPPreview1.PageNumber-WPPreview1.Columns;
  WPPreview1ChangePagenumber(nil);
end;

procedure TWPPreviewForm.btnNextPageClick(Sender: TObject);
begin
   WPPreview1.PageNumber := WPPreview1.PageNumber+WPPreview1.Columns;
   WPPreview1ChangePagenumber(nil);
end;

procedure TWPPreviewForm.btnLastPageClick(Sender: TObject);
begin
  WPPreview1.PageNumber := WPPreview1.PageCount-1;
  WPPreview1ChangePagenumber(nil);
end;

procedure TWPPreviewForm.btnFirstPageClick(Sender: TObject);
begin
   WPPreview1.PageNumber := 0;
   WPPreview1ChangePagenumber(nil);
end;

procedure TWPPreviewForm.WPPreview1UpdateExternScrollbar(
  Sender: TWPCustomRtfEdit; ScrollBar: TScrollStyle; Range, Page,
  Pos: Integer);
begin
   WPPreview1ChangePagenumber(nil);
end;

procedure TWPPreviewForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 case Key of
   VK_PRIOR:
   begin
      WPPreview1.PageNumber := WPPreview1.PageNumber-WPPreview1.PageColumns;
      if WPPreview1.SinglePageMode then WPPreview1.SetScrollBarSize(false);
      Key := 0;
   end;
   VK_NEXT:
   begin
      WPPreview1.PageNumber := WPPreview1.PageNumber+WPPreview1.PageColumns;
      if WPPreview1.SinglePageMode then WPPreview1.SetScrollBarSize(false);
      Key := 0;
   end;
   VK_HOME:
   begin
      WPPreview1.PageNumber := 0;
      if WPPreview1.SinglePageMode then WPPreview1.SetScrollBarSize(false);
      Key := 0;
   end;
   VK_END:
   begin
      WPPreview1.PageNumber := MaxInt;
      if WPPreview1.SinglePageMode then WPPreview1.SetScrollBarSize(false);
      Key := 0;
   end;
   else exit;
 end;
 PageNO.Text := IntToStr(WPPreview1.PageNumber+1);
end;



end.

