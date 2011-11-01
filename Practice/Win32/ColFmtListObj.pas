unit ColFmtListObj;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// List Object holding Column format definitions and useful methods
// This object is used by the Coding, Dissection and Journal forms to
// keep details of table columns.
// It is setup in the form.  Column postion and width can be read from and
// written to the INI file.
// The Dissection and Journal forms have two edit modes.  In the restricted
// mode only two columns are avaialbe.  In the general mode all columns are
// available.  The object stores two edit flags with each column.  The flag tested
// to determine whether the column is editable is set by the EditMode.
// In the Coding Form restricted editing gives access to the Account column only.
// This special case is handled in the form and the Restricted mode is not used
//
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   ECollect, OvcTCell, SysUtils, IniFiles, Classes, StStrL;

type
   TDirection = (diLeft, diRight);
   TEditMode  = (emRestrict, emGeneral);

type
   TColumnDefn = record
     cdFieldID      : integer;
     cdHeading      : string[30];
     cdDescriptiveName : string[ 60];
     cdWidth        : integer;
     cdTableCell    : TOvcBaseTableCell;
     cdDefEditMode  : Array[ TEditMode ] of boolean; //Save default edit modes for restore columns
     cdEditMode     : Array[ TEditMode ] of boolean; //Two Edit Modes - Restricted and General
     cdSortOrder    : integer;      //sort order to use when col displaying
                                    //this field is clicked
     cdRequiredPosition : integer;  //required position for this column when a reorder is done
     cdDefPosition  : integer;      //default position - note list index gives actual position
     cdDefWidth     : integer;      //default width
     cdDefHidden    : boolean;      //default hidden state
     cdHidden       : boolean;      //is the field hidden in the table
   end;
   pColumnDefn = ^TColumnDefn;

type
   TColFmtList = class(TExtdCollection)
   private
      FEditMode : TEditMode;
   protected
      procedure   FreeItem     (Item : Pointer); override;
   public
      function  ColumnDefn_At(Index : integer) : pColumnDefn;
      function  GetColNumOfField(const FieldId: integer): integer;
      function  GetColNumOfHeading(const Heading: String): integer;
      procedure InsColDefnRec(aHeading: string; aFieldID: integer;
                              aCell: TOvcBaseTableCell; aWidth: integer;
                              aVisible : boolean;
                              aEditRestrict, aEditGeneral: boolean;
                              aSortOrder: integer; aDescription : string = '';
                              DefPosition: Integer = -1;
                              DefWidth: Integer = -1;
                              DefHidden: Integer = -1);
      function  SetColEditMode(const aEditMode: TEditMode; const CurrentCol: Integer): Integer;
      function  ColIsEditable( Index : Integer ) : Boolean;
      function  FieldIsEditable( const FieldId: integer) : Boolean;

      function  GetClosestEditCol(const CurrentCol, TargetCol: integer): integer;
      function  GetLeftMostEditCol: integer;
      function  GetNextEditCol(const CurrentCol: integer; const MoveDir: TDirection): integer;
      function  GetRightMostEditCol: integer;
      procedure SetToDefault;
      procedure ReOrder;
      function  SumAdjColumnWidth : Integer;
   property
      EditMode : TEditMode read FEditMode write FEditMode;
   end;

function New_ColumnDefn_Rec : pColumnDefn;

//******************************************************************************
implementation

//uses
//  Globals;

const
   MinWidth            = 5;
   MaxWidth            = 300;

//Record type used to store setting record read from ini file.
//Moved here because it was a nested function and could not be used
//as procedural value.
type
   TIniColumnDefn = record
     ciHeading      : string[30];
     ciPosition     : integer;
   end;
   pIniColumnDefn = ^TIniColumnDefn;

   function IniListSortCompare( pA, pB : Pointer): Integer;
   // Sort Compare function for IniList
   // Compares Positions of A and B
   // Returns -1 if A < B, 0 if A = B, 1 if A > B
   var
      pICD1, pICD2 : pIniColumnDefn;
   begin
      Result := 0; //Default to equal
      pICD1 := pIniColumnDefn( pA );
      pICD2 := pIniColumnDefn( pB );
      if pICD1^.ciPosition < pICD2^.ciPosition then
         Result := -1;
      if pICD1^.ciPosition > pICD2^.ciPosition then
         Result := 1;
   end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TColFmtList.ColumnDefn_At(Index: integer): pColumnDefn;
