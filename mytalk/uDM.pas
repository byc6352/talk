unit uDM;

interface

uses
  System.SysUtils, System.Classes, System.Win.ScktComp,windows,
  uConfig,uOrder;
const
  wm_user=$0400;
  wm_data=wm_user+100+4;
  MAX_BUF_SIZE=8192;

type
  //数据接收标志:未接收,不可用,接收中,接收完成
  TFrecvFlag=(Fnone,Funavailable,Frecving,FrecvEnd);//数据接收标志


  PRecvDataBuffer=^stRecvDataBuffer;
  stRecvDataBuffer=record   //接收数据缓冲区
    oh:stOrderHeader;
    recvFlag:TFrecvFlag;     //接收标志
    Recved:integer;         //已接收的数据大小
    idle:integer;            //空闲时间
    buf:array[0..MAX_BUF_SIZE-1] of byte;
  end;

type
  TDM = class(TDataModule)
    cs1: TClientSocket;
    procedure DataModuleCreate(Sender: TObject);
    procedure cs1Connect(Sender: TObject; Socket: TCustomWinSocket);
    procedure cs1Disconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure cs1Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure cs1Read(Sender: TObject; Socket: TCustomWinSocket);
  private
    { Private declarations }
    mUserID:integer;
    function RecvData(var Socket: TCustomWinSocket):TFrecvFlag;
    procedure processCmd(poh:POrderHeader);
    function getSocketErr(ErrorEvent: TErrorEvent;ErrorCode:integer):string;
    procedure RequestUserID();

  public
    { Public declarations }
    procedure SendMSG(friendID:integer;msg:ansistring);
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}
uses
  uMain;

procedure TDM.SendMSG(friendID:integer;msg:ansistring);
var
  oh:stOrderHeader;
  buf:array[0..1023] of byte;
begin
  uOrder.formatOH(oh);
  oh.cmd:=uOrder.CMD_MSG;
  oh.len:=length(msg);
  oh.pid:=friendID;
  zeromemory(@buf[0],1024);
  move(oh,buf[0],sizeof(oh));
  move(msg[1],buf[sizeof(oh)],oh.len);
  cs1.socket.SendBuf(buf[0],sizeof(oh)+oh.len);
end;
procedure TDM.RequestUserID();
var
  oh:stOrderHeader;
  buf:array[0..1023] of byte;
begin
  uOrder.formatOH(oh);
  oh.cmd:=uOrder.CMD_REQUEST_USER_ID;
  if cs1.Active then
    cs1.Socket.SendBuf(oh,sizeof(oh));
end;

procedure TDM.cs1Connect(Sender: TObject; Socket: TCustomWinSocket);
begin
  fmain.LogMain('连接服务器成功！');
  RequestUserID();
end;

procedure TDM.cs1Disconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  fmain.LogMain('断开与服务器连接！');
end;

