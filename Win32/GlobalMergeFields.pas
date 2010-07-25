unit GlobalMergeFields;

interface



type
  TMergeFieldType = (
  mf_UnKnown,
  mf_ReportList,
  mf_Body,
  User_Name,
  User_Email,
  User_DDI,

  Client_Name,
  Client_Code,

  Practice_Name,
  Practice_Email,

  Document_Date,
  Document_Time,
  Document_Page
  );


const
  User_First =  User_Name;
  User_Last  = User_DDI;

  Client_First = Client_Name;
  Client_Last  = Client_Code;

  Practice_First = Practice_Name;
  Practice_Last = Practice_Email;

    MergeFieldNames : array [TMergeFieldType] of string = (
  'UnKnown',
  'Report List',
  'Body',

  'User_Name',
  'User_Email',
  'User_DDI',

  'Client_Name',
  'Client_Code',

  'Practice_Name',
  'Practice_Email',

  'Date',
  'Time',
  'Page num'

  );



function GetGlobalMergeText(const value: string): string;


implementation
uses
   SysUtils,
   stDate,
   bkdateutils,
   SYDEFS,
   Globals;

function GetGlobalMergeText(const value: string): string;
var
  CurrUser: pUser_Rec;
begin
   Result := '';

   //Client fields
   if Assigned(Globals.MyClient) then begin
      if value = MergeFieldNames[Client_Name] then
         Result := Globals.MyClient.clFields.clName
      else if value = MergeFieldNames[Client_Code]then
         Result := Globals.MyClient.clFields.clCode;
   end;

   if Assigned(AdminSystem) then begin

      //User fields
      if Assigned(Globals.CurrUser) then begin
         CurrUser := AdminSystem.fdSystem_User_List.FindCode(Globals.CurrUser.Code);
         if assigned(CurrUser) then begin
            if value = MergeFieldNames[User_Name] then
               Result := CurrUser.usName
            else if value = MergeFieldNames[User_Email] then
               Result := CurrUser.usEMail_Address
            else if value = MergeFieldNames[User_DDI] then
               Result := CurrUser.usDirect_Dial;
         end;
      end;

      //Practice fields
      if value = MergeFieldNames[Practice_Name] then
         Result := AdminSystem.fdFields.fdPractice_Name_for_Reports
      else if value = MergeFieldNames[Practice_Email] then
         Result := AdminSystem.fdFields.fdPractice_EMail_Address;
   end;

   //Document
   if value = MergeFieldNames[Document_Date] then
      Result := BkDate2Str(CurrentDate)
   else if value = MergeFieldNames[Document_Time] then
      Result := TimeToStr(Time);
end;



end.
