unit uOrder;

interface
uses  windows;
const

  //���ݴ���Э���ͷ��
  UID:integer=8888;//��ͷ��ʶ;
  VER:integer=1003;
  ENC:integer=7620;

  CMD_TEST=1000;//���ԣ�

  CMD_READY=1001;//׼��������;
  CMD_REQUEST_USER_ID=1002;//�����û�ID
  CMD_MSG=1003;//��ȡ��Ϣ����;
  CMD_FILE_TRANS=1004;//�����ļ�����;
  CMD_SEND_RESULT=1005;//ת�����ݳɹ��񣻣��Է��Ƿ����ߣ�
type
  POrderHeader=^stOrderHeader;
  stOrderHeader=packed record
    uid:DWORD;
    Ver:DWORD;
    Enc:DWORD;
    id:DWORD;
    pid:DWORD;
    cmd:DWORD;
    len:DWORD;
    dat:pointer;
  end;
  function VerifyOH(oh:stOrderHeader) :boolean;//У���ͷ;
  function formatOH(var oh:stOrderHeader) :stOrderHeader;//��ʽ����ͷ;
var
  id:integer=0;
implementation
function VerifyOH(oh:stOrderHeader) :boolean;//У���ͷ;
begin
  result:=true;
  if(oh.uid<>UID)then result:=false;
  if(oh.Ver<>VER)then result:=false;
  if(oh.ENC<>ENC)then result:=false;
end;
function formatOH(var oh:stOrderHeader) :stOrderHeader;//��ʽ����ͷ;
begin
  oh.uid:=UID;
  oh.Ver:=VER;
  oh.Enc:=ENC;
  oh.id:=id;
  oh.pid:=0;
  oh.cmd:=CMD_READY;
  oh.len:=0;
  oh.dat:=nil;
  result:=oh;
end;

end.