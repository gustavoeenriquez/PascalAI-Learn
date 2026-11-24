﻿unit Acciones;

// Lo que el asistente hace en el mundo. Lo delicado pide permiso, y lo hecho queda anotado
// en la nota del día (memoria/AAAA-MM-DD.md): la conversación se pierde al reiniciar; la nota, no.

interface

uses
  SysUtils, Pai.AI, Pai.Human, Pai.JSON, Memoria;

/// Envía un correo. Antes de enviarlo, le pide permiso a Marta en el chat.
[Tool]
function EnviarCorreo(const Para, Asunto, Cuerpo: string): string;

/// Devuelve dinero a un cliente. Antes de hacerlo, le pide permiso a Marta en el chat.
[Tool]
function DevolverDinero(const Cliente: string; Pesos: Integer): string;

implementation

function EnviarCorreo(const Para, Asunto, Cuerpo: string): string;
begin
  if not Approve('¿Enviar a ' + Para + '?' + sLineBreak + Asunto + sLineBreak + Cuerpo) then
    Exit('Marta dijo que no: el correo no se envió');
  var Args := TJSONObject.Create;
  Args.AddPair('Para', Para);
  Args.AddPair('Asunto', Asunto);
  Args.AddPair('Cuerpo', Cuerpo);
  MCP('correo').Call('Enviar', Args.ToJSON);
  Anotar('Correo enviado a ' + Para + ': ' + Asunto);          // lo anota el código, no el modelo
  Result := 'enviado a ' + Para + ', con el permiso de Marta';
end;

function DevolverDinero(const Cliente: string; Pesos: Integer): string;
begin
  if not Approve(Format('¿Devolver %d pesos a %s?', [Pesos, Cliente])) then
    Exit('Marta dijo que no: no se devolvió nada');
  Anotar(Format('Devolución de %d pesos a %s', [Pesos, Cliente]));
  Result := Format('devolución hecha: %d pesos para %s, con el permiso de Marta', [Pesos, Cliente]);
end;

end.
