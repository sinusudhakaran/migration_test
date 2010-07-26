unit Wpdbrich;
{ -----------------------------------------------------------------------------
  WPTools Version 5
  Wpdbrich - Copyright (C) 2002 by wpcubed GmbH      -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  The main memo control. It allows editing and printing of formatted text
  WPCTRMemo ->TWPCustomRtfEdit
  WPCTRRich ->TWPCustomRichText
               ->TWPRichText
               ->TWPEdit
  WPDBRich  ->TDBWPRichText
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

{$I WPINC.INC}

{--$DEFINE WP_DBBLOG_TRYEXCEPT} // we catch load errors when window is not created!

{ remove period	ONLY if	you want to save the data manualy in
  the DataSource - UpdateData event.
  Example:
     procedure TForm1.DataSource1UpdateData(Sender: TObject);
     begin
  if DBWPRichText1.Modified then
  DBWPRichText1.UpdateData(DataSource1);
     end;
}
{.$DEFINE MANUALPOSTDATA}

{ New property:
  OptimizeSpeed	: Boolean
     if	TRUE then Data is not loaded in	case Height<=1 or Visible := FALSE
  New Events for better	support	of 3rdParty Database Engines with special
  blob fields. If these	events are set the data	will not be loaded from
  the database record
    FOnLoadData(Sender)
    FOnSaveData(Sender)
}

interface

uses Windows, SysUtils, Messages, Classes, Controls, Graphics, Menus, Forms,
   DB, DBCtrls, WPRTEDefs, WPRTEPaint, WPCTRMemo, WPCTRRich,
   WPObj_Image;

type
  {:: This control is used to load and save to a database blob. You can change the load format
  and save format suing format strings.
  To load/save cyrillic ANSI texts use:  <br>

     DBWPRichText1.TextLoadFormat := 'ANSI-codepage1251'; <br>
   DBWPRichText1.TextSaveFormat := 'ANSI-codepage1251';
  }
  TDBWPRichText = class(TWPCustomRichText)
  PRIVATE
{$IFNDEF T2H}
    FDataLink: TFieldDataLink;
    FNoResetOnEscape : Boolean;
    FAutoDisplay: Boolean;
    FTextReloaded: Boolean;
    FFocused: Boolean;
    FNoReloadOnEdit: boolean;
    FIgnoreReload: boolean;
    FDataLoaded: Boolean;
    FOnNotifyLocked: TNotifyEvent;
    FOnLoadData: TNotifyEvent;
    FOnSaveData: TNotifyEvent;
    FLastWasUpdate, FWhileUpdateData: Boolean;
    FNoUpdateOnExit: Boolean;
    function GetDataField: string;
    function GetDataSource: TDataSource;
    function GetField: TField;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    procedure SetAutoDisplay(Value: Boolean);
    procedure SetFocused(Value: Boolean);
    procedure WMSize(var Message: TWMSize); MESSAGE WM_SIZE;
    procedure CMEnter(var Message: TCMEnter); MESSAGE CM_ENTER;
    procedure CMExit(var Message: TCMEnter); MESSAGE CM_Exit;
    procedure CMGetDataLink(var Message: TMessage); MESSAGE CM_GetDataLink;
{$ENDIF}
  PROTECTED
{$IFNDEF T2H}
    procedure KeyDown(var Key: Word; Shift: TShiftState); OVERRIDE;
    procedure KeyPress(var Key: Char); OVERRIDE;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); OVERRIDE;
    procedure EnableDataControlIcons;
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    procedure UpdateData(Sender: TObject);
    procedure LoadData;   
{$ENDIF}
  PUBLIC
    ContinueProcess: Boolean;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); OVERRIDE;
    constructor Create(AOwner: TComponent); OVERRIDE;
    destructor Destroy; OVERRIDE;
    function Changing: Boolean; OVERRIDE;
    function SaveChanging: Boolean; OVERRIDE;
{$IFNDEF T2H}
    procedure OnToolBarIconSelection(Sender: TObject;
      var Typ: TWpSelNr; const str: string; const group, num, index: Integer); OVERRIDE;
    property Field: TField READ GetField;
{$ENDIF}
  PUBLISHED
    property AutoDisplay: Boolean READ FAutoDisplay WRITE SetAutoDisplay;
    property OnNotifyLocked: TNotifyEvent READ FOnNotifyLocked WRITE FOnNotifyLocked;
    property DataField: string READ GetDataField WRITE SetDataField;
    property DataSource: TDataSource READ GetDataSource WRITE SetDataSource;
    property NoUpdateOnExit: Boolean READ FNoUpdateOnExit WRITE FNoUpdateOnExit;
    property NoReloadOnEdit: Boolean READ FNoReloadOnEdit WRITE FNoReloadOnEdit;
    property NoResetOnEscape : Boolean read FNoResetOnEscape write FNoResetOnEscape;
{$IFNDEF T2H}
    property AllowMultiView;
    //NOT POSSIBLE: property RTFText;
    property Header;
    property RTFVariables;
    property PrintParameter;
    property SpellCheckStrategie;
    property SpellIgnoredForObj;
    property Readonly;
    property WPToolBar;
    property WPRuler;
    property VRuler;
    property GraphicPopupMenu;
{$IFDEF IWPGUTTER}property WPGutter; {$ENDIF}
    property ActionList;
    property OnCharacterAttrChange;
    property OnInitializeRTFDataObject;
    property OnInitializedRTFData;
    property OnPrepareParForPaint;
    property AfterImageSaving;
    property BeforeObjectSelection;
    property AfterObjectSelection;
    property OnClickCreateHeaderFooter;
    property OnChange;
    property OnChangeLastFileName;
    property OnResize;
    property OnChangeZooming;
    //NOT POSSIBLE: property HeaderFooter;
    property DefaultIOFormat;
    property XOffset;
    property YOffset;
    property XBetween;
    property YBetween;
    property AutoZoom;
    property Zooming;
    property Resizing;
    property PageColumns;
    property LayoutMode;
    property PaperColor;
    property ColorDesktop;
    property ScrollBars;
    property WantTabs;
    property WantReturns;
    property EditOptions;
    property EditOptionsEx;
    property ViewOptions;
    property ClipboardOptions;
    property FormatOptions;
    property FormatOptionsEx;
    property EditBoxModes;
    property WordWrap;
    property AcceptFiles;
    property AcceptFilesOptions;

    property ProtectedProp;
    property OnCheckProtection;
    property OnEditFieldGetSize;
    property OnEditFieldFocus;

    property BorderStyle;
    property Transparent;

    property HyperLinkCursor;
    property TextObjectCursor;


    property InsertPointAttr;
    property HyperlinkTextAttr;
    property BookmarkTextAttr;
    property SPANObjectTextAttr;
    property HiddenTextAttr;
    property AutomaticTextAttr;
    property ProtectedTextAttr;
    property FieldObjectTextAttr;
    property WriteObjectMode;

    property OnRequestStyle;
    property OnRequestHTTPString;
    property OnRequestHTTPImage;
    property OnGetPageGapText;

    property OnClickHotText;
    property ClickableCodes;
    property OneClickHyperlink;
    property HyperLinkEvent;
    property OnCustomLinePaintBefore;
    property OnCustomLinePaintAfter;
    property BeforeInitializePar;
    property OnDropFile;
    property OnCalcPageNr;
    property OnClick;

    property OnDblClick;

    property OnUpdateExternScrollbar;
    property OnEditBoxChangeHeight;
    property OnSetupPrinterEvent;
    property OnEditBoxChangeWidth;

    property OnChangeViewMode;

    property OnChangeSelection;
    property OnUndoStateChanged;
    property OnMailMergeGetText;

    property OnNewRTFDataBlock;
    property OnClear;
    property AfterLoadText;
    property OnOpenDialog;
    property BeforePasteText;
    property BeforePasteImage;
    property BeforeDropText;
    property BeforeOverwriteFile;
    property BeforeCopyText;
    property BeforeCutText;
    property AfterCopyToClipboard;

    property OnTextObjectMouseMove;
    property OnTextObjectMouseDown;
    property OnTextObjectMouseUp;
    property OnTextObjectClick;
    property OnTextObjectDblClick;
    property OnTextObjectPaint;
    property OnTextObjectMove;

    property OnDelayedUpdate;
    property AfterDelayedUpdate;

    property OnGetAttributeColor; // was: OnGetAttrColor

    property OnTextObjGetTextEx;

    property BeforeEditBoxNeedFocus;

    property OnWorkOnTextChanged;

    property OnChangeCursorPos;

    property OnMeasureTextPage;

    property BeforeDestroyPaintPage;

    property OnPaintWatermark;

    property OnPaintExternPage;

    property OnMouseDownWord;

    property AfterCompleteWordEvent;

    property OnActivatingHotStyle;
    property OnActivateHint;
    property OnClickText;
    property OnDeactivateHotStyle;

    property OnGetSpecialText;
   {$IFNDEF T2H} // ------------ Standard Properties ----------------------------
    property Align;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property ParentColor;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    {:@event}
    property OnDragDrop;
    {:@event}
    property OnDragOver;
    {:@event}
    property OnEndDrag;
    {:@event}
    property OnEnter;
    {:@event}
    property OnExit;
    {:@event}
    property OnKeyDown;
    {:@event}
    property OnKeyPress;
    {:@event}
    property OnKeyUp;
    {:@event}
    property OnMouseDown;
    {:@event}
    property OnMouseMove;
    {:@event}
    property OnMouseUp;
    property Anchors;
    property Constraints;
{$ENDIF}
{$ENDIF}
//#<Events>
    property OnLoadData: TNotifyEvent READ FOnLoadData WRITE FOnLoadData;
    property OnSaveData: TNotifyEvent READ FOnSaveData WRITE FOnSaveData;
