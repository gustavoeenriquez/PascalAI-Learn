uses
  SysUtils, Pai.Learn.Data, Pai.Learn.Text;

type
  /// Un modelo de lenguaje de bigramas: se puede usar como cualquier modelo (pascal/TBigramas).
  TBigramas = class(TInterfacedObject, ILanguageModel)
  private
    FModelo: TNGram;
  public
    constructor Create;
    function Next(const Context: TArray<string>): TArray<TTokenProb>;
  end;

constructor TBigramas.Create;
begin
  Todo('crea FModelo := TNGram.Create(2) y entrénalo con Tokenize.Words(Datasets.Text(''cuentos''))');
end;

function TBigramas.Next(const Context: TArray<string>): TArray<TTokenProb>;
begin
  Todo('devuelve lo que dice FModelo para ese contexto');
end;

model Narrador
  primary 'mock/eco';     // pai.package lo cambia por pascal/TBigramas
  maxtokens 30;
end;

begin
  var R := Narrador.Chat('había una vez');
  WriteLn(R.Text);
  WriteLn('modelo: ', R.Model, '   tokens: ', R.Tokens);
end.
