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

-- Concede permissão para o usuário ANHAS realizar consultas (SELECT) na tabela CLIENTE que pertence ao usuário (esquema) TI.
GRANT SELECT ON TI.CLIENTE TO ANHAS;

-- Apresenta se o autocommit esta ativo
show autocommit;

-- Ativa o commit automático no SQL*Plus/SQLcl. Cada comando DML (INSERT, UPDATE, DELETE, MERGE) é confirmado permanentemente no banco imediatamente após sua execução bem-sucedida.
SET autocommit ON;

-- Lista todas as roles (papéis/ permissões agrupadas) existentes no banco de dados, mostrando nome, se é role padrão do Oracle, etc.
SELECT * FROM dba_roles;

-- Cria uma nova role chamada "devops" no banco de dados. Uma role é um conjunto de privilégios que pode ser concedido a usuários.
CREATE ROLE devops;

-- Lista todas as roles personalizadas (não mantidas pelo Oracle) criadas por usuários ou DBAs.
SELECT * FROM dba_roles WHERE oracle_maintained = 'N';

-- Concede ao usuário TI o papel SYSDBA, que é o mais alto privilégio administrativo do Oracle. Permite ligar/desligar o banco, criar/alterar estruturas críticas e acessar qualquer dado.
GRANT sysdba TO TI;

-- Verifica se o usuário TI está listado no arquivo de senhas externo (password file) e mostra quais privilégios de administração (como SYSDBA, SYSOPER) ele possui.
SELECT * FROM v$pwfile_users WHERE username = 'TI';

-- Remove o papel de SYSDBA do usuario TI.
REVOKE sysdba FROM TI;

-- Lista todos os privilégios de sistema concedidos a usuários e roles no banco de dados, mostrando quem recebeu, qual privilégio e se pode repassar (ADMIN_OPTION).
SELECT * FROM dba_sys_privs;

-- Mostra todos os usuários com privilégios administrativos especiais (SYSDBA, SYSOPER, SYSASM, etc.) registrados no arquivo de senhas externo do Oracle, permitindo conexão quando o banco está fechado.
SELECT * FROM v$pwfile_users;

-- Lista todos os privilégios de objeto (tabela, view, etc.) concedidos a usuários e roles, mostrando dono do objeto, nome do objeto, tipo, quem recebeu o privilégio e qual permissão (SELECT, INSERT, UPDATE, DELETE, etc.).
SELECT * FROM dba_tab_privs;

--  Lista todas as roles concedidas a usuários e a outras roles, mostrando quem recebeu, qual role foi concedida e se pode repassar (ADMIN_OPTION).
SELECT * FROM dba_role_privs;

-- Lista todas as roles e os usuários que as possuem, relacionando o nome da role (dba_roles.role) com o nome do usuário/role que a recebeu (dba_role_privs.grantee), ordenado por role e depois por usuário.
SELECT
    r.role AS role_name,
    rp.grantee AS user_name
    FROM dba_roles r
        JOIN dba_role_privs rp
        ON
        r.role = rp.granted_role
        ORDER BY role_name, user_name;

-- Lista todos os privilégios de sistema concedidos diretamente ao usuário SYS (o superusuário do Oracle), ordenados alfabeticamente pelo nome do privilégio.
SELECT
    grantee AS user_name,
    privilege
    FROM dba_sys_privs
        WHERE grantee = 'SYS' ORDER BY privilege;

-- Define uma cota de 10 MB de espaço em disco no tablespace USERS para o usuário livraria, limitando quanto ele pode armazenar ali.
ALTER USER livraria QUOTA 10M ON USERS;

-- Define cota ilimitada de espaço no tablespace USERS para o usuário livraria, permitindo que ele use todo o espaço disponível nesse tablespace sem restrições.
ALTER USER livraria QUOTA UNLIMITED ON USERS;