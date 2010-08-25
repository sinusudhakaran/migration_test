{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10875: ad3ThesaurusDialogCtrl.pas 
{
{   Rev 1.4    1/27/2005 2:14:24 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:44 pm  Glenn
}
{
{   Rev 1.2    2/22/2004 12:00:00 AM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:48 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:56 AM  mnovak
}
{
{   Rev 1.1    7/30/2002 12:07:14 AM  mnovak
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

Addict Thesaurus Dialog Control Component

History:
9/23/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3ThesaurusDialogCtrl;

{$I addict3.inc}

interface

uses
    Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
    {$IFDEF Delphi5AndAbove} contnrs, {$ENDIF}
    ad3Util,
    ad3ThesaurusLanguages;

type

    TThesaurusDialogCommand     = ( tdcLookedUp, tdcPrevious, tdcLookup, tdcReplace, tdcClose );
    TThesaurusDialogCommands    = set of TThesaurusDialogCommand;

    TPromptLookupEvent          = procedure( Sender:TObject; Word:String; ContextList:TObjectList ) of object;
    TPromptContextEvent         = procedure( Sender:TObject; Words:TStringList ) of object;

    TThesaurusDialogCtrl = class(TComponent)
    protected
        FAddictThesaurus        :Pointer;
        FCommandsEnabled        :TThesaurusDialogCommands;
        FCommandsVisible        :TThesaurusDialogCommands;

        FOnActivate             :TNotifyEvent;
        FOnPromptLookup         :TPromptLookupEvent;
        FOnPromptContext        :TPromptContextEvent;

    protected

        // Property read/write functions

        procedure WriteThesaurus( NewThesaurus:Pointer );
        function ReadVersion:String;
        procedure WriteVersion( NewVersion:String );

    public
        {$IFNDEF T2H}
        constructor Create( aowner:TComponent ); override;
        {$ENDIF}

        property Thesaurus:Pointer read FAddictThesaurus write WriteThesaurus;
        property CommandsEnabled:TThesaurusDialogCommands read FCommandsEnabled write FCommandsEnabled;
        property CommandsVisible:TThesaurusDialogCommands read FCommandsVisible write FCommandsVisible;

        procedure SetContext( Index:Integer );
        procedure LookupWord( Word:String );
        procedure ReplaceWord( Word:String );
        procedure DoubleClickWord( Word:String );
        procedure Cancel;

        function GetString( LanguageString:TThesaurusLanguageString ):String;

    published

        property Version:String read ReadVersion write WriteVersion stored false;

        // Public Events

        //#<Events>
        property OnPromptLookup:TPromptLookupEvent read FOnPromptLookup write FOnPromptLookup;
        property OnPromptContext:TPromptContextEvent read FOnPromptContext write FOnPromptContext;
        property OnActivate:TNotifyEvent read FOnActivate write FOnActivate;
        //#</Events>
    end;

implementation

uses
    ad3ThesaurusBase;


//************************************************************
// Thesaurus Dialog Control
//************************************************************

constructor TThesaurusDialogCtrl.Create( aowner:TComponent );
begin
    inherited Create(aowner);

    FAddictThesaurus    := nil;

    FOnPromptLookup     := nil;
    FOnPromptContext    := nil;
    FOnActivate         := nil;
end;


//************************************************************
// Property read/write functions
//************************************************************

procedure TThesaurusDialogCtrl.WriteThesaurus( NewThesaurus:Pointer );
begin
    if (not(Assigned(FAddictThesaurus))) then
    begin
        FAddictThesaurus    := NewThesaurus;

        if  (Assigned(FAddictThesaurus)) then
        begin
            FCommandsEnabled    := TThesaurus3Base(FAddictThesaurus).CommandsEnabled;
            FCommandsVisible    := TThesaurus3Base(FAddictThesaurus).CommandsVisible;

            if (Assigned(FOnActivate)) then
            begin
                FOnActivate( Self );
            end;
        end;
    end;
end;

//************************************************************

function TThesaurusDialogCtrl.ReadVersion:String;
begin
    Result := GetAddictVersion;
end;

//************************************************************

procedure TThesaurusDialogCtrl.WriteVersion( NewVersion:String );
begin
end;




//************************************************************
// Public Methods
//************************************************************

procedure TThesaurusDialogCtrl.SetContext( Index:Integer );
begin
    if (Assigned(FAddictThesaurus)) then
    begin
        TThesaurus3Base(FAddictThesaurus).Lookup_SetContext( Index );
    end;
end;

//************************************************************

procedure TThesaurusDialogCtrl.LookupWord( Word:String );
begin
    if (Assigned(FAddictThesaurus)) then
    begin
        TThesaurus3Base(FAddictThesaurus).Lookup_LookupWord( Word );
    end;
end;

//************************************************************

procedure TThesaurusDialogCtrl.ReplaceWord( Word:String );
begin
    if (Assigned(FAddictThesaurus)) then
    begin
        TThesaurus3Base(FAddictThesaurus).Lookup_ReplaceWord( Word );
    end;
end;

//************************************************************

procedure TThesaurusDialogCtrl.DoubleClickWord( Word:String );
begin
    if (Assigned(FAddictThesaurus)) then
    begin
        TThesaurus3Base(FAddictThesaurus).Lookup_DoubleClickWord( Word );
    end;
end;

//************************************************************

procedure TThesaurusDialogCtrl.Cancel;
begin
    if (Assigned(FAddictThesaurus)) then
    begin
        TThesaurus3Base(FAddictThesaurus).Lookup_Cancel;
    end;
end;

//************************************************************

function TThesaurusDialogCtrl.GetString( LanguageString:TThesaurusLanguageString ):String;
begin
    Result := '';
    if (Assigned(FAddictThesaurus)) then
    begin
        Result := TThesaurus3Base(FAddictThesaurus).GetString( LanguageString );
    end;
end;


end.

