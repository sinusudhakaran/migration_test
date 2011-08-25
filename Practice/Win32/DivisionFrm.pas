unit DivisionFrm;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Remarks:

   Author:

}
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, glConst, Grids_ts, TSGrid, ExtCtrls,
  OsFont;

type
  TDivisionDlg = class(TForm)
    pnlButtons: TPanel;
    btnCopy: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    gdDivisions: TtsGrid;

    procedure btnCopyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure gdDivisionsCellLoaded(Sender: TObject; DataCol,
      DataRow: Integer; var Value: Variant);
    procedure gdDivisionsCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; ByUser: Boolean);
    procedure gdDivisionsMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
    TempHeadings          : Array[1..Max_Divisions] of String[60];

    procedure LoadDivisions;
    procedure SaveDivisions;
  public

  end;

function EditDivisions : boolean;

//******************************************************************************
implementation

uses
  BKHelp,
  bkXPThemes,
  clobj32,
  CopyFromDlg,
  CustomHeadingsListObj,
  files,
  Globals,
  WarningMorefrm,
  AuditMgr;

{$R *.DFM}

function EditDivisions : boolean;
var
  Division : TDivisionDlg;
begin
  Result := false;
  Division := TDivisionDlg.Create(Application);
  with Division do
  begin
    try
      BKHelpSetUp(Division, BKH_Adding_divisions);
      LoadDivisions;
      if ( ShowModal = mrOK) then begin

        //*** Flag Audit ***
        MyClient.ClientAuditMgr.FlagAudit(arCustomHeadings);

        SaveDivisions;
        Result := true;
      end;
    finally
      Free;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDivisionDlg.btnCopyClick(Sender: TObject);
var
  Code       : string;
  FromClient : TClientObj;
  DivisionNo : integer;
begin
  if SelectCopyFrom('Copy Divisions from...',Code) then begin
   FromClient := nil;
   OpenAClient(Code,FromClient,false);
   try
     if not Assigned(FromClient) then
     begin
       HelpfulWarningMsg('Unable to open client '+code,0);
       exit;
     end;
     //have both clients open, begin copying..
     gdDivisions.BeginUpdate;
     try
       //can just do a straight copy
       for DivisionNo := 1 to Max_Divisions do begin
         TempHeadings[ DivisionNo] := FromClient.clCustom_Headings_List.Get_Division_Heading( DivisionNo);
       end;
     finally
       gdDivisions.EndUpdate;
     end;
     gdDivisions.Refresh;
   finally
     CloseAClient(FromClient);
     FromClient := nil;
   end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDivisionDlg.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);
   gdDivisions.HeadingFont := Font;
   gdDivisions.Rows := Max_Divisions;
   gdDivisions.Col[2].MaxLength := 60;
   btnCopy.Enabled := ( not CurrUser.HasRestrictedAccess);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TDivisionDlg.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
   //make sure we save existing edits
   gdDivisions.EndEdit( false);
end;

procedure TDivisionDlg.gdDivisionsCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
begin
  if DataCol = 2 then
    Value := TempHeadings[ DataRow]
  else begin
    Value := IntToStr( DataRow);
  end;
end;

procedure TDivisionDlg.gdDivisionsCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; ByUser: Boolean);
begin
  if ( DataCol = 2) and ( ByUser) then
    TempHeadings[ DataRow] := gdDivisions.CurrentCell.Value;
end;

procedure TDivisionDlg.LoadDivisions;
var
  DivisionNo         : integer;
begin
  for DivisionNo := 1 to Max_Divisions do begin
    TempHeadings[ DivisionNo] := MyClient.clCustom_Headings_List.Get_Division_Heading( DivisionNo);
  end;
end;

procedure TDivisionDlg.SaveDivisions;
var
  DivisionNo         : integer;
begin
  for DivisionNo := 1 to Max_Divisions do begin
    MyClient.clCustom_Headings_List.Set_Division_Heading( DivisionNo, TempHeadings[ DivisionNo]);
  end;
end;

procedure TDivisionDlg.gdDivisionsMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
var
  NewRow : integer;
begin
  NewRow := gdDivisions.CurrentDataRow;

  if WheelDelta < 0 then begin
    if Shift = [] then
      NewRow := gdDivisions.CurrentDataRow + 1;

    if Shift = [ ssShift] then
      NewRow := gdDivisions.CurrentDataRow + 10;

    if NewRow > gdDivisions.Rows then
      NewRow := gdDivisions.Rows;
  end
  else begin
    if Shift = [] then
      NewRow := gdDivisions.CurrentDataRow - 1;

    if Shift = [ ssShift] then
      NewRow := gdDivisions.CurrentDataRow - 10;

    if NewRow < 1 then
      NewRow := 1;
  end;

  if NewRow in [ 1..gdDivisions.Rows] then begin
    gdDivisions.CurrentDataRow := NewRow;
    gdDivisions.PutCellInView(2,NewRow);
  end;
  Handled := true;
end;
end.

