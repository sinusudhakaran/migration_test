unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SYDEFS, ComCtrls, Spin, Grids, AuditMgr;

type
  TForm1 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    ListView2: TListView;
    Edit1: TEdit;
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    btnSavePayee: TButton;
    TabSheet2: TTabSheet;
    btnSaveUser: TButton;
    ListView3: TListView;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    btnDelete: TButton;
    Label7: TLabel;
    ListView4: TListView;
    Label6: TLabel;
    ListView1: TListView;
    TabSheet3: TTabSheet;
    Button2: TButton;
    TabSheet4: TTabSheet;
    Label8: TLabel;
    Edit5: TEdit;
    Label9: TLabel;
    Edit6: TEdit;
    Label10: TLabel;
    StringGrid1: TStringGrid;
    Button3: TButton;
    TabSheet5: TTabSheet;
    cbAuditTypes: TComboBox;
    Edit7: TEdit;
    Label11: TLabel;
    Label12: TLabel;
    ListView5: TListView;
    btnByTxnType: TButton;
    ListView6: TListView;
    btnListAuditTypes: TButton;
    btnByTxnID: TButton;
    btnSaveToCSV: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ListView2SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btnSavePayeeClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSaveUserClick(Sender: TObject);
    procedure ListView3SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ListView2Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure btnDeleteClick(Sender: TObject);
    procedure ListView3Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btnListAuditTypesClick(Sender: TObject);
    procedure btnByTxnTypeClick(Sender: TObject);
    procedure btnByTxnIDClick(Sender: TObject);
    procedure btnSaveToCSVClick(Sender: TObject);
  private
    { Private declarations }
    procedure DisplayClientAuditRecs;
    procedure DisplayPracticeDetails;
    procedure DisplaySystemAuditRecs;
    procedure DisplayPayees;
    procedure DisplayUsers;
    procedure LoadAuditTypes;
    procedure DisplayAuditRecsByAuditType(AAuditType: TAuditType);
    procedure DisplayAuditRecsByTransactionID(ARecordID: integer);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  BKDEFS, BKPDIO, SYUSIO, ClientDB, UserTable, SystemDB,
  SYAUDIT, BKAUDIT;

{$R *.dfm}

procedure TForm1.btnSaveUserClick(Sender: TObject);
var
  User: pUser_Rec;
begin
  if ListView3.SelCount > 0 then
    //Change
    User := pUser_Rec(ListView3.ItemFocused.SubItems.Objects[0])
  else
    //Add
    User := SystemData.UserTable.NewUser;

  //Set values
  User.usCode := Edit2.Text;
  User.usName := Edit3.Text;
  User.usEMail_Address := Edit4.Text;

  //*** Flag Audit ***
  SystemAuditMgr.FlagAudit(atUsers);

  //Save
  SystemData.SaveToFile(SYSTEM_DB);

  //Display
  DisplayUsers;
  DisplaySystemAuditRecs;
  Edit2.Text := '';
  Edit3.Text := '';
  Edit4.Text := '';
end;

procedure TForm1.btnByTxnIDClick(Sender: TObject);
var
  RecordID: integer;
begin
  //Filter audit records by audit type
  RecordID := StrToInt(Edit7.Text);
  DisplayAuditRecsByTransactionID(RecordID);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  User: pUser_Rec;
begin
  //Delete
  User := pUser_Rec(ListView3.ItemFocused.SubItems.Objects[0]);
  SystemData.UserTable.DeleteUser(User);

  //*** Flag Audit ***
  SystemAuditMgr.FlagAudit(atUsers);

  //Save
  SystemData.SaveToFile(SYSTEM_DB);

  //Display
  ListView3.ItemFocused.Delete;
  DisplayUsers;
  DisplaySystemAuditRecs;
  Edit2.Text := '';
  Edit3.Text := '';
  Edit4.Text := '';
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i: integer;
begin
  SystemData.PracticeDetails.fdPractice_Name_for_Reports := Edit5.Text;
  SystemData.PracticeDetails.fdPractice_Phone := Edit6.Text;

  //*** Flag Audit ***
  SystemAuditMgr.FlagAudit(atPracticeSetup);

  for i := Low(SystemData.PracticeDetails.fdGST_Class_Types) to
           High(SystemData.PracticeDetails.fdGST_Class_Types) do begin
    SystemData.PracticeDetails.fdGST_Class_Names[i] := StringGrid1.Cells[0, i];
    SystemData.PracticeDetails.fdGST_Rates[i+1, 1] := StrToFloat(StringGrid1.Cells[1, i]);
    SystemData.PracticeDetails.fdGST_Rates[i+1, 2] := StrToFloat(StringGrid1.Cells[1, i]);
    SystemData.PracticeDetails.fdGST_Rates[i+1, 3] := StrToFloat(StringGrid1.Cells[1, i]);
  end;

  //*** Flag Audit ***
  SystemAuditMgr.FlagAudit(atPracticeGSTDefaults);

  //Save
  SystemData.SaveToFile(SYSTEM_DB);

  //Display
  DisplaySystemAuditRecs;
