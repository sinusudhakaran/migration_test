�
 TDLGEDITUSER 0�  TPF0TdlgEditUserdlgEditUserLeft�TopBorderStylebsDialogCaptionUser DetailsClientHeight�ClientWidthAColor	clBtnFaceDefaultMonitor
dmMainFormFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameTahoma
Font.Style OldCreateOrderPositionpoScreenCenterScaledShowHint	OnCreate
FormCreateOnShowFormShow
DesignSizeA� PixelsPerInch`
TextHeight TButtonbtnOKLeft�Top�WidthKHeightAnchorsakRightakBottom Caption&OKDefault	TabOrderOnClick
btnOKClick  TButton	btnCancelLeft�Top�WidthKHeightAnchorsakRightakBottom Cancel	CaptionCancelTabOrderOnClickbtnCancelClick  TPageControlpcMainLeftTopWidth3Height�
ActivePage	tsDetailsTabOrder  	TTabSheet	tsDetailsCaptionUser Details TLabelLabel1LeftTopWidth2HeightCaption
&User CodeFocusControl	eUserCode  TLabelLabel2LeftTop/Width4HeightCaption
User &NameFocusControl	eFullName  TLabelLabel3LeftTopOWidthFHeightCaption&E-mail AddressFocusControleMail  TLabelLabel4LeftTop� Width.HeightCaption	&PasswordFocusControlePass  TLabelLabel5LeftTop� WidthVHeightCaption&Confirm PasswordFocusControleConfirmPass  TLabelLabel7LeftTop� Width%HeightCaptionOptions  TLabelLabel8LeftTop� Width1HeightCaption
User &TypeFocusControlcmbUserType  TLabellblUserTypeLeft� Top� Width1HeightAutoSizeCaptionlblUserType  TLabelLabel9LeftTopoWidth0HeightCaptionD&irect DialFocusControleDirectDial  TLabel
stUserNameLeftxTopWidth:HeightCaption
stUserName  TLabelLabel20LeftTop� WidthsHeightCaption(Maximum 8 characters)  TEdit	eUserCodeLeftxTopWidthyHeightBorderStylebsNoneCharCaseecUpperCase	MaxLengthTabOrder Text	EUSERCODE  TEdit	eFullNameLeftxTop,Width�HeightBorderStylebsNone	MaxLength<TabOrderText	eFullName  TEditeMailLeftxTopLWidth�HeightBorderStylebsNone	MaxLengthPTabOrderTexteMail  TEditePassLeftxTop� WidthyHeightBorderStylebsNoneCharCaseecUpperCaseFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.Name	Wingdings
Font.Style 	MaxLength
ParentFontPasswordChar   ŸTabOrderTextEPASS  TEditeConfirmPassLeft�Top� WidthyHeightBorderStylebsNoneCharCaseecUpperCaseFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.Name	Wingdings
Font.Style 	MaxLength
ParentFontPasswordChar   ŸTabOrderTextECONFIRMPASS  	TCheckBox	chkMasterLeftxTop� WidthIHeightCaption.User can create and edit Master &MemorisationsTabOrder  TPanel
pnlSpecialLeftlTop\Width�Height
BevelInnerbvRaised
BevelOuter	bvLoweredTabOrder 	TCheckBoxchkLoggedInLeftTopWidthiHeightCaptionUser is &Logged InTabOrder OnClickchkLoggedInClick   	TComboBoxcmbUserTypeLeftxTop� WidthyHeightStylecsDropDownList
ItemHeightTabOrderOnSelectcmbUserTypeSelect  TEditeDirectDialLeftxToplWidth� HeightBorderStylebsNone	MaxLengthTabOrderTexteDirectDial  	TCheckBoxCBPrintDialogOptionLeftxTopWidthIHeightCaption,&Always show printer options before printingTabOrder	  	TCheckBoxCBSuppressHeaderFooterLeftxTop$WidthIHeightCaption$&Suppress Reporting Headers/Footers TabOrder
  	TCheckBoxchkShowPracticeLogoLeftxTopBWidthIHeightCaptionShow practice logoTabOrder   	TTabSheettsFilesCaptionFiles
ImageIndexExplicitLeft ExplicitTop ExplicitWidth ExplicitHeight  TLabelLabel6LeftTopWidthvHeightCaptionThis user has access to:   TRadioButton
rbAllFilesLeft0Top#WidthqHeightCaption
&All filesTabOrder OnClickrbAllFilesClick  TRadioButtonrbSelectedFilesLeft0Top;Width� HeightCaptionSelected &files onlyTabOrderOnClickrbSelectedFilesClick  TPanelpnlSelectedLeftTopPWidthHeight� 
BevelOuterbvNoneCaptionpnlSelectedTabOrder 	TListViewlvFilesLeftTopWidth�Height� ColumnsCaptionCodeWidthx AutoSize	CaptionName  MultiSelect	ReadOnly	SmallImagesAppImages.FilesTabOrder 	ViewStylevsReport  TButtonbtnAddLeft�TopWidthYHeightCaptionA&ddTabOrderOnClickbtnAddClick  TButton	btnRemoveLeft�Top*WidthYHeightCaption&RemoveTabOrderOnClickbtnRemoveClick  TButtonbtnRemoveAllLeft�TopVWidthYHeightCaptionRemo&ve AllTabOrderOnClickbtnRemoveAllClick      