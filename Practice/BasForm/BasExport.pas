unit BasExport;
//------------------------------------------------------------------------------
{
   Title: BAS/IAS export routines

   Description:

   Remarks:

   Author:

}
//------------------------------------------------------------------------------

interface
uses
   BasCalc,
   clObj32;

function SaveForELS( const aClient : TClientObj; BasInfo : TBasInfo; const DefaultELSDir : string;
                     var Response : string) : boolean;

function SaveXML( const aClient : TClientObj; BasInfo : TBasInfo; const DefaultDir : string;
                  var Response : string) : boolean;

//******************************************************************************
implementation
uses
   SysUtils,
   BasUtils,
   GlobalDirectories,
   LogUtil,
   stDate,
   bkconst,
   Registry,
   Windows,
   stDatest, BKDEFS;

const
   Unitname = 'BasExport';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SaveForELS( const aClient : TClientObj; BasInfo : TBasInfo; const DefaultELSDir : string;
                     var Response : string) : boolean;
//returns the file name saved to.  returns '' if not saved
//altered July 2001 to support Sol6 Tax 2001 with new tags.
//this is an interim approach.
Const
   ThisMethodName = 'TFrmBAS.SaveForELS';

Var
   ELSDir      : String;
   ELSFile     : TextFile;
   ELSFileName : String;
   D1,M1,Y1    : Integer;
   D2,M2,Y2    : Integer;
   Msg         : String;

   IsBAS_GA_Form : boolean;
