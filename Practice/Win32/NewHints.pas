unit NewHints;
//------------------------------------------------------------------------------
{
   Title:       New Hints Unit

   Description: Allows custom hint window to be shown in the code entries screen

   Author:      Steve Agnew

   Remarks:

}
//------------------------------------------------------------------------------
interface
uses
  Classes, BkDefs, BkConst, Controls, Forms, Windows, WorkRecDefs, baObj32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function GetCodeEntriesHint( Const Bank_Account : TBank_Account; const T : pTransaction_Rec; Const OptionalHintsOn : Boolean) : string ;
function GetDissectionHint( const pWD : pWorkDissect_Rec; Const OptionalHintsOn : Boolean) : string; overload;
function GetDissectionHint( const pWJ : pWorkJournal_Rec; Const OptionalHintsOn : Boolean) : string; overload;
function GetPayeeHint( const aPayeeNo : integer; const OptionalHintsOn : boolean) : string; overload;
function GetPayeeHint( const pT : pTransaction_Rec; const OptionalHintsOn : boolean): string; overload;

function GetJobHint(const JobCode: string; const OptionalHintsOn : boolean) : string; overload;
function GetJobHint(const pT : pTransaction_Rec; const OptionalHintsOn : boolean): string; overload;

function GetSuperHint( const pWD : pWorkDissect_Rec; Const OptionalHintsOn : Boolean) : string; overload;
function GetSuperHint( const pWJ : pWorkJournal_Rec; Const OptionalHintsOn : Boolean) : string; overload;

procedure HideCustomHint( var Hint: THintWindow );
procedure ShowCustomHint( var Hint : THintWindow; Const Position : TPoint; Const HintMsg : String ); Overload;
procedure ShowCustomHint( var Hint : THintWindow; const CellRect : TRect ; const HintMsg : string ) ; Overload;

//******************************************************************************
implementation
uses
  SuperFieldsUtils,
  Software,
  Globals,
  CHList32,
  StStrS,
  SysUtils,
  Graphics,
  PayeeObj,
  bkDateUtils,
  genutils,
  moneydef,
  gstcalc32,
  SageHandisoftSuperConst,
  ForexHelpers;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CONST
   MaxLinesToShow = 23;

procedure HideCustomHint( var Hint: THintWindow );
begin
   if Assigned( Hint ) and Hint.HandleAllocated then Hint.ReleaseHandle;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ShowCustomHint( var Hint : THintWindow; Const Position : TPoint; Const HintMsg : String );
//simple version of showCustomHint.  Positions the hint window at the
//specified point
Var
   R : TRect;
begin
   R := Hint.CalcHintRect( Screen.Width, HintMsg, NIL );
   OffsetRect( R, Position.X, Position.Y );
   Inc( R.Bottom, 2 );
   Inc( R.Right, 6 );
   if HintMsg = 'INVALID CODE!' then
      Hint.Color := clRed
   else
      Hint.Color := Application.HintColor;
   Hint.ActivateHint( R, HintMsg );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ShowCustomHint( var Hint : THintWindow ; const CellRect : TRect ; const HintMsg : string ) ; Overload;
//advanced version of showcustomhint.  positions the window so that window
//does not disappear off screen.
var
  ShowBelow : Boolean;
  ShowRight : Boolean;
  Where     : ( AboveLeft, AboveRight, BelowLeft, BelowRight );
  R         : TRect ;
  OffsetPosition : TPoint;
begin
  R := Hint.CalcHintRect( Screen.Width, HintMsg, nil ) ;
  Inc( R.Bottom, 2 ) ;
  Inc( R.Right, 6 ) ;
  ShowBelow := ( CellRect.Bottom + R.Bottom ) <= Screen.DesktopHeight;
  ShowRight := ( CellRect.Right + R.Right ) <= Screen.DesktopWidth;
  if ShowBelow then
  begin
    if ShowRight then
      Where := BelowRight
    else
      Where := BelowLeft
  end
  else
  begin
    if ShowRight then
      Where := AboveRight
    else
      Where := AboveLeft
  end;

  Case Where of
    AboveLeft  :
      begin
        OffsetPosition.X := CellRect.Left - R.Right;
        OffsetPosition.Y := CellRect.Top - R.Bottom - 4;
      end;
    AboveRight :
      begin
        OffsetPosition.X := CellRect.Right;
        OffsetPosition.Y := CellRect.Top - R.Bottom - 4;
      end;
    BelowLeft  :
      begin
        OffsetPosition.X := CellRect.Left - R.Right;
        OffsetPosition.Y := CellRect.Bottom;
      end;
    BelowRight :
      begin
        OffsetPosition.X := CellRect.Right;
        OffsetPosition.Y := CellRect.Bottom;
      end;
  end;
  OffsetRect( R, OffsetPosition.X, OffsetPosition.Y );
  if HintMsg = 'INVALID CODE!' then
  begin
    Hint.Color := clRed;
  end
  else
  begin
    Hint.Color := Application.HintColor ;
  end;
  try
    Hint.ActivateHint( R, HintMsg ) ;
  except
  end;
end ;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddIfNotZero( aMsg : string; aAmount : Money; aHint : TStringList);
var
  VS : string;  //value string
begin
  VS := Trim( Format( '%15.2n', [ Abs( aAmount ) / 100 ] ) ) ;
  if aAmount < 0 then
    VS := '(' + VS + ')';

  VS := LeftPadS( VS, 6) ;
  if aAmount <> 0 then
    aHint.Add( PadS( aMsg, 31) + VS);
end;

procedure AddIfNotBlank( aMsg : string; aValue : string; aHint : TStringList);
var
  VS : string;  //value string
begin
  VS := Trim( aValue ) ;
  VS := LeftPadS( VS, 6) ;
  if Trim(aValue) <> '' then
    aHint.Add( PadS( aMsg, 31) + VS);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetCodeEntriesHint( Const Bank_Account : TBank_Account; const T : pTransaction_Rec; Const OptionalHintsOn : Boolean) : string ;
