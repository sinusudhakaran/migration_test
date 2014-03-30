unit ChartRemapfrm;

interface

uses
  Ecollect,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, ComCtrls, StdCtrls, ExtCtrls,VTEditors, Buttons,
  OSFont;

type

//TBoolCheck = (bSame, bFalse, bTrue);

PChartItem = ^TChartItem;
TChartItem = class(Tobject)
private

public
   OldCode: string;
   NewCode: string;
   NewName: string;
   TmpCode: string;
   //NewPost: TBoolCheck;
   OldItem: Pointer;
   ChartNode: PVirtualNode;
   // Should realy sub class them..
   function GetNewChartName: string;
   function GetNewChartCode: string;
   function GetNewGSTName: string;
   function GetNewGSTCode: string;
   function GetOldChartName: string;
   function GetOldGSTName: string;
   //function GetOldPostText: string;
   //function GetNewPostText: string;
end;


TNewChart = class(TExtdSortedCollection)
private
   FNewCode: string;
   FOldCode: string;
   fLookup: TChartItem;
   FTempID: Integer;
   procedure SetNewCode(const Value: string);
   procedure SetOldCode(const Value: string);
   function GetChartItems(Index: Integer): TChartItem;
   procedure SetChartItems(Index: Integer; const Value: TChartItem);
protected
   procedure FreeItem(Item : Pointer); override;
public
   function Compare(Item1,Item2 : Pointer): Integer; override;
   constructor Create; override;
   //procedure ReadFromFile(Filename: string);virtual;
   destructor Destroy; override;
   property OldCode: string read FOldCode write SetOldCode;
   property NewCode: string read FNewCode write SetNewCode;
   function Lookup(Code, Description: string; SkipBlank : Boolean = True):TChartItem;
   function Remap(Code: string; var Count: Integer): string;
   function NewTempCode: string;
   property ChartItems [index: Integer]: TChartItem read GetChartItems write SetChartItems;
end;



type
  TfrmRemapChart = class(TForm)
    pBtn: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    pcChart: TPageControl;
    tsChart: TTabSheet;
    tsGST: TTabSheet;
    ChartGrid: TVirtualStringTree;
    pChartTop: TPanel;
    pGSTTop: TPanel;
    GSTGrid: TVirtualStringTree;
    lChartFile: TLabel;
    eChartFile: TEdit;
    btnChartBrowse: TButton;
    OpenDlg: TOpenDialog;
    btnChart: TBitBtn;
    btnGSTChart: TBitBtn;
    btnGSTBrowse: TButton;
    EGstFile: TEdit;
    lGstFile: TLabel;
    pSave: TPanel;
    btnChartsave: TButton;
    btnChartSaveAs: TButton;
    pGSTSave: TPanel;
    btnGSTSave: TButton;
    btnGSTSaveAs: TButton;
    SaveDlg: TSaveDialog;
    procedure btnChartBrowseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnChartClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ChartGridGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure ChartGridCreateEditor(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure ChartGridEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure ChartGridNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; NewText: WideString);
    procedure ChartGridPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure ChartGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnGSTBrowseClick(Sender: TObject);
    procedure GSTGridGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure btnGSTChartClick(Sender: TObject);
    procedure GSTGridCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure GSTGridEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure ChartGridHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ChartGridCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure GSTGridHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GSTGridCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure GSTGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GSTGridNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; NewText: WideString);
    procedure btnChartSaveAsClick(Sender: TObject);
    procedure btnChartsaveClick(Sender: TObject);
    procedure btnGSTSaveClick(Sender: TObject);
    procedure btnGSTSaveAsClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure GSTGridPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure tsChartShow(Sender: TObject);
    procedure tsGSTShow(Sender: TObject);
    procedure ChartGridKeyPress(Sender: TObject; var Key: Char);
    procedure GSTGridKeyPress(Sender: TObject; var Key: Char);
    procedure ChartGridDblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

  private
    FNewChart: TNewChart;
    fChartCombo: TComboEditLink;
    fBoolCombo: TComboEditLink;
    FNewGST: TNewChart;
    fGSTCombo: TComboEditLink;
    FStatString: string;
    FGSTSel,
    FChartsel: TChartitem;
    // Chart
    procedure ReloadChart (SelItem: TChartItem = nil);
    procedure LoadChartFile(const Value: string);
    function SaveChartFile(const Value: string): Boolean;
    procedure LoadClientChart;
    function ValidateChart: Boolean;
    procedure RemapChart(Value: TNewChart);

    //Work..
    procedure RemapCharts;
    function SomethingToDo: Boolean;
    procedure AddCount(const Count: Integer; const Name: string);

    // GST
    function GSTIndex(const Value: string):Integer;
    procedure LoadGSTFile(const Value: string);
    function SaveGSTFile(const Value: string): Boolean;
    procedure LoadClientGST;
    procedure ReloadGST (SelItem: TChartItem = nil);
    function ValidateGST: Boolean;
    procedure RemapGST(Value: TNewChart);

    //Node Item Array
    function GetChartItem(index: pVirtualnode): TchartItem;
    function GetGSTItem(index: pVirtualnode): TchartItem;
    procedure SetChartItem(index: pVirtualnode; const Value: TchartItem);
    procedure SetGSTItem(index: pVirtualnode; const Value: TchartItem);
    property GSTItem [index: pVirtualnode]: TchartItem read GetGSTItem write SetGSTItem;
    property ChartItem [index: pVirtualnode]: TchartItem read GetChartItem write SetChartItem;
    procedure FocusGrid(Grid: TvirtualStringTree);
    function EditGrid(Grid: TvirtualStringTree; Key: Char): Boolean;

    procedure DblClickGrid(Grid: TVirtualStringTree);
    procedure HandleMessage(const MSG: string; Node: PVirtualNode; Tree: TVirtualStringTree);
    procedure SetChartFilename(const Value: string);
    procedure SetGSTFilename(const Value: string);
    function GetChartFilename: string;
    function GetGSTFilename: string;
    function OverWriteCheck(Value: string): Boolean;
    property ChartFilename: string read GetChartFilename write SetChartFilename;
    property GSTFilename: string read GetGSTFilename write SetGSTFilename;


    { Private declarations }
  protected
    procedure UpdateActions; override;
  public

    { Public declarations }
  end;

procedure RemapChart;

implementation

uses
   bkHelp,
   bdList32,
   BASUtils,
   YesNoDlg,
   ImagesFrm,
   UpdateMF,
   ClientHomePagefrm,
   files,
   bkConst,
   InfoMoreFrm,
   ErrorMoreFrm,
   STStrS,
   bkDefs,
   Globals,
   clOBJ32,
   bkXPThemes,
   AuditMgr,
   MainFrm;

{$R *.dfm}

const
  // Chart Columns
  ccOldCode = 0;
  ccOldName = 1;
  //ccOldPost = 2;
  ccNewCode = 2;
  ccNewName = 3;
  //ccNewPost = 5;

  // GST Columns
  cgOldCode = 0;
  cgOldName = 1;
  cgNewCode = 2;
  cgNewName = 3;

  BackupFile =   '.CVT';


// Some helpers

{function BoolText(const Value: TBoolCheck): string; overload;
begin
   case Value of
      bFalse: Result := 'N';
      bTrue: Result := 'Y';
      bSame: Result := '';
   end;
end;

function BoolText(const Value: Boolean): string; overload;
begin
   if Value then
      Result := 'Y'
   else
      Result := 'N'
end;

function BoolToCheck(const Value: Boolean): TBoolCheck;
begin
   if Value then
      Result := bTrue
   else
      Result := bFalse;
end;

function TextBool(const Value: string): TBoolCheck;
begin
   Result := bSame;
   if Value > '' then
      if Upcase(Value[1]) in ['Y','T','1'] then
         Result := bTrue
      else
         Result := bFalse;

end;}



procedure RemapChart;
var
  lDlg: TfrmRemapChart;
begin
   if not Assigned(MyClient) then
      Exit; // Savety Net..

   if not CloseMDIChildren then
      Exit; // Budgets don't have a refresh, they cannont handle a Chart Change...

   lDlg := TfrmRemapChart.Create(Application.MainForm);
   try
      case ldlg.ShowModal of
         mrOK    : begin
                     //*** Flag Audit ***
                     MyClient.ClientAuditMgr.FlagAudit(arChartOfAccounts);
                     MyClient.ClientAuditMgr.FlagAudit(arClientFiles); //VAT changes

                     RefreshHomepage;
                   end;
      end;
   finally
      LDlg.Free;
   end;
end;


{ TfrmRemapChart }

