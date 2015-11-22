unit DlgSelect;

{-----------------------------------------------------}
interface
{-----------------------------------------------------}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, checklst, ExtCtrls, OvcCkLb, ImgList, ComCtrls, baobj32,
  StDate, bkConst,
  OSFont;

type

  TdlgSelect = class(TForm)
    btnOK        : TButton;
    btnCancel    : TButton;
    lvAccountsEx : TListView;
    Bevel1       : TBevel;
    btnSelectAllAccounts: TButton;
    btnClearAllAccounts: TButton;
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure lvAccountsExDblClick(Sender: TObject);
    procedure lvAccountsExEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure FormShow(Sender: TObject);
    procedure lvAccountsExCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure lvAccountsExColumnClick(Sender: TObject; Column: TListColumn);
    procedure btnSelectAllAccountsClick(Sender: TObject);
    procedure btnClearAllAccountsClick(Sender: TObject);
  private
    { Private declarations }
    SortCol : integer;

    fEntriesColumn : integer;
  public
    { Public declarations }
  end;

  TBankTypes = btMin..btMax;
  TBankSet = set of TBankTypes;

function SelectBankAccountsForExport( const D1, D2 : tStDate; const AccountSet: TBankSet = [btBank, btCashJournals, btAccrualJournals] ) : TStringList;
function SelectBankAccountForExport( const D1, D2 : tStDate ) : TBank_Account;

{-----------------------------------------------------}
implementation
{-----------------------------------------------------}

uses
   bkXPThemes,
   clObj32,
   globals,
   imagesfrm,
   StStrS,
   GenUtils,
   TravUtils,
   bkDefs,
   Software,
   WarningMoreFrm;

{$R *.DFM}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgSelect.FormCreate(Sender: TObject);
begin
  fEntriesColumn           := 3;

  bkXPThemes.ThemeForm( Self);
  lvAccountsEx.items.clear;
  SetUpHelp;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelect.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelect.FormShow(Sender: TObject);
begin
  keybd_event(vk_down,0,0,0);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelect.lvAccountsExCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  Key1,Key2 : ShortString;
  Num1, Num2 : integer;
begin
  if SortCol <> fEntriesColumn then
    if SortCol <> 0 then begin
      Key1 := Item1.SubItems.Strings[SortCol-1];
      Key2 := Item2.SubItems.Strings[SortCol-1];
      Compare := StStrS.CompStringS(Key1,Key2);
    end
    else
  else begin
    Key1 := Item1.SubItems.Strings[SortCol-1];
    Key2 := Item2.SubItems.Strings[SortCol-1];

    Num1 := Str2Long(Key1);
    Num2 := Str2Long(Key2);

    if num1 > num2 then Compare := -1 else
    if num1 < num2 then Compare := 1 else
    Compare := 0;
  end;
(*
  case SortCol of
  0: begin
       Key1 := Item1.Caption;
       Key2 := Item2.Caption;
       Compare := StStrS.CompStringS(Key1,Key2);
     end;
  3 : begin
       Key1 := Item1.SubItems.Strings[SortCol-1];
       Key2 := Item2.SubItems.Strings[SortCol-1];

       Num1 := Str2Long(Key1);
       Num2 := Str2Long(Key2);

       if num1 > num2 then Compare := -1 else
       if num1 < num2 then Compare := 1 else
       Compare := 0;
     end;
  else
     begin
       Key1 := Item1.SubItems.Strings[SortCol-1];
       Key2 := Item2.SubItems.Strings[SortCol-1];
       Compare := StStrS.CompStringS(Key1,Key2);
     end;
  end; *)
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelect.lvAccountsExColumnClick(Sender: TObject;
  Column: TListColumn);
var
  i     : integer;
  Index : Integer;
begin
   Index := -1;
   for i := 0 to Pred( lvAccountsEx.Columns.Count ) do
      if lvAccountsEx.Columns[i] = Column then
         Index := i;

   if Index > 0 then
   begin
      for i := 0 to lvAccountsEx.columns.Count-1 do
         lvAccountsEx.columns[i].ImageIndex := -1;

      column.ImageIndex := MAINTAIN_COLSORT_BMP;

      SortCol := Index;
      lvAccountsEx.AlphaSort;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgSelect.lvAccountsExDblClick(Sender: TObject);