begin
   SysUtils.SetCurrentDir( GlobalDirectories.glDataDir);

   result    := false;
   Response  := '';
   ELSDir    := DefaultELSDir;

   if (ELSDir <> '') then
   begin
     if not DirectoryExists( ELSDir ) then
     begin
        if not CreateDir( ELSDir) then
        begin
           Msg := Format('Unable To Create Directory %s', [ ELSDir ] ) ;
           LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' - ' + Msg );
           Response := Msg;
           exit;
        end;
     end;
   end;

   With BASInfo, aClient.clFields do
   Begin
      ELSFileName := ELSDir + clCode + '.ELS';
      AssignFile( ELSFile, ELSFileName );
      Rewrite( ELSFile );
      Writeln( ELSFile, '<1>' );
      Writeln( ELSFile, '[', clTax_Ledger_Code , ']' );

      IsBAS_GA_Form :=  BasUtils.IsBASForm( BasFormType);

      if IsBAS_GA_Form then
         Writeln( ELSFile, '^XXX*GA*_' )
      else
         Writeln( ELSFile, '^XXX*GB*_' );

      if DocumentID <> '' then
         Writeln( ELSFile, '^EAA*', DocumentID, '*_' );
      //else dont write

      StDateToDMY( BasFromDate, D1, M1, Y1 );
      StDateToDMY( BasToDate, D2, M2, Y2 );

      //Is this a quarterly, monthly or annual form
      if IsBAS_GA_Form then begin
         If not IsQuarterlyStatement then
            Writeln( ELSFile, '^EFP*M*_' ) // Monthly Return
         else
            Writeln( ELSFile, '^EFP*Q*_' ); // Quarterly Return
      end
      else begin
         If not IsQuarterlyStatement then
            Writeln( ELSFile, '^EFQ*M*_' ) // Monthly Return
         else
            Writeln( ELSFile, '^EFQ*Q*_' ); // Quarterly Return
      end;

      //ABN_Extra, only write out if not blank
      Writeln( ELSFile, '^EBN*', ABN, '*_' );
      if ABN_Extra <> '' then
         Writeln( ELSFile, '^ECY*', ABN_Extra, '*_');

      //Dates
      Writeln( ELSFile, '^SOL6A3*', StDateToDateString( 'ddmmyyyy', BasFromDate, True ), '*_' );
      Writeln( ELSFile, '^SOL6A4*', StDateToDateString( 'ddmmyyyy', BasToDate, True ), '*_' );
      Writeln( ELSFile, '^SOL6A5*', StDateToDateString( 'ddmmyyyy', DueDate, True ), '*_' );
      Writeln( ELSFile, '^SOL6A6*', StDateToDateString( 'ddmmyyyy', PaymentDate, True ), '*_' );

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Summary
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      if IsBas_GA_Form then begin
         Writeln( ELSFile, '^EBG*',      iWineEqlPayable_1C               , '*_' );
         Writeln( ELSFile, '^EDX*',      iWineEqlRefund_1D                , '*_' );
         Writeln( ELSFile, '^EBH*',      iLuxCarPayable_1E                , '*_' );
         Writeln( ELSFile, '^EDY*',      iLuxCarRefund_1F                 , '*_' );
         //Writeln( ELSFile, '^EDZ*',      iSalesTaxCredit_1G               , '*_' ); //obsolete Jul 2001
         Writeln( ELSFile, '^EEC*',      iGSTNetAmount_3                  , '*_' );
      end;
      Writeln( ELSFile, '^EBM*',      iTotalWithheld_4                 , '*_' );
      Writeln( ELSFile, '^EED*',      iIncomeTaxInstalm_5A             , '*_' );
      Writeln( ELSFile, '^EEE*',      iCrAdjPrevIncome_5B              , '*_' );
      Writeln( ELSFile, '^EEF*',      iFBTInstalm_6A                   , '*_' );
      Writeln( ELSFile, '^EEG*',      iVariationCr_6B                  , '*_' );
      Writeln( ELSFile, '^EDD*',      iDeferredInstalm_7               , '*_' );

      if aClient.clFields.clBAS_Include_Fuel then
      begin
        if iFuelOverClaim_7C <> 0 then
          Writeln( ELSFile, '^EFO*',      iFuelOverClaim_7C                , '*_' );
        if iFuelCredit_7D <> 0 then
          Writeln( ELSFile, '^EFS*',      iFuelCredit_7D                   , '*_' );
      end;

      Writeln( ELSFile, '^EBO*',      iTaxPayableTotal_8A              , '*_' );
      Writeln( ELSFile, '^EBP*',      iTaxCreditTotal_8B               , '*_' );
      Writeln( ELSFile, '^EBQ*',      iNetTaxObligation_9              , '*_' );

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// GST
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      if iGSTOptionUsed = 1 then begin
         Writeln( ELSFile, '^EHM*Y*_');    //GST option 1
         if bG1IncludesGST then
            Writeln( ELSFile, '^EHP*Y*_')
         else
            Writeln( ELSFile, '^EHP*N*_');
      end;

      if iGSTOptionUsed = 2 then begin
         Writeln( ELSFile, '^EHN*Y*_');    //GST option 1
         if bG1IncludesGST then
            Writeln( ELSFile, '^EHR*Y*_')
         else
            Writeln( ELSFile, '^EHR*N*_');
      end;

      if iGSTOptionUsed = 3 then begin
         Writeln( ELSFile, '^EHO*Y*_');
         Writeln( ELSFile, '^EIE*',   iG21_ATOInstalment    , '*_' );
         Writeln( ELSFile, '^EHT*',   iG22_EstimatedNetGST  , '*_' );
         Writeln( ELSFile, '^EHU*',   iG23_VariedAmount     , '*_' );
         Writeln( ELSFile, '^EHV*',   iG24_ReasonVar        , '*_' );
      end;

      Writeln( ELSFile, '^SOL6G1*',   iIncome_G1                      , '*_' );
      Writeln( ELSFile, '^EBS*',      iExports_G2                     , '*_' );
      Writeln( ELSFile, '^EBT*',      iGSTFreeSupplies_G3             , '*_' );
      Writeln( ELSFile, '^SOL6G4*',   iInputTaxedSales_G4             , '*_' );
      Writeln( ELSFile, '^SOL6G7*',   iIncAdjustments_G7              , '*_' );
      Writeln( ELSFile, '^SOL6G9*',   iGSTPayable_G9                  , '*_' );

      Writeln( ELSFile, '^EBZ*',      iCapitalAcq_G10                 , '*_' );
      Writeln( ELSFile, '^EAR*',      iOtherAcq_G11                   , '*_' );
      Writeln( ELSFile, '^SOL6G13*',  iAcqInputTaxedSales_G13         , '*_' );
      Writeln( ELSFile, '^SOL6G14*',  iAcqNoGST_G14                   , '*_' );
      Writeln( ELSFile, '^SOL6G15*',  iEstPrivateUse_G15              , '*_' );
      Writeln( ELSFile, '^SOL6G18*',  iAcqAdjustments_G18             , '*_' );
      Writeln( ELSFile, '^SOL6G20*',  iGSTCredit_G20                  , '*_' );

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Income Tax Instalment
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      if iPAYGInstalmentOptionUsed = 1 then begin
         Writeln( ELSFile, '^EHX*Y*_');
         Writeln( ELSFile, '^EGA*',   iT7_ATOInstalment           , '*_' );

         if iTaxReasonVar_T4 <> 0 then
         begin
           Writeln( ELSFile, '^SOL6T4*',iTaxReasonVar_T4          , '*_' );
           Writeln( ELSFile, '^EGB*',   iT8_EstimatedTax            , '*_' );
           Writeln( ELSFile, '^EGC*',   iT9_VariedAmount            , '*_' );
         end;
      end;

      // IAS N export
      if iPAYGInstalmentOptionUsed = 3 then begin
         Writeln( ELSFile, '^EII*Y*_');
         Writeln( ELSFile, '^EEW*',   iBAST5           , '*_' );

         if iTaxReasonVar_T4 <> 0 then
         begin
           Writeln( ELSFile, '^SOL6T4*',iTaxReasonVar_T4          , '*_' );
           Writeln( ELSFile, '^EGB*',   iT8_EstimatedTax            , '*_' );
           Writeln( ELSFile, '^EGC*',   iT6_VariedAmount            , '*_' )
         end;
      end;

      if iPAYGInstalmentOptionUsed = 2 then begin
         Writeln( ELSFile, '^EHY*Y*_');   //PAYG instalment option 2
         Writeln( ELSFile, '^EDN*',      iTaxInstalmIncome_T1         , '*_' );

         if iTaxReasonVar_T4 <> 0 then
         begin
           Writeln( ELSFile, '^EER*',      dTaxVarInstalmRate_T3:0:2    , '*_' );
           Writeln( ELSFile, '^SOL6T11*',    iT11_T1x_T2orT3              , '*_' );
           Writeln( ELSFile, '^SOL6T4*',      iTaxReasonVar_T4          , '*_' );
         end
         else
         begin
           Writeln( ELSFile, '^EEQ*',      dTaxInstalmRate_T2:0:2       , '*_' );
           Writeln( ELSFile, '^SOL6T11*',    iT11_T1x_T2orT3              , '*_' );
         end;
      end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// PAYG Withheld
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      Writeln( ELSFile, '^EDO*',      iTotalSalary_W1                 , '*_' );
      Writeln( ELSFile, '^EDP*',      iSalaryWithheld_W2              , '*_' );
      Writeln( ELSFile, '^ECJ*',      iInvstmntDist_W3                , '*_' );
      Writeln( ELSFile, '^ECK*',      iInvoicePymt_W4                 , '*_' );

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// FBT Tax Instalment
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      Writeln( ELSFile, '^EBI*',      iFBTInstalm_F1                  , '*_' );
      if iFBTReasonVar_F4 <> 0 then
      begin
         Writeln( ELSFile, '^EES*',      iFBTTotalPayable_F2             , '*_' );
         Writeln( ELSFile, '^EBJ*',      iFBTVariedInstalm_F3            , '*_' );
         Writeln( ELSFile, '^EDB*',      iFBTReasonVar_F4             , '*_' );
      end;

      Writeln( ELSFile, '<EOF>' );
      CloseFile( ELSFile );

      Response := ELSFileName;
      Result   := True;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function SaveXML_PreJul2001( const aClient : TClientObj; BasInfo : TBasInfo; const DefaultDir : string;
                             var Response : string) : boolean;
