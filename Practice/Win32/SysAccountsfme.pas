unit SysAccountsfme;

interface

uses
  Contnrs,
  CMFilterForm,
  MoneyDef,
  MoneyUtils,
  RZGroupbar,VirtualTreeHandler, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,syDefs, VirtualTrees, ExtCtrls, StdCtrls, Menus,
  OsFont, ActnList;


type
    TSABaseItem = class (TTreeBaseItem)
    private
       fClientCode: string;
       fClientName: string;
       function GetClientCode: string;
       function GetClientName: string;

    public
       SysAccount :PSystem_Bank_Account_Rec;
       IsOffsite: Boolean;
       constructor Create(aSysAccount :pSystem_Bank_Account_Rec; AGroup: Integer);
       function GetTagText(const Tag: Integer): string; override;
       procedure OnPaintText(const Tag : integer; Canvas: TCanvas;TextType: TVSTTextType );override;
       function GetNodeHeight (const Value : Integer) : Integer; override;
       function GetTagHint(const Tag: Integer; Offset : TPoint) : string; override;
       function CompareGroup(const Tag : integer; WithItem : TTreeBaseItem; SortDirection : TSortDirection) : Integer; override;
       function CompareTagText(const Tag: integer; WithItem: TTreeBaseItem; SortDirection: TSortDirection) : Integer; override;
       function GetImageindex: Integer;
       function GetBalance: Money;
       property ClientName: string read GetClientName;
       property ClientCode: string read GetClientCode;
    end;


type
  TfmeSysAccounts = class(TFrame)
    pTop: TPanel;
    AccountTree: TVirtualStringTree;
    cbFilter: TComboBox;
    pmHeader: TPopupMenu;
    btnFilter: TButton;
    btnSearchClear: TButton;
    btnResetFilter: TButton;
    EBFind: TEdit;
    Label1: TLabel;
    lblCount: TLabel;
    SearchTimer: TTimer;
    Frameactions: TActionList;
    actFilter: TAction;
    actReset: TAction;
    actRestoreColumns: TAction;
    procedure AccountTreeHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure AccountTreeGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure AccountTreeKeyPress(Sender: TObject; var Key: Char);
    procedure cbFilterChange(Sender: TObject);
    procedure pmHeaderPopup(Sender: TObject);
    procedure AccountTreeHeaderDragging(Sender: TVTHeader; Column: TColumnIndex;
      var Allowed: Boolean);
    procedure SearchTimerTimer(Sender: TObject);
    procedure btnSearchClearClick(Sender: TObject);
    procedure EBFindChange(Sender: TObject);
    procedure EBFindKeyPress(Sender: TObject; var Key: Char);
    procedure actFilterExecute(Sender: TObject);
    procedure actResetExecute(Sender: TObject);
    procedure actRestoreColumnsExecute(Sender: TObject);
    procedure AccountTreeBeforeItemPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
      var CustomDraw: Boolean);
    procedure AccountTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AccountTreeClick(Sender: TObject);

  private
    fAccountList: TTreeBaseList;
    fGroupList: TObjectList;
    FInclude: saFilterSet;
    FSearchText: string;
    procedure SetSelected(const Value: PSystem_Bank_Account_Rec);
    function GetAccounts(Index: PVirtualNode): TSABaseItem;
    procedure SetAccounts(Index: PVirtualNode; const Value: TSABaseItem);
    procedure SetInclude(const Value: saFilterSet);
    function GetAccountList: TTreeBaseList;
    procedure SetOnSelectionChanged(const Value: TNotifyEvent);
    function GetOnSelectionChanged: TNotifyEvent;
    function GetSelected: PSystem_Bank_Account_Rec;
    procedure SetSelectedList(const Value: string);
    function GetSelectedList: string;
    // Column Handeling
    procedure mniShowHideColumnsClick(Sender: TObject);
    function GetColumn(Tag: Integer): TVirtualTreeColumn;
    function ColumnVisible(Tag: Integer):Boolean;
    procedure DefaultSort;
    procedure SetSearchText(const Value: string);
    // Group Handling
    function TestNewGroup(const Value: Integer):TSABaseItem; overload;
    function TestNewGroup(const Value: string; var CurGroup: Integer):TSABaseItem; overload;
    { Private declarations }
  public
    procedure DoCreate(const SavedCols: string);
    procedure DoDestroy(var SaveCols: string);
    procedure ReloadAccounts(SelAccount: string = '');
    procedure FixColumns;
    procedure BeginUpdate;
    procedure EndUpdate;
    property AccountList: TTreeBaseList read GetAccountList;
    property Accounts [Index :PVirtualNode]: TSABaseItem read GetAccounts write SetAccounts;
    property Selected: PSystem_Bank_Account_Rec read GetSelected write SetSelected;
    property SelectedList: string read GetSelectedList write SetSelectedList;
    property Include: saFilterSet read FInclude write SetInclude;
    property SearchText: string read FSearchText write SetSearchText;
    function AddColumn(Name: string; Position,Tag, width: Integer):TVirtualTreeColumn; overload;
    function AddColumn(Position, Tag, width: Integer):TVirtualTreeColumn; overload;
    function ColumnName(Tag: Integer): string;
    property OnSelectionChanged: TNotifyEvent read GetOnSelectionChanged write SetOnSelectionChanged;
    // Just a helper..
    function GetStringList(FromText: string):tStringList; // Should make a class..
    function AccountsHaveFrequencyInfo: Boolean;
    { Public declarations }
  end;

const
  //CollumnTags
  // Don't change these, because thats how they where saved
  cot_ClientCode   = 1;
  cot_ClientName   = 2;
  cot_AccNo        = 3;
  cot_AccName      = 4;
  cot_AccBal       = 5; //now removed..
  cot_FirstDate    = 6;
  cot_LastDate     = 7;
  cot_Delivered    = 8;
  cot_CurrencyCode = 9;
  cot_Status       = 10;
  cot_NoCharge     = 11;
  cot_Institution  = 12;
  cot_Inactive     = 13;
  cot_Frequency    = 14;

  // Only for Supper user, so no point saving or moving them
  cot_Offsite      = 101;
  cot_LRN          = 102;
  cot_TLRN         = 103;


