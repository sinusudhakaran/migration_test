unit ClientSelectFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TLookupOption = (ltUser, ltGroup, ltClientType);

  TReportSort = (rsClient, rsByStaffMember, rsGroup, rsClientType);

  TRangeOption = (roAll, roRange, roSelection);

  TClientSelectOptions = class(TObject)
  private
    FRangeOption: TRangeOption;
    FReportSort: TReportSort;
    FClientFrom: string;
    FClientTo: string;
    FCodeSelectionList: TStringList;
    procedure SetClientFrom(const Value: string);
    procedure SetClientTo(const Value: string);
    procedure SetRangeOption(const Value: TRangeOption);
    procedure SetReportSort(const Value: TReportSort);
  public
    constructor Create;
    destructor Destroy; override;
    function ClientInSelection(AClientCode: string): Boolean;
    property ReportSort: TReportSort read FReportSort write SetReportSort;
    property RangeOption: TRangeOption read FRangeOption write SetRangeOption;
    property FromCode: string read FClientFrom write SetClientFrom;
    property ToCode: string read FClientTo write SetClientTo;
    property CodeSelectionList: TStringList read FCodeSelectionList;
  end;

  TFmeClientSelect = class(TFrame)
    grpSettings: TGroupBox;
    lblFrom: TLabel;
    lblTo: TLabel;
    Label5: TLabel;
    btnFromLookup: TSpeedButton;
    btnToLookup: TSpeedButton;
    lblSelection: TLabel;
    btnSelect: TSpeedButton;
    edtFromCode: TEdit;
    edtToCode: TEdit;
    edtSelection: TEdit;
    rbSelectAll: TRadioButton;
    rbRange: TRadioButton;
    rbSelection: TRadioButton;
    Panel1: TPanel;
    rbClient: TRadioButton;
    rbStaffMember: TRadioButton;
    rbGroup: TRadioButton;
    rbClientType: TRadioButton;
    procedure btnFromLookupClick(Sender: TObject);
    procedure rbClientClick(Sender: TObject);
    procedure rbRangeClick(Sender: TObject);
    procedure btnToLookupClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
  private
    FLookupList: TStringList;
    function DoOtherLookup(LookupType: TLookupOption; Caption: string;
      Multiple: Boolean; AlreadySelectedText: string; var Selection: string): boolean;
    procedure DoLookup(AEdit: TEdit);
    procedure DoClientLookup(AEdit: TEdit; Op: string; Multiple: Boolean);
    procedure DoUserLookup(AEdit: TEdit; Op: string; Multiple: Boolean);
    procedure DoGroupLookup(AEdit: TEdit; Op: string; Multiple: Boolean);
    procedure DoClientTypeLookup(AEdit: TEdit; Op: string; Multiple: Boolean);
    procedure LoadLookupBitmaps;
    function GetRangeOption: TRangeOption;
    procedure SetRangeOption(const Value: TRangeOption);
    function GetReportSort: TReportSort;
    procedure SetReportSort(const Value: TReportSort);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property RangeOption: TRangeOption read GetRangeOption write SetRangeOption;
    property ReportSort: TReportSort read GetReportSort write SetReportSort;
    function Validate(Prompt: Boolean): Boolean;
  end;

implementation

uses
  InfoMoreFrm,
  ComCtrls,
  SyDefs,
  Globals,
  CheckInOutFrm,
  ImagesFrm,
  SelectListDlg,
  UsrList32,
  grpList32,
  ctypelist32,
  bkConst;

{$R *.dfm}

procedure TFmeClientSelect.btnFromLookupClick(Sender: TObject);
begin
  DoLookup(edtFromCode);
end;

procedure TFmeClientSelect.btnSelectClick(Sender: TObject);
begin
  if rbClient.Checked then
    DoClientLookup(edtSelection, 'Select Client Codes', True)
  else if rbStaffMember.Checked then
    DoUserLookup(edtSelection, 'Select Staff Members', True)
  else if rbGroup.Checked then
    DoGroupLookup(edtSelection, 'Select Groups', True)
  else if rbClientType.Checked then
    DoClientTypeLookup(edtSelection, 'Select Client Types', True);
