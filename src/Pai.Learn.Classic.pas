unit Pai.Learn.Classic;

// Modelos clásicos, escritos para leerse: regresión lineal, regresión logística y árbol de decisión.
// Sin trucos: cada uno aprende con un bucle que se puede seguir paso a paso.
//
//   var M := TLinearRegression.Create;
//   M.Fit(X, Y, 0.1, 500);              // X: una fila por ejemplo; Y: el valor esperado
//   WriteLn(M.Predict([3, 1]):0:2);
//
//   var T := TDecisionTree.Create(3);   // como mucho 3 preguntas seguidas
//   T.Fit(Datasets.Iris);
//   WriteLn(T.Predict([5.1, 3.5, 1.4, 0.2]));   // 0: setosa
//   WriteLn(T.ToString);                         // las preguntas que aprendió

interface

uses
  SysUtils, Generics.Collections, Pai.Learn.Linalg, Pai.Learn.Data, Pai.Learn.Plot;

type
  /// Regresión lineal: Y ≈ W · X + B. Aprende W y B con descenso del gradiente sobre el error
  /// cuadrático medio (o con la ecuación cerrada, Solve).
  TLinearRegression = class
  public
    W: TVec;
    B: Double;
    /// Cuántas pasadas hizo y el error de la última (para graficar cómo baja).
    Losses: TArray<Double>;
    /// Descenso del gradiente: Epochs pasadas con paso Rate.
    procedure Fit(const X: TMatrix; const Y: TVec; Rate: Double = 0.05; Epochs: Integer = 500);
    function Predict(const X: TVec): Double;
    /// El error cuadrático medio sobre esos ejemplos.
    function Loss(const X: TMatrix; const Y: TVec): Double;
  end;

  /// Regresión logística: la probabilidad de la clase 1 es sigmoide(W · X + B). Aprende con descenso
  /// del gradiente sobre la entropía cruzada. Y son 0 o 1.
  TLogisticRegression = class
  public
    W: TVec;
    B: Double;
    Losses: TArray<Double>;
    procedure Fit(const X: TMatrix; const Y: TVec; Rate: Double = 0.5; Epochs: Integer = 500);
    /// La probabilidad de la clase 1.
    function Probability(const X: TVec): Double;
    /// 1 si la probabilidad es al menos 0,5; si no, 0.
    function Predict(const X: TVec): Integer;
    function Loss(const X: TMatrix; const Y: TVec): Double;
  end;

  /// Un nodo del árbol: o pregunta (¿X[Feature] <= Threshold?) o es una hoja con su clase.
  TTreeNode = class
  public
    IsLeaf: Boolean;
    LabelIndex: Integer;         // la clase de la hoja (o la más común del nodo)
    Feature: Integer;
    Threshold: Double;
    Gini: Double;                // la impureza de los ejemplos que llegaron aquí (0 = todos de una clase)
    Count: Integer;              // cuántos ejemplos llegaron
    Left, Right: TTreeNode;      // sí (<=) y no (>)
    destructor Destroy; override;
  end;

  /// Árbol de decisión (CART con Gini): en cada nodo busca la pregunta ¿X[f] <= t? que mejor separa
  /// las clases (la que deja los grupos más puros) hasta MaxDepth preguntas o hasta que un grupo es puro.
  TDecisionTree = class
  private
    FClassNames: TArray<string>;
    FFeatureNames: TArray<string>;
    function Build(const X: TMatrix; const L: TArray<Integer>; const Rows: TArray<Integer>; Depth: Integer): TTreeNode;
    function NodeText(N: TTreeNode; const Indent: string): string;
    function PlotNode(N: TTreeNode): TPlotNode;
  public
    Root: TTreeNode;
    MaxDepth: Integer;
    MinSamples: Integer;         // un nodo con menos ejemplos no se parte
    constructor Create(AMaxDepth: Integer = 3; AMinSamples: Integer = 2);
    destructor Destroy; override;
    procedure Fit(const D: TDataset); overload;
    procedure Fit(const X: TMatrix; const Labels: TArray<Integer>; Classes: Integer); overload;
    function Predict(const X: TVec): Integer;
    /// Las preguntas, una por línea, con sangría por nivel.
    function ToString: string;
    /// Para Plot: TreeSvg(T.ToPlot).
    function ToPlot: TPlotNode;
    property FeatureNames: TArray<string> read FFeatureNames write FFeatureNames;
  end;

function Sigmoid(Z: Double): Double;

implementation

uses
  Math;

function Sigmoid(Z: Double): Double;
begin
  Result := 1 / (1 + Exp(-Z));
end;

// ------------------------------------------------------------------ regresión lineal

