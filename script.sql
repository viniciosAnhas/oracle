-- Verifica se o listener (serviço que aceita conexões) está ativo e quais serviços estão registrados.
lsnrctl status

-- Inicia o listener do Oracle, permitindo que novas conexões sejam aceitas.
lsnrctl start

-- Mostra o nome e o estado (ex: OPEN, MOUNTED) da instância do banco de dados atual.
SELECT instance_name, status FROM v$instance;

-- Desliga o banco de dados imediatamente, desconectando sessões, revertendo transações pendentes e fechando os arquivos de forma limpa.
shutdown immediate

-- Inicia a instância Oracle, monta o banco de dados e o abre para uso normal.
startup

-- Retorna informações do CDB (Container Database) raiz. O con_id = 1 sempre se refere ao container raiz do CDB, que é o banco de dados "mestre" que contém todos os PDBs.
SELECT con_id, dbid, name FROM v$containers WHERE con_id = 1;

-- Exibe o nome do container (CDB ou PDB) no qual a sessão atual está conectada.
show con_name;

-- Lista os nomes de todos os PDBs (pluggable databases) existentes dentro do CDB.
SELECT name FROM v$pdbs;

-- Cria um usuário comum (common user) visível em todos os containers (CDB e todos os PDBs).
CREATE USER C##DEVOPS identified by "dev123" container=all;

-- Concede o privilégio de conexão ao usuário C##DEVOPS em todos os containers.
GRANT connect to C##DEVOPS container=all;

-- Concede permissão para criar tabelas apenas no container atual (CDB ou PDB) onde o comando foi executado.
GRANT CREATE TABLE to C##DEVOPS container=current;

-- Exibe o nome do usuário com o qual a sessão atual está conectada ao banco de dados.
show user;

-- Conecta (ou tenta conectar) ao banco de dados usando o usuário C##DEVOPS e a senha dev123 na instância/container atual.
conn C##DEVOPS/dev123;

-- Remove a permissão de criar tabelas do usuário C##DEVOPS apenas no container atual (CDB ou PDB onde o comando é executado).
REVOKE CREATE TABLE FROM C##DEVOPS container=current;

-- Muda o contexto da sessão atual para o PDB chamado "ORCLPDB", permitindo trabalhar dentro desse banco de dados plugável específico.
ALTER SESSION SET container=ORCLPDB;

-- Mostra o modo de abertura do banco de dados.
-- READ WRITE: Banco aberto para leitura e escrita.
-- READ ONLY: Banco aberto apenas para leitura.
-- MOUNTED: Banco montado, mas não aberto (acesso restrito a DBA).
-- READ WRITE WITH APPLY: Banco físico standby aplicando logs (Data Guard).
-- READ ONLY WITH APPLY: Banco lógico standby aplicando logs.
SELECT open_mode FROM v$database;

-- Mostra o estado atual da instância Oracle.
-- OPEN: Instância iniciada e banco de dados aberto normalmente.
-- MOUNTED: Instância montou o banco, mas ele ainda não está aberto para usuários.
-- STARTED: Instância iniciada, mas banco ainda não montado (após STARTUP NOMOUNT).
-- OPEN MIGRATE: Em processo de upgrade/downgrade do banco.
SELECT status FROM v$instance;

-- Abre o PDB chamado "ORCLPDB", deixando-o disponível para conexões e operações normais.
ALTER pluggable DATABASE ORCLPDB open;

--  Define o diretório padrão para criação de arquivos de dados do banco (ex: novos PDBs/tablespaces) tanto em memória quanto no arquivo de parâmetros.
ALTER SYSTEM SET db_create_file_dest='C:\app\pdbs' scope=both;

-- Lista todos os parâmetros de inicialização do Oracle que contêm a palavra "CREATE" (como db_create_file_dest, db_create_online_log_dest_N, etc.) e seus valores atuais.
show parameter CREATE;

-- Cria um novo PDB chamado "pdb1" com um usuário administrador "admin" (senha: benvindo1) e limita o armazenamento máximo a 2 GB.
CREATE pluggable DATABASE pdb1 ADMIN user admin identified BY benvindo1 storage(maxsize 2G);

-- Muda a sessão para o container raiz (CDB).
ALTER SESSION SET container=CDB$ROOT;

-- Fecha o PDB pdb1 imediatamente, desconectando sessões ativas.
ALTER pluggable DATABASE pdb1 CLOSE IMMEDIATE;

-- Reabre o PDB pdb1 apenas em modo de leitura.
ALTER pluggable DATABASE pdb1 OPEN READ ONLY;

-- Lista todos os PDBs com seus nomes e modos de abertura (ex: READ WRITE, READ ONLY, MOUNTED).
SELECT name, open_mode FROM v$pdbs;

-- Cria um novo PDB chamado "pdb2" clonando a estrutura e os dados do PDB "pdb1" (origem). O pdb1 deve estar aberto em modo read-only ou aberto normalmente para isso.
CREATE pluggable DATABASE pdb2 FROM pdb1;

-- Remove permanentemente o PDB "pdb2" e exclui seus arquivos de dados físicos do sistema operacional.
DROP pluggable DATABASE pdb2 including datafiles;

-- Cria um usuário chamado "TI" com a senha "senhaTI" no container atual.
CREATE user TI identified BY senhaTI;

-- Concede os papéis (roles) CONNECT (permissão para conectar) e RESOURCE (permite criar objetos como tabelas, índices, procedures) ao usuário TI.
GRANT CONNECT, RESOURCE TO TI;

-- Confirma (torna permanentes) todas as alterações feitas na transação atual.
COMMIT;

-- Consulta o usuário 'TI' na visão DBA_USERS, mostrando seu nome e status da conta
SELECT username, account_status FROM dba_users WHERE username = 'TI';

-- Concede todos os privilégios do sistema (como CREATE TABLE, CREATE VIEW, DROP ANY TABLE, etc.) ao usuário TI, tornando-o poderoso equivalente a um DBA. Cuidado: Isso dá controle total sobre o container atual.
GRANT all privileges TO TI;

-- Concede ao usuário TI a permissão de ler (SELECT) qualquer tabela de qualquer esquema (exceto SYS) no container atual (CDB ou PDB).
GRANT SELECT any TABLE TO 'TI';