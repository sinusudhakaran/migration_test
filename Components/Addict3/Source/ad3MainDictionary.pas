{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10841: ad3MainDictionary.pas 
{
{   Rev 1.4    1/27/2005 2:14:18 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:18 pm  Glenn
}
{
{   Rev 1.2    2/21/2004 11:59:44 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:32 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:42 AM  mnovak
}
{
{   Rev 1.1    7/30/2002 12:07:12 AM  mnovak
{ Prep for v3.3 release
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

Main dictionary class for reading AddictX dictionaries

History:
7/23/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3MainDictionary;

{$I addict3.inc}

interface

uses
    classes,
    Windows,
    SysUtils,
    ad3Util,
    ad3PhoneticsMap;

{$IFNDEF T2H}
const
    HeaderBufferSize        = 1024;
    CharactersPerNode       = 9;
    MaxPhoneticSuggestions  = 500;
{$ENDIF}

type

    {$IFNDEF T2H}
    PChildLookup = ^TChildLookup;
    TChildLookup = record
        FEndOfWord  :Byte;
        FChildren   :Byte;
        FIndex      :DWORD;
    end;
    {$ENDIF}

    {$IFNDEF T2H}
    TCharSetTable = record
        FChar       :Array[0..255] of DWORD;
    end;
    {$ENDIF}

    //************************************************************
    // Main Dictionary Class
    //************************************************************

    TMainDictionary = class(TObject)
    private
        FWord               :PChar;
        FSuggestions        :TStrings;
        FPhonetics          :TPhoneticsMap;
        FOriginalWord       :String;
        FOriginalMap        :String;
        FOriginalMapLength  :LongInt; 

    private
        procedure InternalPrefixWords( Base:PChar; Current:PChar; NodeIndex:DWORD );
        procedure PerformPrefixWords( Word:PChar );
        function FoundWord:Boolean;
        procedure InternalSuggest( OriginalWord:String; Phonetics:TPhoneticsMap; Suggestions:TStrings );

    protected
        FFilename           :String;
        FLoaded             :Boolean;
        FTitle              :String;
        FLanguage           :DWORD;
        FWordCount          :DWORD;
        FNodeCount          :DWORD;

        FFileHandle         :THandle;
        FMappingHandle      :THandle;
        FPFile              :Pointer;
        FLinkageSize        :DWORD;
        FPLinkage           :PByte;
        FLookup             :Array [0..255] of TChildLookup;
        FNodes              :Array [0..(CharactersPerNode-1)] of PByte;
        FCharSetTable       :TCharSetTable;

        FCompleteHeader     :Array [0..(HeaderBufferSize-1)] of char;
        FCharacterCount     :Array [0..(CharactersPerNode-1)] of DWORD;
        FNodePositionStart  :Array [0..CharactersPerNode] of DWORD;
        FNodeIndexStart     :Array [0..CharactersPerNode] of DWORD;

        FWordsFoundCount    :LongInt;

    protected

        procedure WriteFilename( Filename:String );
        procedure WriteLoaded( Loaded:Boolean );

        function GetNode( Index:DWORD; var Chars:DWORD ):LPDWORD;
        function GetLinkageIndex( var Offset:DWORD ):DWORD;
        function InternalWordExists( Word:PChar; var Length:LongInt ):Boolean;

    public
        {$IFNDEF T2H}
        constructor Create;
        destructor Destroy; override;
        {$ENDIF}

        function WordExists( const Word:String ):Boolean;
        function WordLength( const Word:String ):LongInt;

        procedure Suggest( Word:String; Phonetics:TPhoneticsMap; Suggestions:TStrings );
        procedure WordFound;

        property Filename:String read FFilename write WriteFilename;
        property Loaded:Boolean read FLoaded write WriteLoaded;
        property Title:String read FTitle;
        property Language:DWORD read FLanguage;
        property WordCount:DWORD read FWordCount;
        property NodeCount:DWORD read FNodeCount;

        property WordsFoundCount:LongInt read FWordsFoundCount;
    end;

implementation


const
    HeaderString            = 'Addict Dictionary Compiler, Version 4.0' + #13#10 +
                              '(c) 1995-2000 Addictive Software' + #13#10 +
                              'http://www.addictive.net/' + #13#10 +
                              'addictsw@kagi.com' + #13#10#13#10;
    WRITE_CHAR              = $000000FF;
    WRITE_EOW               = $80000000;
    WRITE_CHILDREN          = $70000000;
    WRITE_CHILDREN_OFFSET   = 28;
    WRITE_INDEX             = $0FFFFF00;
    WRITE_INDEX_OFFSET      = 8;
    WRITE_16BIT_MAX         = $0000FFFF;


//************************************************************
// Main Dictionary Class
//************************************************************

constructor TMainDictionary.Create;
begin
    inherited Create;

    FFilename   := '';
    FLoaded     := False;
    FTitle      := '';
    FLanguage   := 0;
    FWordCount  := 0;
    FNodeCount  := 0;

    FFileHandle     := INVALID_HANDLE_VALUE;
    FMappingHandle  := 0;
    FPFile          := nil;
    FLinkageSize    := 0;
    FPLinkage       := nil;

    FWordsFoundCount    := 0;
end;

//************************************************************

destructor TMainDictionary.destroy;
begin
    WriteLoaded( False );

    inherited destroy;
end;



//************************************************************
// Property Read/Write Functions
//************************************************************

procedure TMainDictionary.WriteFilename( Filename:String );
var
    WasLoaded           :Boolean;
    FileHandle          :THandle;
    FileSize            :DWORD;
    BytesRead           :DWORD;
    BLength             :Byte;
    Index               :DWORD;
    WideTitle           :Array[0..256] of WCHAR;
    TempHeaderString    :String;
begin
    if (not FileExists( Filename )) then
    begin
        exit;
    end;

    FileHandle  := CreateFile( PChar(Filename), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0 );
    if (FileHandle = INVALID_HANDLE_VALUE) then
    begin
        exit;
    end;

    try
        FWordsFoundCount    := 0;

        WasLoaded   := Loaded;
        Loaded      := False;

        // Read all of the pertinent information right up to the NodeStream into memory.

        FileSize    := GetFileSize( FileHandle, nil );
        if (FileSize <= HeaderBufferSize) then
        begin
            exit;
        end;

        ReadFile( FileHandle, FCompleteHeader, HeaderBufferSize, BytesRead, nil );

        TempHeaderString := copy( PChar(@FCompleteHeader), 0, lstrlenA(HeaderString) );
        if (TempHeaderString <> HeaderString) then
        begin
            exit;
        end;

        BLength := 0;
        ReadFile( FileHandle, BLength, 1, BytesRead, nil );

        ReadFile( FileHandle, WideTitle, (BLength + 1) * 2, BytesRead, nil );
        ReadFile( FileHandle, FLanguage, SizeOf(FLanguage), BytesRead, nil );
        ReadFile( FileHandle, FWordCount, SizeOf(FWordCount), BytesRead, nil );
        ReadFile( FileHandle, FNodeCount, SizeOf(FNodeCount), BytesRead, nil );
        ReadFile( FileHandle, FCharacterCount, SizeOf(FCharacterCount), BytesRead, nil );

        FTitle  := WideTitle;

        FNodePositionStart[0]   := SetFilePointer( FileHandle, 0, nil, FILE_CURRENT );
        FNodeIndexStart[0]      := 0;

        for Index := 1 to CharactersPerNode do
        begin
            FNodePositionStart[Index]   := FNodePositionStart[Index - 1] + ((4 + (Index - 1)) * FCharacterCount[Index - 1]);
            FNodeIndexStart[Index]      := FNodeIndexStart[Index - 1] + FCharacterCount[Index - 1];
        end;

        FFileName := Filename;

    finally

        CloseHandle( FileHandle );
    end;

    Loaded := WasLoaded;
end;

//************************************************************

procedure TMainDictionary.WriteLoaded( Loaded:Boolean );
var
    FileSize    :DWORD;
    Failed      :Boolean;
    PLinkStart  :LPDWORD;
    Loop        :LongInt;
begin
    if (Loaded = FLoaded) or (FFilename = '') then
    begin
        exit;
    end;

    FLoaded := Loaded;

    if (FLoaded) then
    begin

        // Do whats needed to load the dictionary into memory

        Failed      := True;

        try
            FFileHandle := CreateFile( PChar(FFilename), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0 );
            if (FFileHandle = INVALID_HANDLE_VALUE) then
            begin
                exit;
            end;

            FileSize        := GetFileSize( FFileHandle, nil );
            FMappingHandle  := CreateFileMapping( FFileHandle, nil, PAGE_READONLY or SEC_COMMIT, 0, 0, nil );
            if (0 = FMappingHandle) then
            begin
                exit;
            end;

            FPFile          := MapViewOfFile( FMappingHandle, FILE_MAP_READ, 0, 0, 0 );
            if (not Assigned(FPFile)) then
            begin
                exit;
            end;

            if (FileSize <= (FNodePositionStart[CharactersPerNode] + SizeOf(DWORD))) then
            begin
                exit;
            end;

            PLinkStart      := LPDWORD(BYTEAdd( PByte(FPFile), FNodePositionStart[CharactersPerNode] ));

            FLinkageSize    := PLinkStart^;
            FPLinkage       := PByte(DWORDAdd( PLinkStart, 1 ));

            if (FileSize < (FNodePositionStart[CharactersPerNode] + SizeOf(DWORD) + FLinkageSize + SizeOf(FLookup) + SizeOf(FCharSetTable))) then
            begin
                exit;
            end;

            CopyMemory( @FLookup, BYTEAdd(FPLinkage,FLinkageSize), SizeOf(FLookup) );

            for Loop := 0 to CharactersPerNode - 1 do
            begin
                FNodes[Loop] := BYTEAdd(PByte(FPFile),FNodePositionStart[Loop]);
            end;

            CopyMemory( @FCharSetTable, BYTEAdd(FPLinkage, FLinkageSize + SizeOf(FLookup)), SizeOf(FCharSetTable) );

            Failed := False;

        finally

            // If we failed in any way, then we simply revert to being
            // unloaded by calling WriteLoaded with false.  This will
            // gracefully free up anything we've opened thusfar.

            if (Failed) then
            begin
                WriteLoaded( False );
            end;
        end;
    end
    else
    begin

        // clean up our allocated resources

        if (nil <> FPFile) then
        begin
            UnmapViewOfFile( FPFile );
            FPFile := nil;
        end;
        if (0 <> FMappingHandle) then
        begin
            CloseHandle( FMappingHandle );
            FMappingHandle := 0;
        end;
        if (INVALID_HANDLE_VALUE <> FFileHandle) then
        begin
            CloseHandle( FFileHandle );
            FFileHandle := INVALID_HANDLE_VALUE;
        end;
    end;
end;




//************************************************************
// Utility Functions
//************************************************************

// The Obvious loop below is unrolled intentionally for
// performance reasons.

function TMainDictionary.GetNode( Index:DWORD; var Chars:DWORD ):LPDWORD;
begin
    if (Index < FNodeIndexStart[1]) then
    begin
        Chars   := 0;
        Result  := DWORDAdd( LPDWORD(FNodes[0]), Index );
    end
    else if (Index < FNodeIndexStart[2]) then
    begin
        Chars   := 1;
        Result  := LPDWORD( BYTEAdd( FNodes[1], ((sizeof(DWORD) + 1) * (Index - FNodeIndexStart[1])) ));
    end
    else if (Index < FNodeIndexStart[3]) then
    begin
        Chars   := 2;
        Result  := LPDWORD( BYTEAdd( FNodes[2], ((sizeof(DWORD) + 2) * (Index - FNodeIndexStart[2])) ));
    end
    else if (Index < FNodeIndexStart[4]) then
    begin
        Chars   := 3;
        Result  := LPDWORD( BYTEAdd( FNodes[3], ((sizeof(DWORD) + 3) * (Index - FNodeIndexStart[3])) ));
    end
    else if (Index < FNodeIndexStart[5]) then
    begin
        Chars   := 4;
        Result  := LPDWORD( BYTEAdd( FNodes[4], ((sizeof(DWORD) + 4) * (Index - FNodeIndexStart[4])) ));
    end
    else if (Index < FNodeIndexStart[6]) then
    begin
        Chars   := 5;
        Result  := LPDWORD( BYTEAdd( FNodes[5], ((sizeof(DWORD) + 5) * (Index - FNodeIndexStart[5])) ));
    end
    else if (Index < FNodeIndexStart[7]) then
    begin
        Chars   := 6;
        Result  := LPDWORD( BYTEAdd( FNodes[6], ((sizeof(DWORD) + 6) * (Index - FNodeIndexStart[6])) ));
    end
    else if (Index < FNodeIndexStart[8]) then
    begin
        Chars   := 7;
        Result  := LPDWORD( BYTEAdd( FNodes[7], ((sizeof(DWORD) + 7) * (Index - FNodeIndexStart[7])) ));
    end
    else // if (Index < FNodeIndexStart[9]) then
    begin
        Chars   := 8;
        Result  := LPDWORD( BYTEAdd( FNodes[8], ((sizeof(DWORD) + 8) * (Index - FNodeIndexStart[8])) ));
    end
end;

//************************************************************

function TMainDictionary.GetLinkageIndex( var Offset:DWORD ):DWORD;
var
    PB  :PByte;
begin

    PB := BYTEAdd( FPLinkage, Offset );

    // check to see if we always have 16 bit references... if so...

    if (FNodeCount < WRITE_16BIT_MAX) then
    begin
        Offset  := Offset + 2;
        Result  := (PWord(PB))^;
        exit;
    end;

    // if the high bit is set, then its a 16 bit reference, where
    // the bytes are stored high-order first...

    if ((PB^ and $80) <> 0) then
    begin
        // XOR out the flag, and then shift the first byte up, and OR
        // in the second byte

        Offset  := Offset + 2;

        Result := (PB^ xor $80);
        Result := (Result shl 8) or DWORD((BYTEAdd(PB,1))^);
        exit;
    end;

    // its a three byte reference (stored in reverse order)

    Offset := Offset + 3;

    Result := PB^;
    Result := (Result shl 8) or DWORD((BYTEAdd(PB,1))^);
    Result := (Result shl 8) or DWORD((BYTEAdd(PB,2))^);
end;

//************************************************************

function TMainDictionary.InternalWordExists( Word:PChar; var Length:LongInt ):Boolean;
var
    PLookup     :PChildLookup;
    Chars       :DWORD;
    Children    :DWORD;
    Index       :DWORD;
    PNode       :LPDWORD;
    Node        :DWORD;
    CharIndex   :LongInt;
    PB          :PByte;
begin
    if (not FLoaded) then
    begin
        Loaded := True;
        if (not FLoaded) then
        begin
            Result := False;
            exit;
        end;
    end;

    if (Word[0] = #0) then
    begin
        Result := False;
        exit;
    end;

    // Notice that we use the Stored ChildLookup structure in order to speed
    // access to the information about the first character in the word.

    Length  := 0;
    PLookup := @(FLookup[ Ord(Word[0]) ]);

    if (Word[1] = #0) and (PLookup^.FEndOfWord <> 0) then
    begin
        inc(Length);
        Result := True;
        exit;
    end;

    if (PLookup^.FChildren = 0) then
    begin
        Result := False;
        exit;
    end;

    inc(Length);

    Chars   := 0;
    PNode   := nil;
    Node    := 0;

    Children    := PLookup^.FChildren;
    Index       := PLookup^.FIndex;
    CharIndex   := 1;

    // now we continue through the word...

    while (Word[CharIndex] <> #0) do
    begin
        // find the child that matches the next letter in
        // the string

        if (Children = 1) then
        begin
            PNode   := GetNode( Index, Chars );
            Node    := PNode^;

            if ((Node and WRITE_CHAR) <> Ord(Word[CharIndex])) then
            begin
                Result := False;
                exit;
            end;
        end
        else
        begin
            while (Children > 0) do
            begin
                PNode   := GetNode( GetLinkageIndex(Index), Chars );
                Node    := PNode^;
                if ((Node and WRITE_CHAR) = Ord(Word[CharIndex])) then
                begin
                    break;
                end;
                dec(Children);
            end;

            if (Children = 0) then
            begin
                Result := False;
                exit;
            end;
        end;

        inc(Length);
        inc(CharIndex);

        if (Word[CharIndex] = #0) then
        begin
            Result := ((Node and WRITE_EOW) <> 0);
            exit;
        end;

        // skip additional characters if they are present...

        if (Chars > 0) then
        begin
            PB := PByte( DWORDAdd( PNode, 1 ) );

            repeat
                dec(Chars);

                if (PB^ <> Ord(Word[CharIndex])) then
                begin
                    Result := False;
                    exit;
                end;

                PB := ByteAdd( PB, 1 );
                inc(CharIndex);

                inc(Length);

            until (Chars = 0);
        end;

        // Setup for the next character iteration

        Children    := (Node and WRITE_CHILDREN) shr WRITE_CHILDREN_OFFSET;
        Index       := (Node and WRITE_INDEX) shr WRITE_INDEX_OFFSET;

        // If children is 0, then we have to pick up the childcount
        // off of the linkage array

        if (Children = 0) then
        begin
            if ((Node and WRITE_INDEX) = WRITE_INDEX) then
            begin
                Result := False;
                exit;
            end;

            Children    := (BYTEAdd( FPLinkage, Index ))^;
            inc(Index);
        end;
    end;

    Result := False;
end;


//************************************************************
// Private suggestions generation functions
//************************************************************

procedure TMainDictionary.InternalPrefixWords( Base:PChar; Current:PChar; NodeIndex:DWORD );
var
    Chars       :DWORD;
    PNode       :LPDWORD;
    Node        :DWORD;
    PB          :PByte;
    Children    :DWORD;
    Index       :DWORD;
begin
    PNode   := GetNode( NodeIndex, Chars );
    Node    := PNode^;

    if (NodeIndex <> 0) then
    begin
        Current^    := Chr( Node and WRITE_CHAR );
        Current     := PChar(ByteAdd( PByte(Current), 1 ));
        Current^    := #0;

        if ((Node and WRITE_EOW) <> 0) then
        begin
            if (FoundWord) then
            begin
                exit;
            end;
        end;

        if (Chars > 0) then
        begin
            PB := PByte( DWORDAdd( PNode, 1 ) );
            repeat
                Current^    := Chr( PB^ );
                Current     := PChar( ByteAdd( PByte(Current), 1 ) );
                PB          := ByteAdd( PB, 1 );
                dec(Chars);
            until (Chars = 0);
            Current^ := #0;
        end;
    end;

    Children    := (Node and WRITE_CHILDREN) shr WRITE_CHILDREN_OFFSET;
    Index       := (Node and WRITE_INDEX) shr WRITE_INDEX_OFFSET;

    if (Children = 1) then
    begin
        InternalPrefixWords( Base, Current, Index );
        exit;
    end;

    if (Children = 0) then
    begin
        if ((Node and WRITE_INDEX) = WRITE_INDEX) then
        begin
            exit;
        end;
        Children    := (BYTEAdd( FPLinkage, Index ))^;
        inc(Index);
    end;
    while (Children > 0) do
    begin
        dec( Children );
        InternalPrefixWords( Base, Current, GetLinkageIndex( Index ) );
    end;
end;

//************************************************************

procedure TMainDictionary.PerformPrefixWords( Word:PChar );
var
    Chars       :DWORD;
    Children    :DWORD;
    Index       :DWORD;
    PNode       :LPDWORD;
    Node        :DWORD;
    CharIndex   :LongInt;
    PB          :PByte;
    LastIndex   :DWORD;
begin
    if (not FLoaded) then
    begin
        Loaded := True;
        if (not FLoaded) then
        begin
            exit;
        end;
    end;

    if (Word[0] = #0) then
    begin
        exit;
    end;

    Chars       := 0;
    PNode       := GetNode( 0, Chars );
    Node        := PNode^;
    LastIndex   := 0;

    Children    := (Node and WRITE_CHILDREN) shr WRITE_CHILDREN_OFFSET;
    Index       := (Node and WRITE_INDEX) shr WRITE_INDEX_OFFSET;
    CharIndex   := 0;

    if (Children = 0) then
    begin
        if ((Node and WRITE_INDEX) = WRITE_INDEX) then
        begin
            exit;
        end;

        Children    := (BYTEAdd( FPLinkage, Index ))^;
        inc(Index);
    end;

    while (Word[CharIndex] <> #0) do
    begin
        if (Children = 1) then
        begin
            LastIndex   := Index;
            PNode       := GetNode( Index, Chars );
            Node        := PNode^;

            if ((Node and WRITE_CHAR) <> Ord(Word[CharIndex])) then
            begin
                exit;
            end;
        end
        else
        begin
            while (Children > 0) do
            begin
                LastIndex   := GetLinkageIndex( Index );
                PNode       := GetNode( LastIndex, Chars );
                Node        := PNode^;
                if ((Node and WRITE_CHAR) = Ord(Word[CharIndex])) then
                begin
                    break;
                end;
                dec(Children);
            end;

            if (Children = 0) then
            begin
                exit;
            end;
        end;

        inc(CharIndex);

        if (Chars > 0) then
        begin
            PB := PByte( DWORDAdd( PNode, 1 ) );

            repeat
                dec(Chars);

                if (PB^ <> Ord(Word[CharIndex])) then
                begin
                    exit;
                end;

                PB := ByteAdd( PB, 1 );
                inc(CharIndex);

            until (Chars = 0);
        end;

        Children    := (Node and WRITE_CHILDREN) shr WRITE_CHILDREN_OFFSET;
        Index       := (Node and WRITE_INDEX) shr WRITE_INDEX_OFFSET;

        if (Children = 0) then
        begin
            if ((Node and WRITE_INDEX) = WRITE_INDEX) then
            begin
                exit;
            end;

            Children    := (BYTEAdd( FPLinkage, Index ))^;
            inc(Index);
        end;
    end;

    InternalPrefixWords( Word, PChar(BYTEAdd( PByte(Word), CharIndex - 1 )), LastIndex );
end;

//************************************************************

function TMainDictionary.FoundWord:Boolean;
var
    NewMap  :String;
begin
    Result  := False;
    NewMap  := FPhonetics.GetMapping( FWord );

    if (NewMap = FOriginalMap) then
    begin
        if (FSuggestions.Count > MaxPhoneticSuggestions) then
        begin
            Result := True;
        end
        else if (FSuggestions.IndexOf( FWord ) < 0) then
        begin
            FSuggestions.Add( FWord );
        end;
    end
    else
    begin
        if (Length( NewMap ) > FOriginalMapLength) then
        begin
            Result := True;
        end;
    end;
end;

//************************************************************

procedure TMainDictionary.InternalSuggest( OriginalWord:String; Phonetics:TPhoneticsMap; Suggestions:TStrings );
var
    DestWord    :Array[0..512] of Char;
    Index       :Integer;
begin
    for Index := 0 to Phonetics.StartDepth - 1 do
    begin
        DestWord[Index] := OriginalWord[Index + 1];
    end;
    DestWord[Phonetics.StartDepth]  := #0;

    FWord           := DestWord;
    FSuggestions    := Suggestions;
    FPhonetics      := Phonetics;

    PerformPrefixWords( FWord );
end;




//************************************************************
// Public Dictionary Lookups
//************************************************************

function TMainDictionary.WordExists( const Word:String ):Boolean;
var
    Length  :LongInt;
begin
    Result := InternalWordExists( PChar(Word), Length );
end;

//************************************************************

function TMainDictionary.WordLength( const Word:String ):LongInt;
begin
    InternalWordExists( PChar(Word), Result );
end;

//************************************************************

procedure TMainDictionary.Suggest( Word:String; Phonetics:TPhoneticsMap; Suggestions:TStrings );
begin
    FOriginalWord       := Word;
    FOriginalMap        := Phonetics.GetMapping( Word );
    FOriginalMapLength  := Length(FOriginalMap);

    if (FOriginalMapLength < 2) then
    begin
        exit;
    end;

    InternalSuggest( Word, Phonetics, Suggestions );
end;

//************************************************************

procedure TMainDictionary.WordFound;
begin
    inc( FWordsFoundCount );
end;



end.

