unit BudgetDetailDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OvcBase, OvcEF, OvcPB, OvcPF, budobj32, Mask, RzEdit, RzSpnEdt,
  OSFont;

type
  TdlgBudgetDetail = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    eName: TEdit;
    OvcController1: TOvcController;                                       
    cmbBudget: TComboBox;
    btnOK: TButton;
    btnCancel: TButton;
    cmbStartMonth: TComboBox;
    spnStartYear: TRzSpinEdit;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
    Budget    : TBudget;

    function CanPostBudget: boolean;
    procedure LoadMonths;
    procedure LoadBudgets;
    function CreateNewBudget(var aBudget: TBudget): Boolean;
  public
    { Public declarations }
    //function Execute : boolean;
  end;

  function AddBudget(var aBudget : TBudget) : boolean;
//******************************************************************************
implementation

{$R *.DFM}

uses
   globals,
   bkConst,
   bkhelp,
   bkDateUtils,
   bkXPThemes,
   ovcDate,
   stdatest,
   bkdefs,
   selectdate,
   ErrorMoreFrm,
   bkbdio;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgBudgetDetail.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  SetUpHelp;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgBudgetDetail.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := BKH_Creating_budgets;
   //Components
   cmbStartMonth.Hint :=
      'Enter the Budget Start Date|'+
      'Enter the start date for the Budget';
   eName.Hint     :=
      'Enter a Budget name|'+
      'Enter a name for this Budget';
   cmbBudget.Hint :=
      'Select an existing Budget to copy figures from|'+
      'Select an existing Budget to copy figures from';
end;
//------------------------------------------------------------------------------
procedure CopyBudgetValues(FromBudget, ToBudget: TBudget);
var
  i,j : integer;
  OldLine,
  NewBudgetLine : pBudget_Detail_Rec;
  AccountCode: String[ 20 ];
  CodeRec: pAccount_Rec;
begin
  if not (Assigned(FromBudget) and Assigned(ToBudget)) then exit;

  ToBudget.buDetail.FreeAll;

  for i := 0 to FromBudget.buDetail.ItemCount-1 do
  begin
     OldLine := FromBudget.buDetail.Budget_Detail_At(i);
     AccountCode := OldLine.bdAccount_Code;
     CodeRec := MyClient.clChart.FindCode(AccountCode);
     if Assigned(CodeRec) then
     begin
       if CodeRec.chPosting_Allowed then
       begin
         NewBudgetLine := New_Budget_Detail_Rec;
         NewBudgetLine.bdAccount_Code := AccountCode;
         NewBudgetLine.bdPercent_Account := OldLine.bdPercent_Account;
         NewBudgetLine.bdPercentage := OldLine.bdPercentage;
         for j := 1 to 12 do
         begin
           NewBudgetLine.bdBudget[j] := OldLine.bdBudget[j];
           NewBudgetLine.bdQty_Budget[j] := OldLine.bdQty_Budget[j];
           NewBudgetLine.bdEach_Budget[j] := OldLine.bdEach_Budget[j];
         end;

         ToBudget.buDetail.Insert(NewBudgetLine);
       end;
     end;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgBudgetDetail.btnOKClick(Sender: TObject);
begin
  if CanPostBudget then
    ModalResult := mrOK;
end;

//------------------------------------------------------------------------------
function TdlgBudgetDetail.CanPostBudget: boolean;
var
  DateFrom : Integer;
  tempBudget : TBudget;
  i : integer;
begin
  result := false;

  {check that given values are ok}
  if eName.Text = '' then
  begin
    HelpfulErrorMsg( 'You must enter a name for the budget', 0 );
    exit;
  end;

  //check if a budget with the same name and date already exists
  DateFrom := DMYToStDate(1, cmbStartMonth.ItemIndex + 1, spnStartYear.IntValue, EPOCH);
  DateFrom := StNull2BK(DateFrom);
  tempBudget := NIL;
  With MyClient.clBudget_List do
      For I := 0 to Pred( itemCount ) do
         With Budget_At( I ), buFields do
            If ( buName = eName.text ) and
               ( buStart_Date = DateFrom ) then
                  tempBudget := Budget_At( I );

   If tempBudget<>NIL then
   Begin
      HelpfulErrorMsg( 'A Budget with this name and start date already exists', 0 );
      exit;
   end;

   result := true;
end;
//------------------------------------------------------------------------------
procedure TdlgBudgetDetail.LoadMonths;
var i: integer;
begin
  cmbStartMonth.Items.Clear;
  for i := (moMin + 1) to moMax do
    cmbStartMonth.Items.Add(moNames[i]);
end;

procedure TdlgBudgetDetail.LoadBudgets;
var i: Integer;
    BudgetStr: String;
begin
  cmbBudget.Items.Clear;
  cmbBudget.Items.AddObject('<none>',nil);

  for i := MyClient.clBudget_List.ItemCount-1 downto 0 do
  begin
     Budget := MyClient.clBudget_List.Budget_At(i);
     BudgetStr := Budget.buFields.buName+ ' ('+ bkDate2Str(Budget.buFields.buStart_Date) +')';
     cmbBudget.Items.AddObject(BudgetStr,Budget);
   end;

  cmbBudget.ItemIndex   := 0;
end;

//------------------------------------------------------------------------------
function AddBudget(var aBudget : TBudget) : boolean;
var
  DlgBudgetDetail : tDlgBudgetDetail;
  Day, Month, Year : Integer;
begin
  result := false;
  if Assigned(aBudget) then aBudget := nil;

  DlgBudgetDetail := tDlgBudgetDetail.Create(Application.MainForm);
  try
    with DlgBudgetDetail do
    begin
      Budget := aBudget;
      LoadMonths;

      //set default
      StDateToDMY(MyClient.clFields.clFinancial_Year_Starts, Day, Month, Year);

      cmbStartMonth.ItemIndex := Month-1;
      spnStartYear.IntValue := Year;

      LoadBudgets;
    end;

    if DlgBudgetDetail.ShowModal=mrOK then
      result := DlgBudgetDetail.CreateNewBudget(aBudget);

  finally
    DlgBudgetDetail.Free;
  end;
end;

function TdlgBudgetDetail.CreateNewBudget(var aBudget : TBudget): Boolean;
var
  DateFrom: Integer;
  CopyFrom : TBudget;
begin
 {create a new budget}
 aBudget := TBudget.Create;

 DateFrom := DMYToStDate(1, cmbStartMonth.ItemIndex + 1, spnStartYear.IntValue, EPOCH);

 aBudget.buFields.buStart_Date := StNull2BK( DateFrom );
 aBudget.buFields.buName       := eName.Text;
 //aBudget.IsNew := true;
 {if copy from is not nil then copy values for another budget}
 CopyFrom := nil;

 if cmbBudget.ItemIndex <> -1 then
    CopyFrom := TBudget(cmbBudget.Items.Objects[cmbBudget.itemIndex]);

 if Assigned(CopyFrom) then
     CopyBudgetValues(CopyFrom,aBudget);

 MyClient.clBudget_List.Insert(aBudget);
 result := true;
end;
//------------------------------------------------------------------------------


end.