//#</Events>
  end;

  // New component to do mailmerge
  TWPMMDataProvider = class;
  TWPMMDataProviderOption = (wpmmPreserveObjectSize, wpmmConvertRTFToANSI);
  TWPMMDataProviderOptions = set of TWPMMDataProviderOption;

  TWPMMDataProviderGetDataset = procedure(Sender : TObject;
                  const Fieldname : string;
                  {$IFNDEF BCB} const {$ENDIF} Contents: TWPMMInsertTextContents;
                  var Dataset : TDataset) of Object;
  TWPMMDataProviderGetTextEvent = procedure(Sender: TObject;
    const inspname: string;
    {$IFNDEF BCB} const {$ENDIF} Contents: TWPMMInsertTextContents;
    var Done : Boolean) of object;

  TWPMMDataProviderSaveTextEvent = procedure(Sender: TObject;
    const inspname: string;
    {$IFNDEF BCB} const {$ENDIF} Contents: TWPMMInsertTextContents;
    var   SavedText : string;
    var   Field     : TField;
    var   Ignore : Boolean) of object;

  {$IFNDEF T2H}
  TWPMMDatalink = class(TDatalink)
  private
    FWPMMDataProvider : TWPMMDataProvider;
  protected
    procedure DataSetChanged; override;
    procedure UpdateData; override;
  end;
  {$ENDIF}

  TWPMMDataProvider = class(TComponent)
  private
    FEditBox      : TWPCustomRichText;
    FSuperMerge : TWPAbstractSuperMerge;
    FAutoLoadData, FAutoSaveData : Boolean;
    FDatalink     : TWPMMDatalink;
    FNextDataProvider : TWPMMDataProvider;
    FOnGetDataset : TWPMMDataProviderGetDataset;
    FOptions      : TWPMMDataProviderOptions;
    FGetTextToInsert: TWPMMDataProviderGetTextEvent;
    FSaveFielddata : TWPMMDataProviderSaveTextEvent;
    FNowWriteData: Boolean;
    FRTFFieldList : TStringList;
    FRTFFields : TStringList;
    FBMPFields : TStringList;
    FShowFieldNames, FAppendSpaceToNonEmpty : Boolean;
    procedure SetEditBox(x : TWPCustomRichText);
    procedure SetSuperMerge(x : TWPAbstractSuperMerge);
    procedure SetAutoLoadData(x : Boolean);
    procedure SetShowFieldNames(x : Boolean);
    procedure SetDatasource(Value : TDataSource);
    function  GetDataSource: TDataSource;
    procedure SetRTFFields(x : TStrings);
    procedure SetBMPFields(x : TStrings);
    function  GetRTFFields : TStrings;
    function  GetBMPFields : TStrings;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    procedure   DoMergeGetText(Sender: TObject; const fieldname: string;
                  Contents: TWPMMInsertTextContents);
    constructor Create(aOwner : TComponent); override;
    destructor  Destroy; override;
    procedure   ReadData; virtual;
    procedure   WriteData; virtual;
  published
    property Datasource : TDatasource read GetDatasource write SetDatasource;
    property NextDataProvider : TWPMMDataProvider read FNextDataProvider write FNextDataProvider;
    property EditBox : TWPCustomRichText read FEditBox write SetEditBox;
    property SuperMerge : TWPAbstractSuperMerge read FSuperMerge write SetSuperMerge;
    property ShowFieldNames : Boolean read FShowFieldNames write SetShowFieldNames;
    property Options : TWPMMDataProviderOptions read FOptions write FOptions;
    property AutoLoadData : Boolean read FAutoLoadData write SetAutoLoadData;
    property AppendSpaceToNonEmpty : Boolean Read FAppendSpaceToNonEmpty write FAppendSpaceToNonEmpty;
    property OnGetTextToInsert: TWPMMDataProviderGetTextEvent read FGetTextToInsert write FGetTextToInsert;
    property OnSaveFieldData : TWPMMDataProviderSaveTextEvent read FSaveFielddata write FSaveFielddata;
    property OnGetDataset : TWPMMDataProviderGetDataset read FOnGetDataset write FOnGetDataset;
    property AutoSaveData : Boolean read FAutoSaveData write FAutoSaveData;
    property RTFFields : TStrings read GetRTFFields write SetRTFFields;
    property BMPFields : TStrings read GetBMPFields write SetBMPFields;
  end;


