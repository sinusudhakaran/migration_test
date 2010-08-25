{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10845: ad3ParseEngine.pas 
{
{   Rev 1.4    1/27/2005 2:14:20 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:20 pm  Glenn
}
{
{   Rev 1.2    2/21/2004 11:59:46 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:34 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:44 AM  mnovak
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

New parsing engine for AddictSpell

History:
7/23/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3ParseEngine;

{$I addict3.inc}

interface

uses
    classes,
    {$IFDEF Delphi5AndAbove} contnrs, {$ENDIF}
    ad3Util,
    ad3ParserBase;

type

    //************************************************************
    // Primary AddictSpell parsing engine
    //************************************************************

    TMainParsingEngine = class(TParsingEngine)
    protected
        FParser             :TControlParser;
        FCharSet            :String;
        FForbidStart        :String;
        FForbidEnd          :String;
        FForbidMidWord      :String;
        FBStartCharSet      :Array[0..255] of Boolean;
        FBCharSet           :Array[0..255] of Boolean;
        FBForbidEnd         :Array[0..255] of Boolean;
        FWord               :String;

        FAllowMidPeriod             :Boolean;
        FAllowIncompleteLastWord    :Boolean;
        FAllowHTMLCharMapping       :Boolean;
        FFrenchExceptions           :Boolean;

    protected

        procedure SetCharSet( NewCharSet:String );
        procedure SetMidWord( NewForbidMidWord:String );
        procedure SetForbidEnd( NewForbidEnd:String );
        procedure SetFrenchExceptions( NewValue:Boolean );

    public

        {$IFNDEF T2H}
        constructor Create;
        {$ENDIF}

        procedure Initialize( Parser:TControlParser; CheckType:LongInt ); override;
        procedure AdjustToPosition( XPos:LongInt; YPos:LongInt ); override;
        function NextWord:String; override;

        property CharSet:String read FCharSet write SetCharSet;
        property ForbidStart:String read FForbidStart write FForbidStart;
        property ForbidEnd:String read FForbidEnd write SetForbidEnd;
        property ForbidMidWord:String read FForbidMidWord write SetMidWord;
        property CurrentWord:String read FWord;

        property AllowMidPeriod:Boolean read FAllowMidPeriod write FAllowMidPeriod;
        property AllowIncompleteLastWord:Boolean read FAllowIncompleteLastWord write FAllowIncompleteLastWord;
        property AllowHTMLCharMapping:Boolean read FAllowHTMLCharMapping write FAllowHTMLCharMapping;
        property AllowFrenchExceptions:Boolean read FFrenchExceptions write SetFrenchExceptions;
    end;


implementation

uses
    SysUtils;

//************************************************************
// Primary AddictSpell parsing engine
//************************************************************

const
    KCharSet    =   '’1234567890&''abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ¸¨' +
                    #225 + #232 + #239 + #233 + #236 + #237 + #242 + #243 + #248 +
                    #154 + #157 + #250 + #249 + #253 + #158 + #193 + #200 + #207 +
                    #201 + #204 + #205 + #210 + #211 + #216 + #138 + #141 + #218 +
                    #217 + #221 + #142 + #156 +
                    #185 + #230 + #234 + #179 + #179 + #241 + #243 + #156 + #191 + #159 + #165 + #198 + #202 + #163 + #209 + #211 + #140 + #175 + #143 +    // Polish Additions
                    #178 + #162 + #177 + #161 + #188 + #172 + #182 + #166;          // Old Russian Additions

constructor TMainParsingEngine.Create;
begin
    inherited Create;

    FForbidStart    := '''"';
    FForbidEnd      := '''".';
    FForbidMidWord  := '&';
    SetCharSet( KCharSet );
    FParser                 := nil;
    FWord                   := '';
    FAllowMidPeriod         := True;
    AllowIncompleteLastWord := False;
    FAllowHTMLCharMapping   := False;
end;


(*************************************************************)
(* 2nd Generation addict parsing engine *)
(*************************************************************)

procedure TMainParsingEngine.SetCharSet( NewCharSet:String );
var
    Count   :LongInt;
begin
    FCharSet := NewCharSet;
    for Count := 0 to 255 do
    begin
        FBStartCharSet[Count]   := False;
        FBCharSet[Count]        := False;
        FBForbidEnd[Count]      := False;
    end;
    for Count := 1 to Length(NewCharSet) do
    begin
        FBStartCharSet[ Ord(NewCharSet[Count]) ] := True;
        if (Pos(NewCharSet[Count],FForbidMidWord) = 0) then
        begin
            FBCharSet[ Ord(NewCharSet[Count]) ] := True;
        end;
    end;
    for Count := 1 to Length(FForbidEnd) do
    begin
        FBForbidEnd[ Ord(FForbidEnd[Count]) ] := True;
    end;
end;

(*************************************************************)

procedure TMainParsingEngine.SetMidWord( NewForbidMidWord:String );
begin
    FForbidMidWord  := NewForbidMidWord;
    SetCharSet( CharSet );
end;

(*************************************************************)

procedure TMainParsingEngine.SetForbidEnd( NewForbidEnd:String );
begin
    FForbidEnd  := NewForbidEnd;
    SetCharSet( CharSet );
end;

(*************************************************************)

procedure TMainParsingEngine.SetFrenchExceptions( NewValue:Boolean );
var
    Index   :Integer;
begin
    FFrenchExceptions := NewValue;
    if (FFrenchExceptions) then
    begin
        ForbidMidWord := ForbidMidWord + '''';
    end
    else
    begin
        Index := pos( '''', FForbidMidWord );
        if (Index > 0) then
        begin
            delete( FForbidMidWord, Index, 1 );
        end;
        ForbidMidWord := FForbidMidWord;
    end;
end;

(*************************************************************)

procedure TMainParsingEngine.Initialize( Parser:TControlParser; CheckType:LongInt );
var
    XStart, YStart, XEnd, YEnd  :LongInt;
begin
    FParser := Parser;

    if (Assigned(FParser)) then
    begin
        FParser.GetSelectionPosition( XStart, YStart, XEnd, YEnd );

        if (CheckType = CheckType_Selected) then
        begin
            AdjustToPosition( XStart, YStart );
            FParser.SetPosition( XEnd, YEnd, ptEnd );
        end
        else if (CheckType = CheckType_FromCursor) then
        begin
            AdjustToPosition( XStart, YStart );
        end
        else if (CheckType = CheckType_All) then
        begin
            FParser.SetPosition( 0, 0, ptCurrent );
        end
        else if (CheckType = CheckType_Current) then
        begin
            // No adjusting the parser
        end;
    end;
end;

(*************************************************************)

procedure TMainParsingEngine.AdjustToPosition( XPos:LongInt; YPos:LongInt );
begin
    FParser.SetPosition( XPos, YPos, ptCurrent );

    // Back us up to the first character that isn't in our character set

    while (FBCharSet[ Ord(FParser.GetChar) ]) do
    begin
        if (not FParser.MovePrevious) then
        begin
            break;
        end;
    end;
end;

(*************************************************************)

function TMainParsingEngine.NextWord:String;
var
    CurrentChar         :Char;
    FBreak              :Boolean;
    FIgnore             :Boolean;
    FAbbrev             :Boolean;
    FAdjustForbidEnd    :Boolean;
begin
    repeat
        Result      := '';

        // First find the word start position

        repeat
            CurrentChar := FParser.GetChar;

            FIgnore := False;
            if (Assigned(FOnInlineIgnore)) then
            begin
                FOnInlineIgnore( CurrentChar, FParser, FIgnore );
                if (FIgnore) then
                begin
                    continue;
                end;
            end;

            if (FBStartCharSet[ Ord(CurrentChar) ]) then
            begin
                if (Pos( CurrentChar, FForbidStart ) = 0) then
                begin
                    break;
                end;
            end;
            if (not FParser.MoveNext) then
            begin
                exit;
            end;
        until (false);

        // OK, Now collect the word itself

        Result      := CurrentChar;
        FAbbrev     := False;

        repeat
            if (not FParser.MoveNext) then
            begin
                if (not FAllowIncompleteLastWord) then
                begin
                    Result := '';
                end;
                break;
            end;
            CurrentChar := FParser.GetChar;
            if (not FBCharSet[ Ord(CurrentChar) ]) then
            begin
                // OK, now for one of our first parser overrides of the default
                // parsing.  If the word ended with a '.', then we check the
                // character after the word to see if its in the character set.
                // If it is, then we consider this a single word, instead of
                // two words.

                FBreak := True;

                if  (FAllowMidPeriod) and
                    (CurrentChar = '.') then
                begin
                    FParser.MoveNext;
                    if  (FBCharSet[ Ord(FParser.GetChar) ]) then
                    begin
                        FBreak := False;
                    end;
                    if (pos( '.', Result ) > 0) then
                    begin
                        FAbbrev := True;
                        FBreak  := False;
                    end;
                    FParser.MovePrevious;
                end;

                // For french, we almost always treat the apostrophe as a word
                // break... however, there are a couple of exceptions to this
                // rule which we handle here...

                if  (FFrenchExceptions) and
                    (CurrentChar = '''') then
                begin
                    if  (AnsiLowercase(Result) = 'aujourd') or
                        (AnsiLowercase(Result) = 'entr')        then
                    begin
                        FBreak := False;
                    end;
                end;

                if (FBreak) then
                begin
                    break;
                end;

            end;
            Result := Result + CurrentChar;
        until (false);

        // If the word ends with characters that we've outlawed words ending
        // with, then we delete them and back up the parsing position

        FAdjustForbidEnd    := FAbbrev and FBForbidEnd[ Ord('.') ];
        if (FAdjustForbidEnd) then
        begin
            FBForbidEnd[ Ord('.') ] := False;
        end;

        while ((Result <> '') and (FBForbidEnd[ Ord( Result[ Length(Result) ] ) ])) do
        begin
            delete( Result, Length(Result), 1 );
            FParser.MovePrevious;
        end;

        if (FAdjustForbidEnd) then
        begin
            FBForbidEnd[ Ord('.') ] := True;
        end;

        // Lets verify the word through the ignore phase

        FIgnore := False;
        if (Assigned(FOnPreCheckIgnore)) then
        begin
            FOnPreCheckIgnore( Result, FParser, FIgnore );
        end;

    Until (not FIgnore);

    // We should now have either our word or an empty string to return

    FWord := Result;
end;

(*************************************************************)


end.

