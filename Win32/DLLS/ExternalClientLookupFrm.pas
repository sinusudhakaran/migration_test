unit ExternalClientLookupFrm;
//------------------------------------------------------------------------------
{
   Title:         Simple Lookup Form for BankLink Client codes

   Description:   Designed to be part of bklookup.dll

   Author:        Matthew Hopkins - Oct 2004

   Remarks:       Requires LOOKUPDLL to be defined so that globals and logutil
                  don't try to hook in the rest of bk5

   Revisions:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ImgList;

type
  TfrmBKLookup = class(TForm)
    pnlFooter: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    lvClient: TListView;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure lvClientDblClick(Sender: TObject);
    procedure lvClientColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvClientCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
  private
    { Private declarations }
    SortCol : integer;

    procedure PopulateGrid;
    procedure SetSelectedCode(const Value: ShortString);
    function  GetSelectedCode : ShortString;
  public
    { Public declarations }
    property SelectedCode : ShortString read GetSelectedCode write SetSelectedCode;
  end;

function LookupBKClientCode( aHandle : THandle; DefaultCode, SelectedCode : PChar) : LongBool; stdcall;
//accept a default code and return the code selected by the user in selectedCode
//return true if a code selected and ok pressed
//parameters:  aHandle : handle of calling application
//             defaultCode : default code to select in list
//             selectedCode : code selected from list will be returned here
//                            max length is 10 char
//                            Memory for pChar must be allocated by the calling
//                            routine
//******************************************************************************
implementation
uses
  Admin32, Globals, syDefs, lvUtils, bkconst, StStrS;
                                                       
{$R *.dfm}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBKLookup.FormCreate(Sender: TObject);
begin
  PopulateGrid;
  SortCol := 0;
  lvClient.Columns[0].ImageIndex := 0;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmBKLookup.GetSelectedCode: ShortString;
begin
  if lvClient.Selected <> nil then
    result := lvClient.Selected.Caption
  else
    result := '';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBKLookup.lvClientDblClick(Sender: TObject);
begin
  if lvClient.Selected <> nil then
    btnOK.Click;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBKLookup.PopulateGrid;
var
  i : integer;
  ClientRec : pClient_File_Rec;
  newItem : TListItem;
begin
  for i := GlobalAdminSnapshot.fdSystem_Client_File_List.First to
           GlobalAdminSnapshot.fdSystem_Client_File_List.Last do
  begin
    ClientRec := GlobalAdminSnapshot.fdSystem_Client_File_List.Client_File_At(i);
    //only return active clients
    if ClientRec.cfClient_Type = bkConst.ctActive then
    begin
      newItem := lvClient.Items.Add;
      newItem.ImageIndex := -1;
      newItem.Caption := ClientRec^.cfFile_Code;
      newItem.SubItems.Add( ClientRec^.cfFile_Name);
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBKLookup.SetSelectedCode(const Value: ShortString);
var
  SelectedItem : TListItem;
begin
  if (Value <> '') then
  begin
    SelectedItem := lvClient.FindCaption(0, Value, False, True, True);
    if Assigned( SelectedItem) then
    begin
      SelectListViewItem(lvClient, SelectedItem);
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function LookupBKClientCode( aHandle : THandle; DefaultCode, SelectedCode : PChar) : LongBool; stdcall;
//parameters:
// aHandle : application handle so that can be called from a dll
// DefaultCode : pChar containing default code to selected
// SelectedCode : pChar containing the returned boolean, will be max of 10 bytes
//                memory must be allocated before calling
var
  aCode : string;
  LookupForm : TfrmBKLookup;
  sDefaultCode : string;
begin
  Result := false;
  try
    //load admin system
    Admin32.ReloadAdminAndTakeSnapshot( Globals.GlobalAdminSnapshot);

    //convert default code from pchar to string;
    sDefaultCode := DefaultCode;

    //create the lookup form and position on selected code
    LookupForm := TfrmBKLookup.Create( Application );
    try
      LookupForm.SelectedCode := sDefaultCode;
      if LookupForm.ShowModal = mrOK then
      begin
        //set the return code if one selected
        aCode := LookupForm.SelectedCode;
        if ( aCode <> '') then
        begin
          StrPCopy( SelectedCode, aCode);
          result := true;
        end;
      end;
    finally
      LookupForm.Release;
    end;
  except
    On E : Exception do
    begin
      MessageDlg('Error in bkLookup: ' + E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TfrmBKLookup.lvClientColumnClick(Sender: TObject;
  Column: TListColumn);
var
 i : integer;
begin
  for i := 0 to lvClient.columns.Count-1 do
    lvClient.columns[i].ImageIndex := -1;
  column.ImageIndex := 0;

  SortCol := Column.ID;
  lvClient.AlphaSort;
end;


procedure TfrmBKLookup.lvClientCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  Key1,Key2 : ShortString;
begin
  case SortCol of
  0: begin
       Key1 := Item1.Caption;
       Key2 := Item2.Caption;
     end;
  else
     begin
       Key1 := Item1.SubItems.Strings[SortCol-1];
       Key2 := Item2.SubItems.Strings[SortCol-1];
     end;
  end; {case}

  Compare := StStrS.CompStringS(Key1,Key2);
end;

end.
