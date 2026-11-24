unit Memoria;

// La memoria del asistente: archivos Markdown que sobreviven a los reinicios.

interface

uses
  SysUtils, IOUtils, Pai.AI;

/// Guarda un dato importante y duradero sobre Marta o el negocio
[Tool]
function Recordar(const Dato: string): string;

/// Anota algo que pasó hoy
[Tool]
function Anotar(const Nota: string): string;

/// Lo que el asistente sabe: MEMORY.md y las notas de hoy
function LeerMemoria: string;

implementation

blackboard Disco
  Escrituras: Integer;
end;

/// Una línea al final de un archivo, de a una: si el modelo pide dos cosas a la vez, no chocan.
procedure Agregar(const Archivo, Linea: string);
begin
  Disco.Atomic(procedure
    begin
      TFile.AppendAllText(Archivo, Linea + sLineBreak);
      Disco.Escrituras := Disco.Escrituras + 1;
    end);
end;

function Hoy: string;
begin
  Result := TPath.Combine('memoria', FormatDateTime('yyyy-mm-dd', Now) + '.md');
end;

function Recordar(const Dato: string): string;
begin
  Agregar(TPath.Combine('memoria', 'MEMORY.md'), '- ' + Dato);
  Result := 'guardado en MEMORY.md';
end;

function Anotar(const Nota: string): string;
begin
  Agregar(Hoy, '- ' + FormatDateTime('hh:nn', Now) + ' ' + Nota);
  Result := 'anotado en ' + Hoy;
end;

function LeerMemoria: string;
begin
  Result := '';
  if TFile.Exists(TPath.Combine('memoria', 'MEMORY.md')) then
    Result := '## MEMORY.md' + sLineBreak + TFile.ReadAllText(TPath.Combine('memoria', 'MEMORY.md'));
  if TFile.Exists(Hoy) then
    Result := Result + sLineBreak + '## Hoy' + sLineBreak + TFile.ReadAllText(Hoy);
end;

end.
