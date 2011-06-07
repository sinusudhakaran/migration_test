unit SetupSubgroupsFrm;
//------------------------------------------------------------------------------
{
   Title:       Setup Sub-groups form

   Description:

   Remarks:

   Author:      Matthew Hopkins Jun01

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Grids_ts, TSGrid, bkConst, glConst, ExtCtrls,
  OSFont;

type
  TfrmSetupSubGroups = class(TForm)
    pnlButtons: TPanel;
    btnCopy: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    gdSubGroups: TtsGrid;

    procedure btnCopyClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure gdSubGroupsCellLoaded(Sender: TObject; DataCol,
      DataRow: Integer; var Value: Variant);
    procedure gdSubGroupsCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; ByUser: Boolean);
    procedure gdSubGroupsMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
    TempHeadings          : Array[0..Max_SubGroups] of String[60];

    procedure LoadSubGroups;
    procedure SaveSubGroups;
  public

  end;

function SetupSubGroups : boolean;

//******************************************************************************
implementation

uses
  BKHelp,
  bkXPThemes,
  clobj32,
  copyFromDlg,
  CustomHeadingsListObj,
  files,
  Globals,
  WarningMoreFrm,
  AuditMgr;

{$R *.DFM}

{ TfrmSetupSubGroups }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmSetupSubGroups.LoadSubGroups;
var
  SubGroupNo         : integer;
begin
  for SubGroupNo := 0 to Max_SubGroups do begin
    TempHeadings[ SubGroupNo] := MyClient.clCustom_Headings_List.Get_SubGroup_Heading( SubGroupNo);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmSetupSubGroups.SaveSubGroups;
var
  SubGroupNo : integer;
begin
  for SubGroupNo := 0 to Max_SubGroups do begin
    MyClient.clCustom_Headings_List.Set_SubGroup_Heading( SubGroupNo, TempHeadings[ SubGroupNo]);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SetupSubGroups : boolean;
var
  SetupSubGroups : TfrmSetupSubGroups;
begin
  Result := false;
  SetupSubGroups := TfrmSetupSubGroups.Create(Application.Mainform);
  with SetupSubGroups do
  begin
    try
      BKHelpSetUp(SetupSubGroups, BKH_Adding_sub_groups);
      LoadSubgroups;
      if ( ShowModal = mrOK) then begin

        //*** Flag Audit ***
        MyClient.ClientAuditMgr.FlagAudit(atCustomHeadings);

        SaveSubgroups;
        Result := true;
      end;
    finally
      Free;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmSetupSubGroups.btnCopyClick(Sender: TObject);
var
   Code       : string;
   FromClient : TClientObj;
   SubGroupNo    : integer;
begin
   //prompt user for client to copy from
   if SubgroupsCopyFrom('Copy Sub-groups from...',Code) then begin
      FromClient := nil;
      OpenAClient(Code,FromClient,false);
      try
         if not Assigned(FromClient) then begin
           HelpfulWarningMsg('Unable to open client '+code,0);
           exit;
         end;

         gdSubGroups.BeginUpdate;
         try
           //can just do a straight copy
           for SubGroupNo := 0 to Max_SubGroups do begin
             TempHeadings[ SubGroupNo] := FromClient.clCustom_Headings_List.Get_SubGroup_Heading( SubGroupNo);
           end;
         finally
           gdSubGroups.EndUpdate;
         end;
      finally
         CloseAClient(FromClient);
         FromClient := nil;
      end;
      gdSubGroups.Refresh;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmSetupSubGroups.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
   //make sure we save existing edits
   gdSubGroups.EndEdit( false);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmSetupSubGroups.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  gdSubGroups.HeadingFont := Font;
  gdSubGroups.Rows := Max_SubGroups + 1;
  gdSubGroups.Col[2].MaxLength := 60;
  btnCopy.Enabled := ( not CurrUser.HasRestrictedAccess);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmSetupSubGroups.gdSubGroupsCellLoaded(Sender: TObject;
  DataCol, DataRow: Integer; var Value: Variant);
begin
  if DataCol = 2 then
    Value := TempHeadings[ DataRow - 1]
  else begin
    if DataRow = 1 then
      Value := 'Unallocated'
    else
      Value := IntToStr( DataRow -1);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmSetupSubGroups.gdSubGroupsCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; ByUser: Boolean);
begin
  if ( DataCol = 2) and ( ByUser) then
    TempHeadings[ DataRow - 1] := gdSubGroups.CurrentCell.Value;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmSetupSubGroups.gdSubGroupsMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
var
  NewRow : integer;
begin
  NewRow := gdSubGroups.CurrentDataRow;

  if WheelDelta < 0 then begin
    if Shift = [] then
      NewRow := gdSubGroups.CurrentDataRow + 1;

    if Shift = [ ssShift] then
      NewRow := gdSubGroups.CurrentDataRow + 10;

    if NewRow > gdSubGroups.Rows then
      NewRow := gdSubGroups.Rows;
  end
  else begin
    if Shift = [] then
      NewRow := gdSubGroups.CurrentDataRow - 1;

    if Shift = [ ssShift] then
      NewRow := gdSubGroups.CurrentDataRow - 10;

    if NewRow < 1 then
      NewRow := 1;
  end;

  if NewRow in [ 1..gdSubGroups.Rows] then begin
    gdSubGroups.CurrentDataRow := NewRow;
    gdSubGroups.PutCellInView(2,NewRow);
  end;
  Handled := true;
end;

end.
