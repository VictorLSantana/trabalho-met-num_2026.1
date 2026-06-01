
set.seed(123) # Para garantir a reprodutibilidade dos resultados

n = 50 # Tamanho da amostra

dados = data.frame(
  id = 1:n,
  genero = sample(
    c("Feminino", "Masculino"),
    n,
    replace = TRUE,
    prob = c(0.65, 0.35) # Proporção obtida após coleta de campo
  ),
  faixa_etaria = sample(
    c("18-34", "35+"),
    n,
    replace = TRUE,
    prob = c(0.55, 0.45) # Proporção obtida após coleta de campo
  )
)

# Mostrar as proporções de cada categoria 
genero_resumo = prop.table(table(dados$genero))

genero_resumo = data.frame(
  Categoria = names(genero_resumo),
  Proporcao = round(as.numeric(genero_resumo) * 100, 1)
)

names(genero_resumo)[2] = "(%)"

#genero_resumo

idade_resumo = prop.table(table(dados$faixa_etaria))

idade_resumo = data.frame(
  Categoria = names(idade_resumo),
  Proporcao = round(as.numeric(idade_resumo) * 100, 1)
)

names(idade_resumo)[2] = "(%)"

#idade_resumo

head(dados)
table(dados$genero, dados$faixa_etaria)