//returns a hint message for use in the coding screen
//for release 5.2 all hint messages are optional
//
//  T = pointer to transaction to generate hint for
//
//  OptionalHintsOn = show the following for a normal transaction
//                         description, upi status, gst amount,
//                         source of transaction, coded by, notes
//
//                    show the following for a dissection
//                         code, description, amount, notes
var
  D             : pDissection_Rec ;
  A             : pAccount_Rec ;
  No            : Integer ;
  MaxCLen       : Integer ;
  MaxDLen       : Integer ;
  MaxVLen       : Integer ;
  MaxFCLen      : Integer ;
  MaxCRLen      : Integer;
  CS            : Bk5CodeStr ;
//  GstID         : string;
  DS            : string[ 80 ] ;
  VS            : string[ 15 ] ;
  FCS           : string[ 15 ] ;
  RS            : String[ 15 ] ;
  PS            : string;
  H             : string ;
  Commas        : Boolean ;
  HintSL        : TStringList;
  SL            : TStringList;
  Forex         : Boolean;
begin
  Result    := '' ;
  if not Assigned( T ) then
    exit ;

  if not OptionalHintsOn then
    exit;

  Forex := Bank_Account.IsAForexAccount;

  HintSL := TStringList.Create;
  Try
    //show coding information
    With T^ do if ( txFirst_Dissection = nil ) then
    begin
      if ( txAccount <> '' ) then
      begin
        A := MyClient.clChart.FindCode( txAccount ) ;
        if not Assigned( A ) then
        begin
          HintSL.Add( 'INVALID CODE!' );
        end
        else
        begin
          //show chart code description
          DS := A^.chAccount_Description ;
          HintSL.Add( DS );

          {
          //show gst amount
          if txGST_Class > 0 then
          begin
            GSTID := GSTCalc32.GetGstClassCode( MyClient, txGST_Class);
            HintSL.Add( Format( 'GST Amount $%0.2f [%s]', [ Abs( txGST_Amount ) / 100.0, GSTID ] ) );
          end;

          //show coded by method
          DS := '' ;
          case txCoded_By of
            cbMemorisedC         : DS := 'Memorised' ;
            cbMemorisedM         : DS := 'Memorised (Master)' ;
            cbAnalysis           : DS := 'Analysis Code' ;
            cbManualPayee        : DS := 'Payee Code' ; //not currently used
            cbAutoPayee          : DS := 'Payee Code' ; //not currently used
            cbECodingManual      : DS := 'BNotes' ;
            cbECodingManualPayee : DS := 'BNotes (Payee)' ;
          end ;
          if DS<>'' then HintSL.Add( DS );
          }
        end;
      end ;

      {
      //show source of entry
      DS := '' ;
      case txSource of
        orHistorical   : DS := 'Historical Entry' ;
        orGenerated    : DS := 'Generated' ;
        orGeneratedRev : DS := 'Reversed' ;
      end ;
      if DS<>'' then HintSL.Add( DS );

      //show upi state information
      DS := '' ;
      case txUPI_State of
        upMatchedUPC,
        upMatchedUPD,
        upBalanceOfUPC,
        upBalanceOfUPD :
        begin
          DS := ' Original Entry   ' + bkDate2Str( txDate_Presented ) +
                '     ' + MakeCodingRef( txOriginal_Reference ) +
                '     $' + MakeAmount( txOriginal_Amount ) ;

          case txOriginal_Source of
            orHistorical   : DS := DS + ' Historical' ;
            orGenerated    : DS := DS + ' Generated' ;
            orGeneratedRev : DS := DS + ' Reversed' ;
          end ;
        end ;

        upReversedUPC,
        upReversedUPD : DS := 'Cancelled on ' + bkDate2str( txDate_Presented ) ;
      end ;
      if DS<>'' then
        HintSL.Add( DS );

      if txUPC_Status in [ ucMatchingRef, ucMatchingAmount ] then
        HintSL.Add( ucNames[ txUPC_Status ] );

      //show finalised state
      if txLocked then HintSL.Add( '[FINALISED]' );
      }
    end
    else
    begin
      //show details for a dissected entry
      MaxCLen := 0 ;
      MaxDLen := 0 ;
      MaxVLen := 8 ;
      MaxFCLen := 0;
      MaxCRLen := 0;

      Commas := False ;
      D := txFirst_Dissection ;
      while D <> nil do with D^ do
      begin
        A := MyClient.clChart.FindCode( dsAccount ) ;
        if Assigned( A ) then DS := A^.chAccount_Description else DS := '<Unknown Code>' ;
        if Length( dsAccount ) > MaxCLen then MaxCLen := Length( dsAccount ) ;
        if Length( DS ) > MaxDLen then MaxDLen := Length( DS ) ;

        if Forex then
        Begin
//          FCS := Bank_Account.MoneyStrBrackets( dsForeign_Currency_Amount );
          FCS := Bank_Account.MoneyStrBrackets( dsAmount );
//          if dsForeign_Currency_Amount >= 0 then
          if dsAmount >= 0 then
            FCS := FCS + ' ';
          if Length( FCS ) > MaxFCLen then MaxFCLen := Length( FCS ) ;

          RS := Format( '%0.5f', [ dsForex_Conversion_Rate ] );
          if Length( RS ) > MaxCRLen then MaxCRLen := Length( RS ) ;

//          VS := MyClient.MoneyStrBrackets( Abs( dsAmount ) ) ;
          VS := MyClient.MoneyStrBrackets( Abs( dsForeign_Currency_Amount ) ) ;
//          if dsAmount >= 0 then VS := VS + ' ';
          if dsForeign_Currency_Amount >= 0 then VS := VS + ' ';
          if Length( VS ) > MaxVLen then MaxVLen := Length( VS ) ;
        End
        Else
        Begin
          VS := TrimSpacesS( Format( '%15.2n', [ Abs( dsAmount ) / 100 ] ) ) ;
          if dsAmount < 0 then
          begin
            VS := '(' + VS + ')' ;
            Commas := True ;
          end ;
          if Length( VS ) > MaxVLen then MaxVLen := Length( VS ) ;
        end;
        D := dsNext ;
      end ;

      D := txFirst_Dissection ;
      While D <> nil do with D^ do
      begin
        CS := PadS( dsAccount, MaxCLen ) ;
        A := MyClient.clChart.FindCode( dsAccount ) ;
        if Assigned( A ) then DS := A^.chAccount_Description else DS := '<Unknown Code>' ;
        DS := PadS( DS, MaxDLen ) ;

        if Forex then
        Begin
