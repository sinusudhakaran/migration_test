{****************************************************************}
{ TWebUpdate & TWebUpdate Wizard component                       }
{ for Delphi & C++Builder                                        }
{ version 1.8                                                    }
{                                                                }
{ written by                                                     }
{   TMS Software                                                 }
{   copyright © 1998-2007                                        }
{   Email : info@tmssoftware.com                                 }
{   Web : http://www.tmssoftware.com                             }
{****************************************************************}
unit wupdreg;

{$I TMSDEFS.INC}

interface

uses
  Classes, WUpdate, WUpdateWiz, WUpdateLanguages;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Web',[TWebUpdate
  , TWebUpdateWizard
  , TWebUpdateWizardDutch
  , TWebUpdateWizardEnglish
  , TWebUpdateWizardFrench
  , TWebUpdateWizardGerman
  , TWebUpdateWizardPortugese
  , TWebUpdateWizardSpanish
  , TWebUpdateWizardDanish
  , TWebUpdateWizardItalian
  , TWebUpdateWizardNorwegian
  , TWebUpdateWizardHungarian
  , TWebUpdateWizardSwedish
  , TWebUpdateWizardCzech
  , TWebUpdateWizardPolish
  ]);
end;

end.

