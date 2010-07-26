unit DBaseReader;

{-------------------------------------------------------}
{   This unit allows us to read a dbase 3 or 4 format   }
{   file.  note this is not a complete utility, but only}
{   works for selected data types that are used to read }
{   CA systems and SimpleFund format files              }

interface
uses
   BuffStrm, ECollect, sysutils, classes, dialogs;

const
   DBFieldNameLen         = 10;
   DelMarkName            = '_DelMark';

{--FType}

   DelMarkFType           = #0; {-Not a dBASE field type, but describes the 1st byte of a dBASE record}
   DateFType              = 'D';
   CharFType              = 'C';
   LogicFType             = 'L';
   NumerFType             = 'N';
   FloatFType             = 'F';
   MemoFType              = 'M';

{--CType}
   ReservedCType   = 0;
   BooleanCType    = 1;
   CharCType       = 2;
   ByteCType       = 3;
   ShortIntCType   = 4;
   IntegerCType    = 5;
   WordCType       = 6;
   LongIntCType    = 7;
   CompCType       = 8;
   RealCType       = 9;
   SingleCType     = 10;
   DoubleCType     = 11;
   ExtendedCType   = 12;
   StringCType     = 13;
   ArrayCType      = 14;
   AZStringCType   = 15;
   DateCType       = 16;
   TimeCType       = 17;

{--DBaseVersion}
   DBVersion3X = $0300;
   DBVersion4X = $0400;

{--Private constants}
   DB4MaxFields = 255;

{--Interfaced types}
Type
   DBaseFieldName = Array [0 .. DBFieldNameLen] Of Char; {-dBASE field name}
   DBaseFieldNameStr = String [DBFieldNameLen];

   DBaseVersion = Integer;

{--Private types}
   DBaseFileField = Record
      Name         : DBaseFieldName;
      FType        : Char;
      Address      : ^Char;
      Width,
      Decimals     : Byte;
      Reserved1    : Array [0 .. 1] of Byte;
      IDWorkReg    : Byte;
      Reserved2    : Array [0 .. 1] of Byte;
      SetFieldFlag : Byte;
      Reserved3    : Array [0 .. 7] of Byte;
   End;

   DBaseFileDate = Record
      Year,
      Month,
      Day    : Byte;
   End;

   DBaseFileHeader = Record
      DBaseVer   : Byte;
      LastChange : DBaseFileDate;
      NrOfRecs   : Longint;
      HeaderSize,
      RecordSize : Word;
   End;

   tDBaseField = class
      FieldName: DBaseFieldNameStr;
      FType    : Char;
      Width    : Byte;
      Decimals : Byte;
      Offset   : Word;
      CType    : Byte;
   public
      Procedure DetermineCType;
   end;

type
   tDBaseFile = class(TbfsBufferedFileStream)
      Header      : DBaseFileHeader;
      DBVer       : DBaseVersion;
      RefNr       : Longint;
      Fields      : Byte;
      FieldList   : TExtdCollection;
      RecInfo     : Array[0..4096] of Byte;

      constructor Create(const aFileName: string);
      destructor Destroy; override;
   public
      Procedure   GotoRecord ( Ref : LongInt );
      Procedure   Get( Position : LongInt; Var B; Size : Word );
      Function    GetField( Name : ShortString; FCType : Byte; Var DstBuf ): Integer;
   end;

{-------------------------------------------------------}
implementation

Const
  DBMaxFields            = 128;
  DBDateFieldWidth       = 8;
  DBLogicFieldWidth      = 1;
  DBMemoFieldWidth       = 10;
  DBMaxCharFieldWidth    = 254;
  DBMaxNumFieldWidth     = 19;
  DBMaxNumFieldDecimals  = 15;
  DB4MaxNumFieldWidth    = 20;
  DB4MaxNumFieldDecimals = 18;
  DBMaxRecSize           = 4001;
    {-Maximum record size + 1 byte ( dBASE delete mark )}
  DBMinMemoRecSize       = 512;
  DBMaxMemoSize          = $FFF7; {64 K Bytes - 8 Bytes}
  DBDataOnly             = $03;
  DBDataAndMemo          = $83;
  DB4DataAndMemo         = $8B;
  DB4ValidMemoField      = $0008FFFF;
  DB4ValidMemoFile       = $01020000;
  DBEndOfHeader          = #$0D;
  DBEndOfFile            = #$1A;
  DBEndOfMemoRec         = #$1A;

