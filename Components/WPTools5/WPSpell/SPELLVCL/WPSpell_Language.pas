// ----------------------------------------------------------------
// WPCubed SpellCheck - WPSPELL
// ----------------------------------------------------------------
// Localizable Strings
// ----------------------------------------------------------------
// Original Copyright (c) 1995-2002, Eminent Domain Software
// included in WPSpell under OEM license
// Modifications Copyright (c) 2004, WPCubed GmbH, Munich
// Last Modification: 17.2.2005
// ----------------------------------------------------------------

// the strings with comment §§§  need translation.
// If compiler symbol SHOW_LANGUAGE_COMBO You
// can select DLG language using combobox on form

unit WPSpell_Language;

interface

{$I WPSpell_INC.INC}

type
  TWPSLanguages = (
{$IFDEF SupportEnglish}lgEnglish{$ENDIF}
{$IFDEF SupportSpanish}, lgSpanish{$ENDIF}
{$IFDEF SupportItalian}, lgItalian{$ENDIF}
{$IFDEF SupportFrench}, lgFrench{$ENDIF}
{$IFDEF SupportGerman}, lgGerman{$ENDIF}
{$IFDEF SupportDutch}, lgDutch{$ENDIF}
{$IFDEF SupportPortogese}, lgPortogese{$ENDIF});

  TMSLabels = (
   // Messages
   tlblTitle,
   tlblFoundPhrase,
   tlblNotFoundPhrase,
   tlblNoErrorsMesg,
   tlblAbortedMesg,
   tlblCompleteMesg,
   tlblAddMesg,
   tlblAddedMesg,
   tlblFilterDIC, tlblFilterDCT,
   tlblLanguageMenu, // 'Languages'
   tlblErrDictionaryFormat, // 'Cannot load this dictionary :'
   // Option Dialog
   tlblTitleOptions,
   tlblTabDictionaries, tlblTabUserDict, tlblTabSpellCheckOpt,
   tlblAddDictionaries,
   tlblEnableDisable,  tlblEnable, tlblDisable, // one button!
   tlblRemoveDCT,
   tlblDefaultLanguage,
   tlblUserDictStandard, tlblUserDictAdd, tlblUserDictRemove, tlblUserDictEdit,
   tlblOptNoCompoundWord,
   tlblOptIgnoreCase,
   tlblOptIgnoreCAPSWords,
   tlblOptIgnoreWordsWithNums,
   tlblOptSpellAsYouGo,
   tlblOptAutocorrectCaseMistakes,
   tlblOptAutoCorrectUserDict,
   tlblOptOK,
   // Spellcheck Form Dialog
    tbtnConfigure,
    tlblFound, tlblNotFound, tlblReplace, tlblSuggestions,
    tbtnReplace, tbtnReplaceAll, tbtnAdd, tbtnSkip, tbtnSkipAll,
    tbtnSuggest, tbtnClose, tbtnAutoCorrect, tbtnOptions,
    tbtnUndoLast, tbtnHelp);
  TLabelArray = array[TMSLabels] of string;


