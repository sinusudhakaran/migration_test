unit MRUListUtils;
//------------------------------------------------------------------------------
{
   Title:       MRU List Utilities

   Description: Utilities for managing the list of Most Recently Used files

   Remarks:

   Author:

}
//------------------------------------------------------------------------------

interface
uses
   menus, classes;

procedure DisplayMRU( RootMenu : TMenuItem; MRUStart : TMenuItem; MRUEnd : TMenuItem;
                      OnClick : TNotifyEvent);
procedure AddToMRU( const FileName : ShortString );

//******************************************************************************
implementation
uses
   INISettings,
   SysUtils;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DisplayMRU( RootMenu : TMenuItem; MRUStart : TMenuItem; MRUEnd : TMenuItem;
                      OnClick : TNotifyEvent);
// MRU on File and on ToolBar Open Combo
// MRU List contains Code and Name
var
  i : Integer;
  p : Integer;
  S : String;
  NewItem : TMenuItem;
  MRUFrom, MRU_To : integer;
begin
  // File Menu
  // Clear items below MRUStart
  MRUFrom := RootMenu.IndexOf(MRUStart);
  MRU_To  := RootMenu.IndexOf(MRUEnd);
  for i := MRUFrom+1 to MRU_To-1 do
     RootMenu.Delete(MRUFrom+1);
  MRUStart.visible := false;
  // Add items to menu, assumes values have been shuffled up
  for i := MAX_MRU downto 1 do begin
     if INI_MRUList[i] <> '' then begin
        MRUStart.visible := true;
        NewItem := TMenuItem.Create(RootMenu);
        // Extract Code
        S := INI_MRUList[i];
        p :=  pos( #9, S ) - 1;
        if p <= 0 then
           p := Length( S );
        S := Copy( S, 1, p );
        NewItem.Caption := '&'+inttostr(i)+' '+S;
        NewItem.OnClick := OnClick;
        RootMenu.Insert(MRUFrom+1,NewItem);
     end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddToMRU( const FileName : ShortString );
var
   NewFileNames : array[ 1..MAX_MRU ] of ShortString;
   NewFileCount : Integer;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   procedure AddNewMRUItem( aFilename : string);
   Var
      i     : Integer;
   Begin
      if aFilename = '' then exit;
      if not FileExists( aFilename ) then Exit; // File isn't there
      if ( NewFileCount = MAX_MRU ) then Exit; // List is Full
      for i := 1 to NewFileCount do begin
         if NewFilenames[ i ] = aFilename then Exit; // Already in the list
      end;
      Inc( NewFileCount );
      NewFileNames[ NewFileCount ] := aFilename;
   end;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   i     : Integer;
begin
   // Clear out the new List
   for i := 1 to MAX_MRU do NewFileNames[ i ] := '';
   NewFileCount := 0;
   // Put the new file code and name at the top
   AddNewMRUItem( FileName );
   // Add in the existing INI_MRUList data
   for i := 1 to MAX_MRU do begin
      if INI_MRUList[ i ]<>'' then begin
         AddNewMRUItem( INI_MRUList[i] );
      end;
   end;
   // Put it all back into the INI_MRUList
   for i := 1 to MAX_MRU do INI_MRUList[i] := '';
   for i := 1 to NewFileCount do begin
      INI_MRUList[ i ] := NewFileNames[ i ];
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
