{***************************************************************************}
{ TAdvStyleIF interface                                                     }
{ for Delphi & C++Builder                                                   }
{ version 1.0                                                               }
{                                                                           }
{ written by TMS Software                                                   }
{            copyright © 2006                                               }
{            Email : info@tmssoftware.com                                   }
{            Web : http://www.tmssoftware.com                               }
{                                                                           }
{ The source code is given as is. The author is not responsible             }
{ for any possible damage done due to the use of this code.                 }
{ The component can be freely used in any application. The complete         }
{ source code remains property of the author and may not be distributed,    }
{ published, given or sold in any form as such. No parts of the source      }
{ code can be included in any other component or application without        }
{ written authorization of the author.                                      }
{***************************************************************************}

unit AdvStyleIF;

interface

uses
  Classes;

type
  TTMSStyle = (tsOffice2003Blue, tsOffice2003Silver, tsOffice2003Olive, tsOffice2003Classic,
    tsOffice2007Luna, tsOffice2007Obsidian, tsWindowsXP, tsWhidbey, tsCustom, tsOffice2007Silver);

  //
  //  ['{E1199D64-5AF9-4DB7-B363-FABE5D1EEE0F}']
  //  function GetComponentStyle: TTMSStyle;

  ITMSStyle = interface
  ['{11AC2DDC-C087-4298-AB6E-EA1B5017511B}']
    procedure SetComponentStyle(AStyle: TTMSStyle);
  end;

implementation

end.
