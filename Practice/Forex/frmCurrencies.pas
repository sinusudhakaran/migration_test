unit frmCurrencies;

interface

uses
  Virtualtreehandler,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, VirtualTrees,  ActnList, RzGroupBar,
  OsFont;

type
  TCurrenciesFrm = class(TForm)
    pButtons: TPanel;
    btnCancel: TButton;
    BtnoK: TButton;
    RSGroupBar: TRzGroupBar;
    grpStyles: TRzGroup;
    Splitter1: TSplitter;
    Panel1: TPanel;
    vtCurrencies: TVirtualStringTree;
    ActionList1: TActionList;
    acDelete: TAction;
    acAdd: TAction;
    grpDetails: TRzGroup;
    procedure FormCreate(Sender: TObject);
    procedure vtCurrenciesHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure vtCurrenciesNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; NewText: WideString);
    procedure vtCurrenciesEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure acAddExecute(Sender: TObject);
    procedure BtnoKClick(Sender: TObject);
    procedure acDeleteExecute(Sender: TObject);

  private
    FTreeList: TTreeBaseList;
    procedure FillCurrencies;
    function FindISO(value: string; Select: Boolean = False): Boolean;
    procedure Cleanup;
    { Private declarations }
  protected
    procedure UpdateActions; override;   
  public
    { Public declarations }
  end;

  function MaintainCurrencies: Boolean;

implementation

uses
  YesNoDlg,
  Imagesfrm,
  ErrorMoreFrm,
  bkBranding,
  ISO_4217,
  bkXPThemes,
  ExchangeRateList,
  Admin32,
  SysObj32,
  Globals;

{$R *.dfm}

  function MaintainCurrencies: Boolean;
  begin
      with TCurrenciesFrm.Create(Application.MainForm) do try
         Result := ShowModal = mrOK;
      finally
         Free;
      end;
  end;

const
   Tag_Iso = 1;
   Tag_Name = 2;
   Tag_Style = 3;

type
  TCurrencyTreeItem = class(TTreeBaseItem)
  private
     FISO: shortString;
     FCurType: Integer;
  public
     constructor Create(ISO: string; CurType: Integer);

     function GetTagText(const Tag: Integer): string; override;
  end;



procedure TCurrenciesFrm.acAddExecute(Sender: TObject);
var lnode: PVirtualNode;
    lnc: TCurrencyTreeItem;
begin
   // Make a New style name...
   lnc := TCurrencyTreeItem.Create('',ct_User);
   lNode := FTreeList.AddNodeItem(nil,lnc);
   vtCurrencies.Selected[lnode] := True;
   vtCurrencies.SetFocus;
   vtCurrencies.EditNode(LNode,0);
end;


procedure TCurrenciesFrm.acDeleteExecute(Sender: TObject);
var
   Lc: TCurrencyTreeItem;
   Node: PVirtualNode;
