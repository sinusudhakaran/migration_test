unit ReversingEntryDetailsFrm;
//------------------------------------------------------------------------------
{
   Title:        Reversing Entry Details

   Description:  Allows the user to edit the date of the reversing entry.

   Remarks:      Checks that the date does not fall inside a finalised period
                 Relies on the MyClient object.

   Author:       Matthew Hopkins Jan 2001

}
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OvcBase, OvcEF, OvcPB, OvcPF, StdCtrls,

  baObj32, bkDefs,
  OSFont;

type
  TfrmReversingEntryDetails = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    lblRef: TLabel;
    lblAmount: TLabel;
    eDate: TOvcPictureField;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lblReversingPrefix: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    OvcController1: TOvcController;
    procedure FormCreate(Sender: TObject);
    procedure eDateError(Sender: TObject; ErrorCode: Word;
      ErrorMsg: String);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    BankAccount : TBank_Account;
    MinDate     : integer;
  public
    { Public declarations }
  end;

  function GetReversingEntryDate(ba : TBank_Account; pUPI : pTransaction_Rec) : integer;

//******************************************************************************
implementation

uses
   OvcDate,
   bkDateUtils,
   bkXPThemes,
   infoMoreFrm,
   quikDate,
   globals,
   bktxio,
   bkconst,
   warningMoreFrm,
   finalise32,
   GenUtils;

{$R *.DFM}
//------------------------------------------------------------------------------

procedure TfrmReversingEntryDetails.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  eDate.Epoch       := BKDATEEPOCH;
  eDate.PictureMask := BKDATEFORMAT;
  lblReversingPrefix.caption := '';

//  SetupHelp;
end;
//------------------------------------------------------------------------------

procedure TfrmReversingEntryDetails.eDateError(Sender: TObject;
  ErrorCode: Word; ErrorMsg: String);
begin
  HelpfulWarningMsg('Invalid Date Entered',0);
  Edate.AsString := '';
end;
//------------------------------------------------------------------------------

function GetReversingEntryDate(ba : TBank_Account; pUPI : pTransaction_Rec) : integer;
var
   NewRef   : string;
   LastTFDate : integer;   //date of last transferred or finalised entry
   d,m,y    : integer;
   B,T      : integer;
   EOM      : integer;
begin
   result := 0;

   with TfrmReversingEntryDetails.Create(Application.MainForm) do begin
      try
         BankAccount := ba;
         MinDate     := pUPI^.txDate_Effective + 1;

         //complete details
         case pUPI^.txUPI_State of
            upUPC : NewRef := upNames[ upReversedUPC] + MakeCodingRef( pUPI^.txReference);
            upUPD : NewRef := upNames[ upReversedUPD] + MakeCodingRef( pUPI^.txReference);
            upUPW : NewRef := upNames[ upReversedUPW] + MakeCodingRef( pUPI^.txReference);            
         end;

         lblRef.caption      := NewRef;
         lblAmount.caption   := MakeAmount( -1 * pUPI^.txAmount);

         //date defaults to the end of the month following the last finalised period
         //or last transferred period ( which ever is later).
         //find date of last finalised entry in client file
         LastTFDate := 0;
         With MyClient.clBank_Account_List do
            For B := 0 to Pred( itemCount ) do
              With Bank_Account_At( B ).baTransaction_List do
                  For T := 0 to Pred( itemCount ) do
                     With Transaction_At( T )^ do begin
                        If ( txLocked) or ( txDate_Transferred > 0) then begin
                           if txDate_Effective > LastTFDate then
                              LastTFDate := txDate_Effective;
                        end;
                     end;
         StDateToDMY( LastTFDate, d, m, y);
         Inc( m);
         if m > 12 then begin
            m := 1;
            Inc( y);
         end;
         EOM := DMYToStDate( DaysInMonth( m, y, BKDateEpoch), m, y, BKDateEpoch);
         eDate.AsStDate := EOM;
         //--------------
         ShowModal;
         //--------------
         if ModalResult = mrOK then begin
            result := eDate.AsStDate;
         end;
      finally
         Free;
      end;
   end;
end;
//------------------------------------------------------------------------------
procedure TfrmReversingEntryDetails.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin

end;
//------------------------------------------------------------------------------

procedure TfrmReversingEntryDetails.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
   d,m,y    : integer;
   BOM,EOM  : integer;
   B        : integer;
   T        : integer;
   SomeFinalised   : Boolean;
begin
   if ModalResult = mrOK then begin
      //validate the date is ok
      if eDate.AsStDate <= 0 then begin
         HelpfulWarningMsg( 'You must select a date for this entry!', 0);
         CanClose := false;
         exit;
      end;
      //make sure date not before effective date
      if ( eDate.AsStDate < MinDate) then begin
         HelpfulWarningMsg( 'The date selected must be later than ' + bkDate2Str( MinDate -1), 0);
         CanClose := false;
         exit;
      end;

      //make sure that date is not in a finalised period.  Do this by
      //checking for any finalised or transferred entries in the same month as
      //the date selected
      StDateToDMY( eDate.AsStDate, d, m, y);
      BOM := DMYToStDate(1,m,y,bkDateEpoch);
      EOM := DMYToStDate( DaysInMonth( m,y, BKDateEpoch), m, y, BKDateEpoch);
      SomeFinalised   := false;

      With MyClient.clBank_Account_List do
         For B := 0 to Pred( itemCount ) do
            With Bank_Account_At( B ).baTransaction_List do
               For T := 0 to Pred( itemCount ) do
                  With Transaction_At( T )^ do
                     If ( txDate_Effective >= BOM ) and ( txDate_Effective <= EOM ) then begin
                        If txLocked then
                           SomeFinalised := true;
//                      if txDate_Transferred > 0 then
//                         SomeTransferred := true;
                     end;

      if SomeFinalised then begin
         HelpfulWarningMsg( 'There are finalised entries in the same month as the date '+
                            'you have selected.  A reversing entry cannot be added to a period '+
                            'which contains finalised entries.'#13#13+
                            'Please select a valid date.', 0);
         CanClose := false;
         exit;
      end;
   end;
end;
//------------------------------------------------------------------------------

end.
