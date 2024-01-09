DELIMITER // CREATE PROCEDURE inserir_venda() 
BEGIN
    SELECT
        *
    FROM
        banco_stage.vendas
    WHERE
        banco_stage.nome_cliente IS NOT NULL
        AND banco_stage.cnpj_cliente IS NOT NULL
        AND banco_stage.email_cliente IS NOT NULL
        AND banco_stage.telefone_cliente IS NOT NULL
        AND banco_stage.numero_nf IS NOT NULL
        AND banco_stage.data_emissao IS NOT NULL
        AND banco_stage.valor_net IS NOT NULL
        AND banco_stage.valor_tributo IS NOT NULL
        AND banco_stage.valor_total IS NOT NULL
        AND banco_stage.nome_item IS NOT NULL
        AND banco_stage.qtd_item IS NOT NULL
        AND banco_stage.condicao_pagamento IS NOT NULL
        AND banco_stage.cep IS NOT NULL
        AND banco_stage.num_endereco IS NOT NULL
        AND banco_stage.tipo_endereco IS NOT NULL
        AND banco_stage.data_processamento IS NOT NULL;

    
    INSERT INTO
            projeto_finaceiro.clientes (
            nome,
            cnpj,
            email,
            telefone,
            )
        VALUES
            (
            select
                bs.nome_cliente, bs.cnpj_cliente, bs.email_cliente, bs.telefone_cliente
            from
                banco_stage.vendas bs WHERE bs.cnpj_cliente NOT in (select pf.cnpj from projeto_finaceiro.clientes pf) AND
                bs.nome_cliente IS NOT NULL
                AND bs.cnpj_cliente IS NOT NULL
                AND bs.email_cliente IS NOT NULL
                AND bs.telefone_cliente IS NOT NULL
                AND bs.numero_nf IS NOT NULL
                AND bs.data_emissao IS NOT NULL
                AND bs.valor_net IS NOT NULL
                AND bs.valor_tributo IS NOT NULL
                AND bs.valor_total IS NOT NULL
                AND bs.nome_item IS NOT NULL
                AND bs.qtd_item IS NOT NULL
                AND bs.condicao_pagamento IS NOT NULL
                AND bs.cep IS NOT NULL
                AND bs.num_endereco IS NOT NULL
                AND bs.tipo_endereco IS NOT NULL
                AND bs.data_processamento IS NOT NULL
                AND bs.cep in (select pf.cep from projeto_financeiro.cep pf);
            );

    -- Se não houver campos obrigatórios nulos, realiza o INSERT

    INSERT INTO
        notas_fiscais_saida (
            data_emissao,
            nome_item,
            numero_item,
            qtd_item,
            valor_nf,
            valor_tributo,
            valor_total,
            id_condicao,
            id_clientes
        )
            select bs.data_emissao, bs.nome_item, bs.numero_nf, bs.qtd_item, bs.valor_net,bs.valor_tributo, bs.valor_total, cd.id_condicao,pj.id_clientes from 
            banco_stage.vendas bs inner join projeto_financeiro.clientes pj on (pj.cnpj = bs.cnpj_cliente)
            inner join projeto_finaceiro.condicao_pagamento cd on (bs.condicao_pagamento = cd.descricao) WHERE
            bs.nome_cliente IS NOT NULL
            AND bs.cnpj_cliente IS NOT NULL
            AND bs.email_cliente IS NOT NULL
            AND bs.telefone_cliente IS NOT NULL
            AND bs.numero_nf IS NOT NULL
            AND bs.data_emissao IS NOT NULL
            AND bs.valor_net IS NOT NULL
            AND bs.valor_tributo IS NOT NULL
            AND bs.valor_total IS NOT NULL
            AND bs.nome_item IS NOT NULL
            AND bs.qtd_item IS NOT NULL
            AND bs.condicao_pagamento IS NOT NULL
            AND bs.cep IS NOT NULL
            AND bs.num_endereco IS NOT NULL
            AND bs.tipo_endereco IS NOT NULL
            AND bs.data_processamento IS NOT NULL
            AND bs.cep in (select pf.cep from projeto_financeiro.cep pf)
            AND bs.numero_nf not in (select pf.numero_item from projeto_financeiro.notas_fiscais_saida pf);

            2*select date(data_emissao+1) from banco_stage.vendas

        Insert Into projeto_financeiro.programacao_recebimento
            select data_emissao+30 as data_vencimento,  from projeto_financeiro.notas_fiscais_saida pf inner join condicao_pagamento cd on pf.id_condicao = cd.id_condicao
             where id_nf_saida not in (select id_nf_saida from programacao_recebimento)

    

END / / DELIMITER;

30 dias
30 dias
30/60 dias

A vista
30 dias
30/60 dias



PreencherParcelas(select cd.quantidade_parcela,pf.data_processamento,pf.valor_total,pf.id_nf_saida from projeto_financeiro.notas_fiscais_saida pf inner join projeto_financeiro.condicao_pagamento cd on (pf.id_condicao = cd.id_condicao))
DELIMITER //
CREATE PROCEDURE PreencherParcelas(
    IN numeroParcelas INT,
    IN data_vencimento DATE,
    IN valorParcela DECIMAL(16, 2),
    IN idNotaFiscal INT
)
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= numeroParcelas DO
        INSERT INTO programacao_recebimento (
            data_vencimento,
            numero_parcela,
            status_recebimento,
            valor_parcela,
            id_nf_saida
        ) VALUES (
            CASE
                WHEN (SELECT pf.id_condicao FROM projeto_financeiro.notas_fiscais_saida pf INNER JOIN projeto_financeiro.condicao_pagamento cd ON (pf.id_condicao = cd.id_condicao) WHERE pf.numero_item = idNotaFiscal) = 1 THEN
                    data_vencimento
                WHEN (SELECT pf.id_condicao FROM projeto_financeiro.notas_fiscais_saida pf INNER JOIN projeto_financeiro.condicao_pagamento cd ON (pf.id_condicao = cd.id_condicao) WHERE pf.numero_item = idNotaFiscal) IN (2, 3, 4) THEN
                    DATE_ADD(data_vencimento, INTERVAL i MONTH)
                WHEN (SELECT pf.id_condicao FROM projeto_financeiro.notas_fiscais_saida pf INNER JOIN projeto_financeiro.condicao_pagamento cd ON (pf.id_condicao = cd.id_condicao) WHERE pf.numero_item = idNotaFiscal) IN (5, 6, 7) THEN
                    DATE_ADD(data_vencimento, INTERVAL (i - 1) MONTH)
            END,
            i,
            CASE
                WHEN (SELECT pf.id_condicao FROM projeto_financeiro.notas_fiscais_saida pf INNER JOIN projeto_financeiro.condicao_pagamento cd ON (pf.id_condicao = cd.id_condicao) WHERE pf.numero_item = idNotaFiscal) = 1 THEN
                    'Aprovado'
                ELSE
                    'Aguardando Pagamento'
            END,
            valorParcela / numeroParcelas,
            idNotaFiscal
        );

        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;