begin
   result := At(Index);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TColFmtList.FreeItem(Item: Pointer);
begin
   FreeMem( Item, SizeOf( TColumnDefn));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TColFmtList.GetColNumOfField( const FieldId: integer ): integer;
//returns the column index for the column that has this field id
//returns -1 if no column with this id exists
var
   i : integer;
begin
   result := -1;
   for i := 0 to Pred( ItemCount ) do begin
      if ColumnDefn_At(i)^.cdFieldID = FieldId then begin
         result := i;
         break;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TColFmtList.GetColNumOfHeading( const Heading : String ): integer;
var
   i : integer;
begin
   result := -1;
   for i := 0 to Pred( ItemCount ) do begin
      if ColumnDefn_At(i)^.cdHeading = Heading then begin
         result := i;
         break;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TColFmtList.InsColDefnRec(aHeading: string;
                                    aFieldID: integer;
                                    aCell: TOvcBaseTableCell;
                                    aWidth: integer;
                                    aVisible : boolean;
                                    aEditRestrict : boolean;
                                    aEditGeneral  : boolean;
                                    aSortOrder : integer;
                                    aDescription : string = '';
                                    DefPosition: Integer = -1;
                                    DefWidth: Integer = -1;
                                    DefHidden: Integer = -1);
// Insert a new column definition, aDescription is an optional parameter
var
   p : pColumnDefn;
begin
   p := New_ColumnDefn_Rec;
   with p^ do begin
      cdFieldID      := aFieldID;
      cdWidth        := aWidth;
      cdHeading      := aHeading;
      cdTableCell    := aCell;
      cdDefEditMode[ emRestrict ]  := aEditRestrict;
      cdDefEditMode[ emGeneral  ]  := aEditGeneral;
      cdEditMode[ emRestrict ]  := aEditRestrict;
      cdEditMode[ emGeneral  ]  := aEditGeneral;
      cdSortOrder    := aSortOrder;
      if DefPosition = -1 then
        cdDefPosition := Self.ItemCount
      else
        cdDefPosition := DefPosition;
      if DefWidth = -1 then
        cdDefWidth := aWidth
      else
        cdDefWidth := DefWidth;
      cdHidden := not aVisible;
      if DefHidden = 1 then
        cdDefHidden := True
      else if DefHidden = 0 then
        cdDefHidden := False
      else
        cdDefHidden := not aVisible;
      //if no description is given just use the heading
      if aDescription = '' then
         cdDescriptiveName := aHeading
      else
         cdDescriptiveName := aDescription;
   end;
   Self.Insert(p);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TColFmtList.ColIsEditable(Index: Integer): Boolean;
begin
   Result := ColumnDefn_At( Index )^.cdEditMode[ FEditMode ] and ( not ColumnDefn_At( Index)^.cdHidden);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TColFmtList.FieldIsEditable(const FieldId: integer): Boolean;
var
   ColIndex : integer;
begin
   result := false;
   ColIndex := GetColNumOfField( FieldID );
   if ColIndex = -1 then exit;
   result := ColIsEditable( ColIndex);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  TColFmtList.SetColEditMode( const aEditMode : TEditMode; const CurrentCol : Integer ) : Integer;
// Sets the requrested edit mode
// Pass the current column.  Returns the closed editable column
// This may the same as the current column
begin
   FEditMode := aEditMode;
   if ColIsEditable( CurrentCol) then begin
      Result := CurrentCol;
      Exit;
   end;
   Result := GetNextEditCol( CurrentCol, diLeft );
   if Result = -1 then
      Result := GetNextEditCol( CurrentCol, diRight );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TColFmtList.GetNextEditCol( const CurrentCol : integer;
                                     const MoveDir : TDirection ) : integer;
//finds the next editable col starting a the CurrentCol and moving in the
//direction given.  if no col is found in that direction then returns -1
var
   TryCol  : integer;
