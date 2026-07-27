-- Gênero dos leads: --


SELECT
CASE WHEN IBGE.gender = 'male' THEN 'Masculino'
	 ELSE 'Feminino' -- Como não existe nenhum outro valor além de male e female, é possível realizar dessa forma. --
	 END AS "Gênero",
COUNT(*) AS "Leads"
FROM sales.customers SC
LEFT JOIN temp_tables.ibge_genders AS IBGE
	ON SC.first_name = UPPER(IBGE.first_name)
GROUP BY IBGE.gender


-- Status profissional dos leads:

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