//returns the file name saved to.  returns '' if not saved
Const
   ThisMethodName = 'TFrmBAS.SaveXML';
type
   TFieldState = ( fsReadOnly, fsEditable );

Var
   XMLdir      : String;
   XMLFile     : TextFile;
   XMLFileName : String;
   sMsg        : string;

   procedure WriteDTD;
   begin
      Writeln( XMLFile, '<?xml version="1.0" encoding="UTF-8"?>');
      Writeln( XMLFile, '');
      Writeln( XMLFile, '  <!DOCTYPE ECIFORM [');
      Writeln( XMLFile, '     <!ELEMENT ECIFORM (ORIGIN, FIELD_LIST)>');
      Writeln( XMLFile, '     <!-- The combined type and version of this form -->');
      Writeln( XMLFile, '     <!ATTLIST ECIFORM TYPE CDATA #REQUIRED>');
      Writeln( XMLFile, '     <!-- Is the content of this form used as a template or data -->');
      Writeln( XMLFile, '     <!ATTLIST ECIFORM CONTENT CDATA #REQUIRED>');
      Writeln( XMLFile, '     <!-- The place from which this form originated -->');
      Writeln( XMLFile, '     <!ELEMENT ORIGIN (#PCDATA)>');
      Writeln( XMLFile, '     <!-- The list of configurable or enterable fields on the form -->');
      Writeln( XMLFile, '     <!ELEMENT FIELD_LIST (FIELD*)>');
      Writeln( XMLFile, '     <!-- A field on the form -->');
      Writeln( XMLFile, '     <!ELEMENT FIELD (VALUE?, EDIT_STATE?)>');
      Writeln( XMLFile, '     <!-- The unique identification name of this field -->');
      Writeln( XMLFile, '     <!ATTLIST FIELD ID CDATA #REQUIRED>');
      Writeln( XMLFile, '');
      Writeln( XMLFile, '        <!-- The data value entered into the field -->');
      Writeln( XMLFile, '        <!ELEMENT VALUE (#PCDATA)>');
      Writeln( XMLFile, '        <!-- Is the field readonly or editable -->');
      Writeln( XMLFile, '        <!ELEMENT EDIT_STATE (#PCDATA)>');
      Writeln( XMLFile, '  ]>');
   end;


   procedure WriteXMLField( fID : string; Value : string; State : TFieldState);
   var
      s : string;
   begin
      Writeln( XMLFile, '      <FIELD ID="' + fID + '">');
      Writeln( XMLFile, '         <VALUE>' + value + '</VALUE>');
      case State of
         fsReadOnly : s := 'readonly';
         fsEditable : s := 'editable';
      end;
      Writeln( XMLFile, '         <EDIT_STATE>' + s + '</EDIT_STATE>');
      Writeln( XMLFile, '      </FIELD>');
   end;

