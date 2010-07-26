{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10867: ad3Suggestions.pas 
{
{   Rev 1.4    1/27/2005 2:14:24 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:38 pm  Glenn
}
{
{   Rev 1.2    2/21/2004 11:59:58 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:46 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:54 AM  mnovak
}
{
{   Rev 1.2    9/23/2002 8:43:30 PM  mnovak
{ Fixed InternalSuggestion CharSet swapping problem
}
{
{   Rev 1.1    7/30/2002 12:07:12 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.0    6/23/2002 11:55:28 PM  mnovak
}
{
{   Rev 1.0    6/17/2002 1:34:20 AM  Supervisor
}
(*************************************************************

Addict 3.4,  (c) 1996-2005, Addictive Software
Contact: addictsw@addictivesoftware.com

AddictSpell Suggestions Generation Engine

History:
8/6/00      - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3Suggestions;

{$I addict3.inc}

interface

uses
    windows,
    sysutils,
    classes;

type

    TExistsEvent        = procedure( const Word:PChar; var Exists:Boolean ) of object;
    TSuggestionType     = ( stSingleDeletion, stTransposition, stInsertion, stSubstitution, stSplitWord );
    TSuggestionTypes    = set of TSuggestionType;

    //************************************************************
    // AddictSpell Suggestions Generation
    //************************************************************

    TSuggestionsGenerator = class(TObject)
    protected

        FWord           :String;
        FLength         :LongInt;
        FWords          :TStrings;
        FExistsFunc     :TExistsEvent;

        FLanguage               :DWORD;
        FUsageCharSet           :String;
        FStartCharSet           :String;
        FMaxCount               :LongInt;
        FDefaultSuggestionTypes :Boolean;
        FSuggestionTypes        :TSuggestionTypes;
        FRestrictCase           :Boolean;

    protected

        procedure WriteLanguage( NewLanguage:DWORD ); virtual;
        procedure WriteDefaultSuggestionTypes( NewValue:Boolean ); virtual;
        procedure WriteSuggestionTypes( NewTypes:TSuggestionTypes ); virtual;

        function AddWordToList( Word:String ):Boolean; virtual;
        function CheckWord( const Word:PChar ):Boolean; virtual;

        function Generate_SingleDeletion:Boolean; virtual;
        function Generate_SingleTransposition( Distance:Integer ):Boolean; virtual;
        function Generate_SingleInsertion:Boolean; virtual;
        function Generate_SingleSubstitution:Boolean; virtual;
        function Generate_SplitWord:Boolean; virtual;

        procedure InternalSuggest( const Word:String; MaxSuggestions:LongInt; Words:TStrings; ExistsFunc:TExistsEvent ); virtual;

    public

        {$IFNDEF T2H}
        constructor Create;
        {$ENDIF}

        procedure Suggest( const Word:String; MaxSuggestions:LongInt; Words:TStrings; ExistsFunc:TExistsEvent ); virtual;

        property Language:DWORD read FLanguage write WriteLanguage;

        property UsageCharSet:String read FUsageCharSet write FUsageCharSet;
        property StartCharSet:String read FStartCharSet write FStartCharSet;
        property DefaultSuggestionTypes:Boolean read FDefaultSuggestionTypes write WriteDefaultSuggestionTypes;
        property SuggestionTypes:TSuggestionTypes read FSuggestionTypes write WriteSuggestionTypes;
        property RestrictSuggestionCase:Boolean read FRestrictCase write FRestrictCase;
    end;

implementation

const
    KUsageCharSet       = '''abcdefghijklmnopqrstuvwxyz×Þßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ¸¨¹³¿';
    KFullCharSet        = '''abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ¸¨¹³¿';
    KSwedishLanguage    = $041d;    
    KCzechLanguage      = $0405;
    KCzechAdditions     =   #225 + #232 + #239 + #233 + #236 + #237 + #242 + #243 + #248 +
                            #154 + #157 + #250 + #249 + #253 + #158 + #193 + #200 + #207 +
                            #201 + #204 + #205 + #210 + #211 + #216 + #138 + #141 + #218 +
                            #217 + #221 + #142;
    KFrenchLanguage     = $000c;
    KFrenchAdditions    =   #156;
    KRussianLanguage    = $0419;
    KRussianAdditions   =   #178 + #162 + #177 + #161 + #188 + #172 + #182 + #166;
    KPolishLanguage     = $0415;
    KPolishAdditions    =   #185 + #230 + #234 + #179 + #179 + #241 + #243 + #156 + #191 +
                            #159 + #165 + #198 + #202 + #163 + #209 + #211 + #140 + #175 +
                            #143;





//************************************************************
// AddictSpell Suggestions Generation
//************************************************************

constructor TSuggestionsGenerator.Create;
begin
    inherited Create;

    FLanguage               :=  0;
    FUsageCharSet           :=  KUsageCharSet;
    FStartCharSet           :=  KFullCharSet;
    DefaultSuggestionTypes  := True;
    FRestrictCase           := False;
end;


//************************************************************
// Property Read/Write functions
//************************************************************

procedure TSuggestionsGenerator.WriteLanguage( NewLanguage:DWORD );
begin
    if (FLanguage <> NewLanguage) then
    begin
        FLanguage := NewLanguage;
        WriteDefaultSuggestionTypes( FDefaultSuggestionTypes );

        if (NewLanguage = KCzechLanguage) then
        begin
            FUsageCharSet   := FUsageCharSet + KCzechAdditions;
            FStartCharSet   := FStartCharSet + KCzechAdditions;
        end;
        if ((NewLanguage and $00FF) = KFrenchLanguage) then
        begin
            FUsageCharSet   := FUsageCharSet + KFrenchAdditions;
            FStartCharSet   := FStartCharSet + KFrenchAdditions;
        end;
        if (NewLanguage = KRussianLanguage) then
        begin
            FUsageCharSet   := FUsageCharSet + KRussianAdditions;
            FStartCharSet   := FStartCharSet + KRussianAdditions;
        end;
        if (NewLanguage = KPolishLanguage) then
        begin
            FUsageCharSet   := FUsageCharSet + KPolishAdditions;
            FStartCharSet   := FStartCharSet + KPolishAdditions;
        end;
    end;
end;

//************************************************************

procedure TSuggestionsGenerator.WriteDefaultSuggestionTypes( NewValue:Boolean );
begin
    FDefaultSuggestionTypes := NewValue;
    if (FDefaultSuggestionTypes) then
    begin
        FSuggestionTypes := [ stSingleDeletion, stTransposition, stInsertion, stSubstitution, stSplitWord ];
        if (FLanguage = KSwedishLanguage) then
        begin
            FSuggestionTypes := FSuggestionTypes - [stSplitWord];
        end;
    end;
end;

//************************************************************

procedure TSuggestionsGenerator.WriteSuggestionTypes( NewTypes:TSuggestionTypes );
begin
    FSuggestionTypes := NewTypes;
    WriteDefaultSuggestionTypes( False );
end;


//************************************************************
// Suggestions Utility Functions
//************************************************************

function TSuggestionsGenerator.AddWordToList( Word:String ):Boolean;
var
    Index   :Integer;
begin
    // We also don't allow the same word multiple times
    Result := True;
    Index       := FWords.IndexOf( Word );
    if (Index >= 0) then
    begin
        // IndexOf is case insensitive, so we add one additional
        // check..

        if (FWords[Index] = Word) then
        begin
            Result := False;
            Exit;
        end;
    end;

    FWords.Add( Word );
end;

//************************************************************

function TSuggestionsGenerator.CheckWord( const Word:PChar ):Boolean;
var
    Exists              :Boolean;
    SourceLower         :Boolean;
    ReplacementLower    :Boolean;
    WordPart            :String;
begin
    if (Length( Word ) > 1) then
    begin
        FExistsFunc( Word, Exists );
        if (Exists) then
        begin
            Result := (FMaxCount < FWords.Count);
            if (not Result) then
            begin
                SourceLower         := (AnsiLowerCase(FWord) = FWord);
                ReplacementLower    := (AnsiLowerCase(Word) = Word);

                // We don't allow words that begin in uppercase (that are
                // acceptible in lower case) to be suggestions for a lowercase
                // word

                if SourceLower and (not ReplacementLower) then
                begin
                    FExistsFunc( PChar(AnsiLowerCase(Word)), Exists );
                    if (Exists) then
                    begin
                        exit;
                    end;
                end;

                // We also don't allow strange case mixings...

                if FRestrictCase and (not ReplacementLower) then
                begin
                    WordPart := copy(Word, 2, Length(Word) - 1);
                    if  (AnsiLowerCase(WordPart) <> WordPart) and
                        (AnsiUpperCase(WordPart) <> WordPart) then
                    begin
                        exit;
                    end;
                end;

                AddWordToList( Word );
            end;

            Exit;
        end;
    end;
    Result := False;
end;

//************************************************************

function TSuggestionsGenerator.Generate_SingleDeletion:Boolean;
var
    Index   :LongInt;
    Word    :String;
    CharSet :PChar;
    Count   :LongInt;
begin
    Result := True;

    // We're inserting a single character in each position and checking
    // the word (with the exception of the first position)

    for Index := (FLength + 1) downto 2 do
    begin
        Word := FWord;
        insert( '!', Word, Index );
        CharSet := PChar(FUsageCharSet);
        Count   := 0;

        while (CharSet[Count] <> #0) do
        begin
            Word[Index] := CharSet[Count];
            if (CheckWord( PChar(Word) )) then
            begin
                exit;
            end;
            inc(Count);
        end;
    end;

    // We now insert a single character in the first position and check the
    // results...  we use the StartCharSet here though

    Word := FWord;
    insert( '!', Word, 1 );
    CharSet := PChar(FStartCharSet);
    Count   := 0;

    while (CharSet[Count] <> #0) do
    begin
        Word[1] := CharSet[Count];
        if (CheckWord( PChar(Word) )) then
        begin
            exit;
        end;
        inc(Count);
    end;

    Result := False;
end;

//************************************************************

function TSuggestionsGenerator.Generate_SingleTransposition( Distance:Integer ):Boolean;
var
    Word    :String;
    Index   :LongInt;
    Ch      :Char;
begin
    Result  := True;

    Word    := FWord;
    if (FLength > Distance + 1) then
    begin
        for Index := (FLength - Distance) downto 1 do
        begin
            Ch                      := Word[Index];
            Word[Index]             := Word[Index + Distance];
            Word[Index + Distance]  := Ch;

            if (CheckWord( PChar(Word) )) then
            begin
                exit;
            end;

            Ch                      := Word[Index];
            Word[Index]             := Word[Index + Distance];
            Word[Index + Distance]  := Ch;
        end;
    end;

    Result  := False;
end;

//************************************************************

function TSuggestionsGenerator.Generate_SingleInsertion:Boolean;
var
    Word    :String;
    Index   :LongInt;
begin
    Result := True;

    for Index := FLength downto 1 do
    begin
        Word    := FWord;
        delete( Word, Index, 1 );

        if (CheckWord( PChar(Word) )) then
        begin
            exit;
        end;
    end;

    Result := False;
end;

//************************************************************

function TSuggestionsGenerator.Generate_SingleSubstitution:Boolean;
var
    Word    :String;
    Index   :LongInt;
    Ch      :Char;
    CharSet :PChar;
    Count   :LongInt;
begin
    Result := True;

    Word := FWord;
    for Index := FLength downto 2 do
    begin
        Ch          := Word[Index];

        CharSet := PChar(FUsageCharSet);
        Count   := 0;

        while (CharSet[Count] <> #0) do
        begin
            Word[Index] := CharSet[Count];
            if (CheckWord( PChar(Word) )) then
            begin
                exit;
            end;
            inc(Count);
        end;

        Word[Index] := Ch;
    end;

    CharSet := PChar(FStartCharSet);
    Count   := 0;

    while (CharSet[Count] <> #0) do
    begin
        Word[1] := CharSet[Count];
        if (CheckWord( PChar(Word) )) then
        begin
            exit;
        end;
        inc(Count);
    end;

    Result := False;
end;

//************************************************************

function TSuggestionsGenerator.Generate_SplitWord:Boolean;
var
    Word1   :String;
    Word2   :String;
    Count   :LongInt;
    Exists  :Boolean;
begin
    for Count := 2 to FLength - 2 do
    begin
        Word1   := copy( FWord, 1, Count );
        FExistsFunc( PChar(Word1), Exists );
        if (Exists) then
        begin
            Word2   := copy( FWord, Count + 1, FLength - Count );
            FExistsFunc( PChar(Word2), Exists );
            if (Exists) then
            begin
                Result := (FMaxCount < FWords.Count);
                if (not Result) then
                begin
                    AddWordToList( PChar(Word1 + ' ' + Word2) );
                end
                else
                begin
                    exit;
                end;
            end;
        end;
    end;

    Count := pos( '.', FWord );
    if (Count > 0) then
    begin
        if  (Count < Length(FWord)) and
            (pos( '.', copy( FWord, Count + 1, Length(FWord) ) ) = 0) and
            (AnsiUpperCase( FWord[Count + 1 ] ) = FWord[Count + 1]) then
        begin
            FExistsFunc( PChar(copy( FWord, 1, Count-1 )), Exists );
            if (Exists) then
            begin
                FExistsFunc( PChar(copy( FWord, Count + 1, Length(FWord) )), Exists );
                if (Exists) then
                begin
                    if (FMaxCount >= FWords.Count) then
                    begin
                        Word1 := FWord;
                        Insert( '  ', Word1, Count + 1 );
                        AddWordToList( PChar(Word1) );
                    end;
                end;
            end;
        end;
    end;

    Result  := False;
end;



//************************************************************
// Internal Suggetions Method
//************************************************************

procedure TSuggestionsGenerator.InternalSuggest( const Word:String; MaxSuggestions:LongInt; Words:TStrings; ExistsFunc:TExistsEvent );
var
    FOldCharSet :String;
begin
    FLength := Length(Word);

    if (MaxSuggestions = -1) then
    begin
        MaxSuggestions := $FFFF;
    end;

    if  (not Assigned(ExistsFunc)) or
        (not Assigned(Words)) or
        (Word = '') or
        (MaxSuggestions <= 0) or
        (FLength > 250) then
    begin
        exit;
    end;

    FWord           := Word;
    FWords          := Words;
    FExistsFunc     := ExistsFunc;
    FMaxCount       := MaxSuggestions;

    FOldCharSet := FUsageCharSet;
    if (AnsiLowerCase(FWord) <> FWord) then
    begin
        FUsageCharSet := FStartCharSet;
    end;

    try
        if  (stTransposition in FSuggestionTypes) and
            (Generate_SingleTransposition( 1 )) then
        begin
            exit;
        end;

        if  (stSingleDeletion in FSuggestionTypes) and
            (Generate_SingleDeletion) then
        begin
            exit;
        end;

        if  (stInsertion in FSuggestionTypes) and
            (Generate_SingleInsertion) then
        begin
            exit;
        end;

        if  (stSubstitution in FSuggestionTypes) and
            (Generate_SingleSubstitution) then
        begin
            exit;
        end;

        if  (stTransposition in FSuggestionTypes) and
            (Generate_SingleTransposition( 2 )) then
        begin
            exit;
        end;

        if  (stSplitWord in FSuggestionTypes) and
            (Generate_SplitWord) then
        begin
            exit;
        end;

    finally
        FUsageCharSet := FOldCharSet;
    end;
end;



//************************************************************
// Public Suggetions Method
//************************************************************

procedure TSuggestionsGenerator.Suggest( const Word:String; MaxSuggestions:LongInt; Words:TStrings; ExistsFunc:TExistsEvent );
begin
    InternalSuggest( Word, MaxSuggestions, Words, ExistsFunc );

    if  (AnsiUppercase(Word) <> Word) and
        (AnsiLowercase(Word) <> Word) then
    begin
        if (AnsiUppercase(Word[1]) = Word[1]) then
        begin
            InternalSuggest( Word[1] + AnsiLowercase(Copy(Word, 2, Length(Word)-1)), MaxSuggestions, Words, ExistsFunc );
        end
        else
        begin
            InternalSuggest( AnsiLowercase(Word), MaxSuggestions, Words, ExistsFunc );
        end;
    end;
end;




end.
