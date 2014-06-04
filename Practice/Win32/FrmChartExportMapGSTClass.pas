unit FrmChartExportMapGSTClass;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  OSFont,
  StdCtrls,
  ChartExportToMYOBCashbook,
  ovctchdr,
  ovctcedt,
  ovctcmmn,
  ovctcell,
  ovctcstr,
  ovctccbx,
  ovcbase,
  ovctable;

//------------------------------------------------------------------------------
type
  TFrmChartExportMapGSTClass = class(TForm)
    grpMain: TGroupBox;
    lblGstRemapFile: TLabel;
    edtGstReMapFile: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    btnSave: TButton;
    btnSaveAs: TButton;
    btnBrowse: TButton;
    SaveDlg: TSaveDialog;
    OpenDlg: TOpenDialog;
    tblGSTReMap: TOvcTable;
    OvcController: TOvcController;
    colCashBookGSTDropDown: TOvcTCComboBox;
    colID: TOvcTCString;
    colClassDescription: TOvcTCString;
    colHeader: TOvcTCColHead;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnSaveAsClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure tblGSTReMapGetCellData(Sender: TObject; RowNum, ColNum: Integer;
      var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure tblGSTReMapGetCellAttributes(Sender: TObject; RowNum,
      ColNum: Integer; var CellAttr: TOvcCellAttributes);
    procedure colCashBookGSTDropDownChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    fDirty : boolean;
    fGSTMapCol : TGSTMapCol;
    fOkPressed : boolean;

    function OverWriteCheck(aFileName: string): Boolean;

    procedure Refesh;
    function Validate() : boolean;
  public
    function Execute : boolean;

    property GSTMapCol : TGSTMapCol read fGSTMapCol write fGSTMapCol;
    property Dirty : boolean read fDirty write fDirty;
  end;

  //----------------------------------------------------------------------------
  function ShowMapGSTClass(w_PopupParent: Forms.TForm; aGSTMapCol : TGSTMapCol) : boolean;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  ErrorMoreFrm,
  WarningMoreFrm,
  Globals,
  YesNoDlg,
  LogUtil,
  bkBranding,
  BKHelp;

const
  UnitName = 'FrmChartExportMapGSTClass';
  IDCol           = 0;
  DescriptionCol  = 1;
  MYOBCashBookCol = 2;

var
  Teststring : ShortString = 'Test string';


//------------------------------------------------------------------------------
function ShowMapGSTClass(w_PopupParent: Forms.TForm; aGSTMapCol : TGSTMapCol) : boolean;
var
  MyDlg : TFrmChartExportMapGSTClass;
begin
  result := false;

  MyDlg := TFrmChartExportMapGSTClass.Create(Application.mainForm);
  try
    MyDlg.PopupParent := w_PopupParent;
    MyDlg.PopupMode   := pmExplicit;
    MyDlg.GSTMapCol   := aGSTMapCol;

    BKHelpSetUp(MyDlg, BKH_Export_chart_to_COMPANY_NAME1_Essentials_Cashbook);
    Result := MyDlg.Execute;
  finally
    FreeAndNil(MyDlg);
  end;
end;

{ TFrmChartExportMapGSTClass }
//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.btnBrowseClick(Sender: TObject);
const
  ThisMethodName = 'btnBrowseClick';
var
  FileName : string;
  ErrorStr : string;
begin
  FileName := edtGstReMapFile.Text;

  OpenDlg.FileName := FileName;
  OpenDLG.Filter := 'CSV File *.csv|*.csv';
  OpenDLG.FilterIndex := 0;
  if OpenDlg.Execute then
  begin
    FileName := OpenDlg.FileName;
    if GSTMapCol.LoadGSTFile(FileName, ErrorStr) then
    begin
      edtGstReMapFile.Text := FileName;
      btnSave.Enabled := true;
      Refesh;
    end
    else
    begin
      HelpfulErrorMsg(ErrorStr,0);
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + ErrorStr );
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.btnSaveClick(Sender: TObject);
const
  ThisMethodName = 'btnSaveClick';
var
  FileName : string;
  ErrorStr : string;
begin
  FileName := edtGstReMapFile.Text;

  if not GSTMapCol.SaveGSTFile(FileName, ErrorStr) then
  begin
    HelpfulErrorMsg(ErrorStr,0);
    LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + ErrorStr );
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.colCashBookGSTDropDownChange(
  Sender: TObject);
begin
  fDirty := true;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.btnSaveAsClick(Sender: TObject);
const
  ThisMethodName = 'btnSaveAsClick';
var
  FileName : string;
  ErrorStr : string;