procedure TLinearRegression.Fit(const X: TMatrix; const Y: TVec; Rate: Double; Epochs: Integer);
begin
  SetLength(W, X.Cols);
  for var J := 0 to X.Cols - 1 do
    W[J] := 0;
  B := 0;
  Losses := [];
  var N := X.Rows;
  for var E := 1 to Epochs do
  begin
    // el gradiente del error cuadrático medio: 2/N * suma((predicho - Y) * X)
    var GW: TVec;
    SetLength(GW, X.Cols);
    for var J := 0 to X.Cols - 1 do
      GW[J] := 0;
    var GB: Double := 0.0;
    for var I := 0 to N - 1 do
    begin
      var Err := Predict(X.Row(I)) - Y[I];
      for var J := 0 to X.Cols - 1 do
        GW[J] := GW[J] + 2 * Err * X[I, J] / N;
      GB := GB + 2 * Err / N;
    end;
    for var J := 0 to X.Cols - 1 do
      W[J] := W[J] - Rate * GW[J];
    B := B - Rate * GB;
    Losses := Losses + [Loss(X, Y)];
  end;
end;

function TLinearRegression.Predict(const X: TVec): Double;
begin
  Result := Dot(W, X) + B;
end;

function TLinearRegression.Loss(const X: TMatrix; const Y: TVec): Double;
begin
  Result := 0;
  for var I := 0 to X.Rows - 1 do
    Result := Result + Sqr(Predict(X.Row(I)) - Y[I]);
  Result := Result / X.Rows;
end;

// ------------------------------------------------------------------ regresión logística

procedure TLogisticRegression.Fit(const X: TMatrix; const Y: TVec; Rate: Double; Epochs: Integer);
begin
  SetLength(W, X.Cols);
  for var J := 0 to X.Cols - 1 do
    W[J] := 0;
  B := 0;
  Losses := [];
  var N := X.Rows;
  for var E := 1 to Epochs do
  begin
    // el gradiente de la entropía cruzada es el mismo de la regresión lineal sin el 2: (p - y) * x
    var GW: TVec;
    SetLength(GW, X.Cols);
    for var J := 0 to X.Cols - 1 do
      GW[J] := 0;
    var GB: Double := 0.0;
    for var I := 0 to N - 1 do
    begin
      var Err := Probability(X.Row(I)) - Y[I];
      for var J := 0 to X.Cols - 1 do
        GW[J] := GW[J] + Err * X[I, J] / N;
      GB := GB + Err / N;
    end;
    for var J := 0 to X.Cols - 1 do
      W[J] := W[J] - Rate * GW[J];
    B := B - Rate * GB;
    Losses := Losses + [Loss(X, Y)];
  end;
end;

function TLogisticRegression.Probability(const X: TVec): Double;
begin
  Result := Sigmoid(Dot(W, X) + B);
end;

function TLogisticRegression.Predict(const X: TVec): Integer;
begin
  if Probability(X) >= 0.5 then Result := 1 else Result := 0;
end;

function TLogisticRegression.Loss(const X: TMatrix; const Y: TVec): Double;
begin
  Result := 0;
  for var I := 0 to X.Rows - 1 do
  begin
    var P := Min(Max(Probability(X.Row(I)), 1e-12), 1 - 1e-12);
    Result := Result - (Y[I] * Ln(P) + (1 - Y[I]) * Ln(1 - P));
  end;
  Result := Result / X.Rows;
end;

// ------------------------------------------------------------------ árbol de decisión

destructor TTreeNode.Destroy;
begin
  Left.Free;
  Right.Free;
  inherited;
end;

constructor TDecisionTree.Create(AMaxDepth, AMinSamples: Integer);
begin
  inherited Create;
  MaxDepth := AMaxDepth;
  MinSamples := AMinSamples;
end;

destructor TDecisionTree.Destroy;
begin
  Root.Free;
  inherited;
end;

function GiniOf(const Counts: TArray<Integer>; N: Integer): Double;
begin
  Result := 1;
  if N = 0 then
    Exit(0);
  for var C in Counts do
    Result := Result - Sqr(C / N);
end;

function TDecisionTree.Build(const X: TMatrix; const L: TArray<Integer>; const Rows: TArray<Integer>;
  Depth: Integer): TTreeNode;
var
  Counts: TArray<Integer>;
