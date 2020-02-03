unit uDM;

interface

uses
  System.SysUtils, System.Classes, System.Win.ScktComp,uConfig,uOrder,windows;
const
  //wm_user=$0400;
  //wm_data=wm_user+100+1;
  MAX_BUF_SIZE=8192; //8192
  USER_ID_BASE=1001;//��ʼ�������
type
  //TEventFlag=(Fconnect,Fdisconnect,FgetUserId,FListPhone,FAddUser,FAddPhone);
  //���ݽ��ձ�־:δ����,������,������,�������
  TFrecvFlag=(Fnone,Funavailable,Frecving,FrecvEnd);//���ݽ��ձ�־

  PRecvDataBuffer=^stRecvDataBuffer;
  stRecvDataBuffer=record   //�������ݻ�����
    oh:stOrderHeader;
    targetSocket:TCustomWinSocket;
    recvFlag:TFrecvFlag;     //���ձ�־
    Recved:integer;         //�ѽ��յ����ݴ�С
    idle:integer;            //����ʱ��

  end;
  PRepeatDataBuffer=^stRepeatDataBuffer;
  stRepeatDataBuffer=record   //ת�����ݻ�����
    oh:stOrderHeader;
    targetSocket:TCustomWinSocket;
  end;

type
  Tdm = class(TDataModule)
    ssOrder: TServerSocket;
    ssData1: TServerSocket;
    procedure DataModuleCreate(Sender: TObject);
    procedure ssOrderClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ssOrderClientError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ssOrderClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ssOrderClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
  private
    { Private declarations }
    mNewUserID:integer;//�µı��
    function getSocketErr(ErrorEvent: TErrorEvent;ErrorCode:integer):string;
    function getNewUserID():integer;
    function PairSocket(Sender: TObject; Socket: TCustomWinSocket):boolean; //ƥ��socket
    procedure SendResult(Socket: TCustomWinSocket;bSuccess:boolean);   //���� ת�������Ƿ�ɹ�
    function repeatData(inSocket,outSocket: TCustomWinSocket):boolean;
  public
    { Public declarations }
  end;

var
  dm: Tdm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}
uses
  uMain;
function Tdm.getNewUserID():integer;
begin
  result:=mNewUserID;
  mNewUserID:=mNewUserID+1;
end;

procedure Tdm.DataModuleCreate(Sender: TObject);
begin
  ssorder.Port:=uConfig.port_order;
  ssorder.Open;
  ssdata1.Port:=uConfig.port_data;
  ssdata1.Open;
  mNewUserID:=USER_ID_BASE;
  //uMain.fMain.LogMain('��������˿ڣ�'+inttostr(ssorder.Port));
  //uMain.fMain.LogMain('�������ݶ˿ڣ�'+inttostr(ssorder.Port));
end;

procedure Tdm.ssOrderClientConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
 fmain.LogMain('ssOrderClientConnect:'+socket.RemoteAddress);
end;

procedure Tdm.ssOrderClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  if socket.Data<>nil then
  begin
   freemem(socket.Data);
   socket.Data:=nil;
  end;
end;

procedure Tdm.ssOrderClientError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  fMain.LogMain('ssOrderClientError:'+getSocketErr(ErrorEvent,ErrorCode)+';addr:'+socket.RemoteAddress);
  socket.Close;
  ErrorCode:=0;
end;









procedure Tdm.ssOrderClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
  recvFlag:TFrecvFlag;
  pBuf:PRecvdataBuffer;
  oh:stOrderHeader;
  sbuf:ansistring;
begin
  fMain.LogMain('----------------------------------------------ssOrderClientRead:datasize:'+inttostr(socket.ReceiveLength)+'-----------------------------------------------------------------------------------');
  pBuf:=nil;
try
  if(socket.ReceiveLength=0)then exit;
  //if(ReceiveLength=1)then begin fmain.LogMain('ReceiveLength:1');exit;end;
  if(socket.Data=nil)then     //1.����ʱ�����û�id
  begin
    socket.ReceiveBuf(oh,sizeof(oh));
    if(not uOrder.VerifyOH(oh))then exit;
    fmain.LogMain('�������ӣ�'+socket.RemoteAddress+';ID='+inttostr(oh.id)+';PID='+inttostr(oh.pid));
    getmem(pBuf,sizeof(stRecvDataBuffer));
    zeromemory(pBuf,sizeof(stRecvDataBuffer));
    pBuf^.oh:=oh;
    socket.Data:=pBuf;

    if (oh.len=0)and(oh.cmd=uOrder.CMD_REQUEST_USER_ID) then
    begin
      pBuf^.recvFlag:=FrecvEnd;
      oh.id:=getNewUserId();
      socket.SendBuf(oh,sizeof(oh));
      exit;
    end;

  end else begin
    pBuf:=socket.Data;
  end;
  if(pBuf^.recvFlag<>Frecving)then
  begin
    socket.ReceiveBuf(oh,sizeof(oh));
    if(not uOrder.VerifyOH(oh))then
    begin
      pBuf^.recvFlag:=Funavailable;
      exit;
    end;
    pBuf^.oh:=oh;              //2.��������ͷ
    if not PairSocket(Sender,Socket) then //3.�Է��Ƿ�����
    begin
      if(oh.len>0)then   //����ʣ������
      begin
        setlength(sbuf,oh.len);
        socket.ReceiveBuf(sbuf[1],oh.len);
      end;
      SendResult(socket,false);  //�Է�δ���ߣ�
      exit;
    end;
    SendResult(socket,true);  //�Է����ߣ�
    pBuf^.targetSocket.SendBuf(oh,sizeof(stOrderHeader));
    if(oh.len=0)then exit;
    //recvLen:=recvLen-sizeof(stOrderHeader);
    //if(recvLen=0)then exit;
  end;
  if(pBuf^.targetSocket<>nil)and(pBuf^.targetSocket.Connected)then
  begin
    repeatData(socket,pBuf^.targetSocket);
    exit;
  end;

  if(oh.len>0)then   //����ʣ������
  begin
    setlength(sbuf,oh.len);
    socket.ReceiveBuf(sbuf[1],oh.len);
  end;