procedure TfrmRemapChart.AddCount(const Count: Integer; const Name: string);
begin
   if Count > 0 then
       fStatString := fStatstring + Format( #13'%s updated,', [Name]);
end;

procedure TfrmRemapChart.btnChartBrowseClick(Sender: TObject);
begin
   OpenDlg.FileName := ChartFilename;
   OpenDLG.Filter := 'CSV File *.csv|*.csv';
   OpenDLG.FilterIndex := 0;
   if OpenDlg.Execute then begin
      LoadChartFile(OpenDlg.FileName);
   end;
   FocusGrid(ChartGrid);
end;

procedure TfrmRemapChart.btnChartClick(Sender: TObject);
begin
   LoadClientChart;
   FocusGrid(ChartGrid);
end;

procedure TfrmRemapChart.btnChartSaveAsClick(Sender: TObject);
var LFilename : string;
begin
   LFilename := ChartFilename;
   if LFilename = '' then // make a default
      lFilename := Globals.DataDir + MyClient.clFields.clCode + '_ChartMap.csv';

   SaveDlg.FileName := lFilename;
   if SaveDlg.Execute then begin
      lFilename := SaveDlg.FileName;
      if OverWriteCheck(LFilename) then
         if SaveChartFile(LFilename) then
             ChartFilename := LFilename;
   end;
   FocusGrid(ChartGrid);
end;

procedure TfrmRemapChart.btnChartsaveClick(Sender: TObject);
begin
   if ChartFilename > '' then
      SaveChartFile(ChartFilename);
   FocusGrid(ChartGrid);   
end;

procedure TfrmRemapChart.btnGSTBrowseClick(Sender: TObject);
begin
   OpenDlg.FileName := GSTFilename;
   OpenDLG.Filter := 'CSV File *.csv|*.csv';
   OpenDLG.FilterIndex := 0;
   if OpenDlg.Execute then begin
      LoadGSTFile(OpenDlg.FileName);
   end;
   FocusGrid(GSTGrid);
end;

procedure TfrmRemapChart.btnGSTChartClick(Sender: TObject);
begin
   LoadClientGST;
   FocusGrid(GSTGrid);
end;

procedure TfrmRemapChart.btnGSTSaveAsClick(Sender: TObject);
var LFilename : string;
begin
   LFilename := GSTFilename;
   if LFilename = '' then
      lFilename := Globals.DataDir + MyClient.clFields.clCode + '_'+ MyClient.TaxSystemNameUC +'Map.csv';

   SaveDlg.FileName := lFilename;
   if SaveDlg.Execute then begin
      lFilename := SaveDlg.FileName;
      if OverWriteCheck(LFilename) then
         if SaveGSTFile(LFilename) then
            GSTFilename := LFilename;
   end;
   FocusGrid(GSTGrid);
end;

procedure TfrmRemapChart.btnGSTSaveClick(Sender: TObject);
begin
    if GSTFilename > '' then
      SaveGSTFile(GSTFilename);
    FocusGrid(GSTGrid);  
end;

procedure TfrmRemapChart.btnOKClick(Sender: TObject);
begin
   if ValidateChart
   and ValidateGST then
      RemapCharts;

end;

type
  // Just a locak type so we can set the Editor Lenght
  TTextEditLink = class(TStringEditLink)
  public
    constructor Create(const len: Integer);
  end;
  constructor TTextEditLink.Create(const len: Integer);
  begin
     inherited Create;
     Edit.MaxLength := Len;
  end;


procedure TfrmRemapChart.ChartGridCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
begin
    case column of
    ccOldCode : Result := CompareText(ChartItem[Node1].OldCode,         ChartItem[Node2].OldCode);
    ccOldName : Result := CompareText(ChartItem[Node1].GetOldChartName, ChartItem[Node2].GetOldChartName);
    ccNewCode : Result := CompareText(ChartItem[Node1].GetNewChartCode, ChartItem[Node2].GetNewChartCode);
    ccNewName : Result := CompareText(ChartItem[Node1].GetNewChartName ,ChartItem[Node2].GetNewChartName);
    //ccOldPost : Result := CompareText(ChartItem[Node1].GetOldPostText  ,ChartItem[Node2].GetOldPostText);
    //ccNewPost : Result := CompareText(ChartItem[Node1].GetNewPostText  ,ChartItem[Node2].GetNewPostText);
    end;
end;

procedure TfrmRemapChart.ChartGridCreateEditor(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
begin
    case column of
    ccOldCode : EditLink := fChartCombo.Link;
    ccNewCode : EditLink := TTextEditLink.Create(20);
    ccNewName : EditLink := TTextEditLink.Create(60);
    //ccNewPost : EditLink := fBoolCombo.Link;
    else EditLink := nil;
    end;
end;

procedure TfrmRemapChart.ChartGridDblClick(Sender: TObject);
begin
   //DblClickGrid(ChartGrid);
end;

procedure TfrmRemapChart.ChartGridEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
   if not Assigned(Node) then
      Exit;
   if Node.Index >= Cardinal(FNewChart.ItemCount) then
      Exit;

   Allowed :=  column in [ccOldCode, ccNewCode, ccNewName{,ccNewPost}];
end;

procedure TfrmRemapChart.ChartGridGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
begin
   if not Assigned(Node) then
      Exit;
   if Node.Index >= Cardinal(FNewChart.ItemCount) then
      Exit;

   with ChartItem[Node] do begin
      case Column of
         ccOldCode: CellText := OldCode;
         ccOldName: Celltext := GetOldChartName;
         //ccOldPost: CellText := GetOldPostText;
         ccNewCode: CellText := GetNewChartCode;
         ccNewName: Celltext := GetNewChartName;
         //ccNewPost: CellText := GetNewPostText;
      end;
   end;
end;

procedure TfrmRemapChart.ChartGridHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  //Chartgrid.BeginUpdate;
  if Chartgrid.Header.SortColumn = Column then begin
     if Chartgrid.Header.SortDirection = sdAscending then
        Chartgrid.Header.SortDirection := sdDescending
     else
        Chartgrid.Header.SortDirection := sdAscending;
  end else begin
     Chartgrid.Header.SortColumn := Column;
     Chartgrid.Header.SortDirection := sdAscending;
  end;
  //ChartGrid.SortTree();
  //Chartgrid.EndUpdate;

end;

procedure TfrmRemapChart.ChartGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var ni:TChartItem;
    ln: PVirtualNode;
begin
 if tsEditing in ChartGrid.TreeStates then
    Exit; //?? I wnont get any keys ??

 case key of
   VK_Return : Key := 0; // Wierd focus problem

   VK_Insert : begin
           ni := FNewChart.Lookup('', '', False);
           if Assigned(ni) then begin
              // Already Have a Blank one, Use this first..
              ChartGrid.Selected[ni.ChartNode] := True;
              ChartGrid.FocusedNode := ni.ChartNode;
           end else begin
              ni := TChartItem.Create;
              FNewChart.Insert(ni);
              ReloadChart(ni);

           end;
           ChartGrid.FocusedColumn := 0;
           Key := 0;
       end;
   VK_Delete : begin
         ln := ChartGrid.GetFirstSelected;
          if Assigned(ln) then begin
             ni := ChartItem[ln];
             if Assigned(ni) then
                FNewChart.DelFreeItem(ni);
             if Assigned(ln.NextSibling) then
                ln := ln.NextSibling
             else
                ln := ln.PrevSibling;
             if assigned(ln) then
                ni := ChartItem[ln]
             else
                ni := nil;
             ReloadChart(ni);
          end;
          key := 0;
      end;

   end;
end;


procedure TfrmRemapChart.ChartGridKeyPress(Sender: TObject; var Key: Char);
begin
  if tsEditing in ChartGrid.TreeStates then
     Exit;
   if key in [' '..'~'] then
            EditGrid(ChartGrid,Key);
end;

procedure TfrmRemapChart.ChartGridNewText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; NewText: WideString);

var lNew: tChartItem;
begin
   if not Assigned(Node) then
      Exit;

   if Node.Index >= Cardinal(FNewChart.ItemCount) then
      Exit;

   case column of
    ccOldCode :  begin
          //Can only be in the list once...
          if not Sametext(ChartItem[Node].OldCode , NewText) then begin
             // Check if I Have it in the list..
             lNew := FNewChart.Lookup(NewText, '');
             if Assigned(lNew) then begin
                HelpfulInfoMsg(Format('Code "%s" is already in the list',[NewText]) ,0);
                FChartSel := LNew;
             end else begin
                // Not in the list..
                ChartItem[Node].OldCode := NewText;
                // But is it in the chart...
                ChartItem[Node].OldItem := MyClient.clChart.FindCode(NewText);
                FNewChart.Sort;
                //ReloadChart;
             end;
          end;
      end;
    ccOldName{,
    ccOldPost }:; // ?? Should never happen
    ccNewCode : ChartItem[Node].NewCode := NewText;
    ccNewName : ChartItem[Node].NewName := NewText;
    //ccNewpost : ChartItem[Node].NewPost := TextBool (NewText);
    end;
    ChartGrid.SetFocus;
end;

procedure TfrmRemapChart.ChartGridPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
begin
  if not Assigned(Node) then
      Exit;
   if Node.Index >= Cardinal(FNewChart.ItemCount) then
      Exit;

   with ChartItem[Node] do begin
      case Column of
         ccOldCode: if not Assigned(OldItem) then
                       TargetCanvas.Font.Color := clRed;

         ccNewCode: if Assigned(OldItem)  // Check if Different
                    and (NewCode > '')
                    and (NewCode <>  pAccount_Rec(OldItem).chAccount_Code) then
                       TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold];

         ccNewName: if Assigned(OldItem)  // Check if Different
                    and (NewName > '')
                    and (NewName <>  pAccount_Rec(OldItem).chAccount_Description) then
                       TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold];



         {ccNewPost: if Assigned(OldItem)  // Check if Different
                    and (NewPost <> bSame)
                    and (NewPost <> BoolToCheck(pAccount_Rec(OldItem).chPosting_Allowed)) then
                       TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold];}
      end;
   end;
