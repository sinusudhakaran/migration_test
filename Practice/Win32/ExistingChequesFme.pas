unit ExistingChequesFme;
//------------------------------------------------------------------------------
{
   Title:         Existing cheques frame

   Description:   Frame for use in Add UPC, Del UPC dialogs

   Remarks:

   Author:        Matthew Hopkins Jan 2001

}
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, baObj32;

type
  TfmeExistingCheques = class(TFrame)
    label1: TLabel;
    pgCheques: TPageControl;
    tbsAll: TTabSheet;
    lbAllCheques: TListBox;
    tblPresented: TTabSheet;
    tbsUnpresented: TTabSheet;
    lblDates: TLabel;
    lbPresented: TListBox;
    lbUnpresented: TListBox;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Fill( aBankAccount : TBank_Account; ceFromDate : integer; ceToDate : integer);
  end;

//******************************************************************************
implementation
uses
   bkDefs,
   bkDateUtils;
{$R *.DFM}
type
   TExistingChequeInfo = record
     ecChequeNo     : integer;
     ecPresented    : boolean;
   end;
   pExistingChequeInfo = ^TExistingChequeInfo;

   function ChequeCompare( pA, pB : Pointer): Integer;
   // Compares Cheque no of A and B
   // Returns -1 if A < B, 0 if A = B, 1 if A > B
   var
      p1, p2 : pExistingChequeInfo;
   begin
      Result := 0; //Default to equal
      p1 := pExistingChequeInfo( pA );
      p2 := pExistingChequeInfo( pB );
      if p1^.ecChequeNo < p2^.ecChequeNo then
         Result := -1;
      if p1^.ecChequeNo > p2^.ecChequeNo then
         Result := 1;
   end;

{ TExistingChequesFme }
//------------------------------------------------------------------------------

procedure TfmeExistingCheques.Fill(aBankAccount: TBank_Account; ceFromDate,
  ceToDate: integer);
var
   ChqList               : TList;
   i                     : integer;
   pT                    : pTransaction_Rec;
   pECInfo               : pExistingChequeInfo;

   FirstChqInRange       : integer;
   LastChqInRange        : integer;

   FirstPresChqInRange   : integer;
   LastPresChqInRange    : integer;

   FirstUnPresChqInRange : integer;
   LastUnPresChqInRange  : integer;