const
  //CBFilter index
  cbf_All        = 0;
  cbf_Attached   = 1;
  cbf_New        = 2;
  cbf_Unattached = 3;
  cbf_Deleted    = 4;
  cbf_Inactive   = 5;
  cbf_Provisional= 6;

implementation

{$R *.dfm}

uses
  RZCommon,
  RzGrafx,
  stStrS,
  stDate,
  Math,
  StrUtils,
  bkdateutils,
  bkConst,
  imagesfrm,
  Globals,
  Admin32;

const

  // The default columns in default order
  DefColumns : array [1..14] of byte =
  (cot_Status, cot_ClientCode, cot_ClientName, cot_AccNo,
   cot_AccName,cot_AccBal, cot_CurrencyCode, cot_FirstDate, cot_LastDate,
   cot_NoCharge, cot_Delivered, cot_Institution, cot_Frequency, cot_Inactive) ;

  // Valid Columns, update this as columns change..
  ValidColumns = [cot_ClientCode .. cot_Frequency, cot_Offsite..cot_TLRN] - [cot_AccBal];

  // Columns that are sorted in groups
  GroupColumns = [cot_Status, cot_Delivered, cot_FirstDate,cot_LastDate, cot_Institution, cot_Frequency];

procedure InitClient(SysAccount: PSystem_Bank_Account_Rec; var ClientCode, ClientName : string) ;
var acMap: pClient_Account_Map_Rec;
    Client: pClient_File_Rec;
begin
   // see if we can make something up...
   if Assigned(SysAccount) then

   if not SysAccount.sbAttach_Required then begin

      acMap := Adminsystem.fdSystem_Client_Account_Map.FindFirstClient(SysAccount.sbLRN);
      if Assigned(acmap) then begin
         if Assigned(Adminsystem.fdSystem_Client_Account_Map.FindNextClient(SysAccount.sbLRN)) then begin
            ClientCode := 'Multiple';
            ClientName := '-';
            Exit;
         end;

         Client := AdminSystem.fdSystem_Client_File_List.FindLRN(acmap.amClient_LRN);
         if Assigned(Client) then begin
            ClientCode := Client.cfFile_Code;
            ClientName := Client.cfFile_Name;
            Exit;
         end;
      end;
   end;

   // Stillhere??
   ClientName := ' ';
   ClientCode := ' ';
end;


function TestOffsite(SysAccount: PSystem_Bank_Account_Rec): Boolean;
begin
  if SysAccount.sbBankLink_Code > '' then
     Result := not SameText( SysAccount.sbBankLink_Code, AdminSystem.fdFields.fdBankLink_Code)
  else
     Result := SysAccount.sbAccount_Type = sbtOffsite;
end;

{ TASBaseItem }



function TSABaseItem.CompareGroup(const Tag: integer; WithItem: TTreeBaseItem;
  SortDirection: TSortDirection): Integer;
begin
   Result := inherited CompareGroup(Tag, WithItem, SortDirection);
   if Result = 0 then begin// Keep the heading at the top...
      if not Assigned(SysAccount) then
         Result := 1
      else if not Assigned(TSABaseItem(WithItem).SysAccount) then
         Result := -1;
      if SortDirection = sdAscending then
         Result := -Result
   end;
end;

function TSABaseItem.CompareTagText(const Tag: integer; WithItem: TTreeBaseItem;
  SortDirection: TSortDirection): Integer;

begin
   case Tag of
   { This would make it more Numeric.. But it seems is not required..
   cot_AccNo        : Result := CompareText(LeftPadChS(SysAccount.sbAccount_Number,                      '0',20),
                                            LeftPadChS(TSABaseItem(WithItem).SysAccount.sbAccount_Number,'0',20)); }

   cot_AccBal       : Result := CompareValue(GetBalance, TSABaseItem(WithItem).GetBalance);
   cot_FirstDate    : Result := CompareValue(SysAccount.sbFirst_Available_Date, TSABaseItem(WithItem).SysAccount.sbFirst_Available_Date);
   cot_LastDate     : Result := CompareValue(SysAccount.sbLast_Entry_Date,      TSABaseItem(WithItem).SysAccount.sbLast_Entry_Date);
   cot_LRN          : Result := CompareValue(SysAccount.sbLRN,                  TSABaseItem(WithItem).SysAccount.sbLRN);
   cot_TLRN         : Result := CompareValue(SysAccount.sbLast_Transaction_LRN, TSABaseItem(WithItem).SysAccount.sbLast_Transaction_LRN);
   cot_NoCharge,
   cot_Inactive,
   cot_Frequency,
   cot_Offsite     : Result := CompareText(GetTagText(Tag),WithItem.GetTagText(Tag));

   else Result := inherited CompareTagText(Tag,WithItem,SortDirection); // Leaves the space at the bottom
   end;
end;

constructor TSABaseItem.Create(aSysAccount :pSystem_Bank_Account_Rec; AGroup: Integer);
begin

  inherited Create('',AGroup);
  IsOffsite := False;
  SysAccount := aSysAccount;
  if Assigned(SysAccount) then begin
     Title := SysAccount.sbAccount_Number;
     IsOffsite := TestOffsite(SysAccount);
  end;
end;

function TSABaseItem.GetBalance: Money;
begin
   if assigned(SysAccount)
   and (SysAccount.sbAccount_Password = '') then
      Result := SysAccount.sbCurrent_Balance
   else
      Result := UnKnown
end;

function TSABaseItem.GetClientCode: string;

begin
   if fClientCode = '' then
      InitClient(SysAccount,fClientCode,fClientName);

   Result := fClientCode;
end;

function TSABaseItem.GetClientName: string;
begin
   if fClientName = '' then
      initClient(SysAccount,fClientCode,fClientName);
   Result := fClientName;
end;


function TSABaseItem.GetImageindex: Integer;
begin
   // Result := -1;
   if SysAccount = nil then begin
      Result := -1;
      exit;
   end;

   if SysAccount.sbMark_As_Deleted then begin
      Result := STATES_DELETED_BMP;
   end else begin
      if SysAccount.sbAttach_Required then begin
         if SysAccount.sbNew_This_Month then
            Result := STATES_NEW_ACCOUNT_BMP
         else
            Result := STATES_UNATTACHED_BMP;
      end else
         Result := STATES_ATTACHED_BMP;
   end;
   if SysAccount.sbAccount_Password <> '' then
       Result := Result + 7;
