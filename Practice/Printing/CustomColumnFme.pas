unit CustomColumnFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, CheckLst, BKReportColumnManager, RptParams;


type
  TCustomColumnEvent = procedure() of object;

  TCustomReportType = (crCoding, crSuper);

  TfmeCustomColumn = class(TFrame)
    btnDefaults: TButton;
    btnDown: TBitBtn;
    btnLoadTemplate: TBitBtn;
    btnSaveTemplate: TBitBtn;
    btnUp: TBitBtn;
    chkColumns: TCheckListBox;
    gbOrientation: TGroupBox;
    gbSelectedColumn: TGroupBox;
    gbTemplates: TGroupBox;
    lblSelectAccounts: TLabel;
    rbLandscape: TRadioButton;
    rbPortrait: TRadioButton;
    dlgLoadTemplate: TOpenDialog;
    dlgSaveTemplate: TSaveDialog;
    procedure chkColumnsClickCheck(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure btnLoadTemplateClick(Sender: TObject);
    procedure btnDefaultsClick(Sender: TObject);
    procedure btnSaveTemplateClick(Sender: TObject);
    procedure rbPortraitClick(Sender: TObject);
    procedure chkColumnsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure chkColumnsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure chkColumnsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure chkColumnsStartDrag(Sender: TObject; var DragObject: TDragObject);
  private
    { Private declarations }
    FColManager: TReportColumnList;
    FReportParams: TRPTParameters;
    FOnApplySettings: TCustomColumnEvent;
    FStartingPoint: TPoint;
    FOldOverIndex: integer;
    FOnSaveSettings: TCustomColumnEvent;
    FCustomReportType: TCustomReportType;
    FTemplateExt: string;
    procedure SetReportParams(const Value: TRPTParameters); //Note: Only works with TCodingReportSettings!!
    procedure SetApplySettings(const Value: TCustomColumnEvent);
    procedure SyncColumns;
    procedure SetOnSaveSettings(const Value: TCustomColumnEvent);
    procedure SetCustomReportType(const Value: TCustomReportType);
  public
    { Public declarations }
    procedure ApplySettings;
    procedure LoadCustomColumns;
    procedure OutputColumn(aDataToken: integer; Value: boolean);
    property ReportParams: TRPTParameters read FReportParams write SetReportParams;
    property OnApplySettings: TCustomColumnEvent read FOnApplySettings write SetApplySettings;
    property OnSaveSettings: TCustomColumnEvent read FOnSaveSettings write SetOnSaveSettings;
    procedure UpdateActions;
    property CustomReportType: TCustomReportType read FCustomReportType write SetCustomReportType;
  end;

implementation

uses
  CodingRepDlg,
  LedgerRepDlg,
  Globals,
  OmniXML,
  OmniXmlUtils,
  YesNoDlg,
  WinUtils,
  WarningMoreFrm,
  ErrorMoreFrm;

const
  CODING_RPT_LAYOUT_EXT = '.crl';
  SUPER_RPT_LAYOUT_EXT = '.srl';

{$R *.dfm}

{ TFrame1 }

procedure TfmeCustomColumn.ApplySettings;
begin
  if Assigned(FOnApplySettings) then
    OnApplySettings; 
end;

procedure TfmeCustomColumn.btnDefaultsClick(Sender: TObject);
var
  TempWideStr: WideString;
begin
  //Reset Custom Columns
  FColManager.SetupColumns;
  //Save and reload from a temp var so that custom column settings are not
  //overriden in the client file
  TCodingReportSettings(FReportParams).SaveCustomReportXML(TempWideStr);
  TCodingReportSettings(FReportParams).LoadCustomReportXML(TempWideStr);
  ApplySettings;
end;

procedure TfmeCustomColumn.btnDownClick(Sender: TObject);
begin
  if (chkColumns.ItemIndex >= 0) and
     (chkColumns.ItemIndex < (chkColumns.Items.Count - 1)) then begin
    FColManager.ExchangeColumns(ChkColumns.ItemIndex,
                                ChkColumns.ItemIndex + 1);
    ChkColumns.Items.Exchange(ChkColumns.ItemIndex,
                              ChkColumns.ItemIndex + 1);
  end;
end;

procedure TfmeCustomColumn.btnLoadTemplateClick(Sender: TObject);
var
  Document: IXMLDocument;
  FileName : String;
  Node: IXMLNode;
begin
  dlgLoadTemplate.InitialDir := Globals.StyleDir;
  if dlgLoadTemplate.Execute then begin
    Filename := dlgLoadTemplate.FileName;
    if FileExists(Filename) then begin
      //Create Coding Report Layout file
      Document := CreateXMLDoc;
      try
        Document.Text := '';
        Document.Load(FileName);
        Node := Document.FirstChild;
        case FCustomReportType of
          crCoding:
              if Node.NodeName = 'CodingReportLayout' then begin
                TCodingReportSettings(FReportParams).ReadFromNode(Node);
                ApplySettings;
              end else
                HelpfulWarningMsg('File not loaded - invalid coding report template.',0);
          crSuper:
              if Node.NodeName = 'SuperfundReportLayout' then begin
                TLRParameters(FReportParams).ReadFromNode(Node);
                ApplySettings;
              end else
                HelpfulWarningMsg('File not loaded - invalid ledger report template.',0);
        end;
      finally
        Document := nil;
      end;
    end else
      HelpfulErrorMsg( 'The file "' + Filename + '" cannot be found', 0);
  end;
end;

procedure TfmeCustomColumn.btnSaveTemplateClick(Sender: TObject);
var
  i: integer;
  Document: IXMLDocument;
  FileName : String;
  Node: IXMLNode;
  MessageText: string;
begin
  dlgSaveTemplate.InitialDir := Globals.StyleDir;
  if dlgSaveTemplate.Execute then begin
    //make sure the filename has the correct extension
    FileName := dlgSaveTemplate.FileName;
    i := Length(FileName);
    if (Copy(FileName, i-3, 4) <> FTemplateExt) then
      FileName := FileName + FTemplateExt;
    while BKFileExists(FileName) do
    begin
      MessageText := Format('The file %s already exists. Overwrite?',
                            [ExtractFileName(FileName)]);
      if AskYesNo('Overwrite File', MessageText, dlg_yes, 0) = DLG_YES then
        Break;
      if not dlgSaveTemplate.Execute then exit;
      FileName := dlgSaveTemplate.FileName;
      i := Length(Filename);
      if (Copy(FileName, i-3, 4) <> FTemplateExt) then
        FileName := FileName + FTemplateExt;
    end;
    Document := CreateXMLDoc;
    try
      Document.Text := '';
      case FCustomReportType of
        crCoding:
          begin
            //Create custom Coding Report Layout file
            Node := Document.AppendChild(Document.CreateElement('CodingReportLayout'));
            if Assigned(FOnSaveSettings) then
              OnSaveSettings;
            TCodingReportSettings(FReportParams).SaveToNode(Node);
          end;
        crSuper:
          begin
            //Create custom Superfund Report Layout file
            Document.Text := '';
            Node := Document.AppendChild(Document.CreateElement('SuperfundReportLayout'));
            if Assigned(FOnSaveSettings) then
              OnSaveSettings;
            TLRParameters(FReportParams).SaveToNode(Node);
          end;
      end;
      Document.Save(FileName);
    finally
      Document := nil;
    end;
  end;
end;

procedure TfmeCustomColumn.btnUpClick(Sender: TObject);
begin
  if ChkColumns.ItemIndex > 0 then begin

     FColManager.ExchangeColumns(ChkColumns.ItemIndex,
                                 ChkColumns.ItemIndex - 1);
     ChkColumns.Items.Exchange(ChkColumns.ItemIndex,
                               ChkColumns.ItemIndex - 1);
  end;
end;

procedure TfmeCustomColumn.chkColumnsClickCheck(Sender: TObject);
begin
  SyncColumns;
end;

procedure TfmeCustomColumn.chkColumnsDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  DropPosition, StartPosition: Integer;
begin
  with Source as TCheckListBox do
  begin
    StartPosition := ItemAtPos(FStartingPoint, True);
    DropPosition := ItemAtPos(Point(x,y), False);
    if (DropPosition >= 0) then begin
      if (DropPosition >= chkColumns.Count) then
        DropPosition := chkColumns.Count - 1;
      FColManager.Move(StartPosition, DropPosition);
      Items.Move(StartPosition, DropPosition);
      Itemindex := DropPosition;
    end;
  end;
end;

procedure TfmeCustomColumn.chkColumnsDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  R: TRect;
  OldOverIndex, NewOverIndex: integer;
begin
  Accept := Source = chkColumns;
  if not Accept then Exit;

  OldOverIndex := FOldOverIndex;
  NewOverIndex := chkColumns.ItemAtPos(Point(X, Y), True);
  if (NewOverIndex <> OldOverIndex) then begin
    //Save old index
    FOldOverIndex := NewOverIndex;
    //Draw focus rect
    if (NewOverIndex >= 0) then begin
      R := chkColumns.ItemRect(NewOverIndex);
      chkColumns.Canvas.DrawFocusRect(R);
    end;
    //Clear old focus rect
    if (OldOverIndex >= 0)  then begin
      R := chkColumns.ItemRect(OldOverIndex);
      chkColumns.Canvas.DrawFocusRect(R);
    end;
  end;
end;

procedure TfmeCustomColumn.chkColumnsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FStartingPoint.X := X;
  FStartingPoint.Y := Y;
end;

procedure TfmeCustomColumn.chkColumnsStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  FOldOverIndex := -1;
end;

procedure TfmeCustomColumn.LoadCustomColumns;
var
  i: integer;
  ColIdx: integer;
  ColumnItem: TReportColumnItem;
begin
  chkColumns.Items.BeginUpdate;
  try
    chkColumns.Clear;
    for i := 0 to Pred(FColManager.Count) do begin
      ColumnItem := TReportColumnItem(FColManager.Columns[i]);
      ColIdx := chkColumns.Items.AddObject(ColumnItem.Title, TObject(ColumnItem));
      chkColumns.Checked[ColIdx] := ColumnItem.OutputCol;
      chkColumns.ItemEnabled[ColIdx] := not ColumnItem.DisableColumn;
    end;
    SyncColumns;
  finally
    chkColumns.Items.EndUpdate;
  end;
end;

procedure TfmeCustomColumn.OutputColumn(aDataToken: integer; Value: boolean);
var
  i: integer;
begin
  //Set output column flag
  for i := 0 to chkColumns.Count - 1 do
    if (TReportColumnItem(chkColumns.Items.Objects[i]).DataToken = aDataToken) then begin
      chkColumns.Checked[i] := Value;
      FColManager.OutputCol(i, Value);
      Exit;
    end;
end;

procedure TfmeCustomColumn.rbPortraitClick(Sender: TObject);
begin
  FColManager.Orientation := 0;
  if rbLandscape.Checked then
    FColManager.Orientation := 1;
end;

procedure TfmeCustomColumn.SetApplySettings(const Value: TCustomColumnEvent);
begin
  FOnApplySettings := Value;
end;

procedure TfmeCustomColumn.SetCustomReportType(const Value: TCustomReportType);
begin
  FCustomReportType := Value;
  case FCustomReportType of
    crCoding:
      begin
        FTemplateExt := CODING_RPT_LAYOUT_EXT;
        dlgSaveTemplate.FileName := Format('*%s', [CODING_RPT_LAYOUT_EXT]);
        dlgSaveTemplate.Filter := Format('Coding Report Layout (*%s)|*%s',
                                    [CODING_RPT_LAYOUT_EXT, CODING_RPT_LAYOUT_EXT]);
      end;
    crSuper:
      begin
        FTemplateExt := SUPER_RPT_LAYOUT_EXT;
        dlgSaveTemplate.FileName := Format('*%s', [SUPER_RPT_LAYOUT_EXT]);
        dlgSaveTemplate.Filter := Format('Superfund Report Layout (*%s)|*%s',
                                    [SUPER_RPT_LAYOUT_EXT, SUPER_RPT_LAYOUT_EXT]);
      end;
  end;
  dlgLoadTemplate.FileName := dlgSaveTemplate.FileName;
  dlgLoadTemplate.Filter := dlgSaveTemplate.Filter
end;

procedure TfmeCustomColumn.SetOnSaveSettings(const Value: TCustomColumnEvent);
begin
  FOnSaveSettings := Value;
end;

procedure TfmeCustomColumn.SetReportParams(const Value: TRPTParameters);
begin
  FReportParams := Value;
  FColManager := TCodingReportSettings(FReportParams).ColManager;
end;

procedure TfmeCustomColumn.SyncColumns;
var
  i: integer;
begin
  for i := 0 to Pred(ChkColumns.Count) do
    FColManager.OutputCol(i, ChkColumns.Checked[i]);
end;

procedure TfmeCustomColumn.UpdateActions;
begin
  btnUp.Enabled := chkColumns.ItemIndex > 0;
  btnDown.Enabled := (chkColumns.ItemIndex >= 0)
                  and  (chkColumns.ItemIndex < (chkColumns.Items.Count - 1));
end;

end.