begin
   if Assigned( lvAccountsEx.Selected ) then
   Begin
      case lvAccountsEx.MultiSelect of
         False : ModalResult := mrOK; { Exit and Choose this Bank Account }
         True  : lvAccountsEx.Selected.Checked := True;
      end;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgSelect.lvAccountsExEditing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  AllowEdit := false;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function SelectBankAccountsForExport( const D1, D2 : tStDate; const AccountSet: TBankSet = [btBank, btCashJournals, btAccrualJournals] ) : TStringList;
var
   MyDlg      : TdlgSelect;
   BA         : TBank_Account;
   i          : integer;
   TrxCount   : Integer;
   NumChecked : Integer;
   NewItem    : TListItem;
   AList      : TStringList;
   lbExtractAccountNumberAs : boolean;
   fExtractAccountNoColumn  : TListColumn;
begin
   Result     := NIL;

   if not ( Assigned( MyClient) ) then exit;

   MyDlg := TdlgSelect.Create(Application.MainForm);
   try
      with MyDlg do
      begin
         Caption    := 'Extract Data: Select the account(s) you want to process' ;
         lvAccountsEx.MultiSelect := True;
         lvAccountsEx.CheckBoxes  := True;

         lvAccountsEx.Hint    :=
          'Select an Account by checking the "Select" box next to it|'+
          'Select an Account by checking the "Select" box next to it';

         SortCol    := 1;

         lbExtractAccountNumberAs :=
           Software.CanExtractAccountNumberAs(
             MyClient.clFields.clCountry,
             MyClient.clFields.clAccounting_System_Used);
         if lbExtractAccountNumberAs then begin
           fExtractAccountNoColumn := TListColumn( lvAccountsEx.Columns.Add );;
           for I := lvAccountsEx.Columns.Count - 1 downto 3 do begin
             TListColumn( lvAccountsEx.Columns[ i ] ).Assign( TListColumn( lvAccountsEx.Columns[ pred( i ) ] ) );
           end;
           TListColumn( lvAccountsEx.Columns[ 2 ] ).Caption := 'Extract Account No';
           TListColumn( lvAccountsEx.Columns[ 2 ] ).Width := 180;
           fEntriesColumn           := 4;

           lvAccountsEx.UpdateItems(0, MAXINT);
           MyDlg.Width := MyDlg.Width + TListColumn( lvAccountsEx.Columns[ 2 ] ).Width;
         end;

         with MyClient.clBank_Account_List do
         Begin
            For i := 0 to Pred( ItemCount ) do
            Begin
               BA := Bank_Account_At( i );
               With BA, baFields do
               Begin
                  if ( baAccount_Type in AccountSet ) then
                  Begin
                     TrxCount  := TravUtils.NumberAvailableForExport( BA, D1, D2 );
                     NewItem := lvAccountsEx.Items.Add;
                     NewItem.Caption := ' ';
                     NewItem.ImageIndex := -1;
                     NewItem.SubItems.AddObject( baBank_Account_Number, BA );

                     if lbExtractAccountNumberAs then
                       NewItem.SubItems.Add( baExtract_Account_Number );
                     NewItem.SubItems.Add( baBank_Account_Name );
                     NewItem.SubItems.Add( IntToStr( TrxCount ) );
                     if ( TrxCount > 0 ) then
                        NewItem.Checked := True
                     else
                        NewItem.Checked := False;
                  end;
               end;         
            end;
         end;
      
         if ( MyDlg.ShowModal = mrOK ) then
         begin
            NumChecked := 0;
            For i := 0 to Pred( lvAccountsEx.items.Count ) do 
            Begin
               With lvAccountsEx.Items[i] do
               Begin
                 if Checked then begin
                   if lvAccountsEx.Items[ i ].SubItems.Objects[ 0 ] is TBank_Account then
                     if ( ( lvAccountsEx.Items[ i ].SubItems.Objects[ 0 ] as TBank_Account ).baFields.baAccount_Type in
                            [ btCashJournals, btAccrualJournals ] ) and
                          ( trim( (
                              lvAccountsEx.Items[ i ].SubItems.Objects[ 0 ] as TBank_Account ).baFields.baExtract_Account_Number ) = '' ) and
                           Software.CanExtractAccountNumberAs(
                             MyClient.clFields.clCountry,
                             MyClient.clFields.clAccounting_System_Used) then begin
                         HelpfulWarningMsg( 'Before you can extract these entries, ' +
                           'you must specify an Extract Account Number for ' +
                           'journals. To do this, go to Other Functions | Bank ' +
                           'Accounts and edit the journal. ', 0 );
                         result := SelectBankAccountsForExport( D1, D2, AccountSet );
                         Exit;
                       end;
                   Inc( NumChecked );
                 end;
               end;
            end;
            if NumChecked = 0 then Exit;

            AList := TStringList.Create;
            For i := 0 to Pred( lvAccountsEx.items.Count ) do 
            Begin
               With lvAccountsEx.Items[i] do
               Begin
                 if Checked then AList.AddObject( SubItems[0], SubItems.Objects[0] );
               end;
            end;
            Result := AList;
         end;
      end; {with}
   finally
      MyDlg.Free;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function SelectBankAccountForExport( const D1, D2 : tStDate ) : TBank_Account;
