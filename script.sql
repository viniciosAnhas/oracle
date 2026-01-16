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