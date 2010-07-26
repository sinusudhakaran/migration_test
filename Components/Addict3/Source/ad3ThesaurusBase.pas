{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10871: ad3ThesaurusBase.pas 
{
{   Rev 1.4    1/27/2005 2:14:24 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:40 pm  Glenn
}
{
{   Rev 1.2    2/22/2004 12:00:00 AM  mnovak
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

TThesaurus3Base Component - Base thesaurus component class

History:
9/22/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3ThesaurusBase;

{$I addict3.inc}

interface

uses
    classes, windows, forms, controls, sysutils,
    {$IFDEF Delphi5AndAbove} contnrs, {$ENDIF}
    ad3Util,
    ad3ThesaurusFile,
    ad3ThesaurusDialogCtrl,
    ad3ParserBase,
    ad3ParseEngine,
    ad3ThesaurusLanguages,
    ad3WinAPIParser;

type

    //************************************************************
    // Thesaurus Base Component
    //************************************************************

    TDialogDoubleClickAction    = ( dcaNone, dcaReplace, dcaLookup );
    
    TCustomThesaurusDialogEvent = procedure( Sender:TObject; var ThesaurusForm:TForm; Create:Boolean ) of object;
    TThesaurusGetStringEvent    = procedure( Sender:TObject; LanguageString:TThesaurusLanguageString; var Text:String ) of object;

    TThesaurus3Base = class(TComponent)
    private
    protected

        // Runtime

        FParsingEngine          :TParsingEngine;
        FThesaurusFile          :TThesaurusFile;
        FInLookup               :Boolean;
        FDialogPosition         :TRect;
        FDialogForm             :TForm;
        FDialogCtrl             :TThesaurusDialogCtrl;
        FOldCursor              :TCursor;

        // Event re-directs

        FOldOnShow              :TNotifyEvent;

        // Public Properties

        FFilename               :String;
        FSortedLists            :Boolean;
        FDoubleClickAction      :TDialogDoubleClickAction;
        FReplacementWord        :String;
        FUILanguage             :TThesaurusLanguageType;
        FCommandsEnabled        :TThesaurusDialogCommands;
        FCommandsVisible        :TThesaurusDialogCommands;
        FHelpFile               :String;
        FHelpCtxThesaurusDialog :THelpContext;

        // Public Events

        FOnCreateThesaurusDialog    :TCustomThesaurusDialogEvent;
        FOnPromptLookup             :TPromptLookupEvent;
        FOnPromptContext            :TPromptContextEvent;
        FOnBeforeChange             :TNotifyEvent;
        FOnGetString                :TThesaurusGetStringEvent;

    protected

        // Property read/write functions

        procedure WriteFilename( NewFilename:String ); virtual;
        procedure WriteParsingEngine( NewEngine:TParsingEngine ); virtual;
        function ReadVersion:String;
        procedure WriteVersion( NewVersion:String );

        // Utility Functions

        procedure PlaceDialog; virtual;
        function LookupWordInternal( Word:String ):String; virtual;
        function SetupDialogControl( Dialog:TForm ):TThesaurusDialogCtrl; virtual;
        procedure FirePromptLookup; virtual;

        // Dialog Events

        procedure Form_OnShow( Sender:TObject ); virtual;

        // Functions for override...

        procedure CreateThesaurusDialog; virtual;

    public

        {$IFNDEF T2H}
        constructor Create( AOwner:TComponent ); override;
        destructor Destroy; override;
        {$ENDIF}

        // public properties

        property ParsingEngine:TParsingEngine read FParsingEngine write WriteParsingEngine;
        property ThesaurusFile:TThesaurusFile read FThesaurusFile;
        property ReplacementWord:String read FReplacementWord write FReplacementWord;

        // public methods

        function LookupParser( Parser:TControlParser ):Boolean; virtual;
        function LookupWinControl( Control:TWinControl ):Boolean; virtual;
        function LookupWord( Word:String ):String; virtual;

        function GetString( LanguageString:TThesaurusLanguageString ):String; virtual;

        procedure Lookup_SetContext( Index:Integer ); virtual;
        procedure Lookup_LookupWord( Word:String ); virtual;
        procedure Lookup_ReplaceWord( Word:String ); virtual;
        procedure Lookup_DoubleClickWord( Word:String ); virtual;
        procedure Lookup_Cancel; virtual;

    published

        // published properties

        property Filename:String read FFilename write WriteFilename;
        property SortedLists:Boolean read FSortedLists write FSortedLists;
        property DoubleClickAction:TDialogDoubleClickAction read FDoubleClickAction write FDoubleClickAction;
        property UILanguage:TThesaurusLanguageType read FUILanguage write FUILanguage;
        property CommandsEnabled:TThesaurusDialogCommands read FCommandsEnabled write FCommandsEnabled;
        property CommandsVisible:TThesaurusDialogCommands read FCommandsVisible write FCommandsVisible;
        property HelpFile:String read FHelpFile write FHelpFile;
        property HelpCtxThesaurusDialog:THelpContext read FHelpCtxThesaurusDialog write FHelpCtxThesaurusDialog;

        property Version:String read ReadVersion write WriteVersion stored false;

        // events

        //#<Events>
        property OnCreateThesaurusDialog:TCustomThesaurusDialogEvent read FOnCreateThesaurusDialog write FOnCreateThesaurusDialog;
        property OnPromptLookup:TPromptLookupEvent read FOnPromptLookup write FOnPromptLookup;
        property OnPromptContext:TPromptContextEvent read FOnPromptContext write FOnPromptContext;
        property OnBeforeChange:TNotifyEvent read FOnBeforeChange write FOnBeforeChange;
        property OnGetString:TThesaurusGetStringEvent read FOnGetString write FOnGetString; 
        //#</Events>
    end;


implementation


//************************************************************
// Thesaurus Base Component
//************************************************************

constructor TThesaurus3Base.Create( AOwner:TComponent );
begin
    inherited Create( AOwner );

    FParsingEngine  := TMainParsingEngine.Create;

    FFilename               := '%AppDir%\Roget.adt';
    FSortedLists            := False;
    FDoubleClickAction      := dcaLookup;
    FReplacementWord        := '';
    FUILanguage             := ltEnglish;
    FCommandsEnabled        := [ tdcLookedUp, tdcPrevious, tdcLookup, tdcReplace, tdcClose ];
    FCommandsVisible        := [ tdcLookedUp, tdcPrevious, tdcLookup, tdcReplace, tdcClose ];
    FHelpFile               := '';
    FHelpCtxThesaurusDialog := 0;

    FThesaurusFile          := TThesaurusFile.Create;
    FThesaurusFile.Filename := ExpandBasicVars( FFilename );
    FInLookup               := False;
    FDialogPosition         := Rect( -1, -1, -1, -1 );
    FDialogForm             := nil;
    FDialogCtrl             := nil;

    FOldOnShow              := nil;

    FOnCreateThesaurusDialog    := nil;
    FOnPromptLookup             := nil;
    FOnPromptContext            := nil;
    FOnBeforeChange             := nil;
    FOnGetString                := nil;

    CheckTrialVersion;
end;

//************************************************************

destructor TThesaurus3Base.Destroy;
begin
    FThesaurusFile.Free;
    FParsingEngine.Free;

    inherited Destroy;
end;


//************************************************************
// Property read/write functions
//************************************************************

procedure TThesaurus3Base.WriteFilename( NewFilename:String );
begin
    FFilename   := NewFilename;

    if (csDesigning in ComponentState) then
    begin
        exit;
    end;

    FThesaurusFile.Filename := ExpandBasicVars( FFilename );
end;

//************************************************************

procedure TThesaurus3Base.WriteParsingEngine( NewEngine:TParsingEngine );
begin
    if (Assigned(NewEngine)) then
    begin
        FParsingEngine.Free;
        FParsingEngine := NewEngine;
    end;
end;

//************************************************************

function TThesaurus3Base.ReadVersion:String;
begin
    Result := GetAddictVersion;
end;

//************************************************************

procedure TThesaurus3Base.WriteVersion( NewVersion:String );
begin
end;



//************************************************************
// Functions for override...
//************************************************************

procedure TThesaurus3Base.CreateThesaurusDialog;
begin
    FDialogForm := nil;
end;




//************************************************************
// Utility Functions
//************************************************************

procedure TThesaurus3Base.PlaceDialog;
begin
    if (Assigned( FDialogForm )) then
    begin
        if (FDialogPosition.Left = -1) and (FDialogPosition.Top = -1) then
        begin
            FDialogForm.Position := {$IFDEF Delphi5AndAbove} poOwnerFormCenter {$ELSE} poScreenCenter {$ENDIF};
        end
        else
        begin
            AdjustDialogToRect( FDialogForm, FDialogPosition, True, True );
        end;
    end;
end;

//************************************************************

function TThesaurus3Base.LookupWordInternal( Word:String ):String;
var
    OldLoaded   :Boolean;
begin
    if (FInLookup) then
    begin
        exit;
    end;

    FInLookup   := True;

    OldLoaded   := FThesaurusFile.Loaded;

    FOldCursor      := Screen.Cursor;
    Screen.Cursor   := crHourglass;
    try
        FThesaurusFile.LookupWord( Word );

        if (FThesaurusFile.Loaded) then
        begin
            // Create the thesaurus dialog

            if (Assigned( FOnCreateThesaurusDialog )) then
            begin
                FOnCreateThesaurusDialog( Self, FDialogForm, True );
            end
            else
            begin
                CreateThesaurusDialog;
            end;

            // Now find the dialog control component

            FReplacementWord := '';

            if (Assigned( FDialogForm )) then
            begin
                FDialogForm.HelpFile    := FHelpFile;
                FDialogForm.HelpContext := FHelpCtxThesaurusDialog;

                FOldOnShow          := FDialogForm.OnShow;
                FDialogForm.OnShow  := Form_OnShow;

                FDialogCtrl         := SetupDialogControl( FDialogForm );

                PlaceDialog;

                FDialogForm.ShowModal;

                FDialogForm.OnShow          := FOldOnShow;
                FOldOnShow                  := nil;
            end
            else
            begin
                FirePromptLookup;
            end;

            Result              := FReplacementWord;

            FDialogCtrl         := nil;

            // Free the dialog .. (user or default)

            if (Assigned( FOnCreateThesaurusDialog )) then
            begin
                FOnCreateThesaurusDialog( Self, FDialogForm, False );
            end
            else
            begin
                FDialogForm.Release;
            end;
            FDialogForm         := nil;
        end;
    finally
        Screen.Cursor   := FOldCursor;
    end;

    FThesaurusFile.Loaded := OldLoaded;

    FInLookup   := False;
end;

//************************************************************

function TThesaurus3Base.SetupDialogControl( Dialog:TForm ):TThesaurusDialogCtrl;
var
    Index   :LongInt;
begin
    Result := nil;
    for Index := 0 to Dialog.ComponentCount - 1 do
    begin
        if (Dialog.Components[Index] is TThesaurusDialogCtrl) then
        begin
            TThesaurusDialogCtrl(Dialog.Components[Index]).Thesaurus := Self;
            Result := TThesaurusDialogCtrl(Dialog.Components[Index]);
            break;
        end;
    end;
end;

//************************************************************

function ContextSortProc( Item1, Item2: Pointer ):Integer;
begin
    if (TThesaurusEntry(Item1).ContextWord = TThesaurusEntry(Item2).ContextWord) then
    begin
        Result := 0;
    end
    else if (TThesaurusEntry(Item1).ContextWord < TThesaurusEntry(Item2).ContextWord) then
    begin
        Result := -1;
    end
    else
    begin
        Result := 1;
    end;
end;

procedure TThesaurus3Base.FirePromptLookup;
begin
    if (FSortedLists) then
    begin
        FThesaurusFile.Contexts.Sort( ContextSortProc );
    end;

    if (Assigned(FOnPromptLookup)) then
    begin
        FOnPromptLookup( Self, FThesaurusFile.ContextWord, FThesaurusFile.Contexts );
    end;
    if (Assigned(FDialogCtrl)) and (Assigned(FDialogCtrl.OnPromptLookup)) then
    begin
        FDialogCtrl.OnPromptLookup( Self, FThesaurusFile.ContextWord, FThesaurusFile.Contexts );
    end;
end;



//************************************************************
// Dialog Events
//************************************************************

procedure TThesaurus3Base.Form_OnShow( Sender:TObject );
begin
    FirePromptLookup;

    if (Assigned(FOldOnShow)) then
    begin
        FOldOnShow( Sender );
    end;

    Screen.Cursor := FOldCursor;
end;




//************************************************************
// Public Methods
//************************************************************

function TThesaurus3Base.LookupParser( Parser:TControlParser ):Boolean;
var
    Word        :String;
    Replacement :String;
begin
    if (Parser = nil) then
    begin
        Result := False;
        exit;
    end;

    FParsingEngine.Initialize( Parser, CheckType_FromCursor );

    Word    := FParsingEngine.NextWord;
    Result  := (Word <> '');

    if (Result) then
    begin
        Parser.SelectWord( Length(Word) );
        Parser.GetSelectionScreenPosition( FDialogPosition );

        Replacement := LookupWordInternal( Word );

        if (Replacement <> '') then
        begin
            if (Assigned(FOnBeforeChange)) then
            begin
                FOnBeforeChange( Self );
            end;
            Parser.ReplaceWord( Replacement, ReplacementState_Replace );
        end;
    end;
end;

//************************************************************

function TThesaurus3Base.LookupWinControl( Control:TWinControl ):Boolean;
var
    Parser  :TWinAPIControlParser;
begin
    Parser := TWinAPIControlParser.Create;
    Parser.Initialize( Control );
    Result := LookupParser( Parser );
    Parser.Free;
end;

//************************************************************

function TThesaurus3Base.LookupWord( Word:String ):String;
begin
    FDialogPosition := Rect( -1, -1, -1, -1 );
    Result          := LookupWordInternal( Word );
end;

//************************************************************

function TThesaurus3Base.GetString( LanguageString:TThesaurusLanguageString ):String;
begin
    Result := ad3ThesaurusLanguages.GetString( LanguageString, FUILanguage );
    if (Assigned(FOnGetString)) then
    begin
        FOnGetString( Self, LanguageString, Result );
    end;
    if (LanguageString = lsThesaurus) then
    begin
        Result := ReplaceString( '%name%', FThesaurusFile.Name, Result );
    end;
end;

//************************************************************

procedure TThesaurus3Base.Lookup_SetContext( Index:Integer );
var
    Entry   :TThesaurusEntry;
    Kind    :Integer;
    Loop    :Integer;
    Max     :Integer;
begin
    if (Index >= 0) and (Index < FThesaurusFile.Contexts.Count) then
    begin
        Entry   := TThesaurusEntry(FThesaurusFile.Contexts[Index]);
        Kind    := Entry.ContextKind;

        if (Kind = 0) then
        begin
            Max := 1;
            for Loop := 1 to 4 do
            begin
                if (Entry.Words[Loop].IndexOf( AnsiLowercase(Entry.ContextWord) ) >= 0) then
                begin
                    Kind := Loop;
                    break;
                end;
                if (Entry.Words[Loop].Count > Entry.Words[Max].Count) then
                begin
                    Max := Loop;
                end;
            end;

            if (Kind = 0) then
            begin
                Kind := 1;
            end;
        end;

        if (FSortedLists) then
        begin
            Entry.Words[Kind].Sort;
        end;

        if (Assigned(FOnPromptContext)) then
        begin
            FOnPromptContext( Self, Entry.Words[Kind] );
        end;
        if (Assigned(FDialogCtrl)) and (Assigned(FDialogCtrl.OnPromptContext)) then
        begin
            FDialogCtrl.OnPromptContext( Self, Entry.Words[Kind] );
        end;
    end;
end;

//************************************************************

procedure TThesaurus3Base.Lookup_LookupWord( Word:String );
begin
    FThesaurusFile.LookupWord( Word );
    FirePromptLookup;
end;

//************************************************************

procedure TThesaurus3Base.Lookup_ReplaceWord( Word:String );
begin
    FReplacementWord := Word;

    if (Assigned( FDialogForm )) then
    begin
        FDialogForm.ModalResult := mrOK;
    end;
end;

//************************************************************

procedure TThesaurus3Base.Lookup_DoubleClickWord( Word:String );
begin
    if (FDoubleClickAction = dcaLookup) then
    begin
        Lookup_LookupWord( Word );
    end
    else if (FDoubleClickAction = dcaReplace) then 
    begin
        Lookup_ReplaceWord( Word );
    end;
end;

//************************************************************

procedure TThesaurus3Base.Lookup_Cancel;
begin
    if (Assigned( FDialogForm )) then
    begin
        FDialogForm.ModalResult := mrCancel;
    end;
end;



end.

