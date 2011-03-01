unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SYDEFS, ComCtrls, Spin;

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
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Memo2: TMemo;
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
    procedure Button1Click(Sender: TObject);
    procedure ListView3Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    procedure DisplayClientAuditRecs;
    procedure DisplaySystemAuditRecs;
    procedure DisplayPayees;
    procedure DisplayUsers;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  BKDEFS, BKPDIO, SYUSIO, ClientDB, AuditMgr, UserTable, SystemDB,
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

procedure TForm1.Button1Click(Sender: TObject);
var
  i: integer;
begin
  //List tables
  memo1.Clear;
  for i := 0 to 254 do begin
    if SYAuditNames.GetAuditTableName(i) <> '' then
      Memo1.Lines.Add(SYAuditNames.GetAuditTableName(i) + ' (SY)');
    if BKAuditNames.GetAuditTableName(i) <> '' then
      Memo1.Lines.Add(BKAuditNames.GetAuditTableName(i) + ' (BK)');
  end;
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
begin
  Memo2.Clear;
  ClientAuditMgr.TablesToAudit(Memo2.Lines);
  SystemAuditMgr.TablesToAudit(Memo2.Lines);
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

end.
