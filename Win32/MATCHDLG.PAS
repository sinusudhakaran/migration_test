unit MatchDlg;
//------------------------------------------------------------------------------
{
   Title:       Match Dialog

   Description:

   Remarks:     Execute called by CodingFrm.pas.  The actual updating of the
                transactions is done in Codingfrm.pas.

   Author:

}
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OvcTCNum, OvcTCEdt, OvcTCSim, OvcTCBEF, OvcTCPic, OvcTCmmn, OvcTCell,
  OvcTCStr, OvcTCHdr, OvcBase, OvcTable, StdCtrls, ExtCtrls, bkDefs, UEList32,
  ComCtrls, baObj32, OsFont;

type
  TdlgMatch = class(TForm)
    pnlButtons: TPanel;
    btnMatch: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Shape1: TShape;
    lblDate: TLabel;
    lblRef: TLabel;
    lblCode: TLabel;
    lblAmount: TLabel;
    lblEntryType: TLabel;
    lvUEItems: TListView;
    pnlWarnings: TPanel;
    pnlInfo: TPanel;
    Label3: TLabel;
    Label5: TLabel;
    lblNewAmount: TLabel;
    InfoBmp: TImage;
    lblNewDate: TLabel;
    lblNewRef: TLabel;
    lblWarning: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnMatchClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure lvUEItemsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    { Private declarations }
    MatchPressed : boolean;
    PresentedTrx : pTransaction_Rec;
    fBank_Account : TBank_Account;
  public
    { Public declarations }
    MatchedEntry : pUE;
    function Execute(P : PTransaction_Rec; UEList : tUEList ): boolean;
  end;


function MatchUnpEntry( P : PTransaction_Rec; UEList : tUEList ): pUE;

//******************************************************************************
implementation

uses
  bkConst,
  bkDateUtils,
  BKHelp,
  bkutil32,
  bkXPThemes,
  Globals,
  GenUtils,
  ForexHelpers,
  lvUtils,
  YesNoDlg;

{$R *.DFM}

//------------------------------------------------------------------------------

procedure TdlgMatch.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  MatchedEntry        := nil;
  MatchPressed        := false;

  lblNewDate.caption  := '';
  lblNewRef.caption   := '';
  lblNewAmount.caption := '';
  lblWarning.Font.Color  := clRed;

  pnlWarnings.Color := clBtnFace;
  SetUpHelp;
end;
//------------------------------------------------------------------------------

procedure TdlgMatch.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := BKH_Chapter_6_Unpresented_items;
   //Components
   btnMatch.Hint    :=
                    'Match the Unpresented Item with the selected transaction|' +
                    'Match the Unpresented Item with the selected transaction in the Code Entries Screen';
end;

//------------------------------------------------------------------------------
function TdlgMatch.Execute(P : PTransaction_Rec; UEList : tUEList ): boolean;
var
   UE : pUE;
   Refce : integer;
   ClosestMatch : pUE;
   i            : integer;
   NewItem      : TListItem;
   ClosestItem  : TListItem;
begin
   result  := false;
   if not Assigned(UEList) or (UEList.ItemCount =0) then exit;

   ClosestMatch := nil;
   ClosestItem  := nil;

   //store for later use
   PresentedTrx := p;
   fBank_Account := p.Bank_Account;


   //get the cheque number of the current transaction
   Refce := p^.txCheque_Number;
   if (Refce > 0) then
      ClosestMatch:= UEList.FindUEByNumber(Refce);
   if not Assigned(ClosestMatch) then
      ClosestMatch := UEList.FindUEByAmount( p.Statement_Amount );

   //load the list view with items that could match
   for i := 0 to Pred( UEList.ItemCount) do begin
      UE := UEList.UEItem_At( i);

      //only add items that have the same sign, exclude items with zero amount
      //can only match items that have a presentation date greater than the
      //effective date of the UPI
      if ( ( UE^.Amount > 0) and ( p.Statement_Amount > 0) or
           ( UE^.Amount < 0) and ( p.Statement_Amount < 0))
         and ( UE^.Issued < p^.txDate_Presented) then begin
         NewItem := lvUEItems.Items.Add;
         NewItem.Caption := bkDate2Str( UE^.Issued);
         NewItem.SubItems.AddObject( GetFormattedReference( UE^.Ptr), TObject( UE));
         NewItem.SubItems.Add( '');
         NewItem.SubItems.Add( MakeAmount( UE^.Amount));
         NewItem.SubItems.Add( IntToStr( UE^.Ptr^.txType)+ ':' + MyClient.clFields.clShort_Name[ UE^.Ptr^.txType]);

         if UE = ClosestMatch then
            ClosestItem := NewItem;
      end;
   end;
   //load details of original transaction
   lblDate.caption      := bkDate2Str( p^.txDate_Effective);
   lblRef.Caption       := GetFormattedReference( p);
   lblCode.caption      := p^.txAccount;
   lblAmount.caption    := fBank_Account.MoneyStr( p.Statement_Amount );
   lblEntryType.caption := IntToStr( p^.txType)+ ':' + MyClient.clFields.clShort_Name[ p^.txType];
   //find closest match
   if Assigned( ClosestItem) then begin
      LVUTILS.SelectListViewItem( lvUEItems, ClosestItem);
      lvUEItemsSelectItem( nil, ClosestItem, true);
   end;
   //---------------------------
   ShowModal;
   //---------------------------
   If MatchPressed and Assigned( lvUEItems.Selected) then begin
      MatchedEntry := pUE( lvUEItems.Selected.SubItems.Objects[0]);
      result := true;
   end;
