unit imagesfrm;
{----------------------------------------------------------}
{This form should not be made visible.  It only contains   }
{the image lists for the application.                      }
{----------------------------------------------------------}

interface

uses   
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ExtCtrls, StdCtrls, jpeg, RzGroupBar, RzCommon,
  OsFont, dxGDIPlusClasses;
                                                                            
type
  TAppImages = class(TForm)  {toolbar icons}
    Coding: TImageList;      {also used by dissections and memorisation}
    Budgets: TImageList;     {Banklink B bitmap}
    Maintain: TImageList;
    Files: TImageList;       {open dialog}
    Misc: TImageList;               
    ErrorBmp: TImage;
    InfoBmp: TImage;
    WarningBmp: TImage;
    QuestionBmp: TImage;
    DriveBmp: TImage;
    GreyLightBmp: TImage;
    GreenLightBmp: TImage;
    RedLightBmp: TImage;
    Period: TImageList;
    Client: TImageList;
    imgTick: TImage;
    imgTickLock: TImage;
    imgLock: TImage;
    States: TImageList;
    imgNotes: TImage;
    imgImportNotes: TImage;
    imgDissectNotes: TImage;
    imgDissectImportNotes: TImage;
    imgBankLinkB: TImage;
    imgCustomLogin: TImage;
    imgBankLinkLogo256: TImage;
    imgBankLinkLogoHiColor: TImage;
    ilFileActions_ClientMgr: TImageList;
    imgFindStates: TImage;
    imgBannerRight256: TImage;
    imgBannerRightHiColor: TImage;
    imgBackgroundImage: TImage;
    imgLogin: TImage;
    imgAboutHiColor: TImage;
    imgBankLinkLogoWhiteBkgnd: TImage;
    imgReadNotes: TImage;
    imgDissectReadNotes: TImage;
    imgBackgroundImage_Books: TImage;
    imgAboutHiColor_Books: TImage;
    imgBooksBanner_256: TImage;
    imgBooksBanner_HiColor: TImage;
    AppGroupController: TRzGroupController;
    ToolBtn: TImageList;
    ColorDlg: TColorDialog;
    Imglogo: TImage;
    imPreview: TImageList;
    imPage: TImageList;
    imgLookupClient: TImage;
    imgLookupUser: TImage;
    GlCustomColors: TRzCustomColors;
    imgLookupGroup: TImage;
    imgLookupClientType: TImage;
    imgBankstreamLogin: TImage;
    imgBankstreamLogoHiColor: TImage;
    imgBankstreamLogo256: TImage;
    imgDownloadBankstreamLogo: TImage;
    imgBankstreamIcon: TImage;
    imgMainBackgroundLogo: TImage;
    imgClientHomepageLogo: TImage;
    imgReports: TImage;
    imgBankstreamIcon16x16: TImage;
    imgMainBackground: TImage;
    imgSmallLogo: TImage;
    ImgLogoMedium: TImage;
    imgStatementDetails: TImage;
    imgBlueSuggMemCircle: TImage;
    imgGraySuggMemCircle: TImage;
    imgGridColArrow: TImage;
    procedure FormCreate(Sender: TObject);
  private

  public                              
    { Public declarations }
    CustomLoginBitmapLoaded : boolean;
  end;

