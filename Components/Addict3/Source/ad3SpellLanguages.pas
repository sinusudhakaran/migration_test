{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10863: ad3SpellLanguages.pas
{
{   Rev 1.7    28/07/2005 2:04:54 pm  Glenn
{ Added Estonian Strings
}
{
{   Rev 1.6    28/07/2005 1:51:48 pm  Glenn
{ Improved German Strings
}
{
{   Rev 1.4    20/12/2004 3:24:34 pm  Glenn
}
{
{   Rev 1.3    2/21/2004 11:59:54 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.2    2/16/2004 6:35:44 PM  mnovak
{ Italian Updates
}
{
{   Rev 1.1    12/3/2003 1:03:42 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:52 AM  mnovak
}
{
{   Rev 1.3    7/30/2002 12:07:12 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.2    7/29/2002 10:47:32 PM  mnovak
{ Polish update
}
{
{   Rev 1.1    27/07/2002 10:11:40 pm  glenn
}
(*************************************************************

Addict 3.4,  (c) 1996-2005, Addictive Software
Contact: addictsw@addictivesoftware.com

TAddictSpell3 Languages Module

History:
8/13/00     - Michael Novak         - Initial Write
3/9/01      - Michael Novak         - v3 Official Release
7/8/01      - Rafal Platek          - Polish translation
7/9/01      - Miloslav Skacel       - added TSpellLanguageType ltCzech
9/28/01     - Sverre Hårstadstrand  - Norwegian translation (Bokmål)
12/9/03     - Stefano Spagna        - Italian translation
4/26/05     - Ilmar Kerm            - Estonian translation

**************************************************************)

unit ad3SpellLanguages;

{$I addict3.inc}

interface


type

    TSpellLanguageType = (
        ltEnglish,
        ltSwedish,
        ltBrPort,
        ltAfrikaans,
        ltGerman,
        ltSpanish,
        ltRussian,
        ltCzech,
        ltDutch,
        ltDanish,
        ltPolish,
        ltNorwegianBok,
        ltFrench,
        ltItalian,
        ltEstonian );

    TSpellLanguageString = (

        lsLiveSpelling,                     // check spelling as you type
	   lsLiveCorrect,                      // correct splling errors as you type
        lsIgnoreUpcase,                     // ignore uppercase
        lsIgnoreNumbers,                    // ignore numbers
        lsHTML,                             // ignore HTML
        lsInternet,                         // ignore Internet addresses
        lsQuoted,                           // ignore Quoted Lines
        lsAbbreviations,                    // ignore Abbreviations
        lsPrimaryOnly,                      // make suggestions from primary
        lsRepeated,                         // check for repeated words
        lsDUalCaps,                         // auto-correct DUal caps?

        lsConfirmation,                     // Confirmation dialog title
        lsRemoveCustomDict,                 // Remove this custom dict?

        lsIgnoreAllChangeAll,               // (Ignore All / Change All)

        lsSpelling,                         // Spell check and spell check completion title
        lsSpellingOptions,                  // Spelling options dialog title
        lsDictionaries,                     // Custom dictionaries dialog title
        lsIgnoreAllChangeAllTitle,          // Edit Dialog Caption for internal custom
        lsNewCustomTitle,                   // New Custom Dialog title

        lsDlgNotFound,                      // Not Found label
        lsDlgRepeatedWord,                  // Repeated Word label
        lsDlgReplaceWith,                   // Replace With label
        lsDlgSuggestions,                   // Suggestions label
        lsDlgUndo,                          // Undo button
        lsDlgOptions,                       // Options button
        lsDlgIgnoreAll,                     // Ignore All button
        lsDlgIgnore,                        // Ignore button
        lsDlgChangeAll,                     // Change All button
        lsDlgChange,                        // Change button
        lsDlgAdd,                           // Add button
        lsDlgAutoCorrect,                   // AutoCorrect button
        lsDlgHelp,                          // Help button
        lsDlgCancel,                        // Cancel Button
        lsDlgResetDefaults,                 // Reset Defaults Button

        lsDlgOptionsLabel,                  // Options groupbox label
        lsDlgDictionariesLabel,             // Dictionaries groupbox label
        lsDlgName,                          // Main Dictionaries name column
        lsDlgFilename,                      // Main Dictionaries filename column
        lsDlgCustomDictionary,              // Custom Dictionary combo label
	   lsDlgDictionaries,                  // Dictionaries button
        lsDlgBrowseForMain,                 // Browse for main dictionaries item
        lsDlgBrowseForMainTitle,            // Browse for main dictionaries title

        lsDlgCustomDictionaries,            // Custom Dictionaries group box
        lsDlgEdit,                          // Edit Button
        lsDlgDelete,                        // Delete Button
        lsDlgNew,                           // New Button
        lsDlgOK,                            // OK Button

        lsDlgNewCustom,                     // New Custom Edit label

        lsDlgAddedWords,                    // Added Words
        lsDlgAddedWordsExplanation,         // Added words explanation
        lsDlgIgnoreThisWord,                // Ignore This Word Label
        lsDlgAutoCorrectPairs,              // Auto-Corrected words
        lsDlgAutoCorrectPairsExplanation,   // Auto-Corrected words explanation
        lsDlgReplace,                       // Replace Label
        lsDlgWith,                          // With label
        lsDlgExcludedWords,                 // Excluded Words
        lsDlgExcludedWordsExplanation,      // Excluded words explanation
        lsDlgExcludeThisWord,               // Exclude this word label

        lsEndMessage,                       // The spell check end message
        lsWordsChecked,                     // The 'Words checked:' message
        lsEndSelectionMessage,              // The end-of-selection check message

        lsMnNoSuggestions,                  // No suggestions menu item
        lsMnIgnore,                         // Ignore menu item
        lsMnIgnoreAll,                      // Ignore all menu item
        lsMnAdd,                            // Add menu item
        lsMnChangeAll,                      // Change all menu item
        lsMnAutoCorrect,                    // Auto correct menu item
        lsMnSpelling                        // Spelling ... menu item
        );

{$IFNDEF T2H}
function GetString( LangString:TSpellLanguageString; Language:TSpellLanguageType ):String;
{$ENDIF}

implementation

{$IFDEF AD3ENGLISHONLY}
{$DEFINE AD3NOSWEDISH}
{$DEFINE AD3NOBRPORT}
{$DEFINE AD3NOGERMAN}
{$DEFINE AD3NOAFRIKAANS}
{$DEFINE AD3NOSPANISH}
{$DEFINE AD3NORUSSIAN}
{$DEFINE AD3NOCZECH}
{$DEFINE AD3NODUTCH}
{$DEFINE AD3NODANISH}
{$DEFINE AD3NOPOLISH}
{$DEFINE AD3NOFRENCH}
{$DEFINE AD3NONORWAYBOK}
{$DEFINE AD3NOITALIAN}
{$DEFINE AD3NOESTONIAN}
{$ENDIF}

function GetString( LangString:TSpellLanguageString; Language:TSpellLanguageType ):String;
begin
    Result := '';

    case (LangString) of
    lsLiveSpelling:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Check spelling as you type';                 {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Kontrollera stavningen när du skriver';      {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Verificar a ortografia enquanto escreve';    {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Gaan spel reëls na terwyl jy tik';           {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Automatische Rechtschreibprüfung';           {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Verificar la ortografía mientras escribe';   {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïðîâåðÿòü îð&ôîãðàôèþ ïðè ââîäå';            {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Kontrolovat pravopis pøi psaní';             {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Spelling controleren onder het typen';       {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'L&øbende stavekontrol';                      {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Sprawdzaj pisowniê podczas pisania';         {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Vérifier l''orthographe automatiquement';    {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Fortløpende stavekontroll';                  {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Correzione ortografica durante la digitazione';      {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:      Result := 'Õigekirja kontrolli kirjutamise ajal';     {$ENDIF}
        end;
    lsLiveCorrect:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Correct spelling errors as you type';                {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Rätta stavfel när du skriver';                       {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Corrigir erros de ortografia enquanto você escreve'; {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Maak spelling reg terwyl jy tik';                    {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Automatische Korrektur';                             {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Corregir errores ortográficos mientras escribe';     {$ENDIF}
	   {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Èñïðàâëÿòü ñëîâà ñ î&øèáêàìè ïðè ââîäå';             {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Opravovat chyby pøi psaní';                          {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Spellingsfouten verbeteren onder het typen';         {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Korriger stavefejl under indtastning';               {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Poprawiaj pisowniê podczas pisania';                 {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Corriger l''orthographe automatiquement';            {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Korriger stavefeil mens du skriver';                 {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Correggi errori di or&tografica durante la digitazione'; {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Õigekirjavead paranda kirjutamise ajal';             {$ENDIF}
        end;
    lsIgnoreUpcase:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Ignore words in &UPPERCASE';                 {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Ignorera ord med &STORA bokstäver';          {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Ignorar palavras escritas com &Maiúsculas';  {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Ignoreer woorde in &HOOFLETTERS';            {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Wörter in &Großbuchstaben ignorieren';       {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Ignorar palabras en &MAYÚSCULAS';            {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïðîïóñêàòü ñëîâà èç &ÏÐÎÏÈÑÍÛÕ áóêâ';        {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Ignorovat slova &VELKÝMI písmeny';           {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Woorden in hoofdletters negeren';            {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Ignorer ord &med kun store bogstaver';       {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Pomiñ wyrazy pisane &WIELKIMI literami';     {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Ignorer les mots en &majuscule';             {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Ignorer ord med &STORE bokstaver';           {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Ignora parole in &MAIUSCOLO';                {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Ignoreeri S&UURTÄHTEDEGA kirjutatud sõnu';      {$ENDIF}
        end;
    lsIgnoreNumbers:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Ignore words containing numbers';        {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Ignorera ord med siffror';               {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Ignorar palavras que contém números';    {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Ignoreer woorde met nommers';            {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Wörter mit Zahlen ignorieren';           {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Ignorar palabras que contengan números'; {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïðîïóñêàòü ñëîâà ñ &öèôðàìè';            {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Ignorovat slova obsahující èíslice';     {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Woorden met nummers negeren';            {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Ignorer ord med tal';                    {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Pomiñ wyrazy zawieraj¹ce liczby';        {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Ignorer les mots contenants des nombres';{$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Ignorer ord som inneholder &tall';       {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Ignora parole contenente n&umeri';       {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Ignoreeri numbreid sisaldavaid sõnu';    {$ENDIF}
        end;
    lsHTML:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Ignore markup languages (&HTML, XML, etc)';  {$ENDIF}
	   {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Ignorera &HTML, XML, etc';                   {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Ignorar &HTML, XML, etc';                    {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Ignoreer &HTML';                             {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&HTML ignorieren';                           {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Ignorar &HTML, XML, etc';                    {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïðîïóñêàòü &ðàçìåòêó HTML è XML';            {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Ignorovat znaèky &HTML, XML atd.';           {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := '&HTML negeren';                              {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Ignorer &filadresser (HTML, XML, etc';       {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Pomiñ znaczniki (&HTML, XML, itp.)';         {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Ignorer les languages &HTML, XML, etc';      {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Ignorer &HTML, XML o.l.';                    {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Ignora linguaggi marcati (&HTML, XML, ecc)'; {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Ignoreeri märgistuskeeli (&HTML, XML jt)';      {$ENDIF}
        end;
    lsInternet:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Ignore Internet addresses';          {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Ignorera Internetaddresser';         {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Ignorar endereços de Internet';      {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Ignoreer &Internet adresse';         {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Internet-Adressen ignorieren';       {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Ignorar direcciones de Internet';    {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïðîïóñêàòü àäðåñà &Èíòåðíåòà';       {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Ignorovat internetové adresy';       {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Internet adressen negeren';          {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Ignorer &Internet adresser';         {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Pomiñ adresy internetowe';           {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Ignorer les adresses Internet';      {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Ignorer Internettaddresser';         {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'I&gnora Indirizzi Internet';         {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Ignoreeri internetiaadresse';      {$ENDIF}
        end;
    lsQuoted:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Ignore quoted lines';                    {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Ignorera citerade rader';                {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Ignorar linhas entre aspas';             {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Ignoreer lyne tussen aanhalings tekens'; {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Zeilen in Anführungszeichen ignorieren'; {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Ignorar líneas entre comillas';          {$ENDIF}
	   {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïðîïóñêàòü öè&òèðîâàííûé òåêñò';         {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Ignorovat øádky v apostrofech';          {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Zinnen tussen aanhalingstekens negeren'; {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Ignorer linier i anførselstegn';         {$ENDIF}
	   {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Pomiñ linie w cudzys³owach';             {$ENDIF}
	   {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Ignorer les lignes en citation';    {$ENDIF}
	   {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Ignorer linjer i anførselstegn';         {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Ignora parola tra &virgolette';           {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Ignoreeri jutumärkides olevaid ridu';      {$ENDIF}
        end;
    lsAbbreviations:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Ignore abbreviations';       {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Ignorera förkortningar';     {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Ignorar abreviaturas';       {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Ignoreer afkortings';        {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Abkürzungen ignorieren';     {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Ignorar abreviaturas';       {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïðîïóñêàòü à&ááðåâèàòóðû';   {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Ignorovat zkratky';          {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'afkortingen negeren';        {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Ignorer f&orkortelser';      {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Pomiñ skróty';               {$ENDIF}
	   {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Ignorer les abréviations';   {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Ignorer forkortelser';       {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Ignora &abbreviazioni';       {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Ignoreeri lühendeid';      {$ENDIF}
        end;
    lsPrimaryOnly:
	   case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Suggest from main dictionaries only';            {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Föreslå ord endast ur huvudlexikon';             {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Sugerir somente dos dicionários principais';     {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Gebruik slegs die hoof woordeboeke';             {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Vorschläge nur aus Hauptwörterbuch';             {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Sugerir sólo de diccionarios principales';       {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïðåäëàãàòü òîëüêî èç &îñíîâíûõ ñëîâàðåé';        {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Nabízet pouze z hlavního slovníku';              {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Alleen van hoofd woordenboek' ;                  {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Kun forslag fra &hoved ordbøger';                {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Sugeruj tylko z g³ównych s³owników';             {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Suggérer du dictionnaire principal seulement';   {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'K&un forslag fra hovedordbøker';                  {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Suggerisci solo da&l dizionario principale';      {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Soovitused võta ainult peasõnastikust';          {$ENDIF}
        end;
    lsRepeated:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Prompt on repeated word';            {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Varna för upprepade ord';            {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Indagar sobre palavra repetida';     {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Abfrage bei wiederholten Worten';    {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Vra op herhalings';                  {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Detenerse en palabra repetida';      {$ENDIF}
	   {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïðîâ&åðÿòü ïîâòîðû ñëîâ';            {$ENDIF}
	   {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Upozornit na opakující se slovo';    {$ENDIF}
	   {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'vragen bij herhaald woord';          {$ENDIF}
	   {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Spørg ved &gentagne ord';            {$ENDIF}
	   {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Pytaj przy powtórzonym wyrazie';     {$ENDIF}
	   {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Indiquer les mots répétés';          {$ENDIF}
	   {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'S&pør ved gjentatte ord';            {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Co&nferma sulla parola ripetuta';      {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Korduva sõna korral küsi uuesti';      {$ENDIF}
	   end;
    lsDUalCaps:
	   case (Language) of
	   {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Automatically correct DUal capitals';                         {$ENDIF}
	   {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Rätta automatiskt TVå stora bokstäver';                       {$ENDIF}
	   {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Corrigir DUas maiúsculas automaticamente';                    {$ENDIF}
	   {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'ZWei Großbuchstaben am Wortanfang korrigieren';               {$ENDIF}
	   {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'TRANSLATION NEEDED: Automatically correct DUal capitals';     {$ENDIF}
	   {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Corregir automáticamente mayúsculas DObles';                  {$ENDIF}
	   {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Èñïðàâëÿòü &ÄÂå ÏÐîïèñíûå áóêâû';                             {$ENDIF}
	   {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Automaticky opravit DVe pocátecní velká písmena';             {$ENDIF}
	   {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'TWee beginhoofdletters &corrigeren';                          {$ENDIF}
	   {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Automatisk rette DObbelte store bogstaver';                   {$ENDIF}
	   {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Automatycznie poprawiaj podwójne WIelkie litery';             {$ENDIF}
	   {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Corriger automatiquement les DOubles majuscules';             {$ENDIF}
       {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'KOrriger to innledende store bokstaver';                      {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Correggi Automaticamente DOppie Maiuscole';                  {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Paranda TOpeltsuurtähed automaatselt';      {$ENDIF}
       end;

    lsConfirmation:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Confirmation:';  {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Bekräfta:';      {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Confirmação:';   {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Bestätigung:';   {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Bevestig';       {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Confirmación:';  {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïîäòâåðæäåíèå:'; {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Potvrzení:';     {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Bevestiging:';   {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Bekræftelse:';   {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Potwierdzenie:'; {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Confirmation:';  {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Bekreftelse:';   {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Conferma:';      {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Kinnitus:';      {$ENDIF}
        end;
    lsRemoveCustomDict:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Delete this custom dictionary?';                             {$ENDIF}
	   {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Tag bort detta användarlexikon?';                            {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Apagar este dicionário personalizado?';                      {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Skrap hierdie privaat woordeboek';                           {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Soll dieses Benutzerwörterbuch wirklich gelöscht werden?';   {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '¿Borrar este diccionario personalizado?';                    {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Óäàëèòü ýòîò âñïîìîãàòåëüíûé ñëîâàðü?';                      {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Smazat uživatelský slovník?';                                {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Verwijder dit aangepaste woordenboek?';                      {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Slet denne bruger ordbog?';                                  {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Czy usun¹æ ten s³ownik u¿ytkownika?';                        {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Effacer ce dictionnaire personnel?';                         {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Slette denne brukerordbok?';                                 {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Cancellare questo dizionario predefinito?';                  {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Kas soovid selle abisõnastiku kustutada?';      {$ENDIF}
        end;

    lsIgnoreAllChangeAll:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '(Ignore All / Change All)';              {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := '(Ignorera Allt / Ändra Allt)';           {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Ignorar Todas / Trocar Todas';           {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '(Ignoreer almal / Verander almal)';      {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '(Alles ignorieren / Alles ändern)';      {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '(Ignorar Todas / Cambiar Todas)';        {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '(Ïðîïóñòèòü âñå / Çàìåíèòü âñå)';        {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '(Ignorovat vše / Zamìnit vše)';          {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := '(Alles Negeren / Alles vervangen)';      {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '(Ignorer Alle / Ret Alle)';              {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '(Pomiñ wszystkie / Popraw wszystkie)';   {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '(Ingorer tout / Changer tout)';          {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '(Ignorer Alle / Korriger Alle)';         {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '(Ignora Tutto / Sostituisci Tutto)';     {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '(Ignoreeri kõiki / Muuda kõik)';      {$ENDIF}
        end;

    lsSpelling:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Spelling';               {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Stavning';               {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Ortografia';             {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Spelreëls';              {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Rechtschreibprüfung';    {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Ortografía';             {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Îðôîãðàôèÿ';             {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Pravopis';               {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Spellingscontrole';      {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Stavekontrol';           {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Pisownia';               {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Orthographe';            {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Stavekontroll';          {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Controllo Ortografico';  {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Õigekiri';      {$ENDIF}
        end;
    lsSpellingOptions:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Spelling Options';               {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Stavningsinställningar';         {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Opções de Ortografia';           {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Optionen';                       {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Spelkeuse';                      {$ENDIF}
	   {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Opciones de Ortografía';         {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïàðàìåòðû ïðîâåðêè îðôîãðàôèè';  {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Volby kontroly pravopisu';       {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Spellingscontrole Opties';       {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Stavekontrol indstillinger';     {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Ustawienia pisowni';             {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Options orthographiques';        {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Innstillinger for stavekontroll';{$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Opzioni Controllo Ortografico';  {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Õigekirja sätted';      {$ENDIF}
        end;
    lsDictionaries:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Dictionaries';   {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Lexikon';        {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Dicionários';    {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Wörterbücher';   {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Woordeboeke';    {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Diccionarios';   {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ñëîâàðè';        {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Slovníky';       {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Woordenboeken';  {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Ordbøger';       {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'S³owniki';       {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Dictionnaires';  {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Ordbøker';       {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Dizionari';       {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Sõnastikud';      {$ENDIF}
        end;
    lsIgnoreAllChangeAllTitle:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Words added with Ignore All / Change All';               {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Ord som adderats med Ignorera Allt / Ändra Allt';        {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Palavras adicionadas com Ignorar Todas / Trocar Todas';  {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Woorde bygevoeg met (Ignoreer almal / Verander almal)';  {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Wörter mit "Alles ignorieren" anfügen / Alles ändern';    {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Palabras agregadas con Ignorar Todas / Cambiar Todas';   {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïðîïóñòèòü âñå / Çàìåíèòü âñå';                          {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Slova pøidaná Ignorovat vše / Zamìnit vše';              {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Woorden toegevoegd met Alles Negeren/Alles vervangen';   {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Ord tilføjet med Ignorer Alle / Ret Alle';               {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'S³owa dodane przez Pomiñ wszystkie / Popraw wszystkie';  {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Mots ajoutés avec Ignore tout / Change tout';            {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Ord lagt til med Ignorer Alle / Korriger Alle';          {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Parole aggiunte con Ignora Tutto / Cambia Tutto';       {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Käsuga Ignoreeri kõiki / Muuda kõik lisatud sõnad';      {$ENDIF}
        end;
    lsNewCustomTitle:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'New Custom Dictionary';              {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Nytt användarlexikon';               {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Novo Dicionário Personalizado';      {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Neues Benutzerwörterbuch';           {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Nuwe privaat woordeboek';            {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Nuevo Diccionario Personalizado';    {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ñîçäàíèå ñëîâàðÿ';                   {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Nový uživatelský slovník';           {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Nieuw aangepast woordenboek';        {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Ny Bruger Ordbog';                   {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Nowy s³ownik u¿ytkownika';           {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Nouveau dictionnaire personnel';     {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Ny brukerordbok';                    {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Nuovo Dizionario Predefinito';       {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Uus abisõnastik';                    {$ENDIF}
        end;

    lsDlgNotFound:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Not Found:';         {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Ej funnet:';         {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Não encontrada:';    {$ENDIF}
	   {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Nicht gefunden:';    {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Nie gevind nie';     {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'No Encontrada:';     {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Íåò â ñëîâàðå:';     {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Není ve slovníku:';  {$ENDIF}
	   {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Niet gevonden:';     {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Ej fundet:';         {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Nie znaleziono:';    {$ENDIF}
	   {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Non trouvé:';        {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Ikke funnet:';       {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Non T&rovata:';       {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Ei leitud:';      {$ENDIF}
        end;
    lsDlgRepeatedWord:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Repeated Word:';     {$ENDIF}
	   {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Upprepat ord:';      {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Palavra Repetida:';  {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Wiederholtes Wort:'; {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Herhaalde woord:';   {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Palabra Repetida:';  {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïîâòîð ñëîâ';        {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Opakované slovo:';   {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Herhaald woord:';    {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Gentaget Ord:';      {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Powtórzone s³owo:';  {$ENDIF}
	   {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Mot répété:';        {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Gjentatt ord:';      {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Ripeti Parola:';     {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Korduv sõna:';      {$ENDIF}
        end;
    lsDlgReplaceWith:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Replace With:';     {$ENDIF}
	   {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'E&rsätt med:';       {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Substituir &por:';   {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Vervang met:';       {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'E&rsetzen mit:';     {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Reemplazar Con:';   {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Çàìåíèòü &íà:';      {$ENDIF}
	   {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Nahradit èím:';     {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Vervangen met:';     {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Erstat med:';       {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Za&mieñ na:';        {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&Remplacer par:';    {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'E&rstatt med:';      {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Sostituisci Co&n:';  {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Asendus:';      {$ENDIF}
        end;
    lsDlgSuggestions:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Suggestions:';  {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'För&slag:';      {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Sugestões:';    {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Voorstelle:';    {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Vor&schläge:';   {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Sugerencias:';  {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Âà&ðèàíòû';      {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Návrhy:';       {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := '&Suggesties:';   {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Forslag:';      {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Propozycje:';   {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&Suggestions:';  {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'For&slag';       {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Sugg&erimenti:'; {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'S&oovitused:';      {$ENDIF}
        end;
    lsDlgUndo:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Undo';          {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := '&Ångra';         {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Desfazer';      {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&Rückgängig';    {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Gaan terug';    {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Deshacer';      {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Âåðí&óòü';       {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Zpìt';          {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Ongedaan maken'; {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Fortryd';       {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Cofnij';        {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&Défaire';       {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Angre';         {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Ann. &Digitazione'; {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Unusta';      {$ENDIF}
        end;
    lsDlgOptions:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Options...';    {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := '&Inställningar'; {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Opções';        {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&Optionen';      {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Keuse';         {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Opciones';      {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ï&àðàìåòðû...';  {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Nastavení';     {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := '&Opties';        {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Indstillinger'; {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Ustawienia';    {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&Options';       {$ENDIF}
	   {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'I&nnstillinger...'; {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Opzioni...';     {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Sätted...';      {$ENDIF}
        end;
    lsDlgIgnoreAll:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Ignore All';        {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := '&Ignorera Allt';     {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Ignorar Todas';     {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Alles &ignorieren';  {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Ignoreer almal';    {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Ignorar Todas';     {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïðîïóñòèòü &âñå';    {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Ignorovat vše';     {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Alles negeren';      {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Ignorer Alle';      {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Pom&iñ wszystkie';   {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&Ignorer tout';      {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Ignorer alle';      {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Ignora Tutto';      {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Ignoreeri kõiki';      {$ENDIF}
        end;
    lsDlgIgnore:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'I&gnore';        {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'I&gnorera';      {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'I&gnorar';       {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Ignoreer';      {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&Ignorieren';    {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'I&gnorar';       {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Ïðîïóñòèòü';    {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'I&gnorovat';     {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Negeren';        {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'I&gnorer';       {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Pomiñ';         {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'I&gnorer';       {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'I&gnorer';       {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'I&gnora';        {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'I&gnoreeri';      {$ENDIF}
        end;
    lsDlgChangeAll:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Change All';        {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Ändra Allt';         {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Trocar Todas';      {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Alles ände&rn';      {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Verander almal';    {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Cambiar Todas';     {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Çàìåíèòü âñ&å';      {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Zamìnit vše';       {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Alles vervangen';    {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'R&et Alle';          {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Popraw wszystkie';  {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&Changer tout';      {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Korriger alle';     {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Sostituisci Tutto'; {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Muuda kõik';      {$ENDIF}
        end;
    lsDlgChange:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'C&hange';    {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := '&Ändra';     {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'T&rocar';    {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Ä&ndern';    {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Verander';  {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Ca&mbiar';   {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Çàìåíèòü';  {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Z&amìnit';   {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Vervangen';  {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Ret';       {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Pop&raw';    {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'C&hanger';   {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Endre';     {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Sos&tituisci'; {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Muu&da';      {$ENDIF}
        end;
    lsDlgAdd:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Add';           {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := '&Lägg till';     {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Adicionar';     {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'V&oeg by';       {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Hinzu&fügen';    {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Agregar';       {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Äîáàâèòü';      {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Pøidat';        {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Toevoegen';      {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Tilføj';        {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Dodaj';         {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&Ajouter';       {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Legg til';      {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Aggiungi';      {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Lisa';      {$ENDIF}
        end;
    lsDlgAutoCorrect:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Au&to-Correct';          {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Autokorrigera';          {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Auto-Corrigir';          {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Auto-&Korrektur';        {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Vervang automaties';     {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Au&to-Corregir';         {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Àâ&òîçàìåíà';            {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Au&tom. opravy';         {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Au&tomatisch Vervangen'; {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Au&to-korriger';         {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Au&to-korekta';          {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Au&to-Correction';       {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Au&to-korriger';    {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Correzione A&uto.';      {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Auto-&parandus';      {$ENDIF}
        end;
    lsDlgHelp:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Help';      {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := '&Hjälp';     {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'A&juda';     {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&Hilfe';     {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Hulp';      {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'A&yuda';     {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Ñïðàâêà';   {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Nápovìda';  {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := '&Help';      {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Hjælp';     {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Pomo&c';     {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'A&ide';      {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Hjelp';     {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Aiuto';     {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'A&bi';      {$ENDIF}
        end;
    lsDlgCancel:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Cancel';         {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Avbryt';         {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Cancelar';       {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Abbrechen';      {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Kanselleer';    {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Cancelar';       {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Îòìåíà';         {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Storno';         {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Annuleren';      {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Annuller';      {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Anuluj';         {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Annuler';        {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Avbryt';         {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Chiudi';        {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Loobu';      {$ENDIF}
        end;
    lsDlgResetDefaults:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Reset Defaults';                         {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Standardvärden';                         {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Configuração Padrão';                    {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Standard';                               {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Herstel standaard waardes';              {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Reestablecer Predeterminados';           {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Âîññòàíîâèòü óñòàíîâêè ïî óìîë÷àíèþ?';   {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Obnovit výchozí nastavení';              {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Standaard instellingen';                 {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Standard indstillinger';                 {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Ustawienia domyœlne';                    {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Valeurs par défaut';                     {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Standard innstillinger';                 {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Ripristina Dizionari';                   {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Vaikeväärtused';                  {$ENDIF}
        end;

    lsDlgOptionsLabel:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := ' O&ptions: ';        {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := ' Inställningar: ';   {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := ' O&pções ';          {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := ' O&ptionen: ';       {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := ' &Keuse: ';          {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := ' O&pciones: ';       {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := ' Ïàðàìåòðû: ';       {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := ' &Nastavení: ';      {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := ' O&pties: ';         {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := ' &Indstillinger: ';  {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := ' &Ustawienia: ';     {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := ' O&ptions: ';        {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := ' &Innstillinger: ';  {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := ' O&pzioni: ';        {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := ' &Sätted: ';      {$ENDIF}
        end;
    lsDlgDictionariesLabel:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := ' D&ictionaries: ';   {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := ' Le&xikon: ';        {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := ' D&icionários';      {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := ' &Wörterbücher: ';   {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := ' &Woordeboeke ';     {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := ' D&iccionarios: ';   {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := ' Ñëîâ&àðè: ';        {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := ' &Slovníky: ';       {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := ' &Woordenboeken: ';  {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := ' &Ordbøger: ';       {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := ' &S³owniki: ';       {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := ' Dictionnaires: ';   {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := ' Or&dbøker: ';       {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := ' D&izionari: ';      {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := ' Sõ&nastikud: ';      {$ENDIF}
        end;
    lsDlgBrowseForMain:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Locate Dictionaries...';         {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Sök reda på lexikon...';         {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Localizar Dicionários...';       {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Soek vir woordeboeke ...';       {$ENDIF}
	   {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Wörterbücher suchen...';         {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Localizar Diccionarios...';      {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Óêàçàòü ïàïêó ...';              {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Vyhledat slovníky ...';          {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Woordenboeken zoeken...';        {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Søg efter Ordbøger...';          {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Wska¿ s³owniki...';              {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Localiser les dictionnaires...'; {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Søk etter Ordbøker...';          {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Trova Dizionari ...';            {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Sõnastike asukoht...';      {$ENDIF}
        end;
    lsDlgBrowseForMainTitle:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Choose Folder Containing Dictionaries';                  {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Välj katalog som innehåller lexikon';                    {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Selecione a Pasta que Contém os Dicionários';            {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Kies Lêer wat woordeboeke bevat';                        {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Wählen Sie den Ordner, der die Wörterbücher enthält';    {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Escoja la Carpeta que Contiene los Diccionarios';        {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Âûáåðèòå ïàïêó ñî ñëîâàðÿìè';                            {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Vyberte složku obsahující slovníky';                     {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Kies de map die de woordenboeken bevat';                 {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Vælg folder med Ordbøger';                               {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Wska¿ folder zawieraj¹cy s³owniki';                      {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Choisissez le répertoire contenant les dictionnaires';   {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Velg katalog som inneholder ordbøker';                   {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Scegli la Cartella Contenete i Dizionari';               {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Vali sõnastike kataloog';      {$ENDIF}
        end;
    lsDlgName:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Name';       {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Namn';       {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Nome';       {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Name';       {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Naam';       {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Nombre';     {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Íàçâàíèå';   {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Název';      {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Naam';       {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Navn';       {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Nazwa';      {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Nom';        {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Navn';       {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Nome';       {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Nimi';      {$ENDIF}
        end;
    lsDlgFilename:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Filename';           {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Filnamn';            {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Nome do Arquivo';    {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Dateiname';          {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Lêer naam';          {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Nombre de Archivo';  {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Èìÿ ôàéëà';          {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Název souboru';      {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Bestandsnaam';       {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Filnavn';            {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Nazwa pliku';        {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Nom du fichier';     {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Filnavn';            {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Nome del File';      {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Faili nimi';      {$ENDIF}
        end;
    lsDlgCustomDictionary:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Custom Dictionary:';            {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Användarlexikon:';               {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Dicionário &Personalizado:';     {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&Benutzer Wörterbuch:';          {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Privaat wooedeboek:';           {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Diccionario &Personalizado:';    {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Âñïîìîãàòåëüíûé ñëîâàðü:';      {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Uživatelský slovník:';          {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Aangepast woordenboek:';         {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Bruger Ordbog:';                {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'S³ownik &u¿ytkownika:';          {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Di&ctionnaires personnels:';                 {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Brukerordbok';                  {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Di&zionario Predefinito:';       {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Abisõnastik:';      {$ENDIF}
        end;
    lsDlgDictionaries:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Dictionaries ...';  {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Lexikon ...';        {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Dicionários...';    {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&Wörterbücher...';   {$ENDIF}
	   {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Woordeboeke...';    {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Diccionarios ...';  {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ñ&ëîâàðè...';        {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Slovníky...';       {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := '&Woordenboeken...';  {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Ordbøger ...';      {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&S³owniki ...';      {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&Dictionnaires...';  {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Ordb&øker...';       {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Dizionari...';      {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Sõnastikud ...';    {$ENDIF}
        end;

    lsDlgCustomDictionaries:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := ' Custom Dictionaries: ';             {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := ' Användarlexikon: ';                 {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := ' Dicionários Personalizados: ';      {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := ' Benutzer Wörterbuch: ';             {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := ' Privaat woordeboeke';               {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := ' Diccionarios &Personalizados: ';    {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := ' Âñïîìîãàòåëüíûå ñëîâàðè: ';         {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := ' Uživatelské slovníky: ';            {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := ' Aangepaste woordenboeken:';         {$ENDIF}
	   {$IFNDEF AD3NODANISH}   ltDanish:       Result := ' Bruger Ordbøger: ';                 {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := ' S³owniki u¿ytkownika: ';            {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := ' Dictionnaires personnels: ';        {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := ' Brukerordbøker: ';                  {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := ' Dizionari Predefiniti: ';           {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := ' Abisõnastikud: ';                   {$ENDIF}
        end;
    lsDlgEdit:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Edit';          {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Redigera';       {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Editar';        {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Verander';      {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&Bearbeiten';    {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Editar';        {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Èçìåíèòü...';   {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Upravit';       {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Bewerken';       {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Rediger';       {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Edytuj';        {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Modifi&er';      {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Rediger';    {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Modifica';      {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Muuda';         {$ENDIF}
        end;
    lsDlgDelete:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Delete';        {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Tag &bort';      {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Apagar';        {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&Löschen';       {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Skrap';         {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Borrar';        {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Óäàëèòü';       {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Smazat';        {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Verwijderen';    {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Slet';          {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Usuñ';          {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&Supprimer';     {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '$Slett';         {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Elimina';       {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Kustuta';      {$ENDIF}
        end;
    lsDlgNew:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&New';           {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := '&Nytt';          {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Novo';          {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&Neu';           {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Nuut';          {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Nuevo';         {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ñ&îçäàòü...';    {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Nový';          {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := '&Nieuw';         {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Ny';            {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Nowy';          {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&Nouveau';       {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Ny';            {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Nuovo';         {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Uus';           {$ENDIF}
        end;
    lsDlgOK:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&OK';        {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := '&OK';        {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Ok';        {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&OK';        {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Aanvaar';   {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Aceptar';    {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'ÎÊ';         {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&OK';        {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := '&OK';        {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&OK';        {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&OK';        {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&OK';        {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&OK';        {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&OK';        {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Olgu';      {$ENDIF}
        end;

    lsDlgNewCustom:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Enter the new custom dictionary name:';                     {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Skriv in namnet på det nya användarlexikonet:';              {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Entre com o nome do novo dicionário personalizado:';        {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Voeg die nuwe privaat woordeboek naam in:';                 {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Nam&e für neues Benutzerwörterbuch:';                        {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Escriba el nombre del nuevo diccionario personalizado:';    {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Íàçâàíèå íîâîãî ñëîâàðÿ:';                                  {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Zadejte název nového uživatelského slovníku:';              {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Geef een naam voor eigengemaakt woordenboek:';               {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Indtast nyt bruger ordbogs navn:';                          {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&WprowadŸ now¹ nazwê s³ownika u¿ytkownika:';                 {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&Entrer le nom du nouveau dictionnaire:';                    {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Skriv inn navnet på den nye brukerordboken:';               {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Scrivi il nome del nuovo dizionario predefinito:';          {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Sisesta uue abisõnastiku nimi:';      {$ENDIF}
        end;

    lsDlgAddedWords:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Add&ed Words';           {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Adderade ord';           {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Palavras A&dicionadas';  {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Hin&zugefügte Wörter';   {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Bygevoegde woorde:';    {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Palabras Agr&egadas';    {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Äîáàâëåííûå';            {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Pøidaná slova';         {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Toegevoegde Woorden';    {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Tilføjede ord';         {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Dodan&e s³owa';          {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Mots ajout&és';          {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Ord som er lagt &til';   {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Aggi&ungi Parole';       {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Lisatud sõnad';      {$ENDIF}
        end;
    lsDlgAddedWordsExplanation:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'These words will be considered correct during a spell check operation.';         {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Dessa ord kommer att anses riktiga vid en stavningskontroll.';                   {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Estas palavras serão consideradas corretas durante uma verificação ortográfica'; {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Hierdie woorde sal slegs oorweeg word tydens ''n proeflees operasie :';          {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Während der Rechtschreibprüfung werden diese Wörter als korrekt angesehen.';     {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Estas palabras se considerarán correctas durante una revisión de ortografía.';   {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ýòè ñëîâà áóäóò ñ÷èòàòüñÿ ïðàâèëüíûìè ïðè ïðîâåðêå îðôîãðàôèè';                  {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Tato slova budou bìhem kontroly pravopisu považována za bezchybná';              {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Deze woorden zullen als correct worden beschouwd.';                              {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Disse ord betragtes som korrekte under en stavekontrol gennemgang.';             {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Te s³owa bêd¹ uwzglêdniane podczas operacji sprawdzania pisowni.';               {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Ces mots seront acceptés durant une vérication de l''orthographe.';              {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Disse ord betraktes som korrekte ved en stavekontroll.';                          {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Queste parole saranno considerate corrette durante il controllo ortografico.';   {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Õigekirjakontrolli ajal loetakse need sõnad õigeks.';      {$ENDIF}
        end;
    lsDlgIgnoreThisWord:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Ignore this word:';         {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Ignorera dessa ord:';        {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Ignorar esta palavra:';     {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Ignoreer hierdie woord:';   {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Dieses Wort &ignorieren:';   {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Ignorar esta palabra:';     {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Ïðîïóñòèòü ýòî ñëîâî:';     {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Ignoruj slovo:';            {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Dit woord negeren:';         {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Ignorer disse ord:';        {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Pom&iñ to s³owo:';           {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&Ignorer ce mot:';           {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Ignorer følgende ord:';     {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Ignora questa parola:';     {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Ignoreeri seda sõna:';      {$ENDIF}
        end;
    lsDlgAutoCorrectPairs:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'A&uto-Correct Pairs';            {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Autokorrigera dessa par';        {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Pares de Auto-Correção';         {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Auto-&Korrektur Paare';          {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Automatiese vervangs pare:';     {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Pares de A&uto-Corrección';      {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Àâòîçàìåíà';                     {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Pár pro a&utomatickou opravu';   {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Automatische verbetering paar';  {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'A&uto-korriger par';             {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Pary A&uto-korekty';             {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'A&uto-Correction des paires';    {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'A&uto-korriger par';             {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Auto-corre&zione coppie';        {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Automaatse &paranduse sõnapaarid';{$ENDIF}
        end;
    lsDlgAutoCorrectPairsExplanation:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'These words will automatically be corrected when encountered during a spelling check.';              {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Dessa ord kommer att rättas automatiskt under en stavningskontroll.';                                {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Estas palavras serão automaticamente corrigidas durante uma verificação ortográfica';                {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Hierdie woorde sal automaties reg gemaak word wanneer hulle tydens ''n spel toets teegekom word.';   {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Diese Wörter werden während der Rechtschreibprüfung automatisch korrigiert.';                        {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Estas palabras serán corregidas automáticamente durante una revisión de ortografía.';                {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ýòè ñëîâà áóäóò àâòîìàòè÷åñêè çàìåíÿòüñÿ ïðè ïðîâåðêå îðôîãðàôèè';                                   {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Tato slova budou bìhem kontroly pravopisu automaticky opravena';                                     {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Deze woorden worden automatisch verbeterd als spellingscontrol ze tegen komt.';                      {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Disse ord vil automatisk blive korrigeret når de opdages under et stavekontrol check.';              {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Te s³owa bêd¹ automatycznie poprawiane podczas sprawdzania pisowni.';                                {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Ces mots seront corrigés automatiquements lors d''une vérification.';                                {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Disse ord vil automatisk bli korrigert når de oppdages ved en stavekontroll.';                       {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Queste parole saranno considerate in automatico sempre corrette durante il controllo ortografico.';                {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Õigekirjakontrolli ajal parandatakse need sõnad automaatselt.';      {$ENDIF}
        end;
    lsDlgReplace:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Replace:';      {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'E&rsätt:';       {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Substituir:';   {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Vervang:';      {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'E&rsetzen:';     {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Reemplazar:';   {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Çàìåíèòü:';     {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Zamìnit:';      {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Vervangen:';     {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Erstat:';       {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Zamieñ:';       {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&Remplacer';     {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Erstatt:';      {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Sostituisci:';  {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Asendatav sõna:';{$ENDIF}
        end;
    lsDlgWith:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&With:'; {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := '&med:';  {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Por:';  {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&mit:';  {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Met:';  {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Con:';  {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&íà:';   {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Èím:';  {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := '&Met:';  {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Med:';  {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Na:';   {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'A&vec:'; {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Med:';  {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Con:';  {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Asendus&sõna:';      {$ENDIF}
        end;
    lsDlgExcludedWords:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Excluded Words';            {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Uteslutna ord';              {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Palavras &Excluídas';        {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Uitgesluite woorde:';       {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Diese Wörter aus&schließen'; {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Palabras &Excluidas';        {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Çàïðåùåííûå';                {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Vyòatá slova';              {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Foute woorden:';             {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Ekskluderede ord';          {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Oprócz s³ów';               {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Mots &exclus';               {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Utelatte ord';              {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Escludi &Parole';            {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Välistatud sõnad';      {$ENDIF}
        end;
    lsDlgExcludedWordsExplanation:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'These words will always be considered incorrect during a spell check operation.';                    {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Dessa ord kommer alltid att anses felaktiga vid en stavningskontroll.';                              {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Estas palavras serão sempre consideradas incorretas durante uma verificação ortográfica.';           {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Hierdie woorde sal altyd as foutief gesien word wanneer hulle tydens ''n spel toets teegekom word';  {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Während der Rechtschreibprüfung werden diese Wörter stets als falsch angenommen.';                   {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Estas palabras siempre serán consideradas incorrectas durante una revisión de ortografía';           {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Âî âðåìÿ ïðîâåðêè îðôîãðàôèè ýòè ñëîâà áóäóò ðàññìàòðèâàòüñÿ êàê îøèáî÷íûå';                         {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Tato slova budou bìhem kontroly pravopisu považována za chybná';                                     {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Deze woorden zullen altijd als niet correct worden beschouwd.';                                      {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Disse ord vil altid blive betragtet som ukorrekte under et stavekontrol check.';                     {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Te s³owa bêd¹ zawsze uwa¿ane za nieprawid³owe podczas sprawdzania pisowni.';                         {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Ces mots seront rejetés lors d''une vérication de l''orthographe.';                                  {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Disse ord vil altlid bli betraktet som ukorrekte ved en stavekontroll.';                             {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Queste parole saranno considerate sempre non corrette durante il controllo ortografico.';            {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Õigekirjakontrolli ajal märgitakse need sõnad alati vigaseks.';      {$ENDIF}
        end;
    lsDlgExcludeThisWord:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'E&xclude this word:';        {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Uteslut detta ord:';         {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'E&xcluir esta palavra:';     {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Los hierdie woord';          {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Dieses &Wort ausschließen:'; {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'E&xcluir esta palabra:';     {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Çàïðåòèòü ñëîâî:';          {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Vyjmout slovo:';            {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Woord fout rekenen:';        {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Ekskluder dette ord:';      {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Oprócz tego s³owa:';        {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'E&xclure ce mot:';           {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Utelat dette ordet:';       {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Escludi &questa parola:';    {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Välista see sõna:';      {$ENDIF}
        end;

    lsEndMessage:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'The spelling check is complete.';            {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Stavningskontrollen är klar.';               {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Verificação ortográfica completada.';        {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Die Proef lees het voltooi';                 {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Die Rechtschreibprüfung ist abgeschlossen.'; {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Revisión de Ortografía Completada.';         {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïðîâåðêà îðôîãðàôèè çàâåðøåíà.';             {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Kontrola pravopisu byla dokonèena.';         {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Spellingscontrol is voltooid.';              {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Stavekontrol er udført.';                    {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Sprawdzanie pisowni jest zakoñczone.';       {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'La vérification est terminée.';              {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Stavekontrollen er utført.';                 {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Il Controllo Ortografico è terminato.';      {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Õigekirjakontroll lõpetatud.';               {$ENDIF}
        end;
    lsWordsChecked:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'Words checked:';         {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Kontrollerade ord:';     {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Palavras verificadas:';  {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Woorde getoets';         {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Geprüfte Wörter:';       {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'Palabras revisadas:';    {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïðîâåðåíî ñëîâ:';        {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Zkontrolovaná slova:';   {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Woorden gecontroleerd:'; {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Ord kontrolleret:';      {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Sprawdzone wyrazy:';     {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'Mots vérifiés:';         {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Ord kontrollert:';       {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Parole selezionate:';    {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Kontrollitud sõnad:';    {$ENDIF}
        end;
    lsEndSelectionMessage:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'The selection has been checked.  Would you like to check the remainder of the document?';                        {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Det markerade stycket är kontrollerat. Vill du kontrollera resten av dokumentet?';                               {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'A verificação da seleção foi concluída. Você gostaria de verificar o resto do documento?';                       {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Der selektierte Text wurde geprüft.  Wollen Sie den Rest des Dokumentes auch prüfen?';                           {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Die seleksie is geproeflees.  Wil jy die res van die dokument proeflees?';                                       {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'La selección ha sido revisada.  ¿Le gustaría revisar el resto del documento?';                                   {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïðîñìîòð âûäåëåííîãî ôðàãìåíòà çàêîí÷åí. Ïðîäîëæèòü ïðîâåðêó îñòàâøåéñÿ ÷àñòè äîêóìåíòà?';                       {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'Oznaèený text byl zkontrolován. Chcete zkontrolovat zbytek textu?';                                              {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'De selectie is gecontroleerd. Wilt u de rest van het document controleren?';                                     {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Selektionen er blevet kontrolleret.  Vil du gerne kontrollere resten af dette dokument?';                        {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Zaznaczenie uleg³o zmianie. Czy chcesz sprawdziæ resztê dokumentu?';                                             {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'La sélection a été vérifiée. Voulez-vous vérifier le reste du document ?';                                       {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Den valgte teksten er kontrollert. Vil du kontrollere resten av dokumentet?';                                    {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Questa parte è stata selezionata. Vuoi selezionare il resto del documento?';                                     {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Valikus olev tekst on kontrollitud. Kas soovid kontrollida ka ülejäänud dokumenti?';      {$ENDIF}
        end;

    lsMnNoSuggestions:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '(no suggestions)';       {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := '(inga förslag)';         {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '(sem sugestões)';        {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '(keine Vorschläge)';     {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '(Geen voorstelle nie)';  {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '(sin sugerencias)';      {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '(âàðèàíòû îñòóòñòâóþò)'; {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '(žádné návrhy)';         {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := '(geen suggesties)';      {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '(ingen forslag)';        {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '(brak propozycji)';      {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '(aucune suggestion)';    {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '(ingen forslag)';        {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '(nessun suggerimento)';  {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '(soovitusi ei ole)';      {$ENDIF}
        end;
    lsMnIgnore:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'I&gnore';        {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Ignorera';       {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'I&gnorar';       {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'I&gnorieren';    {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'I&gnoreer';      {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'I&gnorar';       {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Ïðîïóñòèòü';    {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'I&gnorovat';     {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Negeren';        {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Ignorer';       {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Pom&iñ';         {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'I&gnorer';       {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Ignorer';       {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'I&gnora';        {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'I&gnoreeri';     {$ENDIF}
        end;
    lsMnIgnoreAll:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Ignore All';        {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Ignorera Allt';      {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Ignorar Todas';     {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Alles &ignorieren';  {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Ignorrer almal';    {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Ignorar Todas';     {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Ïðîïóñòèòü &âñå';    {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Ignorovat vše';     {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Alles Negeren';      {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'Ignorer &Alle';      {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Pomiñ &wszystkie';   {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&Ignorer tout';      {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'Ignorer &Alle';      {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Ignora Tutto';      {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Ignoreeri kõiki';      {$ENDIF}
        end;
    lsMnAdd:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Add';           {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := '&Lägg till';     {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Adicionar';     {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := '&Voeg by';       {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&Hinzufügen';    {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Agregar';       {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Äîáàâèòü';      {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Pøidat';        {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Toevoegen';      {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Tilføj';        {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Dodaj';         {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&Ajouter';       {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Legg til';      {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Aggiungi';      {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Lisa';          {$ENDIF}
        end;
    lsMnChangeAll:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Change All';        {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Ändra allt';         {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Trocar Todas';      {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Al&les ändern';      {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Skrap almal';        {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Cambiar Todas';     {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := 'Çàìåíèòü âñ&å';      {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Zamìnit vše';       {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'Alles Vervangen';    {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Ret Alle';          {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := '&Popraw szystkie';   {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&Changer tout';      {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Korriger alle';     {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Sostituisci Tutto'; {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := '&Muuda kõik';        {$ENDIF}
        end;
    lsMnAutoCorrect:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := 'A&uto Correct';          {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := 'Autokorrigera';          {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := 'Auto-Corrigir';          {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := 'Auto-&Korrektur';        {$ENDIF}
        {$IFNDEF AD3NOAFRIKAANS}ltAfrikaans:    Result := 'Vervang &automaties';    {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := 'A&uto-Corregir';         {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Àâòîçàìåíà';            {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := 'A&utomatická kontrola';  {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := 'A&uto Correctie';        {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := 'A&uto Korriger';         {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'A&uto Korekta';          {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := 'A&uto Correction';       {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := 'A&utokorriger';          {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := 'Correzione A&uto.';      {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'A&utomaatne parandus';   {$ENDIF}
        end;
    lsMnSpelling:
        case (Language) of
        {$IFNDEF AD3NOENGLISH}  ltEnglish:      Result := '&Spelling ...';              {$ENDIF}
        {$IFNDEF AD3NOSWEDISH}  ltSwedish:      Result := '&Stavning ...';              {$ENDIF}
        {$IFNDEF AD3NOBRPORT}   ltBrPort:       Result := '&Ortografia...';             {$ENDIF}
        {$IFNDEF AD3NOENGLISH}  ltAfrikaans:    Result := '&Spel toets ...';            {$ENDIF}
        {$IFNDEF AD3NOGERMAN}   ltGerman:       Result := '&Rechtschreibprüfung ...';   {$ENDIF}
        {$IFNDEF AD3NOSPANISH}  ltSpanish:      Result := '&Ortografía ...';            {$ENDIF}
        {$IFNDEF AD3NORUSSIAN}  ltRussian:      Result := '&Ïðîâåðêà îðôîãðàôèè...';    {$ENDIF}
        {$IFNDEF AD3NOCZECH}    ltCzech:        Result := '&Pravopis ...';              {$ENDIF}
        {$IFNDEF AD3NODUTCH}    ltDutch:        Result := '&Spelling ...';              {$ENDIF}
        {$IFNDEF AD3NODANISH}   ltDanish:       Result := '&Stavekontrol ...';          {$ENDIF}
        {$IFNDEF AD3NOPOLISH}   ltPolish:       Result := 'Pi&sownia ...';              {$ENDIF}
        {$IFNDEF AD3NOFRENCH}   ltFrench:       Result := '&Orthographe ...';           {$ENDIF}
        {$IFNDEF AD3NONORWAYBOK}ltNorwegianBok: Result := '&Stavekontroll ...';         {$ENDIF}
        {$IFNDEF AD3NOITALIAN}  ltItalian:      Result := '&Ortografia ...';            {$ENDIF}
        {$IFNDEF AD3NOESTONIAN}  ltEstonian:    Result := 'Õige&kiri ...';              {$ENDIF}
        end;
    end;
end;



end.

