unit uConfig;

interface
uses
  Vcl.Forms,System.SysUtils,windows;
const
  WORK_DIR:string='talkrepeater';
  LOG_NAME:string='talkrepeaterLog.txt';
  port_order:DWORD=6010;
  port_data:DWORD=6011;


var
  workdir:string;//¹¤×÷Ä¿Â¼
  logfile:string;//
  isInit:boolean=false;
  procedure init();
implementation
procedure init();
var
    me:String;
begin
   isInit:=true;
   me:=application.ExeName;
   workdir:=extractfiledir(me)+'\'+WORK_DIR;
   if(not DirectoryExists(workdir))then ForceDirectories(workdir);
   logfile:=workdir+'\'+LOG_NAME;
end;

begin
  init();
end.
