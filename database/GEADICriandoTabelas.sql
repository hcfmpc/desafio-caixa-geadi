-- Conectar ao servidor SQL Server
USE master;
GO

-- Criar o banco de dados DBGEADI
CREATE DATABASE DBGEADI;
GO

USE [DBGEADI]
GO
/****** Object:  Table [dbo].[aditb001_controle_arquivos]    Script Date: 17/09/2024 17:34:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[aditb001_controle_arquivos](
	[nu_id] [bigint] IDENTITY(1,1) NOT NULL,
	[no_arquivo] [varchar](max) NOT NULL,
	[no_local] [varchar](max) NOT NULL,
	[qt_bytes] [bigint] NOT NULL,
	[dt_criacao] [datetime2](7) NOT NULL,
	[dt_modificacao] [datetime2](7) NOT NULL,
	[dt_log] [datetime2](7) NOT NULL,
	[nu_lote_id] [bigint] NOT NULL,
 CONSTRAINT [PK_aditb001_controle_arquivos] PRIMARY KEY CLUSTERED 
(
	[nu_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


/****** Object:  Table [dbo].[aditb002_lote_arquivos]    Script Date: 17/09/2024 17:34:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[aditb002_lote_arquivos](
	[nu_id] [bigint] IDENTITY(1,1) NOT NULL,
	[dt_criacao] [datetime2](7) NOT NULL,
	[qt_arquivos] [int] NOT NULL,
 CONSTRAINT [PK_aditb002_lote_arquivos] PRIMARY KEY CLUSTERED 
(
	[nu_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[aditb001_controle_arquivos]  WITH CHECK ADD  CONSTRAINT [FK_aditb001_controle_arquivos_aditb002_lote_arquivos_nu_lote_id] FOREIGN KEY([nu_lote_id])
REFERENCES [dbo].[aditb002_lote_arquivos] ([nu_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[aditb001_controle_arquivos] CHECK CONSTRAINT [FK_aditb001_controle_arquivos_aditb002_lote_arquivos_nu_lote_id]
GO

/****** Object:  Table [dbo].[aditb002_lote_arquivos]    Script Date: 17/09/2024 17:34:20 ******/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[aditb003_base_mensal_ETL](
[nu_id] [bigint] IDENTITY(1,1) NOT NULL,
[ctr] varchar(max),
[co_ope] varchar(max),
[cpf_cnpj] varchar(max),
[ic_caixa] varchar(max),
[tp_pessoa] varchar(max),
[co_sis] varchar(max),
[unidade] varchar(max),
[co_ag_relac] varchar(max),
[dt_conce] varchar(max),
[DD_VENCIMENTO_CONTRATO] varchar(max),
[vlr_conce] varchar(max),
[posicao] varchar(max),
[da_ini] varchar(max),
[dt_mov] varchar(max),
[da_atual] varchar(max),
[nu_tabela_atual] varchar(max),
[base_calculo] varchar(max),
[rat_prov] varchar(max),
[rat_hh] varchar(max),
[co_mod] varchar(max),
[cart] varchar(max),
[co_cart] varchar(max),
[co_seg] varchar(max),
[no_seg] varchar(max),
[co_segger] varchar(max),
[co_segger_gp] varchar(max),
[co_segad] varchar(max),
[rat_h5] varchar(max),
[rat_h6] varchar(max),
[ic_atacado] varchar(max),
[ic_reg] varchar(max),
[ic_rj] varchar(max),
[ic_honrado] varchar(max),
[am_honrado] varchar(max)
CONSTRAINT [PK_aditb003_base_mensal] PRIMARY KEY CLUSTERED 
(
	[nu_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

/****** Object:  Table  ******/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[aditb004_base_mensal_STAGING] (
    nu_id BIGINT IDENTITY(1,1) NOT NULL,
    ctr NVARCHAR(100) NULL,
    co_ope INT NULL,
    cpf_cnpj NVARCHAR(100) NULL,
    ic_caixa BIT NULL,
    tp_pessoa INT NULL,
    co_sis INT NULL,
    unidade INT NULL,
    co_ag_relac INT NULL,
    dt_conce DATE NULL,
    DD_VENCIMENTO_CONTRATO INT NULL,
    vlr_conce DECIMAL(18, 2) NULL,
    posicao INT NULL,
    da_ini INT NULL,
    dt_mov DATE NULL,
    da_atual INT NULL,
    nu_tabela_atual INT NULL,
    base_calculo DECIMAL(18, 2) NULL,
    rat_prov NVARCHAR(100) NULL,
    rat_hh NVARCHAR(100) NULL,
    co_mod NVARCHAR(100) NULL,
    cart NVARCHAR(100) NULL,
    co_cart NVARCHAR(100) NULL,
    co_seg NVARCHAR(100) NULL,
    no_seg NVARCHAR(100) NULL,
    co_segger NVARCHAR(100) NULL,
    co_segger_gp NVARCHAR(100) NULL,
    co_segad NVARCHAR(100) NULL,
    rat_h5 NVARCHAR(100) NULL,
    rat_h6 NVARCHAR(100) NULL,
    ic_atacado BIT NULL,
    ic_reg BIT NULL,
    ic_rj BIT NULL,
    ic_honrado BIT NULL,
    am_honrado NVARCHAR(100) NULL,
 CONSTRAINT [PK_aditb004_base_mensal_STAGING] PRIMARY KEY CLUSTERED 
(
	[nu_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table  ******/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[aditb005_base_mensal] (
    nu_id BIGINT IDENTITY(1,1) NOT NULL,
    ctr NVARCHAR(100) NULL,
    co_ope INT NULL,
    cpf_cnpj NVARCHAR(100) NULL,
    ic_caixa BIT NULL,
    tp_pessoa INT NULL,
    co_sis INT NULL,
    unidade INT NULL,
    co_ag_relac INT NULL,
    dt_conce DATE NULL,
    DD_VENCIMENTO_CONTRATO INT NULL,
    vlr_conce DECIMAL(18, 2) NULL,
    posicao INT NULL,
    da_ini INT NULL,
    dt_mov DATE NULL,
    da_atual INT NULL,
    nu_tabela_atual INT NULL,
    base_calculo DECIMAL(18, 2) NULL,
    rat_prov NVARCHAR(100) NULL,
    rat_hh NVARCHAR(100) NULL,
    co_mod NVARCHAR(100) NULL,
    cart NVARCHAR(100) NULL,
    co_cart NVARCHAR(100) NULL,
    co_seg NVARCHAR(100) NULL,
    no_seg NVARCHAR(100) NULL,
    co_segger NVARCHAR(100) NULL,
    co_segger_gp NVARCHAR(100) NULL,
    co_segad NVARCHAR(100) NULL,
    rat_h5 NVARCHAR(100) NULL,
    rat_h6 NVARCHAR(100) NULL,
    ic_atacado BIT NULL,
    ic_reg BIT NULL,
    ic_rj BIT NULL,
    ic_honrado BIT NULL,
    am_honrado NVARCHAR(100) NULL,
 CONSTRAINT [PK_aditb005_base_mensal] PRIMARY KEY CLUSTERED 
(
	[nu_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table  ******/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[aditb006_etapa_atualizacao_base_arquivos](
	[nu_id] [bigint] IDENTITY(1,1) NOT NULL,
	[no_etapa] [varchar](200) NOT NULL,
 CONSTRAINT [PK_aditb006_etapa_atualizacao_base_arquivos] PRIMARY KEY CLUSTERED 
(
	[nu_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table  ******/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[aditb007_log_atualizacao_base_arquivos](
	[nu_id] [bigint] IDENTITY(1,1) NOT NULL,
    [dt_update] [datetime2](7) NOT NULL,
    [nu_etapa_id] [bigint] NOT NULL,
    [ic_sucesso] [bit] NOT NULL,
    [er_message] [nvarchar](max) NULL,
    [er_severity] [int] NULL,
    [er_state] [int] NULL,
    [er_line] [int] NULL,
    [er_procedure] [nvarchar](max) NULL,
    CONSTRAINT [PK_aditb007_log_atualizacao_base_arquivos] PRIMARY KEY CLUSTERED 
(
	[nu_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[aditb007_log_atualizacao_base_arquivos]  WITH CHECK ADD  CONSTRAINT [FK_aditb007_log_atualizacao_base_arquivos_aditb006_etapa_atualizacao_base_arquivos] FOREIGN KEY([nu_etapa_id])
REFERENCES [dbo].[aditb006_etapa_atualizacao_base_arquivos] ([nu_id])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[aditb007_log_atualizacao_base_arquivos] CHECK CONSTRAINT [FK_aditb007_log_atualizacao_base_arquivos_aditb006_etapa_atualizacao_base_arquivos]
GO


--INSERIR DADOS ETAPAS
INSERT INTO aditb006_etapa_atualizacao_base_arquivos VALUES ('Update ETL base mensal')
INSERT INTO aditb006_etapa_atualizacao_base_arquivos VALUES ('Update STAGING base mensal')
INSERT INTO aditb006_etapa_atualizacao_base_arquivos VALUES ('Update PRD base mensal')