finally

end;
end;


function TDM.repeatData(inSocket,outSocket: TCustomWinSocket):boolean;
var
  buf:array of byte;
  dataLen,recvLen,recved,sended,sendLen,errCount:integer;
begin
  result:=false;
  dataLen:=inSocket.ReceiveLength;
  if(dataLen<=0)then exit;
  recvLen:=0;
  setlength(buf,dataLen);
  while dataLen>0 do
  begin
    recved:=inSocket.ReceiveBuf(buf[recvLen],dataLen);
    if(recved<=0)then
    begin
      fmain.LogMain('repeatData recv error:'+inttostr(recved));
      exit;
    end;
    recvLen:=recvLen+recved;
    dataLen:=dataLen-recved;
  end;
  if(outSocket=nil)or(outSocket.Connected=false)then exit;
  errCount:=0;
  sendLen:=0;
  dataLen:=length(buf);
  while dataLen>0 do
  begin
    sended:=outSocket.SendBuf(Buf[SendLen],dataLen);
    if(sended<=0)then
    begin
      fmain.LogMain('repeatData send error:'+inttostr(recved));
      sleep(1000);
      errCount:=errCount+1;
      if(errCount>3)then exit;
      continue;
    end;
    sendLen:=sended+sendLen;
    dataLen:=dataLen-sended;
  end;
  result:=true;
end;

procedure TDM.SendResult(Socket: TCustomWinSocket;bSuccess:boolean);   //���� ת�������Ƿ�ɹ�
var
  oh:stOrderHeader;
begin
  uOrder.formatOH(oh);
  oh.cmd:=uOrder.CMD_SEND_RESULT;
  if(bSuccess) then DWORD(oh.dat):=1;
  socket.SendBuf(oh,sizeof(oh));
end;

//����id����socket
function TDM.PairSocket(Sender: TObject; Socket: TCustomWinSocket):boolean;
var
  i:integer;
  ServerSocket:TServerWinSocket;
  pBuf1,pBuf2:pRepeatDatabuffer;
begin
  result:=false;
  pBuf1:=Socket.Data;
  ServerSocket:=Sender as TServerWinSocket;
  fmain.LogMain('Pair��port='+inttostr(socket.LocalPort)+';connectcount='+inttostr(ServerSocket.ActiveConnections));
  for I := 0 to ServerSocket.ActiveConnections-1 do
  begin
    pBuf2:=ServerSocket.Connections[i].Data;
    if(pBuf2=nil)then continue;

    if(pBuf2^.oh.id=pBuf1^.oh.pid)then
    begin
      pBuf1^.targetSocket:=ServerSocket.Connections[i];
      pBuf2^.targetSocket:=Socket;
      result:=true;
      exit;
    end;
  end;
end;



//----------------------------------------------------------------------------------------
function tdm.getSocketErr(ErrorEvent: TErrorEvent;ErrorCode:integer):string;
var
  sErrorCode,inf,sErrorEvent:string;
begin
  sErrorCode:='������룺'+inttostr(ErrorCode);
  if ErrorEvent=eeConnect then
  begin
    sErrorEvent:='����ʧ�ܣ�';
  end;
  if ErrorEvent=eeGeneral then
  begin
    sErrorEvent:='�޷�ʶ��Ĵ���';
  end;
  if ErrorEvent=eeSend then
  begin
    sErrorEvent:='��������ʧ�ܣ�';
  end;
    if ErrorEvent=eeReceive then
  begin
    sErrorEvent:='��������ʧ�ܣ�';
  end;
    if ErrorEvent=eeDisconnect then
  begin
    //DisCon(socket);

    sErrorEvent:='�ر�����ʧ�ܣ�';
  end;
    if ErrorEvent=eeAccept then
  begin
    sErrorEvent:='��������ʧ�ܣ�';
  end;
  inf:=sErrorEvent+sErrorCode;
  result:=inf;
end;

end.