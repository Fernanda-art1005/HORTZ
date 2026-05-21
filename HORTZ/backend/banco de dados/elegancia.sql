-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 21/05/2026 às 03:14
-- Versão do servidor: 10.4.32-MariaDB
-- Versão do PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `elegancia`
--

-- --------------------------------------------------------

--
-- Estrutura para tabela `aliquota_imposto`
--

CREATE TABLE `aliquota_imposto` (
  `id` varchar(36) NOT NULL,
  `descricao` varchar(100) NOT NULL,
  `percentual` decimal(5,2) NOT NULL,
  `ativa` tinyint(1) NOT NULL DEFAULT 1,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Despejando dados para a tabela `aliquota_imposto`
--

INSERT INTO `aliquota_imposto` (`id`, `descricao`, `percentual`, `ativa`, `criado_em`, `atualizado_em`) VALUES
('47c3d623-54b2-11f1-b76e-047c16fa71ed', 'Alíquota Padrão (ISS/ICMS simplificado)', 5.00, 1, '2026-05-20 22:13:30', '2026-05-20 22:13:30');

--
-- Acionadores `aliquota_imposto`
--
DELIMITER $$
CREATE TRIGGER `trg_aliquota_uuid` BEFORE INSERT ON `aliquota_imposto` FOR EACH ROW BEGIN IF NEW.id IS NULL OR NEW.id = '' THEN SET NEW.id = UUID(); END IF; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `clientes`
--

CREATE TABLE `clientes` (
  `id` varchar(36) NOT NULL,
  `nome` varchar(150) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `telefone` varchar(30) DEFAULT NULL,
  `limite_credito` decimal(12,2) NOT NULL DEFAULT 0.00,
  `saldo_devedor` decimal(12,2) NOT NULL DEFAULT 0.00,
  `status` enum('ativo','inadimplente','bloqueado') NOT NULL DEFAULT 'ativo',
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `criado_por` varchar(36) DEFAULT NULL,
  `credito_disponivel` decimal(12,2) GENERATED ALWAYS AS (`limite_credito` - `saldo_devedor`) STORED
) ;

--
-- Acionadores `clientes`
--
DELIMITER $$
CREATE TRIGGER `trg_clientes_uuid` BEFORE INSERT ON `clientes` FOR EACH ROW BEGIN IF NEW.id IS NULL OR NEW.id = '' THEN SET NEW.id = UUID(); END IF; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `funis_kanban`
--

CREATE TABLE `funis_kanban` (
  `id` varchar(36) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `ordem` int(11) NOT NULL DEFAULT 0,
  `cor` varchar(7) DEFAULT NULL,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `criado_por` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Colunas do quadro kanban. Ordem define a sequência de exibição.';

--
-- Despejando dados para a tabela `funis_kanban`
--

INSERT INTO `funis_kanban` (`id`, `nome`, `ordem`, `cor`, `criado_em`, `criado_por`) VALUES
('47cbc7fb-54b2-11f1-b76e-047c16fa71ed', 'A Fazer', 1, '#5B8DEF', '2026-05-20 22:13:31', NULL),
('47cbdc42-54b2-11f1-b76e-047c16fa71ed', 'Em Andamento', 2, '#F5A623', '2026-05-20 22:13:31', NULL),
('47cbdd20-54b2-11f1-b76e-047c16fa71ed', 'Em Revisão', 3, '#9B59B6', '2026-05-20 22:13:31', NULL),
('47cbdd61-54b2-11f1-b76e-047c16fa71ed', 'Concluído', 4, '#27AE60', '2026-05-20 22:13:31', NULL);

--
-- Acionadores `funis_kanban`
--
DELIMITER $$
CREATE TRIGGER `trg_funis_uuid` BEFORE INSERT ON `funis_kanban` FOR EACH ROW BEGIN IF NEW.id IS NULL OR NEW.id = '' THEN SET NEW.id = UUID(); END IF; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `itens_venda`
--

CREATE TABLE `itens_venda` (
  `id` varchar(36) NOT NULL,
  `venda_id` varchar(36) NOT NULL,
  `produto_id` varchar(36) NOT NULL,
  `nome_produto` varchar(200) NOT NULL,
  `preco_unitario` decimal(12,2) NOT NULL,
  `quantidade` int(11) NOT NULL,
  `subtotal` decimal(12,2) GENERATED ALWAYS AS (`preco_unitario` * `quantidade`) STORED
) ;

--
-- Acionadores `itens_venda`
--
DELIMITER $$
CREATE TRIGGER `trg_itens_venda_uuid` BEFORE INSERT ON `itens_venda` FOR EACH ROW BEGIN IF NEW.id IS NULL OR NEW.id = '' THEN SET NEW.id = UUID(); END IF; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `log_auditoria`
--

CREATE TABLE `log_auditoria` (
  `id` varchar(36) NOT NULL,
  `usuario_id` varchar(36) DEFAULT NULL,
  `nome_usuario` varchar(150) NOT NULL,
  `perfil_usuario` enum('administrador','caixa','estoque') DEFAULT NULL,
  `tipo_acao` enum('login','logout','criar','editar','excluir','venda_concluida','venda_cancelada','pagamento_recebido','estoque_atualizado','convite_enviado','membro_removido','permissao_alterada') NOT NULL,
  `modulo` varchar(60) NOT NULL,
  `descricao` text NOT NULL,
  `valor` decimal(12,2) DEFAULT NULL,
  `status` varchar(60) DEFAULT NULL,
  `referencia_id` varchar(36) DEFAULT NULL,
  `ip_origem` varchar(45) DEFAULT NULL,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Log de auditoria imutável. Nenhuma linha pode ser alterada ou excluída.';

--
-- Acionadores `log_auditoria`
--
DELIMITER $$
CREATE TRIGGER `trg_log_uuid` BEFORE INSERT ON `log_auditoria` FOR EACH ROW BEGIN IF NEW.id IS NULL OR NEW.id = '' THEN SET NEW.id = UUID(); END IF; END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_proteger_log_delete` BEFORE DELETE ON `log_auditoria` FOR EACH ROW BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O log de auditoria é imutável. Operações de DELETE não são permitidas.'; END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_proteger_log_update` BEFORE UPDATE ON `log_auditoria` FOR EACH ROW BEGIN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O log de auditoria é imutável. Operações de UPDATE não são permitidas.'; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `pagamentos_credito`
--

CREATE TABLE `pagamentos_credito` (
  `id` varchar(36) NOT NULL,
  `cliente_id` varchar(36) NOT NULL,
  `usuario_id` varchar(36) NOT NULL,
  `valor_pago` decimal(12,2) NOT NULL,
  `saldo_anterior` decimal(12,2) NOT NULL,
  `saldo_posterior` decimal(12,2) NOT NULL,
  `observacoes` text DEFAULT NULL,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp()
) ;

--
-- Acionadores `pagamentos_credito`
--
DELIMITER $$
CREATE TRIGGER `trg_pagamentos_uuid` BEFORE INSERT ON `pagamentos_credito` FOR EACH ROW BEGIN IF NEW.id IS NULL OR NEW.id = '' THEN SET NEW.id = UUID(); END IF; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `permissoes`
--

CREATE TABLE `permissoes` (
  `id` varchar(36) NOT NULL,
  `perfil` enum('administrador','caixa','estoque') NOT NULL,
  `modulo` varchar(60) NOT NULL,
  `pode_visualizar` tinyint(1) NOT NULL DEFAULT 0,
  `pode_criar` tinyint(1) NOT NULL DEFAULT 0,
  `pode_editar` tinyint(1) NOT NULL DEFAULT 0,
  `pode_excluir` tinyint(1) NOT NULL DEFAULT 0,
  `atualizado_em` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `atualizado_por` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Permissões por perfil e módulo. Gerenciadas pelo administrador.';

--
-- Despejando dados para a tabela `permissoes`
--

INSERT INTO `permissoes` (`id`, `perfil`, `modulo`, `pode_visualizar`, `pode_criar`, `pode_editar`, `pode_excluir`, `atualizado_em`, `atualizado_por`) VALUES
('47d041e0-54b2-11f1-b76e-047c16fa71ed', 'administrador', 'dashboard', 1, 1, 1, 1, '2026-05-20 22:13:31', NULL),
('47d063e1-54b2-11f1-b76e-047c16fa71ed', 'administrador', 'caixa', 1, 1, 1, 1, '2026-05-20 22:13:31', NULL),
('47d064f6-54b2-11f1-b76e-047c16fa71ed', 'administrador', 'estoque', 1, 1, 1, 1, '2026-05-20 22:13:31', NULL),
('47d0655c-54b2-11f1-b76e-047c16fa71ed', 'administrador', 'financeiro', 1, 1, 1, 1, '2026-05-20 22:13:31', NULL),
('47d0659e-54b2-11f1-b76e-047c16fa71ed', 'administrador', 'relatorio', 1, 0, 0, 0, '2026-05-20 22:13:31', NULL),
('47d065dd-54b2-11f1-b76e-047c16fa71ed', 'administrador', 'tarefas', 1, 1, 1, 1, '2026-05-20 22:13:31', NULL),
('47d06619-54b2-11f1-b76e-047c16fa71ed', 'administrador', 'clientes', 1, 1, 1, 1, '2026-05-20 22:13:31', NULL),
('47d06656-54b2-11f1-b76e-047c16fa71ed', 'administrador', 'equipe', 1, 1, 1, 1, '2026-05-20 22:13:31', NULL),
('47d06695-54b2-11f1-b76e-047c16fa71ed', 'caixa', 'dashboard', 1, 0, 0, 0, '2026-05-20 22:13:31', NULL),
('47d066d1-54b2-11f1-b76e-047c16fa71ed', 'caixa', 'caixa', 1, 1, 1, 0, '2026-05-20 22:13:31', NULL),
('47d06709-54b2-11f1-b76e-047c16fa71ed', 'caixa', 'estoque', 0, 0, 0, 0, '2026-05-20 22:13:31', NULL),
('47d06743-54b2-11f1-b76e-047c16fa71ed', 'caixa', 'financeiro', 0, 0, 0, 0, '2026-05-20 22:13:31', NULL),
('47d06780-54b2-11f1-b76e-047c16fa71ed', 'caixa', 'relatorio', 0, 0, 0, 0, '2026-05-20 22:13:31', NULL),
('47d067b9-54b2-11f1-b76e-047c16fa71ed', 'caixa', 'tarefas', 1, 1, 1, 0, '2026-05-20 22:13:31', NULL),
('47d067f2-54b2-11f1-b76e-047c16fa71ed', 'caixa', 'clientes', 1, 0, 0, 0, '2026-05-20 22:13:31', NULL),
('47d06829-54b2-11f1-b76e-047c16fa71ed', 'caixa', 'equipe', 0, 0, 0, 0, '2026-05-20 22:13:31', NULL),
('47d06865-54b2-11f1-b76e-047c16fa71ed', 'estoque', 'dashboard', 1, 0, 0, 0, '2026-05-20 22:13:31', NULL),
('47d068a3-54b2-11f1-b76e-047c16fa71ed', 'estoque', 'caixa', 0, 0, 0, 0, '2026-05-20 22:13:31', NULL),
('47d0eb53-54b2-11f1-b76e-047c16fa71ed', 'estoque', 'estoque', 1, 1, 1, 1, '2026-05-20 22:13:31', NULL),
('47d0ec64-54b2-11f1-b76e-047c16fa71ed', 'estoque', 'financeiro', 0, 0, 0, 0, '2026-05-20 22:13:31', NULL),
('47d0ecc2-54b2-11f1-b76e-047c16fa71ed', 'estoque', 'relatorio', 0, 0, 0, 0, '2026-05-20 22:13:31', NULL),
('47d0ed10-54b2-11f1-b76e-047c16fa71ed', 'estoque', 'tarefas', 1, 1, 1, 0, '2026-05-20 22:13:31', NULL),
('47d0ed5e-54b2-11f1-b76e-047c16fa71ed', 'estoque', 'clientes', 0, 0, 0, 0, '2026-05-20 22:13:31', NULL),
('47d0edab-54b2-11f1-b76e-047c16fa71ed', 'estoque', 'equipe', 0, 0, 0, 0, '2026-05-20 22:13:31', NULL);

--
-- Acionadores `permissoes`
--
DELIMITER $$
CREATE TRIGGER `trg_permissoes_uuid` BEFORE INSERT ON `permissoes` FOR EACH ROW BEGIN IF NEW.id IS NULL OR NEW.id = '' THEN SET NEW.id = UUID(); END IF; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `produtos`
--

CREATE TABLE `produtos` (
  `id` varchar(36) NOT NULL,
  `nome` varchar(200) NOT NULL,
  `descricao` text DEFAULT NULL,
  `preco` decimal(12,2) NOT NULL,
  `quantidade_estoque` int(11) NOT NULL DEFAULT 0,
  `estoque_minimo` int(11) NOT NULL DEFAULT 5,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `criado_por` varchar(36) DEFAULT NULL
) ;

--
-- Acionadores `produtos`
--
DELIMITER $$
CREATE TRIGGER `trg_produtos_uuid` BEFORE INSERT ON `produtos` FOR EACH ROW BEGIN IF NEW.id IS NULL OR NEW.id = '' THEN SET NEW.id = UUID(); END IF; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `tarefas`
--

CREATE TABLE `tarefas` (
  `id` varchar(36) NOT NULL,
  `funil_id` varchar(36) NOT NULL,
  `responsavel_id` varchar(36) NOT NULL,
  `titulo` varchar(200) NOT NULL,
  `descricao` text DEFAULT NULL,
  `prioridade` enum('baixa','media','alta','urgente') NOT NULL DEFAULT 'media',
  `status` enum('aberta','em_andamento','concluida','cancelada') NOT NULL DEFAULT 'aberta',
  `data_vencimento` date NOT NULL,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `criado_por` varchar(36) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Tarefas do quadro kanban com responsável e prioridade obrigatórios.';

--
-- Acionadores `tarefas`
--
DELIMITER $$
CREATE TRIGGER `trg_tarefas_uuid` BEFORE INSERT ON `tarefas` FOR EACH ROW BEGIN IF NEW.id IS NULL OR NEW.id = '' THEN SET NEW.id = UUID(); END IF; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `transacoes_financeiras`
--

CREATE TABLE `transacoes_financeiras` (
  `id` varchar(36) NOT NULL,
  `descricao` varchar(300) NOT NULL,
  `tipo` enum('receita','despesa','saida') NOT NULL,
  `status` enum('pendente','concluido','saida') NOT NULL DEFAULT 'pendente',
  `valor` decimal(12,2) NOT NULL,
  `data_transacao` date NOT NULL,
  `venda_id` varchar(36) DEFAULT NULL,
  `cliente_id` varchar(36) DEFAULT NULL,
  `usuario_id` varchar(36) DEFAULT NULL,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Acionadores `transacoes_financeiras`
--
DELIMITER $$
CREATE TRIGGER `trg_transacoes_uuid` BEFORE INSERT ON `transacoes_financeiras` FOR EACH ROW BEGIN IF NEW.id IS NULL OR NEW.id = '' THEN SET NEW.id = UUID(); END IF; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `usuarios`
--

CREATE TABLE `usuarios` (
  `id` varchar(36) NOT NULL,
  `nome` varchar(150) NOT NULL,
  `email` varchar(255) NOT NULL,
  `senha_hash` text NOT NULL,
  `perfil` enum('administrador','caixa','estoque') NOT NULL DEFAULT 'caixa',
  `status` enum('ativo','inativo','convite_pendente') NOT NULL DEFAULT 'ativo',
  `token_convite` text DEFAULT NULL,
  `convite_expira` datetime DEFAULT NULL,
  `ultimo_login` datetime DEFAULT NULL,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Usuários do sistema com autenticação e perfil de acesso.';

--
-- Despejando dados para a tabela `usuarios`
--

INSERT INTO `usuarios` (`id`, `nome`, `email`, `senha_hash`, `perfil`, `status`, `token_convite`, `convite_expira`, `ultimo_login`, `criado_em`, `atualizado_em`) VALUES
('47c7c148-54b2-11f1-b76e-047c16fa71ed', 'Administrador', 'admin@eleganciapremium.com.br', '$2b$12$PLACEHOLDER_HASH_TROCAR_NO_PRIMEIRO_ACESSO', 'administrador', 'ativo', NULL, NULL, NULL, '2026-05-20 22:13:31', '2026-05-20 22:13:31');

--
-- Acionadores `usuarios`
--
DELIMITER $$
CREATE TRIGGER `trg_usuarios_uuid` BEFORE INSERT ON `usuarios` FOR EACH ROW BEGIN IF NEW.id IS NULL OR NEW.id = '' THEN SET NEW.id = UUID(); END IF; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `vendas`
--

CREATE TABLE `vendas` (
  `id` varchar(36) NOT NULL,
  `numero` int(11) NOT NULL,
  `cliente_id` varchar(36) DEFAULT NULL,
  `usuario_id` varchar(36) NOT NULL,
  `forma_pagamento` enum('debito','credito_loja','pix','cartao') NOT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  `percentual_imposto` decimal(5,2) NOT NULL DEFAULT 0.00,
  `valor_imposto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total` decimal(12,2) NOT NULL,
  `status` enum('aberta','concluida','cancelada') NOT NULL DEFAULT 'aberta',
  `observacoes` text DEFAULT NULL,
  `concluida_em` datetime DEFAULT NULL,
  `cancelada_em` datetime DEFAULT NULL,
  `criado_em` datetime NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Acionadores `vendas`
--
DELIMITER $$
CREATE TRIGGER `trg_concluir_venda` BEFORE UPDATE ON `vendas` FOR EACH ROW BEGIN
    IF NEW.status = 'concluida' AND OLD.status <> 'concluida' THEN
        SET NEW.concluida_em = NOW();
        
        -- Nota: No ambiente MySQL, lembre-se de que validações complexas de loop de estoque por item 
        -- e atualizações parciais de saldo devedor do cliente devem ser disparadas via Stored Procedures 
        -- na sua camada de aplicação para garantir o isolamento ACID correto.
        
        INSERT INTO transacoes_financeiras (id, descricao, tipo, status, valor, data_transacao, venda_id, cliente_id, usuario_id)
        VALUES (
            UUID(),
            CONCAT('Venda #', NEW.numero, IF(NEW.forma_pagamento = 'credito_loja', ' (crédito loja)', '')),
            'receita',
            IF(NEW.forma_pagamento = 'credito_loja', 'pendente', 'concluido'),
            NEW.total,
            CURRENT_DATE(),
            NEW.id,
            NEW.cliente_id,
            NEW.usuario_id
        );
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_vendas_uuid` BEFORE INSERT ON `vendas` FOR EACH ROW BEGIN IF NEW.id IS NULL OR NEW.id = '' THEN SET NEW.id = UUID(); END IF; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `vw_alertas_estoque_baixo`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `vw_alertas_estoque_baixo` (
`id` varchar(36)
,`nome` varchar(200)
,`preco` decimal(12,2)
,`quantidade_estoque` int(11)
,`estoque_minimo` int(11)
,`unidades_em_falta` bigint(12)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `vw_creditos_vencidos`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `vw_creditos_vencidos` (
`id` varchar(36)
,`nome` varchar(150)
,`email` varchar(255)
,`telefone` varchar(30)
,`limite_credito` decimal(12,2)
,`saldo_devedor` decimal(12,2)
,`credito_disponivel` decimal(12,2)
,`status` enum('ativo','inadimplente','bloqueado')
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `vw_historico_compras_cliente`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `vw_historico_compras_cliente` (
`venda_id` varchar(36)
,`numero_venda` int(11)
,`cliente_id` varchar(36)
,`nome_cliente` varchar(150)
,`forma_pagamento` enum('debito','credito_loja','pix','cartao')
,`subtotal` decimal(12,2)
,`valor_imposto` decimal(12,2)
,`total` decimal(12,2)
,`status` enum('aberta','concluida','cancelada')
,`concluida_em` datetime
,`criado_em` datetime
,`operador` varchar(150)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `vw_kpis_dashboard`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `vw_kpis_dashboard` (
`receita_total` decimal(34,2)
,`total_vendas` bigint(21)
,`produtos_ativos` bigint(21)
,`credito_pendente_total` decimal(34,2)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `vw_receita_mensal_ano`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `vw_receita_mensal_ano` (
`mes` int(2)
,`nome_mes` varchar(9)
,`receita` decimal(34,2)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `vw_saldo_loja`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `vw_saldo_loja` (
`total_receitas` decimal(34,2)
,`total_despesas` decimal(34,2)
,`saldo_total` decimal(35,2)
,`credito_pendente` decimal(34,2)
);

-- --------------------------------------------------------

--
-- Estrutura para view `vw_alertas_estoque_baixo`
--
DROP TABLE IF EXISTS `vw_alertas_estoque_baixo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_alertas_estoque_baixo`  AS SELECT `produtos`.`id` AS `id`, `produtos`.`nome` AS `nome`, `produtos`.`preco` AS `preco`, `produtos`.`quantidade_estoque` AS `quantidade_estoque`, `produtos`.`estoque_minimo` AS `estoque_minimo`, `produtos`.`estoque_minimo`- `produtos`.`quantidade_estoque` AS `unidades_em_falta` FROM `produtos` WHERE `produtos`.`ativo` = 1 AND `produtos`.`quantidade_estoque` <= `produtos`.`estoque_minimo` ORDER BY `produtos`.`estoque_minimo`- `produtos`.`quantidade_estoque` DESC, `produtos`.`nome` ASC ;

-- --------------------------------------------------------

--
-- Estrutura para view `vw_creditos_vencidos`
--
DROP TABLE IF EXISTS `vw_creditos_vencidos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_creditos_vencidos`  AS SELECT `clientes`.`id` AS `id`, `clientes`.`nome` AS `nome`, `clientes`.`email` AS `email`, `clientes`.`telefone` AS `telefone`, `clientes`.`limite_credito` AS `limite_credito`, `clientes`.`saldo_devedor` AS `saldo_devedor`, `clientes`.`credito_disponivel` AS `credito_disponivel`, `clientes`.`status` AS `status` FROM `clientes` WHERE `clientes`.`status` = 'inadimplente' OR `clientes`.`saldo_devedor` > 0 AND `clientes`.`status` = 'ativo' ORDER BY `clientes`.`saldo_devedor` DESC ;

-- --------------------------------------------------------

--
-- Estrutura para view `vw_historico_compras_cliente`
--
DROP TABLE IF EXISTS `vw_historico_compras_cliente`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_historico_compras_cliente`  AS SELECT `v`.`id` AS `venda_id`, `v`.`numero` AS `numero_venda`, `v`.`cliente_id` AS `cliente_id`, `c`.`nome` AS `nome_cliente`, `v`.`forma_pagamento` AS `forma_pagamento`, `v`.`subtotal` AS `subtotal`, `v`.`valor_imposto` AS `valor_imposto`, `v`.`total` AS `total`, `v`.`status` AS `status`, `v`.`concluida_em` AS `concluida_em`, `v`.`criado_em` AS `criado_em`, `u`.`nome` AS `operador` FROM ((`vendas` `v` join `clientes` `c` on(`c`.`id` = `v`.`cliente_id`)) join `usuarios` `u` on(`u`.`id` = `v`.`usuario_id`)) WHERE `v`.`status` = 'concluida' ORDER BY `v`.`concluida_em` DESC ;

-- --------------------------------------------------------

--
-- Estrutura para view `vw_kpis_dashboard`
--
DROP TABLE IF EXISTS `vw_kpis_dashboard`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_kpis_dashboard`  AS SELECT (select coalesce(sum(`transacoes_financeiras`.`valor`),0) from `transacoes_financeiras` where `transacoes_financeiras`.`tipo` = 'receita' and `transacoes_financeiras`.`status` = 'concluido') AS `receita_total`, (select count(0) from `vendas` where `vendas`.`status` = 'concluida') AS `total_vendas`, (select count(0) from `produtos` where `produtos`.`ativo` = 1 and `produtos`.`quantidade_estoque` > 0) AS `produtos_ativos`, (select coalesce(sum(`clientes`.`saldo_devedor`),0) from `clientes` where `clientes`.`status` in ('inadimplente','ativo') and `clientes`.`saldo_devedor` > 0) AS `credito_pendente_total` ;

-- --------------------------------------------------------

--
-- Estrutura para view `vw_receita_mensal_ano`
--
DROP TABLE IF EXISTS `vw_receita_mensal_ano`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_receita_mensal_ano`  AS SELECT `m`.`mes` AS `mes`, CASE `m`.`mes` WHEN 1 THEN 'Janeiro' WHEN 2 THEN 'Fevereiro' WHEN 3 THEN 'Março' WHEN 4 THEN 'Abril' WHEN 5 THEN 'Maio' WHEN 6 THEN 'Junho' WHEN 7 THEN 'Julho' WHEN 8 THEN 'Agosto' WHEN 9 THEN 'Setembro' WHEN 10 THEN 'Outubro' WHEN 11 THEN 'Novembro' WHEN 12 THEN 'Dezembro' END AS `nome_mes`, coalesce(sum(`tf`.`valor`),0) AS `receita` FROM ((select 1 AS `mes` union select 2 AS `2` union select 3 AS `3` union select 4 AS `4` union select 5 AS `5` union select 6 AS `6` union select 7 AS `7` union select 8 AS `8` union select 9 AS `9` union select 10 AS `10` union select 11 AS `11` union select 12 AS `12`) `m` left join `transacoes_financeiras` `tf` on(month(`tf`.`data_transacao`) = `m`.`mes` and year(`tf`.`data_transacao`) = year(curdate()) and `tf`.`tipo` = 'receita' and `tf`.`status` = 'concluido')) GROUP BY `m`.`mes` ORDER BY `m`.`mes` ASC ;

-- --------------------------------------------------------

--
-- Estrutura para view `vw_saldo_loja`
--
DROP TABLE IF EXISTS `vw_saldo_loja`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_saldo_loja`  AS SELECT coalesce(sum(case when `transacoes_financeiras`.`tipo` = 'receita' and `transacoes_financeiras`.`status` = 'concluido' then `transacoes_financeiras`.`valor` else 0 end),0) AS `total_receitas`, coalesce(sum(case when `transacoes_financeiras`.`tipo` in ('despesa','saida') then `transacoes_financeiras`.`valor` else 0 end),0) AS `total_despesas`, coalesce(sum(case when `transacoes_financeiras`.`tipo` = 'receita' and `transacoes_financeiras`.`status` = 'concluido' then `transacoes_financeiras`.`valor` else 0 end),0) - coalesce(sum(case when `transacoes_financeiras`.`tipo` in ('despesa','saida') then `transacoes_financeiras`.`valor` else 0 end),0) AS `saldo_total`, coalesce(sum(case when `transacoes_financeiras`.`tipo` = 'receita' and `transacoes_financeiras`.`status` = 'pendente' then `transacoes_financeiras`.`valor` else 0 end),0) AS `credito_pendente` FROM `transacoes_financeiras` ;

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `aliquota_imposto`
--
ALTER TABLE `aliquota_imposto`
  ADD PRIMARY KEY (`id`);

--
-- Índices de tabela `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `criado_por` (`criado_por`),
  ADD KEY `idx_clientes_nome` (`nome`);

--
-- Índices de tabela `funis_kanban`
--
ALTER TABLE `funis_kanban`
  ADD PRIMARY KEY (`id`),
  ADD KEY `criado_por` (`criado_por`);

--
-- Índices de tabela `itens_venda`
--
ALTER TABLE `itens_venda`
  ADD PRIMARY KEY (`id`),
  ADD KEY `venda_id` (`venda_id`),
  ADD KEY `produto_id` (`produto_id`);

--
-- Índices de tabela `log_auditoria`
--
ALTER TABLE `log_auditoria`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `idx_log_criado_em` (`criado_em`);

--
-- Índices de tabela `pagamentos_credito`
--
ALTER TABLE `pagamentos_credito`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cliente_id` (`cliente_id`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Índices de tabela `permissoes`
--
ALTER TABLE `permissoes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_permissao_perfil_modulo` (`perfil`,`modulo`),
  ADD KEY `atualizado_por` (`atualizado_por`);

--
-- Índices de tabela `produtos`
--
ALTER TABLE `produtos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `criado_por` (`criado_por`),
  ADD KEY `idx_produtos_nome` (`nome`);

--
-- Índices de tabela `tarefas`
--
ALTER TABLE `tarefas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `funil_id` (`funil_id`),
  ADD KEY `responsavel_id` (`responsavel_id`),
  ADD KEY `criado_por` (`criado_por`);

--
-- Índices de tabela `transacoes_financeiras`
--
ALTER TABLE `transacoes_financeiras`
  ADD PRIMARY KEY (`id`),
  ADD KEY `venda_id` (`venda_id`),
  ADD KEY `cliente_id` (`cliente_id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `idx_transacoes_data` (`data_transacao`);

--
-- Índices de tabela `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_usuarios_email` (`email`);

--
-- Índices de tabela `vendas`
--
ALTER TABLE `vendas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `numero` (`numero`),
  ADD KEY `cliente_id` (`cliente_id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `idx_vendas_criado_em` (`criado_em`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `vendas`
--
ALTER TABLE `vendas`
  MODIFY `numero` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `clientes`
--
ALTER TABLE `clientes`
  ADD CONSTRAINT `clientes_ibfk_1` FOREIGN KEY (`criado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Restrições para tabelas `funis_kanban`
--
ALTER TABLE `funis_kanban`
  ADD CONSTRAINT `funis_kanban_ibfk_1` FOREIGN KEY (`criado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Restrições para tabelas `itens_venda`
--
ALTER TABLE `itens_venda`
  ADD CONSTRAINT `itens_venda_ibfk_1` FOREIGN KEY (`venda_id`) REFERENCES `vendas` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `itens_venda_ibfk_2` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`);

--
-- Restrições para tabelas `log_auditoria`
--
ALTER TABLE `log_auditoria`
  ADD CONSTRAINT `log_auditoria_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Restrições para tabelas `pagamentos_credito`
--
ALTER TABLE `pagamentos_credito`
  ADD CONSTRAINT `pagamentos_credito_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`),
  ADD CONSTRAINT `pagamentos_credito_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`);

--
-- Restrições para tabelas `permissoes`
--
ALTER TABLE `permissoes`
  ADD CONSTRAINT `permissoes_ibfk_1` FOREIGN KEY (`atualizado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Restrições para tabelas `produtos`
--
ALTER TABLE `produtos`
  ADD CONSTRAINT `produtos_ibfk_1` FOREIGN KEY (`criado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Restrições para tabelas `tarefas`
--
ALTER TABLE `tarefas`
  ADD CONSTRAINT `tarefas_ibfk_1` FOREIGN KEY (`funil_id`) REFERENCES `funis_kanban` (`id`),
  ADD CONSTRAINT `tarefas_ibfk_2` FOREIGN KEY (`responsavel_id`) REFERENCES `usuarios` (`id`),
  ADD CONSTRAINT `tarefas_ibfk_3` FOREIGN KEY (`criado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Restrições para tabelas `transacoes_financeiras`
--
ALTER TABLE `transacoes_financeiras`
  ADD CONSTRAINT `transacoes_financeiras_ibfk_1` FOREIGN KEY (`venda_id`) REFERENCES `vendas` (`id`),
  ADD CONSTRAINT `transacoes_financeiras_ibfk_2` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `transacoes_financeiras_ibfk_3` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Restrições para tabelas `vendas`
--
ALTER TABLE `vendas`
  ADD CONSTRAINT `vendas_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`),
  ADD CONSTRAINT `vendas_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