begin
   // Looking at the style list
   Lc := TCurrencyTreeItem(FTreeList.GetNodeItem(vtCurrencies.GetFirstSelected));
   if Assigned(Lc) then
   if Lc.FCurType = ct_User then
      if AskYesNo('Delete Currency',
      'Are you sure you want to delete curreny'#10'"' + Lc.Title + '"?', DLG_YES,0 )= DLG_YES then begin
          Node := Lc.Node;
          if Assigned(Node) then
            if Assigned(Node.NextSibling) then
               Node := Node.NextSibling
            else if Assigned(Node.PrevSibling) then
               Node := Node.PrevSibling
            else
               Node := nil;
          FTreeList.RemoveItem(Lc);
          // Reselect ..
          if Assigned(Node) then
             vtCurrencies.Selected[Node] := True;
      end;
end;

procedure TCurrenciesFrm.BtnoKClick(Sender: TObject);
var
  I,C: Integer;
  Lc: TCurrencyTreeItem;
begin
   // First just sorta validate...
   Cleanup;


   // Save...

   Admin32.LoadAdminSystem(True,'Currencies');
   FillChar(AdminSystem.fCurrencyList, Sizeof(AdminSystem.fCurrencyList),0);
   C := Low(AdminSystem.fCurrencyList.ehISO_Codes);
   for I := 0 to FtreeList.Count - 1 do begin
      Lc := TCurrencyTreeItem(FTreeList[I]);
      AdminSystem.fCurrencyList.ehISO_Codes[C] := lc.FISO;
      AdminSystem.fCurrencyList.ehCur_Type [C] := lc.FCurType;
      inc(C);
   end;
   Admin32.SaveAdminSystem();
   ModalResult := mrOK;
end;

procedure TCurrenciesFrm.Cleanup;

   function Remove: Boolean;
   var I: Integer;
       Lc: TCurrencyTreeItem;
       Node: PVirtualNode;
   begin
      Result := true;
      for I := 0 to FtreeList.Count - 1 do begin
         Lc := TCurrencyTreeItem(FTreeList[I]);
         if (lc.FCurType = ct_User)
         and (not Assigned(Get_ISO_4217_Record(lc.FISO))) then begin
            Node := Lc.Node;
            if Assigned(Node) then
               if Assigned(Node.NextSibling) then
                  Node := Node.NextSibling
               else if Assigned(Node.PrevSibling) then
                  Node := Node.PrevSibling
               else
                  Node := nil;
            FTreeList.RemoveItem(Lc);
            // Reselect ..
            if Assigned(Node) then
               vtCurrencies.Selected[Node] := True;
            Exit;
         end;
      end;
   Result := false;
end;

begin
   while Remove do;
end;

procedure TCurrenciesFrm.FillCurrencies;
var
   keep: TCursor;
   C: Integer;
begin
   keep := Screen.Cursor;
   Screen.Cursor := crHourGlass;
   vtCurrencies.BeginUpdate;
   try
      vtCurrencies.Clear;
      FTreeList.Clear;
      AdminSystem.SyncCurrenciesToSystemAccounts;
      for C := low(AdminSystem.fCurrencyList .ehISO_Codes) to high(AdminSystem.fCurrencyList.ehISO_Codes) do
        if AdminSystem.fCurrencyList.ehISO_Codes[C] > '' then begin
          FTreeList.AddNodeItem(nil,TCurrencyTreeItem.Create(
             AdminSystem.fCurrencyList.ehISO_Codes[C],
             AdminSystem.fCurrencyList.ehCur_Type [C] ));
        end;

   finally
      vtCurrencies.EndUpdate;
      Screen.Cursor := Keep;
   end;
end;

function TCurrenciesFrm.FindISO(value: string; Select: Boolean): Boolean;
var I: Integer;
begin
   for I := 0 to FtreeList.Count - 1 do
      if SameText(TCurrencyTreeItem(FTreeList[I]).FISO,Value) then begin
         Result := True;
         if select then
            vtCurrencies.Selected[TCurrencyTreeItem(FTreeList[I]).Node] := True;
         Exit;
      end;
   Result := false;
end;

procedure TCurrenciesFrm.FormCreate(Sender: TObject);
begin
   // Common bits
   bkXPThemes.ThemeForm(Self);
   vtCurrencies.Header.Font := Font;
   vtCurrencies.Header.Height := Abs(vtCurrencies.Header.Font.height) * 10 div 6;
   vtCurrencies.DefaultNodeHeight := Abs(Self.Font.Height * 15 div 8); //So the editor fits
   RSGroupBar.GradientColorStop := bkBranding.GroupBackGroundStopColor;
   RSGroupBar.GradientColorStart := bkBranding.GroupBackGroundStartColor;

   grpDetails.Items[0].Caption := format('Base currency: %s', [AdminSystem.fCurrencyCode]);

   FTreeList:= TTreeBaseList.Create(vtCurrencies);
   FillCurrencies;
end;

procedure TCurrenciesFrm.FormDestroy(Sender: TObject);
begin
   FTreeList.Free;
end;

procedure TCurrenciesFrm.UpdateActions;
var Ls: TCurrencyTreeItem;
begin
   // Looking at the style list
   Ls := TCurrencyTreeItem(FTreeList.GetNodeItem(vtCurrencies.GetFirstSelected));
   if Assigned(Ls) then begin
      acdelete.Enabled := ls.FCurType = ct_User;
   end else begin
      acdelete.Enabled := False;
   end;
end;

procedure TCurrenciesFrm.vtCurrenciesEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
var Ls: TCurrencyTreeItem;
begin
   Allowed := False;
   if Column = 0 then begin
      Ls := TCurrencyTreeItem(FTreeList.GetNodeItem(Node));
      if Assigned(ls) then
         Allowed := ls.FCurType = ct_User;
   end;
end;

procedure TCurrenciesFrm.vtCurrenciesHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
   if Column = vtCurrencies.Header.SortColumn then
      case vtCurrencies.Header.SortDirection of
         sdAscending: vtCurrencies.Header.SortDirection := sdDescending;
         sdDescending: vtCurrencies.Header.SortDirection := sdAscending;
      end
   else begin
      vtCurrencies.Header.SortColumn := Column;
      vtCurrencies.Header.SortDirection := sdAscending;
   end;

   with vtCurrencies.Header do
      vtCurrencies.SortTree(SortColumn, SortDirection);
end;

procedure TCurrenciesFrm.vtCurrenciesNewText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; NewText: WideString);

var
  NewIso: string;
  lc: TCurrencyTreeItem;
  lISO: pISO_4217_Record;
begin
 if FTreeList.GetColumnTag(Column) = Tag_Iso then begin

      NewIso := Uppercase(Trim(NewText)); // need to check more...
      lc := TCurrencyTreeItem(FTreeList.GetNodeItem(Node));
      if sametext(NewIso, lc.FISO) then
         Exit; // no change...

      if (Length(NewIso) = 0)
      or (Length(NewIso) > 3) then begin
         HelpfulErrorMsg('Please enter a 3 character ISO code',0);
         Exit;
      end;

      if FindISO(NewIso) then begin
         HelpfulErrorMsg(format(
         'ISO Currency Code "%s" is already in the list of currencies for your Practice'#13'You cannot have a curreny more than once', [NewISO]),0);
         Exit;
      end;
      // Now Test the ISO code
      lISO := Get_ISO_4217_Record(NewISO);
      if not Assigned(lISO) then begin
          HelpfulErrorMsg(format(
         'ISO Currency Code "%s" is not valid'#13'Please enter a correct code', [NewISO]),0);
          Exit;
      end;

      lc.FISO := NewISO;
      lc.Title := LISO.Name;
   end;
end;

{ TCurrencyTreeItem }

constructor TCurrencyTreeItem.Create(ISO: string; CurType: Integer);
var lISO: pISO_4217_Record;
begin
   inherited create('',0);
   FIso := Iso;
   FCurType := CurType;
   lISO := Get_ISO_4217_Record(ISO);
   if Assigned(lISO) then
      Title := lISO.Name;
end;

function TCurrencyTreeItem.GetTagText(const Tag: Integer): string;
begin
   case Tag of
     Tag_Iso : Result := FISO;
     Tag_Name : Result := Title;
     Tag_Style : case FCurType of
                  ct_System : Result := 'System';
                  ct_Base : Result := 'Base/Local';
                  ct_User : Result := 'User Added';
                 end;
   end;

end;

end.