end;
//------------------------------------------------------------------------------

procedure TdlgMatch.btnMatchClick(Sender: TObject);
var
  SelectedUPI : pUE;
  SelectedTrx : pTransaction_Rec;

begin
  if not Assigned( lvUEItems.Selected) then exit;

  SelectedUPI := pUE( lvUEItems.Selected.SubItems.Objects[0]);
  SelectedTrx := SelectedUPI.Ptr;

  if SelectedTrx.Statement_Amount = PresentedTrx.Statement_Amount then
  begin
    if AskYesNo( 'Confirm Match', 'Mark the unpresented item as presented and ' +
                 'delete the current presented item?', DLG_NO, 0 ) = DLG_NO then begin
       exit;
    end;
  end
  else
  begin
    If AskYesNo( 'Confirm Match', 'Mark the unpresented item ('+
       fBank_Account.MoneyStr( SelectedTrx.Statement_Amount ) +
       ') as presented on ' + bkDate2Str( PresentedTrx^.txDate_Effective) + '.'+
       #13#13 +
       'Adjust the amount of the current presented item '#13'from '+
       fBank_Account.MoneyStr( PresentedTrx.Statement_Amount ) +
       ' to ' +
       fBank_Account.MoneyStr( PresentedTrx.Statement_Amount - SelectedUPI.Amount ) +
       '?', DLG_NO,0 )= DLG_NO then
         exit;
  end;
  MatchPressed := true;
  Close;
end;

//------------------------------------------------------------------------------

procedure TdlgMatch.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TdlgMatch.lvUEItemsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
   WarningMsg : string;
   UPI : pUE;
begin
    if not Assigned( Item) then exit;

    pnlInfo.Visible := false;
    pnlWarnings.Color := clBtnFace;
    lblWarning.Visible := false;

    WarningMsg := 'WARNING:  ';

    //test selected item to see if amount or ref different
    UPI := pUE( Item.SubItems.Objects[0]);

    if UPI^.Number <> PresentedTrx^.txCheque_Number then begin
       WarningMsg := WarningMsg + 'Cheque numbers do not match.  ';
       lblWarning.visible := true;
    end;

    if UPI^.ptr^.txType <> PresentedTrx^.txType then begin
       WarningMsg := WarningMsg + 'Entry Types do not match.  ';
       lblWarning.visible := true;
    end;

    lblWarning.caption := WarningMsg;

    if UPI^.Amount <> PresentedTrx^.Statement_Amount then
    begin
       lblNewDate.caption   := lblDate.caption;
       case UPI^.Ptr^.txUPI_State of
          upUPC : lblNewRef.caption := upNames[ upBalanceOfUPC] + MakeCodingRef( PresentedTrx^.txReference);
          upUPD : lblNewRef.caption := upNames[ upBalanceOfUPD] + MakeCodingRef( PresentedTrx^.txReference);
          upUPW : lblNewRef.caption := upNames[ upBalanceOfUPW] + MakeCodingRef( PresentedTrx^.txReference);
       end;
       lblNewAmount.caption := fBank_Account.MoneyStr( PresentedTrx^.Statement_Amount - UPI^.Amount );
       pnlInfo.Visible := true;
    end;

    if pnlInfo.Visible or lblWarning.Visible then
       pnlWarnings.Color := clWindow
    else
       pnlWarnings.Color := clBtnFace;
end;
//------------------------------------------------------------------------------

function MatchUnpEntry( P : PTransaction_Rec; UEList : tUEList ): pUE;
var
  MyDlg : TdlgMatch;
begin
   result := nil;
   MyDlg := TdlgMatch.Create(Application.MainForm);
   try
      if MyDlg.Execute(p,UEList) then
      begin
        result := MyDlg.MatchedEntry;
      end
   finally
      MyDlg.Free;
   end;
end;

//------------------------------------------------------------------------------

end.