end;

procedure TForm1.btnByTxnTypeClick(Sender: TObject);
var
  AuditType: TAuditType;
begin
  //Filter audit records by audit type
  AuditType := TAuditType(cbAuditTypes.Items.Objects[cbAuditTypes.ItemIndex]);
  DisplayAuditRecsByAuditType(AuditType);
end;

procedure TForm1.btnListAuditTypesClick(Sender: TObject);
var
  i: integer;
  ListItem: TListItem;
begin
  for i := atMin to atMax do begin
    ListItem := ListView6.Items.Add;
    ListItem.Caption := ClientAuditMgr.AuditTypeToStr(i);
    ListItem.SubItems.Add(ClientAuditMgr.AuditTypeToDBStr(i));
    ListItem.SubItems.Add(ClientAuditMgr.AuditTypeToTableStr(i));
  end;
end;

procedure TForm1.btnSaveToCSVClick(Sender: TObject);
var
  i, j: integer;
  StringList: TStringList;
  AuditRec: string;
begin
  StringList := TStringList.Create;
  try
    for i := 0 to ListView5.Items.Count - 1 do begin
      AuditRec := ListView5.Items[i].Caption;
      for j := 0 to ListView5.Items[i].SubItems.Count - 1 do begin
        AuditRec := AuditRec + ',' + ListView5.Items[i].SubItems[j];
      end;
      StringList.Add(AuditRec);
    end;
    StringList.SaveToFile('Audit.csv');
  finally
    StringList.Free
  end;
end;

procedure TForm1.btnDeleteClick(Sender: TObject);
var
  Payee: pPayee_Detail_Rec;
begin
  //Delete
  Payee := pPayee_Detail_Rec(ListView2.ItemFocused.SubItems.Objects[0]);
  Client.PayeeTable.DeletePayee(Payee);

  //*** Flag Audit ***
  ClientAuditMgr.FlagAudit(atPayees);

  //Save
  Client.SaveToFile(CLIENT_DB);

  //Display
  ListView2.ItemFocused.Delete;
  DisplayPayees;
  DisplayClientAuditRecs;
  Spinedit1.Value := 0;
  Edit1.Text := '';
end;

procedure TForm1.btnSavePayeeClick(Sender: TObject);
var
  Payee: pPayee_Detail_Rec;
begin
  if ListView2.SelCount > 0 then
    //Change
    Payee := pPayee_Detail_Rec(ListView2.ItemFocused.SubItems.Objects[0])
  else
    //Add
    Payee := Client.PayeeTable.NewPayee;

  //Set values
  Payee.pdNumber := Spinedit1.Value;
  Payee.pdName := Edit1.Text;

  //*** Flag Audit ***
  ClientAuditMgr.FlagAudit(atPayees);

  //Save
  Client.SaveToFile(CLIENT_DB);

  //Display
  DisplayPayees;
  DisplayClientAuditRecs;
  Spinedit1.Value := 0;
  Edit1.Text := '';
end;

procedure TForm1.DisplayAuditRecsByAuditType(AAuditType: TAuditType);
var
  i: integer;
  ListItem: TListItem;
  DB: string;
begin
  ListView5.Items.Clear;
  //Get DB
  DB := SystemAuditMgr.AuditTypeToDBStr(AAuditType);
  //Filter records by audit type
  if (DB = 'SY') then begin
    with SystemData.AuditTable.AuditRecords do
      for i := First to Last do begin
        if SystemData.AuditTable.AuditRecords.Audit_At(i).atTransaction_Type = AAuditType then begin
          ListItem := ListView5.Items.Add;
          ListItem.Caption := IntToStr(i);
          SystemData.AuditTable.SetAuditStrings(i, ListItem.SubItems);
        end;
      end;
  end else begin
    with Client.AuditTable.AuditRecords do
      for i := First to Last do begin
        if Client.AuditTable.AuditRecords.Audit_At(i).atTransaction_Type = AAuditType then begin
          ListItem := ListView5.Items.Add;
          ListItem.Caption := IntToStr(i);
          Client.AuditTable.SetAuditStrings(i, ListItem.SubItems);
        end;
      end;
  end;
end;

procedure TForm1.DisplayAuditRecsByTransactionID(ARecordID: integer);
var
  i: integer;
  ListItem: TListItem;
begin
  ListView5.Items.Clear;
  //System
  with SystemData.AuditTable.AuditRecords do
    for i := First to Last do begin
      if SystemData.AuditTable.AuditRecords.Audit_At(i).atRecord_ID = ARecordID then begin
        ListItem := ListView5.Items.Add;
        ListItem.Caption := IntToStr(i);
        SystemData.AuditTable.SetAuditStrings(i, ListItem.SubItems);
      end;
    end;
  //Client
  with Client.AuditTable.AuditRecords do
    for i := First to Last do begin
      if Client.AuditTable.AuditRecords.Audit_At(i).atRecord_ID = ARecordID then begin
        ListItem := ListView5.Items.Add;
        ListItem.Caption := IntToStr(i);
        Client.AuditTable.SetAuditStrings(i, ListItem.SubItems);
      end;
    end;