end;

procedure TFmeClientSelect.btnToLookupClick(Sender: TObject);
begin
  DoLookup(edtToCode);
end;

constructor TFmeClientSelect.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLookupList := TStringList.Create;
  rbRangeClick(AOwner);
  rbClientClick(AOwner); //make sure that correct values are displayed
  LoadLookupBitmaps;
end;

destructor TFmeClientSelect.Destroy;
begin
  FLookupList.Free;
  inherited;
end;

procedure TFmeClientSelect.DoClientLookup(AEdit: TEdit; Op: string; Multiple: Boolean);
var
  CodeList : TStringList;
  I: Integer;
begin
  CodeList := TStringList.Create;
  try
    CodeList.Delimiter :=  ClientCodeDelimiter;
    CodeList.StrictDelimiter := true;
    for i := 0 to FLookupList.Count - 1 do
      CodeList.Add(FLookupList[i]);
    CodeList.DelimitedText := SelectCodeToLookup( Op, CodeList.DelimitedText, Multiple);
    FLookupList.Clear;
    AEdit.Text := '';
    if Multiple then
    begin
      for I := 0 to Pred(CodeList.Count) do
      begin
        if AEdit.Text <> '' then
          AEdit.Text := AEdit.Text + ',';
        AEdit.Text := AEdit.Text + CodeList[i];
        FLookupList.Add(CodeList[i]);
      end;
    end
    else if CodeList.Count > 0 then
      AEdit.Text := CodeList[0];
  finally
    CodeList.Free;
  end;
end;

procedure TFmeClientSelect.DoClientTypeLookup(AEdit: TEdit; Op: string;
  Multiple: Boolean);
var
  Selection: String;
begin
  if DoOtherLookup(ltClientType, Op, Multiple, AEdit.Text, Selection) then
    AEdit.Text := Selection;
end;

procedure TFmeClientSelect.DoGroupLookup(AEdit: TEdit; Op: string; Multiple: Boolean);
var
  Selection: String;
begin
  if DoOtherLookup(ltGroup, Op, Multiple, AEdit.Text, Selection) then
    AEdit.Text := Selection;
end;

procedure TFmeClientSelect.DoLookup(AEdit: TEdit);
begin
  if rbClient.Checked then
    DoClientLookup(AEdit, 'Select Client Code From Range', False)
  else if rbStaffMember.Checked then
    DoUserLookup(AEdit, 'Select Staff Member From Range', False)
  else if rbGroup.Checked then
    DoGroupLookup(AEdit, 'Select Group From Range', False)
  else if rbClientType.Checked then
    DoClientTypeLookup(AEdit, 'Select Client Type From Range', False);
end;

function TFmeClientSelect.DoOtherLookup(LookupType: TLookupOption;
  Caption: string; Multiple: Boolean; AlreadySelectedText: string;
  var Selection: string): boolean;
var
  dlgSelectList : TdlgSelectList;
  NewItem       : TListItem;
  i             : integer;
  StoredIndex   : integer;
  User          : pUser_Rec;
  UserList      : TSystem_User_List;
  GroupList     : tSystem_Group_List;
  Group         : pGroup_Rec;
  ClientTypeList: TSystem_Client_Type_List;
  ClientType    : pClient_Type_Rec;
  Item          : TListItem;
  ItemName      : string;
