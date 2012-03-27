unit LogTables;

interface

uses
   Types,
   logger,
   MigrateTable;

type



  TUserActionLogTable = class (TMigrateTable)
  protected
     procedure SetupTable; override;
  public
     function Insert (const msgType: TLogMsgType;  const logMsg: string; ClientCode: string = ''): Boolean;
  end;

implementation

uses
   Forms,
   Windows,
   WinUtils,
   Sysutils;

{ TUserActionLogTable }



function TUserActionLogTable.Insert(const msgType: TLogMsgType;  const logMsg: string; ClientCode: string = ''): Boolean;

begin


      // Write it to the table..
      Result := RunValues(
      [
        ToSQL(0)
       ,ToSQL(50)
       ,ToSQL('Information')
       ,ToSQL(LogData.TypeToText(msgType))
       ,DateTimeToSQL(LogData.Timestamp)
       ,ToSQL(LogData.MachineName)
       ,ToSQL('BankLink Migrator')
       ,ToSQL(LogData.ProcessID)
       ,ToSQL(LogData.ProcsessName)
       ,ToSQL(logMsg)
       ,ToSQL(format(
'Timestamp: %s Message: Information Category: %s Machine: %s Area - Data Migration LoggedInUser - %s Details - %s',
           [FormatDateTime('dd/mm/yyyy  hh:nn:ss am/pm', LogData.Timestamp),
           LogData.TypeToText(msgType),
           LogData.MachineName,
           LogData.UserName,
           LogMsg ] ))
       ,ToSQL(LogData.UserName)
       ,ToSQL('Data Migration')
       ,ToSQL(ClientCode)
       ,ToSQL(LogData.TypeToText(msgType))


      ],[]);

end;



procedure TUserActionLogTable.SetupTable;
begin
   TableName := 'Logs';
   SetFields ([
      'EventID'
      ,'Priority'
      ,'Severity'
      ,'Title'
      ,'Timestamp'
      ,'MachineName'
      ,'AppDomainName'
      ,'ProcessID'
      ,'ProcessName'
      ,'Message'
      ,'FormattedMessage'
      ,'LoggedInUser'
      ,'Area'
      ,'ClientCode'
      ,'Category'

       ],[]);

end;


end.
