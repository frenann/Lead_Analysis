-- Gênero dos leads ----------------------------------


SELECT
CASE WHEN IBGE.gender = 'male' THEN 'Masculino'
	 ELSE 'Feminino' -- Como não existe nenhum outro valor além de male e female, é possível realizar dessa forma. --
	 END AS "Gênero",
COUNT(*) AS "Leads"
FROM sales.customers SC
LEFT JOIN temp_tables.ibge_genders AS IBGE
	ON SC.first_name = UPPER(IBGE.first_name)
GROUP BY IBGE.gender


--Status profissional dos leads -------------------------------------------------------------

SELECT DISTINCT professional_status
FROM sales.customers

-- Assim, descobrimos que temos 8 status diferentes.

SELECT 
CASE WHEN professional_status = 'clt' THEN 'CLT'
	 WHEN professional_status = 'freelancer' THEN 'Freelancer'
	 WHEN professional_status = 'retired' THEN 'Aposentado'
	 WHEN professional_status = 'self_employed' THEN 'Autônomo'
	 WHEN professional_status = 'businessman' THEN 'Empresário'
	 WHEN professional_status = 'student' THEN 'Estudante'
	 WHEN professional_status = 'civil_servant' THEN 'Funcionário Público'
	 ELSE 'Outro'	 
END AS "Status Profissional",
(COUNT(*)::FLOAT)/(SELECT COUNT (*) FROM sales.customers) AS "% dos Leads"
FROM sales.customers
GROUP BY professional_status
ORDER BY "% dos Leads"


-- Faixa Etária dos Leads ----------------------------------------------------------------


-- Criando a função DATEDIFF:


CREATE OR REPLACE FUNCTION DATEDIFF(
    tipo VARCHAR,
    date_from DATE,
    date_to DATE
)
RETURNS INTEGER
LANGUAGE SQL
AS $$
    SELECT
        CASE
            WHEN tipo IN ('d', 'day', 'days')
                THEN (date_to - date_from)

            WHEN tipo IN ('w', 'week', 'weeks')
                THEN (date_to - date_from) / 7

            WHEN tipo IN ('m', 'month', 'months')
                THEN (date_to - date_from) / 30

            WHEN tipo IN ('y', 'year', 'years')
                THEN (date_to - date_from) / 365
        END;
$$;



SELECT 
CASE WHEN DATEDIFF('years', birth_date, CURRENT_DATE) < 20 THEN '0-20'
	 WHEN DATEDIFF('years', birth_date, CURRENT_DATE) < 40 THEN '20-40'
	 WHEN DATEDIFF('years', birth_date, CURRENT_DATE) < 60 THEN '40-60'
	 WHEN DATEDIFF('years', birth_date, CURRENT_DATE) < 80 THEN '60-80'
	 ELSE '80+'
END AS "Faixa Etária",
COUNT (*)::FLOAT/(SELECT COUNT(*) FROM sales.customers) AS "% dos Leads"
FROM sales.customers
GROUP BY "Faixa Etária"
ORDER BY "Faixa Etária" ASC


-- Faixa Salarial dos Leads ---------------------------------------------

SELECT 
CASE WHEN income < 5000 THEN '0-5k'
	 WHEN income  < 10000 THEN '5-10k'
	 WHEN income  < 15000 THEN '10-15k'
	 WHEN income  < 20000 THEN '15-20k'
	 ELSE '+20k'
END AS "Faixa Salarial",
COUNT (*)::FLOAT/(SELECT COUNT(*) FROM sales.customers) AS "% dos Leads",
CASE WHEN income < 5000 THEN 1
	 WHEN income  < 10000 THEN 2
	 WHEN income  < 15000 THEN 3
	 WHEN income  < 20000 THEN 4
	 ELSE 5
END AS "Ordem"
FROM sales.customers
GROUP BY "Faixa Salarial", "Ordem"
ORDER BY "Ordem" ASC


-- Classificação dos Veículos Visitados -----------------------

SELECT *
FROM sales.funnel

SELECT *
FROM sales.products

WITH Classe_Veiculo AS (

SELECT 
SF.visit_page_date,
SP.model_year,
EXTRACT('YEAR' FROM visit_page_date) - SP.model_year::INT AS "Idade_Veiculo",
CASE WHEN EXTRACT('YEAR' FROM visit_page_date) - SP.model_year::INT <= 1 THEN 'Novo'
	 WHEN EXTRACT('YEAR' FROM visit_page_date) - SP.model_year::INT <= 4 THEN 'Seminovo'
	 ELSE 'Usado'
END AS "Classificacao do Veiculo"
FROM sales.funnel SF
LEFT JOIN sales.products SP
ON SF.product_id = SP.product_id
)

SELECT 
"Classificacao do Veiculo",
COUNT (*)::FLOAT/(SELECT COUNT(*) FROM sales.funnel) AS "% dos Veículos Visitados"
FROM Classe_Veiculo
GROUP BY "Classificacao do Veiculo"



-- Idade dos Veículos -------------------------------


WITH FaixaEtaria_Veiculos AS (

SELECT 
SF.visit_page_date,
SP.model_year,
EXTRACT('YEAR' FROM visit_page_date) - SP.model_year::INT AS "Idade_Veiculo",
CASE WHEN EXTRACT('YEAR' FROM visit_page_date) - SP.model_year::INT <= 1 THEN 'Até 1 ano'
	 WHEN EXTRACT('YEAR' FROM visit_page_date) - SP.model_year::INT <= 4 THEN 'Até 4 anos'
	 WHEN EXTRACT('YEAR' FROM visit_page_date) - SP.model_year::INT <= 7 THEN 'Até 7 anos'
	 WHEN EXTRACT('YEAR' FROM visit_page_date) - SP.model_year::INT <= 10 THEN 'Até 10 anos'
	 ELSE 'Mais de 10 anos'
END AS "Idade do Veiculo",
EXTRACT('YEAR' FROM visit_page_date) - SP.model_year::INT AS "Idade_Veiculo",
CASE WHEN EXTRACT('YEAR' FROM visit_page_date) - SP.model_year::INT <= 1 THEN 1
	 WHEN EXTRACT('YEAR' FROM visit_page_date) - SP.model_year::INT <= 4 THEN 2
	 WHEN EXTRACT('YEAR' FROM visit_page_date) - SP.model_year::INT <= 7 THEN 3
	 WHEN EXTRACT('YEAR' FROM visit_page_date) - SP.model_year::INT <= 10 THEN 4
	 ELSE 5
END AS "Ordem"
FROM sales.funnel SF
LEFT JOIN sales.products SP
ON SF.product_id = SP.product_id
)

SELECT 
"Idade do Veiculo",
COUNT (*)::FLOAT/(SELECT COUNT(*) FROM sales.funnel) AS "% Veículos Visitados",
"Ordem"
FROM FaixaEtaria_Veiculos
GROUP BY "Idade do Veiculo", "Ordem"
ORDER BY "Ordem" ASC


-- Veículos Mais Visitados por Marca ---------------------------------------

SELECT
SP.brand AS "Marca",
SP.model AS "Modelo",
COUNT(*) AS "Visitas"
FROM sales.funnel SF
LEFT JOIN sales.products SP
ON SF.product_id = SP.product_id
GROUP BY SP.brand, SP.model
ORDER BY SP.brand, SP.model, "Visitas" 