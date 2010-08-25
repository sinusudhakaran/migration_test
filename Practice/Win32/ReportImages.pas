//------------------------------------------------------------------------------
// ReportImages
//
// Provides procedures to set up the ReportImages object.
//
//------------------------------------------------------------------------------
unit ReportImages;
interface
uses
  Graphics,
  ReportTypes;

procedure CreateReportImageList;
//procedure LoadReportImageList;
procedure AddToReportImageList(Filename, Name : String; Width, Height : Integer);
procedure AddPictureToReportImageList( aPicture : TPicture; name : string; width, height : integer);
procedure AddReportTypeToList(Name: string; Value: TReportTypeParams); overload;
procedure AddReportTypeToList(rptType: tReportType; Value: TReportTypeParams); overload;
procedure DestroyReportImageList;

implementation

uses
  SysUtils,
  Globals,
  LockUtils,
  ReportImagesObj,
  WinUtils;

//------------------------------------------------------------------------------
//
// Creates the object that holds the images and image information.
//
procedure CreateReportImageList;
begin
  ReportImageList := TReportImageList.Create;
end;

//------------------------------------------------------------------------------
//
// Loads the images specified in the Admin System into the ReportImage object.
//
procedure AddReportTypeToList(rptType: tReportType; Value: TReportTypeParams); overload;
begin
   AddReportTypeToList(reportTypeNames[rptType], Value);
end;
procedure AddReportTypeToList(Name: string; Value: TReportTypeParams);
var
  imgImage : TPicture;
begin
  if not assigned(ReportImageList) then
     Exit;

  if (Value.H_LogoFile = '')
  and (Value.F_LogoFile = '') then
    Exit;
  if ((Value.H_LogoFile > '') and (not ReportImageList.HasName(Name + '_HEADER')))
  or ((Value.F_LogoFile > '') and (not ReportImageList.HasName(Name + '_FOOTER'))) then
  //if ObtainLock(ltPracHeaderFooterImg, TimeToWaitForPracLogo) then try
  //Not locked here but as prt of newPrintObj
  begin
     if (Value.H_LogoFile > '') and (not ReportImageList.HasName(Name + '_HEADER')) then begin
         imgImage := TPicture.Create;
         try
            imgImage.LoadFromFile(Value.H_LogoFile);
            ReportImageList.Add(Name + '_HEADER',imgImage,
            Value.H_LogoFileWidth,
            Value.H_LogoFileHeight);
         except
         end;
     end;
     if (Value.F_LogoFile > '') and (not ReportImageList.HasName(Name + '_FOOTER')) then begin
         imgImage := TPicture.Create;
         try
            imgImage.LoadFromFile(Value.F_LogoFile);
            ReportImageList.Add(Name + '_FOOTER',imgImage,
            Value.F_LogoFileWidth,
            Value.F_LogoFileHeight);
         except
         end;
     end;
  end;
  {finally
     ReleaseLock(ltPracHeaderFooterImg);
  end;}
end;

(*
procedure LoadReportImageList;
var
  imgImage : TPicture;
  LogosUsed : boolean;
begin
  if not Assigned( Globals.AdminSystem) then
    Exit;

  LogosUsed := (AdminSystem.fdFields.fdClient_Report_Header_Logo_File <> '') or
               (AdminSystem.fdFields.fdClient_Report_Footer_Logo_File <> '') or
               (AdminSystem.fdFields.fdCoding_Report_Header_Logo_File <> '') or
               (AdminSystem.fdFields.fdCoding_Report_Footer_Logo_File <> '');

  if not LogosUsed then
    Exit;

  //obtain a lock before reading the logo files to avoid any sharing violations
  //will return true if a lock was available
  //if lock is not available then dont load
  if ObtainLock(ltPracHeaderFooterImg, TimeToWaitForPracLogo) then
  begin
    if (AdminSystem.fdFields.fdClient_Report_Header_Logo_File <> '') then
    begin
      if (BKFileExists(AdminSystem.fdFields.fdClient_Report_Header_Logo_File)) then
      begin
        imgImage := TPicture.Create;
        try
          imgImage.LoadFromFile(AdminSystem.fdFields.fdClient_Report_Header_Logo_File);
          ReportImageList.Add('CLIENT_HEADER',imgImage,
            AdminSystem.fdFields.fdClient_Report_Header_Logo_Width,
            AdminSystem.fdFields.fdClient_Report_Header_Logo_Height);
        except
        end;
      end;
    end;

    if (AdminSystem.fdFields.fdClient_Report_Footer_Logo_File <> '') then
    begin
      if (BKFileExists(AdminSystem.fdFields.fdClient_Report_Footer_Logo_File)) then
      begin
        imgImage := TPicture.Create;
        try
          imgImage.LoadFromFile(AdminSystem.fdFields.fdClient_Report_Footer_Logo_File);
          ReportImageList.Add('CLIENT_FOOTER',imgImage,
            AdminSystem.fdFields.fdClient_Report_Footer_Logo_Width,
            AdminSystem.fdFields.fdClient_Report_Footer_Logo_Height);
        except
        end;
      end;
    end;

    if (AdminSystem.fdFields.fdCoding_Report_Header_Logo_File <> '') then
    begin
      if (BKFileExists(AdminSystem.fdFields.fdCoding_Report_Header_Logo_File)) then
      begin
        imgImage := TPicture.Create;
        try
          imgImage.LoadFromFile(AdminSystem.fdFields.fdCoding_Report_Header_Logo_File);
          ReportImageList.Add('CODING_HEADER',imgImage,
            AdminSystem.fdFields.fdCoding_Report_Header_Logo_Width,
            AdminSystem.fdFields.fdCoding_Report_Header_Logo_Height);
        except
        end;
      end;
    end;

    if (AdminSystem.fdFields.fdCoding_Report_Footer_Logo_File <> '') then
    begin
      if (BKFileExists(AdminSystem.fdFields.fdCoding_Report_Footer_Logo_File)) then
      begin
        imgImage := TPicture.Create;
        try
          imgImage.LoadFromFile(AdminSystem.fdFields.fdCoding_Report_Footer_Logo_File);
          ReportImageList.Add('CODING_FOOTER',imgImage,
            AdminSystem.fdFields.fdCoding_Report_Footer_Logo_Width,
            AdminSystem.fdFields.fdCoding_Report_Footer_Logo_Height);
        except
        end;
      end;
    end;

    ReleaseLock( ltPracHeaderFooterImg)
  end;
end;

*)

//------------------------------------------------------------------------------
//
// Loads a single image into the ReportImage object.
//
procedure AddToReportImageList(Filename, Name : String; Width, Height : Integer);
var
  imgImage : TPicture;
begin
  if not Assigned(ReportImageList) then
     Exit;
  if ReportImageList.HasName(Name) then
     Exit;
  if ObtainLock(ltPracHeaderFooterImg, TimeToWaitForPracLogo) then
  begin
    imgImage := TPicture.Create;
    try
      imgImage.LoadFromFile(Filename);
      ReportImageList.Add(Name,imgImage, Width, Height);
    except
    end;
    ReleaseLock( ltPracHeaderFooterImg)
  end;
end;

//------------------------------------------------------------------------------
procedure AddPictureToReportImageList( aPicture : TPicture; name : string; width, height : integer);
begin
  if not Assigned(ReportImageList) then
     Exit;
  ReportImageList.Add( name, aPicture, width, height);
end;

//------------------------------------------------------------------------------
//
// Releases the memory taken by the object.
//
procedure DestroyReportImageList;
begin
  FreeAndNil(ReportImageList);
end;

end.
