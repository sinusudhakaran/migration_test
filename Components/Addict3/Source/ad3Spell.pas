{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10857: ad3Spell.pas 
{
{   Rev 1.6    1/27/2005 2:14:20 AM  mnovak
}
{
{   Rev 1.5    20/12/2004 3:24:28 pm  Glenn
}
{
{   Rev 1.4    8/31/2004 2:41:34 AM  mnovak
{ Handle dialog parenting slightly differently
}
{
{   Rev 1.3    2/21/2004 11:59:50 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.2    12/3/2003 1:03:36 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.1    11/25/2003 9:15:04 PM  mnovak
{ Use new TControlParser2 method to setup initial spelling dialog parenting.
}
{
{   Rev 1.0    8/25/2003 1:01:46 AM  mnovak
}
{
{   Rev 1.2    7/30/2002 12:07:12 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.1    26/06/2002 4:45:24 pm  glenn
{ Form Fixes, Font Fix, D7 Support
}
(*************************************************************

Addict 3.4,  (c) 1996-2005, Addictive Software
Contact: addictsw@addictivesoftware.com

TAddictSpell3 Component

History:
7/28/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3Spell;

{$I addict3.inc}

interface

uses
    windows, Forms, SysUtils, Classes, controls, graphics, stdctrls, comctrls,
    {$IFDEF Delphi5AndAbove} contnrs, {$ENDIF}
    ad3Util,
    ad3ParserBase,
    ad3SpellBase,
    ad3CustomDictionary,
    ad3ConfigurationDialog,
    ad3CustomDictionariesDialog,
    ad3CustomDictionaryEditDialog,
    ad3SpellDialog;

type

    //************************************************************
    // AddictSpell Component
    //************************************************************

    TAddictSpell3 = class(TAddictSpell3Base)
    private
    protected

        FUIFontControls         :TFont;
        FUIFontText             :TFont;
        FUIUseFonts             :Boolean;

    protected

	   // Dialog Utility Funtions

	   procedure CreateSpellDialog; override;
	   procedure SetUIFontControls (const Value : TFont);
	   procedure SetUIFontText (const Value : TFont);

    public

	   {$IFNDEF T2H}
	   constructor Create( AOwner:TComponent ); override;
	   destructor Destroy; override;
	   {$ENDIF}

	   // Dialog control callbacks

	   {$IFNDEF T2H}
	   procedure InternalSetup( AOwner:TComponent ); override;
	   procedure InternalSetupCustomDictionaries( AOwner:TComponent ); override;
	   procedure InternalEditCustomDictionary( AOwner:TComponent; CustomDictionary:TCustomDictionary ); override;
	   procedure InternalSetupAddDictionaryDir( AOwner:TComponent ); override;
	   procedure SetupFormFonts( Dialog:TForm; ApplyTextFont:Boolean ); virtual;
	   {$ENDIF}

    published
	   property UILanguageFontControls:TFont read FUIFontControls Write SetUIFontControls;
	   property UILanguageFontText:TFont read FUIFontText write SetUIFontText;
	   property UILanguageUseFonts:Boolean read FUIUseFonts write FUIUseFonts;
    end;

implementation

uses
    ad3SpellLanguages,
    ad3WinAPIParser,
    ActiveX,
    ShlObj;


//************************************************************

constructor TAddictSpell3.Create( AOwner:TComponent );
begin
    inherited Create( AOwner );

    FSpellUIType    := suiDialog;

    FUIFontControls := TFont.Create;

    FUIFontText     := TFont.Create;
    FUIUseFonts     := False;
end;

//************************************************************
procedure TAddictSpell3.SetUIFontControls (const Value : TFont);
begin
	FUIFontControls.Assign (Value);
end;
//************************************************************
procedure TAddictSpell3.SetUIFontText (const Value : TFont);
begin
	FUIFontText.Assign (Value);
end;
//************************************************************

destructor TAddictSpell3.Destroy;
begin
    FUIFontText.Free;
    FUIFontControls.Free;

    inherited Destroy;
end;

//************************************************************

procedure TAddictSpell3.SetupFormFonts( Dialog:TForm; ApplyTextFont:Boolean );
var
    Index   :LongInt;
    Control :TControl;
    Font    :TFont;
begin
    if (Assigned(Dialog)) and FUIUseFonts then
    begin
        for Index := 0 to Dialog.ComponentCount - 1 do
        begin
            if not(Dialog.Components[Index] is TControl) then
                continue;

            Control := (Dialog.Components[Index] as TControl);
            Font    := nil;

            if (Control is TLabel) then
                Font := (Control as TLabel).Font;
            if (Control is TButton) then
                Font := (Control as TButton).Font;
            if (Control is TCheckbox) then
                Font := (Control as TCheckbox).Font;
            if (Control is TGroupBox) then
                Font := (Control as TGroupBox).Font;
            if (Control is TPageControl) then
                Font := (Control as TPageControl).Font;

            if (Assigned(Font)) then
            begin
                Font.Assign( FUIFontControls );
                continue;
            end;

            if (Control is TListView) then
                Font := (Control as TListView).Font;
            if (Control is TListBox) then
                Font := (Control as TListBox).Font;
            if (Control is TEdit) then
                Font := (Control as TEdit).Font;
            if (Control is TCombobox) then
                Font := (Control as TComboBox).Font;

            if (Assigned(Font)) then
            begin
                if (ApplyTextFont) then
                begin
                    Font.Assign( FUIFontText );
                end
                else
                begin
                    Font.Assign( FUIFontControls );
                end;
            end;
        end;

    end;
end;



//************************************************************
// Dialog Control Callbacks
//************************************************************

procedure TAddictSpell3.InternalSetup( AOwner:TComponent );
var
    ConfigDialog    :TSpellCheckConfigDialog;
begin
    inherited InternalSetup( AOwner );

    if (not Assigned( FOnShowConfigDialog )) then
    begin
        ConfigDialog := TSpellCheckConfigDialog.Create( AOwner );
        if (Assigned(ConfigDialog)) then
        begin
            try
                SetupFormFonts( ConfigDialog, False );
                SetupDialogControl( ConfigDialog, nil );
                ConfigDialog.HelpFile       := FHelpFile;
                ConfigDialog.HelpContext    := FHelpCtxConfigDialog;
                ConfigDialog.ShowModal;
            finally
                ConfigDialog.Free;
            end;

            OptimizeMainDictionaryOrder;
        end;
    end;
end;

//************************************************************

procedure TAddictSpell3.InternalSetupCustomDictionaries( AOwner:TComponent );
var
    Dialog  :TCustomDictionariesDialog;
begin
    inherited InternalSetupCustomDictionaries( AOwner );

    if (not Assigned( FOnShowCustomDialog )) then
    begin
        Dialog := TCustomDictionariesDialog.Create( AOwner );
        if (Assigned(Dialog)) then
        begin
            try
                SetupFormFonts( Dialog, False );
                SetupDialogControl( Dialog, nil );
                Dialog.HelpFile     := FHelpFile;
                Dialog.HelpContext  := FHelpCtxDictionariesDialog;
                Dialog.ShowModal;
            finally
                Dialog.Free;
            end;
        end;
    end;
end;

//************************************************************

procedure TAddictSpell3.InternalEditCustomDictionary( AOwner:TComponent; CustomDictionary:TCustomDictionary );
var
    EditDialog  :TCustomDictionaryEditDialog;
begin
    inherited InternalEditCustomDictionary( AOwner, CustomDictionary );

    if (not Assigned( FOnShowEditDialog )) then
    begin
        EditDialog  := TCustomDictionaryEditDialog.Create( AOwner );
        if (Assigned(EditDialog)) then
        begin
            try
                SetupFormFonts( EditDialog, True );
                SetupDialogControl( EditDialog, CustomDictionary );
                EditDialog.HelpFile     := FHelpFile;
                EditDialog.HelpContext  := FHelpCtxDictionaryEditDialog;
                EditDialog.ShowModal;
                FireConfigurationChanged( True );
            finally
                EditDialog.Free;
            end;
        end;
    end;
end;

//************************************************************

procedure TAddictSpell3.InternalSetupAddDictionaryDir( AOwner:TComponent );
var
    BrowseInfo  :TBrowseInfo;
    Buffer      :PChar;
    ItemIDList  :PItemIDList;
    ShellMalloc :IMalloc;
begin
    inherited InternalSetupAddDictionaryDir( AOwner );

    if (not Assigned(FOnShowAddDictionaryDir)) then
    begin
        ShellMalloc := nil;
        ZeroMemory( @BrowseInfo, sizeof(BrowseInfo) );
        if  (SUCCEEDED(ShGetMalloc(ShellMalloc))) and
            (ShellMalloc <> nil) then
        begin
            Buffer := ShellMalloc.Alloc(MAX_PATH);
            try
                if (AOwner.Owner is TWinControl) then
                begin
                    BrowseInfo.hwndOwner    := (AOwner.Owner as TWinControl).Handle;
                end
                else
                begin
                    BrowseInfo.hwndOwner    := Application.Handle;
                end;

                BrowseInfo.pidlRoot         := nil;
                BrowseInfo.pszDisplayName   := Buffer;
                BrowseInfo.lpszTitle        := PChar(GetString(lsDlgBrowseForMainTitle));
                BrowseInfo.ulFlags          := BIF_RETURNONLYFSDIRS or BIF_EDITBOX;

                ItemIDList := ShBrowseForFolder(BrowseInfo);

                if (ItemIDList <> nil) then
                begin
                    ShGetPathFromIDList(ItemIDList, Buffer);
                    ShellMalloc.Free(ItemIDList);

                    FConfiguration.NewDictionaryPaths.Add( Buffer );
                end;

            finally
                ShellMalloc.Free(Buffer);
            end;
        end;
    end;
end;

//************************************************************

procedure TAddictSpell3.CreateSpellDialog;
var
    OwnerCtrl   :TComponent;
begin
    OwnerCtrl   := Self;

    // OK, we really want to parent this to the dialog that the control we're
    // bringing the dialog up for is on.  However, we won't always know this,
    // but we make a query to the parser to see if we can determine it.

    if  Assigned(FParser) and
        (FParser is TControlParser2) and
        ((FParser as TControlParser2).GetControl <> nil) then
    begin
        OwnerCtrl := (FParser as TControlParser2).GetControl;
    end;

    while (assigned(OwnerCtrl) and not(OwnerCtrl is TForm)) do
    begin
        OwnerCtrl := OwnerCtrl.Owner;
    end;

    if (not(Assigned(OwnerCtrl))) then
    begin
        OwnerCtrl := Self;
    end;

    FDialogForm := TForm(TSpellDialog.Create( OwnerCtrl ));
    SetupFormFonts( FDialogForm, True );
end;



end.