begin
  StoredIndex := -1;
  dlgSelectList := TdlgSelectList.Create( Application);
  try
    //set up the dialog
    dlgSelectList.Caption := Caption;
    dlgSelectList.lvList.Columns.Clear;
    dlgSelectList.lvList.Columns.Add;
    //Groups, 1 column
    //Client Types, 1 column
    //Users, 2 columns
    if (LookupType = ltUser) then
      dlgSelectList.lvList.Columns.Add;
    dlgSelectList.lvList.Clear;
    dlgSelectList.lvList.MultiSelect := Multiple;
    //Do this based on Lookup Type
    case LookupType of
      ltUser:
        begin
          UserList := AdminSystem.fdSystem_User_List;
          for i := 0 to Pred(UserList.itemCount) do
          begin
            User := UserList.User_At(i);
            NewItem := dlgSelectList.lvList.Items.Add;
            NewItem.Caption := User^.usCode;
            NewItem.SubItems.Add(User^.usName);
            NewItem.ImageIndex := -1;
            if (User^.usCode = AlreadySelectedText) then
              StoredIndex := dlgSelectList.lvList.Items.Count - 1;
            NewItem.Selected := FLookupList.IndexOf(User^.usCode) > -1;
          end;
        end;
      ltGroup:
        begin
          //load admin group with full names
          GroupList := AdminSystem.fdSystem_Group_List;
          for i := 0 to Pred(GroupList.itemCount) do
          begin
            Group := GroupList.Group_At(i);

            NewItem := dlgSelectList.lvList.Items.Add;
            NewItem.Caption := Group^.grName;
            NewItem.ImageIndex := -1;

            if (Group^.grName = AlreadySelectedText) then
              StoredIndex := dlgSelectList.lvList.Items.Count - 1;
            NewItem.Selected := FLookupList.IndexOf(Group^.grName) > -1;
          end;
        end;
      ltClientType:
        begin
          ClientTypeList := AdminSystem.fdSystem_Client_Type_List;
          //load admin group with full names
          for i := 0 to Pred(ClientTypeList.itemCount) do
          begin
            ClientType := ClientTypeList.Client_Type_At(i);

            NewItem := dlgSelectList.lvList.Items.Add;
            NewItem.Caption := ClientType^.ctName;
            NewItem.ImageIndex := -1;

            if (ClientType^.ctName = AlreadySelectedText) then
              StoredIndex := dlgSelectList.lvList.Items.Count - 1;
            NewItem.Selected := FLookupList.IndexOf(ClientType^.ctName) > -1;
          end;
        end;
    end;
    NewItem := dlgSelectList.lvList.Items.Add;
    if LookupType = ltUser then
    begin
      NewItem.Caption := ' ';
      NewItem.SubItems.Add('Not Allocated');
    end
    else
    begin
      NewItem.Caption := 'Not Allocated';
    end;

    NewItem.ImageIndex := -1;
    NewItem.Selected := FLookupList.IndexOf(' ') > -1;
    case LookupType of
      ltUser:
        begin
          dlgSelectList.lvList.Column[0].Width := 100;
          dlgSelectList.lvList.Column[1].Width := dlgSelectList.lvList.ClientWidth - 100;
          dlgSelectList.lvList.Column[0].Caption := 'Staff Code';
          dlgSelectList.lvList.Column[1].Caption := 'Staff Member';
        end;
      ltGroup:
        begin
          dlgSelectList.lvList.Column[0].Width := dlgSelectList.lvList.ClientWidth;
          dlgSelectList.lvList.Column[0].Caption := 'Group Name';
        end;
      ltClientType:
        begin
          dlgSelectList.lvList.Column[0].Width := dlgSelectList.lvList.ClientWidth;
          dlgSelectList.lvList.Column[0].Caption := 'Client Type Name';
        end;
    end;


    if StoredIndex <> - 1 then
      dlgSelectList.lvList.ItemIndex := StoredIndex;
    if (dlgSelectList.ShowModal = mrOK) then
    begin
      FLookupList.Clear;
      Selection := '';
      if Multiple then
      begin
        for i := 0 to Pred(dlgSelectList.lvList.Items.Count) do
        begin
          Item := dlgSelectList.lvList.Items[i];
          ItemName := Item.Caption;
          if ItemName = 'Not Allocated' then
            ItemName := ' ';
          
          if Item.Selected then
          begin
            FLookupList.Add(ItemName);
            if Selection <> '' then
              Selection := Selection + ',';
            Selection := Selection + ItemName;
          end;
        end;
      end
      else if dlgSelectList.lvList.SelCount > 0 then
      begin
        NewItem := dlgSelectList.lvList.Selected;
        ItemName := NewItem.Caption;
        if ItemName = 'Not Allocated' then
          ItemName := ' ';
        Selection := ItemName;
      end;
      Result := true;
    end
    else
      Result := false;
  finally
    dlgSelectList.Free;
  end;