begin
   TryCol := CurrentCol;
   repeat
      if MoveDir = diLeft then
         Dec(TryCol)
      else
         Inc(TryCol);

      if (TryCol < 0) or (TryCol > Pred(ItemCount)) then begin
         TryCol := -1;
         break;
      end;
   until ColIsEditable( TryCol);
   result := TryCol;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TColFmtList.GetClosestEditCol( const CurrentCol : integer;
                                        const TargetCol : integer) : integer;
//routine assumes curr col editable, will try to find the col which is
//closest to the target col, moves in the direction of the current col
var
   TryCol   : integer;
   Direction : TDirection;
begin
   if (CurrentCol < TargetCol) then
      Direction := diRight
   else
      Direction := diLeft;

   Result := CurrentCol;   
   TryCol := TargetCol;
   while not (ColIsEditable( TryCol)) do begin
      //move to next col
      if Direction = diLeft then begin
         Dec(TryCol);
         if TryCol = -1 then Exit;
      end
      else begin
         Inc(TryCol);
         if TryCol > Pred( ItemCount ) then Exit;
      end;
   end;
   Result := TryCol;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TColFmtList.GetLeftMostEditCol : integer;
//assumes that there is a least one editable col
begin
   Result := 0;
   while not ( ColIsEditable( Result)) do begin
      Inc(result);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TColFmtList.GetRightMostEditCol : integer;
//assumes that there is a least one editable col
begin
   Result := Pred(ItemCount);
   while not ( ColIsEditable( Result)) do begin
      Dec(result);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function ColumnPosCompare( pA, pB : Pointer): Integer;
// Sort Compare function for ColumnPos List
// Compares Positions of A and B
// Returns -1 if A < B, 0 if A = B, 1 if A > B
var
   p1, p2 : pColumnDefn;
begin
   Result := 0; //Default to equal
   p1 := pColumnDefn( pA );
   p2 := pColumnDefn( pB );
   if p1^.cdDefPosition < p2^.cdDefPosition then
      Result := -1;
   if p1^.cdDefPosition > p2^.cdDefPosition then
      Result := 1;
end;


procedure TColFmtList.SetToDefault;
//called to resort the column list by DefaultPosition field
// Before it used cdDefPosition direct, but that means that the number of columns must match
var
   PointerList : TList;
   i           : integer;
