unit Buzon;

// El buzón: lo que el asistente dice sin que le escriban, y las preguntas que esperan un sí o un no.

interface

uses
  SysUtils, IOUtils, Pai.AI, Pai.JSON;

type
  TPregunta = record
    Id: string;
    Texto: string;
  end;

  TPendientes = record
    Mensajes: TArray<string>;
    Preguntas: TArray<TPregunta>;
  end;

blackboard Salida
  Avisos: TArray<string>;
end;

/// El chat consulta el buzón cada segundo y contesta las preguntas.
[Expose('/buzon')]
agent TBuzon
  function Pendientes: TPendientes;
  function Responder(const Id, Respuesta: string): string;
end;

implementation

function TBuzon.Pendientes: TPendientes;
begin
  Result.Mensajes := Salida.Avisos;
  Salida.Avisos := [];
  Result.Preguntas := [];
  if TDirectory.Exists('.pai/human') then
    for var F in TDirectory.GetFiles('.pai/human', '*.json') do
    begin
      var P: TPregunta;
      P.Id := TPath.GetFileNameWithoutExtension(F);
      P.Texto := TJSONObject.ParseJSONValue(TFile.ReadAllText(F)).GetString('question', '');
      Result.Preguntas := Result.Preguntas + [P];
    end;
end;

function TBuzon.Responder(const Id, Respuesta: string): string;
begin
  TFile.WriteAllText(TPath.Combine('.pai/human', Id + '.answer'), Respuesta);
  Result := 'ok';
end;

end.