const
  // if more valid characters are needed, here is where to declare them
  ValidChars: set of Char = {valid characters used for parsing buffer}
  [#39 {'}, '0'..'9', 'a'..'z', 'A'..'Z', #128 {Ç}..#165 {Ñ}];
  NumberSet: set of Char =
  ['0'..'9'];

// Language Message Constants for WPSpell
const
  UserDictInfoHint = 'User Dictionary Syntax:' + #10 + #10 +
     ' "A" : A is always correct' + #10 +
     ' "#B" : B is always wrong' + #10 +
     ' "=A=B" : replace A with B';

  cLabels: array[TWPSLanguages] of TLabelArray = (
{$IFDEF SupportEnglish}
    {English}(
    'Spell Checker',  // tlblTitle
    'Word found:',    // tlblFoundPhrase
    'Not found:',     // tlblNotFoundPhrase
    'No errors found. Spell checking complete...', // tlblNoErrorsMesg
    'Spell checking aborted.', // tlblNoErrorsMesg
    'Spell checking complete.', // tlblCompleteMesg
    'Add "%s" to dictionary?',  // tlblAddMesg
    '"%s" already in dictionary.',  // tlblAddedMesg
    'User Dictionaries|*.DIC', // tlblFilterDIC
    'Dictionaries|*.DCT', // tlblFilterDCT
    'Languages',
    'Cannot load this dictionary :',
    // WPSpellOptions  --------------------------------------------------- §§§
    'Spellcheck Options', // tlblTitleOptions,
    'Dictionaries', 'User Dictionaries', 'Options', // Tabsheet Captions
    'Add Dictionaries', // Buttons on first tab
    'Enabled/Disable', 'Enable', 'Disable', // Button btnEnableDCT
    'Remove', // tlblRemoveDCT
    'Selected Language:', // labSelLanguage
    'Standard', 'Add', 'Remove', 'Edit', // Buttons on second Tab
    // Spellcheck Options, third tab
    'No compound word checking', // tlblOptNoCompoundWord,
    'Ignore Case', // tlblOptIgnoreCase,
    'Ignore all CAPS words', // tlblOptIgnoreCAPSWords,
    'Ignore Words with numbers', // tlblOptIgnoreWordsWithNums,
    'Highlight misspelled words', // tlblOptSpellAsYouGo,
    'Autocorrect Case mistakes', // tlblOptAutocorrectCaseMistakes,
    'Use autocorrection user entries', // tlblOptAutoCorrectUserDict,
    'OK', // tlblOptOK,
    // WPSpellForm  ------------------------------------------------------------
    'Configure..',
    'In Dictionary:', 'Not in Dictionary:', 'Change &To:',
    'Suggestio&ns:',
    '&Change', 'C&hange All', '&Add', '&Ignore', 'I&gnore All',
    '&Suggest', 'Cancel', 'AutoCorrect', '&Options', '&Undo Last', 'Help')
{$ENDIF}
{$IFDEF SupportSpanish}
    {Spanish}, (
     'Verificación de Ortografía.',
     'Se encontró:',
     'No se encontró:',
     'Se terminó de verificar la ortografía.' + #13 + 'No se encontraron errores...',
     'Se detuvo la verificación de ortografía.',
     'Se terminó de verificar la ortografía.',
     '¿Quiere añadir "%s" al diccionario?',
     '"%s" ya está en el diccionario.',
    'User Dictionaries|*.DIC', // tlblFilterDIC  §§§
    'Dictionaries|*.DCT', // tlblFilterDCT §§§
    'Languages',  // §§§
    'Cannot load this dictionary :',  // §§§
    // WPSpellOptions  --------------------------------------------------- §§§
    'Spellcheck Options', // tlblTitleOptions,
    'Dictionaries', 'User Dictionaries', 'Options', // Tabsheet Captions
    'Add Dictionaries', // Buttons on first tab
    'Enabled/Disable', 'Enable', 'Disable', // Button btnEnableDCT
    'Remove', // tlblRemoveDCT
    'Selected Language:', // labSelLanguage
    'Standard', 'Add', 'Remove', 'Edit', // Buttons on second Tab
    // Spellcheck Options, third tab
    'No compound word checking', // tlblOptNoCompoundWord,
    'Ignore Case', // tlblOptIgnoreCase,
    'Ignore all CAPS words', // tlblOptIgnoreCAPSWords,
    'Ignore Words with numbers', // tlblOptIgnoreWordsWithNums,
    'Highlight misspelled words', // tlblOptSpellAsYouGo,
    'Autocorrect Case mistakes', // tlblOptAutocorrectCaseMistakes,
    'Use autocorrection user entries', // tlblOptAutoCorrectUserDict,
    'OK', // tlblOptOK,
    // WPSpellForm  ------------------------------------------------------------
    'Configure..', //§§§
    'Encontrado:', 'No Encontrado:', 'Reemplazar Con:',
    'Sugerencias:',
    'Cambiar', 'Cambiarlos', 'Añadir', 'Saltar', 'Ignorar',
    'Sugerir', 'Cerrar', 'Corregir', '&Opciones', 'Deshacer', 'Ayuda')
{$ENDIF}
{$IFDEF SupportItalian}
    {Italian}, (
     'Controllo Ortografico',
     'Parola trovata',
     'Non trovata',
     'Controllo ortografico completato. Nessun errore...',
     'Controllo ortografico interrotto.',
     'Controllo ortografico completato.',
     'Add "%s" to dictionary?', //§§§
     '"%s" already in dictionary', //§§§
    'User Dictionaries|*.DIC', // tlblFilterDIC  §§§
    'Dictionaries|*.DCT', // tlblFilterDCT §§§
    'Languages',  // §§§
    'Cannot load this dictionary :',  // §§§
    // WPSpellOptions  --------------------------------------------------- §§§
    'Spellcheck Options', // tlblTitleOptions,
    'Dictionaries', 'User Dictionaries', 'Options', // Tabsheet Captions
    'Add Dictionaries', // Buttons on first tab
    'Enabled/Disable', 'Enable', 'Disable', // Button btnEnableDCT
    'Remove', // tlblRemoveDCT
    'Selected Language:', // labSelLanguage
    'Standard', 'Add', 'Remove', 'Edit', // Buttons on second Tab
    // Spellcheck Options, third tab
    'No compound word checking', // tlblOptNoCompoundWord,
    'Ignore Case', // tlblOptIgnoreCase,
    'Ignore all CAPS words', // tlblOptIgnoreCAPSWords,
    'Ignore Words with numbers', // tlblOptIgnoreWordsWithNums,
    'Highlight misspelled words', // tlblOptSpellAsYouGo,
    'Autocorrect Case mistakes', // tlblOptAutocorrectCaseMistakes,
    'Use autocorrection user entries', // tlblOptAutoCorrectUserDict,
    'OK', // tlblOptOK,
    // WPSpellForm  ------------------------------------------------------------
    'Configure..', //§§§
    'Trovato:', 'Non trovato:', 'Modifica:', 'Suggerimenti:',
    'Sostituisci', 'Sostituisci Tutti', 'Aggiungi', 'Salta',
    'Salta Tutti', 'Suggerisci', 'Cancella',
    'Correzione Automatica', 'Opzioni', 'Disfa Ultimo', '?')
{$ENDIF}
{$IFDEF SupportFrench}
    {French}, (
     'Vérification de l''orthographe',
     'Mot trouvé',
     'Pas dans le dictionaire',
     'Pas d''erreurs. Vérification de l''orthographe terminée.',
     'Vérification de l''orthographe interrompue.',
     'Vérification de l''orthographe terminée.',
     'Ajouter "%s" au dictionaire?',
     '"%s" déjà dans le dictionare.',
    'User Dictionaries|*.DIC', // tlblFilterDIC  §§§
    'Dictionaries|*.DCT', // tlblFilterDCT §§§
    'Languages',  // §§§
    'Cannot load this dictionary :',  // §§§
    // WPSpellOptions  --------------------------------------------------- §§§
    'Spellcheck Options', // tlblTitleOptions,
    'Dictionaries', 'User Dictionaries', 'Options', // Tabsheet Captions
    'Add Dictionaries', // Buttons on first tab
    'Enabled/Disable', 'Enable', 'Disable', // Button btnEnableDCT
    'Remove', // tlblRemoveDCT
    'Selected Language:', // labSelLanguage
    'Standard', 'Add', 'Remove', 'Edit', // Buttons on second Tab
    // Spellcheck Options, third tab
    'No compound word checking', // tlblOptNoCompoundWord,
    'Ignore Case', // tlblOptIgnoreCase,
    'Ignore all CAPS words', // tlblOptIgnoreCAPSWords,
    'Ignore Words with numbers', // tlblOptIgnoreWordsWithNums,
    'Highlight misspelled words', // tlblOptSpellAsYouGo,
    'Autocorrect Case mistakes', // tlblOptAutocorrectCaseMistakes,
    'Use autocorrection user entries', // tlblOptAutoCorrectUserDict,
    'OK', // tlblOptOK,
    // WPSpellForm  ------------------------------------------------------------
    'Configure..', //§§§
    'Dans le dictionaire:', 'Absent du Dictionaire:',
    'Remplacar &Par:', 'Suggestio&ns:',
    '&Remplacar', 'Remplacar &Tout', '&Ajouter', '&Ignorer',
    'I&gnorer toujours',
    '&Suggérer', 'Annnuler', 'AutoCorrection', '&Options', 'Annuler &Dernière',
    'Aide')
{$ENDIF}
{$IFDEF SupportGerman}
    {German}, (
    'Rechtschreibprüfung',
    'Gefundenes Wort',
    'Nicht gefunden',
    'Keine Fehler gefunden. Rechtschreibprüfung abgeschlossen.',
    'Rechtschreibprüfung abgebrochen.',
    'Rechtschreibprüfung abgeschlossen.',
    '"%s" in Wörterbuch einfügen?',
    '"%s" ist schon im Wörterbuch',
    'Anwender Wörterbücher|*.DIC',
    'Wörterbücher|*.DCT',
    'Sprachen',
    'Dieses Wörterbuch hat nicht das erwartete Format :',
    // WPSpellOptions  ---------------------------------------------------------
    'Textkorrektur Optionen',
    'Wörterbücher', 'Benutzer Wörterbücher', 'Optionen',
    'Wörterbücher laden',
    'Ein/Aus', 'Aktiviere', 'Deaktiviere',
    'Entfernen', 
    'Aktuelle Sprache:',
    'Standard', 'Laden/Neu', 'Entfernen', 'Ändern',
    // Spellcheck Options, third tab
    'Nicht auf zusammengesetzte Worte hin prüfen',
    'Groß-/Kleinschreibung ignorieren',
    'Komplett GROSS geschriebene Worte ignorieren',
    'Worte mit Zahlen ignorieren',
    'Fehler im Text hervorheben',
    'Groß/Kleinschreibung automatisch korrigieren',
    'Automatische Textkorrektur aktivieren',
    'OK', // tlblOptOK,
    // WPSpellForm  ------------------------------------------------------------
    'Optionen..', //§§§
    'Im Wörterbuch:', 'Nicht im Wörterbuch:', 'Ä&ndere in:',
    '&Vorschläge:',
    'Än&dern', '&Alles ändern', '&Einfügen', '&Ignorieren', 'Immer I&gnorieren',
    '&Schlage Vor', 'Schließen', 'AutoKorrigieren', '&Optionen', '&Widerufe',
    'Hilfe')
{$ENDIF}
{$IFDEF SupportDutch}
    {Dutch}, (
    'Spellingscontrole',
    'Woord gevonden:',
    'Niet gevonden:',
    'Geen fouten gevonden. De spellingscontrole is beeindigd.',
    'Spellingscontrole afgebroken.',
     'Spellingscontrole  afgesloten.',
     '"%s" toevoegen aan het woordenboek?',
     '"%s" bestaat al in het woordenboek.',
    'Gebruiker woordenboek|*.DIC',
    'Woordenboeken|*.DCT',
    'Talen',
    'Kan dit woordenboek niet laden:',
    // WPSpellOptions  ---------------------------------------------------
    'Spellingscontrole Opties', // tlblTitleOptions,
    'Woordenboeken',
    'Gebruikers woordenboeken',
    'Opties', // Tabsheet Captions
    'Woordenboeken toevoegen', // Buttons on first tab
    'In/Uit', 'Aktiveren', 'Deaktiveren', // Button btnEnableDCT
    'Verwijderen', // tlblRemoveDCT
    'Gekozen Taal:', // labSelLanguage
    'Standaard', 'Toevoegen', 'Verwijderen', 'Bewerken', // Buttons on second Tab
    // Spellcheck Options, third tab
    'Niet controleren op samengevoegde woorden', // tlblOptNoCompoundWord,
    'Groot-/kleinschrijving negeren', // tlblOptIgnoreCase,
    'Alle compleet GROOT geschreven woorden negeren', // tlblOptIgnoreCAPSWords,
    'Woorden met nummers negeren', // tlblOptIgnoreWordsWithNums,
    'Fouten', // tlblOptSpellAsYouGo,
    'Automatisch groot/kleinschrijving corrigeren', // tlblOptAutocorrectCaseMistakes,
    'Automatische tekst correctie aktiveren', // tlblOptAutoCorrectUserDict,
    'OK', // tlblOptOK,
    // WPSpellForm  ------------------------------------------------------------
    'Opties..', //§§§
    'In Woordenboek:', 'Niet in Woordenboek:', 'V&ander in:',
    '&Suggestie',
    '&Verander', '&Alles veranderen', '&Toevoegen', '&Negeren', '&Alles negeren',
    '&Suggestie', 'Sluiten', 'AutoCorrectie', '&Opties',
    '&Laatste ongedaan maken', 'Help')
{$ENDIF}
{$IFDEF SupportPortogese} //§§§
    {Portogese},(
    'Spell Checker',  // tlblTitle
    'Word found:',    // tlblFoundPhrase
    'Not found:',     // tlblNotFoundPhrase
    'No errors found. Spell checking complete...', // tlblNoErrorsMesg
    'Spell checking aborted.', // tlblNoErrorsMesg
    'Spell checking complete.', // tlblCompleteMesg
    'Add "%s" to dictionary?',  // tlblAddMesg
    '"%s" already in dictionary.',  // tlblAddedMesg
    'User Dictionaries|*.DIC', // tlblFilterDIC  §§§
    'Dictionaries|*.DCT', // tlblFilterDCT §§§
    'Languages',  // §§§
    'Cannot load this dictionary :',  // §§§
    // WPSpellOptions  --------------------------------------------------- §§§
    'Spellcheck Options', // tlblTitleOptions,
    'Dictionaries', 'User Dictionaries', 'Options', // Tabsheet Captions
    'Add Dictionaries', // Buttons on first tab
    'Enabled/Disable', 'Enable', 'Disable', // Button btnEnableDCT
    'Remove', // tlblRemoveDCT
    'Selected Language:', // labSelLanguage
    'Standard', 'Add', 'Remove', 'Edit', // Buttons on second Tab
    // Spellcheck Options, third tab
    'No compound word checking', // tlblOptNoCompoundWord,
    'Ignore Case', // tlblOptIgnoreCase,
    'Ignore all CAPS words', // tlblOptIgnoreCAPSWords,
    'Ignore Words with numbers', // tlblOptIgnoreWordsWithNums,
    'Highlight misspelled words', // tlblOptSpellAsYouGo,
    'Autocorrect Case mistakes', // tlblOptAutocorrectCaseMistakes,
    'Use autocorrection user entries', // tlblOptAutoCorrectUserDict,
    'OK', // tlblOptOK,
    // WPSpellForm  ------------------------------------------------------------
    'Configure..', //§§§
    'In Dictionary:', 'Not in Dictionary:', 'Change &To:',
    'Suggestio&ns:',
    '&Change', 'C&hange All', '&Add', '&Ignore', 'I&gnore All',
    '&Suggest', 'Cancel', 'AutoCorrect', '&Options', '&Undo Last', 'Help')
{$ENDIF}
    );


implementation

end.