procedure TDM.cs1Error(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  fMain.LogMain('ClientError:'+getSocketErr(ErrorEvent,ErrorCode));
  //socket.Close;
  ErrorCode:=0;
end;

procedure TDM.cs1Read(Sender: TObject; Socket: TCustomWinSocket);
var
  recvFlag:TFrecvFlag;
  pBuf:PRecvDataBuffer;
  poh:POrderHeader;
begin
  recvFlag:=RecvData(socket);
  if(recvFlag<>FrecvEnd)then exit;
  pBuf:=socket.Data;
  poh:=@pBuf^.oh;
  processCmd(poh);
end;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  cs1.Close;
  cs1.Port:=uConfig.port_order;
  cs1.Address:=uConfig.host_addr;
  cs1.Open;
end;




//----------------------------------------------------------------------------------------


procedure TDM.processCmd(poh:POrderHeader);
var
  msg:ansistring;
  res:integer;
begin
  case poh^.cmd of
  uOrder.CMD_READY:
    begin
      exit;
    end;
  uOrder.CMD_REQUEST_USER_ID:
    begin
      uorder.id:=poh^.id;
      mUserId:=uorder.id;
      fmain.Caption:=uConfig.APP_NAME+uConfig.APP_VERSION+'(用户编号：'+inttostr(mUserId)+')';
    end;
  uOrder.CMD_MSG:
    begin
      if poh^.len<=0 then  exit;
      setLength(msg,poh^.len);
      move(poh^.dat^,msg[1],poh^.len);
      fmain.MSGmain(poh^.pid,msg);
      //fmain.LogMain(msg);
      //SendMessage(Fmain.Handle,wm_data,DWORD(FListPhone),integer(poh));
    end;
  uOrder.CMD_FILE_TRANS:
    begin
      //SendMessage(Fmain.Handle,wm_data,DWORD(FDelPhone),integer(poh));
    end;
  uOrder.CMD_SEND_RESULT:
    begin
       res:=dword(poh^.dat);
       if(res=1)then
         fmain.LogMain('发送成功！')
       else
         fmain.LogMain('对方不在线！');
      //SendMessage(Fmain.Handle,wm_data,DWORD(FDelPhone),integer(poh));
    end;
  end;
end;

//接收异步数据
function TDM.RecvData(var Socket: TCustomWinSocket):TFrecvFlag;
var
  pBuf:PRecvDataBuffer;
  oh:stOrderHeader;
  ReceiveLength,requestLen,RecvedLen,DataLen:integer; //
  pdata:pointer;
begin
  ReceiveLength:=socket.ReceiveLength;
  pBuf:=nil;
try
  if(ReceiveLength=0)then exit;
  if(ReceiveLength=1)then begin fmain.LogMain('ReceiveLength:1');exit;end;
  if(socket.Data=nil)then
  begin
    socket.ReceiveBuf(oh,sizeof(oh));
    if(not uOrder.VerifyOH(oh))then exit;
    getmem(pBuf,sizeof(stRecvDataBuffer));
    zeromemory(pBuf,sizeof(stRecvDataBuffer));
    pBuf^.oh:=oh;
    socket.Data:=pBuf;
    if (oh.len=0) then
    begin
      pBuf^.recvFlag:=FrecvEnd;
      exit;
    end
    else begin
      pBuf^.recvFlag:=Frecving;
      ReceiveLength:=ReceiveLength-sizeof(oh);
      //getmem(pBuf^.oh.dat,oh.len);
      pBuf^.oh.dat:=@pBuf^.buf[0];
      if(ReceiveLength=0)then exit;
    end;
  end else begin
    pBuf:=socket.Data;
  end;

  if(pBuf^.recvFlag<>Frecving)then
  begin
    socket.ReceiveBuf(oh,sizeof(oh));
    pBuf^.Recved:=0;
    if(not uOrder.VerifyOH(oh))then
    begin
      pBuf^.recvFlag:=Funavailable;
      exit;
    end;
    pBuf^.oh:=oh;

    if(oh.len=0)then
    begin
      pBuf^.recvFlag:=FrecvEnd;
      exit;
    end else begin
      DataLen:=oh.len;
      if DataLen<=ReceiveLength-sizeof(oh) then requestLen:=DataLen else requestLen:=ReceiveLength-sizeof(oh); //要接收的数据；

      zeromemory(@pBuf^.buf[0],MAX_BUF_SIZE);
      RecvedLen:=socket.ReceiveBuf(pBuf^.buf[0],requestLen);
      fMain.LogMain('RecvData0:'+ansiString(pansichar(@pBuf^.buf[0]))+';Recved:'+inttostr(RecvedLen));
      if RecvedLen=-1 then RecvedLen:=0;
      pBuf^.Recved:=RecvedLen;
      if(pBuf^.Recved>=oh.len)then
        pBuf^.recvFlag:=FrecvEnd
      else
        pBuf^.recvFlag:=Frecving;
      exit;
    end;
  end else begin
    RecvedLen:=pBuf^.Recved;
    DataLen:=pBuf^.oh.len;
    if(RecvedLen<DataLen)then
    begin
      if DataLen-RecvedLen<=ReceiveLength then requestLen:=DataLen-RecvedLen else requestLen:=ReceiveLength; //要接收的数据；
      //pdata:=pointer(DWORD(pBuf^.oh.dat)+RecvedLen);
      //pdata:=@pBuf^.buf[RecvedLen];
      //RecvedLen:=socket.ReceiveBuf(pdata^,requestLen);
      fMain.LogMain('RecvData1:RecvedLen:'+inttostr(RecvedLen));
      RecvedLen:=socket.ReceiveBuf(pBuf^.buf[RecvedLen],requestLen);
      fMain.LogMain('RecvData1:'+ansiString(pansiChar(@pBuf^.buf[0]))+';RecvedLen:'+inttostr(RecvedLen));
      if(RecvedLen=-1)then exit;
      pBuf^.Recved:=pBuf^.Recved+RecvedLen;

      if(pBuf^.Recved>=pBuf^.oh.len)then
      begin
        pBuf^.recvFlag:=FrecvEnd;
      end;
    end else begin
        pBuf^.recvFlag:=FrecvEnd;
    end;
  end;
finally
  if pBuf<>nil then
  begin
    pBuf^.idle:=0;
    if(pBuf^.oh.len>0)then
      pBuf^.oh.dat:=@pBuf^.buf[0];
    result:=pBuf^.recvFlag;
  end
  else
    result:=Funavailable;
end;
end;



function tdm.getSocketErr(ErrorEvent: TErrorEvent;ErrorCode:integer):string;
var
  sErrorCode,inf,sErrorEvent:string;
begin
  sErrorCode:='错误代码：'+inttostr(ErrorCode);
  if ErrorEvent=eeConnect then
  begin
    sErrorEvent:='连接失败！';
  end;
  if ErrorEvent=eeGeneral then
  begin
    sErrorEvent:='无法识别的错误！';
  end;
  if ErrorEvent=eeSend then
  begin
    sErrorEvent:='发送数据失败！';
  end;
    if ErrorEvent=eeReceive then
  begin
    sErrorEvent:='接受数据失败！';
  end;
    if ErrorEvent=eeDisconnect then
  begin
    //DisCon(socket);

    sErrorEvent:='关闭连接失败！';
  end;
    if ErrorEvent=eeAccept then
  begin
    sErrorEvent:='接受连接失败！';
  end;
  inf:=sErrorEvent+sErrorCode;
  result:=inf;
end;

end.