end;

procedure TFmeClientSelect.DoUserLookup(AEdit: TEdit; Op: string; Multiple: Boolean);
var
  Selection: String;
begin
  if DoOtherLookup(ltUser, Op, Multiple, AEdit.Text, Selection) then
    AEdit.Text := Selection;
end;

function TFmeClientSelect.GetRangeOption: TRangeOption;
begin
  Result := roAll;
  if rbRange.Checked then
     Result := roRange
  else if rbSelection.Checked then
     Result := roSelection;
end;

function TFmeClientSelect.GetReportSort: TReportSort;
begin
  Result := rsClient;
  if rbStaffMember.checked then
    Result := rsByStaffMember
  else if rbGroup.checked then
    Result := rsGroup
  else if rbClientType.checked then
    Result := rsClientType;
end;

procedure TFmeClientSelect.LoadLookupBitmaps;
begin
  if rbClient.Checked then
  begin
    btnFromLookup.Glyph := ImagesFrm.AppImages.imgLookupClient.Picture.Bitmap;
    btnToLookup.Glyph := ImagesFrm.AppImages.imgLookupClient.Picture.Bitmap;
    btnSelect.Glyph := ImagesFrm.AppImages.imgLookupClient.Picture.Bitmap;
  end
  else if rbStaffMember.Checked then
  begin
    btnFromLookup.Glyph := ImagesFrm.AppImages.imgLookupUser.Picture.Bitmap;
    btnToLookup.Glyph := ImagesFrm.AppImages.imgLookupUser.Picture.Bitmap;
    btnSelect.Glyph := ImagesFrm.AppImages.imgLookupUser.Picture.Bitmap;
  end
  else if rbGroup.Checked then
  begin
    btnFromLookup.Glyph := ImagesFrm.AppImages.imgLookupGroup.Picture.Bitmap;
    btnToLookup.Glyph := ImagesFrm.AppImages.imgLookupGroup.Picture.Bitmap;
    btnSelect.Glyph := ImagesFrm.AppImages.imgLookupGroup.Picture.Bitmap;
  end
  else if rbClientType.Checked then
  begin
    btnFromLookup.Glyph := ImagesFrm.AppImages.imgLookupClientType.Picture.Bitmap;
    btnToLookup.Glyph := ImagesFrm.AppImages.imgLookupClientType.Picture.Bitmap;
    btnSelect.Glyph := ImagesFrm.AppImages.imgLookupClientType.Picture.Bitmap;
  end;
end;

procedure TFmeClientSelect.rbClientClick(Sender: TObject);