//          FCS := Bank_Account.MoneyStrBrackets( dsForeign_Currency_Amount );
          FCS := Bank_Account.MoneyStrBrackets( dsAmount );
//          if dsForeign_Currency_Amount >= 0 then
          if dsAmount >= 0 then
            FCS := FCS + ' ';
          FCS := LeftPadS( FCS, MaxFCLen );

//          RS := Format( '%0.5f', [ dsForex_Conversion_Rate ] );
          RS := Format( '%0.5f', [ T^.Default_Forex_Rate ] );
          RS:= LeftPadS( RS, MaxCRLen );

//          VS := MyClient.MoneyStrBrackets( dsAmount ) ;
          VS := MyClient.MoneyStrBrackets( dsForeign_Currency_Amount ) ;
          VS := LeftPadS( VS, MaxVLen );
        End
        else
        Begin
          VS := TrimSpacesS( Format( '%15.2n', [ Abs( dsAmount ) / 100 ] ) ) ;
          if dsAmount < 0 then
            VS := '(' + VS + ')'
          else
            if Commas then VS := VS + ' ' ;
          VS := LeftPadS( VS, MaxVLen ) ;
        End;

        if dsAmount_Type_Is_Percent then
        begin
          PS := '[' +  FormatFloat( '###.####', Abs( dsPercent_Amount ) / 10000  ) + '%]';
        end
        else
          PS := '';

        if Forex then
          HintSL.Add( CS + ' ' + DS + ' ' + FCS + ' @ ' + RS + ' = ' + VS + ' ' + PS )
        Else
          HintSL.Add( CS + ' ' + DS + ' ' + VS + ' ' + PS );
        D := D.dsNext ;
      end;
    end;

    //show notes for the transaction
    if ( Length( T^.txNotes) > 0) or ( Length( T^.txECoding_Import_Notes) > 0) then
    begin