begin
  FileName := edtGstReMapFile.Text;

  if FileName = '' then
    FileName := Globals.DataDir + MyClient.clFields.clCode + '_'+ MyClient.TaxSystemNameUC + 'Map.csv';

  SaveDlg.FileName := FileName;
  if SaveDlg.Execute then
  begin
    FileName := SaveDlg.FileName;
    if OverWriteCheck(FileName) then
    begin
      if GSTMapCol.SaveGSTFile(FileName, ErrorStr) then
      begin
        edtGstReMapFile.Text := FileName;
        btnSave.Enabled := true;
      end
      else
      begin
        HelpfulErrorMsg(ErrorStr,0);
        LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + ErrorStr );
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.btnOkClick(Sender: TObject);
begin
  tblGSTReMap.StopEditingState(True);

  fOkPressed := true;
end;

//------------------------------------------------------------------------------
function TFrmChartExportMapGSTClass.OverWriteCheck(aFileName: string): Boolean;
begin
  if FileExists(aFileName) then
    Result :=  AskYesNo('File Exists',
                        format( '%s'#13'already exists, do you want to overwrite?',[aFileName]),
                        dlg_yes, 0) = dlg_yes //overwrite
  else
    Result := True;// does not exist We'r ok..
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.Refesh;
begin
  tblGSTReMap.RowLimit := GSTMapCol.Count+1;
  tblGSTReMap.Refresh;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.tblGSTReMapGetCellAttributes(
  Sender: TObject; RowNum, ColNum: Integer; var CellAttr: TOvcCellAttributes);
var
  CurrGSTMapItem : TGSTMapItem;
begin
  if (CellAttr.caColor = tblGSTReMap.Color) and (RowNum >= tblGSTReMap.LockedRows) then
  begin
    if (RowNum > 0) then
    begin
      if (GSTMapCol.ItemAtColIndex(RowNum-1, CurrGSTMapItem)) and
         (ColNum = MYOBCashbookCol) and
         (CurrGSTMapItem.DispMYOBIndex = -1) then
        CellAttr.caColor := clRed
      else
      begin
        if Odd(RowNum) then
           CellAttr.caColor := clWindow
        else
           CellAttr.caColor := bkBranding.GSTAlternateLineColor;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.tblGSTReMapGetCellData(Sender: TObject;
  RowNum, ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
var
  CurrGSTMapItem : TGSTMapItem;
begin
  data := nil;
  if (RowNum > 0) and
     (GSTMapCol.ItemAtColIndex(RowNum-1, CurrGSTMapItem)) then
  begin
    Case ColNum of
      IDCol: begin
        data := @CurrGSTMapItem.DispPracCode;
      end;
      DescriptionCol : begin
        data := @CurrGSTMapItem.DispPracDesc;
      end;
      MYOBCashbookCol : begin
        data := @CurrGSTMapItem.DispMYOBIndex;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TFrmChartExportMapGSTClass.Validate: boolean;
begin
  Result := true;

  if not GSTMapCol.CheckIfAllGstCodesAreMapped() then
  begin
    Result := false;
    HelpfulWarningMsg('Please assign all GST classes',0);
    Exit;
  end;
end;

//------------------------------------------------------------------------------
function TFrmChartExportMapGSTClass.Execute: boolean;
var
  GstClassIndex : integer;
begin
  fDirty := false;

  if (GSTMapCol.PrevGSTFileLocation <> '') and
     (FileExists(GSTMapCol.PrevGSTFileLocation)) then
  begin
    edtGstReMapFile.Text := GSTMapCol.PrevGSTFileLocation;
    btnSave.Enabled := true;
  end;

  colCashBookGSTDropDown.Items.Clear;
  for GstClassIndex := 0 to length(GSTMapCol.GetGSTClassMapArr)-1  do
  begin
    colCashBookGSTDropDown.Items.Add(GSTMapCol.GetGSTClassMapArr[GstClassIndex].CashbookGstClassDesc);
  end;

  fOkPressed := false;

  Refesh;

  Result := (ShowModal = mrOK);
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := true;
  if fOkPressed then
  begin
    fOkPressed := false;

    CanClose := Validate();
    if not CanClose then
      Exit;

    if (fDirty) and
       (edtGstReMapFile.Text = '') then
    begin
      if (AskYesNo('Save this mapping','Would you like to save this mapping?', dlg_yes, 0) = DLG_YES) then
      begin
        btnSaveAsClick(Sender);
      end;
    end;

    GSTMapCol.PrevGSTFileLocation := edtGstReMapFile.Text;
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.FormShow(Sender: TObject);
begin
  if GSTMapCol.Count > 0 then
  begin
    tblGSTReMap.SetActiveCell(1, MYOBCashBookCol);
    tblGSTReMap.SetFocus;
  end;
end;

end.