begin
  Result := TTreeNode.Create;
  SetLength(Counts, Length(FClassNames));
  for var C := 0 to High(Counts) do
    Counts[C] := 0;
  for var R in Rows do
    Inc(Counts[L[R]]);
  Result.Count := Length(Rows);
  Result.Gini := GiniOf(Counts, Length(Rows));
  Result.LabelIndex := 0;
  for var C := 1 to High(Counts) do
    if Counts[C] > Counts[Result.LabelIndex] then
      Result.LabelIndex := C;
  Result.IsLeaf := True;
  if (Depth >= MaxDepth) or (Length(Rows) < MinSamples) or (Result.Gini = 0) then
    Exit;
  // la mejor pregunta: la que deja menos impureza (Gini ponderado por tamaño)
  var Best := Result.Gini;
  var BestF := -1;
  var BestT: Double := 0.0;
  for var F := 0 to X.Cols - 1 do
  begin
    // los umbrales posibles: el punto medio entre valores distintos, ordenados
    var Vals: TArray<Double>;
    SetLength(Vals, Length(Rows));
    for var I := 0 to High(Rows) do
      Vals[I] := X[Rows[I], F];
    TArray.Sort<Double>(Vals);
    for var I := 1 to High(Vals) do
    begin
      if Vals[I] = Vals[I - 1] then
        Continue;
      var T := (Vals[I] + Vals[I - 1]) / 2;
      var CL, CR: TArray<Integer>;
      SetLength(CL, Length(FClassNames));
      SetLength(CR, Length(FClassNames));
      for var C := 0 to High(CL) do
      begin
        CL[C] := 0;
        CR[C] := 0;
      end;
      var NL := 0;
      for var R in Rows do
        if X[R, F] <= T then
        begin
          Inc(CL[L[R]]);
          Inc(NL);
        end
        else
          Inc(CR[L[R]]);
      var NR := Length(Rows) - NL;
      var G := (NL * GiniOf(CL, NL) + NR * GiniOf(CR, NR)) / Length(Rows);
      if G < Best - 1e-12 then
      begin
        Best := G;
        BestF := F;
        BestT := T;
      end;
    end;
  end;
  if BestF < 0 then
    Exit;                        // ninguna pregunta mejora: hoja
  var LeftRows, RightRows: TArray<Integer>;
  LeftRows := [];
  RightRows := [];
  for var R in Rows do
    if X[R, BestF] <= BestT then
      LeftRows := LeftRows + [R]
    else
      RightRows := RightRows + [R];
  Result.IsLeaf := False;
  Result.Feature := BestF;
  Result.Threshold := BestT;
  Result.Left := Build(X, L, LeftRows, Depth + 1);
  Result.Right := Build(X, L, RightRows, Depth + 1);
end;

procedure TDecisionTree.Fit(const X: TMatrix; const Labels: TArray<Integer>; Classes: Integer);
var
  Rows: TArray<Integer>;
begin
  FreeAndNil(Root);
  if Length(FClassNames) <> Classes then
  begin
    SetLength(FClassNames, Classes);
    for var C := 0 to Classes - 1 do
      FClassNames[C] := IntToStr(C);
  end;
  SetLength(Rows, X.Rows);
  for var I := 0 to X.Rows - 1 do
    Rows[I] := I;
  Root := Build(X, Labels, Rows, 0);
end;

procedure TDecisionTree.Fit(const D: TDataset);
begin
  FClassNames := D.ClassNames;
  var K := Length(D.ClassNames);
  if K = 0 then
    for var Lb in D.Labels do
      if Lb + 1 > K then
        K := Lb + 1;
  Fit(D.X, D.Labels, K);
end;

function TDecisionTree.Predict(const X: TVec): Integer;
begin
  if Root = nil then
    raise EInvalidOpException.Create('el árbol no aprendió todavía: llame a Fit');
  var N := Root;
  while not N.IsLeaf do
    if X[N.Feature] <= N.Threshold then
      N := N.Left
    else
      N := N.Right;
  Result := N.LabelIndex;
end;

function TDecisionTree.NodeText(N: TTreeNode; const Indent: string): string;
begin
  if N.IsLeaf then
    Exit(Indent + '→ ' + FClassNames[N.LabelIndex] + ' (' + IntToStr(N.Count) + ')' + sLineBreak);
  var Name := 'X[' + IntToStr(N.Feature) + ']';
  if N.Feature < Length(FFeatureNames) then
    Name := FFeatureNames[N.Feature];
  Result := Indent + '¿' + Name + ' <= ' + FormatFloat('0.###', N.Threshold) + '?' + sLineBreak;
  // cada rama: la respuesta y, debajo, lo que sigue (una hoja en la misma línea)
  for var K := 0 to 1 do
  begin
    var C := N.Left;
    var Answer := 'sí';
    if K = 1 then
    begin
      C := N.Right;
      Answer := 'no';
    end;
    if C.IsLeaf then
      Result := Result + Indent + '  ' + Answer + ': → ' + FClassNames[C.LabelIndex] + ' (' + IntToStr(C.Count) + ')' +
        sLineBreak
    else
      Result := Result + Indent + '  ' + Answer + ':' + sLineBreak + NodeText(C, Indent + '    ');
  end;
end;

function TDecisionTree.ToString: string;
begin
  if Root = nil then
    Exit('(sin aprender)');
  Result := NodeText(Root, '').TrimRight;
end;

function TDecisionTree.PlotNode(N: TTreeNode): TPlotNode;
begin
  Result := TPlotNode.Create;
  if N.IsLeaf then
    Result.Text := FClassNames[N.LabelIndex] + ' (' + IntToStr(N.Count) + ')'
  else
  begin
    var Name := 'X[' + IntToStr(N.Feature) + ']';
    if N.Feature < Length(FFeatureNames) then
      Name := FFeatureNames[N.Feature];
    Result.Text := Name + ' <= ' + FormatFloat('0.###', N.Threshold);
    Result.Children := [PlotNode(N.Left), PlotNode(N.Right)];
    Result.EdgeLabels := ['sí', 'no'];
  end;
end;

function TDecisionTree.ToPlot: TPlotNode;
begin
  if Root = nil then
    raise EInvalidOpException.Create('el árbol no aprendió todavía: llame a Fit');
  Result := PlotNode(Root);
end;

end.