TYPE
  CharArr = Array [0 .. $FFFE] Of Char;
  PCharArr = ^CharArr;


{-------------------------------------------------------}
   Function IsNumStr (Str : ShortString;
                      MaxLen : Integer;
                      Signed,
                      Float,
		      Empty : Boolean ) : Boolean;

  Var
    I : Integer;
    CSet : Set Of Char;

  Begin
    If Str <> '' Then Begin
      IsNumStr := False;
      If Length ( Str ) > MaxLen Then Exit;
      If Str [1] = '-' Then Begin
        If Signed Then Begin
          Delete ( Str, 1, 1 );
        End Else Begin
          Exit;
        End;
      End;
      CSet := [];
      For I := 1 To Length ( Str ) Do
        CSet := CSet + [ Str [I] ];
      If Float Then Begin
        IsNumStr := CSet <= ['.', '0' .. '9'];
      End Else Begin
        IsNumStr := CSet <= ['0' .. '9'];
      End;
      Exit;
    End;
    IsNumStr := Empty;
  End;


{-------------------------------------------------------}
  Function CArr2LBStr ( Var LBStr : ShortString;
                            CArr  : Pointer;
                            Size  : Word ) : Integer;

  Begin
    CArr2LBStr := -1;
    If Size > 255 Then Exit;
    Move ( CArr^, LBStr [1], Size );
    LBStr [0] := Char ( Size );
    CArr2LBStr := 0;
  End;

{-------------------------------------------------------}
  Function CArr2Single ( Var Value : Single;
                             CArr : Pointer;
                             Size : Word ) : Integer;
  Var
    Res : Integer;
    TStr : ShortString;

  Begin
    CArr2Single := -1;

    If CArr2LBStr ( TStr, CArr, Size ) <> 0 Then Exit;
    TStr := Trim ( TStr );
    If TStr = '' Then Begin
      Value := 0.0;
      CArr2Single := 0;
      Exit;
    End;
    If Not IsNumStr ( TStr, Size, True, True, True ) Then Exit;
    Val ( TStr, Value, Res );
    If Res <> 0 Then Exit;

    CArr2Single := 0;
  End;


{-------------------------------------------------------}
  Function Char2Boolean ( Var Value : Boolean;
                              Chr : Char ) : Integer;
  Begin
    Char2Boolean := 0;
    Case Upcase ( Chr ) Of
      'T', 'Y', 'J': Value := True;
      'F', 'N':      Value := False;
      Else Begin
        Value := False;
        Char2Boolean := -1;
      End;
    End;
  End;


{-------------------------------------------------------}
{-------------------------------------------------------}
{ tDBaseField }

procedure tDBaseField.DetermineCType;
begin
   Case FType Of
      DelMarkFType   :  CType := BooleanCType;
      MemoFType      :  CType := AZStringCType;
      CharFType      :  Begin
                           If Width = 1 Then
                              CType := CharCType
                           Else
                              CType := StringCType;
                        End;
      LogicFType     :  CType := BooleanCType;
      DateFType      :  CType := DateCType;
      NumerFType,
      FloatFType     :  Begin
                           If Decimals = 0 Then
                           Begin
                              If Width < 3 Then
                                 CType := ShortIntCType
                              Else If Width < 5 Then
                                 CType := IntegerCType
                              Else If Width < 10 Then
                                 CType := LongIntCType
                              Else If Width < 12 Then
                                 CType := RealCType
                              Else If Width < 16 Then
                                 CType := DoubleCType
                              Else If Width < 21 Then
                                 CType := ExtendedCType
                              Else CType := ReservedCType;
                           End
                           Else
                           Begin
                              If Width < 8 Then
                                 CType := SingleCType
                              Else If Width < 12 Then
                                 CType := RealCType
                              Else If Width < 16 Then
                                 CType := DoubleCType
                              Else If Width < 21 Then
                                 CType := ExtendedCType
                              Else
                                 CType := ReservedCType;
                           End;
                        End;
      Else
         CType := ReservedCType;
   End; { of case }
end;

{-------------------------------------------------------}
{-------------------------------------------------------}
{ tDBaseFile }
constructor tDBaseFile.Create(const aFileName: string);
const
  BUFFER_SIZE = 8192;