begin
   //create pointer list
   PointerList := TList.Create;
   try
      //load pointers into a TList
      for i := 0 to Pred( ItemCount) do begin
         PointerList.Add( ColumnDefn_At(i) );
      end;
      //sort pointers
      PointerList.Sort(ColumnPosCompare);
      //reload into column list
      Self.DeleteAll;
      for i := 0 to Pred( PointerList.Count) do begin
         Self.Insert( pColumnDefn( PointerList.Items[ i]) );
      end;
   finally
      PointerList.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(*
procedure TColFmtList.ReadFromIni( const INIFileName : string; const SectionName : String );
// Read Ini File Section named and load values into an array
// If a line is found with a heading that matches a column heading then
// change the position and width of the column to the Ini Values
// Columns without Ini lines remain in their default positions
// unless the postion conflicts with the Ini position.  In this
// case the Column position is changed to the first non conflicting
// postion.
// Ini line format is Heading=Postion,Width ie Amount=3,100
const
   DelimChar = ',';
var
   IniFile     : TMemIniFile;
   IniSection  : TStringList; //Temp holds Section strings
   IniList     : TList;       //List of Pointers to IniColumnDefs
   pC          : pColumnDefn;
   pICD        : pIniColumnDefn;
   S,V         : String;
   ColNo       : Integer;
   IniPos      : Integer;
   IniWidth    : Integer;
   i           : integer;
begin
   IniFile    := TMemIniFile.Create(INIFILENAME);
   IniSection := TStringList.Create;
   IniList    := TList.Create;
   try
      // Get the Ini Section, decode and put values in list records
      IniFile.ReadSectionValues(SectionName, IniSection );
      with IniSection do begin
         if ( Count = 0 ) then begin
            SetToDefault;
            exit;
         end;
         for i := 0 to Pred(Count) do begin
            //Ignore Ini Lines with bad headings
            ColNo := GetColNumOfHeading( Names[i] );
            if ColNo < 0 then
               Continue;
            // Set pointer to Col Defn
            pC := ColumnDefn_At( ColNo );
            //Get Values for Heading
            V := Values[Names[i]];
            // Ignore if values not Postion,Width
            if WordCountL( V, DelimChar ) <> 2 then
               Continue;
            // Extract position
            S := ExtractWordL(1, V, DelimChar);
            IniPos := StrToIntDef( S, - 1 );
            // Use default if bad position
            if ( IniPos < 0 ) or ( IniPos > Pred( Self.ItemCount ) ) then begin
               IniPos := pC^.cdDefPosition;
            end;
            //Extract Width
            S := ExtractWordL(2, V, DelimChar);
            IniWidth := StrToIntDef( S, - 1 );
            // Use default if bad width
            if ( IniWidth < MinWidth ) or ( IniWidth > MaxWidth ) then
               IniWidth := pC^.cdDefWidth;
            // Set the Column width now
            pC^.cdWidth := IniWidth;
            // Now put values into record
            GetMem( pICD, SizeOf( TIniColumnDefn ) );
            with pICD^ do begin
               ciHeading  := Names[i];
               ciPosition := IniPos;
            end;
            IniList.Add( pICD );
         end;
      end;
      // Now we have a TList pointing to Ini Column Defn recs
      // Sort the List so that we add in correct order
      // See sort function above
      IniList.Sort( IniListSortCompare );

      // Now update self with the new positions and widths
      for i := 0 to Pred( IniList.Count ) do begin
         pICD := pIniColumnDefn( IniList[i] );
         ColNo := GetColNumOfHeading( pICD^.ciHeading );
         pC := ColumnDefn_At( ColNo );
         // Now Delete column pointer from current position and insert at new position
         AtDelete( ColNo );
         AtInsert( pICD^.ciPosition, pC );
      end;
   finally
      IniFile.Free;
      IniSection.Free;
      with IniList do begin
         for i := 0 to Pred( Count ) do begin
            FreeMem( pIniColumnDefn(Items[i]), SizeOf( TIniColumnDefn ) );
         end;
         Free;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TColFmtList.WriteToIni( const INIFileName : string; const SectionName : String );
// Write the
var
   i       : integer;
   S       : string;
begin
   with TMemIniFile.Create(INIFILENAME) do begin
      try
         for i := 0 to Pred(ItemCount) do begin
            with ColumnDefn_At(i)^ do begin
               S := Format('%d,%d', [ i, cdWidth]);
               WriteString(SectionName, cdHeading, S );
            end;
         end;
      finally
         UpdateFile;
         Free;
      end;
   end;
end;
*)
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TColFmtList.SumAdjColumnWidth: Integer;
// Return the sum of the column widths
// Add and extra pixel for each column to handle col lines
var
   i : Integer;
begin
   Result := 0;
   for i := 0 to Pred( Self.ItemCount ) do begin
      Result := Result + ColumnDefn_At( i )^.cdWidth + 1;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function New_ColumnDefn_Rec : pColumnDefn;
var
   p : pColumnDefn;
begin
   GetMem( p, SizeOf( TColumnDefn));
   result := p;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ColumnDefnCompare( pA, pB : Pointer): Integer;
// Sort Compare function for Column Defn List
// Compares Positions of A and B
// Returns -1 if A < B, 0 if A = B, 1 if A > B
var
   p1, p2 : pColumnDefn;
begin
   Result := 0; //Default to equal
   p1 := pColumnDefn( pA );
   p2 := pColumnDefn( pB );
   if p1^.cdRequiredPosition < p2^.cdRequiredPosition then
      Result := -1;
   if p1^.cdRequiredPosition > p2^.cdRequiredPosition then
      Result := 1;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TColFmtList.ReOrder;
//called to resort the column list by cdRequiredPosition field
//A TList is used because it has a sort method
var
   PointerList : TList;
   i           : integer;
begin
   //create pointer list
   PointerList := TList.Create;
   try
      //load pointers into a TList
      for i := 0 to Pred( ItemCount) do begin
         PointerList.Add( ColumnDefn_At(i) );
      end;
      //sort pointers
      PointerList.Sort( ColumnDefnCompare );
      //reload into column list
      Self.DeleteAll;
      for i := 0 to Pred( PointerList.Count) do begin
         Self.Insert( pColumnDefn( PointerList.Items[ i]) );
      end;
   finally
      PointerList.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.