end;

function TSABaseItem.GetNodeHeight(const Value: Integer): Integer;
begin
   if not Assigned(SysAccount) then
      Result := 35
   else
      Result := Value
end;

function TSABaseItem.GetTagHint(const Tag: Integer; Offset: TPoint): string;
begin
  if assigned( SysAccount) then
    case Tag of
      cot_Frequency    : if Boolean(SysAccount.sbFrequency_Change_Pending) then
                           Result := 'Change Pending';
    end;
end;

function TSABaseItem.GetTagText(const Tag: Integer): string;
begin
   Result := '';
   if assigned( SysAccount) then case Tag of
     cot_AccNo        : Result := SysAccount.sbAccount_Number;
     cot_AccName      : Result := SysAccount.sbAccount_Name;
     cot_Delivered    : if TestOffsite(SysAccount) then
                           Result := SysAccount.sbBankLink_Code
                        else case SysAccount.sbAccount_Type of
                           sbtProvisional : Result := 'Provisional';
                           sbtOffsite : Result := SysAccount.sbBankLink_Code;
                           else Result := '';
                        end;
     cot_CurrencyCode : Result := SysAccount.sbCurrency_Code;
     cot_ClientCode   : Result := ClientCode;
     cot_ClientName   : Result := ClientName;
     cot_AccBal       : Result := MoneyStr(GetBalance, SysAccount.sbCurrency_Code);
     cot_FirstDate    : Result := bkDate2Str(SysAccount.sbFirst_Available_Date);
     cot_LastDate     : Result := bkDate2str(SysAccount.sbLast_Entry_Date);
     cot_Status       : begin
                         if SysAccount.sbMark_As_Deleted then
                            Result := 'Deleted'
                         else if SysAccount.sbInActive then
                            Result := 'Inactive'
                         else if SysAccount.sbAttach_Required then begin
                               if SysAccount.sbNew_This_Month then
                                  Result := 'New'
                               else
                                  Result := 'Unattached'
                            end else
                               if IsOffsite then
                                  Result := 'Secure'
                               else
                                  Result := 'Attached'
                      end;
     cot_NoCharge     : if SysAccount.sbNo_Charge_Account then
                           Result := 'No';

     cot_Offsite      : if SysAccount.sbAccount_Type = sbtOffsite then
                           Result := 'Yes';
     cot_Inactive     : if SysAccount.sbInActive then
                           Result := 'Yes';
     cot_Institution  : Result := SysAccount.sbInstitution;
     cot_Frequency    : begin
                          case SysAccount.sbFrequency of
                            difmonthly,
                            difWeekly,
                            difDaily   : Result := difFrequencyNames[SysAccount.sbFrequency];
                          else
                            Result := difFrequencyNames[difUnspecified];
                          end;
                          if Boolean(SysAccount.sbFrequency_Change_Pending) then
                            Result := '*' + Result;
                        end;
     cot_LRN          : Result := Inttostr(SysAccount.sbLRN);
     cot_TLRN         : Result := Inttostr(SysAccount.sbLast_Transaction_LRN);
   end;
end;



procedure TSABaseItem.OnPaintText(const Tag: integer; Canvas: TCanvas;
  TextType: TVSTTextType);
begin
   if Assigned(SysAccount) then
      Exit;
   Canvas.Font := appimages.Font;
   Canvas.Font.Style := [fsBold];
end;

{ TfmeSysAccounts }

function TfmeSysAccounts.AccountsHaveFrequencyInfo: Boolean;
var
  i: integer;
begin
  Result := False;
  for i := 0 to Pred(AdminSystem.fdSystem_Bank_Account_List.ItemCount) do begin
    if (AdminSystem.fdSystem_Bank_Account_List.System_Bank_Account_At(i).sbFrequency <> difUnspecified) then begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TfmeSysAccounts.AccountTreeBeforeItemPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
  var CustomDraw: Boolean);

var lItem: TSABaseItem;
    Column: TColumnIndex;
    LRect: TRect;

begin // Could have put it in the list...
   lItem := Accounts[Node];
   if not Assigned(LItem) then
      Exit;
   if Assigned(LItem.SysAccount) then
      Exit;

    CustomDraw := true;

    //paint background
    TargetCanvas.Brush.Color := clWindow;
    TargetCanvas.FillRect( ItemRect);

    //paint sort column shading
    Column := AccountTree.Header.SortColumn;
    if ( Column >= 0) and ( Column < AccountTree.Header.Columns.Count) then
    begin
      //only paint if in view
      if ( AccountTree.Header.Columns[ Column].Left < ItemRect.Right) then
      begin
        LRect.Left := AccountTree.Header.Columns[ Column].Left;
        LRect.Top  := ItemRect.Top;
        LRect.Right := LRect.Left + AccountTree.Header.Columns[ Column].Width;
        LRect.Bottom := ItemRect.Bottom;
        OffsetRect( LRect, -AccountTree.OffsetX, 0);
        TargetCanvas.Brush.Color := $F7F7F7;
        TargetCanvas.FillRect( LRect);
      end;
    end;

    //paint text
    TargetCanvas.Brush.Color := clWindow;
    TargetCanvas.Brush.Style := bsClear;

    TargetCanvas.Font := appimages.Font;
    TargetCanvas.Font.Style := [fsBold];


    InflateRect( ItemRect, -6, -2 );
    DrawText( TargetCanvas.Handle, PChar( LItem.Title ), -1, ItemRect, DT_LEFT or DT_VCENTER or DT_SINGLELINE);

    //paint line
    LRect.Left     := 6;
    LRect.Top      := ItemRect.Bottom - 5;
    LRect.Bottom   := LRect.Top + 1;
    LRect.Right    := 200;
    RzGrafx.PaintGradient( TargetCanvas, LRect, gdVerticalCenter, clBtnFace, clHighlight);
end;

