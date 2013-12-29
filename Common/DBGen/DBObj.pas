unit DBObj;

// --------------------------------------------------------------------------
interface uses Classes;
// --------------------------------------------------------------------------

Type
   tFieldType = Class( TObject )
      fCode      : ShortString;
      fDefn      : String;
      fReadVars  : String;
      fWriteVars : String;
      fReadCode  : String;
      fWriteCode : String;
      fFreeCode  : String;
      fCRCCode   : String;
      Constructor Create( Const aCode : ShortString );
      Destructor Destroy; Override;
   end;

Var
   FieldTypes : TList = NIL;

Procedure ReplaceCodes( Var AString : String; Const ASearchText, AReplaceText : String );
Function FindFieldType( Const ACode : ShortString ): TFieldType;

// --------------------------------------------------------------------------
implementation uses SysUtils;
// --------------------------------------------------------------------------

Function FindFieldType( Const ACode : ShortString ): TFieldType;
Var
   i : Integer;
Begin
   For i := 0 to Pred( FieldTypes.Count ) do
   Begin
      Result := TFieldType( FieldTypes[ i ] );
      If Result.fCode = ACode then exit;
   end;
   Result := NIL;
end;

// --------------------------------------------------------------------------

Procedure ReplaceCodes( Var AString : String; Const ASearchText, AReplaceText : String );
Var
   i : Integer;
   LeftS : String;
   RightS : String;
Begin
   i := Pos( ASearchText, AString );
   While i > 0 do
   Begin
      LeftS  := Copy( AString, 1, i-1 );
      RightS := Copy( AString, i + Length( ASearchText ), Length( AString ) );
      AString := LeftS + AReplaceText + RightS;
      i := Pos( ASearchText, AString );
   end;
end;

// --------------------------------------------------------------------------

{ tField }

destructor tFieldType.Destroy;
begin
   fDefn      := '';
   fReadVars  := '';
   fWriteVars := '';
   fReadCode  := '';
   fWriteCode := '';
   fFreeCode  := '';
   fCRCCode   := '';
   inherited;
end;

constructor tFieldType.Create(const aCode: ShortString);
begin
   Inherited Create;
   fCode      := aCode;
   fDefn      := '';
   fReadVars  := '';
   fWriteVars := '';
   fReadCode  := '';
   fWriteCode := '';
   fCRCCode   := '';
end;

// -----------------------------------------------------------------------------

Procedure AddFieldType( F : TFieldType );
Var
   i : Integer;
Begin
   For i := 0 to Pred( FieldTypes.Count ) do
      With TFieldType( FieldTypes[ i ] ) do
   If fCode = F.fCode then
   Begin
      Writeln( 'AddFieldType Error: duplicate field type ',F.fCode );
      Halt;
   end;
   FieldTypes.Add( F );
end;

// -----------------------------------------------------------------------------

Procedure CloneFieldType( OldCode, NewCode : ShortString );
Var
   i : Integer;
   FSrc : TFieldType;
   FNew : TFieldType;
Begin
   FSrc := NIL;
   For i := 0 to Pred( FieldTypes.Count ) do
      With TFieldType( FieldTypes[ i ] ) do
   If fCode = OldCode then FSrc := TFieldType( FieldTypes[ i ] );

   If FSrc = NIL then
   Begin
      Writeln( 'CloneFieldType Error: Field type ' + OldCode + ' does not exist' );
      Halt;
   end;

   FNew := tFieldType.Create( NewCode );
   FNew.fDefn := FSrc.fDefn;
   FNew.fReadVars := FSrc.fReadVars;
   FNew.fWriteVars := FSrc.fWriteVars;
   FNew.fReadCode := FSrc.fReadCode;
   FNew.fWriteCode := FSrc.fWriteCode;
   FNew.fFreeCode  := FSrc.fFreeCode;
   FNew.fCRCCode   := FSrc.fCRCCode;
   AddFieldType( FNew );
end;

// -----------------------------------------------------------------------------

Procedure AddFieldTypes;

Const
   CR = #$0D;

Var
   F : TFieldType;