//      if (HintSL.Count > 0) then
//        HintSL.Add('');
//      HintSl.Add('Notes:');
    end;

    //show import notes
    if Length( T^.txECoding_Import_Notes ) > 0 then
    begin
      SL := TStringList.Create;
      Try
        H  := WrapText( T^.txECoding_Import_Notes, 40 );
        SL.Text := H;
        for No := 0 to Pred( SL.Count ) do
          HintSL.Add( SL.Strings[ No ] );
      Finally
        SL.Free;
      end;
    end;

    //show user notes
    if Length( T^.txNotes ) > 0 then
    begin
      if (Length( T^.txECoding_Import_Notes ) > 0) then
      begin
      //  HintSL.Add('');
      end;
      SL := TStringList.Create;
      Try
        H  := WrapText( T^.txNotes, 40 );
        SL.Text := H;
        For No := 0 to Pred( SL.Count ) do HintSL.Add( SL.Strings[ No ] );
      Finally
        SL.Free;
      end;
    end;

    //show super fields
    if T^.txSF_Super_Fields_Edited
    and Software.CanUseSuperFundFields( MyClient.clFields.clCountry,
                                        MyClient.clFields.clAccounting_System_Used) then
      begin
        if (HintSL.Count > 0) then
          HintSL.Add('');

        case MyClient.clFields.clAccounting_System_Used of
        saSupervisor,
        saSuperMate,
        saSolution6SuperFund :
        begin
          AddIfNotBlank( sffNamesSupervis[ sff_Member_ID],                T^.txSF_Member_ID, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Franked],                   T^.txSF_Franked, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Unfranked],                 T^.txSF_Unfranked, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Interest],                  T^.txSF_Interest, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Foreign_Income] ,           T^.txSF_Foreign_Income, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Capital_Gains_Other],       T^.txSF_Capital_Gains_Other, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_CG_Foreign_Disc],           T^.txSF_Capital_Gains_Foreign_Disc, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Rent],                      T^.txSF_Rent, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Capital_Gains] ,            T^.txSF_Capital_Gains_Indexed, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Discounted_Capital_Gains],  T^.txSF_Capital_Gains_Disc, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Other_Expenses],            T^.txSF_Other_Expenses, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Tax_Deferred_Dist] ,        T^.txSF_Tax_Deferred_Dist, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Tax_Free_Dist] ,            T^.txSF_Tax_Free_Dist, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Tax_Exempt_Dist] ,          T^.txSF_Tax_Exempt_Dist, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Special_Income],            T^.txSF_Special_Income, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Imputed_Credit],            T^.txSF_Imputed_Credit, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Foreign_Tax_Credits] ,      T^.txSF_Foreign_Tax_Credits, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Foreign_CG_Credits] ,       T^.txSF_Foreign_Capital_Gains_Credit, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_TFN_Credits] ,              T^.txSF_TFN_Credits, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Other_Tax_Credit],          T^.txSF_Other_Tax_Credit, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Non_Resident_Tax],          T^.txSF_Non_Resident_Tax, HintSL);
        end;

        saDesktopSuper,
        saClassSuperIP
         :  begin
          if MyClient.clFields.clAccounting_System_Used = saDesktopSuper then
             AddIfNotBlank(sffNamesDesktop[ sff_Transaction_Type], T^.txSF_Transaction_Code, HintSL);
          AddIfNotBlank(sffNamesDesktop[ sff_Member_Component], T^.txSF_Fund_Code, HintSL);
          AddIfNotBlank(sffNamesDesktop[ sff_Member_ID], T^.txSF_Member_Account_Code, HintSL);
          if T^.txSF_CGT_Date <> 0 then
            HintSL.Add( PadS( sffNamesDesktop[sff_CGT_Date], 31) + bkDate2Str( T^.txsf_CGT_Date));
          AddIfNotZero( sffNamesDesktop[ sff_Special_Income],            T^.txSF_Special_Income, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Franked],                   T^.txSF_Franked, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Unfranked],                 T^.txSF_Unfranked, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Foreign_Income] ,           T^.txSF_Foreign_Income, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Other_Expenses],            T^.txSF_Other_Expenses, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Capital_Gains_Other],       T^.txSF_Capital_Gains_Other, HintSL);
          if T^.txSF_Capital_Gains_Fraction_Half then
            HintSL.Add( PadS( sffNamesDesktop[sff_Discounted_Capital_Gains], 31) + '1/2')
          else
            HintSL.Add( PadS( sffNamesDesktop[sff_Discounted_Capital_Gains], 31) + '2/3');
          AddIfNotZero( sffNamesDesktop[ sff_Discounted_Capital_Gains],  T^.txSF_Capital_Gains_Disc, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Capital_Gains] ,            T^.txSF_Capital_Gains_Indexed, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Tax_Deferred_Dist] ,        T^.txSF_Tax_Deferred_Dist, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Tax_Free_Dist] ,            T^.txSF_Tax_Free_Dist, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Tax_Exempt_Dist] ,          T^.txSF_Tax_Exempt_Dist, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Imputed_Credit],            T^.txSF_Imputed_Credit, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_TFN_Credits] ,              T^.txSF_TFN_Credits, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Foreign_Tax_Credits] ,      T^.txSF_Foreign_Tax_Credits, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Foreign_CG_Credits] ,       T^.txSF_Foreign_Capital_Gains_Credit, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Other_Tax_Credit],          T^.txSF_Other_Tax_Credit, HintSL);
        end;

        saSageHandisoftSuperfund:
        begin
          //Type
          if T^.txSF_Transaction_ID >= 0 then
            HintSL.Add('Type: ' + TypesArray[TTxnTypes(T^.txSF_Transaction_ID)]);
          //Transaction
          if T^.txSF_Transaction_Code <> '' then
            HintSL.Add('Transaction: ' + T^.txSF_Transaction_Code);
          //Number Issued
          if T^.txQuantity > 0 then
            AddIfNotBlank( 'Number Issued', FormatFloat('#,##0', (T^.txQuantity / 10000)), HintSL);
          AddIfNotZero( sffNamesHandisoftSuperfund[ sff_Unfranked],       T^.txSF_Unfranked, HintSL);
          AddIfNotZero( sffNamesHandisoftSuperfund[ sff_Franked],         T^.txSF_Franked, HintSL);
          AddIfNotZero( sffNamesHandisoftSuperfund[ sff_Imputed_Credit],  T^.txSF_Imputed_Credit, HintSL);
        end;

        else
        begin
          if T^.txSF_CGT_Date <> 0 then
            HintSL.Add( PadS( sffNames[sff_CGT_Date], 31) + bkDate2Str( T^.txsf_CGT_Date));
          AddIfNotZero( sffNames[ sff_Imputed_Credit],            T^.txSF_Imputed_Credit, HintSL);
          AddIfNotZero( sffNames[ sff_Tax_Free_Dist] ,            T^.txSF_Tax_Free_Dist, HintSL);
          AddIfNotZero( sffNames[ sff_Tax_Exempt_Dist] ,          T^.txSF_Tax_Exempt_Dist, HintSL);
          AddIfNotZero( sffNames[ sff_Tax_Deferred_Dist] ,        T^.txSF_Tax_Deferred_Dist, HintSL);
          AddIfNotZero( sffNames[ sff_Franked],                   T^.txSF_Franked, HintSL);
          AddIfNotZero( sffNames[ sff_Unfranked],                 T^.txSF_Unfranked, HintSL);
          AddIfNotZero( sffNames[ sff_TFN_Credits] ,              T^.txSF_TFN_Credits, HintSL);
          AddIfNotZero( sffNames[ sff_Foreign_Income] ,           T^.txSF_Foreign_Income, HintSL);
          AddIfNotZero( sffNames[ sff_Foreign_Tax_Credits] ,      T^.txSF_Foreign_Tax_Credits, HintSL);
          AddIfNotZero( sffNames[ sff_Other_Expenses],            T^.txSF_Other_Expenses, HintSL);
          AddIfNotZero( sffNames[ sff_Capital_Gains] ,            T^.txSF_Capital_Gains_Indexed, HintSL);
          AddIfNotZero( sffNames[ sff_Discounted_Capital_Gains],  T^.txSF_Capital_Gains_Disc, HintSL);
          AddIfNotZero( sffNames[ sff_Capital_Gains_Other],       T^.txSF_Capital_Gains_Other, HintSL);
          AddIfNotBlank (sffNames[ sff_Member_Component],         GetSFMemberText(T.txDate_Effective, T^.txSF_Member_Component, false), HintSL);
        end;
        end;
      end;

    //see if hint is too long
    if HintSL.Count > MaxLinesToShow then
    begin
      For No := Pred( HintSL.Count ) downto MaxLinesToShow do HintSL.Delete( No );
      HintSL.Add( '... more lines ...' );
    end;

    if HintSL.Count = 0 then exit;

    //trim final ODOA
    result := HintSL.Text;

    // Remove the final #$0D#$0A
    if Length( Result ) > 2 then
      SetLength( Result, Length( Result )-2 );
  Finally
    HintSL.Free;
  end;
end ;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetSuperHint( const pWJ : pWorkJournal_Rec; Const OptionalHintsOn : Boolean) : string;
var
  HintSL : TStringList;
