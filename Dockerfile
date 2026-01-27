FROM container-registry.oracle.com/database/free:latest-lite

ENV ORACLE_PWD="admin" \
    ORACLE_HOME=/opt/oracle/product/26ai/dbhomeFree \
    PATH=/opt/oracle/product/26ai/dbhomeFree/bin:$PATH \
    ORACLE_SID=FREE

# construir imagem
# docker build -t db-oracle .

    # rodar container
# docker run -d -p 1521:1521 --name oracle db-oracle

    # entrando no sqlplus
#sqlplus / as sysdba

    # entrando no usuário oracle
# su - oracle
    # password
# oracle