begin
   result   := False;
   Response := '';

   XMLDir := DefaultDir;

   if (XMLDir <> '') then
   begin
     if not DirectoryExists( XMLDir ) then
     begin
        if not CreateDir( XMLDir) then
        Begin
           sMsg := Format('Unable To Create Directory %s', [ XMLDir ] ) ;
           LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' - ' + sMsg );
           Response := sMsg;
           exit;
        end;
     end;
   end;

   With BASInfo, aClient.clFields do Begin
      XMLFileName :=  XMLDir + 'BAS.' + clCode + '_' + StDateToDateString( 'ddmmyy', BasToDate, true) + '.XML';
      AssignFile( XMLFile, XMLFileName );
      Rewrite( XMLFile );

      WriteDTD;

      if IsQuarterlyStatement then
         Writeln( XMLFile, '<ECIFORM TYPE="BAS-QN1-9.1999" CONTENT="data">')
      else
         Writeln( XMLFile, '<ECIFORM TYPE="BAS-MN1-10.1999" CONTENT="data">');


      writeln( XMLFile, '   <ORIGIN>Australian Tax Office</ORIGIN>');
      Writeln( XMLFile, '   <FIELD_LIST>');

      WriteXMLField( 'fA1', DocumentID , fsReadOnly);   //test data = '12123123123'
      WriteXMLField( 'fA2', ABN , fsReadOnly);          //test abn  = '97999999999'
      if ABN_Extra <> '' then
         WriteXMLField( 'fA2a', ABN_Extra, fsReadOnly);      //abn division

      WriteXMLField( 'fA3', StDateToDateString( 'ddmmyyyy', BasFromDate, true)   ,    fsReadOnly);  //test = '01072000'
      WriteXMLField( 'fA4', StDateToDateString( 'ddmmyyyy', BasToDate, true) ,    fsReadOnly);      //test = '30092000'
      //Totals
      WriteXMLField( 'f1C', IntToStr( iWineEqlPayable_1C), fsEditable);
      WriteXMLField( 'f1E', IntToStr( iLuxCarPayable_1E), fsEditable);

      WriteXMLField( 'f1D', IntToStr( iWineEqlRefund_1D), fsEditable);
      WriteXMLField( 'f1F', IntToStr( iLuxCarRefund_1F), fsEditable);
      WriteXMLField( 'f1G', IntToStr( iSalesTaxCredit_1G), fsEditable);

      if IsQuarterlyStatement then begin
         WriteXMLField( 'f5B', IntToStr( iCrAdjPrevIncome_5B), fsEditable);
         WriteXMLField( 'f6B', IntToStr( iVariationCr_6B), fsEditable);
      end;

      //Calculation Sheet - GST
      WriteXMLField( 'fG1', IntToStr( iIncome_G1), fsEditable);
      WriteXMLField( 'fG2', IntToStr( iExports_G2), fsEditable);
      WriteXMLField( 'fG3', IntToStr( iGSTFreeSupplies_G3), fsEditable);
      WriteXMLField( 'fG4', IntToStr( iInputTaxedSales_G4), fsEditable);

      WriteXMLField( 'fG7', IntToStr( iIncAdjustments_G7), fsEditable);

      WriteXMLField( 'fG10', IntToStr( iCapitalAcq_G10), fsEditable);
      WriteXMLField( 'fG11', IntToStr( iOtherAcq_G11), fsEditable);

      WriteXMLField( 'fG13', IntToStr( iAcqInputTaxedSales_G13), fsEditable);
      WriteXMLField( 'fG14', IntToStr( iAcqNoGST_G14), fsEditable);
      WriteXMLField( 'fG15', IntToStr( iEstPrivateUse_G15), fsEditable);

      WriteXMLField( 'fG18', IntToStr( iAcqAdjustments_G18), fsEditable);

      WriteXMLField( 'fW1',  IntToStr( iTotalSalary_W1), fsEditable);
      WriteXMLField( 'fW2',  IntToStr( iSalaryWithheld_W2), fsEditable);
      WriteXMLField( 'fW3',  IntToStr( iInvstmntDist_W3), fsEditable);
      WriteXMLField( 'fW4',  IntToStr( iInvoicePymt_W4), fsEditable);

      if IsQuarterlyStatement then begin
         WriteXMLField( 'fT1',  IntToStr( iTaxInstalmIncome_T1), fsEditable);
         WriteXMLField( 'fT2',  FormatFloat( '#0.00', dTaxInstalmRate_T2), fsEditable);

         //if either of the next two fields are zero then write an empty value
         // or if a reason give then use T3
         if (dTaxVarInstalmRate_T3 > 0) or (iTaxReasonVar_T4 > 0) then
            WriteXMLField( 'fT3',  FormatFloat( '#0.00', dTaxVarInstalmRate_T3), fsEditable)
         else
            WriteXMLField( 'fT3', '', fsEditable);
         if iTaxReasonVar_T4 > 0 then
            WriteXMLField( 'fT4',  Format( '%2.2d', [ iTaxReasonVar_T4 ]), fsEditable)
         else
            WriteXMLField( 'fT4', '', fsEditable);

         WriteXMLField( 'fF2',  IntToStr( iFBTTotalPayable_F2  ), fsEditable);
         //if either of the next two fields are zero then write an empty value
         if iFBTVariedInstalm_F3 > 0 then
            WriteXMLField( 'fF3',  IntToStr( iFBTVariedInstalm_F3), fsEditable)
         else
            WriteXMLField( 'fF3', '', fsEditable);
         if iFBTReasonVar_F4 > 0 then
            WriteXMLField( 'fF4',  Format( '%2.2d', [ iFBTReasonVar_F4 ]), fsEditable)
         else
            WriteXMLField( 'fF4', '', fsEditable);
      end;

      Writeln( XMLFile, '   </FIELD_LIST>');
      Writeln( XMLFile, '</ECIFORM>');
      CloseFile( XMLFile );

      Response := XMLFileName;
      Result   := True;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ATO_DocType( FormType : byte) : string;