begin
  Result    := '' ;

  if not OptionalHintsOn then
    exit;

  HintSL := TStringList.Create;
  Try
    //super hints
    if pWJ^.dtSF_Super_Fields_Edited then
      begin
        case MyClient.clFields.clAccounting_System_Used of

        saSupervisor ,saSuperMate,saSolution6SuperFund:
        begin
          AddIfNotBlank( sffNamesSupervis[ sff_Member_ID],                pWJ^.dtSF_Member_ID, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Franked],                   pWJ^.dtSF_Franked, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Unfranked],                 pWJ^.dtSF_Unfranked, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Imputed_Credit],            pWJ^.dtSF_Imputed_Credit, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Interest],                  pWJ^.dtSF_Interest, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Foreign_Income] ,           pWJ^.dtSF_Foreign_Income, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Capital_Gains_Other],       pWJ^.dtSF_Capital_Gains_Other, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_CG_Foreign_Disc],           pWJ^.dtSF_Capital_Gains_Foreign_Disc, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Rent],                      pWJ^.dtSF_Rent, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Capital_Gains] ,            pWJ^.dtSF_Capital_Gains_Indexed, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Discounted_Capital_Gains],  pWJ^.dtSF_Capital_Gains_Disc, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Other_Expenses],            pWJ^.dtSF_Other_Expenses, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Tax_Deferred_Dist] ,        pWJ^.dtSF_Tax_Deferred_Dist, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Tax_Free_Dist] ,            pWJ^.dtSF_Tax_Free_Dist, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Tax_Exempt_Dist] ,          pWJ^.dtSF_Tax_Exempt_Dist, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Special_Income],            pWJ^.dtSF_Special_Income, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Foreign_Tax_Credits] ,      pWJ^.dtSF_Foreign_Tax_Credits, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Foreign_CG_Credits] ,       pWJ^.dtSF_Foreign_Capital_Gains_Credit, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_TFN_Credits] ,              pWJ^.dtSF_TFN_Credits, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Other_Tax_Credit],          pWJ^.dtSF_Other_Tax_Credit, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Non_Resident_Tax],          pWJ^.dtSF_Non_Resident_Tax, HintSL);
        end;

        saDesktopSuper,
        saClassSuperIP :
        begin
          if MyClient.clFields.clAccounting_System_Used = saDesktopSuper then
             AddIfNotBlank(sffNamesDesktop[ sff_Transaction_Type], pWJ^.dtSF_Transaction_Type_Code, HintSL);

          AddIfNotBlank(sffNamesDesktop[ sff_Member_Component], pWJ^.dtSF_Fund_Code, HintSL);
          AddIfNotBlank(sffNamesDesktop[ sff_Member_ID], pWJ^.dtSF_Member_Account_Code, HintSL);
          if pWJ^.dtSF_CGT_Date <> 0 then
            HintSL.Add( PadS( sffNamesDesktop[sff_CGT_Date], 31) + bkDate2Str( pWJ^.dtSF_CGT_Date));
          AddIfNotZero( sffNamesDesktop[ sff_Special_Income],            pWJ^.dtSF_Special_Income, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Franked],                   pWJ^.dtSF_Franked, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Unfranked],                 pWJ^.dtSF_Unfranked, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Imputed_Credit],            pWJ^.dtSF_Imputed_Credit, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Foreign_Income] ,           pWJ^.dtSF_Foreign_Income, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Other_Expenses],            pWJ^.dtSF_Other_Expenses, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Capital_Gains_Other],       pWJ^.dtSF_Capital_Gains_Other, HintSL);
          if pWJ^.dtSF_Capital_Gains_Fraction_Half then
            HintSL.Add( PadS( sffNamesDesktop[sff_Discounted_Capital_Gains], 31) + '1/2')
          else
            HintSL.Add( PadS( sffNamesDesktop[sff_Discounted_Capital_Gains], 31) + '2/3');
          AddIfNotZero( sffNamesDesktop[ sff_Discounted_Capital_Gains],  pWJ^.dtSF_Capital_Gains_Disc, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Capital_Gains] ,            pWJ^.dtSF_Capital_Gains_Indexed, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Tax_Deferred_Dist] ,        pWJ^.dtSF_Tax_Deferred_Dist, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Tax_Free_Dist] ,            pWJ^.dtSF_Tax_Free_Dist, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Tax_Exempt_Dist] ,          pWJ^.dtSF_Tax_Exempt_Dist, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_TFN_Credits] ,              pWJ^.dtSF_TFN_Credits, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Foreign_Tax_Credits] ,      pWJ^.dtSF_Foreign_Tax_Credits, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Foreign_CG_Credits] ,       pWJ^.dtSF_Foreign_Capital_Gains_Credit, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Other_Tax_Credit],          pWJ^.dtSF_Other_Tax_Credit, HintSL);
        end;

        saSageHandisoftSuperfund :
        begin
          //Type
          if pWJ^.dtSF_Transaction_Type_ID >= 0 then
            HintSL.Add('Type: ' + TypesArray[TTxnTypes(pWJ^.dtSF_Transaction_Type_ID)]);
          //Transaction
          if pWJ^.dtSF_Transaction_Type_Code <> '' then
            HintSL.Add('Transaction: ' + pWJ^.dtSF_Transaction_Type_Code);
          //Number Issued
          if pWJ^.dtQuantity > 0 then
            AddIfNotBlank( 'Number Issued', FormatFloat('#,##0', (pWJ^.dtQuantity / 10000)), HintSL);
          AddIfNotZero( sffNamesHandisoftSuperfund[ sff_Unfranked],       pWJ^.dtSF_Unfranked, HintSL);
          AddIfNotZero( sffNamesHandisoftSuperfund[ sff_Franked],         pWJ^.dtSF_Franked, HintSL);
          AddIfNotZero( sffNamesHandisoftSuperfund[ sff_Imputed_Credit],  pWJ^.dtSF_Imputed_Credit, HintSL);
        end;

        else
        begin
          if pWJ^.dtSF_CGT_Date <> 0 then
            HintSL.Add( PadS( sffNames[sff_CGT_Date], 31) + bkDate2Str( pWJ^.dtSF_CGT_Date));
          AddIfNotZero( sffNames[ sff_Franked],                  pWJ^.dtSF_Franked, HintSL);
          AddIfNotZero( sffNames[ sff_Unfranked],                pWJ^.dtSF_Unfranked, HintSL);
          AddIfNotZero( sffNames[ sff_Imputed_Credit],           pWJ^.dtSF_Imputed_Credit, HintSL);
          AddIfNotZero( sffNames[ sff_Tax_Free_Dist] ,           pWJ^.dtSF_Tax_Free_Dist, HintSL);
          AddIfNotZero( sffNames[ sff_Tax_Exempt_Dist] ,         pWJ^.dtSF_Tax_Exempt_Dist, HintSL);
          AddIfNotZero( sffNames[ sff_Tax_Deferred_Dist] ,       pWJ^.dtSF_Tax_Deferred_Dist, HintSL);
          AddIfNotZero( sffNames[ sff_TFN_Credits] ,             pWJ^.dtSF_TFN_Credits, HintSL);
          AddIfNotZero( sffNames[ sff_Foreign_Income] ,          pWJ^.dtSF_Foreign_Income, HintSL);
          AddIfNotZero( sffNames[ sff_Foreign_Tax_Credits] ,     pWJ^.dtSF_Foreign_Tax_Credits, HintSL);
          AddIfNotZero( sffNames[ sff_Other_Expenses],           pWJ^.dtSF_Other_Expenses, HintSL);
          AddIfNotZero( sffNames[ sff_Capital_Gains] ,           pWJ^.dtSF_Capital_Gains_Indexed, HintSL);
          AddIfNotZero( sffNames[ sff_Discounted_Capital_Gains], pWJ^.dtSF_Capital_Gains_Disc, HintSL);
          AddIfNotZero( sffNames[ sff_Capital_Gains_Other],      pWJ^.dtSF_Capital_Gains_Other, HintSL);
          AddIfNotBlank (sffNames[ sff_Member_Component],        GetSFMemberText(pWJ.dtdate, pWJ^.dtSF_Member_Component, false), HintSL);
        end;
        end;
      end;

    if HintSL.Count = 0 then exit;

    //trim final ODOA
    result := HintSL.Text;
    // Remove the final #$0D#$0A
    if Length( Result ) > 2 then
      SetLength( Result, Length( Result )-2 );
  Finally
    HintSL.Free;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetSuperHint( const pWD : pWorkDissect_Rec; Const OptionalHintsOn : Boolean) : string;