begin
  if rbClient.checked then begin
    lblFrom.caption := '&From Client Code';
    lblTo.caption   := 'T&o Client Code';
    edtFromCode.Hint    :=
       'Include Clients from this code|'+
       'Include Clients from this code';
    edtToCode.Hint      :=
       'Include Clients up to this code|'+
       'Include Clients up to this code';
    grpSettings.Caption := 'Select Clients';
    lblSelection.Caption := 'Clients';
    rbSelectAll.Caption := 'All Clients';
  end else if rbStaffMember.Checked then begin
    lblFrom.caption := '&From Staff Member';
    lblTo.caption   := 'T&o Staff Member';
    edtFromCode.Hint    :=
       'Include Staff Members from this Staff Member|'+
       'Include Staff Members from this Staff Member';
    edtToCode.Hint      :=
       'Include Staff Members up to this Staff Member|'+
       'Include Staff Members up to this Staff Member';
    grpSettings.caption := 'Select Staff Members';
    lblSelection.Caption := 'Staff Members';
    rbSelectAll.Caption := 'All Staff Members';
  end else if rbGroup.Checked then begin
    lblFrom.caption := '&From Group';
    lblTo.caption   := 'T&o Group';
    edtFromCode.Hint    :=
       'Include Clients from this group|'+
       'Include Clients from this group';
    edtToCode.Hint      :=
       'Include Clients up to this group|'+
       'Include Clients up to this group';
    grpSettings.Caption := 'Select Groups';
    lblSelection.Caption := 'Groups';
    rbSelectAll.Caption := 'All Groups';
  end else if rbClientType.Checked then begin
    lblFrom.caption := '&From Client Type';
    lblTo.caption   := 'T&o Client Type';
    edtFromCode.Hint    :=
       'Include Clients from this Client Type|'+
       'Include Clients from this Client Type';
    edtToCode.Hint      :=
       'Include Clients up to this Client Type|'+
       'Include Clients up to this Client Type';
    grpSettings.Caption := 'Select Client Types';
    lblSelection.Caption := 'Client Types';
    rbSelectAll.Caption := 'All Client Types';
  end;

  LoadLookupBitmaps;
end;

procedure TFmeClientSelect.rbRangeClick(Sender: TObject);
begin
  //Range
  edtFromCode.Enabled := rbRange.Checked;
  edtToCode.Enabled := rbRange.Checked;
  btnFromLookup.Enabled := rbRange.Checked;
  btnToLookup.Enabled := rbRange.Checked;
  lblFrom.Enabled := rbRange.Checked;
  lblTo.Enabled := rbRange.Checked;
  //Selection
  edtSelection.Enabled := rbSelection.Checked;
  btnSelect.Enabled := rbSelection.Checked;
  lblSelection.Enabled := rbSelection.Checked;
end;

procedure TFmeClientSelect.SetRangeOption(const Value: TRangeOption);
begin
   case Value of
     roRange: rbRange.Checked := True;
     roSelection: rbSelection.Checked := True;
     else rbSelectAll.Checked := True;
  end;
end;

procedure TFmeClientSelect.SetReportSort(const Value: TReportSort);
begin
   case Value of
     rsByStaffMember: rbStaffMember.checked := True;
     rsGroup: rbGroup.checked := True;
     rsClientType: rbClientType.checked := True;
     else  rbClient.checked := True;
  end;
end;

function TFmeClientSelect.Validate(Prompt: Boolean): Boolean;
   function SortText: string;
   begin
      case reportSort of
      rsByStaffMember : Result := 'staff member';
      rsGroup         : Result := 'group';
      rsClientType    : Result := 'client type';
      else Result := 'client';
      end;
   end;
begin
   Result := False;

   if rbRange.Checked then begin
       if (edtFromCode.Text = '')
       and (edtToCode.Text = '') then begin
          if Prompt then begin
              HelpfulInfoMsg( format('Please select a valid %s range.',[SortText]),0);
              edtFromCode.SetFocus;
          end;
          Exit;
       end;
   end else if rbSelection.Checked then begin
      if edtSelection.Text = '' then begin
         if Prompt then begin
             HelpfulInfoMsg( format('Please select at least one %s.',[SortText]),0);
             edtSelection.SetFocus;
         end;
         Exit;
      end;
   end;

   // Still here,
   Result := True;
end;

{ TClientSelectOptions }

function TClientSelectOptions.ClientInSelection(AClientCode: string): Boolean;
//Note: This is essentially the same as TCodingOptimisationOptions.SetClientSelectOptions
//      in CodingOptimisationReportRangeDlg.pas. May want to refactor at some point.
const
  FIRST_REC = '';
  LAST_REC  = 'þ';
var
  Key1, Key2: string[60];
  ClientFileRec: pClient_File_Rec;
  pUser: PUser_Rec;
  pGroup: pGroup_Rec;
  pClientType: pClient_Type_Rec;
  SortByName: string;