const
  CLIENT_NEW_BMP          =  0;
  CLIENT_OPEN_BMP         =  1;
  CLIENT_SAVE_BMP         =  2;
  CLIENT_SAVEAS_BMP       =  3;
  CLIENT_TASKS_BMP        =  4;
  CLIENT_ABANDON_BMP      =  5;
  CLIENT_INFORMATION_BMP  =  6;
  CLIENT_PREFERENCE_BMP   =  7; //Dummy
  CLIENT_SENDTO_BMP       =  8;
  CLIENT_CHECKIN_BMP      =  9;
  CLIENT_CHECKOUT_BMP     = 10;

  CLIENT_CODING_BMP       = 11;
  CLIENT_BUDGET_BMP       = 12;
  CLIENT_REPORT_BMP       = 13;
  CLIENT_GRAPH_BMP        = 14;
  CLIENT_GST_BMP          = 15;

  CLIENT_MANAGER_BMP      = 16;
  CLIENT_USER_BMP         = 21;
  // ....
  CLIENT_FAVOURITES_BMP   = 25;

  CODING_CHART_BMP        = 0;
  CODING_PAYEE_BMP        = 1;
  CODING_MEMORISE_BMP     = 2;
  CODING_DISSECT_BMP      = 3;
  CODING_SORT_BMP         = 4;
  CODING_GOTO_BMP         = 5;
  CODING_REPEAT_BMP       = 6;
  CODING_FIND_BMP         = 7;
  CODING_FILTER_BMP       = 8;
  CODING_MORE_BMP         = 9;
  CODING_HELP_BMP         = 10;
  CODING_SUPER_BMP        = 11;
  //....
  CODING_JOB_BMP          = 18;

  BUDGET_GENERATE_BMP     = 0;
  BUDGET_COPY_BMP         = 1;
  BUDGET_SPLIT_BMP        = 2;
  BUDGET_AVERAGE_BMP      = 3;
  BUDGET_SMOOTH_BMP       = 4;
  BUDGET_ZERO_BMP         = 5;
  BUDGET_EXPORT           = 10;
  BUDGET_IMPORT           = 11;

  MAINTAIN_VIEW_BMP       = 0;
  MAINTAIN_DELETE_BMP     = 1;
  MAINTAIN_CLOSE_BMP      = 2;
  MAINTAIN_MEMORISE_BMP   = 3;
  MAINTAIN_FOLDER_CLOSED_BMP = 4;
  MAINTAIN_FOLDER_OPEN_BMP= 5;
  MAINTAIN_PAGE_NORMAL_BMP= 6;
  MAINTAIN_BALL_BMP       = 7;
  MAINTAIN_ARROWUP_BMP    = 8;
  MAINTAIN_ARROWDOWN_BMP  = 9;
  MAINTAIN_INSERT_BMP     = 10;
  MAINTAIN_EDIT_BMP       = 11;
  MAINTAIN_USER_BMP       = 12;
  MAINTAIN_COLSORT_BMP    = 13;
  MAINTAIN_NEW_CLIENT_BMP = 14;
  MAINTAIN_ATTACH_BMP     = 15;
  MAINTAIN_PAGE_OPEN_BMP  = 16;
  MAINTAIN_LOCK_BMP       = 17;
  MAINTAIN_MASTER_MEM_PAGE_BMP = 18;
  MAINTAIN_PREVIEW_BMP    = 19;
  MAINTAIN_HELP           = 20;
  MAINTAIN_COLOR_BMP      = 21;
  MAINTAIN_COLSORTUP_BMP  = 22;
  MAINTAIN_ALERT          = 23;
  MAINTAIN_ONLINE_ADMIN   = 24;
  MAINTAIN_ONLINE         = 25;
  MAINTAIN_SELECT         = 26;


  FILES_NORMAL_BMP          = 0;
  FILES_OPEN_BMP            = 1;
  FILES_CHECKEDOUT_BMP      = 2;
  FILES_OFFSITE_BMP         = 3;
  FILES_ERROR_BMP           = 4;
  FILES_COLSORT_BMP         = 5;

  MISC_FILE_BMP             = 0;
  MISC_ARROWLEFT_BMP        = 1;
  MISC_ARROWRIGHT_BMP       = 2;
  MISC_CALENDAR_BMP         = 3;
  MISC_FINDFOLDER_BMP       = 4;
  MISC_BADFILE_BMP          = 5;
  MISC_JUSTIFY_LEFT_BMP     = 6;
  MISC_JUSTIFY_CENTER_BMP   = 7;
  MISC_JUSTIFY_RIGHT_BMP    = 8;
  MISC_FONT_BMP             = 9;
  MISC_NEWFILEICON_BMP      = 10;

  STATES_NEW_ACCOUNT_BMP    = 0;
  STATES_UNATTACHED_BMP     = 1;
  STATES_DELETED_BMP        = 2;
  STATES_ATTACHED_BMP       = 3;
  STATES_ALERT              = 6;

  // Most of these are liked at design time..
  Manager_Client            = 0;
  ///
  ///
  Manager_SingleTick        = 21;
  Manager_SingleNoTick      = 22;
  Manager_DoubleTick        = 30;
  Manager_DoubleNoTick      = 31;

  FILE_ACTIONS_INFO  = 4;
  FILE_ACTIONS_INFO2 = 39;

//  CHART_BMP = 0;
//  PAYEE_BMP = 1;

var
  AppImages: TAppImages;


function GetColor (const Name :string; AColor : TColor):TColor;
function IniColor (const Name :string; AColor : TColor):TColor;

implementation

{$R *.DFM}

uses
   Globals,
   bkbranding,
   Winutils;

procedure TAppImages.FormCreate(Sender: TObject);
begin
  if bkBranding.Is256Color then
  begin
    AppGroupController.Color := clWhite;
    AppGroupController.CaptionColorStart := clbtnFace;
    AppGroupController.CaptionColor := clbtnFace;
    AppGroupController.CaptionColorStop := clbtnFace;

  end;
  GlCustomColors.Colors.CommaText := INI_CustomColors;
  AppGroupController.Font.Name := Font.name;
  AppGroupController.Font.Size := Font.Size;
  AppGroupController.Font.color := clHotLight;
  AppGroupController.ItemStaticFont.Name := Font.name;
  AppGroupController.ItemStaticFont.Size := Font.Size;
  AppGroupController.CaptionFont.Name := Font.name;
  AppGroupController.CaptionFont.Size := Font.Size;
end;

function GetColor (const Name :string; AColor : TColor):TColor;
begin
   Result := AColor;
   AppImages.ColorDlg.Color := AColor;
   //AppImages.ColorDlg.
   if AppImages.ColorDlg.Execute then begin
      Result := AppImages.ColorDlg.Color;
      writePrivateProfileString('Colors',Pchar(Name),PChar(IntTostr(Result)),
      Pchar(ChangeFileExt(Application.ExeName,'.ini')));
   end;
end;

function IniColor (const Name :string; AColor : TColor):TColor;
begin
  Result := GetPrivateProfileInt('Colors',Pchar(Name),AColor,
      Pchar(ChangeFileExt(Application.ExeName,'.ini')));
end;

end.