var
  HintSL : TStringList;
begin
  Result    := '' ;

  if not OptionalHintsOn then
    exit;

  HintSL := TStringList.Create;
  Try
    //super hints
    if pWD^.dtSuper_Fields_Edited then
      begin
        case MyClient.clFields.clAccounting_System_Used of
        saSupervisor,
        saSuperMate,saSolution6SuperFund :
        begin
          AddIfNotBlank( sffNamesSupervis[ sff_Member_ID],                pWD^.dtSF_Member_ID, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Franked],                   pWD^.dtSF_Franked, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Unfranked],                 pWD^.dtSF_Unfranked, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Interest],                  pWD^.dtSF_Interest, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Foreign_Income] ,           pWD^.dtSF_Foreign_Income, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Capital_Gains_Other],       pWD^.dtSF_Capital_Gains_Other, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_CG_Foreign_Disc],           pWD^.dtSF_Capital_Gains_Foreign_Disc, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Rent],                      pWD^.dtSF_Rent, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Capital_Gains] ,            pWD^.dtSF_Capital_Gains_Indexed, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Discounted_Capital_Gains],  pWD^.dtSF_Capital_Gains_Disc, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Other_Expenses],            pWD^.dtSF_Other_Expenses, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Tax_Deferred_Dist] ,        pWD^.dtSF_Tax_Deferred_Dist, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Tax_Free_Dist] ,            pWD^.dtSF_Tax_Free_Dist, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Tax_Exempt_Dist] ,          pWD^.dtSF_Tax_Exempt_Dist, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Special_Income],            pWD^.dtSF_Special_Income, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Imputed_Credit],            pWD^.dtSF_Imputed_Credit, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Foreign_Tax_Credits] ,      pWD^.dtSF_Foreign_Tax_Credits, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Foreign_CG_Credits] ,       pWD^.dtSF_Foreign_Capital_Gains_Credit, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_TFN_Credits] ,              pWD^.dtSF_TFN_Credits, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Other_Tax_Credit],          pWD^.dtSF_Other_Tax_Credit, HintSL);
          AddIfNotZero( sffNamesSupervis[ sff_Non_Resident_Tax],          pWD^.dtSF_Non_Resident_Tax, HintSL);
        end;
        saDesktopSuper,
        saClassSuperIP:
        begin
          AddIfNotBlank(sffNamesDesktop[ sff_Transaction_Type], pWD^.dtSF_Transaction_Type_Code, HintSL);
          AddIfNotBlank(sffNamesDesktop[ sff_Member_Component], pWD^.dtSF_Fund_Code, HintSL);
          AddIfNotBlank(sffNamesDesktop[ sff_Member_ID], pWD^.dtSF_Member_Account_Code, HintSL);
          if pWD^.dtSF_CGT_Date <> 0 then
            HintSL.Add( PadS( sffNamesDesktop[sff_CGT_Date], 31) + bkDate2Str( pWD^.dtSF_CGT_Date));
          AddIfNotZero( sffNamesDesktop[ sff_Special_Income],            pWD^.dtSF_Special_Income, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Franked],                   pWD^.dtSF_Franked, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Unfranked],                 pWD^.dtSF_Unfranked, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Foreign_Income] ,           pWD^.dtSF_Foreign_Income, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Other_Expenses],            pWD^.dtSF_Other_Expenses, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Capital_Gains_Other],       pWD^.dtSF_Capital_Gains_Other, HintSL);
          if pWD^.dtSF_Capital_Gains_Fraction_Half then
            HintSL.Add( PadS( sffNamesDesktop[sff_Discounted_Capital_Gains], 31) + '1/2')
          else
            HintSL.Add( PadS( sffNamesDesktop[sff_Discounted_Capital_Gains], 31) + '2/3');
          AddIfNotZero( sffNamesDesktop[ sff_Discounted_Capital_Gains],  pWD^.dtSF_Capital_Gains_Disc, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Capital_Gains] ,            pWD^.dtSF_Capital_Gains_Indexed, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Tax_Deferred_Dist] ,        pWD^.dtSF_Tax_Deferred_Dist, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Tax_Free_Dist] ,            pWD^.dtSF_Tax_Free_Dist, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Tax_Exempt_Dist] ,          pWD^.dtSF_Tax_Exempt_Dist, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Imputed_Credit],            pWD^.dtSF_Imputed_Credit, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_TFN_Credits] ,              pWD^.dtSF_TFN_Credits, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Foreign_Tax_Credits] ,      pWD^.dtSF_Foreign_Tax_Credits, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Foreign_CG_Credits] ,       pWD^.dtSF_Foreign_Capital_Gains_Credit, HintSL);
          AddIfNotZero( sffNamesDesktop[ sff_Other_Tax_Credit],          pWD^.dtSF_Other_Tax_Credit, HintSL);
        end;

        saSageHandisoftSuperfund :
        begin
          //Type
          if pWD^.dtSF_Transaction_Type_ID >= 0 then
            HintSL.Add('Type: ' + TypesArray[TTxnTypes(pWD^.dtSF_Transaction_Type_ID)]);
          //Transaction
          if pWD^.dtSF_Transaction_Type_Code <> '' then
            HintSL.Add('Transaction: ' + pWD^.dtSF_Transaction_Type_Code);
          //Number Issued
          if pWD^.dtQuantity > 0 then
            AddIfNotBlank( 'Number Issued', FormatFloat('#,##0', (pWD^.dtQuantity / 10000)), HintSL);
          AddIfNotZero( sffNamesHandisoftSuperfund[ sff_Unfranked],       pWD^.dtSF_Unfranked, HintSL);
          AddIfNotZero( sffNamesHandisoftSuperfund[ sff_Franked],         pWD^.dtSF_Franked, HintSL);
          AddIfNotZero( sffNamesHandisoftSuperfund[ sff_Imputed_Credit],  pWD^.dtSF_Imputed_Credit, HintSL);
        end;

        else
        begin
          if pWD^.dtSF_CGT_Date <> 0 then
            HintSL.Add( PadS( sffNames[sff_CGT_Date], 31) + bkDate2Str( pWD^.dtSF_CGT_Date));
          AddIfNotZero( sffNames[ sff_Imputed_Credit],            pWD^.dtSF_Imputed_Credit, HintSL);
          AddIfNotZero( sffNames[ sff_Tax_Free_Dist] ,            pWD^.dtSF_Tax_Free_Dist, HintSL);
          AddIfNotZero( sffNames[ sff_Tax_Exempt_Dist] ,          pWD^.dtSF_Tax_Exempt_Dist, HintSL);
          AddIfNotZero( sffNames[ sff_Tax_Deferred_Dist] ,        pWD^.dtSF_Tax_Deferred_Dist, HintSL);
          AddIfNotZero( sffNames[ sff_Franked],                   pWD^.dtSF_Franked, HintSL);
          AddIfNotZero( sffNames[ sff_Unfranked],                 pWD^.dtSF_Unfranked, HintSL);
          AddIfNotZero( sffNames[ sff_TFN_Credits] ,              pWD^.dtSF_TFN_Credits, HintSL);
          AddIfNotZero( sffNames[ sff_Foreign_Income] ,           pWD^.dtSF_Foreign_Income, HintSL);
          AddIfNotZero( sffNames[ sff_Foreign_Tax_Credits] ,      pWD^.dtSF_Foreign_Tax_Credits, HintSL);
          AddIfNotZero( sffNames[ sff_Other_Expenses],            pWD^.dtSF_Other_Expenses, HintSL);
          AddIfNotZero( sffNames[ sff_Capital_Gains] ,            pWD^.dtSF_Capital_Gains_Indexed, HintSL);
          AddIfNotZero( sffNames[ sff_Discounted_Capital_Gains],  pWD^.dtSF_Capital_Gains_Disc, HintSL);
          AddIfNotZero( sffNames[ sff_Capital_Gains_Other],       pWD^.dtSF_Capital_Gains_Other, HintSL);
          AddIfNotBlank (sffNames[ sff_Member_Component],         GetSFMemberText(pWD.dtDate,  pWD^.dtSF_Member_Component, false), HintSL);
        end;
       end;//Case
      end;

    if HintSL.Count = 0 then exit;

    //trim final ODOA
    result := HintSL.Text;
    // Remove the final #$0D#$0A
    if Length( Result ) > 2 then
      SetLength( Result, Length( Result )-2 );
  Finally
    HintSL.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetDissectionHint( const pWD : pWorkDissect_Rec; Const OptionalHintsOn : Boolean) : string;
