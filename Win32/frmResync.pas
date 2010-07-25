unit frmResync;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  TResynchronizeFrm = class(TForm)
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    Splitter1: TSplitter;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    eSysdb: TEdit;
    lClients: TListView;
    Eexe: TEdit;
    Label2: TLabel;
    btn: TButton;
    procedure FormCreate(Sender: TObject);
    procedure lClientsDeletion(Sender: TObject; Item: TListItem);
    procedure lClientsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure btnClick(Sender: TObject);
  private
    procedure CheckDir;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ResynchronizeFrm: TResynchronizeFrm;

implementation

{$R *.dfm}
uses
   Globals,
   Admin32,
   clobj32,
   SYdefs,
   BkDefs;
{ TForm1 }


procedure TResynchronizeFrm.btnClick(Sender: TObject);
var I: integer;
    cr: pClient_File_Rec;
    kc: TCursor;
begin
   btn.Enabled := False;
   kc := Screen.Cursor;
   Screen.Cursor := crHourGlass;

   LoadAdminSystem(True, 'ReySync');
   try
      for I := 0 to pred(lClients.Items.Count) do
         if lClients.Items[I].Selected then
            if assigned(lClients.Items[I].Data) then
            with TClientObj(lClients.Items[I].Data) do begin
               cr := AdminSystem.fdSystem_Client_File_List.FindCode(clFields.clCode);
               if assigned(cr) then begin
                  clFields.clMagic_Number := AdminSystem.fdFields.fdMagic_Number;
                  Save;
                  cr.cfForeign_File := False;
               end;
            end;

   finally
     SaveAdminSystem;
     Screen.Cursor := kc;
   end;

   CheckDir;
end;

procedure TResynchronizeFrm.CheckDir;
var I: Integer;

   procedure CheckClient(Value: string);
   var lc: TClientObj;
       P: Integer;
      function CanLink: Boolean;
      begin
         Result := False;
         if lc.clFields.clMagic_Number = Globals.AdminSystem.fdFields.fdMagic_Number then
            Exit; // Already done..
              // Is this all ???
         Result := True;
      end;

   begin
      lc := TClientObj.Create;
      try try
         lc.Open(Value,Globals.FILEEXTN);
         if CanLink then
            lClients.AddItem(lc.clFields.clCode,lc)
         else
            lc.Free;
      except
         on E: exception do begin
            //lClients.AddItem(Value  + ' ' + E.Message, nil);
            lc.Free;
         end;
      end;
      finally

      end;
   end;

begin
   lClients.Clear;

   if Admin32.AdminExists then begin
      if LoadAdminSystem(False, 'reLink') then begin

         eSysDB.Text := IntTostr(Globals.AdminSystem.fdFields.fdFile_Version);

         for I := AdminSystem.fdSystem_Client_File_List.First to
            AdminSystem.fdSystem_Client_File_List.Last do
               CheckClient(AdminSystem.fdSystem_Client_File_List.Client_File_At(I).cfFile_Code);


          if Lclients.Items.Count = 0 then
              lClients.AddItem('No foreign clients found' ,nil)
      end else begin
         eSysDB.Text := 'Can''t read System.db';
      end;
   end else begin
      eSysDB.Text := 'System.db not found';
   end;
end;

procedure TResynchronizeFrm.FormCreate(Sender: TObject);
begin
   Eexe.Text := BKdefs.BK_FILE_VERSION_STR + '.' + IntToStr(BkDefs.BK_FILE_VERSION);
   CheckDir;
end;

procedure TResynchronizeFrm.lClientsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
   btn.Enabled := lClients.SelCount > 0;
end;

procedure TResynchronizeFrm.lClientsDeletion(Sender: TObject; Item: TListItem);
begin
   if assigned(Item.Data) then
       TObject(Item.Data).Free;
end;

end.
