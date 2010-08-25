unit mmxl32;
//------------------------------------------------------------------------------
{
   Title:       Master Memorisations List

   Description:  Handles load and save of master memorised entries

   Remarks:      Updated Nov 2001 to use a list to store master mem files rather
                 than storing in an array.

   Author:       Matthew, Steve
}
//------------------------------------------------------------------------------

interface
uses
  bkdefs, mxList32, eCollect, mxfiles32, bkconst;
!!
type
  TSystem_Memorised_Transaction_List = Class( TMemorised_Transaction_List )
      symxCode         : BankPrefixStr;
      symxLast_Updated : Int64;
      symxCRC          : LongWord;
      Constructor Create( ACode : BankPrefixStr );
      Destructor  Destroy; Override;
      Procedure   Refresh;
      function    Save : boolean;
   end;

type
   TSystem_Masters = Class( TExtdSortedCollection )
      constructor Create;
      function  Compare(Item1,Item2 : Pointer): Integer; override;
   protected
      procedure FreeItem(Item : Pointer); override;
   public
      Function  System_Memorised_Transaction_List_At( Index : Integer ) : TSystem_Memorised_Transaction_List;
      Function  FindCode( CONST ACode: BankPrefixStr ): TSystem_Memorised_Transaction_List;
   end;

Const
   System_Masters : TSystem_Masters = NIL;

function  ReloadSystemMXList( BankPrefix : BankPrefixStr) : boolean;

//******************************************************************************
implementation
uses
  bk5Except,
  bkmxio,
  LogUtil,
  sysutils,
  stStrs,
  ioStream, crcFileUtils;

const
  UnitName = 'MMXL32';
var
  DebugMe : boolean = false;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Constructor TSystem_Memorised_Transaction_List.Create( ACode : BankPrefixStr );
Begin
   Inherited Create;
   symxCode         := ACode;
   symxLast_Updated := 0;
   symxCRC          := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Destructor TSystem_Memorised_Transaction_List.Destroy;
Begin
   Inherited Destroy;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure TSystem_Memorised_Transaction_List.Refresh;
//reload this master memorisation list
Var
   TimeNow               : Int64;
   MasterFileName        : String;
   pMx                   : pMemorised_Transaction_Rec ;
   f                     : MXFile;
   MX                    : tMemorised_Transaction_Rec;
Begin
   MasterFilename  := mxFiles32.MasterFileName( symxCode);
   if not BKFileExists( MasterFilename) then exit;

   TimeNow := mxFiles32.GetMasterFileTimeStamp( symxCode);
   If TimeNow <> symxLast_Updated then begin
      if DebugMe then LogUtil.LogMsg( lmDebug, Unitname, 'Loading ' + MasterFilename + ' into Master Mem List');
      //lock master file
      if not mxFiles32.LockMasterFile( symxCode) then  Exit;
      try
         //free existing
         FreeAll;
         //load new
         AssignFile(f, MasterFilename);
         Reset(f);
         try
           while not EOF(f) do begin
             Read(f,MX);
             pMX := New_Memorised_Transaction_Rec;
             pMX^ := MX;
             with pMX^ do begin
               mxFrom_Master_List := true;
               mxNext             := nil;
             end; //with
             Insert_Memorised_Transaction_Rec(pMX);
           end; //while
         finally
           CloseFile(f);
         end;
         UpdateLinks;
         symxLast_Updated := GetMasterFileTimeStamp( symxCode);

         if DebugMe then LogUtil.LogMsg( lmDebug, Unitname, 'Load completed successfully');
      finally
         //unlock master file
         mxFiles32.UnlockMasterFile( symxCode);
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TSystem_Memorised_Transaction_List.Save : boolean;
//returns true if lock was obtainable
Var
   MasterFileName : String;
   i              : Integer;
   f              : MXFile;
   MX             : tMemorised_Transaction_Rec;
   pMX            : pMemorised_Transaction_Rec;
Begin
   result := false;
   MasterFilename  := mxFiles32.MasterFileName( symxCode);

   if DebugMe then LogUtil.LogMsg( lmDebug, Unitname, 'Saving ' + MasterFilename + ' from Master Mem List');

   if not mxFiles32.LockMasterFile( symxCode) then
      exit
   else
      result := true;

   //delete the backup file and rename existing to backup name
   DeleteFile( MasterFileBackupName( syMXCode));
   RenameFile( MasterFilename, MasterFileBackupName( syMXCode));

   //now recreate the master file
   AssignFile( f, MasterFileName);
   Rewrite( f);
   try
     for i := 0 to Pred( ItemCount) do begin
       pMX := Memorised_Transaction_At(i);
       MX  := pMX^;
       Write(f,MX);
     end;
   finally
     CloseFile(f);
   end;
   //unlock the file.  This is not inside a try finally because the file
   //should remain locked if something goes wrong
   UnlockMasterFile( syMXCode);
   if DebugMe then LogUtil.LogMsg( lmDebug, Unitname, 'Save completed successfully');
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TSystem_Masters }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TSystem_Masters.Compare(Item1, Item2: Pointer): Integer;
Var
   P1 : TSystem_Memorised_Transaction_List Absolute Item1;
   P2 : TSystem_Memorised_Transaction_List Absolute Item2;
begin
   Result := StStrS.CompStringS( P1.symxCode, P2.symxCode );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TSystem_Masters.Create;
begin
   inherited Create;
   Duplicates := false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TSystem_Masters.FindCode( const ACode: BankPrefixStr ): TSystem_Memorised_Transaction_List;
//searchs the list of master mem list objects to find a list with the specified
//prefix
var
  L, H, I, C: Integer;
  P  : TSystem_Memorised_Transaction_List;
begin
  Result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then exit;

  repeat
    I := (L + H) shr 1;
    P := System_Memorised_Transaction_List_At( i );
    C := STStrS.CompStringS( ACode, P.symxCode );
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);
  if c=0 then Result := P;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TSystem_Masters.FreeItem(Item: Pointer);
var
   P : TSystem_Memorised_Transaction_List;
begin
   P := TSystem_Memorised_Transaction_List( Item );
   P.Free;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TSystem_Masters.System_Memorised_Transaction_List_At( Index: Integer): TSystem_Memorised_Transaction_List;
begin
   Result := TSystem_Memorised_Transaction_List( At( Index ) );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  ReloadSystemMXList( BankPrefix : BankPrefixStr) : boolean;
//returns true if the latest version of the master memorisations for this bank
//prefix have been loaded
//if no list exists for this prefix try to load from file,
//if list does exists then just refresh it
var
   Master_List    : TSystem_Memorised_Transaction_List;
   MasterFilename : string;
begin
   result := false;

   Master_List := System_Masters.FindCode( BankPrefix );
   if not Assigned( Master_List ) then begin
      MasterFilename := mxFiles32.MasterFileName( BankPrefix);

      if BKFileExists( MasterFilename) then begin
         //create a master list entry
         Master_List := TSystem_Memorised_Transaction_List.Create( BankPrefix);
         System_Masters.Insert( Master_List);
         Master_List.Refresh;
         result := true;

         if DebugMe then LogUtil.LogMsg( lmDebug, Unitname, 'Add ' + BankPrefix + ' to Master Mem List');
      end;
   end
   else begin
      Master_List.Refresh;
      result := true;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

initialization
   DebugMe := DebugUnit(UnitName);
   System_Masters := TSystem_Masters.Create;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
finalization
   System_Masters.Free;
   System_Masters := NIL;
end.