type
  DBaseFileFullHeader = Record
    Part           : DBaseFileHeader;
    Reserved1      : Array [0 .. 1] Of Char;
    TransActionFlag,
    EncryptionFlag : Byte;
    Reserved2      : Array [0 .. 11] Of Char;
    MDXFlag        : Byte;
    Reserved3      : Array [0 .. 2] Of Char;
  End;

var
   i,
   FieldOfs  : Word;
   DBFBuf    : DBaseFileField;
   p         : TDBaseField;
   Position  : LongInt;

begin
  inherited Create(aFileName,fmOpenRead or fmShareDenyNone, BUFFER_SIZE);
  FieldList := TExtdCollection.create;

  MustFlush := false;

   FillChar( Header, Sizeof( Header ), 0 );
   RefNr       := 0;
   Fields      := 0;

   Get( 0, Header, Sizeof( Header ) );

   Case Header.DBaseVer And DB4DataAndMemo Of
      DBDataOnly :
         DBVer := DBVersion3X;

      DB4DataAndMemo,
      DBDataAndMemo:
         Begin
            If Header.DBaseVer = DB4DataAndMemo Then
               DBVer := DBVersion4X
            else
               DBVer := DBVersion3X;
         End;
   end;

   Fields := ( Header.HeaderSize - ( SizeOf ( DBaseFileFullHeader ) - 1 ) ) Div SizeOf ( DBaseFileField );

   RefNr := 1;

   FieldOfs := 0;
   For i := 0 To Fields Do
   Begin
      P := TDBaseField.Create;
      With P do
      Begin
         If i = 0 Then
         Begin { First Field is Deleted Flag }
            FType       := DelMarkFType;
            Width       := 1;
            Decimals    := 0;
            FieldName   := DelMarkName;
         End
         Else
         Begin

            Position := ( SizeOf ( DBaseFileFullHeader )  ) + ( ( i-1 ) * SizeOf ( DBaseFileField ) );
            Get( Position, DBFBuf, Sizeof ( DBFBuf ) );
            FType := DBFBuf.FType;
            Width := DBFBuf.Width;
            Decimals := DBFBuf.Decimals;

            FieldName := DBFBuf.Name;
         End;
         DetermineCType;
         Offset := FieldOfs;
         Inc ( FieldOfs, Width );
      end;
      FieldList.Insert( P );
   End;

end;

{-------------------------------------------------------}
destructor tDBaseFile.Destroy;
begin
  FieldList.free;
  inherited destroy;
end;

{-------------------------------------------------------}
procedure tDBaseFile.Get(Position: Integer; var B; Size: Word);
begin
   Seek( Position, soFromBeginning);
   Read( B, Size );
end;

{-------------------------------------------------------}
function tDBaseFile.GetField(Name: ShortString; FCType: Byte;
  var DstBuf): Integer;

Var
   F : TDbaseField;
   i: integer;
Begin

   F := nil;
   for i := 0 to pred(FieldList.ItemCount) do
   if TDBaseField(FieldList.Items[i]).FieldName = Name then begin
       F := FieldList.Items[i];
       break;
    end;

   If not Assigned( F ) then Begin GetField := -1; Exit; End;

   With F do
   Case CType Of
      BooleanCType   :  If FType = DelMarkFType Then
                        Begin
                           If Char ( RecInfo[Offset] ) = ' ' Then
                              Boolean ( DstBuf ) := FALSE
                           else
                              Boolean ( DstBuf ) := TRUE;
                           GetField := 0;
                        End
                        Else
                           GetField := Char2Boolean ( Boolean ( DstBuf ), Char ( RecInfo[Offset] ) );

      StringCType    :  GetField := CArr2LBStr ( ShortString(DstBuf), @RecInfo[Offset], Width );

      CharCType    :    Begin
                           Char (DstBuf) := Char (RecInfo[Offset]);
                           GetField := 0;
                        End;

      SingleCType :     GetField := CArr2Single ( Single ( DstBuf ), @RecInfo[Offset], Width );


      Else
        GetField := -1;
   end; { of Case }
end;

{-------------------------------------------------------}
procedure tDBaseFile.GotoRecord(Ref: Integer);
var
  position : integer;
begin
   RefNr := Ref;
   Position := Header.HeaderSize + ( RefNr - 1 ) * Longint ( Header.RecordSize );
   FillChar( RecInfo, Sizeof( RecInfo ), 0 );
   Get( Position, RecInfo, Header.RecordSize );
end;

{-------------------------------------------------------}
{-------------------------------------------------------}
end.