end;

procedure TfrmRemapChart.DblClickGrid(Grid: TVirtualStringTree);
var MousePos : TPoint;
    Node: PVirtualNode;
    Column : Integer;
begin
   // this somehow does not seem to work..
   MousePos := Mouse.CursorPos;
   MousePos := Grid.ScreenToClient(MousePos);
   Node := Grid.GetNodeAt(MousePos.x, MousePos.y, True,Column);

   if not Assigned(Node) then
      Exit;

   for Column := 0 to Grid.Header.Columns.Count - 1 do
      if (Grid.Header.Columns[Column].Left <= MousePos.x)
      and (Grid.Header.Columns[Column].Left
            + Grid.Header.Columns[Column].Width  > MousePos.x) then begin
           dec(MousePos.X, Grid.Header.Columns[Column].Left);
           Break;
      end;
   Grid.EditNode(Node,Column);
end;

function TfrmRemapChart.EditGrid(Grid: TvirtualStringTree; Key: Char): Boolean;
var lmsg: TMessage;
begin
   if Assigned(Grid.FocusedNode)
   and (Grid.FocusedColumn >= 0) then begin
      Result := Grid.EditNode(Grid.FocusedNode, Grid.FocusedColumn);
      if Result
      and (Grid.EditLink <> nil) then begin
         FillChar(lmsg, sizeof(lmsg),0);
         lmsg.Msg := WM_Char;
         lmsg.WParam := ord(Key);
         Grid.EditLink.ProcessMessage(lmsg);
      end;
      
   end else
      Result := False;
end;

type
  TComboEdit20Link = class(TComboEditLink)
  public
    function CreateEditControl: TWinControl; override;
  end;

  function TComboEdit20Link.CreateEditControl: TWinControl;
  begin
     Result := TComboBox.Create(nil);
     with TComboBox(Result) do
        MaxLength := 20;

  end;
type

TComboEdit5Link = class(TComboEditLink)
  public
    function CreateEditControl: TWinControl; override;
  end;

  function TComboEdit5Link.CreateEditControl: TWinControl;
  begin
     Result := TComboBox.Create(nil);
     with TComboBox(Result) do
        MaxLength := 5;

  end;


procedure TfrmRemapChart.FocusGrid(Grid: TvirtualStringTree);
begin
   Grid.SetFocus;
   if not Assigned(Grid.FocusedNode) then
      Grid.FocusedNode := Grid.GetFirst;
   if Grid.FocusedColumn < 0 then
      Grid.FocusedColumn := 0;
end;

procedure TfrmRemapChart.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
const
  CANCEL_PROMPT = 'All changes will be lost. Are you sure you want to exit?';
begin
  if not (ModalResult = mrOK) and btnOK.Enabled then
    CanClose :=  (AskYesNo('Confirm Cancel', CANCEL_PROMPT, Dlg_No, 0) = DLG_YES);
end;

procedure TfrmRemapChart.FormCreate(Sender: TObject);
var lList : TStringList;
    I: Integer;
    la: pAccount_Rec;
begin
   bkXPThemes.ThemeForm(Self);

   Self.HelpContext := BKH_Converting_a_chart_of_accounts;
   //Caption
   self.Caption := Format('Convert Chart of Accounts for %s', [MyClient.clExtendedName]);

   // Sort out Grid Fonts
   ChartGrid.Header.Font := Self.Font;
   ChartGrid.Header.Height := -Self.Font.Height * 10 div 6;
   ChartGrid.DefaultNodeHeight := -Self.Font.Height * 15 div 8; // Make room for the editor
   GSTGrid.Header.Font := Self.Font;
   GSTGrid.Header.Height := ChartGrid.Header.Height;
   GSTGrid.DefaultNodeHeight := ChartGrid.DefaultNodeHeight;

   // Grid DataSize
   ChartGrid.NodeDataSize := SizeOf(Pointer);
   GSTGrid.NodeDataSize := SizeOf(Pointer);

   // Tax Names
   tsGST.Caption := MyClient.TaxSystemNameUC;
   btnGSTChart.Caption := tsGST.Caption;
   lGSTFile.Caption := tsGST.Caption + ' remap file';

   //icons..
   ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP,btnChart.Glyph);
   ImagesFrm.AppImages.Coding.GetBitmap(12,btnGSTChart.Glyph);

   //Dialog Vars
   FNewGST := TNewChart.Create;
   FNewChart := TNewChart.Create;

   // Clean up the GST Classes
   (*  Not sure ...
   for I := low(MyClient.clFields.clGST_Class_Codes) to high(MyClient.clFields.clGST_Class_Codes) do
      if  (trim(MyClient.clFields.clGST_Class_Names[I]) = '') // can have a blank
      and (MyClient.clFields.clGST_Class_Types[I] = gtUndefined) then
         MyClient.clFields.clGST_Class_Codes[I] := '';
   *)

   // Fill the dropdown lists
   lList := TStringList.Create;
   try
      // Fill the Chart Dropdown
      LList.Clear;
      for I := MyClient.clChart.First to MyClient.clChart.Last do begin
         la := MyClient.clChart.Account_At(I);
         LList.Add(la.chAccount_Code);
      end;
      fChartCombo := TComboEdit20Link.Create(LList, csDropDown);

      // Fill the Boolean Dropdown
      lList.Clear;
      LList.Add('');
      LList.Add('Y');
      LList.Add('N');
      fBoolCombo := TComboEditLink.Create(LList, csDropDownlist);

      // Fill The GST Dropdown
      lList.Clear;
      for I := low(MyClient.clFields.clGST_Class_Codes) to high(MyClient.clFields.clGST_Class_Codes) do
         if MyClient.clFields.clGST_Class_Codes[I] > '' then
            LList.Add( MyClient.clFields.clGST_Class_Codes[I]);
      fGSTCombo := TComboEdit5Link.Create(LList, csDropDown);

   finally
      lList.Free;
   end;
   ReloadChart;
   ReloadGST;
end;



procedure TfrmRemapChart.FormDestroy(Sender: TObject);
begin
   FNewChart.Free;
   fChartCombo.Free;
   fBoolCombo.Free;
   FNewGST.Free;
   fGSTCombo.Free;
end;

procedure TfrmRemapChart.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
  Char(vk_Escape) : begin
          Key := #0;
          ModalResult := mrCancel;
      end;
  end;
end;

procedure TfrmRemapChart.FormShow(Sender: TObject);
begin
   pcChart.ActivePage := tsChart;
   ChartGrid.SetFocus;
end;

function TfrmRemapChart.GetChartFilename: string;
begin
  Result := eChartFile.Text;
end;

function TfrmRemapChart.GetChartItem(index: pVirtualnode): TchartItem;
begin
  Result := PchartItem(ChartGrid.GetNodeData(Index))^;
end;

function TfrmRemapChart.GetGSTFilename: string;
begin
   Result := EGSTFile.Text;
end;

function TfrmRemapChart.GetGSTItem(index: pVirtualnode): TchartItem;
begin
   Result := PchartItem(GSTGrid.GetNodeData(index))^;
end;

procedure TfrmRemapChart.GSTGridCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
begin
    case column of
    cgOldCode : Result := CompareText(GSTItem[Node1].OldCode,        GSTItem[Node2].OldCode);
    cgOldName : Result := CompareText(GSTItem[Node1].GetOldGSTName,  GSTItem[Node2].GetOldGSTName);
    cgNewCode : Result := CompareText(GSTItem[Node1].GetNewGSTCode,  GSTItem[Node2].GetNewGSTCode);
    cgNewName : Result := CompareText(GSTItem[Node1].GetNewGSTName , GSTItem[Node2].GetNewGSTName);
    end;
end;