var
   MyDlg      : TdlgSelect;
   BA         : TBank_Account;
   i          : integer;
   TrxCount   : Integer;   
   NewItem    : TListItem;
begin
   Result := NIL;
   
   if not ( Assigned( MyClient) ) then exit;

   MyDlg := TdlgSelect.Create(Application.Mainform);
   try
      with MyDlg do
      begin
         Caption    := 'Extract Data: Select the account you want to process' ;

         lvAccountsEx.MultiSelect := False;
         lvAccountsEx.CheckBoxes  := False;
         //Hide Select column - only one account allowed
         lvAccountsEx.Columns[0].Caption := '';
         lvAccountsEx.Columns[0].MinWidth := 0;
         lvAccountsEx.Columns[0].Width := 0;

         lvAccountsEx.Hint :=
                           'Select an Account|'+
                           'Select an Account';

         btnSelectAllAccounts.Visible := False;
         btnClearAllAccounts.Visible := False;
         SortCol    := 1;

         with MyClient.clBank_Account_List do
         Begin
            For i := 0 to Pred( ItemCount ) do
            Begin
               BA := Bank_Account_At( i );
               With BA, baFields do
               Begin
                  if ( baAccount_Type in [btBank, btCashJournals, btAccrualJournals] ) then
                  Begin
                     TrxCount  := TravUtils.NumberAvailableForExport( BA, D1, D2 );
                     NewItem := lvAccountsEx.Items.Add;
                     NewItem.Caption := ' ';
                     NewItem.ImageIndex := -1;
                     NewItem.SubItems.AddObject( baBank_Account_Number, BA );
                     NewItem.SubItems.Add( baBank_Account_Name );
                     NewItem.SubItems.Add( IntToStr( TrxCount ) );
                  end;
               end;
            end;
         end;

         if ( MyDlg.ShowModal = mrOK ) then
         begin
            if ( lvAccountsEx.Selected <> nil ) then
               Result := TBank_Account( lvAccountsEx.Selected.SubItems.Objects[0] );
         end;
      end; {with}
   finally
      MyDlg.Free;
   end;
end;

{-----------------------------------------------------}

procedure TdlgSelect.btnSelectAllAccountsClick(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to (lvAccountsEx.Items.Count - 1) do
    lvAccountsEx.Items[i].checked := True;
end;

procedure TdlgSelect.btnClearAllAccountsClick(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to (lvAccountsEx.Items.Count - 1) do
    lvAccountsEx.Items[i].checked := False;
end;

end.
