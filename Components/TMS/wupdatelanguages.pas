{*******************************************************************}
{ TWEBUPDATE Wizard component                                       }
{ for Delphi & C++Builder                                           }
{ version 1.6                                                       }
{                                                                   }
{ written by                                                        }
{    TMS Software                                                   }
{    copyright © 1998-2005                                          }
{    Email : info@tmssoftware.com                                   }
{    Web   : http://www.tmssoftware.com                             }
{                                                                   }
{ The source code is given as is. The author is not responsible     }
{ for any possible damage done due to the use of this code.         }
{ The component can be freely used in any application. The source   }
{ code remains property of the writer and may not be distributed    }
{ freely as such.                                                   }
{*******************************************************************}

unit WUpdateLanguages;

interface

uses
  Classes, WUpdateWiz;

type

  TWebUpdateWizardEnglish = class(TWebUpdateWizardLanguage)
  end;

  TWebUpdateWizardDutch = class(TWebUpdateWizardLanguage)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TWebUpdateWizardFrench = class(TWebUpdateWizardLanguage)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TWebUpdateWizardGerman = class(TWebUpdateWizardLanguage)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TWebUpdateWizardPortugese = class(TWebUpdateWizardLanguage)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TWebUpdateWizardSpanish = class(TWebUpdateWizardLanguage)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TWebUpdateWizardDanish = class(TWebUpdateWizardLanguage)
  public
    constructor Create(AOwner: TComponent); override;
  end;
  
  TWebUpdateWizardItalian = class(TWebUpdateWizardLanguage)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TWebUpdateWizardNorwegian = class(TWebUpdateWizardLanguage)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TWebUpdateWizardHungarian = class(TWebUpdateWizardLanguage)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TWebUpdateWizardSwedish = class(TWebUpdateWizardLanguage)
  public
    constructor Create(AOwner: TComponent); override;
  end;


implementation

{ TWebUpdateWizardDutch }

constructor TWebUpdateWizardDutch.Create(AOwner: TComponent);
begin
  inherited;
  Welcome := 'Druk start om te beginnen met controleren voor applicatie updates ...';
  StartButton := 'Start';
  NextButton := 'Volgende';
  ExitButton := 'Verlaten';
  CancelButton := 'Annuleren';
  RestartButton := 'Herstarten';
  GetUpdateButton := 'Update';
  NewVersionFound := 'Nieuwe version gevonden';
  NewVersion := 'Nieuwe versie';
  NoNewVersionAvail := 'Geen nieuwe versie beschikbaar.';
  NewVersionAvail := 'Nieuwe versie beschikbaar.';
  CurrentVersion := 'Huidige versie';
  NoFilesFound := 'Geen bestanden gevonden voor update';
  NoUpdateOnServer := 'geen update gevonden op server ...';
  CannotConnect := 'Er kan geen verbinding met de update server tot stand gebracht worden of';
  WhatsNew := 'Nieuw in update';
  License := 'Licentie overeenkomst';
  AcceptLicense := 'Ik aanvaard';
  NotAcceptLicense := 'Ik aanvaard niet';
  ComponentsAvail := 'Beschikbare applicatie componenten';
  DownloadingFiles := 'Downloaden bestanden';
  CurrentProgress := 'Vooruitgang huidig bestand';
  TotalProgress := 'Totale vooruitgang';
  UpdateComplete := 'Update volledig ...';
  RestartInfo := 'Druk Herstarten om de nieuwe versie te starten.';
end;

{ TWebUpdateWizardFrench }

constructor TWebUpdateWizardFrench.Create(AOwner: TComponent);
begin
  inherited;
  Welcome := 'Appuyez lancer pour controler la disponibilité d''une version nouvelle ...';
  StartButton := 'Lancer';
  NextButton := 'Suivant';
  ExitButton := 'Quitter';
  CancelButton := 'Annuler';
  RestartButton := 'Relancer';
  GetUpdateButton := 'Update';
  NewVersionFound := 'Version nouvelle trouvée';
  NewVersion := 'Version nouvelle';
  NoNewVersionAvail := 'Pas de version nouvelle disponible.';
  NewVersionAvail := 'Version nouvelle disponible.';
  CurrentVersion := 'Version actuelle';
  NoFilesFound := 'Pas de fichiers trouvés pour version nouvelle';
  NoUpdateOnServer := 'pas trouvé de version nouvelle sur serveur ...';
  CannotConnect := 'Pas possible de faire connection avec serveur ou';
  WhatsNew := 'Nouveautés';
  License := 'Conditions de license';
  AcceptLicense := 'J''accepte';
  NotAcceptLicense := 'Je n''accepte pas';
  ComponentsAvail := 'Composants d''application disponible';
  DownloadingFiles := 'Téléchargement des fichiers';
  CurrentProgress := 'Progrès fichier';
  TotalProgress := 'Progrès total';
  UpdateComplete := 'Update complêt ...';
  RestartInfo := 'Appuyez Relancer pour lancer la version nouvelle';
end;

{ TWebUpdateWizardGerman }

constructor TWebUpdateWizardGerman.Create(AOwner: TComponent);
begin
  inherited;
  Welcome := 'Klicken Sie auf Start, um mit der Updateprüfung zu beginnen...';
  StartButton := 'Start';
  NextButton := 'Weiter';
  ExitButton := 'Verlassen';
  RestartButton := 'Neu starten';
  CancelButton := 'Abbruch';
  GetUpdateButton := 'Update';
  NewVersionFound := 'Neue Version gefunden';
  NewVersion := 'Neue Version';
  NoNewVersionAvail := 'Keine neue Version verfügbar.';
  NewVersionAvail := 'Neue Version verfügbar';
  CurrentVersion := 'Aktuelle Version';
  NoFilesFound := 'Auf dem Server wurden keine Dateien gefunden';
  NoUpdateOnServer := 'Kein Update vorhanden auf Server ...';
  CannotConnect := 'Konnte den Updateserver nicht erreichen oder';
  WhatsNew := 'Was ist neu?';
  License := 'Lizenzvereinbar;ung';
  AcceptLicense := 'Ich nehme an' ;
  NotAcceptLicense := 'Ich lehne ab';
  ComponentsAvail := 'Verfügbare Anwendungskomponenten';
  DownloadingFiles := 'Lade Dateien';
  CurrentProgress := 'Verlauf Dateidownload';
  TotalProgress := 'Verlauf Update';
  UpdateComplete := 'Update ist komplett ...';
  RestartInfo := 'Bestätigen Sie den Neustart, um die neue Anwendung zu starten.';
end;

{ TWebUpdateWizardPortugese }

constructor TWebUpdateWizardPortugese.Create(AOwner: TComponent);
begin
  inherited;
  Welcome := 'Clique iniciar para verificar se há novas atualizações...';
  StartButton := 'Iniciar';
  NextButton := 'Próximo';
  ExitButton := 'Sair';
  CancelButton := 'Cancelar';
  RestartButton := 'Reiniciar';
  GetUpdateButton := 'Obter atualização';
  NewVersionFound := 'Nova versão encontrada';
  NewVersion := 'Nova versão';
  NoNewVersionAvail := 'Não há novas versões disponíveis.';
  NewVersionAvail := 'Nova versão disponível.';
  CurrentVersion := 'Versão atual';
  NoFilesFound := 'Nenhum arquivo encontrado para a atualização';
  NoUpdateOnServer := 'Nenhuma atualização encontrada no servidor...';
  CannotConnect := 'Não foi possível conectar ao servidor de atualização ou';
  WhatsNew := 'O que há de novo';
  License := 'Contrato de licença';
  AcceptLicense := 'Aceito';
  NotAcceptLicense := 'Não aceito';
  ComponentsAvail := 'Componentes da aplicação disponíveis';
  DownloadingFiles := 'Fazendo o download dos arquivos';
  CurrentProgress := 'Progresso do arquivo atual';
  TotalProgress := 'Progresso total';
  UpdateComplete := 'Atualização concluída...';
  RestartInfo := 'Clique reiniciar para iniciar a aplicação atualizada.';
end;

{ TWebUpdateWizardSpanish }

constructor TWebUpdateWizardSpanish.Create(AOwner: TComponent);
begin
  inherited;
  Welcome := 'Presione iniciar para buscar actualizaciones disponibles de la aplicación ...';
  StartButton := 'Iniciar';
  NextButton := 'Siguiente';
  ExitButton := 'Salir';
  CancelButton := 'Cancelar';
  RestartButton := 'Reiniciar';
  GetUpdateButton := 'Obtener actualización';
  NewVersionFound := 'Nueva versión encontrada';
  NewVersion := 'Nueva versión';
  NoNewVersionAvail := 'No hay una nueva versión disponible.';
  NewVersionAvail := 'Nueva versión disponible.';
  CurrentVersion := 'Versión actual';
  NoFilesFound := 'No se encontraron archivos para actualizar';
  NoUpdateOnServer := 'no se encontró una nueva actualización en el servidor ...';
  CannotConnect := 'No se puedo establecer la conexión con el servidor de actualizaciones o ';
  WhatsNew := 'Lo nuevo';
  License := 'Acuerdo de licenciamiento';
  AcceptLicense := 'Acepto';
  NotAcceptLicense := 'No acepto';
  ComponentsAvail := 'Componentes de la aplicación disponibles';
  DownloadingFiles := 'Descargando archivos';
  CurrentProgress := 'Progreso de archivo actual';
  TotalProgress := 'Progreso total';
  UpdateComplete := 'Actualización completada ...';
  RestartInfo := 'Presione reiniciar para ejecutar la aplicación actualizada.';
end;

{ TWebUpdateWizardDanish }

constructor TWebUpdateWizardDanish.Create(AOwner: TComponent);
begin
  inherited;
  Welcome := 'Tryk på Start-knappen for at checke for applikationsopdateringer ...';
  StartButton := 'Start';
  NextButton := 'Næste';
  ExitButton := 'Afslut';
  CancelButton := 'Fortryd';
  RestartButton := 'Genstart';
  GetUpdateButton := 'Hent opdatering';
  NewVersionFound := 'Ny version blev fundet';
  NewVersion := 'Ny version';
  NoNewVersionAvail := 'Ingen ny version tilgængelig.';
  NewVersionAvail := 'Ny version tilgængelig.';
  CurrentVersion := 'Nuværende version';
  NoFilesFound := 'Ingen opdaterbare filer blev fundet';
  NoUpdateOnServer := 'ingen opdatering blev fundet på serveren ...';
  CannotConnect := 'Kunne ikke få kontakt til opdateringsserveren eller';
  WhatsNew := 'Hvad er nyt?';
  License := 'Licensaftale';
  AcceptLicense := 'Jeg accepterer';
  NotAcceptLicense := 'Jeg accepterer ikke';
  ComponentsAvail := 'Tilgængelige applikationskomponenter';
  DownloadingFiles := 'Downloader filer';
  CurrentProgress := 'Nuværende filforløb';
  TotalProgress := 'Total filforløb';
  UpdateComplete := 'Opdatering fuldført ...';
  RestartInfo := 'Tryk på genstart for at starte den opdaterede applikation.';
end;

{ TWebUpdateWizardItalian }

constructor TWebUpdateWizardItalian.Create(AOwner: TComponent);
begin
  inherited;
  Welcome := 'Premi Inizia per verificare la disponibilità di aggiornamenti dell''applicazione...';
  StartButton := 'Inizia';
  NextButton := 'Avanti';
  ExitButton := 'Esci';
  CancelButton := 'Annulla';
  RestartButton := 'Riavvia';
  GetUpdateButton := 'Scarica l''aggiornamento';
  NewVersionFound := 'Trovata una nuova versione';
  NewVersion := 'Nuova versione';
  NoNewVersionAvail := 'Nessuna nuova versione disponibile.';
  NewVersionAvail := 'Nuova versione disponibile.';
  CurrentVersion := 'Versione corrente';
  NoFilesFound := 'file non trovati per l''aggiornamento';
  NoUpdateOnServer := 'non c''è un nuovo aggiornamento sul server...';
  CannotConnect := 'Impossibile stabilire la connessione con il server o ';
  WhatsNew := 'Novità';
  License := 'Accordo di licenza';
  AcceptLicense := 'Accetto';
  NotAcceptLicense := 'Non accetto';
  ComponentsAvail := 'Componenti dell''applicazione disponibil';
  DownloadingFiles := 'Scarico i file';
  CurrentProgress := 'Avanzamento del file corrente';
  TotalProgress := 'Avanzamento complessivo';
  UpdateComplete := 'Aggiornamento completo...';
  RestartInfo := 'Premi riavvia per eseguire l''applicazione aggiornata.';
end;

{ TWebUpdateWizardNorwegian }

constructor TWebUpdateWizardNorwegian.Create(AOwner: TComponent);
begin
  inherited;
  Welcome := 'Klikk Start for å se etter tilgjengelige oppdateringer av programmet...';
  StartButton := 'Start';
  NextButton := 'Neste';
  ExitButton := 'Avslutt';
  CancelButton := 'Avbryt';
  RestartButton := 'Start på nytt';
  GetUpdateButton := 'Hent oppdatering';
  NewVersionFound:= 'Ny versjon';
  NoNewVersionAvail := 'Ingen ny versjon er tilgjengelig.';
  NewVersionAvail := 'Ny versjon er tilgjengelig for nedlasting.';
  CurrentVersion := 'Nåværende versjon';
  NoFilesFound := 'Fant ingen filer for oppdateringen';
  NoUpdateOnServer := 'fant ingen oppdatering på serveren ...';
  CannotConnect := 'Kunne ikke koble til oppdateringsserveren eller ';
  WhatsNew := 'Hva er nytt';
  License := 'Lisensavtale';
  AcceptLicense := 'Jeg godtar';   //Too long for the current radio button width
  NotAcceptLicense := 'Jeg godtar ikke';  //Too long for the current radio button width
  ComponentsAvail := 'Tilgjengelige programkomponenter';
  DownloadingFiles := 'Laster ned filer';
  CurrentProgress := 'Nedlastingsforløpet for nåværende fil';
  TotalProgress := 'Nedlastingsforløpet for alle filer';
  UpdateComplete := 'Oppdateringen er ferdig ...';
  RestartInfo := 'Klikk Start på nytt  for å starte det oppdaterte programmet.';
end;


constructor TWebUpdateWizardHungarian.Create(AOwner: TComponent);
begin
  inherited;
  Welcome := 'Kattints az indít gombra és elindul a frissítések keresése ...';
  StartButton := 'Indít';
  NextButton := 'Tovább';
  ExitButton := 'Kilépés';
  CancelButton := 'Mégsem';
  RestartButton := 'Újraindít';
  GetUpdateButton := 'Frissít';
  NewVersionFound := 'Új verziót találtam';
  NewVersion := 'Új verzió';
  NoNewVersionAvail := 'Új verzió nem található.';
  NewVersionAvail := 'Új verzió található.';
  CurrentVersion := 'Aktuális verzió';
  NoFilesFound := 'A frissítésben nem található file';
  NoUpdateOnServer := 'nem található frissítés a kiszolgálón ...';
  CannotConnect := 'Nem tudok kapcsolódni a frissítõ kiszolgálóhoz';
  WhatsNew := 'Mi az újdonság';
  License := 'Szerzõdési feltétel';
  AcceptLicense := 'Elfogadom';
  NotAcceptLicense := 'Visszautasítom';
  ComponentsAvail := 'Lehetséges alkalmazás kopmponensek';
  DownloadingFiles := 'Álományok letöltése';
  CurrentProgress := 'Aktuális mûvelet állpota';
  TotalProgress := 'Teljes mûvelet állapota';
  UpdateComplete := 'Frissítés kész ...';
  RestartInfo := 'Kattints az Ujraindít gombra, hogy elinduljon a frissített alkalmazás.';
end;


{ TWebUpdateWizardSwedish }

constructor TWebUpdateWizardSwedish.Create(AOwner: TComponent);
begin
  inherited;
  Welcome := 'Tryck på Start-knappen för att leta efter tillgängliga uppdateringar ...';
  StartButton := 'Start';
  NextButton := 'Nästa';
  ExitButton := 'Avsluta';
  CancelButton := 'Ångra';
  RestartButton := 'Starta om';
  GetUpdateButton := 'Hämta uppdatering';
  NewVersionFound := 'Ny version funnen';
  NewVersion := 'Ny version';
  NoNewVersionAvail := 'Ny version saknas.';
  NewVersionAvail := 'Ny version finns';
  CurrentVersion := 'Nuvarande version';
  NoFilesFound := 'Hittade inga uppdateringsbara filer';
  NoUpdateOnServer := 'hittade ingen uppdatering på servern ...';
  CannotConnect := 'Kunde inte få kontakt med servern eller';
  WhatsNew := 'Nyheter';
  License := 'Licensavtal';
  AcceptLicense := 'Jag accepterar';
  NotAcceptLicense := 'Jag accepterar inte';
  ComponentsAvail := 'Tillgängliga applikationskomponenter';
  DownloadingFiles := 'Laddar ner filer';
  CurrentProgress := 'Nuvarende filförlopp';
  TotalProgress := 'Totalt filförlopp';
  UpdateComplete := 'Uppdateringen klar ...';
  RestartInfo := 'Tryck på Omstart för att starta den uppdaterade applikationen';
end;

end.