Begin
   // --------------------------------------------------------------------------
   // String Fields
   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'S' );
   F.fDefn      := 'String[ %B1% ];';
   F.fReadCode  := '%NAME% := F.ReadStringValue;' ;
   F.fWriteCode := 'F.WriteStringValue( %TOKEN% , %NAME% );' ;
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'AS' );
   F.fDefn      := 'AnsiString;';
   F.fReadCode  := '%NAME% := F.ReadAnsiStringValue;' ;
   F.fWriteCode := 'F.WriteAnsiStringValue( %TOKEN% , %NAME% );' ;
   F.fFreeCode  := '%NAME% := '''' ;';
   F.fCRCCode   := 'Len := Length( %NAME% );' + CR +
                   'If ( Len > 0 ) then CRC32.UpdateCRC( CRC, Pointer( %NAME% )^, Len );';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'BS' );
   F.fDefn      := 'Array[ 1..%B1% ] of String[ %B2% ];';
   F.fReadVars  := 'S,I';
   F.fReadCode  := 'Begin' + CR +
                   '   S := F.ReadBStringValue( I );' + CR +
                   '   CheckBounds( I, 1, %B1%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I ] := S;' + CR +
                   'end;' ;
   F.fWriteVars := 'I';
   F.fWriteCode := 'For i := 1 to %B1% do F.WriteBStringValue( %TOKEN% , i, %NAME%[ i ] );';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'BS0' );
   F.fDefn      := 'Array[ 0..%B1% ] of String[ %B2% ];';
   F.fReadVars  := 'S,I';
   F.fReadCode  := 'Begin' + CR +
                   '   S := F.ReadBStringValue( I );' + CR +
                   '   CheckBounds( I, 0, %B1%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I ] := S;' + CR +
                   'end;' ;
   F.fWriteVars := 'I';
   F.fWriteCode := 'For i := 0 to %B1% do F.WriteBStringValue( %TOKEN% , i, %NAME%[ i ] );';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'BBS' );
   F.fDefn      := 'Array[ 1..%B1%, 1..%B2% ] of String[ %B3% ];';
   F.fReadVars  := 'S,I1,I2';
   F.fReadCode  := 'Begin' + CR +
                   '   S := F.ReadBBStringValue( I1, I2 );' + CR +
                   '   CheckBounds( I, 1, %B1%, ''%NAME%'' );' + CR +
                   '   CheckBounds( I, 1, %B2%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I1, I2 ] := S;' + CR +
                   'end;' ;
   F.fWriteVars := 'I1,I2';
   F.fWriteCode := 'For I1 := 1 to %B1% do'+ CR +
                   '   For I2 := 1 to %B2% do' + CR +
                   '      F.WriteBBStringValue( %TOKEN% , I1, I2, %NAME%[ I1, I2 ] );';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'BBS0' );
   F.fDefn      := 'Array[ 0..%B1%, 0..%B2% ] of String[ %B3% ];';
   F.fReadVars  := 'S,I1,I2';
   F.fReadCode  := 'Begin' + CR +
                   '   S := F.ReadBBStringValue( I1, I2 );' + CR +
                   '   CheckBounds( I, 0, %B1%, ''%NAME%'' );' + CR +
                   '   CheckBounds( I, 0, %B2%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I1, I2 ] := S;' + CR +
                   'end;' ;
   F.fWriteVars := 'I1,I2';
   F.fWriteCode := 'For I1 := 0 to %B1% do'+ CR +
                   '   For I2 := 0 to %B2% do' + CR +
                   '      F.WriteBBStringValue( %TOKEN% , I1, I2, %NAME%[ I1, I2 ] );';
   AddFieldType( F );

   // --------------------------------------------------------------------------
   // Byte Fields
   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'B' );
   F.fDefn      := 'Byte;';
   F.fReadCode  := '%NAME% := F.ReadByteValue;' ;
   F.fWriteCode := 'F.WriteByteValue( %TOKEN% , %NAME% );' ;
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'BB' );
   F.fDefn      := 'Array[ 1..%B1% ] of Byte;';
   F.fReadVars  := 'B,I';
   F.fReadCode  := 'Begin' + CR +
                   '   B := F.ReadBByteValue( I );' + CR +
                   '   CheckBounds( I, 1, %B1%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I ] := B;' + CR +
                   'end;' ;
   F.fWriteVars := 'I';
   F.fWriteCode := 'For i := 1 to %B1% do F.WriteBByteValue( %TOKEN% , i, %NAME%[ i ] );';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'BB0' );
   F.fDefn      := 'Array[ 0..%B1% ] of Byte;';
   F.fReadVars  := 'B,I';
   F.fReadCode  := 'Begin' + CR +
                   '   B := F.ReadBByteValue( I );' + CR +
                   '   CheckBounds( I, 0, %B1%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I ] := B;' + CR +
                   'end;' ;
   F.fWriteVars := 'I';
   F.fWriteCode := 'For i := 0 to %B1% do F.WriteBByteValue( %TOKEN% , i, %NAME%[ i ] );';
   AddFieldType( F );

   // --------------------------------------------------------------------------
   // Real Fields
   // --------------------------------------------------------------------------
   F := TFieldType.Create('R');
   F.fDefn      := 'Double;';
   F.fReadCode  := '%NAME% := F.ReadDoubleValue;';
   F.fWriteCode := 'F.WriteDoubleValue( %TOKEN%, %NAME% );';
   AddFieldType( F );

   F := TFieldType.Create( 'BR' );
   F.fDefn      := 'Array[ 1..%B1% ] of Double;';
   F.fReadVars  := 'R,I';
   F.fReadCode  := 'Begin' + CR +
                   '   R := F.ReadBDoubleValue( I );' + CR +
                   '   CheckBounds( I, 1, %B1%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I ] := R;' + CR +
                   'end;' ;
   F.fWriteVars := 'I';
   F.fWriteCode := 'For i := 1 to %B1% do F.WriteBDoubleValue( %TOKEN% , i, %NAME%[ i ] );';
   AddFieldType( F );

   // --------------------------------------------------------------------------
   // Integer Fields
   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'I' );
   F.fDefn      := 'Integer;';
   F.fReadCode  := '%NAME% := F.ReadIntegerValue;' ;
   F.fWriteCode := 'F.WriteIntegerValue( %TOKEN% , %NAME% );' ;
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'BI' );
   F.fDefn      := 'Array[ 1..%B1% ] of Integer;';
   F.fReadVars  := 'L,I';
   F.fReadCode  := 'Begin' + CR +
                   '   L := F.ReadBIntegerValue( I );' + CR +
                   '   CheckBounds( I, 1, %B1%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I ] := L;' + CR +
                   'end;' ;
   F.fWriteVars := 'I';
   F.fWriteCode := 'For i := 1 to %B1% do' + CR +
                   '   F.WriteBIntegerValue( %TOKEN% , i, %NAME%[ i ] );';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'BI0' );
   F.fDefn      := 'Array[ 0..%B1% ] of Integer;';
   F.fReadVars  := 'L,I';
   F.fReadCode  := 'Begin' + CR +
                   '   L := F.ReadBIntegerValue( I );' + CR +
                   '   CheckBounds( I, 0, %B1%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I ] := L;' + CR +
                   'end;' ;
   F.fWriteVars := 'I';
   F.fWriteCode := 'For i := 0 to %B1% do F.WriteBIntegerValue( %TOKEN% , i, %NAME%[ i ] );';
   AddFieldType( F );


   CloneFieldType( 'I', 'L' );
   CloneFieldType( 'BI', 'BL' );
   CloneFieldType( 'BI0', 'BL0' );

   // --------------------------------------------------------------------------
   // Date Fields
   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'D' );
   F.fDefn      := 'Integer;';
   F.fReadCode  := '%NAME% := F.ReadDateValue;' ;
   F.fWriteCode := 'F.WriteDateValue( %TOKEN% , %NAME% );' ;
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'DT' );
   F.fDefn      := 'TDateTime;';
   F.fReadCode  := '%NAME% := F.ReadDateTimeValue;' ;
   F.fWriteCode := 'F.WriteDateTimeValue( %TOKEN% , %NAME% );' ;
   AddFieldType( F );

   // --------------------------------------------------------------------------
   F := TFieldType.Create( 'BD' );
   F.fDefn      := 'Array[ 1..%B1% ] of Integer;';
   F.fReadVars  := 'D,I';
   F.fReadCode  := 'Begin' + CR +
                   '   D := F.ReadBDateValue( I );' + CR +
                   '   CheckBounds( I, 1, %B1%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I ] := D;' + CR +
                   'end;' ;
   F.fWriteVars := 'I';
   F.fWriteCode := 'For i := 1 to %B1% do F.WriteBDateValue( %TOKEN% , i, %NAME%[ i ] );';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'BD0' );
   F.fDefn      := 'Array[ 0..%B1% ] of Integer;';
   F.fReadVars  := 'D,I';
   F.fReadCode  := 'Begin' + CR +
                   '   D := F.ReadBDateValue( I );' + CR +
                   '   CheckBounds( I, 0, %B1%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I ] := D;' + CR +
                   'end;' ;
   F.fWriteVars := 'I';
   F.fWriteCode := 'For i := 0 to %B1% do F.WriteBDateValue( %TOKEN% , i, %NAME%[ i ] );';
   AddFieldType( F );

    // --------------------------------------------------------------------------

   F := TFieldType.Create( 'BBD' );
   F.fDefn      := 'Array[ 1..%B1%, 1..%B2% ] of Integer;';
   F.fReadVars  := 'D,I1,I2';
   F.fReadCode  := 'Begin' + CR +
                   '   D := F.ReadBBDateValue( I1, I2 );' + CR +
                   '   CheckBounds( I1, 1, %B1%, ''%NAME%'' );' + CR +
                   '   CheckBounds( I2, 1, %B2%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I1, I2 ] := D;' + CR +
                   'end;' ;
   F.fWriteVars := 'I1,I2';
   F.fWriteCode := 'For I1 := 1 to %B1% do' + CR +
                   '   For I2 := 1 to %B2% do' + CR +
                   '      F.WriteBBDateValue( %TOKEN% , I1, I2, %NAME%[ I1, I2 ] );';

   AddFieldType( F );



   // --------------------------------------------------------------------------
   // Money Fields
   // --------------------------------------------------------------------------

   F := TFieldType.Create( '$' );
   F.fDefn      := 'Money;';
   F.fReadCode  := '%NAME% := F.ReadMoneyValue;' ;
   F.fWriteCode := 'F.WriteMoneyValue( %TOKEN% , %NAME% );' ;
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'B$' );
   F.fDefn      := 'Array[ 1..%B1% ] of Money;';
   F.fReadVars  := 'M,I';
   F.fReadCode  := 'Begin' + CR +
                   '   M := F.ReadBMoneyValue( I );' + CR +
                   '   CheckBounds( I, 1, %B1%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I ] := M;' + CR +
                   'end;' ;
   F.fWriteVars := 'I';
   F.fWriteCode := 'For i := 1 to %B1% do F.WriteBMoneyValue( %TOKEN% , i, %NAME%[ i ] );';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'B$0' );
   F.fDefn      := 'Array[ 0..%B1% ] of Money;';
   F.fReadVars  := 'M,I';
   F.fReadCode  := 'Begin' + CR +
                   '   M := F.ReadBMoneyValue( I );' + CR +
                   '   CheckBounds( I, 0, %B1%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I ] := M;' + CR +
                   'end;' ;
   F.fWriteVars := 'I';
   F.fWriteCode := 'For i := 0 to %B1% do F.WriteBMoneyValue( %TOKEN% , i, %NAME%[ i ] );';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'BB$' );
   F.fDefn      := 'Array[ 1..%B1%, 1..%B2% ] of Money;';
   F.fReadVars  := 'M,I1,I2';
   F.fReadCode  := 'Begin' + CR +
                   '   M := F.ReadBBMoneyValue( I1, I2 );' + CR +
                   '   CheckBounds( I1, 1, %B1%, ''%NAME%'' );' + CR +
                   '   CheckBounds( I2, 1, %B2%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I1, I2 ] := M;' + CR +
                   'end;' ;
   F.fWriteVars := 'I1,I2';
   F.fWriteCode := 'For I1 := 1 to %B1% do' + CR +
                   '   For I2 := 1 to %B2% do' + CR +
                   '      F.WriteBBMoneyValue( %TOKEN% , I1, I2, %NAME%[ I1, I2 ] );';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'BB$0' );
   F.fDefn      := 'Array[ 0..%B1%, 0..%B2% ] of Money;';
   F.fReadVars  := 'M,I1,I2';
   F.fReadCode  := 'Begin' + CR +
                   '   M := F.ReadBBMoneyValue( I1, I2 );' + CR +
                   '   CheckBounds( I1, 0, %B1%, ''%NAME%'' );' + CR +
                   '   CheckBounds( I2, 0, %B2%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I1, I2 ] := M;' + CR +
                   'end;' ;
   F.fWriteVars := 'I1,I2';
   F.fWriteCode := 'For I1 := 0 to %B1% do' + CR +
                   '   For I2 := 0 to %B2% do' + CR +
                   '      F.WriteBBMoneyValue( %TOKEN% , I1, I2, %NAME%[ I1, I2 ] );';
   AddFieldType( F );

   // --------------------------------------------------------------------------
   // Boolean Fields
   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'Y' );
   F.fDefn      := 'Boolean;';
   F.fReadCode  := '%NAME% := F.ReadBooleanValue;' ;
   F.fWriteCode := 'F.WriteBooleanValue( %TOKEN% , %NAME% );' ;
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'BY' );
   F.fDefn      := 'Array[ 1..%B1% ] of Boolean;';
   F.fReadVars  := 'Y,I';
   F.fReadCode  := 'Begin' + CR +
                   '   Y := F.ReadBBooleanValue( I );' + CR +
                   '   CheckBounds( I, 1, %B1%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I ] := Y;' + CR +
                   'end;' ;
   F.fWriteVars := 'I';
   F.fWriteCode := 'For i := 1 to %B1% do F.WriteBBooleanValue( %TOKEN% , i, %NAME%[ i ] );';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'BY0' );
   F.fDefn      := 'Array[ 0..%B1% ] of Boolean;';
   F.fReadVars  := 'Y,I';
   F.fReadCode  := 'Begin' + CR +
                   '   Y := F.ReadBBooleanValue( I );' + CR +
                   '   CheckBounds( I, 0, %B1%, ''%NAME%'' );' + CR +
                   '   %NAME%[ I ] := Y;' + CR +
                   'end;' ;
   F.fWriteVars := 'I';
   F.fWriteCode := 'For i := 0 to %B1% do F.WriteBBooleanValue( %TOKEN% , i, %NAME%[ i ] );';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'LW' );
   F.fDefn      := 'LongWord;';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'PED' );
   F.fDefn      := 'tPeriod_End_Dates;';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'P' );
   F.fDefn      := 'p%A4%;';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'T' );
   F.fDefn      := 'T%A4%;';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'TLB' );
   F.fDefn      := 'TLBRec;';
   AddFieldType( F );

   // --------------------------------------------------------------------------
   // Dynamic Arrays
   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'A$' );
   F.fDefn      := 'DynamicMoneyArray;';
   F.fReadVars  := 'M,I';
   F.fReadCode  := 'Begin' + CR +
                   '   M := F.ReadBMoneyValue( I );' + CR +
                   '   CheckBounds( I, Low( %NAME% ), High( %NAME% ), ''%NAME%'' );' + CR +
                   '   %NAME%[ I ] := M;' + CR +
                   'end;' ;
   F.fWriteVars := 'I';
   F.fWriteCode := 'For i := Low( %NAME% ) to High( %NAME% ) do F.WriteBMoneyValue( %TOKEN% , i, %NAME%[ i ] );';
   F.fFreeCode  := 'SetLength( %NAME%, 0 );';
   F.fCRCCode   := 'Len := Length( %NAME% ) * Sizeof( Money );' + CR +
                   'If ( Len > 0 ) then CRC32.UpdateCRC( CRC, %NAME%[ 0 ], Len );';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'AD' );
   F.fDefn      := 'DynamicDateArray;';
   F.fFreeCode  := 'SetLength( %NAME%, 0 );';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'AY' );
   F.fDefn      := 'DynamicBooleanArray;';
   F.fFreeCode  := 'SetLength( %NAME%, 0 );';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'DTLB' );
   F.fDefn      := 'DTLBRec;';
   F.fFreeCode  := 'DTLBSetLength( %NAME%, 0 );';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'DPD' );
   F.fDefn      := 'TPeriod_Details_Array;';  //defined in DateDef.pas
   F.fFreeCode  := 'SetLength( %NAME%, 0 );';
   AddFieldType( F );

   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'DBR' );
   F.fDefn      := 'TDynamic_Balances_Rec;';  //defined in MoneyDef.pas
   F.fFreeCode  := 'DBR_SetLength( %NAME%, 0 );';
   AddFieldType( F );

   // --------------------------------------------------------------------------
   F := TFieldType.Create( 'TO' );
   F.fDefn      := 'TObject;';
   AddFieldType( F );

   // --------------------------------------------------------------------------
   // Pointer
   // --------------------------------------------------------------------------

   F := TFieldType.Create( 'PTR' );
   F.fDefn      := 'Pointer;';
   F.fReadCode  := '%NAME% := F.ReadIntegerValue;' ;
   F.fWriteCode := 'F.WriteIntegerValue( %TOKEN% , %NAME% );' ;
   AddFieldType( F );

end;

// -----------------------------------------------------------------------------

Procedure FreeFieldTypes;
Var i : Integer;
   F : TFieldType;
Begin
   For i := Pred( FieldTypes.Count ) downto 0 do
   Begin
      F := TFieldType( FieldTypes[ i ] );
      FreeAndNIL( F );
   end;
   FieldTypes.Clear;
   FreeAndNil( FieldTypes );
end;

// -----------------------------------------------------------------------------

Initialization
   FieldTypes := TList.Create;
   AddFieldTypes;
Finalization
   FreeFieldTypes;
end.