procedure TfrmRemapChart.GSTGridCreateEditor(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
begin
    case column of
    cgOldCode : EditLink := fGSTCombo.Link;
    cgNewCode : EditLink := TTextEditLink.Create(GST_CLASS_CODE_LENGTH);
    cgNewName : EditLink := TTextEditLink.Create(60);
    else EditLink := nil;
    end;
end;

procedure TfrmRemapChart.GSTGridEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
   if not Assigned(Node) then
      Exit;
   if Node.Index >= Cardinal(FNewGST.ItemCount) then
      Exit;

   Allowed :=  column in [cgOldCode, cgNewCode, cgNewName];
end;

procedure TfrmRemapChart.GSTGridGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
begin
   if not Assigned(Node) then
      Exit;
   if Node.Index >= Cardinal(FNewGST.ItemCount) then
      Exit;

   with GSTItem[Node] do begin
      case Column of
         cgOldCode: CellText := OldCode;

         cgOldName: CellText := GetOldGSTName;

         cgNewCode: CellText := GetNewGSTCode;

         cgNewName: CellText := GetNewGSTName;
      end;
   end;
end;


procedure TfrmRemapChart.GSTGridHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
 if GSTGrid.Header.SortColumn = Column then begin
     if GSTGrid.Header.SortDirection = sdAscending then
        GSTGrid.Header.SortDirection := sdDescending
     else
        GSTGrid.Header.SortDirection := sdAscending;
  end else begin
     GSTGrid.Header.SortColumn := Column;
     GSTGrid.Header.SortDirection := sdAscending;
  end;
  // GST is not AutoSort ??
  GSTGrid.SortTree(GSTGrid.Header.SortColumn, GSTGrid.Header.SortDirection);
end;

procedure TfrmRemapChart.GSTGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var ni:TChartItem;
    ln: PVirtualNode;
begin
   if tsEditing in GSTGrid.TreeStates then
     Exit;
  case Key of
    VK_Return : Key := 0;

    VK_Insert : begin
           ni := FNewGST.Lookup('', '', False);
           if Assigned(ni) then begin
              // Already Have a Blank one, Use this first..
              GSTGrid.Selected[ni.ChartNode] := True;
              GSTGrid.FocusedNode := ni.ChartNode;
           end else begin
              ni := TChartItem.Create;
              FNewGST.Insert(ni);
              ReloadGST(ni);
           end;
           GSTGrid.FocusedColumn := 0;
           Key := 0;
       end;
    VK_Delete : begin
          ln := GSTGrid.GetFirstSelected;
          if Assigned(ln) then begin
             ni := GSTItem[ln];
             if Assigned(ni) then
                FNewGST.DelFreeItem(ni);
             if Assigned(ln.NextSibling) then
                ln := ln.NextSibling
             else
                ln := ln.PrevSibling;
             if assigned(ln) then
                ni := GSTItem[ln]
             else
                ni := nil;
             ReloadGST(ni);
          end;
          key := 0;
      end;
   end;
end;

procedure TfrmRemapChart.GSTGridKeyPress(Sender: TObject; var Key: Char);
begin
   if tsEditing in GSTGrid.TreeStates then
      Exit;
   if key in [' '..'~'] then
            EditGrid(GSTGrid,Key);
end;

procedure TfrmRemapChart.GSTGridNewText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; NewText: WideString);
var LNew: TChartitem;
begin
   if not Assigned(Node) then
      Exit;

   if Node.Index >= Cardinal(FNewGST.ItemCount) then
      Exit;

   case column of
    cgOldCode :  begin
          //Can only be in the list once...
          if not Sametext(GSTItem[Node].OldCode , NewText) then begin
             // Check if I Have it in the list..
             lNew := FNewGST.Lookup(NewText, '');
             if Assigned(lNew) then begin
                 HelpfulInfoMsg(Format('ID "%s" is already in the list',[NewText]) ,0);
                 FGstSel := lNew; // see if we can move to it..
             end else begin
                // Not in the list..
                GSTItem[Node].OldCode := NewText;
                // But is it in the Class list...
                GSTItem[Node].OldItem := Pointer(GSTIndex(NewText));
                FNewGST.Sort;
                //ReloadGST;
             end;
          end;
      end;
    cgOldName :; // ?? Should never happen
    cgNewCode : GSTItem[Node].NewCode := NewText;
    cgNewName : GSTItem[Node].NewName := NewText;
    end;
    GSTGrid.SetFocus;
end;

procedure TfrmRemapChart.GSTGridPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
begin
   if not Assigned(Node) then
      Exit;
   if Node.Index >= Cardinal(FNewGST.ItemCount) then
      Exit;

   with GSTItem[Node] do begin
      case Column of
         cgOldCode: if OldItem = nil then
                       TargetCanvas.Font.Color := clRed;

         cgNewCode: if (OldItem <> nil)  // Check if Different
                    and (NewCode > '')
                    and (NewCode <>  MyClient.clFields.clGST_Class_Codes[Integer(OldItem)]) then
                       TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold];

         cgNewName: if (OldItem <> nil)  // Check if Different
                    and (NewName > '')
                    and (NewName <>  MyClient.clFields.clGST_Class_Names[Integer(OldItem)]) then
                       TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold];

      end;
   end;
end;

function TfrmRemapChart.GSTIndex(const Value: string): Integer;
begin
   if Value > '' then
      for Result := low(MyClient.clFields.clGST_Class_Codes) to high(MyClient.clFields.clGST_Class_Codes) do
         if SameStr(MyClient.clFields.clGST_Class_Codes[Result], Value) then
           Exit;

   // Still here..
   Result := 0;  // -1 ??
end;

procedure TfrmRemapChart.HandleMessage(const MSG: string; Node: PVirtualNode;
  Tree: TVirtualStringTree);
begin
   if Tree = ChartGrid then
      pcChart.ActivePage := tsChart
   else
      pcChart.ActivePage := tsGST;
   Tree.Selected[Node] := True;
   HelpfulErrorMsg(MSG,0);
   Tree.FocusedNode := Node;
   Tree.SetFocus;
end;

procedure TfrmRemapChart.LoadChartFile(const Value: string);
const
   // Columns in the file..
   fcOldCode = 0;
   fcOldName = 1;
   fcNewCode = 2;
   fcNewName = 3;
   fcNewPost = 4;

var
   lFile, lLine: TStringList;
   L,R: Integer;
   nI: TChartItem;
begin
   lFile := TStringList.Create;
   lLine := TStringList.Create;
   try
      lLine.Delimiter := ',';
      lLine.StrictDelimiter := True;
      try
         lFile.LoadFromFile(Value);
       except
          on e: exception do begin
             HelpfulErrorMsg(Format( 'Cannot open file %s: %s',[Value, e.Message]),0);
             Exit;
          end;
       end;

       if lFile.Count = 0 then begin
          HelpfulErrorMsg(Format( 'Nothing found in file %s',[Value]),0);
          Exit;
       end;
       R := 0;
       // Parser the file...
       for L := 0 to lFile.Count - 1 do begin
          lLine.DelimitedText := LFile[L];
          if lLine.Count < 3 then
             Continue;
          if Length(lLine[fcOldCode]) < 1 then
             Continue;

          if Length(lLine[fcOldCode]) > 20 then begin
             HelpfulErrorMsg(Format('Old code too long in line %d ',[L]),0);
             Exit;
          end;

          if Length(lLine[fcNewCode]) > 20 then begin
             HelpfulErrorMsg(Format('New code too long in line %d ',[L]),0);
             Exit;
          end;

          if lLine.Count > fcNewName then
          if Length(lLine[fcNewName]) > 60 then begin
             HelpfulErrorMsg(Format('Description too long in line %d ',[L]),0);
             Exit;
          end;
          inc(R);
       end;
       if R = 0 then begin
          HelpfulErrorMsg(Format( 'Nothing found in file %s',[Value]),0);
          Exit;
       end;
       // Seems OK ...
       ChartFilename := Value;

       L := 0;
       
       while (FNewChart.ItemCount > 0) and (L < FNewChart.ItemCount) do
       begin
         nI := FNewChart.Items[L];

         if nI.OldCode = '' then
         begin
           FNewChart.Delete(nI);

           nI.Free;
         end
         else
         begin
           Inc(L);
         end;
       end;
  
       for L := 0 to lFile.Count - 1 do begin
          lLine.DelimitedText := LFile[L];

          if lLine.Count < 2 then
             Continue;
          if Length(lLine[fcOldCode]) < 1 then
             Continue;

          nI := FNewChart.Lookup(LLine[fcOldCode], LLine[fcOldName]);
          if not Assigned(nI) then begin
             // Insert a New one...
             nI := TChartItem.Create;
             nI.OldCode := LLine[fcOldCode];
             nI.OldItem := MyClient.clChart.FindCode(nI.OldCode);
             FNewChart.Insert(nI);
          end;
          // Update the item...
          if LLine[fcNewCode] <> ni.OldCode then
             nI.NewCode := LLine[fcNewCode];


          if lLine.Count > fcNewName then begin
             if ni.GetNewChartName <> LLine[fcNewName] then
                nI.NewName := LLine[fcNewName];
          end;
       end;
   finally
      lFile.Free;
      lLine.Free;
   end;
   ReloadChart;
end;


procedure TfrmRemapChart.LoadClientChart;
var I: Integer;
    la: pAccount_Rec;
    nI: TChartItem;
begin
  I := 0;

  while (FNewChart.ItemCount > 0) and (I < FNewChart.ItemCount) do
  begin
    nI := FNewChart.Items[I];

    if nI.OldCode = '' then
    begin
      FNewChart.Delete(nI);

      nI.Free;
    end
    else
    begin
      Inc(I);
    end;
  end;

   for I := MyClient.clChart.First to MyClient.clChart.Last do begin
      la := MyClient.clChart.Account_At(I);
      nI := FNewChart.Lookup(la.chAccount_Code, la.chAccount_Description);
      if not Assigned(ni) then begin
         ni := TChartItem.Create;
         ni.OldCode := la.chAccount_Code;
         ni.OldItem := la;
         FNewChart.Insert(ni);
      end;
   end;
   ReloadChart;
end;