begin

    result := '';
    case FormType of
       bsBasA  : result := 'NAT4189-4.2001';
       bsIasB  : result := 'NAT4192-4.2001';
       bsBasC  : result := 'NAT4195-4.2001';
       bsBasD  : result := 'NAT4191-4.2001';
       bsBasF  : result := 'NAT4190-4.2001';
       bsBasG  : result := 'NAT4235-4.2001';
       bsH     : result := 'NAT4236-4.2001';
       bsK     : result := 'NAT4647-4.2001';
       bsIASI  : result := 'NAT4193-4.2001';
       bsIASJ  : result := 'NAT4197-4.2001';
       bsBasU  : result := 'NAT14167-06.2006';
       bsBasV  : result := 'NAT14168-06.2006';
       bsBasW  : result := 'NAT14169-06.2006';
       bsBasX  : result := 'NAT14170-06.2006';
       bsBasY  : result := 'NAT14171-06.2006';
       bsBasZ  : result := 'NAT14172-06.2006';
       bsIASN  : result := 'NAT4648-8.2001';
    end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ATO_FilenamePrefix( FormType : byte) : string;
begin

    result := '';
    case FormType of
       bsBasA  : result := 'bas-a.';
       bsIasB  : result := 'ias-b.';
       bsBasC  : result := 'bas-c.';
       bsBasD  : result := 'bas-d.';
       bsBasF  : result := 'bas-f.';
       bsBasG  : result := 'bas-g.';
       bsH     : result := 'bas-p.';
       bsK     : result := 'bas-q.';
       bsIASI  : result := 'ias-i.';
       bsIASJ  : result := 'ias-j.';
       bsBasU  : result := 'bas-u.';
       bsBasV  : result := 'bas-v.';
       bsBasW  : result := 'bas-w.';
       bsBasX  : result := 'bas-x.';
       bsBasY  : result := 'bas-y.';
       bsBasZ  : result := 'bas-z.';
       bsIASN  : result := 'ias-n.';
    end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SaveXML( const aClient : TClientObj; BasInfo : TBasInfo; const DefaultDir : string;
                  var Response : string) : boolean;
//returns the file name saved to in Response.  Returns error msg if not saved
Const
   ThisMethodName = 'TFrmBAS.SaveXML';
type
   TFieldState = ( fsReadOnly, fsEditable );