begin
   lblDates.caption := bkDate2Str( ceFromdate) + ' - ' + bkDate2Str( ceToDate);
   lbAllCheques.Clear;
   lbPresented.Clear;
   lbUnpresented.Clear;

   //look thru transactions for ALL cheques, build a SORTED list of all cheque numbers found
   //store if presented or not.

   //cycle thru list, if curr chq is not in sequence with last chq then add new cheque range to
   //list box
   ChqList := TList.Create;
   try
      for i := 0 to Pred( aBankAccount.baTransaction_List.ItemCount) do begin
         pT := aBankAccount.baTransaction_List.Transaction_At( i);
         if ( pT^.txCheque_Number > 0) and ( pT^.txDate_Effective >= ceFromDate) and ( pT^.txDate_Effective <= ceToDate) then begin
            GetMem( pECInfo, SizeOf( TExistingChequeInfo));
            with pECInfo^ do begin
               ecChequeNo := pT^.txCheque_Number;
               ecPresented := pT^.txDate_Presented > 0;
            end;
            ChqList.Add( pECInfo);
         end;
      end;
      //sort
      ChqList.Sort( ChequeCompare);

      //now look for gaps in the cheque range
      FirstChqInRange := 0;
      LastChqInRange  := 0;
      FirstPresChqInRange   := 0;
      LastPresChqInRange    := 0;
      FirstUnPresChqInRange := 0;
      LastUnPresChqInRange  := 0;

      for i := 0 to Pred( ChqList.Count) do begin
         pECInfo := ChqList.Items[ i];

         //All Cheques
         if FirstChqInRange = 0 then begin
            FirstChqInRange := pECInfo^.ecChequeNo;
            LastChqInRange  := pECInfo^.ecChequeNo;
         end
         else begin
            if ( pECInfo^.ecChequeNo - LastChqInRange) > 1 then begin
               //gap in sequence so report range
               if ( FirstChqInRange = LastChqInRange) then
                  lbAllCheques.Items.Add( inttostr( FirstChqInRange))
               else
                  lbAllCheques.Items.Add( inttostr( FirstChqInRange) + ' - ' + inttostr( LastChqInRange));
               //start new range
               FirstChqInRange := pECInfo^.ecChequeNo;
               LastChqInRange  := pECInfo^.ecChequeNo;
            end
            else begin
               //chq is next in sequence so add
               LastChqInRange := pECInfo^.ecChequeNo;
            end;
         end;

         if pECInfo^.ecPresented then begin
            //Presented Cheques
            if FirstPresChqInRange = 0 then begin
               FirstPresChqInRange := pECInfo^.ecChequeNo;
               LastPresChqInRange  := pECInfo^.ecChequeNo;
            end
            else begin
               if ( pECInfo^.ecChequeNo - LastPresChqInRange) > 1 then begin
                  //gap in sequence so report range
                  if ( FirstPresChqInRange = LastPresChqInRange) then
                     lbPresented.Items.Add( inttostr( FirstPresChqInRange))
                  else
                     lbPresented.Items.Add( inttostr( FirstPresChqInRange) + ' - ' + inttostr( LastPresChqInRange));
                  //start new range
                  FirstPresChqInRange := pECInfo^.ecChequeNo;
                  LastPresChqInRange  := pECInfo^.ecChequeNo;
               end
               else begin
                  //chq is next in sequence so add
                  LastPresChqInRange := pECInfo^.ecChequeNo;
               end;
            end;
         end
         else begin
            //Unpresented Cheques
            if FirstUnPresChqInRange = 0 then begin
               FirstUnPresChqInRange := pECInfo^.ecChequeNo;
               LastUnPresChqInRange  := pECInfo^.ecChequeNo;
            end
            else begin
               if ( pECInfo^.ecChequeNo - LastUnPresChqInRange) > 1 then begin
                  //gap in sequence so report range
                  if ( FirstUnPresChqInRange = LastUnPresChqInRange) then
                     lbUnpresented.Items.Add( inttostr( FirstUnPresChqInRange))
                  else
                     lbUnpresented.Items.Add( inttostr( FirstUnPresChqInRange) + ' - ' + inttostr( LastUnPresChqInRange));
                  //start new range
                  FirstUnPresChqInRange := pECInfo^.ecChequeNo;
                  LastUnPresChqInRange  := pECInfo^.ecChequeNo;
               end
               else begin
                  //chq is next in sequence so add
                  LastUnPresChqInRange := pECInfo^.ecChequeNo;
               end;
            end;
         end;
      end;
      //report on last cheques in range
      if FirstChqInRange <> 0 then begin
         if ( FirstChqInRange = LastChqInRange) then
            lbAllCheques.Items.Add( inttostr( FirstChqInRange))
         else
            lbAllCheques.Items.Add( inttostr( FirstChqInRange) + ' - ' + inttostr( LastChqInRange));
      end;

      if FirstPresChqInRange <> 0 then begin
         if ( FirstPresChqInRange = LastPresChqInRange) then
            lbPresented.Items.Add( inttostr( FirstPresChqInRange))
         else
            lbPresented.Items.Add( inttostr( FirstPresChqInRange) + ' - ' + inttostr( LastPresChqInRange));
      end;

      if FirstUnPresChqInRange <> 0 then begin
         if ( FirstUnPresChqInRange = LastUnPresChqInRange) then
            lbUnpresented.Items.Add( inttostr( FirstUnPresChqInRange))
         else
            lbUnpresented.Items.Add( inttostr( FirstUnPresChqInRange) + ' - ' + inttostr( LastUnPresChqInRange));
      end;
      
   finally
      //free list memory
      with ChqList do begin
         for i := 0 to Pred( Count ) do begin
            FreeMem( pExistingChequeInfo(Items[i]), SizeOf( TExistingChequeInfo ) );
         end;
         Free;
      end;
   end;
end;
//------------------------------------------------------------------------------

end.
