{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10885: addict3.pas 
{
{   Rev 1.4    1/27/2005 2:14:26 AM  mnovak
}
{
{   Rev 1.3    20/12/2004 3:24:50 pm  Glenn
}
{
{   Rev 1.2    2/22/2004 12:00:04 AM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.1    12/3/2003 1:03:54 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:58 AM  mnovak
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

Registration Unit

History:
7/28/00     - Michael Novak     - Initial Write
3/9/01      - Michael Novak     - v3 Official Release

**************************************************************)

unit addict3;

{$I addict3.inc}

interface

{$R ADDICT3.DCR}

uses
    classes,
    ad3SpellBase,
    ad3Spell,
    ad3ConfigurationDialogCtrl,
    ad3ThesaurusBase,
    ad3Thesaurus,
    ad3ThesaurusDialogCtrl,
    ad3RichEdit
    ,ad3LiveAutospell
    ;

procedure Register;

implementation

procedure Register;
begin
    RegisterComponents('Addict',    [   TAddictSpell3,
                                        TAddictSpell3Base,
                                        TThesaurus3,
                                        TThesaurus3Base,
                                        TConfigurationDialogCtrl,
                                        TThesaurusDialogCtrl,
                                        TAddictRichEdit
                                        ,TAddictAutoLiveSpell
                                    ]
                        );
end;

end.
