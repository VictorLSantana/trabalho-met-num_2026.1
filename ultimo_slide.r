

#install.packages("Rglpk")
#install.packages("dplyr")

# ---------------------------------------------------------
# Carregamento "Força Bruta" - Silencia absolutamente tudo
# ---------------------------------------------------------

# Abre um sumidouro para desviar mensagens e avisos padrão
msg_sink <- textConnection("foo", "w", local = TRUE)
sink(msg_sink, type = "message")

# Carrega os pacotes de forma ultra-silenciosa
library(Rglpk, quietly = TRUE, warn.conflicts = FALSE)
library(dplyr, quietly = TRUE, warn.conflicts = FALSE)

# Fecha o sumidouro e volta o terminal ao normal
sink(type = "message")
close(msg_sink)
rm(msg_sink)
# -------------------------
# Dados simulados
# -------------------------

set.seed(123)

dados = data.frame(
  id = 1:50,
  genero = sample(
    c("Feminino", "Masculino"),
    50,
    replace = TRUE,
    prob = c(0.65, 0.35)
  ),
  faixa_etaria = sample(
    c("18-34", "35+"),
    50,
    replace = TRUE,
    prob = c(0.55, 0.45)
  )
)

n = nrow(dados)

# -------------------------
# Metas populacionais
# -------------------------

meta_feminino = 26  # 52% de 50
meta_jovem = 20     # 40% de 50
meta_total = 50

# -------------------------
# Função objetivo
# -------------------------
# Variáveis:
# w1,...,w50,d1,...,d50

obj = c(
  rep(0, n),
  rep(1, n)
)

# -------------------------
# Restrições de calibração
# -------------------------

linha_feminino = c(
  as.numeric(dados$genero == "Feminino"),
  rep(0, n)
)

linha_jovem = c(
  as.numeric(dados$faixa_etaria == "18-34"),
  rep(0, n)
)

linha_total = c(
  rep(1, n),
  rep(0, n)
)

# -------------------------
# Linearização
# wi - di <= 1
# -wi - di <= -1
# -------------------------

A1 = matrix(0, nrow = n, ncol = 2*n)

for(i in 1:n){
  A1[i,i] = 1
  A1[i,n+i] = -1
}

A2 = matrix(0, nrow = n, ncol = 2*n)

for(i in 1:n){
  A2[i,i] = -1
  A2[i,n+i] = -1
}

mat = rbind(
  linha_feminino,
  linha_jovem,
  linha_total,
  A1,
  A2
)

dir = c(
  "==",
  "==",
  "==",
  rep("<=", n),
  rep("<=", n)
)

rhs = c(
  meta_feminino,
  meta_jovem,
  meta_total,
  rep(1, n),
  rep(-1, n)
)

bounds = list(
  lower = list(
    ind = 1:(2*n),
    val = rep(0, 2*n)
  )
)

# -------------------------
# Resolver
# -------------------------

sol = Rglpk_solve_LP(
  obj = obj,
  mat = mat,
  dir = dir,
  rhs = rhs,
  bounds = bounds,
  max = FALSE
)

dados$peso_calibrado = sol$solution[1:n]

# -------------------------
# Distribuição original
# -------------------------

sexo_original = dados %>%
  count(genero) %>%
  mutate(
    percentual = round(n/sum(n)*100, 1)
  )

idade_original = dados %>%
  count(faixa_etaria) %>%
  mutate(
    percentual = round(n/sum(n)*100, 1)
  )

# -------------------------
# Distribuição calibrada
# -------------------------

sexo_calibrado = dados %>%
  group_by(genero) %>%
  summarise(
    peso = sum(peso_calibrado)
  ) %>%
  mutate(
    percentual = round(peso/sum(peso)*100, 1)
  )

idade_calibrada = dados %>%
  group_by(faixa_etaria) %>%
  summarise(
    peso = sum(peso_calibrado)
  ) %>%
  mutate(
    percentual = round(peso/sum(peso)*100, 1)
  )

# -------------------------
# Resultados
# -------------------------

#cat("\nDistribuição original - Sexo\n")
#print(sexo_original)

#cat("\nDistribuição calibrada - Sexo\n")
#print(sexo_calibrado)

cat("\nDistribuição original - Faixa Etária\n")
print(idade_original)

cat("\nDistribuição calibrada - Faixa Etária\n")
print(idade_calibrada)

#cat("\nPrimeiros pesos calibrados\n")
#print(head(dados[,c("id","genero","faixa_etaria","peso_calibrado")]))