var
  A             : pAccount_Rec ;
  No            : Integer ;
  DS            : string[ 80 ] ;
  H             : string ;
  HintSL        : TStringList;
  SL            : TStringList;
begin
  Result    := '' ;

  if not OptionalHintsOn then
    exit;

  HintSL := TStringList.Create;
  Try
    //show coding information
    if ( pWD^.dtAccount <> '' ) then
    begin
      A := MyClient.clChart.FindCode( pWD^.dtAccount ) ;
      if not Assigned( A ) then
        DS := 'INVALID CODE!'
      else
        //show chart code description
        DS := A^.chAccount_Description ;
      if pWD.dtAmount_Type_Is_Percent then
        DS := DS + '  [' +  FormatFloat( '###.####', Abs( pWD.dtPercent_Amount ) / 10000  ) + '%]';
      HintSL.Add( DS );
    end;

    //show notes for the transaction
    if ( Length( pWD^.dtNotes) > 0) or ( Length( pWD^.dtImportNotes) > 0) then
    begin
      if (HintSL.Count > 0) then
        HintSL.Add('');
    end;

    //show import notes
    if Length( pWD^.dtImportNotes ) > 0 then
    begin
      SL := TStringList.Create;
      Try
        H  := WrapText( pWD^.dtImportNotes, 40 );
        SL.Text := H;
        for No := 0 to Pred( SL.Count ) do
          HintSL.Add( SL.Strings[ No ] );
      Finally
        SL.Free;
      end;
    end;

    //show user notes
    if Length( pWD^.dtNotes ) > 0 then
    begin
      SL := TStringList.Create;
      Try
        H  := WrapText( pWD^.dtNotes, 40 );
        SL.Text := H;
        For No := 0 to Pred( SL.Count ) do HintSL.Add( SL.Strings[ No ] );
      Finally
        SL.Free;
      end;
    end;

    //super hints
    with MyClient, clFields do
       if  Software.CanUseSuperFundFields( clCountry, clAccounting_System_Used) then begin
          H := GetSuperHint( pWD, OptionalHintsOn);
          if H <> '' then begin
             if HintSL.Count > 0 then
                HintSL.Add( '');
             HintSL.Add( H);
          end;
       end;

    //see if hint is too long
    if HintSL.Count > MaxLinesToShow then
    begin
      For No := Pred( HintSL.Count ) downto MaxLinesToShow do HintSL.Delete( No );
      HintSL.Add( '... more lines ...' );
    end;

    if HintSL.Count = 0 then exit;

    //trim final ODOA
    result := HintSL.Text;

    // Remove the final #$0D#$0A
    if Length( Result ) > 2 then
      SetLength( Result, Length( Result )-2 );
  Finally
    HintSL.Free;
  end;