Var
   XMLdir      : String;
   XMLFile     : TextFile;
   XMLFileName : String;
   sMsg        : string;


   procedure WriteXMLField_NoTest( FieldLabel : string; Value : integer); overload;
   begin
       Writeln( XMLFile, '<' + FieldLabel + '>' + inttostr( value) + '</' + FieldLabel + '>');
   end;


   procedure WriteXMLField( FieldLabel : string; Value : string); overload;
   begin
      if ( Value = '') then exit;

      Writeln( XMLFile, '<' + FieldLabel + '>' +
                        Value +
                        '</' + FieldLabel + '>');
   end;

   procedure WriteXMLField( FieldLabel : string; Value : integer; FieldID : byte; ZeroAsNull : boolean = false); overload;
   //write integer value, test if should be exported
   begin
     if ( Value <> 0) or ( fieldVisible( FieldID, BasInfo.BasFormType, Value)) then
       if ZeroAsNull and (Value = 0) then
         Writeln( XMLFile, '<' + FieldLabel + '></' + FieldLabel + '>')
       else
         Writeln( XMLFile, '<' + FieldLabel + '>' + inttostr( value) + '</' + FieldLabel + '>');
   end;

   procedure WriteXMLField( FieldLabel : string; Value : double); overload;
   //write double value if non zero
   begin
      if ( value <> 0.0) then
         Writeln( XMLFile, '<' + FieldLabel + '>' + FormatFloat( '#0.00', Value) + '</' + FieldLabel + '>');
   end;

   procedure WriteXMLField( FieldLabel : string; Value : double;  FieldID : byte; ZeroAsNull : boolean = false); overload;
   //write double value, test if should be exported
   begin
      if ( fieldVisible( FieldID, BasInfo.BasFormType, value))  then
      begin
        if ZeroAsNull and ( value = 0.0) then
          Writeln( XMLFile, '<' + FieldLabel + '></' + FieldLabel + '>')
        else
          Writeln( XMLFile, '<' + FieldLabel + '>' + FormatFloat( '#0.00', Value) + '</' + FieldLabel + '>');
      end;
   end;

   procedure WriteXMLField( FieldLabel : string; Value : boolean; FieldID : byte); overload;
   //BOOLEAN
   begin
      if FieldVisible( FieldID, BasInfo.BasFormType) then begin
         if Value then
            Writeln( XMLFile, '<' + FieldLabel + '>true</' + FieldLabel + '>')
         else
            Writeln( XMLFile, '<' + FieldLabel + '>false</' + FieldLabel + '>')
      end;
   end;

   procedure UpdateAPSRegistryKey( FileDir : string);
   //aps tax needs to know where the xml file has been saved to
   begin
     with TRegistry.Create do
     begin
        try
           RootKey := HKEY_CURRENT_USER;
           if OpenKey( '\Software\BankLink', true) then
           begin
              if (Length(FileDir) > 1) and (FileDir[1] <> '\') and (ExtractFileDrive(FileDir) = '') then // Relative to data dir
                WriteString( 'APSDirectory', GlobalDirectories.glDataDir + FileDir)
              else
                WriteString( 'APSDirectory', FileDir);
           end;
        finally
           CloseKey;
           Free;
        end;
     end;
   end;

var
  ZeroAsNull : boolean;

begin
   SysUtils.SetCurrentDir( GlobalDirectories.glDataDir);

   //check if in old format
   if BasInfo.BasFormType = bs2000 then begin
      result := SaveXML_PreJul2001( aClient, BasInfo, DefaultDir, Response);
      exit;
   end;

   //new format
   Result := False;
   Response := '';

   XMLDir := DefaultDir;

   if not DirectoryExists( XMLDir ) then
   begin
      if (XMLDir <> '') and (XMLDir <> PathDelim) and not CreateDir( XMLDir) then
      Begin
         sMsg := Format('Unable To Create Directory %s', [ XMLDir ] ) ;
         LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' - ' + sMsg );
         Response := sMsg;
         exit;
      end;
   end;

   With BASInfo, aClient.clFields do Begin

      if clTax_Interface_Used = tsBAS_APS_XML then
      begin
        //APS XML interface has a slightly different filename
        //and also requires a registry entry
        if IsIASForm(BasFormType) then // use TFN-style filename
          XMLFilename := XMLDir + BasInfo.TFN + '_' + StDateToDateString( 'ddmmyy', BasToDate, true) + '.xml'
        else
          XMLFilename := XMLDir + BasInfo.ABN + '_' + StDateToDateString( 'ddmmyy', BasToDate, true) + '.xml';
        UpdateAPSRegistryKey( XMLDir);
      end
      else
        //using standard XML interface
        XMLFileName := XMLDir + ATO_FilenamePrefix( BasFormType) + clCode + '_' + StDateToDateString( 'ddmmyy', BasToDate, true) + '.xml';

      AssignFile( XMLFile, XMLFileName );
      Rewrite( XMLFile );

      Writeln( XMLFile, '<?xml version="1.0" ?>');

      if clTax_Interface_Used = tsBAS_APS_XML then
      begin
        Writeln( XMLFile, '<AusTax>');
      end
      else
      begin
        Writeln( XMLFile, '<!DOCTYPE ' + ATO_DocType( BasFormType) + '>');
        Writeln( XMLFile, '');
      end;

      Writeln( XMLFile, '<'+ ATO_DocType( BasFormType) + '>');
      WriteXMLField( 'DIN', DocumentID);
      WriteXMLField( 'ABN', ABN);
      if ABN_Extra <> '' then
         WriteXMLField( 'CAC', ABN_Extra);

      WriteXMLField( 'PERIOD_DATE_FROM', StDateToDateString( 'ddmmyyyy', BasFromDate, true));
      WriteXMLField( 'PERIOD_DATE_TO',   StDateToDateString( 'ddmmyyyy', BasToDate,   true));

      WriteXMLField( 'MANUAL_MODE', 'false');

      if clGST_Basis = gbPayments then
         WriteXMLField( 'GST_ACCOUNTING_METHOD_LABEL_TEXT', 'Cash')
      else
         WriteXMLField( 'GST_ACCOUNTING_METHOD_LABEL_TEXT', 'Non-cash (accruals)');

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// GST
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      WriteXMLField( 'GST_OPTION_1', (iGSTOptionUsed = 1),                bfGSTOption1);
      if iGSTOptionUsed = 1 then
        WriteXMLField( 'INCLUDE_GST_OPTION_1', bG1IncludesGST,            bfG1IncludesGST)
      else
        WriteXMLField( 'INCLUDE_GST_OPTION_1', False,                     bfG1IncludesGST);
      WriteXMLField( 'GST_OPTION_2', (iGSTOptionUsed = 2),                bfGSTOption2);
      if iGSTOptionUsed = 2 then
        WriteXMLField( 'INCLUDE_GST_OPTION_2', bG1IncludesGST,            bfG2IncludesGST)
      else
        WriteXMLField( 'INCLUDE_GST_OPTION_2', False,                     bfG2IncludesGST);
      WriteXMLField( 'GST_OPTION_3', (iGSTOptionUsed = 3),                bfGSTOption3);
      WriteXMLField( 'ATO_GST_INSTALMENT_AMOUNT', iG21_ATOInstalment,     bfG21);
      WriteXMLField( 'ESTIMATED_GST_FOR_YEAR',    iG22_EstimatedNetGST,   bfG22);
      WriteXMLField( 'VARIED_GST_INSTALMENT',     iG23_VariedAmount,      bfG23);
      if BasUtils.FieldVisible( bfG24, BasFormType, iG24_ReasonVar) then begin
         if iG24_ReasonVar <> 0 then
            WriteXMLField( 'GST_REASON_FOR_VARIATION',  Format( '%2.2d', [iG24_ReasonVar]))
          else
            WriteXMLField( 'GST_REASON_FOR_VARIATION',  '');
      end;
                                          
      WriteXMLField( 'GST_TOTAL_SALES', iIncome_G1, bfG1);
      WriteXMLField( 'EXPORTS',     iExports_G2, bfG2);
      WriteXMLField( 'OTHER_GST_FREE_SUPPLIES', iGSTFreeSupplies_G3, bfG3);
      WriteXMLField( 'CAPITAL_PURCHASES',     iCapitalAcq_G10, bfG10);
      WriteXMLField( 'NON_CAPITAL_PURCHASES',     iOtherAcq_G11, bfG11);

      //Always write the calculation sheet values
      WriteXMLField_NoTest( 'CAL_G1',      iIncome_G1);
      WriteXMLField_NoTest( 'CAL_G2',      iExports_G2);
      WriteXMLField_NoTest( 'CAL_G3',      iGSTFreeSupplies_G3);
      WriteXMLField_NoTest( 'CAL_G4',      iInputTaxedSales_G4);
      WriteXMLField_NoTest( 'CAL_G5',      iTotalGSTFree_G5);
      WriteXMLField_NoTest( 'CAL_G6',      iTotalTaxableSupp_G6);
      WriteXMLField_NoTest( 'CAL_G7',      iIncAdjustments_G7);
      WriteXMLField_NoTest( 'CAL_G8',      iTotalTaxSuppAdj_G8);
      WriteXMLField_NoTest( 'CAL_G9',      iGSTPayable_G9);

      WriteXMLField_NoTest( 'CAL_G10',     iCapitalAcq_G10);
      WriteXMLField_NoTest( 'CAL_G11',     iOtherAcq_G11);
      WriteXMLField_NoTest( 'CAL_G12',     iTotalAcq_G12);
      WriteXMLField_NoTest( 'CAL_G13',     iAcqInputTaxedSales_G13);
      WriteXMLField_NoTest( 'CAL_G14',     iAcqNoGST_G14);
      WriteXMLField_NoTest( 'CAL_G15',     iEstPrivateUse_G15);
      WriteXMLField_NoTest( 'CAL_G16',     iTotalNonCreditAcq_G16);
      WriteXMLField_NoTest( 'CAL_G17',     iTotalCreditAcq_G17);
      WriteXMLField_NoTest( 'CAL_G18',     iAcqAdjustments_G18);
      WriteXMLField_NoTest( 'CAL_G19',     iTotalCreditAcqAdj_G19);
      WriteXMLField_NoTest( 'CAL_G20',     iGSTCredit_G20);

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// PAYG Withheld
// Fields will only be exported if should be there, or value is non zero
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      WriteXMLField( 'WITHHELD_FROM_SALARY_AMOUNT', iTotalSalary_W1, bfW1);
      WriteXMLField( 'TOTAL_PAYMENTS_WITHHOLDING_AMOUNT', iSalaryWithheld_W2, bfW2);
      WriteXMLField( 'WITHHELD_FROM_INVESTMENT_DISTRIBUTIONS_AMOUNT', iInvstmntDist_W3, bfW3);
      WriteXMLField( 'WITHHELD_FROM_INVOICES_NO_ABN', iInvoicePymt_W4, bfW4);
      WriteXMLField( 'TOTAL_WITHHELD_AMOUNT', iW5_TotalAmountsWithheld, bfW5);

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// PAYG Instalment
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      WriteXMLField( 'PAYGI_OPTION_1', iPAYGInstalmentOptionUsed = 1,     bfT7);
      WriteXMLField( 'PAYGI_OPTION_1', iPAYGInstalmentOptionUsed = 3,     bfT6);
          if BasFormType = bsIASN then
            WriteXMLField( 'ATO_CALCULATED_AMOUNT', iBAST5,          bfT5)
          else
          begin
            //T7 - value must be written if option 1 and NO variation specified
            ZeroAsNull := not(((iPAYGInstalmentOptionUsed = 1) or (iPAYGInstalmentOptionUsed = 3)) and (iTaxReasonVar_T4 = 0));
            WriteXMLField( 'ATO_CALCULATED_AMOUNT', iT7_ATOInstalment,          bfT7, ZeroAsNull);
          end;
          //T8,T9,T11
          //value must be exported if option 1 selected and varition specified
          ZeroAsNull := not(((iPAYGInstalmentOptionUsed = 1) or (iPAYGInstalmentOptionUsed = 3)) and (iTaxReasonVar_T4 <> 0));
          WriteXMLField( 'ESTIMATED_YEAR_INCOME_TAX', iT8_EstimatedTax,       bfT8, ZeroAsNull);
          if BasInfo.BasFormType = bsIasN then // uses the same XML field ID!!
            WriteXMLField( 'VARIED_INSTALMENT', iT6_VariedAmount,               bfT9, ZeroAsNull)
          else
            WriteXMLField( 'VARIED_INSTALMENT', iT9_VariedAmount,               bfT9, ZeroAsNull);
          WriteXMLField( 'CALCULATED_INSTALMENT_AMOUNT', iT11_T1x_T2orT3,     bfT11, ZeroAsNull);

      WriteXMLField( 'PAYGI_OPTION_2', iPAYGInstalmentOptionUsed = 2,     bfT1);
          WriteXMLField( 'INSTALMENT_INCOME', iTaxInstalmIncome_T1,           bfT1);
          //T2 - value must be exported if option 2 and NO variation
          ZeroAsNull := not((iPAYGInstalmentOptionUsed = 2) and (iTaxReasonVar_T4 = 0));
          WriteXMLField( 'COMMISSIONERS_INSTALMENT_RATE', dTaxInstalmRate_T2, bfT2, ZeroAsNull);
          //T3 - value must be exported if option 2 and variation specified
          ZeroAsNull := not((iPAYGInstalmentOptionUsed = 2) and (iTaxReasonVar_T4 <> 0));
          WriteXMLField( 'VARIED_INSTALMENT_RATE', dTaxVarInstalmRate_T3,     bfT3, ZeroAsNull);

      if iTaxReasonVar_T4 <> 0 then
        WriteXMLField( 'REASON_VARIATION', Format( '%2.2d', [ iTaxReasonVar_T4]))
      else
        WriteXMLField( 'REASON_VARIATION', '');
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// FBT
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      if iFBTReasonVar_F4 <> 0 then
      begin
        //FBT Reason specified, use F2,F3,F4
        WriteXMLField( 'REASON_FOR_FBT_VARIATION', Format( '%2.2d', [ iFBTReasonVar_F4 ]));
        WriteXMLField( 'ESTIMATED_FBT_TAX', iFBTTotalPayable_F2,            bfF2);
        WriteXMLField( 'VARIED_FBT_INSTALMENT', iFBTVariedInstalm_F3,       bfF3);
        //F1 field will not be filled (normally) if variation is specified
        WriteXMLField( 'ATO_CALCULATED_FBT_INSTALMENT', iFBTInstalm_F1,     bfF1, true); //null if zero
      end
      else
      begin
        //No FBT Reason, use F1
        WriteXMLField( 'REASON_FOR_FBT_VARIATION', '');
        WriteXMLField( 'ATO_CALCULATED_FBT_INSTALMENT', iFBTInstalm_F1,     bfF1);
        //F2,F3 fields will not be filled (normally) if no variation reason
        WriteXMLField( 'ESTIMATED_FBT_TAX', iFBTTotalPayable_F2,            bfF2, true); //null if zero
        WriteXMLField( 'VARIED_FBT_INSTALMENT', iFBTVariedInstalm_F3,       bfF3, true); //null if zero
      end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// SUMMARY
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      WriteXMLField( 'GST_TAX', iGSTPayable_1A,        bf1A);
      WriteXMLField( 'GST_REFUND', iGSTCredit_1B,         bf1B);
      WriteXMLField( 'WINE_EQUALISATION_TAX_PAYABLE', iWineEqlPayable_1C,        bf1C);
      WriteXMLField( 'WINE_EQUALISATION_TAX_REFUNDABLE', iWineEqlRefund_1D,         bf1D);
      WriteXMLField( 'LUXURY_CAR_TAX_PAYABLE', iLuxCarPayable_1E,         bf1E);
      WriteXMLField( 'LUXURY_CAR_TAX_REFUNDABLE', iLuxCarRefund_1F,          bf1F);
      WriteXMLField( 'GST_INSTALMENTS', i1H_GSTInstalment,         bf1H);

      WriteXMLField( 'PAYG_WITHHOLDING', iTotalWithheld_4,       bf4);
      WriteXMLField( 'PAYG_INSTALMENT', iIncomeTaxInstalm_5A,       bf5A);
      WriteXMLField( 'CREDIT_FROM_REDUCED_PAYG_INSTALMENTS', iCrAdjPrevIncome_5B,       bf5B);
      WriteXMLField( 'FBT_INSTALMENT', iFBTInstalm_6A,           bf6a);
      WriteXMLField( 'CREDIT_FROM_REDUCED_FBT_INSTALMENTS', iVariationCr_6B,           bf6B);
      WriteXMLField( 'DEFERRED_COMPANY_FUND_INSTALMENT',  iDeferredInstalm_7,        bf7);
      if aClient.clFields.clBAS_Include_Fuel then
      begin
        WriteXMLField( 'FUEL_EXCISE_DEBIT',  iFuelOverClaim_7C,         bf7c);
        WriteXMLField( 'FUEL_EXCISE_CREDIT',  iFuelCredit_7D,           bf7d);
      end;

      if BasUtils.FieldVisible( bf8A, BasFormType) then
         WriteXMLField_NoTest( 'TOTAL_DEBITS', iTaxPayableTotal_8A);

      if BasUtils.FieldVisible( bf8B, BasFormType) then
         WriteXMLField_NoTest( 'TOTAL_CREDITS', iTaxCreditTotal_8B);

      if BasUtils.FieldVisible( bf9, BasFormType) then
         WriteXMLField_NoTest( 'NET_AMOUNT_FOR_THIS_STATEMENT', iNetTaxObligation_9);

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      Writeln( XMLFile, '</' + ATO_DocType( BasFormType) + '>');
      if clTax_Interface_Used = tsBAS_APS_XML then
      begin
        Writeln( XMLFile, '</AusTax>');
      end;
      CloseFile( XMLFile );

      Response := XMLFileName;
      Result   := True;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
