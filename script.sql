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