begin
  Result := False;

  if AClientCode <> '' then begin
    ClientFileRec := AdminSystem.fdSystem_Client_File_List.FindCode(AClientCode);
    if Assigned(ClientFileRec) then begin

      if (ClientFileRec^.cfClient_Type = ctProspect) then
         Exit;

      //Set keys
      Key1 := FIRST_REC;
      Key2 := LAST_REC;
      if RangeOption = roRange then begin
        if (FromCode <> '') then
           Key1 := FromCode;
        if (ToCode <> '') then
           Key2 := ToCode;
        if Key1 > Key2 then begin
           Key1 := Key2;
           Key2 := FromCode;
        end;
      end;

      //Check if included in selection
      case ReportSort of
        rsClient:
          begin
            //Client
            Result := ((ClientFileRec^.cfFile_Code >= Key1) and (ClientFileRec^.cfFile_Code <= Key2) and
                       (CodeSelectionList.Count = 0)) or
                      (CodeSelectionList.IndexOf(ClientFileRec^.cfFile_Code) > -1)
          end;
        rsByStaffMember:
          begin
            //Staff
            pUser := AdminSystem.fdSystem_User_List.FindLRN(ClientFileRec^.cfUser_Responsible);
            if Assigned(pUser) then
              Result := ((pUser^.usCode >= Key1) and (pUser^.usCode <= Key2) and
                         (RangeOption <> roSelection)) or
                        (CodeSelectionList.IndexOf(pUser^.usCode) > -1)
            else
              //no user record exists,  see if should include unallocated clients.
              //If the to code is blank then we include unallocated clients
              Result := (Key2 = LAST_REC) and
                        ((CodeSelectionList.Count = 0) or
                         (CodeSelectionList.IndexOf(' ') > -1));
          end;
        rsGroup:
          begin
            //Group
            pGroup := AdminSystem.fdSystem_Group_List.FindLRN(ClientFileRec^.cfGroup_LRN);
            if Assigned (pGroup) then begin
              SortByName := UpperCase(pGroup.grName);
              Result := ((SortByName >= Key1) and (SortByName <= Key2) and
                         (RangeOption <> roSelection)) or
                        (CodeSelectionList.IndexOf(SortByName) > -1)
            end else
              Result := (Key2 = LAST_REC) and
                        ((CodeSelectionList.Count = 0) or
                         (CodeSelectionList.IndexOf(' ') > -1));
          end;
        rsClientType:
          begin
            //Client type
            pClientType := AdminSystem.fdSystem_Client_Type_List.FindLRN(ClientFileRec^.cfClient_Type_LRN);
            if Assigned(pClientType) then begin
              SortByName := UpperCase(pClientType.ctName);
              Result := ((SortByName >= Key1) and (SortByName <= Key2) and
                         (RangeOption <> roSelection)) or
                        (CodeSelectionList.IndexOf(SortByName) > -1)
            end else
              Result := (Key2 = LAST_REC) and
                        ((CodeSelectionList.Count = 0) or
                         (CodeSelectionList.IndexOf(' ') > -1));
          end;
      end;
    end;
  end;
end;

constructor TClientSelectOptions.Create;
begin
  inherited;
  FCodeSelectionList := TStringList.Create;
  FCodeSelectionList.StrictDelimiter := True;
  FCodeSelectionList.Delimiter := ',';
end;

destructor TClientSelectOptions.Destroy;
begin
  FCodeSelectionList.Free;
  inherited;
end;

procedure TClientSelectOptions.SetClientFrom(const Value: string);
begin
  FClientFrom := Value;
end;


procedure TClientSelectOptions.SetClientTo(const Value: string);
begin
  FClientTo := Value;
end;

procedure TClientSelectOptions.SetRangeOption(const Value: TRangeOption);
begin
  FRangeOption := Value;
end;

procedure TClientSelectOptions.SetReportSort(const Value: TReportSort);
begin
  FReportSort := Value;
end;

end.
