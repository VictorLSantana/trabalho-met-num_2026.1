
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