end;

procedure TForm1.DisplayClientAuditRecs;
var
  i: integer;
  ListItem: TListItem;
begin
  ListView1.Items.Clear;
  with Client.AuditTable.AuditRecords do
    for i := First to Last do begin
      ListItem := ListView1.Items.Add;
      ListItem.Caption := IntToStr(i);
      Client.AuditTable.SetAuditStrings(i, ListItem.SubItems);
    end;
end;

procedure TForm1.DisplayPayees;
var
  i: integer;
  ListItem: TListItem;
  Payee: pPayee_Detail_Rec;
begin
  ListView2.Items.Clear;
  for i := 0 to Client.PayeeTable.Count - 1 do begin
    Payee := Client.PayeeTable.Items[i];
    ListItem := ListView2.Items.Add;
    ListItem.Caption := IntToStr(Payee.pdAudit_Record_ID);
    ListItem.SubItems.AddObject(IntToStr(Payee.pdNumber), TObject(Payee));
    ListItem.SubItems.Add(Payee.pdName);
  end;
  ListView2.ItemIndex := -1;
end;

procedure TForm1.DisplayPracticeDetails;
var
  i: integer;
begin
  Edit5.Text := SystemData.PracticeDetails.fdPractice_Name_for_Reports;
  Edit6.Text := SystemData.PracticeDetails.fdPractice_Phone;

  StringGrid1.RowCount := High(SystemData.PracticeDetails.fdGST_Class_Types);
  for i := Low(SystemData.PracticeDetails.fdGST_Class_Types) to
           High(SystemData.PracticeDetails.fdGST_Class_Types) do begin
    StringGrid1.Cells[0, i] := SystemData.PracticeDetails.fdGST_Class_Names[i];
    StringGrid1.Cells[1, i] := FloatToStr(SystemData.PracticeDetails.fdGST_Rates[i+1, 1]);
    StringGrid1.Cells[2, i] := FloatToStr(SystemData.PracticeDetails.fdGST_Rates[i+1, 2]);
    StringGrid1.Cells[3, i] := FloatToStr(SystemData.PracticeDetails.fdGST_Rates[i+1, 3]);
  end;
end;

procedure TForm1.DisplaySystemAuditRecs;
var
  i: integer;
  ListItem: TListItem;
begin
  ListView4.Items.Clear;
  with SystemData.AuditTable.AuditRecords do
    for i := First to Last do begin
      ListItem := ListView4.Items.Add;
      ListItem.Caption := IntToStr(i);
      SystemData.AuditTable.SetAuditStrings(i, ListItem.SubItems);
    end;
end;

procedure TForm1.DisplayUsers;
var
  i: integer;
  ListItem: TListItem;
  User: pUser_Rec;
begin
  ListView3.Items.Clear;
  for i := 0 to SystemData.UserTable.Count - 1 do begin
    User := SystemData.UserTable.Items[i];
    ListItem := ListView3.Items.Add;
    ListItem.Caption := User.usCode;
    ListItem.SubItems.AddObject(User.usName, TObject(User));
    ListItem.SubItems.Add(User.usEMail_Address);
  end;
  ListView3.ItemIndex := -1;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SystemData.LoadFromFile(SYSTEM_DB);
  Client.LoadFromFile(CLIENT_DB);

  DisplayClientAuditRecs;
  DisplayPayees;

  DisplaySystemAuditRecs;
  DisplayUsers;

  DisplayPracticeDetails;

  LoadAuditTypes;

  PageControl1.ActivePageIndex := 0;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  SystemData.SaveToFile(SYSTEM_DB);
  Client.SaveToFile(CLIENT_DB);
end;

procedure TForm1.ListView2Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  btnDelete.Enabled := False;
  if Assigned(Item) then
    btnDelete.Enabled := Item.Focused;
end;

procedure TForm1.ListView2SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  SpinEdit1.Value := pPayee_Detail_Rec(Item.SubItems.Objects[0]).pdNumber;
  Edit1.Text := pPayee_Detail_Rec(Item.SubItems.Objects[0]).pdName;
end;

procedure TForm1.ListView3Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  Button2.Enabled := False;
  if Assigned(Item) then
    Button2.Enabled := Item.Focused;
end;

procedure TForm1.ListView3SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  Edit2.Text := pUser_Rec(Item.SubItems.Objects[0]).usCode;
  Edit3.Text := pUser_Rec(Item.SubItems.Objects[0]).usName;
  Edit4.Text := pUser_Rec(Item.SubItems.Objects[0]).usEMail_Address;
end;

procedure TForm1.LoadAuditTypes;
var
  i: integer;
begin
  cbAuditTypes.Clear;
  for i := atMin to atMax do
    cbAuditTypes.Items.AddObject(ClientAuditMgr.AuditTypeToStr(i), TObject(i));
end;

end.
