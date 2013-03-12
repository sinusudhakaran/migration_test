unit dlgReportStyles;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, ExtCtrls, ActnList,  Virtualtreehandler,RzGroupBar,
  StdCtrls,
  OsFont;

type
  TReportStylesDlg = class(TForm)
    RSGroupBar: TRzGroupBar;
    grpStyles: TRzGroup;
    ActionList1: TActionList;
    acAddStyle: TAction;
    acEditStyle: TAction;
    acRenamestyle: TAction;
    acDeleteStyle: TAction;
    acSimple: TAction;
    pnlLists: TPanel;
    vtStyles: TVirtualStringTree;
    pButtons: TPanel;
    btnCancel: TButton;
    BtnoK: TButton;
    Splitter1: TSplitter;
    procedure acAddStyleExecute(Sender: TObject);
    procedure acDeleteStyleExecute(Sender: TObject);
    procedure acEditStyleExecute(Sender: TObject);
    procedure acRenamestyleExecute(Sender: TObject);
    procedure vtStylesNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; NewText: WideString);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnoKClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure vtStylesHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  protected
    procedure UpdateActions;override;
  private
    FTreeList: TTreeBaseList;
    function FindName(value: string; Select: Boolean = False): Boolean;
    function NewStylename: string;
    { Private declarations }
  public
    { Public declarations }
  end;

function EditStyles(StartWith: string): Tmodalresult;


implementation

{$R *.dfm}
uses
   Globals,
   bkBranding,
   glConst,
   ReportTypes,
   ErrorMoreFrm,
   InfoMoreFrm,
   YesNoDlg,
   LockUtils,
   ReportStyleDlg,
   Imagesfrm, bkXPThemes;



function EditStyles(StartWith: string): Tmodalresult;
var MyForm: TReportStylesDlg;
begin
   MyForm := TReportStylesDlg.Create(Application.MainForm);
   try
      if StartWith > '' then
         MyForm.FindName(StartWith, True);
      Result := MyForm.ShowModal;
   finally
      MyForm.Free;
   end;
end;

const
   Tag_Simple = 2;
   Tag_Name   = 1;

type
 TStyleTreeItem = class(TTreeBaseItem)
  private
     FDoEdit: TAction;
     FStyle: TStyleItems;
     procedure SetDoEdit(const Value: TAction);
  public
     constructor Create(AName: string; Action: TAction);
     destructor Destroy; override;
     property DoEdit: TAction read FDoEdit write SetDoEdit;
     function GetTagText(const Tag: Integer): string; override;
     procedure AfterPaintCell(const Tag : integer; Canvas: TCanvas; CellRect: TRect);override;
     procedure DoubleClickTag(const Tag: Integer; Offset: TPoint); override;
     property Style: TStyleItems read FStyle;
  end;


{ TStyleTreeItem }

procedure TStyleTreeItem.AfterPaintCell(const Tag: integer; Canvas: TCanvas;
  CellRect: TRect);
begin
   {if Tag = Tag_Simple then
      if sametext(Title,INI_Report_Style) then
         AppImages.Period.Draw(Canvas, CellRect.Left, CellRect.Top, 0);}
end;

constructor TStyleTreeItem.Create(AName: string; action :TAction);
begin
   inherited create(AName,0);
   FStyle := TStyleItems.Create(AName);
   DoEdit := Action;
end;

destructor TStyleTreeItem.Destroy;
begin
   FStyle.Free;
   inherited;
end;

procedure TStyleTreeItem.DoubleClickTag(const Tag: Integer; Offset: TPoint);
begin
  inherited;
  if Tag = Tag_Name then
     if assigned(FDoEdit) then
        FDoEdit.Execute;
end;

function TStyleTreeItem.GetTagText(const Tag: Integer): string;
begin
   if Tag = Tag_Name then
      Result := Title;
end;

procedure TStyleTreeItem.SetDoEdit(const Value: TAction);
begin
   FDoEdit := Value;
end;



procedure TReportStylesDlg.acAddStyleExecute(Sender: TObject);
var lnode: PVirtualNode;
    lts: TStyleTreeItem;
