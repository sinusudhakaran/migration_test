{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10827: ad3CustomDictionary.pas 
{
{   Rev 1.5    1/27/2005 2:14:16 AM  mnovak
}
{
{   Rev 1.4    20/12/2004 3:24:08 pm  Glenn
}
{
{   Rev 1.3    2/21/2004 11:59:38 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.2    1/11/2004 11:28:32 PM  mnovak
{ Fix word removal issue (if huge numbers of words are removed from the
{ dictionary, an infinite loop could have resulted)
}
{
{   Rev 1.1    12/3/2003 1:03:24 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:38 AM  mnovak
}
{
{   Rev 1.2    7/30/2002 12:07:12 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.1    7/6/2002 11:42:14 PM  mnovak
{ Fixed RemoveAll Exception
{ (Setting Capacity of a list to 0)
}
{
{   Rev 1.0    6/23/2002 11:55:26 PM  mnovak
}
{
{   Rev 1.0    6/17/2002 1:34:18 AM  Supervisor
}
(*************************************************************

Addict 3.4,  (c) 1996-2005, Addictive Software
Contact: addictsw@addictivesoftware.com

Dictionary class for reading AddictX custom dictionaries

History:
7/30/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3CustomDictionary;

{$I addict3.inc}

interface

uses
    windows,
    sysutils,
    classes,
    ad3util;

type
    //************************************************************
    // Custom Dictionary Class
    //************************************************************

    TCustomDictionary = class(TObject)
    protected

        FFilename           :String;
        FLoaded             :Boolean;
        FModified           :Boolean;
        FIgnoreCount        :LongInt;
        FExcludeCount       :LongInt;
        FAutoCorrectCount   :LongInt;

        FFileTime           :Integer;
        FWordCount          :LongInt;

        FAllocated          :LongInt;
        FUsed               :LongInt;
        FWords              :PChar;

        FUpperBound         :LongInt;
        FHashTable          :TList;

        FIndexLists         :Boolean;
        FIgnoreList         :TList;
        FExcludeList        :TList;
        FAutoCorrectList    :TList;

        FTrackOps                   :Boolean;
        FRemovedIgnore              :TStringList;
        FRemovedExclude             :TStringList;
        FRemovedAutoCorrect         :TStringList;
        FAddedIgnore                :TStringList;
        FAddedExclude               :TStringList;
        FAddedAutoCorrect           :TStringList;
        FAddedAutoCorrectReplace    :TStringList;

    protected

        procedure WriteFilename( const Filename:String ); virtual;
        procedure WriteLoaded( Loaded:Boolean ); virtual;
        function ReadIgnoreCount:LongInt; virtual;
        function ReadExcludeCount:LongInt; virtual;
        function ReadAutoCorrectCount:LongInt; virtual;

        function IsCustomDictionary( const Filename:String; ReturnHandle:Boolean; var FileHandle:THandle ):Boolean; virtual;
        procedure LoadDictionary( FileHandle:THandle ); virtual;
        procedure SaveDictionary( const Filename:String ); virtual;

        procedure AddToIndexList( ch:Char; StreamPosition:LongInt ); virtual;
        procedure SetupIndexLists; virtual;

        function StringFromStreamPos( StreamPos:LongInt ):String; virtual;
        function FindWord( chPrefix:Char; Word:String; var Hash:LongInt; var Position:LongInt ):Boolean; virtual;

        procedure AppendBuffer( Buffer:PChar; WriteLen:LongInt ); virtual;
        procedure InternalHash( var Hash:TList; Word:PChar; Offset:LongInt ); virtual;
        procedure AddHash( const Word:String; Position:LongInt ); virtual;
        function AddWord( chPrefix:Char; const Word:String; const Secondary:String ):Boolean; virtual;
        function RemoveWord( chPrefix:Char; Word:PChar ):Boolean; virtual;

        function CreateInstance:TCustomDictionary; virtual;

    public
        {$IFNDEF T2H}
        constructor Create;
        destructor Destroy; override;
        {$ENDIF}

        procedure Save(); virtual;
        procedure SaveAs( const NewFilename:String ); virtual;

        function GetIgnoreWord( Index:DWORD ):String; virtual;
        function GetExcludeWord( Index:DWORD ):String; virtual;
        function GetAutoCorrectWord( Index:DWORD; var Correction:String ):String; virtual;

        function IgnoreExists( const Word:String ):Boolean; virtual;
        function ExcludeExists( const Word:String ):Boolean; virtual;
        function AutoCorrectExists( const Word:String; var Correction:String ):Boolean; virtual;

        function AddIgnore( const Word:String ):Boolean; virtual;
        function AddExclude( const Word:String ):Boolean; virtual;
        function AddAutoCorrect( const Misspelled:String; const Correction:String ):Boolean; virtual;

        function RemoveIgnore( const Word:String ):Boolean; virtual;
        function RemoveExclude( const Word:String ):Boolean; virtual;
        function RemoveAutoCorrect( const Misspelled:String ):Boolean; virtual;
        procedure RemoveAll; virtual;

        property Filename:String read FFilename write WriteFilename;
        property Loaded:Boolean read FLoaded write WriteLoaded;
        property Modified:Boolean read FModified write FModified;
        property IgnoreCount:LongInt read ReadIgnoreCount;
        property ExcludeCount:LongInt read ReadExcludeCount;
        property AutoCorrectCount:LongInt read ReadAutoCorrectCount;
    end;

implementation

const
    HeaderString            = 'Addict User Dictionary, Version 4.0' + #13#10 +
                              '(c) 1995-2000 Addictive Software' + #13#10 +
                              'http://www.addictive.net/' + #13#10 +
                              'addictsw@kagi.com' + #13#10#13#10;
    HeaderStringSize        = 120;

    AllocationSize          = $FFFF;
    ExpectedSessionAdd      = 256;
    EOFChar                 = $1A;

    WildChar                = '*';
    IgnoreChar              = 'I';
    ExcludeChar             = 'E';
    AutoCorrectChar         = 'A';


//************************************************************
// Custom Dictionary Class
//************************************************************

constructor TCustomDictionary.Create;
begin
    inherited Create;

    FFilename           := '';
    FLoaded             := False;
    FModified           := False;
    FIgnoreCount        := 0;
    FExcludeCount       := 0;
    FAutoCorrectCount   := 0;

    FFileTime           := 0;
    FWordCount          := 0;

    FAllocated          := 0;
    FUsed               := 0;
    FWords              := nil;

    FUpperBound         := 0;
    FHashTable          := TList.Create;

    FIndexLists         := False;
    FIgnoreList         := TList.Create;
    FExcludeList        := TList.Create;
    FAutoCorrectList    := TList.Create;

    FTrackOps                   := False;
    FRemovedIgnore              := TStringList.Create;
    FRemovedExclude             := TStringList.Create;
    FRemovedAutoCorrect         := TStringList.Create;
    FAddedIgnore                := TStringList.Create;
    FAddedExclude               := TStringList.Create;
    FAddedAutoCorrect           := TStringList.Create;
    FAddedAutoCorrectReplace    := TStringList.Create;
end;

//************************************************************

destructor TCustomDictionary.destroy;
begin
    WriteLoaded( False );

    FHashTable.Free;

    FIgnoreList.Free;
    FExcludeList.Free;
    FAutoCorrectList.Free;

    FRemovedIgnore.Free;
    FRemovedExclude.Free;
    FRemovedAutoCorrect.Free;
    FAddedIgnore.Free;
    FAddedExclude.Free;
    FAddedAutoCorrect.Free;
    FAddedAutoCorrectReplace.Free;

    inherited destroy;
end;



//************************************************************
// Property Read/Write Functions
//************************************************************

procedure TCustomDictionary.WriteFilename( const Filename:String );
var
    WasLoaded   :Boolean;
    FileHandle  :THandle;
begin
    if (not IsCustomDictionary( Filename, False, FileHandle )) then
    begin
        exit;
    end;

    WasLoaded   := Loaded;
    Loaded      := False;

    FFilename   := Filename;
    FTrackOps   := (FFilename <> '');

    Loaded      := WasLoaded;
end;

//************************************************************

procedure TCustomDictionary.WriteLoaded( Loaded:Boolean );
var
    FileHandle  :THandle;
begin
    if (Loaded = FLoaded) then
    begin
        exit;
    end;

    FLoaded := Loaded;

    if (FLoaded) then
    begin
        // In memory dictionary ?

        if (Filename = '') then
        begin
            exit;
        end;

        if (IsCustomDictionary( Filename, true, FileHandle )) then
        begin
            if (FileHandle <> INVALID_HANDLE_VALUE) then
            begin
                // The dictionary was found...

                FFileTime := FileGetDate( FileHandle );
                LoadDictionary( FileHandle );
                CloseHandle( FileHandle );
            end
            else
            begin
                // this means that the dictionary hasn't been written
                // yet.. we set the modified flag to trigger a write (even
                // if they don't add any words to it...

                FFileTime := 0;
                FModified := True;
            end;
        end
        else
        begin
            WriteLoaded( False );
            exit;
        end;
    end
    else
    begin

        if (FModified) then
        begin
            Save();
        end;

        FModified           := False;

        FIgnoreCount        := 0;
        FExcludeCount       := 0;
        FAutoCorrectCount   := 0;

        FWordCount          := 0;

        FAllocated          := 0;
        FUsed               := 0;

        if (FWords <> nil) then
        begin
            FreeMem( FWords );
            FWords := nil;
        end;

        FUpperBound         := 0;
        FHashTable.Clear;

        FIndexLists         := False;

        FIgnoreList.Clear;
        FExcludeList.Clear;
        FAutoCorrectList.Clear;

        FRemovedIgnore.Clear;
        FRemovedExclude.Clear;
        FRemovedAutoCorrect.Clear;
        FAddedIgnore.Clear;
        FAddedExclude.Clear;
        FAddedAutoCorrect.Clear;
        FAddedAutoCorrectReplace.Clear;
    end;
end;

//************************************************************

function TCustomDictionary.ReadIgnoreCount:LongInt;
begin
    SetupIndexLists;
    Result := FIgnoreList.Count;
end;

//************************************************************

function TCustomDictionary.ReadExcludeCount:LongInt;
begin
    SetupIndexLists;
    Result := FExcludeList.Count;
end;

//************************************************************

function TCustomDictionary.ReadAutoCorrectCount:LongInt;
begin
    SetupIndexLists;
    Result := FAutoCorrectList.Count;
end;




//************************************************************
// Utility Functions
//************************************************************

function TCustomDictionary.IsCustomDictionary( const Filename:String; ReturnHandle:Boolean; var FileHandle:THandle ):Boolean;
var
    FileHeader      :Array[0..HeaderStringSize + 1] of Char;
    BytesRead       :DWORD;
begin
    Result      := False;
    FileHandle  := CreateFile( PChar(Filename), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0 );
    if (INVALID_HANDLE_VALUE = FileHandle) then
    begin
        // if we failed, then no big deal... just assume its a new file,
        // rather than a previously existing file (if we can create it....

        if ( (Filename = '') or (CanFileBeWritten(Filename,true)) ) then
        begin
            Result := True;
        end;
        exit;
    end;

    ReadFile( FileHandle, FileHeader, HeaderStringSize + 1, BytesRead, nil );

    if (not CompareMem( PChar(HeaderString), @FileHeader, HeaderStringSize )) then
    begin
        CloseHandle( FileHandle );
        exit;
    end;

    Result := True;
    if (not ReturnHandle) then
    begin
        CloseHandle( FileHandle );
        FileHandle := INVALID_HANDLE_VALUE;
    end;
end;

//************************************************************

procedure TCustomDictionary.LoadDictionary( FileHandle:THandle );
var
    BytesRead       :DWORD;
begin
    try
        // read the basic word count information...

        ReadFile( FileHandle, FIgnoreCount, SizeOf(FIgnoreCount), BytesRead, nil );
        ReadFile( FileHandle, FExcludeCount, SizeOf(FExcludeCount), BytesRead, nil );
        ReadFile( FileHandle, FAutoCorrectCount, SizeOf(FAutoCorrectCount), BytesRead, nil );
        ReadFile( FileHandle, FWordCount, SizeOf(FWordCount), BytesRead, nil );

        // read the actual hash table into memory...

        ReadFile( FileHandle, FUpperBound, SizeOf(FUpperBound), BytesRead, nil );

        FHashTable.Capacity := FUpperBound;
        FHashTable.Count    := FUpperBound;
        if (FUpperBound > 0) then
        begin
            ReadFile( FileHandle, (FHashTable.List)^, SizeOf(LongInt) * FUpperBound, BytesRead, nil );
        end;

        // read the list of words into memory...

        ReadFile( FileHandle, FUsed, SizeOf(FUsed), BytesRead, nil );

        FAllocated := ((FUsed div AllocationSize) + 1) * AllocationSize;
        ReallocMem( FWords, FAllocated );

        ReadFile( FileHandle, FWords^, FUsed, BytesRead, nil );
    except

        if (FWords <> nil) then
        begin
            FreeMem( FWords );
            FWords              := nil;
        end;
        FUsed               := 0;
        FAllocated          := 0;
        FIgnoreCount        := 0;
        FExcludeCount       := 0;
        FAutoCorrectCount   := 0;
        FWordCount          := 0;
        FHashTable.Clear;
    end;
end;

//************************************************************

procedure TCustomDictionary.SaveDictionary( const Filename:String );
var
    BytesWritten    :DWORD;
    FileHandle      :THandle;
    Header          :String;
    BWrite          :Byte;
begin
    FileHandle  := CreateFile( PChar(Filename), GENERIC_WRITE, FILE_SHARE_READ, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0 );
    if (FileHandle = INVALID_HANDLE_VALUE) then
    begin
        BytesWritten := GetLastError;
        exit;
    end;

    try
        // Write the header

        Header  := HeaderString;
        WriteFile( FileHandle, PChar(Header)^, HeaderStringSize, BytesWritten, nil );
        BWrite  := EOFChar;
        WriteFile( FileHandle, BWrite, sizeof(BWrite), BytesWritten, nil );
        WriteFile( FileHandle, FIgnoreCount, sizeof(FIgnoreCount), BytesWritten, nil );
        WriteFile( FileHandle, FExcludeCount, sizeof(FExcludeCount), BytesWritten, nil );
        WriteFile( FileHandle, FAutoCorrectCount, sizeof(FAutoCorrectCount), BytesWritten, nil );
        WriteFile( FileHandle, FWordCount, sizeof(FWordCount), BytesWritten, nil );

        // Write the hash table

        WriteFile( FileHandle, FUpperBound, sizeof(FUpperBound), BytesWritten, nil );
        if (FUpperBound > 0) then
        begin
            WriteFile( FileHandle, (FHashTable.List)^, SizeOf(LongInt) * FUpperBound, BytesWritten, nil );
        end;

        // Write the list of words into memory

        WriteFile( FileHandle, FUsed, sizeof(FUsed), BytesWritten, nil );
        WriteFile( FileHandle, FWords^, FUsed, BytesWritten, nil );
    finally

        CloseHandle( FileHandle );
    end;
end;

//***************************************************************************

procedure TCustomDictionary.AddToIndexList( ch:Char; StreamPosition:LongInt );
begin
    case (ch) of
    IgnoreChar:
        FIgnoreList.Add( Pointer(StreamPosition) );
    ExcludeChar:
        FExcludeList.Add( Pointer(StreamPosition) );
    AutoCorrectChar:
        FAutoCorrectList.Add( Pointer(StreamPosition) );
    end;
end;

//***************************************************************************

procedure TCustomDictionary.SetupIndexLists;
var
    Index   :LongInt;
begin
    if (FIndexLists) then
    begin
        exit;
    end;

    if (not FLoaded) then
    begin
        Loaded := True;
    end;

    FIgnoreList.Clear;
    FExcludeList.Clear;
    FAutoCorrectList.Clear;

    // pre-allocate the arrays for the size we think they'll end up
    // being..... plus a little bit of leeway for added words

    FIgnoreList.Capacity        := FIgnoreCount + ExpectedSessionAdd;
    FExcludeList.Capacity       := FExcludeCount + ExpectedSessionAdd;
    FAutoCorrectList.Capacity   := FAutoCorrectCount + ExpectedSessionAdd;

    // here we walk the hash table and based upon the entry kind
    // add it to the appropriate list.

    for Index := 0 to FUpperBound - 1 do
    begin
        // if we have an entry with a word in it...

        if (LongInt(FHashTable[Index]) > 0) then
        begin
            // then add it to the appropriate list...

            AddToIndexList( Char((BYTEAdd( PByte(FWords), LongInt(FHashTable[Index]) - 1 ))^), LongInt(FHashTable[Index]) );
        end;
    end;

    FIndexLists := True;
end;

//************************************************************

function TCustomDictionary.StringFromStreamPos( StreamPos:LongInt ):String;
var
    Word    :PChar;
    Length  :LongInt;
begin
    Word    := PChar(BYTEAdd( PByte(FWords), StreamPos ));
    Length  := lstrlenA( Word );
    Result  := Copy( Word, 0, Length );
end;

//************************************************************

function TCustomDictionary.FindWord( chPrefix:Char; Word:String; var Hash:LongInt; var Position:LongInt ):Boolean;
var
    Secondary   :LongInt;
    Looks       :LongInt;
    NewHash     :TList;
    Index       :LongInt;
begin
    if (not FLoaded) then
    begin
        Loaded := True;
    end;

    if (FUpperBound <= 0) then
    begin
        Result := False;
        exit;
    end;

    Hash            := HashString( PChar(Word), FUpperBound );
    Secondary       := SecondaryHash( Hash );
    Looks           := 0;

    repeat
        Position    := LongInt(FHashTable[Hash]);

        if (Position = 0) then
        begin
            Result := False;
            exit;
        end;

        if (Position > 0) then
        begin
            if (StringFromStreamPos( Position ) = Word) then
            begin
                if (chPrefix = WildChar) then
                begin
                    Result := True;
                end
                else
                begin
                    Result := (Char((BYTEAdd( PByte(FWords), Position - 1 ))^) = chPrefix);
                end;
                exit;
            end;
        end;

        Hash := (Hash + Secondary) mod FHashTable.Capacity;

        if ((Looks > FHashTable.Capacity) and (Looks > 0)) then
        begin
            // We've went through the entire hash table... this essentially
            // means that our index has been so dilluted with removed words that
            // there is no longer an 'escape' zero and we MUST re-index or we'll
            // be stuck in an infinite loop...

            // The hash table must now be completely re-hashed to grow to the
            // new size.

            NewHash := TList.Create;
            try
                NewHash.Capacity    := FUpperBound;
                NewHash.Count       := FUpperBound;

                for Index := 0 to FHashTable.Capacity - 1 do
                begin
                    if (LongInt(FHashTable[Index]) > 0) then
                    begin
                        InternalHash( NewHash, PChar(BYTEAdd(PByte(FWords),LongInt(FHashTable[Index]))), LongInt(FHashTable[Index]) );
                    end;
                end;

                FHashTable.Free;
                FHashTable := NewHash;

                FIndexLists  := false;
            except
                NewHash.Free;
            end;

            break;
        end;
        inc(Looks);

    until (false);

    Result := False;
end;

//************************************************************

procedure TCustomDictionary.AppendBuffer( Buffer:PChar; WriteLen:LongInt );
begin
    if (FAllocated - FUsed <= WriteLen) then
    begin
        ReallocMem( FWords, FAllocated + AllocationSize );
        FAllocated := FAllocated + AllocationSize;
    end;
    CopyMemory( BYTEAdd(PByte(FWords),FUsed), Buffer, WriteLen );
    FUsed := FUsed + WriteLen;
end;

//************************************************************

procedure TCustomDictionary.InternalHash( var Hash:TList; Word:PChar; Offset:LongInt );
var
    HashVal     :LongInt;
    Secondary   :LongInt;
begin
    HashVal     := HashString( Word, Hash.Capacity );

    if (LongInt(Hash[HashVal]) > 0) then
    begin
        // must use secondary hash to find the location

        Secondary := SecondaryHash( HashVal );

        repeat
            HashVal := (HashVal + Secondary) mod Hash.Capacity;
        until (LongInt(Hash[HashVal]) = 0);
    end;

    Hash[HashVal] := Pointer(Offset);
end;

//***************************************************************************

procedure TCustomDictionary.AddHash( const Word:String; Position:LongInt );
var
    NewHash     :TList;
    Bound       :DWORD;
    Index       :LongInt;
begin
    if ((FWordCount shl 2) >= FUpperBound) then
    begin
        // The hash table must now be completely re-hashed to grow to the
        // new size.

        NewHash := TList.Create;
        try
            Bound               := GetNextPrime( FUpperBound );
            NewHash.Capacity    := Bound;
            NewHash.Count       := Bound;
            FUpperBound         := Bound;

            for Index := 0 to FHashTable.Capacity - 1 do
            begin
                if (LongInt(FHashTable[Index]) > 0) then
                begin
                    InternalHash( NewHash, PChar(BYTEAdd(PByte(FWords),LongInt(FHashTable[Index]))), LongInt(FHashTable[Index]) );
                end;
            end;

            FHashTable.Free;
            FHashTable := NewHash;

            FIndexLists  := false;
        except
            NewHash.Free;
        end;
    end;

    if (FHashTable.Capacity > 0) then
    begin
        InternalHash( FHashTable, PChar(Word), Position );
    end;
end;

//***************************************************************************

function TCustomDictionary.AddWord( chPrefix:Char; const Word:String; const Secondary:String ):Boolean;
var
    Hash            :Integer;
    Position        :Integer;
    Addition        :Array[0..512] of Char;
    AdditionLen     :Integer;
    WordLen         :Integer;
    SecondaryLen    :Integer;
    Location        :LongInt;
begin
    if (not FLoaded) then
    begin
        Loaded := True;
    end;

    WordLen         := Length(Word);
    SecondaryLen    := Length(Secondary);

    if (WordLen + SecondaryLen > 500) then
    begin
        Result := False;
        exit;
    end;

    Addition[0] := chPrefix;
    CopyMemory( BYTEAdd(@Addition,1), PChar(Word), WordLen );
    Addition[ WordLen + 1 ] := #0;
    AdditionLen := WordLen + 2;

    if (chPrefix = AutoCorrectChar) then
    begin
        CopyMemory( BYTEAdd(@Addition,AdditionLen), PChar(Secondary), SecondaryLen );
        Addition[ AdditionLen + SecondaryLen ] := #0;
        AdditionLen := AdditionLen + SecondaryLen + 1;
    end;

    if (FindWord( WildChar, Word, Hash, Position )) or (Word = '') then
    begin
        Result := False;
        Exit;
    end;

    Location := FUsed + 1;
    AppendBuffer( @Addition, AdditionLen );
    inc( FWordCount );
    AddHash( Word, Location );

    if (FIndexLists) then
    begin
        AddToIndexList( chPrefix, Location );
    end;
    Result := True;
end;

//***************************************************************************

function TCustomDictionary.RemoveWord( chPrefix:Char; Word:PChar ):Boolean;
var
    Hash        :LongInt;
    Position    :LongInt;
begin
    if (not FindWord( chPrefix, Word, Hash, Position )) then
    begin
        Result := False;
        exit;
    end;

    FIndexLists := False;

    // Forget about the word in the stream at the previous position.
    // We do not delete words from the stream, but merely from the
    // hash table.... (don't go deleting tons of things :)

    FHashTable[Hash] := Pointer(-1);

    // we have one less word to worry about

    dec(FWordCount);
    Result := True;
end;

//************************************************************

function TCustomDictionary.CreateInstance:TCustomDictionary;
begin
    Result := TCustomDictionary.Create;
end;



//************************************************************
// Public API Functions
//************************************************************

procedure TCustomDictionary.Save();
var
    FileHandle          :THandle;
    FileTime            :Integer;
    CustomDictionary    :TCustomDictionary;
    Loop                :LongInt;
begin
    if (FModified) and (FFileName <> '') and (IsCustomDictionary(FFileName, True, FileHandle)) then
    begin
        if (FileHandle <> INVALID_HANDLE_VALUE) then
        begin
            FileTime := FileGetDate(FileHandle);
            CloseHandle( FileHandle );
        end
        else
        begin
            FileTime    := FFileTime;
        end;

        if (FFileTime <> FileTime) then
        begin
            // OK, the file has been updated since we read it in...
            // We need to merge our changes into the dictionary.

            CustomDictionary := CreateInstance;
            try
                CustomDictionary.Filename := FFilename;
                CustomDictionary.Loaded   := True;

                for Loop := 0 to FAddedIgnore.Count - 1 do
                begin
                    CustomDictionary.AddIgnore( FAddedIgnore[Loop] );
                end;
                for Loop := 0 to FAddedExclude.Count - 1 do
                begin
                    CustomDictionary.AddExclude( FAddedExclude[Loop] );
                end;
                for Loop := 0 to FAddedAutoCorrect.Count - 1 do
                begin
                    CustomDictionary.AddAutoCorrect( FAddedAutoCorrect[Loop], FAddedAutoCorrectReplace[Loop] );
                end;

                for Loop := 0 to FRemovedIgnore.Count - 1 do
                begin
                    CustomDictionary.RemoveIgnore( FRemovedIgnore[Loop] );
                end;
                for Loop := 0 to FRemovedExclude.Count - 1 do
                begin
                    CustomDictionary.RemoveExclude( FRemovedExclude[Loop] );
                end;
                for Loop := 0 to FRemovedAutoCorrect.Count - 1 do
                begin
                    CustomDictionary.RemoveAutoCorrect( FRemovedAutoCorrect[Loop] );
                end;

                CustomDictionary.Save;

            finally
                CustomDictionary.Free;
            end;

        end
        else
        begin
            SaveDictionary( FFileName );
        end;
    end;

    FModified := False;

    FRemovedIgnore.Clear;
    FRemovedExclude.Clear;
    FRemovedAutoCorrect.Clear;
    FAddedIgnore.Clear;
    FAddedExclude.Clear;
    FAddedAutoCorrect.Clear;
    FAddedAutoCorrectReplace.Clear;
end;

//************************************************************

procedure TCustomDictionary.SaveAs( const NewFilename:String );
begin
    if (not FLoaded) then
    begin
        Loaded := True;
    end;
    SaveDictionary( NewFilename );
end;

//************************************************************

function TCustomDictionary.GetIgnoreWord( Index:DWORD ):String;
begin
    SetupIndexLists;

    Result := '';
    if (LongInt(Index) < FIgnoreList.Count) then
    begin
        Result := StringFromStreamPos( LongInt(FIgnoreList[Index]) );
    end;
end;

//************************************************************

function TCustomDictionary.GetExcludeWord( Index:DWORD ):String;
begin
    SetupIndexLists;

    Result := '';
    if (LongInt(Index) < FExcludeList.Count) then
    begin
        Result := StringFromStreamPos( LongInt(FExcludeList[Index]) );
    end;
end;

//************************************************************

function TCustomDictionary.GetAutoCorrectWord( Index:DWORD; var Correction:String ):String;
var
    Pos     :LongInt;
begin
    SetupIndexLists;

    Result      := '';
    Correction  := '';
    if (LongInt(Index) < FAutoCorrectList.Count) then
    begin
        Result      := StringFromStreamPos( LongInt(FAutoCorrectList[Index]) );
        Pos         := LongInt(FAutoCorrectList[Index]) + Length(Result) + 1;
        Correction  := StringFromStreamPos( Pos );
    end;
end;

//************************************************************

function TCustomDictionary.IgnoreExists( const Word:String ):Boolean;
var
    Hash        :Integer;
    Position    :Integer;
begin
    Result := FindWord( IgnoreChar, Word, Hash, Position );
end;

//************************************************************

function TCustomDictionary.ExcludeExists( const Word:String ):Boolean;
var
    Hash        :Integer;
    Position    :Integer;
begin
    Result := FindWord( ExcludeChar, Word, Hash, Position );
end;

//************************************************************

function TCustomDictionary.AutoCorrectExists( const Word:String; var Correction:String ):Boolean;
var
    Hash        :Integer;
    Position    :Integer;
begin
    Result      := FindWord( AutoCorrectChar, Word, Hash, Position );
    if (Result) then
    begin
        Correction  := StringFromStreamPos( Position + Length(Word) + 1 );
    end;
end;

//************************************************************

function TCustomDictionary.AddIgnore( const Word:String ):Boolean;
begin
    Result := False;
    if (AddWord( IgnoreChar, Word, '' )) then
    begin
        if (FTrackOps) then
        begin
            FAddedIgnore.Add( Word );
        end;
        FModified := True;
        inc( FIgnoreCount );
        Result := True;
    end;
end;

//************************************************************

function TCustomDictionary.AddExclude( const Word:String ):Boolean;
begin
    Result := False;
    if (AddWord( ExcludeChar, Word, '' )) then
    begin
        if (FTrackOps) then
        begin
            FAddedExclude.Add( Word );
        end;
        FModified := True;
        inc( FExcludeCount );
        Result := True;
    end;
end;

//************************************************************

function TCustomDictionary.AddAutoCorrect( const Misspelled:String; const Correction:String ):Boolean;
begin
    Result := False;
    if (AddWord( AutoCorrectChar, Misspelled, Correction )) then
    begin
        if (FTrackOps) then
        begin
            FAddedAutoCorrect.Add( Misspelled );
            FAddedAutoCorrectReplace.Add( Correction );
        end;
        FModified := True;
        inc( FAutoCorrectCount );
        Result := True;
    end;
end;

//************************************************************

function TCustomDictionary.RemoveIgnore( const Word:String ):Boolean;
begin
    Result := False;
    if (RemoveWord( IgnoreChar, PChar(Word) )) then
    begin
        if (FTrackOps) then
        begin
            FRemovedIgnore.Add( Word );
        end;
        FModified := True;
        dec( FIgnoreCount );
        Result := True;
    end;
end;

//************************************************************

function TCustomDictionary.RemoveExclude( const Word:String ):Boolean;
begin
    Result := False;
    if (RemoveWord( ExcludeChar, PChar(Word) )) then
    begin
        if (FTrackOps) then
        begin
            FRemovedExclude.Add( Word );
        end;
        FModified := True;
        dec( FExcludeCount );
        Result := True;
    end;
end;

//************************************************************

function TCustomDictionary.RemoveAutoCorrect( const Misspelled:String ):Boolean;
begin
    Result := False;
    if (RemoveWord( AutoCorrectChar, PChar(Misspelled) )) then
    begin
        if (FTrackOps) then
        begin
            FRemovedAutoCorrect.Add( Misspelled );
        end;
        FModified := True;
        dec( FAutoCorrectCount );
        Result := True;
    end;
end;

//************************************************************

procedure TCustomDictionary.RemoveAll;
begin
    if (not FLoaded) then
    begin
        Loaded := True;
    end;

    FIgnoreCount        := 0;
    FExcludeCount       := 0;
    FAutoCorrectCount   := 0;
    FWordCount          := 0;

    FUpperBound         := 0;
    FHashTable.Clear;

    FAllocated          := 0;
    ReallocMem( FWords, FAllocated );

    FIndexLists         := False;

    FIgnoreList.Clear;
    FExcludeList.Clear;
    FAutoCorrectList.Clear;

    FRemovedIgnore.Clear;
    FRemovedExclude.Clear;
    FRemovedAutoCorrect.Clear;
    FAddedIgnore.Clear;
    FAddedExclude.Clear;
    FAddedAutoCorrect.Clear;
    FAddedAutoCorrectReplace.Clear;
end;



end.

