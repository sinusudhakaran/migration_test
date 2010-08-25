{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10869: ad3Thesaurus.pas 
{
{   Rev 1.4    1/27/2005 2:14:24 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:40 pm  Glenn
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

TThesaurus3 Component

History:
9/23/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit ad3Thesaurus;

{$I addict3.inc}

interface

uses
    windows, Forms, SysUtils, Classes, controls,
    {$IFDEF Delphi5AndAbove} contnrs, {$ENDIF}
    ad3Util,
    ad3ThesaurusBase,
    ad3ThesaurusDialog;

type

    //************************************************************
    // TThesaurus3 Component
    //************************************************************

    TThesaurus3 = class(TThesaurus3Base)
    private
    protected
        // Dialog Utility Funtions

        procedure CreateThesaurusDialog; override;

    public
        {$IFNDEF T2H}
        constructor Create( AOwner:TComponent ); override;
        {$ENDIF}

    published
    end;

implementation


//************************************************************
// TThesaurus3 Component
//************************************************************

constructor TThesaurus3.Create( AOwner:TComponent );
begin
    inherited Create( AOwner );
end;


//************************************************************
// Dialog Utility Callbacks
//************************************************************

procedure TThesaurus3.CreateThesaurusDialog;
begin
    FDialogForm := TForm(TThesDialog.Create( Self ));
end;



end.