begin
   // Make a New style name...
   lts := TStyleTreeItem.Create(NewStylename,acEditStyle);
   lNode := FTreeList.AddNodeItem(nil,lts);
   vtStyles.Selected[lnode] := True;
   vtStyles.SetFocus;
   vtStyles.EditNode(LNode,0);
end;


procedure TReportStylesDlg.acDeleteStyleExecute(Sender: TObject);
var Ls: TStyleTreeItem;
    Node: PVirtualNode;
begin
   Ls := TStyleTreeItem(FTreeList.GetNodeItem(vtStyles.GetFirstSelected));
   if not Assigned(Ls) then
      Exit;

    if AskYesNo('Delete report style',
      'Are you sure you want to delete report style'#10'"' + Ls.Title + '"?', DLG_YES,0 )= DLG_YES then begin
          Node := Ls.Node;
          if Assigned(Node) then
            if Assigned(Node.NextSibling) then
               Node := Node.NextSibling
            else if Assigned(Node.PrevSibling) then
               Node := Node.PrevSibling
            else
               Node := nil;
          FTreeList.RemoveItem(Ls);
          // Reselect ..
          if Assigned(Node) then
             vtStyles.Selected[Node] := True;
      end;

end;

procedure TReportStylesDlg.acEditStyleExecute(Sender: TObject);
var Lts: TStyleTreeItem;
    ls: TStyleitems;
    lnode: PVirtualNode;
begin
   Lts := TStyleTreeItem(FTreeList.GetNodeItem(vtStyles.GetFirstSelected));
   if not Assigned(Lts) then
      Exit; // nothing to edit...

   ls := TStyleitems.Create(''); // Make local copy...
   try
      ls.Assign(lts.Style);
      case EditReportStyle(ls) of
      mrYes : begin // Save as...
               // need a a new node
               lts := TStyleTreeItem.Create('',acEditStyle);
               lts.Style.Assign(ls);
               lts.Title := NewStylename;
               lts.Style.Name := lts.Title;
               lNode := FTreeList.AddNodeItem(nil,lts);

               vtStyles.Selected[lnode] := True;
               vtStyles.SetFocus;
               application.ProcessMessages;
               vtStyles.EditNode(LNode,0);
            end;
      mrOk : begin
               lts.Style.Assign(ls);
            end;
      end;
   finally
      ls.Free;
   end;
end;

procedure TReportStylesDlg.acRenamestyleExecute(Sender: TObject);
var Node: PvirtualNode;
begin
   Node := vtStyles.GetFirstSelected;
   if Assigned(Node) then begin
      vtStyles.SetFocus;
      vtStyles.EditNode(Node,0);
   end;
end;

procedure TReportStylesDlg.BtnoKClick(Sender: TObject);
  procedure SaveReportStyles;
  var I: Integer;
  begin
      for I := 0 to FtreeList.Count - 1 do
         TStyleTreeItem(TStyleTreeItem(FTreeList[I])).Style.Save
  end;
begin
  if FileLocking.ObtainLock(ltPracHeaderFooterImg, TimeToWaitForPracLogo) then
  begin
    try
      ClearStyles;
      SaveReportStyles;
    finally
      FileLocking.ReleaseLock(ltPracHeaderFooterImg);
    end;
  end;
  ModalResult := mroK;
end;

function TReportStylesDlg.FindName(value: string; Select: Boolean = False): Boolean;
var I: Integer;
begin
   for I := 0 to FtreeList.Count - 1 do
      if SameText(TStyleTreeItem(FTreeList[I]).Title,Value) then begin
         Result := True;
         if select then
            vtStyles.Selected[TStyleTreeItem(FTreeList[I]).Node] := True;
         Exit;
      end;
   Result := false;
end;

procedure TReportStylesDlg.FormCreate(Sender: TObject);
   procedure GetStyles;
   var I: integer;
       ll: TStringList;
   begin
      ll := TStringList.Create;
      try
         FillStyleList(ll);
         for I := 0 to ll.Count - 1 do
            FTreeList.AddNodeItem(nil,TStyleTreeItem.Create(ll[I],acEditStyle));
      finally
        ll.Free
      end;
   end;
begin
   bkXPThemes.ThemeForm(Self);
   vtStyles.Header.Font := Font;
   vtStyles.Header.Height := Abs(vtStyles.Header.Font.height) * 10 div 6;
   vtStyles.DefaultNodeHeight := Abs(Self.Font.Height * 15 div 8); //So the editor fits

   RSGroupBar.GradientColorStop := bkBranding.GroupBackGroundStopColor;
   RSGroupBar.GradientColorStart := bkBranding.GroupBackGroundStartColor;
   if UserINI_RS_GroupWidth > 0 then
      RSGroupBar.Width := UserINI_RS_GroupWidth;

   FTreeList:= TTreeBaseList.Create(vtStyles);
   GetStyles;
end;

procedure TReportStylesDlg.FormDestroy(Sender: TObject);
begin
   UserINI_RS_GroupWidth := RSGroupBar.Width;
   FTreeList.Free;
end;

procedure TReportStylesDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case ord(key) of
     VK_ESCAPE : begin
        Key := 0;
        ModalResult := mrCancel;
     end;
     VK_INSERT : begin
        Key := 0;
        acAddStyleExecute(nil);
     end;
     VK_RETURN : begin
        Key := 0;
        acEditStyleExecute(nil);
     end;
   end;
end;

function TReportStylesDlg.NewStylename: string;
var NS: Integer;
   
begin
   NS := 0;
   Result := 'New Style';
   while FindName(Result)  do begin
      Inc(NS);
      Result := 'New Style(' + IntToStr(NS) + ')';
   end;
end;

procedure TReportStylesDlg.updateactions;
var Ls: TStyleTreeItem;
begin
   // Looking at the style list
   Ls := TStyleTreeItem(FTreeList.GetNodeItem(vtStyles.GetFirstSelected));
   if Assigned(Ls) then begin
      //acSimple.Enabled := not sametext(ls.Title, INI_Report_Style);
      acDeleteStyle.Enabled := True;
      acEditStyle.Enabled := True;
      acRenameStyle.Enabled := True;
   end else begin
      //acSimple.Enabled := False;
      acDeleteStyle.Enabled := False;
      acEditStyle.Enabled := False;
      acRenameStyle.Enabled := False;
   end;
end;

procedure TReportStylesDlg.vtStylesHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
   case vtStyles.Header.SortDirection of
      sdAscending: vtStyles.Header.SortDirection := sdDescending;
      sdDescending: vtStyles.Header.SortDirection := sdAscending;
   end;
   with vtStyles.Header do
      vtStyles.SortTree(SortColumn, SortDirection);
end;

procedure TReportStylesDlg.vtStylesNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; NewText: WideString);
var NewName,
    OldName: string;
    ls: TStyleTreeItem;
    I: Integer;