procedure TfrmRemapChart.LoadClientGST;
var I: Integer;
    nI: TChartItem;
begin
  I := 0;

  while (FNewGST.ItemCount > 0) and (I < FNewGST.ItemCount) do
  begin
    nI := FNewGST.Items[I];

    if nI.OldCode = '' then
    begin
      FNewGST.Delete(nI);

      nI.Free;
    end
    else
    begin
      Inc(I);
    end;
  end;
  
   for I := low(MyClient.clFields.clGST_Class_Codes) to high(MyClient.clFields.clGST_Class_Codes) do
      if MyClient.clFields.clGST_Class_Codes[I] > '' then begin
         nI := FNewGST.Lookup(MyClient.clFields.clGST_Class_Codes[I], MyClient.clFields.clGST_Class_Names[I]);
         if not Assigned(ni) then begin
            ni := TChartItem.Create;
            ni.OldCode := MyClient.clFields.clGST_Class_Codes[I] ;
            ni.OldItem := pointer(I);
            FNewGST.Insert(ni);
         end;
      end;

   ReloadGST;
end;

procedure TfrmRemapChart.LoadGSTFile(const Value: string);
const
   // Columns in the GST file..
   fcOldCode = 0;
   fcOldName = 1;
   fcNewCode = 2;
   fcNewName = 3; // Optional..

var
   lFile, lLine: TStringList;
   L,R: Integer;
   nI: TChartItem;
begin
   GSTFilename := Value;
   lFile := TStringList.Create;
   lLine := TStringList.Create;
   try
      lLine.Delimiter := ',';
      lLine.StrictDelimiter := True;
      try
         lFile.LoadFromFile(Value);
      except
         on e: exception do begin
            HelpfulErrorMsg(Format( 'Cannot open file %s: %s',[Value, e.Message]),0);
            Exit;
         end;
      end;

      // Parser the file...
      R := 0;
      for L := 0 to lFile.Count - 1 do begin
         lLine.DelimitedText := LFile[L];

         if lLine.Count < 3 then
             Continue; // Allow for some dud lines...
         if Length(lLine[fcOldCode]) < 1 then
             Continue;

         if Length(lLine[fcOldCode]) > 5 then begin
            HelpfulErrorMsg(Format('Old code too long in line %d ',[L]),0);
            Exit;
         end;

         if Length(lLine[fcNewCode]) > 5 then begin
            HelpfulErrorMsg(Format('New code too long in line %d ',[L]),0);
            Exit;
         end;

         if lLine.Count > fcNewName then
         if Length(lLine[fcNewName]) > 60 then begin
            HelpfulErrorMsg(Format('Description too long in line %d ',[L]),0);
            Exit;
         end;
         Inc(R);
      end;

      if R = 0 then begin
         HelpfulErrorMsg(Format( 'Nothing found in file %s',[Value]),0);
         Exit;
      end;
      //OK Then ..
      GSTFilename := Value;

      L := 0;
      
      while (FNewGST.ItemCount > 0) and (L < FNewGST.ItemCount) do
      begin
        nI := FNewGST.Items[L];

        if nI.OldCode = '' then
        begin
          FNewGST.Delete(nI);

          nI.Free;
        end
        else
        begin
          Inc(L);
        end;
      end;
  
      for L := 0 to lFile.Count - 1 do begin
         lLine.DelimitedText := LFile[L];
         if lLine.Count < 2 then
             Continue;
         if Length(lLine[fcOldCode]) < 1 then
             Continue;

         nI := FNewGST.Lookup(LLine[0], LLine[1]);
         if not Assigned(nI) then begin
            // Insert a New one...
            nI := TChartItem.Create;
            nI.OldCode := LLine[fcOldCode];
            nI.OldItem := Pointer(GSTIndex(nI.OldCode));
            FNewGST.Insert(nI);
         end;
         // Update the item...
         if LLine[fcNewCode] <> nI.OldCode then
            nI.NewCode := LLine[fcNewCode];

         if lLine.Count > fcNewName then begin// Not all files have a new name...
            if LLine[fcNewName] <> ni.GetNewGSTName then
               nI.NewName := LLine[fcNewName];
         end;
      end;
   finally
      lFile.Free;
      lLine.Free;
   end;
   ReloadGST;
end;