procedure TfmeSysAccounts.AccountTreeClick(Sender: TObject);
begin
  OnSelectionChanged(AccountTree);
end;

procedure TfmeSysAccounts.AccountTreeGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
begin
  if Kind in [ikNormal, ikSelected] then
  case fAccountList.GetColumnTag(Column) of
  cot_Status: ImageIndex := Accounts[Node].GetImageindex;
  end;
end;

procedure TfmeSysAccounts.AccountTreeHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var WasGroup: Boolean;
begin
   if Button = mbRight then
      Exit;

   AccountTree.BeginUpdate;
   try
      if Column = AccountTree.Header.SortColumn then begin
         // Just toggle the direction
         if AccountTree.Header.SortDirection = sdAscending then
            AccountTree.Header.SortDirection := sdDescending
         else
            AccountTree.Header.SortDirection := sdAscending;
         fAccountList.GroupSortDirection := AccountTree.Header.SortDirection;
      end else begin
         WasGroup := AccountTree.Header.Columns[ AccountTree.Header.SortColumn].Tag in GroupColumns;
         AccountTree.Header.SortColumn := Column;
         AccountTree.Header.SortDirection := sdAscending;
         fAccountList.GroupSortDirection := AccountTree.Header.SortDirection;

         if WasGroup
         or (AccountTree.Header.Columns[Column].Tag in GroupColumns) then begin // isGroup
            ReloadAccounts;
            Exit; // Dont need the sort..
         end;

      end;

      AccountTree.SortTree(AccountTree.Header.SortColumn,AccountTree.Header.SortDirection, true);
   finally
      AccountTree.EndUpdate;
   end;
end;

procedure TfmeSysAccounts.AccountTreeHeaderDragging(Sender: TVTHeader;
  Column: TColumnIndex; var Allowed: Boolean);
begin
    Allowed := Column <> 0;
end;

procedure TfmeSysAccounts.AccountTreeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = Ord('A')) then
    OnSelectionChanged(AccountTree);
end;

procedure TfmeSysAccounts.AccountTreeKeyPress(Sender: TObject; var Key: Char);
begin
   if Assigned(OnSelectionChanged) then

   if ord(Key) in [VK_Left,VK_Right,VK_Up,VK_Down,VK_End,VK_Home,VK_PRIOR,VK_Next,VK_Space ] then
        OnSelectionChanged(AccountTree);
end;

procedure TfmeSysAccounts.actFilterExecute(Sender: TObject);
var P: TPoint;

    procedure TestFilter;
    var n: Integer;
        Provisional: Boolean;
    begin
       cbFilter.ItemIndex := -1;
       try
       Provisional := false;
       for n := Low(fInclude.Nodes)+ 1 to High(fInclude.Nodes) do begin
           if (n= safsTopDeliver)
           and (fInclude.Nodes[n] = [saProvisional]) then
              Provisional := True
           else begin
              if fInclude.Nodes[n] <> [] then
                 Exit;
              if fInclude.NotNodes[n] <> [] then
                 Exit;
           end;
       end;

       // only Node zero or Provisional ..

       if (fInclude.Nodes[0] = []) then begin
          if fInclude.NotNodes[0] = [] then
             // Notes and NotNotes Blank
             if provisional then
                cbFilter.ItemIndex := cbf_Provisional
             else
                cbFilter.ItemIndex := cbf_All
          else if fInclude.NotNodes[0] = [saAttached] then
             cbFilter.ItemIndex := cbf_UnAttached
          else if  fInclude.NotNodes[0] = [saDeleted] then
             cbFilter.ItemIndex := cbf_Deleted
          else if fInclude.NotNodes[0] = [saInactive] then
             cbFilter.ItemIndex := cbf_Inactive

       end else if fInclude.NotNodes[0] = [] then begin
          if fInclude.Nodes[0] = [saAttached] then
             cbFilter.ItemIndex := cbf_Attached
       end;

       finally
           actReset.Enabled :=  cbFilter.ItemIndex = -1;
       end;
    end;

begin
   p := AccountTree.ClientToScreen(point(0,-AccountTree.Header.Height));
   if ChooseSAFilter(P,AccountTree.Width, AccountTree.Height, fInclude) = mrOK then begin
      // Filter Changed, but look at what the the outcome is...
      TestFilter;
      ReloadAccounts;
   end;
end;


procedure TfmeSysAccounts.actResetExecute(Sender: TObject);
begin
   fInclude.Clear;
   cbFilter.ItemIndex := cbf_All;
   actReset.Enabled := false;
   ReloadAccounts;
end;

procedure TfmeSysAccounts.actRestoreColumnsExecute(Sender: TObject);
var I: Integer;
begin
   AccountTree.Header.Columns.Clear;

   for i := Low(DefColumns) to High(DefColumns) do
      AddColumn(I-1,DefColumns[I],0);
   FixColumns;
   DefaultSort;
end;

function TfmeSysAccounts.AddColumn(Name: string; Position, Tag, width: Integer):TVirtualTreeColumn;
begin
   Result := GetColumn(Tag);
   if Assigned(Result) then
      Exit;

   // Skip the CurrencyCode, if not required
   if Tag = cot_CurrencyCode then
      if not AdminSystem.HasMultiCurrency then
         Exit;
   if not (Tag in ValidColumns) then
      Exit;

   Result := AccountTree.Header.Columns.Add;
   Result.Text := Name;
   Result.Tag := Tag;
   Result.Width := Abs(Width);

   if Tag in [cot_AccBal] then  // ? Only one..
      Result.Alignment := taRightJustify;

   if Width < 0 then // Saved as hidden.
      Result.Options := Result.Options - [coVisible];

   if Position >= 0 then //Only Set if valid
      Result.Position := Position;
end;

function TfmeSysAccounts.AddColumn(Position, Tag, width: Integer):TVirtualTreeColumn;
begin
   Result := AddColumn(ColumnName(Tag),Position,Tag,Width);
end;

procedure TfmeSysAccounts.BeginUpdate;
begin
   AccountTree.BeginUpdate;
end;

procedure TfmeSysAccounts.btnSearchClearClick(Sender: TObject);
begin
   EBFind.Text := '';
   SearchTimerTimer(nil);//Action it..