end ;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetDissectionHint( const pWJ : pWorkJournal_Rec; Const OptionalHintsOn : Boolean) : string;
var
  A             : pAccount_Rec ;
  No            : Integer ;
  DS            : string[ 80 ] ;
  H             : string ;
  HintSL        : TStringList;
begin
  Result    := '' ;

  if not OptionalHintsOn then
    exit;

  HintSL := TStringList.Create;
  Try
    //show coding information
    if ( pWJ^.dtAccount <> '' ) then
    begin
      A := MyClient.clChart.FindCode( pWJ^.dtAccount ) ;
      if not Assigned( A ) then
      begin
        HintSL.Add( 'INVALID CODE!' );
      end
      else
      begin
        //show chart code description
        DS := A^.chAccount_Description ;
        HintSL.Add( DS );
      end;
    end;

    //super hints
    with MyClient, clFields do
       if  Software.CanUseSuperFundFields( clCountry, clAccounting_System_Used) then begin
          H := GetSuperHint( pWJ, OptionalHintsOn);
          if H <> '' then begin
             if HintSL.Count > 0 then
                HintSL.Add( '');
             HintSL.Add( H);
          end;
       end;

    //see if hint is too long
    if HintSL.Count > MaxLinesToShow then
    begin
      For No := Pred( HintSL.Count ) downto MaxLinesToShow do HintSL.Delete( No );
      HintSL.Add( '... more lines ...' );
    end;

    if HintSL.Count = 0 then exit;

    //trim final ODOA
    result := HintSL.Text;

    // Remove the final #$0D#$0A
    if Length( Result ) > 2 then
      SetLength( Result, Length( Result )-2 );
  Finally
    HintSL.Free;
  end;
end ;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetJobHint(const JobCode: string; const OptionalHintsOn : boolean) : string; overload;
var lj: pJob_Heading_Rec;
begin
   Result := '';
   if not OptionalHintsOn then
     exit;
   if JobCode > '' then begin
      lj := MyClient.clJobs.FindCode(JobCode);
      if assigned(lj) then
         result := lj.jhHeading
      else
         Result := 'Unknown';
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetJobHint(const pT : pTransaction_Rec; const OptionalHintsOn : boolean): string; overload;
var
  pD : pDissection_Rec;
  HintSL : TStringList;
  S : string;
  i : integer;
begin
  result := '';

  if not OptionalHintsOn then
    exit;

  if not Assigned(pT) then
    Exit;

  if pT^.txFirst_Dissection = nil then
     Result := GetJobHint(pT.txJob_Code, OptionalHintsOn)
  else begin
     //transaction is dissected, show Jobs as a list if any exist
     HintSL := TStringList.Create;
     try
        if pT^.txJob_Code <> '' then begin
           Result :=  GetJobHint(pT.txJob_Code, OptionalHintsOn);
           Exit;
        end else begin
           pD := pT.txFirst_Dissection;
           while pD <> nil do begin
             if pD^.dsJob_Code <> '' then begin
                S :=  GetJobHint( pd.dsJob_Code, OptionalHintsOn);
                //make sure name is not already in list
                if not HintSL.Find( S, i) then begin
                   if HintSL.Count > MaxLinesToShow then begin
                      S := '... more lines ...';
                      Break;
                   end;
                   HintSL.Add(S);
               end;
             end;
             pD := pD^.dsNext;
           end;
        end;

        if HintSL.Count = 0 then exit;

        Result := HintSL.Text;

        // Remove the final #$0D#$0A
        if Length(Result) > 2 then
           SetLength(Result, Length( Result )-2);
    finally
      HintSL.Free;
    end;
  end;
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetPayeeHint( const aPayeeNo : integer; const OptionalHintsOn : boolean) : string; overload;
var
  APayee : TPayee;
begin
  result := '';

  if not OptionalHintsOn then
    exit;

  if aPayeeNo <> 0 then
  begin
    APayee := MyClient.clPayee_List.Find_Payee_Number( aPayeeNo);
    if Assigned( APayee) then
      result := APayee.pdName
    else
      result := 'Unknown';
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetPayeeHint( const pT : pTransaction_Rec; const OptionalHintsOn : boolean): string; overload;
//this version is used for the CES, it always the name to be displayed even
//if the payees are with a dissection
var
  pD : pDissection_Rec;
  HintSL : TStringList;
  APayee : TPAyee;
  S : string;
  i : integer;
begin
  result := '';

  if not OptionalHintsOn then
    exit;

  if not Assigned( pT) then
    Exit;

  if pT^.txFirst_Dissection = nil then
    result := GetPayeeHint( pT.txPayee_Number, OptionalHintsOn)
  else
  begin
    //transaction is dissected, show payees as a list if any exist
    HintSL := TStringList.Create;
    try
      if pT^.txPayee_Number <> 0 then
      begin
        result :=  GetPayeeHint( pT.txPayee_Number, OptionalHintsOn);
        Exit;
      end
      else
      begin
        pD := pT.txFirst_Dissection;
        while pD <> nil do
        begin
          if pD^.dsPayee_Number <> 0 then
          begin
            APayee := MyClient.clPayee_List.Find_Payee_Number( pD^.dsPayee_Number);
            if Assigned( APayee) then
              S := ( APayee.pdName)
            else
              S := ( 'Unknown Payee');

            //make sure name is not already in list
            if not HintSL.Find( S, i) then
              HintSL.Add( S);
          end;

          pD := pD^.dsNext;
        end;
      end;

      //see if hint is too long
      if HintSL.Count > MaxLinesToShow then
      begin
        For i := Pred( HintSL.Count ) downto MaxLinesToShow do HintSL.Delete( i );
        HintSL.Add( '... more lines ...' );
      end;

      if HintSL.Count = 0 then exit;

      //trim final ODOA
      result := HintSL.Text;

      // Remove the final #$0D#$0A
      if Length( Result ) > 2 then
        SetLength( Result, Length( Result )-2 );
    finally
      HintSL.Free;
    end;
  end;
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.


