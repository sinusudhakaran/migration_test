unit DivisionSelectorFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, clObj32, RptParams;

type
  TDivisionSelectorEvent = procedure() of object;

  TfmeDivisionSelector = class(TFrame)
    lblSelectDivisions: TLabel;
    chkDivisions: TCheckListBox;
    btnSelectAllDivisions: TButton;
    btnClearAllDivisions: TButton;
    chkSplitByDivision: TCheckBox;
    procedure btnSelectAllDivisionsClick(Sender: TObject);
    procedure btnClearAllDivisionsClick(Sender: TObject);
    procedure chkDivisionsClickCheck(Sender: TObject);
  private
    FOnDivisionsChanged: TDivisionSelectorEvent;
    { Private declarations }
    function CheckedCount: integer;
    procedure CMShowingChanged(var M: TMessage); message CM_SHOWINGCHANGED;
    function GetAllDivisionsSelected: Boolean;
    procedure SetOnDivisionsChanged(const Value: TDivisionSelectorEvent);
    procedure DoDivisionsChanged;
  public
    { Public declarations }
    procedure LoadDivisions(aClient: TClientObj);
    procedure UpdateClientDivisions(aClient: TClientObj);
    procedure UpdateSelectedDivisions(aParams: TGenRptParameters);
    property AllDivisionsSelected: Boolean read GetAllDivisionsSelected;
    property OnDivisionsChanged: TDivisionSelectorEvent read FOnDivisionsChanged write SetOnDivisionsChanged;
  end;

implementation

uses
  bkDefs, GLConst;

{$R *.dfm}

procedure TfmeDivisionSelector.btnClearAllDivisionsClick(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to ( chkDivisions.items.count - 1) do
    chkDivisions.checked[ i] := false;
  chkDivisionsClickCheck(Sender);
end;

procedure TfmeDivisionSelector.btnSelectAllDivisionsClick(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to ( chkDivisions.items.count - 1) do
    chkDivisions.checked[ i] := true;
  chkDivisionsClickCheck(Sender);
end;

function TfmeDivisionSelector.CheckedCount: integer;
var
  i: integer;
begin
  Result := 0;
  for i := 0 to chkDivisions.Count - 1 do
    if chkDivisions.Checked[i] then
      Inc(Result)
end;

procedure TfmeDivisionSelector.chkDivisionsClickCheck(Sender: TObject);
begin
  chkSplitByDivision.Enabled := (CheckedCount > 1);
  if not chkSplitByDivision.Enabled then
    chkSplitByDivision.Checked := False;
  DoDivisionsChanged;    
end;

procedure TfmeDivisionSelector.CMShowingChanged(var M: TMessage);
begin
   inherited;
   TabStop := False;
end;

procedure TfmeDivisionSelector.DoDivisionsChanged;
begin
  if Assigned(FOnDivisionsChanged) then
    OnDivisionsChanged;
end;

function TfmeDivisionSelector.GetAllDivisionsSelected: Boolean;
var
  i: integer;
begin
  Result := True;
  for i := 0 to chkDivisions.Count - 1 do
    if not chkDivisions.Checked[i] then begin
      Result := False;
      Break;
    end;
end;

procedure TfmeDivisionSelector.LoadDivisions(aClient: TClientObj);
var
  i : integer;
  dNo : integer;
  pA  : pAccount_Rec;
  Division_Used : Array [ 1..Max_Divisions] of boolean;
begin
  //load divisions
  chkDivisions.Items.Clear;

  //Add special 'No Division Allocated' division
  dNo := 0;
  chkDivisions.Items.AddObject('0 - (No Division Allocated)',
                                       TObject( dNo));

  //only load divisions that have been used in the clients chart
  FillChar( Division_Used, SizeOf( Division_Used), #0);

  with aClient do begin
    //set a flag to tell us if a particular division has been used
    for i := 0 to Pred( clChart.ItemCount) do begin
       pA := clChart.Account_At(i);
       for dNo := 1 to Max_Divisions do
          if pA^.chPrint_in_Division[dNo] then
             Division_Used[dNo] := true;
    end;
    //now load the divisions into the list
    for dNo := 1 to Max_Divisions do begin
      if Division_Used[ dNo] then
        chkDivisions.Items.AddObject(IntToStr(dNo) +
          ' - ' + clCustom_Headings_List.Get_Division_Heading( dNo), TObject( dNo));
    end;
  end;
  //Split by division
  chkSplitByDivision.Checked := aClient.clFields.clTemp_FRS_Split_By_Division;
end;

procedure TfmeDivisionSelector.SetOnDivisionsChanged(
  const Value: TDivisionSelectorEvent);
begin
  FOnDivisionsChanged := Value;
end;

procedure TfmeDivisionSelector.UpdateClientDivisions(aClient: TClientObj);
var
  i: integer;
  Division: integer;
begin
  SetLength(aClient.clFields.clTemp_FRS_Divisions, 0);
  if (not AllDivisionsSelected) or
     (AllDivisionsSelected and aClient.clFields.clTemp_FRS_Split_By_Division) then begin
    SetLength(aClient.clFields.clTemp_FRS_Divisions, Max_Divisions);
    for i := 0 to chkDivisions.Count - 1 do
      if chkDivisions.Checked[i] then begin
        Division := Integer(chkDivisions.Items.Objects[i]);
        aClient.clFields.clTemp_FRS_Divisions[Division] := True;
      end;
  end;
end;

procedure TfmeDivisionSelector.UpdateSelectedDivisions(
  aParams: TGenRptParameters);
var
  i,D: integer;
begin
  if (aParams.DivisionList.Count > 0) then
    //Multiple
    for i := 0 to Pred(aParams.DivisionList.Count) do begin
       D :=  chkDivisions.Items.IndexOfObject(aParams.DivisionList[i]);
       chkDivisions.Checked[D] := True;
    end
  else if (aParams.Division > 0)  then
    //Single
    chkDivisions.Checked[aParams.Division] := True
  else
    //All
    btnSelectAllDivisions.Click;
end;

end.