end;

procedure TfmeSysAccounts.cbFilterChange(Sender: TObject);
begin
   actReset.Enabled := False;
   Include.Clear;
   case cbFilter.ItemIndex of
   cbf_Attached   :begin
                      Include.Nodes[safsTopStatus] := [saAttached];
                    end;
   cbf_New        :begin
                      Include.Nodes[safsTopStatus] := [saNew];
                    end;
   cbf_Unattached :begin
                      Include.NotNodes[safsTopStatus]  := [saAttached];
                    end;
   cbf_Deleted    :begin
                      Include.Nodes[safsTopDeleted] := [saDeleted];   
                    end;
   cbf_Inactive   :begin
                      Include.Nodes[safsTopStatus] := [saInactive];
                    end;
   cbf_Provisional:begin
                      Include.Nodes[safsTopDeliver] := [saProvisional]
                    end;
   end;
   ReloadAccounts;
end;

function TfmeSysAccounts.ColumnName(Tag: Integer): string;
begin
   case Tag of
   //cot_Image        : Result := '';
   cot_ClientCode   : Result := 'Client Code';
   cot_ClientName   : Result := 'Client Name';
   cot_AccNo        : Result := 'Account No';
   cot_AccName      : Result := 'Account Name';
   cot_AccBal       : Result := 'Balance';
   cot_FirstDate    : Result := 'From';
   cot_LastDate     : Result := 'To';
   //cot_PracticeCode : Result := 'Secure Code';
   cot_Delivered    : Result := 'Delivered';

   cot_CurrencyCode : Result := 'Currency';
   cot_Status       : Result := 'Status';
   cot_NoCharge     : Result := 'Charge';
   cot_Institution  : Result := 'Institution Name';
   cot_Frequency    : Result := 'Frequency';
   cot_Inactive     : Result := 'Inactive';
   // Only for Supper user
   cot_Offsite      : Result := 'Not Delivered';
   cot_LRN          : Result := 'LRN';
   cot_TLRN         : Result := 'T LRN';
   else result := '';
   end;
end;

function TfmeSysAccounts.ColumnVisible(Tag: Integer): Boolean;
var LCol: TVirtualTreeColumn;
begin
   Result := False;
   LCol := GetColumn(Tag);
   if Assigned(LCol) then
       Result := coVisible in LCol.Options;
end;

procedure TfmeSysAccounts.DefaultSort;
    procedure SetSortColumn(Defaults : array of integer);
    var C: Integer;
        LCol: TVirtualTreeColumn;
    begin
       for C := Low(Defaults) to High(Defaults) do
         if ColumnVisible(Defaults[C]) then begin
            LCol := GetColumn(Defaults[C]);
            if Assigned(LCol) then begin
               AccountTree.Header.SortColumn := LCol.Index;
               Exit;
            end;
         end;
       // Still Here ??
       for C := 0 to AccountTree.Header.Columns.Count - 1 do
       with AccountTree.Header.Columns[AccountTree.Header.Columns.ColumnFromPosition(C) ] do
          if coVisible in Options then  begin
             // Use the first visible column
             AccountTree.Header.SortColumn := Index;
             Exit;
          end;
    end;

begin
  // Sort out the Sort Column;
  SetSortColumn([cot_Status, cot_ClientCode, cot_AccNo]);
end;

procedure TfmeSysAccounts.DoCreate(const SavedCols: string);
var Cols: TStringList;
    I: Integer;

