unit ImagesFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg;

type
  TAppImages = class(TForm)
    imgLogo: TImage;
    imgBankLinkLogo256: TImage;
    imgBankLinkLogoHiColor: TImage;
    imgPictureLogo: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AppImages: TAppImages;

implementation

{$R *.dfm}

end.
