unit uConfig;

interface
uses
  Vcl.Forms,System.SysUtils,windows;
const
  DEBUG:boolean=true;
  APP_NAME:string='mytalk';
  APP_VERSION:string='1.01';
  WORK_DIR:string='mytalk';
  LOG_NAME:string='talkLog.txt';
  host_addr:string='127.0.0.1';
  port_order:DWORD=6010;
  port_data:DWORD=6011;
var
  workdir:string;//����Ŀ¼
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