begin

  fAccountList := TTreeBaseList.Create(AccountTree);
  fGroupList := TObjectList.Create(False);
  FInclude := saFilterSet.Create;
  // Sort ot the fonts
  AccountTree.Header.Font := AccountTree.Font;
  AccountTree.Canvas.Font := AccountTree.Font;
  AccountTree.Header.Height := Abs(AccountTree.Header.Font.height) * 10 div 6;
  AccountTree.DefaultNodeHeight := Abs(Self.Font.Height * 13 div 8);
  PTop.Height := cbFilter.ClientHeight + 7;

  // Do The Columns
  AccountTree.Header.Columns.Clear;

  // Load the saved ones
  Cols := TStringList.Create;
  try
     Cols.Sorted := False;//Keep the saved order
     Cols.CommaText := {'';//{} SavedCols;
     for I := 0 to Cols.Count - 1 do
        try
            AddColumn(I, StrToInt(Cols.Names[I]),StrToInt(Cols.ValueFromIndex[I]));
        except // May not be integer..
        end;
  finally
     Cols.Free;
  end;

  // Add any default ones
  for i := Low(DefColumns) to High(DefColumns) do
     AddColumn(I-1,DefColumns[I],0);

  // Sort out the Extra columns
  if AdminSystem.HasMultiCurrency then
     AddColumn(-1,cot_CurrencyCode, 0);

  if GLOBALS.SuperUserLoggedIn then begin
     AddColumn(-1, cot_Offsite, 0);
     AddColumn(-1, cot_LRN, 0);
     AddColumn(-1, cot_TLRN, 0);
  end;
  DefaultSort;
end;

procedure TfmeSysAccounts.DoDestroy(var SaveCols: string);
var col: Integer;
begin
  SaveCols := '';
  for Col := 0 to AccountTree.Header.Columns.Count - 1 do
     with AccountTree.Header.Columns[AccountTree.Header.Columns.ColumnFromPosition(col) ] do
     if (Tag < 100) then begin
        if SaveCols > '' then
           SaveCols := SaveCols + ',';

        if coVisible in Options then
           saveCols := saveCols + Format('%d=%d',[Tag,Width])
        else
           saveCols := saveCols + Format('%d=-%d',[Tag,Width]);
     end;
  fAccountList.Free;
  fGroupList.Free;
  FInclude.Free;
end;

procedure TfmeSysAccounts.EBFindChange(Sender: TObject);
begin
   //Restart the timer for each Char
   SearchTimer.Enabled := False;
   SearchTimer.Enabled := True;
end;

procedure TfmeSysAccounts.EBFindKeyPress(Sender: TObject; var Key: Char);
begin
   if Ord(Key)=VK_RETURN then
     SearchTimerTimer(nil); //Action straight away
end;

procedure TfmeSysAccounts.EndUpdate;
begin
    AccountTree.EndUpdate;
end;

procedure TfmeSysAccounts.FixColumns;
var I: Integer; // Rather than just having default widths, it fits them to size..
    Col: TVirtualTreeColumn;

    function TagWidth(Value: Integer): Integer;
    begin
       if Value = cot_Status then
          Result := AccountTree.Images.Width + 4
       else
          Result := 0;   
    end;
begin
   with AccountTree.Header.Columns do
      for I := 0 to Count - 1 do begin
         Col :=  Items[ColumnFromPosition(I)];
         if ([coResizable, coVisible] * Col.Options = [coResizable, coVisible])
         and (Col.Width <= Col.MinWidth) then begin
            // Have to 'fudge' the main column
            // It hast the text width stored
            if Col.Index = AccountTree.Header.MainColumn then
               if Col.Index > 0 then
                  AccountTree.Header.MainColumn := Col.Index -1
               else
                   AccountTree.Header.MainColumn := Col.Index + 1;

               Col.Width := Max (
                                   AccountTree.GetMaxColumnWidth(Col.Index) + TagWidth(Col.Tag),
                                   AccountTree.Canvas.TextWidth(Col.Text)+ Col.Margin * 2 + AccountTree.TextMargin
                                );
         end;
      end;
end;

function TfmeSysAccounts.GetAccountList: TTreeBaseList;
begin
   if fAccountList = nil then
      DoCreate('');
   Result := fAccountList;
end;

function TfmeSysAccounts.GetAccounts(Index: PVirtualNode): TSABaseItem;
begin
   Result := TSABaseItem(fAccountList.GetNodeItem(Index));
end;

function TfmeSysAccounts.GetColumn(Tag: Integer): TVirtualTreeColumn;
var I: Integer;
begin
   Result := nil;
   for I := 0 to AccountTree.Header.Columns.Count - 1 do
      if AccountTree.Header.Columns[i].Tag = Tag then begin
         Result := AccountTree.Header.Columns[i];
         Exit;
      end;
end;

function TfmeSysAccounts.GetStringList(FromText: string): tStringList;
begin
   Result := TStringList.Create;
   Result.StrictDelimiter := true;
   Result.Delimiter := ',';
   Result.DelimitedText := fromtext;
end;


procedure TfmeSysAccounts.mniShowHideColumnsClick(Sender: TObject);
var lCol: tVirtualTreeColumn;
    CI: TColumnIndex;
    NoneVisible: Boolean;
begin
  if sender is TMenuItem then begin
      NoneVisible := False; //Dont need to test..
      LCol := GetColumn(TMenuItem(Sender).Tag);
      if Assigned(LCol) then
         if coVisible in LCol.Options then begin
            LCol.Options := LCol.Options - [coVisible];
            NoneVisible := True;// May need to test
         end else begin
            LCol.Options := LCol.Options + [coVisible];
         end;
      // Make sure we still have a visible column..
      if NoneVisible then begin
         lCol := nil;
         for CI := 0 to AccountTree.Header.Columns.Count - 1 do
           with AccountTree.Header.Columns[CI ] do begin
              if coVisible in options then begin
                 Exit; // Im done...
              end else if Tag = cot_AccNo then
                 LCol := AccountTree.Header.Columns[CI];
           end;
         // Still here...
         if Assigned(LCol) then // Why would it not be...
              LCol.Options := LCol.Options + [coVisible]; // Show the AccNumber..
      end;
  end;
end;

procedure TfmeSysAccounts.pmHeaderPopup(Sender: TObject);

   procedure AddMenuItem(Caption: string;  OnClick: TNotifyEvent = nil; Tag: Integer = 0; Checked: Boolean = false);
   var it: TMenuItem;
   begin
      if Tag >= 100 then
         Exit;
      it := TMenuItem.Create(pmHeader);
      it.Caption := Caption;
      it.Tag     := Tag;
      it.Checked := Checked;
      it.OnClick := OnClick;
      pmHeader.Items.Add(it);
   end;

var
   Col: TColumnIndex;
begin

    pmHeader.Items.Clear;
    for Col := 0 to AccountTree.Header.Columns.Count - 1 do
       with AccountTree.Header.Columns[AccountTree.Header.Columns.ColumnFromPosition(col) ] do
         AddMenuItem(Text,mniShowHideColumnsClick,Tag,coVisible in Options);

    AddMenuItem('-');
    AddMenuItem(actRestoreColumns.Caption , actRestoreColumnsExecute);
end;

function TfmeSysAccounts.GetOnSelectionChanged: TNotifyEvent;
begin
   Result := fAccountList.OnCurBaseItemChange;
end;

function TfmeSysAccounts.GetSelected: PSystem_Bank_Account_Rec;
var lNode: PVirtualNode;
begin
   Result := nil;
   lNode := AccountTree.GetFirstSelected;
   if Assigned(lNode) then
      Result := Accounts[lNode].SysAccount;
end;

function TfmeSysAccounts.GetSelectedList: string;
var lNode: PVirtualNode;
begin
   // Produces Comma seperated string of selected bank accounts
   Result := '';
   lNode := AccountTree.GetFirstSelected;
   while Assigned(lNode) do begin
      if Result > '' then
         Result := result + ',';

      if Assigned(Accounts[lNode].SysAccount) then
        Result := Result + Accounts[lNode].SysAccount.sbAccount_Number;

      lNode := AccountTree.GetNextSelected(lNode);
   end;
end;

procedure TfmeSysAccounts.ReloadAccounts(SelAccount: string = '');
var
   kc: TCursor;
   KXOffset: Integer;
   i,c: Integer;
   BankAcct: pSystem_Bank_Account_Rec;
   lNode: PVirtualNode;
   lSel: TstringList;
   ThisMonth,
   LastMonth,
   SixMonths,
   lastYear: Integer;
   SortTag: Integer;

   function InFilters: Boolean;
     var CurNode: Integer;

     function TestInclude(Value: Boolean; Filter: saFilters): Boolean;
     begin
        if Value then
           Result := (Include.Nodes[CurNode] <> []) // If empty it does not count
                  and (Filter in Include.Nodes[CurNode])
        else
           Result := (Include.NotNodes[CurNode] <> [])
                  and (Filter in Include.NotNodes[CurNode])
     end;

   begin
      if Include.Empty then begin
         Result := True;
         Exit;
      end;
      Result := False;
      for CurNode := low(Include.Nodes) to High(Include.Nodes) do begin

         if (Include.Nodes[CurNode] = [])
         and (Include.NotNodes[CurNode] = []) then
             Continue; // Empty, so all included

         if not ( // Filter within a node is or-ed
                      TestInclude(BankAcct.sbMark_As_Deleted,saDeleted)
                      or TestInclude(TestOffsite(BankAcct), saSecure)
                      or TestInclude(BankAcct.sbInActive, saInactive)
                      or TestInclude(not BankAcct.sbAttach_Required, saAttached)
                      or TestInclude(BankAcct.sbNew_This_Month, saNew)
                      or TestInclude(not BankAcct.sbNo_Charge_Account , saCharge)
                      or TestInclude(BankAcct.sbAccount_Password > '' , saPassword)
                      or TestInclude(BankAcct.sbLast_Entry_Date >= lastYear, saThisYear)
                      or TestInclude(BankAcct.sbFrequency = difMonthly, saFreqMonth)
                      or TestInclude(BankAcct.sbFrequency = difWeekly, saFreqWeek)
                      or TestInclude(BankAcct.sbFrequency = difDaily, saFreqDay)
                      or TestInclude(BankAcct.sbFrequency = difUnspecified, saFreqUnspecified)
                      or TestInclude(BankAcct.sbAccount_Type = sbtProvisional, saProvisional)
                ) then
           Exit; // This node failed

      end;
      Result := True;
   end;

   function InSearch: Boolean;
   var ClientCode, ClientName: string;
   begin
      Result := True; // assume sucess..
      if SearchText = '' then
         Exit;

      if ContainsText(BankAcct.sbAccount_Number, FSearchText) then
         Exit;

      if ContainsText(BankAcct.sbAccount_Name, FSearchText) then
         Exit;

      InitClient(BankAcct,ClientCode, ClientName);

      if ContainsText(ClientCode, FSearchText) then
         Exit;

      if ContainsText(ClientName, FSearchText) then
         Exit;

      // Not found anywhere..
      Result := False;
   end;



   procedure CheckGroup;
   var CurGroup: Integer;
       NewGroup: TSABaseItem;

      procedure StatusGroups;
          function StatusGroup: Integer;
          begin
             if BankAcct.sbMark_As_Deleted then
                Result := 5  //Deleted
             else if BankAcct.sbInActive then
                Result := 2 //Inactive
             else
                if BankAcct.sbAttach_Required then begin
                   if BankAcct.sbNew_This_Month then
                      Result := 0 //New
                   else
                      Result := 1; //Unatached
                end else
                   if TestOffsite(BankAcct) then
                      Result := 4 //Offsite
                   else
                      Result := 3;//Local actached
          end;

       begin //StatusGroups
           CurGroup := StatusGroup;
           NewGroup := TestNewGroup(CurGroup);
           if Assigned(NewGroup) then begin
              case CurGroup of
              0 : NewGroup.Title := 'New Accounts';
              1 : NewGroup.Title := 'Unattached Accounts';
              2 : NewGroup.Title := 'Inactive Accounts';
              3 : NewGroup.Title := 'Attached Accounts';
              4 : NewGroup.Title := 'Books Secure Accounts';
              5 : NewGroup.Title := 'Deleted Accounts';
              end;
              lnode := fAccountList.AddNodeItem(nil, NewGroup);
           end;

       end; //StatusGroups

       procedure InstitutionGroups;
       begin
          NewGroup := TestNewGroup(BankAcct.sbInstitution, CurGroup);
          if Assigned(NewGroup) then begin
             if NewGroup.Title = '' then
                NewGroup.Title := 'No Institution';
             lnode := fAccountList.AddNodeItem(nil, NewGroup);
          end;
       end;//InstitutionGroups

       procedure FrequencyGroups;
       begin
          NewGroup := TestNewGroup(difFrequencyNames[BankAcct.sbFrequency],CurGroup);
          if Assigned(NewGroup) then begin
             if NewGroup.Title = '' then
                NewGroup.Title := 'Unspecified';
             lnode := fAccountList.AddNodeItem(nil, NewGroup);
          end;
       end;

       procedure DateGroups(Fromdate: Boolean);
          function DateGroup(Date: TStDate): Integer;
          begin
             if Date >= ThisMonth then
                Result := 0
             else if Date >= LastMonth then
                Result := 1
             else if Date >=SixMonths then
                Result := 2
             else if Date >= LastYear then
                Result := 3
             else Result := 4;
          end;
       begin // DateGroups
           if Fromdate then
               CurGroup := DateGroup(BankAcct.sbFirst_Available_Date)
           else
              CurGroup := DateGroup(BankAcct.sbLast_Entry_Date);

           NewGroup := TestNewGroup(CurGroup);
           if Assigned(NewGroup) then begin
              case CurGroup of
              0 : NewGroup.Title := 'This Month';
              1 : NewGroup.Title := 'Last Month';
              2 : NewGroup.Title := 'Before Last Month';
              3 : NewGroup.Title := 'More Than 6 Months Ago';
              4 : NewGroup.Title := 'More Than a Year Ago';
              end;
              lnode := fAccountList.AddNodeItem(nil, NewGroup);
           end;
       end;// DateGroups

       procedure DeliveredGroups;
       begin
          if TestOffsite(BankAcct) then
             CurGroup := 2
          else if BankAcct.sbAccount_Type = sbtProvisional then
             CurGroup := 1
          else
             CurGroup := 0;

          NewGroup := TestNewGroup(CurGroup);
          if Assigned(NewGroup) then begin
              case CurGroup of
              2 : NewGroup.Title := 'Books Secure Accounts';
              1 : NewGroup.Title := 'Provisional Accounts';
              0 : NewGroup.Title := 'Practice Accounts';
              end;
              lnode := fAccountList.AddNodeItem(nil, NewGroup);
           end;
       end; //PracticeGroups

       procedure ForexGroups;
       begin
          NewGroup := TestNewGroup(BankAcct.sbCurrency_Code , CurGroup);
          if Assigned(NewGroup) then begin
             lnode := fAccountList.AddNodeItem(nil, NewGroup);
          end;
       end;//InstitutionGroups

   begin //CheckGroup
      CurGroup := 0;
      case SortTag of
      cot_Status : StatusGroups;
      cot_Institution : InstitutionGroups;
      cot_FirstDate : DateGroups(True);
      cot_LastDate : DateGroups(False);
      cot_Delivered : DeliveredGroups;
      cot_CurrencyCode : ForexGroups;
      cot_Frequency : FrequencyGroups;
      end;

      lnode := fAccountList.AddNodeItem(nil, TSABaseItem.Create(BankAcct,CurGroup));
      //While we have the node, set selected..
      if lsel.Indexof( BankAcct.sbAccount_Number ) >= 0 then begin
         AccountTree.Selected[lnode] := True;
         AccountTree.FocusedNode := lNode;
      end;
   end; //CheckGroup
begin
   kc := Screen.Cursor;
   Screen.Cursor := crHourGlass;
   AccountTree.BeginUpdate;
   try
      // Keep the Horizontal scrollpos
      KXOffset := AccountTree.OffsetX;
      // Sort the selection..
      if SelAccount = '' then begin
        SelAccount := SelectedList;
      end;
      ThisMonth := GetFirstDayOfMonth(CurrentDate);
      LastMonth := IncDate(ThisMonth, 0,-1,0);
      SixMonths := IncDate(ThisMonth, 0,-6,0);
      LastYear :=  IncDate(ThisMonth, 0,0,-1);
      SortTag := AccountTree.Header.Columns[ AccountTree.Header.SortColumn].Tag;

      fAccountList.Clear;
      fGroupList.Clear;
      AccountTree.Clear;
      lsel := GetStringList(SelAccount);
      try
      c := 0;
      with AdminSystem.fdSystem_Bank_Account_List do
         for i := 0 to Pred(itemCount) do begin
            BankAcct := System_Bank_Account_At(i);

            // Check the filter and the search
            if InFilters then
            if InSearch then begin
               CheckGroup;

               Inc(c);
            end;
         end;
      finally
         lsel.Free;
      end;

      // Apply the sorting
      AccountTree.SortTree(AccountTree.Header.SortColumn,AccountTree.Header.SortDirection, true);

      // See if we need to adjust any column widths
      FixColumns;

      // Re set the Horizontal scrollbar
      AccountTree.OffsetX := KXOffset;

      // Update the count lable
      if c = 1 then
         lblCount.Caption := '1 Account Listed'
      else
         lblCount.Caption := format('%d Accounts Listed',[c]);
   finally
      AccountTree.EndUpdate;
      Screen.Cursor := kc;
   end;
end;

procedure TfmeSysAccounts.SearchTimerTimer(Sender: TObject);
begin
   SearchTimer.Enabled := False;
   SearchText := Trim(EBFind.Text);
end;

procedure TfmeSysAccounts.SetAccounts(Index: PVirtualNode;
  const Value: TSABaseItem);
begin

end;

procedure TfmeSysAccounts.SetInclude(const Value: saFilterSet);
begin
  FInclude.Assign (Value);
end;


procedure TfmeSysAccounts.SetOnSelectionChanged(const Value: TNotifyEvent);
begin
  fAccountList.OnCurBaseItemChange := Value;
end;

procedure TfmeSysAccounts.SetSearchText(const Value: string);
begin
  if not SameText (FSearchText, Value) then begin
     FSearchText := Value;
     ReloadAccounts;
  end;
  btnSearchClear.Enabled := FSearchText > '';
end;

procedure TfmeSysAccounts.SetSelected(const Value: PSystem_Bank_Account_Rec);
begin

end;

procedure TfmeSysAccounts.SetSelectedList(const Value: string);
begin
end;

function TfmeSysAccounts.TestNewGroup(const Value: string; var CurGroup: Integer): TSABaseItem;
var I: Integer;

    procedure MakeHash;
    var ls: string;
        InWord: Boolean;
        WordCount,
        LetterValue: Integer;
        lp: Integer;
        const CheckChars = ['A'..'Z'];
        procedure NextLetter(Value:Char);
        begin
           try
           CurGroup := CurGroup + (Byte(Value) - 64) * Lettervalue;
           Lettervalue := max(Lettervalue div 40, 40);
           except
           end;
        end;
    begin
       ls := Uppercase(Value);
       InWord := false;
       Lettervalue := 40*40*40*40;
       WordCount := 0;
       for lp := 1 to Length(ls) do
         if Inword then begin
            if ls[lp] in CheckChars then begin
               if lp < 3 then //ANZ /ASB
                 NextLetter(ls[lp]);
            end else
               Inword := False
         end else begin
            if ls[lp] in CheckChars then begin
               NextLetter(ls[lp]);
               InWord := True;
               Inc(WordCount);
            end;
         end;
       CurGroup := CurGroup + WordCount;
    end;
begin
   Result := nil;
   CurGroup := 0;
   if Value = '' then begin
      // Just look for the group
      for I := 0 to fGroupList.Count - 1 do
         if TSABaseItem(fGroupList[I]).GroupID = 0 then
            Exit; // Already in the list...

   end else begin
      for I := 0 to fGroupList.Count - 1 do
         if SameText(TSABaseItem(fGroupList[I]).Title, Value) then begin
            CurGroup := TSABaseItem(fGroupList[I]).GroupID;
            Exit; // Already in the list...
         end;
         MakeHash;
   end;

   Result := TSABaseItem.Create(nil,CurGroup);
   Result.Title := Value;
   FGroupList.Add(Result)
end;


function TfmeSysAccounts.TestNewGroup(const Value: Integer): TSABaseItem;
var I: Integer;
begin
   Result := nil;
   for I := 0 to fGroupList.Count - 1 do
      if TSABaseItem(fGroupList[I]).GroupID = Value then
         Exit; // Already in the list...
   Result := TSABaseItem.Create(nil,Value);
   FGroupList.Add(Result)
end;

end.
