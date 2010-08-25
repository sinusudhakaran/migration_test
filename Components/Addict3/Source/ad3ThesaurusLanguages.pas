{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10879: ad3ThesaurusLanguages.pas 
{
{   Rev 1.6    28/07/2005 2:04:58 pm  Glenn
{ Added Estonian Strings
}
{
{   Rev 1.5    1/27/2005 2:14:24 AM  mnovak
}
{
{   Rev 1.4    20/12/2004 3:24:46 pm  Glenn
}
{
{   Rev 1.3    2/22/2004 12:00:02 AM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.2    2/16/2004 6:35:46 PM  mnovak
{ Italian Updates
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

TAddictSpell3 Languages Module

History:
9/25/00     - Michael Novak         - Initial Write
3/9/01      - Michael Novak         - v3 Official Release
7/8/01      - Rafal Platek          - Polish translation
7/9/01      - Miloslav Skacel       - added TThesaurusLanguageType ltCzech
9/28/01     - Sverre Hårstadstrand  - Norwegian translation (Bokmål)

**************************************************************)

unit ad3ThesaurusLanguages;

{$I addict3.inc}

interface

type

    TThesaurusLanguageType = (
        ltEnglish,
        ltSwedish,
        ltGerman,
        ltRussian,
        ltCzech,
        ltDanish,
        ltNorwegianBok,
        ltPolish,
        ltItalian,
        ltEstonian );

    TThesaurusLanguageString = (

        lsThesaurus,                        // Thesaurus Dialog Title

        lsDlgLookedUp,                      // 'Looked Up:' label
        lsDlgContexts,                      // 'Contexts:' label
        lsDlgReplaceWith,                   // 'Replace With:' label
        lsDlgPrevious,                      // 'Previous' button
        lsDlgLookup,                        // 'Lookup' button
        lsDlgReplace,                       // 'Replace' button
        lsDlgClose,                         // 'Close' button

        lsDlgNotFound                       // '(not found)' context
        );

{$IFNDEF T2H}
function GetString( LangString:TThesaurusLanguageString; Language:TThesaurusLanguageType ):String;
{$ENDIF}

implementation

{$IFDEF AD3ENGLISHONLY}
{$DEFINE AD3NOSWEDISH}
{$DEFINE AD3NOGERMAN}
{$DEFINE AD3NORUSSIAN}
{$DEFINE AD3NOCZECH}
{$DEFINE AD3NODANISH}
{$DEFINE AD3NOPOLISH}
{$DEFINE AD3NONORWAYBOK}
{$DEFINE AD3NOITALIAN}
{$DEFINE AD3NOESTONIAN}
{$ENDIF}

function GetString( LangString:TThesaurusLanguageString; Language:TThesaurusLanguageType ):String;
begin
    Result := '';
    case (LangString) of
    lsThesaurus:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Thesaurus: %name%';     {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Thesaurus: %name%';     {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Thesaurus: %name%';     {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Òåçàóðóñ: %name%';      {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Thesaurus: %name%';     {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Ordbog: %name%';        {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Tezaurus: %name%';      {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Synonymordbok: %name%'; {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Thesaurus: %name%';     {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Tesaurus: %name%';      {$ENDIF}
        end;
    lsDlgLookedUp:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Looked &Up:';        {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Uppslaget ord:';     {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Nachgeschlagen:';    {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ñèíîíèìû &äëÿ:';     {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Nalezeno:';          {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Slået &Op:';         {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Wysz&ukany:';        {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Oppslått:';         {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Cercat&o';           {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Otsitud &sõna:';      {$ENDIF}
        end;
    lsDlgContexts:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Conte&xts:';         {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Betydelser:';        {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Bedeutungen:';       {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Çí&à÷åíèÿ:';         {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Konte&xt:';          {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Betydninger:';      {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Kontekst:';         {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Betydninger:';      {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Cont&esto';          {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Konte&kst:';      {$ENDIF}
        end;
    lsDlgReplaceWith:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Replace &With:';         {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Ersätt med:';            {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Ersetzen &mit:';         {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Çàìåíèòü c&èíîíèìîì:';   {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Zamìnit &èím:';          {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Erstat &Med:';           {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Za&mieñ na:';            {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Erstatt &med synonym:';  {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Sostituisci co&n';       {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Asen&dus:';              {$ENDIF}
        end;
    lsDlgPrevious:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Previous';          {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Tillbaka';           {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&Vorherige';         {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Íàçàä';             {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Pøedchozí';         {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Forrige';           {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Poprzedni';         {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Forrige';           {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Precedente';        {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Eelmine';           {$ENDIF}
        end;
    lsDlgLookup:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Lookup';        {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Slå upp';        {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&Nachschlagen';  {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Ïîèñê';         {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Vyhledat';      {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Slå op';        {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Szukaj';        {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Slå opp';       {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Ce&rca';         {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Otsi';      {$ENDIF}
        end;
    lsDlgReplace:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Replace';       {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Ersätt';         {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&Ersetzen';      {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Çàìåíèòü';      {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Zamìnit';       {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Erstat';        {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Zamieñ';        {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Erstatt';       {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Sostituisci';   {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Asenda';      {$ENDIF}
        end;
    lsDlgClose:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Close';     {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Stäng';      {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&Schließen'; {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Çàêðûòü';    {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Z&avøít';    {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Luk';       {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Zam&knij';   {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Lukk';      {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Chiudi';    {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Sulge';      {$ENDIF}
        end;
    lsDlgNotFound:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '(not found)';        {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := '(inget funnet)';     {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '(nicht gefunden)';   {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '(íåò âàðèàíòîâ)';    {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '(nenalezeno)';       {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '(Ej fundet)';        {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '(nie znaleziono';    {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '(ikke funnet)';      {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '(non trovato)';      {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '(ei leitud)';      {$ENDIF}
        end;
    end;
end;



end.