const
     NoFilenamechars = ['$' , '%' ,',', '''', '`' , '-', '@','{' , '}',
                     '~','!','#','&','_','^','+','.','=','[',']'];
begin

  if FTreeList.GetColumnTag(Column) = Tag_Name then begin

      NewName := Trim(NewText); // need to check more...
      Ls := TStyleTreeItem(FTreeList.GetNodeItem(Node));
      if sametext(NewName, LS.Title) then
         Exit; // no change...

      if Length(NewName) = 0 then begin
         HelpfulErrorMsg('Please enter a longer name',0);
         Exit;
      end;

      if Length(NewName) > 20 then begin
         HelpfulErrorMsg('Please enter a name with 20 characters or less',0);
         Exit;
      end;

      for I := 1 to Length(NewName) do
         if NewName[I] in NoFilenamechars then begin
            HelpfulErrorMsg('Please do not use'+ #13
             + ' $, %, '','', '', `, -, @, {, }, ~, !, #, &, _, ^, +, ., =, [ or ]' + #13 +
             'In the Style name',0);
            Exit;
         end;

      if FindName(NewName) then begin
         HelpfulErrorMsg('Style "' + NewName + '" already exsits'#13'Please try something else',0);
         Exit;
      end;

      // The new Text is fine
      // update the current objects
      OldName := LS.Title;
      LS.Title := NewName;
      LS.Style.Name := NewName;
      // Update the dropdown

   end;
end;

end.
