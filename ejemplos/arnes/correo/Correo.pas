uses
  SysUtils, IOUtils, Pai.AI;

/// Un correo simulado: lee la carpeta entrada y guarda lo enviado en la carpeta enviados.
[Expose('/correo', [MCP])]
agent TCorreo
  /// Los correos recibidos: número, remitente y asunto
  function Listar: TArray<string>;
  /// Un correo completo, por su número
  function Leer(const Id: string): string;
  /// Envía un correo
  function Enviar(const Para, Asunto, Cuerpo: string): string;
end;

function TCorreo.Listar: TArray<string>;
begin
  Result := [];
  for var F in TDirectory.GetFiles('correo/entrada', '*.md') do
  begin
    var L := TFile.ReadAllLines(F);
    Result := Result + [TPath.GetFileNameWithoutExtension(F) + ' · ' + L[0] + ' · ' + L[1]];
  end;
end;

function TCorreo.Leer(const Id: string): string;
begin
  Result := TFile.ReadAllText(TPath.Combine('correo/entrada', Id + '.md'));
end;

function TCorreo.Enviar(const Para, Asunto, Cuerpo: string): string;
begin
  var Nombre := FormatDateTime('yyyymmdd-hhnnss', Now) + '.md';
  TFile.WriteAllText(TPath.Combine('correo/enviados', Nombre), 'Para: ' + Para + sLineBreak + 'Asunto: ' + Asunto + sLineBreak + sLineBreak + Cuerpo);
  Result := 'enviado a ' + Para;
end;

begin
  spawn TCorreo as 'correo';
end.
