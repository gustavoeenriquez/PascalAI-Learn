uses
  SysUtils, Pai.Learn.Data, Pai.Learn.Text;

type
  TBigramas = class(TInterfacedObject, ILanguageModel)
  private
    FModelo: TNGram;
  public
    constructor Create;
    function Next(const Context: TArray<string>): TArray<TTokenProb>;
  end;

  /// Trigramas con retroceso a bigramas.
  TTrigramas = class(TInterfacedObject, ILanguageModel)
  private
    FTri, FBi: TNGram;
  public
    constructor Create;
    function Next(const Context: TArray<string>): TArray<TTokenProb>;
  end;

constructor TBigramas.Create;
begin
  FModelo := TNGram.Create(2);
  FModelo.Train(Tokenize.Words(Datasets.Text('cuentos')));
end;

function TBigramas.Next(const Context: TArray<string>): TArray<TTokenProb>;
begin
  Result := FModelo.Next(Context);
end;

constructor TTrigramas.Create;
begin
  Todo('entrena FTri (TNGram de 3) y FBi (de 2) con las palabras de los cuentos');
end;

function TTrigramas.Next(const Context: TArray<string>): TArray<TTokenProb>;
begin
  Todo('pide a FTri; si no devuelve nada, a FBi');
end;

model Narrador
  primary 'mock/eco';      // pai.package lo cambia
  maxtokens 40;
  temperature 0.7;
end;

begin
  var R := Narrador.Chat('había una vez');
  WriteLn(R.Text);
  WriteLn('modelo: ', R.Model, '   tokens: ', R.Tokens, '   costo: ', R.Cost:0:2);
end.