function TfrmRemapChart.OverWriteCheck(Value: string): Boolean;
begin
   if FileExists(Value) then
      Result :=  AskYesNo( 'File Exists',
                   format( '%s'#13'already exists, do you want to overwrite?',[Value]),
                      dlg_yes, 0) = dlg_yes //overwrite
   else
      Result := True;// does not exist We'r ok..
end;

procedure TfrmRemapChart.ReloadChart(SelItem: TChartItem = nil);
var R: Integer;
    SelNode: PVirtualNode;
begin
  if SelItem = nil then begin
     // Try keep the last selected..
     SelNode := ChartGrid.GetFirstSelected;
     if Assigned(SelNode) then
        SelItem := ChartItem[SelNode];
  end;
  ChartGrid.BeginUpdate;
  try
     ChartGrid.Clear;
     if FNewChart.ItemCount = 0 then begin
        // add a blank line, so we can start..
        FNewChart.Insert( TChartItem.Create);
     end;


     for R  := 0 to FNewChart.Last do begin
        FNewChart.ChartItems[R].ChartNode := ChartGrid.AddChild(nil,FNewChart.ChartItems[R]);
        if FNewChart.ChartItems[R] = SelItem then begin
           ChartGrid.Selected[FNewChart.ChartItems[R].ChartNode] := True;
           ChartGrid.FocusedNode := FNewChart.ChartItems[R].ChartNode;
        end;
     end;

     if SelItem = nil then
        ChartGrid.Selected[ChartGrid.GetFirst] := True;
  finally
      ChartGrid.EndUpdate;
  end;
end;

procedure TfrmRemapChart.ReloadGST(SelItem: TChartItem);
var R: Integer;
    SelNode: PVirtualNode;
begin
  if SelItem = nil then begin
     // Try keep the last selected..
     SelNode := GSTGrid.GetFirstSelected;
     if Assigned(SelNode) then
        SelItem := GSTItem[SelNode];
  end;
  GSTGrid.BeginUpdate;
  try
     GSTGrid.Clear;

     if FNewGST.ItemCount = 0 then begin
        // add a blank line, so we can start..
        FNewGST.Insert( TChartItem.Create);
     end;

     for R  := 0 to FNewGST.Last do begin
        FNewGST.ChartItems[R].ChartNode := GSTGrid.AddChild(nil,FNewGST.ChartItems[R]);
        if FNewGST.ChartItems[R] = SelItem then begin
           GSTGrid.Selected[FNewGST.ChartItems[R].ChartNode] := true;
           GSTGrid.FocusedNode := FNewGST.ChartItems[R].ChartNode;
        end;
     end;

     if SelItem = nil then
        GSTGrid.Selected[GSTGrid.GetFirst ] := True;

  finally
     GSTGrid.EndUpdate;
  end;
end;

procedure TfrmRemapChart.RemapChart(Value: TNewChart);
var
  LCount,
  LCountA,
  LCountT,
  LCountM,
  LCountB,
  LCountC,
  LCountP: Integer;
  I, A, J: Integer;
  CI: TChartItem;
  Dis: pDissection_Rec;
  SaveAuditMgr: TClientAuditManager;
  Index: Integer;

  procedure ResortBudget(var bdList: TBudget_Detail_List);
  var LL: PPointerList;
    I,K,P,B: Integer;

  begin
     //Copy the old pointer list..
     K := bdList.ItemCount;
     getmem(LL,K * Sizeof(Pointer));
     Move(bdList.List^,LL^,K * Sizeof(Pointer));
     // Clear the old list
     bdList.ItemCount := 0;
     // Re insert the saved items in the list
     for I := 0 to k-1 do
        if bdList.Search(LL[I],P) then begin
           // Have to try and add them together
           with bdList.Budget_Detail_At(P)^ do
              for B := low(bdBudget) to High(bdBudget) do begin
                  bdBudget[B] :=  bdBudget[B] + pBudget_Detail_Rec(LL[I]).bdBudget[B];
                  // No Aples for aples..
                  bdQty_Budget[B] :=  0;
                  bdEach_Budget[B] := 0;
              end;
           // now get rid of the duplicate
           bdList.FreeItem(LL[I])
        end else
           bdList.Insert(LL[I]);
    // Get rid of the Temp list
    Freemem(LL,K * Sizeof(Pointer));
  end;


begin
    LCount := 0;
    LCountA := 0;
    // Do the chart itself..
    for I := 0 to MyClient.clChart.Last do
       with MyClient.clChart.Account_At(I)^ do begin
          CI := Value.Lookup(chAccount_Code, chAccount_Description);
          if Assigned(CI) and ((CI.NewCode > '') or (CI.NewName > '')) then
          begin
            if CI.NewCode > '' then
            begin
              chAccount_Code := CI.NewCode;
            end;

            if CI.NewName > '' then
            begin
              chAccount_Description  := CI.NewName;
            end;

            // Posting ??
            Inc(LCount);
          end;
          chLinked_Account_OS  := Value.Remap(chLinked_Account_OS,LCountA);
          chLinked_Account_CS  := Value.Remap(chLinked_Account_CS,LCountA);
       end;
    if LCount > 0 then begin // Need to Re-sort the Chart...
       //Prevent Audit ID's from being regenerated on sort
       MyClient.clChart.Sorting := True;
       try
         MyClient.clChart.Sort(true);
       finally
         MyClient.clChart.Sorting := False;
       end;
       AddCount(LCount,'Chart codes');
    end;

     // Do the GST Contras..
    for I := low(MyClient.clFields.clGST_Account_Codes) to high(MyClient.clFields.clGST_Account_Codes) do
       MyClient.clFields.clGST_Account_Codes[I] :=
          Value.Remap(MyClient.clFields.clGST_Account_Codes[I],LCountA);


    LCountT := 0;
    LCountM := 0;
    LCountB := 0;
    LCountC := 0;
    
    // Do The Accounts
    for A := 0 to MyClient.clBank_Account_List.Last do
       with MyClient.clBank_Account_List.Bank_Account_At(A) do
       begin
          baFields.baContra_Account_Code := Value.Remap(baFields.baContra_Account_Code,LCountA);
          baFields.baExchange_Gain_Loss_Code := Value.Remap(baFields.baExchange_Gain_Loss_Code, LCountB);
           
          // transactions...
          for I := 0 to baTransaction_List.ItemCount - 1 do
             with baTransaction_List.Transaction_At(I)^ do begin
                txAccount := Value.remap(txAccount,LCountT);
                Dis := txFirst_Dissection;
                while Dis <> nil do begin
                   Dis.dsAccount := Value.remap(Dis.dsAccount,LCountT);
                   Dis := Dis.dsNext;
                end;
             end;

          //Old Mems..
          {for I := 0 to baOld_Memorised_Transaction_List.ItemCount -1 do
              with baOld_Memorised_Transaction_List.Memorised_Transaction_At(I)^ do begin
                 for J :=  low(mxAccount) to High( mxAccount) do
                    mxAccount[J] :=  Value.remap(mxAccount[J],MemChangeCount);
              end; }

          // New Mems
          for I := 0 to baMemorisations_List.ItemCount -1 do
             with baMemorisations_List.Memorisation_At(I) do begin
                for J := 0  to mdLines.ItemCount -1 do
                   with mdLines.MemorisationLine_At(J)^ do
                      mlAccount := Value.Remap(mlAccount,LCountM);
             end;

          for Index := 0 to baExchange_Gain_Loss_list.ItemCount - 1 do
          begin
            with baExchange_Gain_Loss_List.Exchange_Gain_Loss_At(Index) do
            begin
              glFields.glAccount := Value.Remap(glFields.glAccount, LCountC);
            end;
          end;
       end; //account

    AddCount(LCountT, 'Transactions');
    AddCount(LCountM, 'Memorisations');
    AddCount(LCountA, 'Contra codes');
    AddCount(LCountB, 'Exchange Gain/Loss codes');
    AddCount(LCountC, 'Exchange Gain/Loss entries');

    // Payees
    LCount := 0;
    for I := 0 to MyClient.clPayee_List.ItemCount-1 do
       with MyClient.clPayee_List.Payee_At(I) do
          for J := 0 to pdLines.ItemCount - 1 do
            with pdLines.PayeeLine_At(J)^ do begin
                plAccount := Value.Remap(plAccount,LCount);
            end;

    AddCount(LCount, 'Payee lines');

    // Budgets
    LCount := 0;
    LCountP := 0;
    for I := 0 to MyClient.clBudget_List.ItemCount -1 do
       with MyClient.clBudget_List.Budget_At(I) do begin
          lCountT := 0;
          for J := 0 to buDetail.ItemCount - 1 do
             with buDetail.Budget_Detail_At(J)^ do
             begin
                bdAccount_Code    :=  Value.Remap(bdAccount_Code, lCountT);
                // Don't need LCountP, but I have to put something in there and I don't want to
                // increment lCountT twice, nor do I want to duplicate this block of code.
                bdPercent_Account := Value.Remap(bdPercent_Account, lCountP);
             end;
          if lCountT > 0 then begin
             ResortBudget(buDetail);
             inc(LCount,LCountT);
          end;
       end;

    AddCount(lCount,'Budget entries');

    // Do any BAs Rules
    LCount := 0;
    for I := BASUtils.MIN_SLOT to BASUtils.MAX_SLOT do
       if MyClient.clFields.clBAS_Field_Source[I] = bsFrom_Chart then
          MyClient.clFields.clBAS_Field_Account_Code[I] :=
             Value.Remap(MyClient.clFields.clBAS_Field_Account_Code[I],lCount);
    AddCount(lCount,'BAS Rules');
end;

procedure TfrmRemapChart.RemapCharts;
var
   Chart2,
   GST2: TNewChart;
   lStat: string;
   gI,gJ : Integer;

   procedure CheckFirstChartPass;
   var I: Integer;
       oI,nI: TChartItem;
   begin
      for I := 0 to fNewChart.ItemCount - 1 do begin
         oI := fNewChart.At(I);
         if oI.OldCode > '' then
         if Assigned(FNewChart.Lookup (oI.NewCode, oI.NewName))
         or Assigned(MyClient.clChart.FindCode(oI.NewCode)) then begin
            //New code is in the Old or used agian, have to change to somthing else first
            if not Assigned(Chart2) then
               Chart2 := TNewChart.Create;
            //Make the second pass item
            ni := TChartItem.Create;
            ni.OldCode := fNewChart.NewTempCode;
            ni.NewCode := oI.NewCode;
            ni.OldItem := nil;
            Chart2.Insert(ni);
            //Redirect the old item
            oI.NewCode := nI.OldCode;
         end;
      end;
   end; //CheckFirstChartPass

   procedure CheckFirstGSTPass;
   var I: Integer;
       oI,nI: TChartItem;
   begin
      for I := 0 to fNewGST.ItemCount - 1 do begin
         oI := fNewGST.At(I);
         if oI.OldCode > '' then
         if Assigned(FNewGST.Lookup (oI.NewCode, oI.NewName))
         or (GSTIndex(oI.NewCode) > 0) then begin
            //New code is in the Old GST Classes, ore used again
            if not Assigned(GST2) then
               GST2 := TNewChart.Create;
            // Make the secound pass item
            ni := TChartItem.Create;
            ni.OldCode := fNewGST.NewTempCode;
            ni.OldItem := nil;
            ni.NewCode := oI.NewCode;
            GST2.Insert(ni);
            //ReDirect the old item
            oI.NewCode := nI.OldCode; // Re sort...
         end;
      end;
   end;//CheckFirstGSTPass

   procedure RemapGSTID(FromId,ToId: Integer);
   var I,A, M: integer;
       Dis: pDissection_Rec;

       function NoNewCode(FromPos: Byte): Boolean;
       var I: Integer;
       begin
          Result := False;
          with MyClient.clFields do
          for I := BASUtils.MIN_SLOT to BASUtils.MAX_SLOT do
             if (clBAS_Field_Number[I] = clBAS_Field_Number[FromPos])// Same BAS field
             and (clBAS_Field_Source[I] = ToID) // ID to change to
             and (clBAS_Field_Balance_Type[I] = clBAS_Field_Balance_Type[FromPos])// Same Balance type
             and (clBAS_Field_Percent[I] = clBAS_Field_Percent[FromPos])
             then begin
                // Just use this one..
                // Clear the Old one..
                clBAS_Field_Percent[FromPos] := 0;
                clBAS_Field_Balance_Type[FromPos] := 0; //blGross;
                clBAS_Field_Number[FromPos] := 0;
                clBAS_Field_Source[FromPos] := 0;
                clBAS_Field_Account_Code[FromPos] := '';
                Exit;
             end;
          // Still here, not found
          Result := True;
       end;
   begin
       // Do the chart...
       for I := 0 to MyClient.clChart.Last do
       with MyClient.clChart.Account_At(I)^ do
          if chGST_Class = FromId then
             chGST_Class := ToId;

       // Do the Bankaccount
       for A := 0 to MyClient.clBank_Account_List.Last do
       with MyClient.clBank_Account_List.Bank_Account_At(A) do begin
          // Transactions..
          for I := 0 to baTransaction_List.ItemCount - 1 do
             with baTransaction_List.Transaction_At(I)^ do begin
                if txGST_Class = FromId then
                    txGST_Class := ToId;
                Dis := txFirst_Dissection;
                while Dis <> nil do begin
                   if Dis.dsGST_Class = FromId then
                      Dis.dsGST_Class := ToId;
                   Dis := Dis.dsNext;
                end;
             end;
          // Memorisations..
          for I := 0 to baMemorisations_List.ItemCount -1 do
             with baMemorisations_List.Memorisation_At(I) do
                for m := 0  to mdLines.ItemCount -1 do
                   with mdLines.MemorisationLine_At(m)^ do
                      if mlGST_Class = FromId then
                         mlGST_Class := ToId;
       end;
       // Do the Bas Rules

       for I := BASUtils.MIN_SLOT to BASUtils.MAX_SLOT do
         if MyClient.ClFields.clBAS_Field_Source[I] = fromID then begin
            if NoNewCode(I) then // Save to just change...
               MyClient.ClFields.clBAS_Field_Source[I] := ToID;

         end;
   end; //RemapGSTID

begin //TfrmRemapChart.RemapCharts;
  if (AdminSystem.fdFields.fdCountry <> whUK) then
  begin
    if askYesNo('Are you sure','You are about to convert the Chart of Accounts'#13 +
        'and change coding for this client file.'#13 +
        'These changes cannot be undone,'#13 +
        'except by clicking File, Abandon Changes.'#13#13 +
        'Are you sure you want to continue?',DLG_Yes,0) <> DLG_YES then
       Exit;
  end
  else
  begin
    if askYesNo('Are you sure','You are about to convert the Chart of Accounts'#13 +
        'and change coding for this client file.'#13 +
        'These changes cannot be undone.' + #13#13 +
        'Are you sure you want to continue?',DLG_Yes,0) <> DLG_YES then
       Exit;
  end;

    try
      frmMain.MemScanIsBusy := True;
      MyClient.clRecommended_Mems.RemoveAccountsFromMems;

      fStatString := '';
      Chart2 := nil;
      GST2 := nil;
      MyClient.CommonSave(BackupFile,True);
      try try
         // Check if we need a double pass.
         CheckFirstChartPass;
         CheckFirstGSTPass;

         // Do the first pass..
         fStatString := '';

         RemapChart(fNewChart);
         RemapGST(fNewGST);

         // Cleanup the message
         if fStatString > '' then begin
            if fStatString[Length(fStatString)] = ',' then
               fStatString[Length(fStatString)] := '.';
            fStatString := 'Chart has been converted successfully.'#13 + fStatString;
         end else begin
            // What else ???
            fStatString := 'Nothing found to convert!';
         end;
         lStat := fStatString;

         // Do the second pass
         if Assigned(Chart2) then
            RemapChart(Chart2);

         if Assigned(GST2) then
            RemapGST(GST2);


         // Check Double GST Codes..
         for gI := low(MyClient.clFields.clGST_Class_Codes) to high(MyClient.clFields.clGST_Class_Codes) do
         if  MyClient.clFields.clGST_Class_Codes[gI] > '' then
            for gJ := gI + 1 to high(MyClient.clFields.clGST_Class_Codes) do if
               MyClient.clFields.clGST_Class_Codes[gI] =
               MyClient.clFields.clGST_Class_Codes[gJ] then begin
                  //Remap to first Instance..
                  RemapGSTID(gJ,gI);
                  //Remove the second Instance..
                  MyClient.clFields.clGST_Class_Codes[gJ] := '';
                  MyClient.clFields.clGST_Class_Names[gJ] := '';
                  MyClient.clFields.clGST_Class_Types[gJ] := gtUndefined;
                  MyClient.clFields.clGST_Account_Codes[gJ] := '';
                  FillChar(MyClient.clFields.clGST_Rates[gJ],Sizeof(MyClient.clFields.clGST_Rates[gJ]),0);
               end;



         HelpfulInfoMsg(lStat,0);

         Modalresult := mrOK;
      except
         on E : Exception do begin
             HelpfulErrorMsg(Format( 'Cannot remap charts: '#13'%s',[e.Message]),0);
             AbandonChanges(false);
             // any first pass would have changed the remap
             ModalResult := mrCancel;
         end;
      end;
      finally
         if Assigned(Chart2) then
            FreeAndNil(Chart2);
         if Assigned(GST2) then
            FreeAndNil(GST2);
      end;
    finally
      // Recommended Mems may now include invalid chart codes, remake them
      // TODO: optimize this to just update the relevant recommended mems

      frmMain.MemScanIsBusy := False;
    end;
end;//TfrmRemapChart.RemapCharts;

procedure TfrmRemapChart.RemapGST(Value: TNewChart);
var
   I, J: Integer;
   lCount: Integer;
begin

    // Cleanup GST Codes
    (* Dont think this is needed anymore
    for I := 0 to fNewGST.ItemCount - 1 do
       with TChartItem(Value.Items[I]) do
       if OldCode > '' then
          for J := low(MyClient.clFields.clGST_Class_Codes) to high(MyClient.clFields.clGST_Class_Codes) do
             if MyClient.clFields.clGST_Class_Codes[J] = NewCode then begin
                if  (trim(MyClient.clFields.clGST_Class_Names[J]) = '') // can have a blank
                and (MyClient.clFields.clGST_Class_Types[J] = gtUndefined) then
                   MyClient.clFields.clGST_Class_Codes[J] := '';
               {else
                   raise Exception.Create( format(
                         'GST Code ''%s''  used more that once',[MyClient.clFields.clGST_Class_Codes[J]])
                         )}
            end;
    *)

    LCount := 0;
    for I := 0 to Value.ItemCount - 1 do
       with TChartItem(Value.Items[I]) do
       if OldCode > '' then begin
          // Do the GST Class
          for J := low(MyClient.clFields.clGST_Class_Codes) to high(MyClient.clFields.clGST_Class_Codes) do
             if MyClient.clFields.clGST_Class_Codes[J] = OldCode then begin
                if NewCode > '' then begin
                   MyClient.clFields.clGST_Class_Codes[J] := NewCode;
                   inc(lCount);
                end;
                if NewName > '' then
                   MyClient.clFields.clGST_Class_Names[J] := NewName;
             end;
       end;

    AddCount(LCount,MyClient.TaxSystemNameUC +' IDs');

end;

function TfrmRemapChart.SaveChartFile(const Value: string): Boolean;
var lFile,
    lLine : TStringList;
    I: Integer;
begin
   Result := False;
   if FNewChart.ItemCount < 1 then
      Exit; //Nothing to do

   lFile := TStringList.Create;
   lLine := TStringList.Create;
   try
      lLine.Delimiter := ',';
      lLine.StrictDelimiter := True;
      for I := 0 to FNewChart.Last do
         with FNewChart.ChartItems[I] do begin
            (* Save anyway, so we can use it as a master
            if (NewCode = '')
            and (NewName = '')
            {and (NewPost = bSame)}then
               Continue; // Nothing to save..
             *)

            if OldCode = '' then
               Continue; 
            // Start a new Line..
            lLine.Clear;

            lLine.Add(OldCode);
            lLine.Add(GetOldChartName);
            lLine.Add(GetNewChartCode);
            lLine.Add(NewName);
            {lline.Add(BoolText(NewPost));}

            // Add line to the 'File'
            LFile.Add(LLine.DelimitedText);
         end;
      // Save the file
      if lFile.Count > 0 then begin
         try
            LFile.SaveToFile(Value);
            Result := True;
         except
            on e: exception do begin
               HelpfulErrorMsg(Format( 'Cannot save to file %s: '#13'%s',[Value, e.Message]),0);
            end;
         end;
      end;
   finally
      lFile.Free;
      lLine.Free;
   end;
end;

function TfrmRemapChart.SaveGSTFile(const Value: string): Boolean;
var lFile,
    lLine : TStringList;
    I: Integer;
begin
   Result := False;
   if FNewGST.ItemCount < 1 then
      Exit; //Nothing to do

   lFile := TStringList.Create;
   lLine := TStringList.Create;
   try
      lLine.Delimiter := ',';
      lLine.StrictDelimiter := True;
      for I := 0 to FNewGST.ItemCount - 1 do
         with FNewGST.ChartItems[I] do begin

            (* Save anyway, so we can use it as a master
            if (NewCode = '')
            and (NewName = '') then
               Continue; // Nothing to save..
            *)

            if OldCode = '' then
               Continue;

            // Start a new Line..
            lLine.Clear;

            lLine.Add(OldCode);
            lLine.Add(GetOldGSTName);
            lLine.Add(GetNewGSTCode);
            lLine.Add(NewName);

            // Add line to the 'File'
            LFile.Add(LLine.DelimitedText);
         end;

      // Save the file
      if lFile.Count > 0 then begin
         try
            LFile.SaveToFile(Value);
            Result := True;
         except
            on e: exception do begin
               HelpfulErrorMsg(Format( 'Cannot save to file %s: '#13'%s',[Value, e.Message]),0);
            end;
         end;
      end;
   finally
      lFile.Free;
      lLine.Free;
   end;
end;

procedure TfrmRemapChart.SetChartFilename(const Value: string);
begin
   eChartFile.Text := Value;
end;

procedure TfrmRemapChart.SetChartItem(index: pVirtualnode;
  const Value: TchartItem);
begin

end;

procedure TfrmRemapChart.SetGSTFilename(const Value: string);
begin
  EGSTFile.Text := Value;
end;


procedure TfrmRemapChart.SetGSTItem(index: pVirtualnode;
  const Value: TchartItem);
begin

end;

function TfrmRemapChart.SomethingToDo: Boolean;
var I: Integer;
begin
  Result := True;
  for I := 0 to fNewChart.itemCount - 1 do
     if (fNewChart.ChartItems[I].NewCode > '') or (FNewChart.ChartItems[I].NewName > '')
     {or (fNewChart.ChartItems[I].NewName > '')} then
        // ? posting.
        Exit;

  for I := 0 to fNewGST.itemCount - 1 do
     if (fNewGST.ChartItems[I].NewCode > '') or (FNewGST.ChartItems[I].NewName > '')
     {or (fNewGST.ChartItems[I].NewName > '')} then
        Exit;

  // Nothing Found..
  Result := False;
end;

procedure TfrmRemapChart.tsChartShow(Sender: TObject);
begin
   FocusGrid(ChartGrid);
end;

procedure TfrmRemapChart.tsGSTShow(Sender: TObject);
begin
   FocusGrid(GSTGrid);
end;

procedure TfrmRemapChart.UpdateActions;
begin
  inherited;

  btnChartSave.Enabled := ChartFilename > '';
  btnGSTSave.Enabled := GSTFilename > '';

  btnChartSaveAs.Enabled := fNewChart.ItemCount > 0;
  btnGSTSaveAs.Enabled := fNewGST.ItemCount > 0;
  btnOK.Enabled := SomethingToDo;
  ///   When editing you can type a number that is already in the list
  ///   this sould help move to that item
  ///   Biut cannot guarantee that the node is still valid
  if Assigned(fChartSel)
  and ChartGrid.CanFocus then try
     ChartGrid.selected[fChartsel.ChartNode] := True;
     ChartGrid.FocusedNode := fChartsel.ChartNode;
     ChartGrid.FocusedColumn := 0;
     ChartGrid.SetFocus;
     fChartSel := nil;
  except
     fChartSel := nil;
  end;
  if Assigned(fGSTSel)
  and GSTGrid.CanFocus then try
     GSTGrid.selected[fGSTSel.ChartNode] := True;
     GSTGrid.FocusedNode := fGSTSel.ChartNode;
     GSTGrid.FocusedColumn := 0;
     GSTGrid.SetFocus;
     fGSTSel := nil;
  except
     fGSTSel := nil;
  end;

end;

function TfrmRemapChart.ValidateChart: Boolean;
var I : Integer;
begin
   Result := False;
   for I := 0 to fNewChart.ItemCount - 1 do
      with TChartItem(fNewChart.At(I)) do begin
         { Dual pass means this is ok..
         if Assigned(MyClient.clChart.FindCode(NewCode)) then begin
             HandleMessage(Format('Code "%s" is already in the chart.',[NewCode]),ChartNode, ChartGrid);
             Exit;
         end;}

         {if Assigned(FNewChart.Lookup (NewCode)) then begin
            HandleMessage(Format('Code "%s" , already in the conversion.',[NewCode]), ChartNode, ChartGrid);
            Exit;
         end; }
      end;
   //Still here..
   Result := True;
end;

function TfrmRemapChart.ValidateGST: Boolean;
var I : Integer;
begin
   Result := False;
   for I := 0 to fNewGST.ItemCount - 1 do
      with TChartItem(fNewGST.At(I)) do begin
         { Dual pass means this is OK
         if GSTIndex(NewCode) > 0 then begin
             HandleMessage(Format('Code "%s" is already a %s class.',[NewCode, MyClient.TaxSystemNameUC]),ChartNode, GSTGrid);
             Exit;
         end;  }

         {if Assigned(FNewGST.Lookup (NewCode)) then begin
            HandleMessage(Format('Code "%s" is already in the conversion.',[NewCode]), ChartNode, GSTGrid);
            Exit;
         end; }
      end;
   //Still here..
   Result := True;
end;


{ TNewChart }

function TNewChart.Compare(Item1, Item2: Pointer): Integer;
begin
  Result := STStrS.CompStringS(
               TChartItem(Item1).OldCode,
               TChartItem(Item2).OldCode
            );
end;

constructor TNewChart.Create;
begin
  inherited create;
  fLookup := TChartItem.Create;
  FTempID := 0;
  //Duplicates := false; is default

end;

destructor TNewChart.Destroy;
begin
  fLookup.Free;
  inherited;
end;

procedure TNewChart.FreeItem(Item: Pointer);
begin
   if Assigned(Item) then
      TChartItem(Item).Free;
end;


function TNewChart.GetChartItems(Index: Integer): TChartItem;
begin
  Result := TChartItem(self.at(Index));
end;


function TNewChart.Lookup(Code, Description: string; SkipBlank : Boolean = True): TChartItem;
var I: Integer;
begin
   Result := nil;
   if SkipBlank and (Code = '') and (Description = '') then
      Exit; //Exclude the Blank line that may be in the list
   fLookup.OldCode := Code;
   if Search(flookup,I) then
      Result := TChartItem(at(I));

end;



function TNewChart.NewTempCode: string;
begin
   inc(fTempID);
   Result := format('|~%d',[fTempID]);
end;

(*
procedure TNewChart.ReadFromFile(Filename: string);
var lFile,
    lLine: TStringList;
    L: Integer;
    CI:TChartItem;
begin
   if not (FileExists(FileName)) then
      raise Exception.Create('No Chart map file found' );

   lFile := TStringList.Create;
   lLine := TStringList.Create;
   try try
      lLine.Delimiter := ',';
      lLine.StrictDelimiter := true;
      lFile.LoadFromFile(Filename);
      if Lfile.Count < 3 then
         raise Exception.Create('Not enough lines' );
      //Check Header ??

      //Check ClientCode changes
      lLine.DelimitedText := lFile[1];
      if lLine.Count < 5 then
         raise Exception.Create(Format('Not enough fields on line $d ',[1]));
      OldCode := lLine[0];
      NewCode := lLine[1];

      // Read the Chart map
      for L := 2 to Lfile.Count - 1 do begin
          lLine.DelimitedText := lFile[L];
          if lLine.Count < 5 then
              raise Exception.Create(Format('Not enough fields on line %d ',[L]));
          // read the new Item
          if Length(lLine[0]) > 20 then
              raise Exception.Create(Format('Old Code too long in line %d ',[L]));
          if Length(lLine[1]) > 20 then
              raise Exception.Create(Format('New Code too long in line %d ',[L]));
          if Length(lLine[2]) > 60 then
              raise Exception.Create(Format('description too long in line %d ',[L]));

          CI := TChartItem.Create;
          CI.OldCode := lLine[0];
          CI.NewCode := lLine[1];
          CI.NewName := lLine[2];
          {
          if lLine[3]> '' then
             CI.NewTaxID := StrToInt(lLine[3]);

          if lLine[4]> '' then
             if UpperCase(lLine[4])[1] = 'Y' then
                CI.AllowPost := True;
           }

          Self.Insert(CI);
      end;
   except
      on E: Exception do
         raise Exception.Create(Format('%s while reading Chart map file',[e.message]));
   end;
   finally
      lFile.Free;
      lLine.Free;
   end;
end;
*)

function TNewChart.Remap(Code: string; var Count: Integer): string;
var I: Integer;
begin
   if Code = '' then begin
      Result := '';
   end else begin
      fLookup.OldCode := Code;
      if Search(flookup,I)
      and (ChartItems[I].NewCode > '') then begin
         Result := ChartItems[I].NewCode;
         Inc(Count);
      end else
         Result := Code;
   end;
end;



procedure TNewChart.SetChartItems(Index: Integer; const Value: TChartItem);
begin

end;

procedure TNewChart.SetNewCode(const Value: string);
begin
  FNewCode := Value;
end;

procedure TNewChart.SetOldCode(const Value: string);
begin
  FOldCode := Value;
end;



{ TChartItem }

function TChartItem.GetNewChartCode: string;
begin
   if (NewCode = '')
   and Assigned(OldItem) then
      Result := pAccount_Rec(OldItem).chAccount_Code
   else
      Result := NewCode;
end;

function TChartItem.GetNewChartName: string;
begin
   if (NewName = '')
   and Assigned(OldItem) then
      Result := pAccount_Rec(OldItem).chAccount_Description
   else
      Result := NewName;
end;

function TChartItem.GetNewGSTCode: string;
begin
   if (NewCode = '')
   and (OldItem <> nil) then
      Result := MyClient.clFields.clGST_Class_Codes[Integer(OldItem)]
   else
      Result := NewCode;
end;

function TChartItem.GetNewGSTName: string;
begin
   if (NewName = '')
   and (OldItem <> nil) then
      Result := MyClient.clFields.clGST_Class_Names[Integer(OldItem)]
   else
      Result := NewName;
end;

{function TChartItem.GetNewPostText: string;
begin
    if (NewPost = bSame)
    and Assigned(OldItem) then
       Result := BoolText(pAccount_Rec(OldItem).chPosting_Allowed)
    else
       Result := Booltext(NewPost);
end;}

function TChartItem.GetOldChartName: string;
begin
   if Assigned(OldItem) then
      Result := pAccount_Rec(OldItem).chAccount_Description
   else
      Result := '';
end;

function TChartItem.GetOldGSTName: string;
begin
   if OldItem <> nil then
      Result := MyClient.clFields.clGST_Class_Names[Integer(OldItem)]
   else
      Result := '';
end;


{function TChartItem.GetOldPostText: string;
begin
   if Assigned(OldItem) then
      Result := BoolText(pAccount_Rec(OldItem).chPosting_Allowed)
   else
      Result := '';
end; }

end.
