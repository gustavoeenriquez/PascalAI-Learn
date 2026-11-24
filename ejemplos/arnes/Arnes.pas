uses
  SysUtils, IOUtils, Pai.AI, Memoria, Acciones, Buzon;

model Asistente
  primary 'claude/claude-haiku-5-5';
  system 'Eres el asistente personal de Marta, dueña de Café La Montaña. Respondes corto, como en un chat. ' +
    'Guarda con Recordar lo que deba durar, y anota con Anotar lo que pase hoy. ' +
    'Para enviar un correo o devolver dinero, usa la herramienta directamente: ella le pide permiso a Marta, ' +
    'y lo que hace queda anotado solo en la nota del día (no lo anotes otra vez).';
  tools Recordar, Anotar, skill('cafe'), auto, mcp('correo'), EnviarCorreo, DevolverDinero;
end;

/// El canal: los mensajes del chat entran por aquí.
[Expose('/chat')]
agent TCanal
  var
    Conv: TConversation;
  constructor Create;
  function Enviar(const Texto: string): string;
  procedure Avisar(const Texto: string);
end;

constructor TCanal.Create;
begin
  Conv := TConversation.Create;
  Conv.Add(rlSystem, 'Lo que sabes:' + sLineBreak + LeerMemoria);
end;

function TCanal.Enviar(const Texto: string): string;
begin
  Conv.Add(rlUser, Texto);
  Result := Asistente.Ask(Conv);
  Conv.Add(rlAssistant, Result);
end;

/// Un aviso que el asistente da sin que le escriban: queda en la conversación y sale por el buzón.
procedure TCanal.Avisar(const Texto: string);
begin
  Conv.Add(rlAssistant, Texto);
  Salida.Append(Avisos, Texto);
end;

/// El latido: cada 30 segundos revisa el correo y avisa lo nuevo, sin que nadie le escriba.
[Every('30s')]
procedure Latido;
begin
  var Vistos := '';
  if TFile.Exists('memoria/vistos.txt') then
    Vistos := TFile.ReadAllText('memoria/vistos.txt');
  var Nuevos := '';
  for var F in TDirectory.GetFiles('correo/entrada', '*.md') do
    if not Vistos.Contains(TPath.GetFileName(F)) then
    begin
      Nuevos := Nuevos + TFile.ReadAllText(F) + sLineBreak;
      TFile.AppendAllText('memoria/vistos.txt', TPath.GetFileName(F) + sLineBreak);
    end;
  if Nuevos <> '' then
    Process<TCanal>('canal').Avisar(Asistente.Ask('Escribe un aviso corto para Marta sobre estos correos nuevos: ' + Nuevos));
end;

// el programa
begin
  spawn TCanal.Create as 'canal';
  spawn TBuzon as 'buzon';
end.