implementation

constructor TDBWPRichText.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  NoReloadOnEdit := TRUE;
  NoUpdateOnExit := FALSE; // TRUE;
  AutoDisplay := True;
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
{$IFNDEF MANUALPOSTDATA}
  FDataLink.OnUpdateData := UpdateData;
{$ENDIF}
  // Many database do not allow binary data in strings
  TextSaveFormat := 'AUTO-nobinary'; // V5.17.3
end;

destructor TDBWPRichText.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;
  inherited Destroy;
end;

procedure TDBWPRichText.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
     (AComponent = DataSource) then DataSource := nil;
end;

procedure TDBWPRichText.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if FDataLoaded then
  begin
    if (Key = VK_DELETE) or ((Key = VK_INSERT) and (ssShift in Shift)) then
      FDataLink.Edit;
  end else
    Key := 0;
end;

procedure TDBWPRichText.KeyPress(var Key: Char);
begin
  if FDataLoaded then   
  begin
    if (Key in [#32..#255]) and (FDataLink.Field <> nil) and
      not FDataLink.Field.IsValidChar(Key) then
    begin
      MessageBeep(0);
      Key := #0;
    end;
    case Key of
      ^H, ^I, ^J, ^M, ^V, ^X, #32..#255:
        if not FDataLink.Editing then
        try
          Changing;
        except
          exit;
        end;
      #27:
        if not FNoResetOnEscape then
        begin
          FDataLink.Reset;
          Key := #0;
        end;
    end;
  end else
  begin
    if Key = #13 then LoadData;
    Key := #0;
  end;
  inherited KeyPress(Key);
end;

function TDBWPRichText.SaveChanging: Boolean;
begin
  FTextReloaded := FALSE;
  Result := Changing;
  if FTextReloaded then Result := FALSE; // Allow change the next time !
end; 

function TDBWPRichText.Changing: Boolean;
var par, pos_in_par, dummy, selpos, sellen: Longint;
  atr: TAttr;
begin
  if csLoading in ComponentState then
       Result := FALSE
  else Result := inherited Changing;
  if Result then
  try
    if (FDataLink.DataSource = nil) or (FDataLink.DataSet = nil)
      or (FDataLink.DataSource.State = dsInactive) then
    begin
      Result := FALSE;
      exit;
    end;
    if not FDataLink.Editing then
    begin
      // Switch to EDIT mode but do not realod the text !
      if NoReloadOnEdit then
      begin
        try
          FIgnoreReload := TRUE;
          FDataLink.Edit;
        except
          Result := FALSE;
          FIgnoreReload := FALSE;
          if assigned(FOnNotifyLocked) then FOnNotifyLocked(Self);
          exit;
        end;
        FIgnoreReload := FALSE;
      end else
      //  Switch to EDIT mode and reload the text if necessary
      begin
        Memo.FIgnoreRepaint := TRUE;
      (*  topoff := Memo.top_offset;
        leftoff := Memo.left_offset; *)
        GetPosition(dummy, dummy, par, pos_in_par);
        atr := Attr;
        GetSelPosLen(selpos,sellen);
        HideSelection;
        try
          FDataLink.Edit;
        except
          Result := FALSE;
          Memo.FIgnoreRepaint := FALSE;
          if assigned(FOnNotifyLocked) then FOnNotifyLocked(Self);
          exit;
        end; 
      (*  Memo.top_offset := topoff;
        Memo.left_offset := leftoff;   *)
        SetPosition(0, 0, par, pos_in_par);
        Attr := atr;
        if sellen > 0 then
        begin
          SetSelPosLen(selpos,sellen);
        end;
        Memo.FIgnoreRepaint := FALSE;
        Memo.RePaint;
        FDataLoaded := True;
      end;
    end;
    FDataLink.Modified;

  except
    Memo.FIgnoreRepaint := FALSE; { V1.94 }
    raise;
  end;
end;

function TDBWPRichText.GetDataSource: TDataSource;
begin
  if FDataLink<>nil then
     Result := FDataLink.DataSource else
  Result := nil;
end;

procedure TDBWPRichText.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

function TDBWPRichText.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TDBWPRichText.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

function TDBWPRichText.GetField: TField;
begin
  Result := FDataLink.Field;
end;

procedure TDBWPRichText.WMSize(var Message: TWMSize);
begin
  inherited;
  if Focused then SetFocusValues(FALSE); { Added 2.35a }
end;

procedure TDBWPRichText.CMGetDataLink(var Message: TMessage);
begin
  Message.Result := Integer(FDataLink);
end;

procedure TDBWPRichText.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
  {$IFDEF DELPHI3ANDUP}
    if FDataLink.Field.IsBlob then
  {$ELSE}
    if FDataLink.Field is TBlobField then
  {$ENDIF}
    begin
      if FAutoDisplay or (FDataLink.Editing and FDataLoaded) then
      begin
        FDataLoaded := False;
        LoadData;
      end else
      begin
        Text := Format('(%s)', [FDataLink.Field.DisplayLabel]);
        FDataLoaded := False;
      end;
    end else
    begin
      if FFocused and FDataLink.CanModify then
        Text := FDataLink.Field.Text
      else
        Text := FDataLink.Field.DisplayText;
      FDataLoaded := True;
    end
  else
  begin
    if csDesigning in ComponentState then Text := Name else Text := '';
    FDataLoaded := False;
  end;
end;

procedure TDBWPRichText.LoadData;
var
  Stream: TMemoryStream;
  pos, selstart, sellength : Integer;
  err : Boolean;
begin
  if not Assigned(FDataLink.Field) then
  begin
      FDataLoaded := False;
  end
  else
  if FIgnoreReload=TRUE  then
  begin
     FDataLoaded := True;
  end
  else
  begin
    FTextReloaded := TRUE;
  //  FLastSelectedObj := nil;
    if (FDataLoaded = FALSE) and assigned(FOnLoadData) then
    begin
      WorkOnText := wpBody;
      ContinueProcess := FALSE;
      FOnLoadData(Self);
      FDataLoaded := True;
      Modified := FALSE;
      EditingChange(Self);
      if not ContinueProcess then exit;
    end;

    if FLastWasUpdate then
    begin
       FLastWasUpdate := FALSE;
       FDataLoaded := TRUE;
    end
    else
    if (FDataLoaded = FALSE) and FDataLink.Field.IsBlob then
    begin
      LockScreen;
      pos := CPPosition;
      Memo.Cursor.GetSelPosLen(selstart, sellength);
      WorkOnText := wpBody;
      Stream := TMemoryStream.Create;
      try
        {$IFDEF WP_DBBLOG_TRYEXCEPT}
        try
        {$ENDIF}
        TBlobField(FDataLink.Field).SaveToStream(Stream);
        err := FALSE;
        {$IFDEF WP_DBBLOG_TRYEXCEPT}
        except
          on e : Exception do
          begin
          // We are in a Form.OnCreate - do not raise an exception here!
          if not HandleAllocated or (csLoading in ComponentState) then
          begin
             err := TRUE;
             AsString := 'DBERROR: ' + e.Message;
          end
          else raise;
          end;
        end;
        {$ENDIF}

        if not err then
        begin
        Stream.Position := 0;
        if Stream.Size > 0 then
        begin
          LoadFromStream(Stream,'',true);
          CPPosition := pos;
          if sellength>0 then
             Memo.Cursor.SetSelPosLen(selstart, sellength);
        end else
        begin
          Clear;
        end;
        end;
        if Memo.DisplayedText=nil then
        begin
          Memo.DisplayedText := Memo.Body;
          Memo.CursorOnText := Memo.Body;
        end;
        FDataLoaded := True;
        Modified := FALSE;
        EditingChange(Self);
      finally
        Stream.Free;
      end;
      SetFocusValues(TRUE);
      UnlockScreen(true);
      invalidate;
      if assigned(FRuler) then FRuler.invalidate;
    end;
  end;
end;

procedure TDBWPRichText.UpdateData(Sender: TObject);
var
  Stream: TMemoryStream;
begin
  if (csDesigning in ComponentState) or FWhileUpdateData or
    (FDataLink.DataSource = nil) or (FDataLink.DataSet = nil)
    or (FDataLink.DataSource.State = dsInactive) {or not FDatalink.Editing}
    then exit;
  FWhileUpdateData := TRUE;
  WorkOnText := wpBody;

  if assigned(FOnSaveData) then
  begin
    ContinueProcess := FALSE;
    FOnSaveData(Self);
  end else ContinueProcess := TRUE;

  if ContinueProcess then
  begin
    if FDataLink.Field.IsBlob then
    begin
      Stream := TMemoryStream.Create;
      try
        if not FDatalink.Editing then
        try
          FIgnoreReload := TRUE;
          FDatalink.Edit;
        finally
          FIgnoreReload := FALSE;
        end;
        SaveToStream(Stream);
        Stream.Position := 0;
        (FDataLink.Field as TBlobField).LoadFromStream(Stream);
      finally
        Stream.Free;
      end;
    end else FDataLink.Field.Text := Text;
    FLastWasUpdate := TRUE;
  end;
  Modified := FALSE;
  FWhileUpdateData := FALSE;
end;

procedure TDBWPRichText.EditingChange(Sender: TObject);
begin
 { if not Readonly then
    inherited SetReadonly(not (FDataLink.Editing and FDataLoaded))
  else inherited SetReadonly(TRUE);  }
  EnableDataControlIcons;
end;


procedure TDBWPRichText.SetFocused(Value: Boolean);
begin
  if FFocused <> Value then
  begin
    FFocused := Value;
  {$IFDEF DELPHI3ANDUP}
    if not Assigned(FDataLink.Field) or not FDataLink.Field.IsBlob then
        FDataLink.Reset;
  {$ELSE}
    if not Assigned(FDataLink.Field) or not (FDataLink.Field is TBlobField) then
        FDataLink.Reset;
  {$ENDIF}
  end;
end;

procedure TDBWPRichText.CMEnter(var Message: TCMEnter);
begin
  SetFocused(True);
  inherited;
end;

procedure TDBWPRichText.CMExit(var Message: TCMExit);
begin
  if not FNoUpdateOnExit then
  try
    FDataLink.UpdateRecord;
  except
    SetFocus;
    raise;
  end;
  SetFocused(False);
  inherited;
end;

procedure TDBWPRichText.SetAutoDisplay(Value: Boolean);
begin
  if FAutoDisplay <> Value then
  begin
    FAutoDisplay := Value;
    if Value and (FDataLink<>nil) then LoadData;
  end;
end;

procedure TDBWPRichText.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (ssDouble in Shift) and not FDataLoaded then LoadData;
end;

procedure TDBWPRichText.EnableDataControlIcons;
begin
  if WPToolBar <> nil then
  begin
    if (FDataLink.DataSource <> nil) and (FDataLink.DataSet <> nil)
      and (FDataLink.DataSource.State <> dsInactive) then
      with FDataLink.DataSet do
      begin
        WPToolBar.EnableIcon(0, WPI_GR_DATA, WPI_CO_Next, not EOF);
        WPToolBar.EnableIcon(0, WPI_GR_DATA, WPI_CO_ToEnd, not EOF);
        WPToolBar.EnableIcon(0, WPI_GR_DATA, WPI_CO_Prev, not BOF);
        WPToolBar.EnableIcon(0, WPI_GR_DATA, WPI_CO_ToStart, not BOF);
        WPToolBar.EnableIcon(0, WPI_GR_DATA, WPI_CO_Edit, not Readonly);
        WPToolBar.EnableIcon(0, WPI_GR_DATA, WPI_CO_Post, Modified);
        WPToolBar.EnableIcon(0, WPI_GR_DATA, WPI_CO_Cancel, Modified);
      end else
    begin
      WPToolBar.EnableIcon(0, WPI_GR_DATA, WPI_CO_Next, FALSE);
      WPToolBar.EnableIcon(0, WPI_GR_DATA, WPI_CO_ToEnd, FALSE);
      WPToolBar.EnableIcon(0, WPI_GR_DATA, WPI_CO_Prev, FALSE);
      WPToolBar.EnableIcon(0, WPI_GR_DATA, WPI_CO_ToStart, FALSE);
      WPToolBar.EnableIcon(0, WPI_GR_DATA, WPI_CO_Add, FALSE);
      WPToolBar.EnableIcon(0, WPI_GR_DATA, WPI_CO_Del, FALSE);
      WPToolBar.EnableIcon(0, WPI_GR_DATA, WPI_CO_Edit, FALSE);
      WPToolBar.EnableIcon(0, WPI_GR_DATA, WPI_CO_Cancel, FALSE);
      WPToolBar.EnableIcon(0, WPI_GR_DATA, WPI_CO_Post, FALSE);
    end;
  end;
end;

{------------------------------------------------------------------------}
{ will be processed even if it has not the focus ------------------------}

procedure TDBWPRichText.OnToolBarIconSelection(Sender: TObject;
  var Typ: TWpSelNr; const str: string; const group, num, index: Integer);
begin
  if (typ = wptIconSel) then
  begin
    if (FDataLink.DataSource <> nil) and (group = WPI_GR_DATA) then
    begin
      if (FDataLink.DataSource.DataSet <> nil)
        and (FDataLink.DataSource.State <> dsInactive)
        then
      begin
        case num of
          WPI_CO_Next: FDataLink.DataSource.DataSet.Next; { Group: WPI_DATA }
          WPI_CO_Prev: FDataLink.DataSource.DataSet.Prior;
          WPI_CO_Add: FDataLink.DataSource.DataSet.Insert;
          WPI_CO_Del: FDataLink.DataSource.DataSet.Delete;
          WPI_CO_Edit: if FDataLink.editing = FALSE then
              FDataLink.DataSource.DataSet.Edit;
          WPI_CO_Cancel: FDataLink.DataSource.DataSet.Cancel;
          WPI_CO_Post: FDataLink.DataSource.DataSet.Post;
          WPI_CO_ToStart: FDataLink.DataSource.DataSet.First;
          WPI_CO_ToEnd: FDataLink.DataSource.DataSet.Last;
        end;
        WPToolBar.DeselectIcon(0, WPI_GR_DATA, num);
        EnableDataControlIcons;
        typ := wptNone;
      end;
    end { Group }
    else if Focused then
    begin { handle some of the other Buttons }
      if group = WPI_GR_DISK then
        case num of
          WPI_CO_ClOSE: begin WPToolBar.DeselectIcon(0, WPI_GR_DISK, num);
              Typ := wptNone;
            end;
        end;
    end;
  end;
  {-------- NOW	call inherited ------------------}
  inherited OnToolBarIconSelection(Sender, Typ, str, group, num, index);
end;



// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

  constructor TWPMMDataProvider.Create(aOwner : TComponent);
  begin
    inherited Create(aOwner);
    FAutoLoadData    := TRUE;
    FDatalink := TWPMMDatalink.Create;
    FDatalink.FWPMMDataProvider := Self;
    FAutoSaveData := FALSE;
    FRTFFieldList := TStringList.Create;
    FRTFFields := TStringList.Create;
    FBMPFields := TStringList.Create;
  end;

  destructor TWPMMDataProvider.Destroy;
  begin
    FDatalink.FWPMMDataProvider := nil;
    FDatalink.Free;
    FRTFFieldList.Free;
    FDatalink := nil;
    FRTFFields.Free;
    FBMPFields.Free;
    if FEditBox<>nil then FEditBox._IntegernOnMailMergeGetText := nil;
    if FSuperMerge<>nil then FSuperMerge._IntegernOnMailMergeGetText := nil;
    inherited Destroy;
  end;

  function TWPMMDataProvider.GetDataSource: TDataSource;
  begin
     Result := FDataLink.DataSource;
  end;

    procedure TWPMMDataProvider.SetRTFFields(x : TStrings);
    begin
       FRTFFields.Assign(x);
    end;

    procedure TWPMMDataProvider.SetBMPFields(x : TStrings);
    begin
       FBMPFields.Assign(x);
    end;

    function  TWPMMDataProvider.GetRTFFields : TStrings;
    begin
       Result :=  FRTFFields;
    end;

    function  TWPMMDataProvider.GetBMPFields : TStrings;
    begin
       Result :=  FBMPFields;
    end;

  procedure TWPMMDataProvider.SetDataSource(Value: TDataSource);
  begin
     FDataLink.DataSource := Value;
     if FDataLink.DataSource<>nil then FDataLink.DataSource.FreeNotification(Self);
     ReadData;
  end;

  procedure TWPMMDataProvider.SetEditBox(x : TWPCustomRichText);
  begin
    if FEditBox<>x then
    begin
       FEditBox := x;
       if FEditBox<>nil then
       begin
           FEditBox.FreeNotification(Self);
           FEditBox._IntegernOnMailMergeGetText := DoMergeGetText;
       end;
       ReadData;
    end;
  end;

  procedure TWPMMDataProvider.SetSuperMerge(x : TWPAbstractSuperMerge);
  begin
    if FSuperMerge<>x then
    begin
       FSuperMerge := x;
       if FSuperMerge<>nil then
       begin
           FSuperMerge.FreeNotification(Self);
           FSuperMerge._IntegernOnMailMergeGetText := DoMergeGetText;
       end;
       //- no, not for the SuperMerge: ReadData;
    end;
  end;

  procedure TWPMMDataProvider.SetAutoLoadData(x : Boolean);
  begin
    if FAutoLoadData<>x then
    begin
       FAutoLoadData := x;
       ReadData;
    end;
  end;

  procedure TWPMMDataProvider.SetShowFieldNames(x : Boolean);
  begin
    if FShowFieldNames<>x then
    begin
       FShowFieldNames := x;
       ReadData;
    end;
  end;

  procedure TWPMMDataProvider.ReadData;
  begin
       if FAutoLoadData and (FEditBox<>nil) and
          (FDataLink.DataSet<>nil) and
          not FDataLink.DataSet.ControlsDisabled and
          FDataLink.DataSet.Active then
          try
            FEditBox.LockScreen;
            FEditBox.MergeText;
          finally
            FEditBox.UnLockScreen(true);
          end;
  end;

  procedure TWPMMDataProvider.WriteData;
  begin
       if FAutoSaveData and not FShowFieldNames and (FEditBox<>nil) and
          (FDataLink.DataSet<>nil) then
       try
         FNowWriteData := TRUE;
         FEditBox.MergeEnumFields('');
         FNowWriteData := FALSE;
       except
         FNowWriteData := FALSE;
       end;
  end;

  procedure TWPMMDataProvider.Notification(AComponent: TComponent; Operation: TOperation);
  begin
    if Operation = opRemove then
    begin
          if AComponent = FEditBox then FEditBox := nil;
          if AComponent = FSuperMerge then FSuperMerge := nil;
          if (FDataLink<>nil) and (AComponent = FDataLink.DataSource) then
              FDataLink.DataSource := nil;
          if AComponent=FNextDataProvider THEN FNextDataProvider := nil;
    end;
    inherited Notification(AComponent, Operation);
  end;


  procedure TWPMMDatalink.DataSetChanged;
  begin
       if FWPMMDataProvider<>nil then FWPMMDataProvider.ReadData;
  end;

  procedure TWPMMDatalink.UpdateData;
  begin
       if FWPMMDataProvider<>nil then FWPMMDataProvider.WriteData;
  end;

procedure TWPMMDataProvider.DoMergeGetText(Sender: TObject;
      const fieldname: string;
      Contents: TWPMMInsertTextContents);
var
     field: TField;
     dataset : TDataset;
     done : Boolean;
     obj  : TWPOImage;
     isnew : Boolean;
     isBMP, isRTF : Boolean;
     s : string;
     i : Integer;
     blobstream : TStream;
     function FindInList(list : TStringList) : Boolean;
     var
       ii : Integer;
     begin
       Result := FALSE;
       for ii:=0 to list.Count-1 do
       if CompareText(fieldname, list[ii])=0 then
       begin Result := TRUE;
             break;
       end;
     end;
begin
  if FNowWriteData and FShowFieldNames then exit; // not allowed !
  // ---------- EditField, the end marks should not be used for mailmerge ! ----
  if Contents.c = WPEditFieldEnd then exit;
  if Contents.c = WPEditFieldStart then Contents.Options := [mmDeleteUntilFieldEnd];
  // ---------------------------------------------------------------------------
  dataset := FDataLink.DataSet;
  Done := FALSE;
  if assigned(FOnGetDataset) then
  begin
     FOnGetDataset(Self, fieldname, Contents, dataset);
     if dataset = nil then exit;
  end;
  // ---------------------------------------------------------------------------
  s := '';
  isBMP := FindInList(FBMPFields);
  isRTF := not isBMP and FindInList(FRTFFields);
  if FNowWriteData then
  begin
    if dataset<>nil then
    begin
      field := dataset.FindField(fieldname);
      if assigned(FSaveFielddata) then
      begin
          if (field is TGraphicField) or isBMP then
               s := ''
          else if (FRTFFieldList.IndexOf(UpperCase(fieldname))<0) and not isRTF then // use last loaded format !
           //  if Contents.OldIsPlain then
               s := Contents.OldText
          else s := Contents.OldFormattedText;
          FSaveFielddata(Self, fieldname, contents, s,field,done);
          if done then
             exit
          else
          if not (field is TGraphicField) and not isBMP and (field<>nil) then
             field.AsString := s;
      end else if not (field is TGraphicField) and (field<>nil) and not isBMP then
      begin
       if not isRTF and (FRTFFieldList.IndexOf(UpperCase(fieldname))<0) then // use last loaded format !
            s := Contents.OldText
       else s := Contents.OldFormattedText;
       field.AsString := s;
      end;
    end;
    exit;
  end;
  // ---------------------------------------------------------------------------
  if assigned(FGetTextToInsert) then
  begin
     FGetTextToInsert(Self, fieldname, contents, done);
     if done then exit;
  end;
  Contents.StringValue := '';
  if (dataset<>nil) and dataset.Active then
  begin
    field := dataset.FindField(fieldname);
    if FShowFieldNames then
    begin
       if field<>nil then Contents.StringValue := field.DisplayName
       else Contents.StringValue := fieldname;
       if FAppendSpaceToNonEmpty and (Contents.StringValue<>'') then
          Contents.StringValue := Contents.StringValue + #32;
       Done:= TRUE;
    end else if (field is TGraphicField) or isBMP then
    begin
           Done := TRUE;
           if (wpmmPreserveObjectSize in FOptions) and
              (Contents.CurrentObject<>nil) and
              (Contents.CurrentObject is TWPOImage) then
           begin
               obj := TWPOImage(Contents.CurrentObject);
               isnew := FALSE;
           end
           else
           begin
             obj := CreateTWPTOClass(
                (Sender as TWPCustomRtfEdit).Memo.RTFData
                , 'BMP') as TWPOImage;
             isnew := TRUE;
           end;
           if obj<>nil then
           begin
            // TWPOImage(obj).Graphic.Width := 10;
            if field is TGraphicField then
               TWPOImage(obj).Picture.Assign(field)
            else if field is TBlobField then
            begin
               blobstream := TMemoryStream.Create;
               try
                 TBlobField(field).SaveToStream(blobstream);
                 blobstream.Position := 0;
                 TWPOImage(obj).FileExtension := 'BMP';
                 TWPOImage(obj).LoadFromStream(blobstream);
              except
               // We don't want to see any image errors here !
              end;
              blobstream.Free;
            end;
            if isnew then
            begin
             TWPOImage(obj).HeightTW :=
                MulDiv(TWPOImage(obj).Graphic.Height,1440,96);
             TWPOImage(obj).WidthTW :=
                MulDiv(TWPOImage(obj).Graphic.Width,1440,96);
            end;
            TWPOImage(obj).WriteRTFMode := wobOnlyRTF;
            Contents.obj := obj;
           end;
     end
     else if field<>nil then
     begin
       Done := TRUE;
       if field.IsNull then
            Contents.StringValue := ''
       else
       try
         Contents.StringValue := field.AsString;
         i := FRTFFieldList.IndexOf(Uppercase(fieldname));
         if (Copy(Contents.StringValue,1,5)='{\rtf') then
         begin
            // Attention, we will loos the formatting !
            if wpmmConvertRTFToANSI in FOptions then
               Contents.StringValue := WPToolsRTFToANSI(Contents.StringValue);
            // we want to save as RTF since it was in this format !
            if i<0 then FRTFFieldList.Add(Uppercase(fieldname));
         end else
         begin
            if not field.IsNull and (i>=0) then FRTFFieldList.Delete(i);
            if FAppendSpaceToNonEmpty and (Contents.StringValue<>'') then
                Contents.StringValue := Contents.StringValue + #32;
         end;
       except
         // If we have a problem create a message but don't hurt further operation
         on e : Exception do Contents.StringValue := 'ERROR:' + e.Message;
       end;
     end;
  end else if FShowFieldNames then
  begin
    Done := TRUE;
    Contents.StringValue := fieldname;
  end;

  if not Done and assigned(FNextDataProvider) and (FNextDataProvider<>Self) then
     FNextDataProvider.DoMergeGetText(Sender,FieldName,Contents);
end;


end.

