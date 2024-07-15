create or replace package PACK_REGISTRO_JLM is

PROCEDURE CADASTRA_CLIENTE( IO_NR_CPF       IN OUT CLIENTE_JLM.NR_CPF%TYPE,
                                I_NM_CLIENTE    IN CLIENTE_JLM.NM_CLIENTE%TYPE,
                                I_DT_NASCIMENTO IN CLIENTE_JLM.DT_NASCIMENTO%TYPE,
                                O_MENSAGEM      OUT VARCHAR2);
                              
------------------------------------------------------------------------------------------------------------------  
 
  PROCEDURE CADASTRA_PRODUTO (IO_CD_PRODUTO  IN OUT PRODUTO_JLM.CD_PRODUTO%TYPE,
                                  I_DS_PRODUTO   IN     PRODUTO_JLM.DS_PRODUTO%TYPE,
                                  I_VL_UNITARIO  IN     PRODUTO_JLM.VL_UNITARIO%TYPE,
                                  O_MENSAGEM        OUT VARCHAR2);
                              
 ------------------------------------------------------------------------------------------------------------------
  
  PROCEDURE CADASTRA_VENDA (IO_CD_VENDA     IN OUT VENDA_JLM.CD_VENDA%TYPE,
                                I_VL_TOTAL      IN     VENDA_JLM.VL_TOTAL%TYPE,
                                I_QT_TOTAL      IN     VENDA_JLM.QT_TOTAL%TYPE,
                                I_NR_CPFCLIENTE IN     VENDA_JLM.NR_CPFCLIENTE%TYPE,
                                IO_DT_VENDA     IN OUT VENDA_JLM.DT_VENDA%TYPE,
                                O_MENSAGEM         OUT VARCHAR2);
                            
  ------------------------------------------------------------------------------------------------------------------
  
  PROCEDURE CADASTRA_ITEMVENDA (I_CD_VENDA      IN ITEMVENDA_JLM.CD_VENDA%TYPE,
                                I_CD_PRODUTO    IN ITEMVENDA_JLM.CD_PRODUTO%TYPE,
                                I_QT_ADQUIRIDA  IN ITEMVENDA_JLM.QT_ADQUIRIDA%TYPE,
                                O_MENSAGEM      OUT VARCHAR2);
                                
  ------------------------------------------------------------------------------------------------------------------
  
  PROCEDURE EXCLUI_VENDA ( I_CD_VENDA   IN VENDA_JLM.CD_VENDA%TYPE,
                           O_MENSAGEM   OUT VARCHAR2);
                           
  ------------------------------------------------------------------------------------------------------------------
  
  PROCEDURE EXCLUI_ITEMVENDA ( I_CD_VENDA   IN ITEMVENDA_JLM.CD_VENDA%TYPE,
                               I_CD_PRODUTO IN ITEMVENDA_JLM.CD_PRODUTO%TYPE,
                               O_MENSAGEM   OUT VARCHAR2);
                               
  ------------------------------------------------------------------------------------------------------------------
  
  PROCEDURE EXCLUI_CLIENTE ( I_NR_CPF   IN CLIENTE_JLM.NR_CPF%TYPE,
                             O_MENSAGEM   OUT VARCHAR2);
                             
  ------------------------------------------------------------------------------------------------------------------
                            
    PROCEDURE EXCLUI_PRODUTO ( I_CD_PRODUTO   IN PRODUTO_JLM.CD_PRODUTO%TYPE,
                             O_MENSAGEM     OUT VARCHAR2);

end PACK_REGISTRO_JLM;
/
create or replace package body PACK_REGISTRO_JLM is

  PROCEDURE CADASTRA_CLIENTE( IO_NR_CPF       IN OUT CLIENTE_JLM.NR_CPF%TYPE,
                              I_NM_CLIENTE    IN CLIENTE_JLM.NM_CLIENTE%TYPE,
                              I_DT_NASCIMENTO IN CLIENTE_JLM.DT_NASCIMENTO%TYPE,
                              O_MENSAGEM      OUT VARCHAR2) IS
  E_GERAL EXCEPTION;
  
  BEGIN
    
   -- TRATAMENTO SE O NR_CPF É NULO
    IF IO_NR_CPF IS NULL THEN
      O_MENSAGEM := 'CPF inválido';
      RAISE E_GERAL;
    END IF;
    
    -- TRATAMENTO DO CPF, CHECANDO SE CONTEM 11 CARACTERES
    IF LENGTH(IO_NR_CPF) <> 11 THEN
      O_MENSAGEM := 'CPF inválido';
      RAISE E_GERAL;
    END IF;
    
    -- TRATAMENTO SE O NM É NULO
    IF I_NM_CLIENTE IS NULL THEN
      O_MENSAGEM := 'O nome do cliente precisa ser informado';
      RAISE E_GERAL;
    END IF;
    
    -- TRATAMENTO SE A DT É NULA
    IF I_DT_NASCIMENTO IS NULL THEN
      O_MENSAGEM := 'A data de nascimento do cliente precisa ser informada';
      RAISE E_GERAL;
    END IF;  
    
   
    -- INSERÇÃO E ATUALIZAÇÃO
    BEGIN
      INSERT INTO CLIENTE_JLM(
        NR_CPF,
        NM_CLIENTE,
        DT_NASCIMENTO)
      VALUES(
        IO_NR_CPF,
        I_NM_CLIENTE,
        I_DT_NASCIMENTO);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
          UPDATE CLIENTE_JLM
            SET NM_CLIENTE    = I_NM_CLIENTE,
                DT_NASCIMENTO = I_DT_NASCIMENTO
          WHERE NR_CPF = IO_NR_CPF;
        EXCEPTION
          WHEN OTHERS THEN
            O_MENSAGEM := 'ERRO AO ATUALIZAR O CLIENTE ('||IO_NR_CPF||'): '||SQLERRM;
            RAISE E_GERAL;
        
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'ERRO AO INSERIR O CLIENTE ('||IO_NR_CPF||'): '||SQLERRM;
    END;
    COMMIT;
    
  EXCEPTION
    WHEN E_GERAL THEN 
      ROLLBACK;
      O_MENSAGEM := '[CADASTRA_CLIENTE] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[CADASTRA_CLIENTE] ERRO NO PROCEDIMENTO QUE CADASTRA CLIENTES: '||SQLERRM;
  END;   
  
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------  
 
  PROCEDURE CADASTRA_PRODUTO (IO_CD_PRODUTO  IN OUT PRODUTO_JLM.CD_PRODUTO%TYPE,
                              I_DS_PRODUTO   IN     PRODUTO_JLM.DS_PRODUTO%TYPE,
                              I_VL_UNITARIO  IN     PRODUTO_JLM.VL_UNITARIO%TYPE,
                              O_MENSAGEM        OUT VARCHAR2) IS

  E_GERAL EXCEPTION;
  
  
  BEGIN
    -- TRATAMENTO SE O DS_PRODUTO É NULO
    IF I_DS_PRODUTO IS NULL THEN
      O_MENSAGEM := 'A descrição do produto precisa ser informada';
      RAISE E_GERAL;
    END IF;
    
    -- TRATAMENTO SE O VL_UNITARIO É NULO
    IF I_VL_UNITARIO IS NULL THEN
      O_MENSAGEM := 'O valor unitário precisa ser informado';
      RAISE E_GERAL;
    END IF;
    
    -- TRATAMENTO SE O CD_PRODUTO É NULO
    IF IO_CD_PRODUTO IS NULL THEN
      BEGIN
        SELECT MAX(PRODUTO_JLM.CD_PRODUTO)
        INTO IO_CD_PRODUTO
        FROM PRODUTO_JLM;
      EXCEPTION
        WHEN OTHERS THEN
          IO_CD_PRODUTO := 0;
      END;
      
      IO_CD_PRODUTO := NVL(IO_CD_PRODUTO,0) +1;
    END IF;
    

    
    -- INSERÇÃO E ATUALIZAÇÃO
    BEGIN
      INSERT INTO PRODUTO_JLM(
          CD_PRODUTO,
          DS_PRODUTO,
          VL_UNITARIO)
        VALUES(
          IO_CD_PRODUTO,
          I_DS_PRODUTO,
          I_VL_UNITARIO);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
          UPDATE PRODUTO_JLM
            SET DS_PRODUTO  = I_DS_PRODUTO,
                VL_UNITARIO = I_VL_UNITARIO
          WHERE CD_PRODUTO  = IO_CD_PRODUTO;
        EXCEPTION
          WHEN OTHERS THEN
            O_MENSAGEM := 'ERRO AO ATUALIZAR O PRODUTO ('||IO_CD_PRODUTO||'): '||SQLERRM;
            RAISE E_GERAL;
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'ERRO AO INSERIR O PRODUTO ('||IO_CD_PRODUTO||'): '||SQLERRM;
    END;
    COMMIT;
    
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[CADASTRA_PRODUTO] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[CADASTRA_PRODUTO] ERRO NO PROCEDIMENTO QUE CADASTRA PRODUTOS: '||SQLERRM;
  END;
  
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  
  PROCEDURE CADASTRA_VENDA (IO_CD_VENDA     IN OUT VENDA_JLM.CD_VENDA%TYPE,
                            I_VL_TOTAL      IN     VENDA_JLM.VL_TOTAL%TYPE,
                            I_QT_TOTAL      IN     VENDA_JLM.QT_TOTAL%TYPE,
                            I_NR_CPFCLIENTE IN     VENDA_JLM.NR_CPFCLIENTE%TYPE,
                            IO_DT_VENDA     IN OUT VENDA_JLM.DT_VENDA%TYPE,
                            O_MENSAGEM         OUT VARCHAR2) IS
                            
  E_GERAL EXCEPTION;
  V_COUNT NUMBER;   -- VAR PARA CHECAR SE O O NR_CPFCLIENTE ESTA CADASTRADO

  BEGIN
    
    -- TRATAMENTO DO VL TOTAL, CHECANDO SE É NULO
    IF I_VL_TOTAL IS NULL THEN
      O_MENSAGEM := 'O valor total precisa ser informado';
      RAISE E_GERAL;
    END IF;
    
    -- TRATAMENTO DA QUANTIDADE, CHECANDO SE É NULA              
    IF I_QT_TOTAL IS NULL THEN
      O_MENSAGEM := 'A quantidade total de itens precisa ser informada';
      RAISE E_GERAL;
    END IF;
    
    -- TRATAMENTO DO CPF, CHECANDO SE É NULO
    IF I_NR_CPFCLIENTE IS NULL THEN
      O_MENSAGEM := 'O número do CPF do cliente precisa ser informado';
      RAISE E_GERAL;
    END IF;
    
    -- TRATAMENTO DO CPF, CHECANDO SE CONTEM 11 CARACTERES
    IF LENGTH(I_NR_CPFCLIENTE) <> 11 THEN
      O_MENSAGEM := 'Precisa ser informado um número correto de CPF';
      RAISE E_GERAL;
    END IF;
    
    -- TRATAMENTO DO CPF, CHECANDO SE ESTA PRESENTE NA TABELA CLIENTE
    BEGIN                           
      SELECT COUNT (*)                    
      INTO V_COUNT
      FROM CLIENTE_JLM
      WHERE CLIENTE_JLM.NR_CPF = I_NR_CPFCLIENTE;
    EXCEPTION
      WHEN OTHERS THEN
        V_COUNT := 0;
    END;
    IF NVL(V_COUNT, 0) = 0 THEN
      O_MENSAGEM := 'O CLIENTE '||I_NR_CPFCLIENTE||' NAO ESTA CADASTRADO';
      RAISE E_GERAL;
    END IF;
    
    
    -- TRATAMENTO DO CD_VENDA, CASO NULL E SEQUENCIAL
    IF IO_CD_VENDA IS NULL THEN
      BEGIN
        SELECT MAX(VENDA_JLM.CD_VENDA)
        INTO       IO_CD_VENDA
        FROM       VENDA_JLM;
      EXCEPTION
        WHEN OTHERS THEN
          IO_CD_VENDA := 0;
      END;
      
      IO_CD_VENDA := NVL(IO_CD_VENDA, 0) +1;
    END IF;
    
    
    
    -- INSERÇÃO E ATUALIZAÇÃO
    BEGIN
      INSERT INTO VENDA_JLM(
             CD_VENDA,
             VL_TOTAL,
             QT_TOTAL,
             NR_CPFCLIENTE,
             DT_VENDA)
           VALUES(
             IO_CD_VENDA,
             I_VL_TOTAL,
             I_QT_TOTAL,
             I_NR_CPFCLIENTE,
             IO_DT_VENDA);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
          UPDATE VENDA_JLM
          SET    VL_TOTAL       = I_VL_TOTAL,
                 QT_TOTAL       = I_QT_TOTAL,
                 NR_CPFCLIENTE  = I_NR_CPFCLIENTE,
                 DT_VENDA       = IO_DT_VENDA
           WHERE CD_VENDA       = IO_CD_VENDA;
        EXCEPTION
          WHEN OTHERS THEN
            O_MENSAGEM := 'ERRO AO ATUALIZAR A VENDA ('||IO_CD_VENDA||'): '||SQLERRM;
            RAISE E_GERAL;
        END;
    END;
    COMMIT;
    
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[CADASTRA_VENDA] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[CADASTRA_VENDA] ERRO NO PROCEDIMENTO QUE CADASTRA A VENDA '||SQLERRM;
  END;
  
  
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  
  PROCEDURE CADASTRA_ITEMVENDA (I_CD_VENDA      IN ITEMVENDA_JLM.CD_VENDA%TYPE,
                                I_CD_PRODUTO    IN ITEMVENDA_JLM.CD_PRODUTO%TYPE,
                                I_QT_ADQUIRIDA  IN ITEMVENDA_JLM.QT_ADQUIRIDA%TYPE,
                                O_MENSAGEM      OUT VARCHAR2) IS
                                
  E_GERAL EXCEPTION;
  V_VL_PRODUTO PRODUTO_JLM.VL_UNITARIO%TYPE; -- VAR PARA ARMAZENAR O VL UNITARIO COM BASE NO CD_PRODUTO
  
  BEGIN

  
    -- TRATAMENTO CHECANDO SE CD_VENDA É NULO
    IF I_CD_VENDA IS NULL THEN
      O_MENSAGEM := 'O código da venda precisa ser informado';
      RAISE E_GERAL;
    END IF;
    
    -- TRATAMENTO CHECANDO SE CD_PRODUTO É NULO
    IF I_CD_PRODUTO IS NULL THEN
      O_MENSAGEM := 'O código do produto precisa ser informado';
      RAISE E_GERAL;
    END IF;
    
    -- TRATAMENTO CHECANDO SE QT_ADQUIRIDA É NULO
    IF I_QT_ADQUIRIDA IS NULL THEN
      O_MENSAGEM := 'A quantidade de produtos adquirida precisa ser informada';
      RAISE E_GERAL;
    END IF;
    
    -- TRATAMENTO DO VALOR DO PRODUTO, CHECANDO NA TABELA PRODUTO
    BEGIN                                  
      SELECT PRODUTO_JLM.VL_UNITARIO
      INTO V_VL_PRODUTO
      FROM PRODUTO_JLM
      WHERE PRODUTO_JLM.CD_PRODUTO = I_CD_PRODUTO;

    EXCEPTION
      WHEN OTHERS THEN
        V_VL_PRODUTO := 0;
    END;
    IF NVL(V_VL_PRODUTO,0) = 0 THEN
      O_MENSAGEM := 'VALOR NAO CADASTRADO PARA O PRODUTO, OU ZERADO';
      RAISE E_GERAL;
    END IF;  
    
    
    -- INSERÇÃO E ATUALIZAÇÃO
    BEGIN
      INSERT INTO ITEMVENDA_JLM (
                     CD_VENDA,
                     CD_PRODUTO,
                     VL_UNITPROD,
                     QT_ADQUIRIDA,
                     DT_RECORD)
                   VALUES( 
                     I_CD_VENDA,
                     I_CD_PRODUTO,
                     V_VL_PRODUTO,
                     I_QT_ADQUIRIDA,
                     SYSDATE);
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
          UPDATE ITEMVENDA_JLM
             SET VL_UNITPROD  = V_VL_PRODUTO,
                 QT_ADQUIRIDA = I_QT_ADQUIRIDA,
                 DT_RECORD    = SYSDATE
           WHERE CD_VENDA     = I_CD_VENDA
             AND CD_PRODUTO   = I_CD_PRODUTO;
        EXCEPTION
          WHEN OTHERS THEN
            O_MENSAGEM := 'ERRO AO ATUALIZAR A VENDA ('||I_CD_VENDA||') DO PRODUTO ('||I_CD_PRODUTO||'): '||SQLERRM;
            RAISE E_GERAL;
        END;
      WHEN OTHERS THEN
        O_MENSAGEM := 'ERRO AO INSERIR A VENDA ('||I_CD_VENDA||') DO PRODUTO ('||I_CD_PRODUTO||'): '||SQLERRM;
        RAISE E_GERAL;
    END;
    COMMIT;
  
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[CADASTRA_ITEMVENDA] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[CADASTRA_ITEMVENDA] ERRO NO PROCEDIMENTO QUE CADASTRA O ITEM DA VENDA'||SQLERRM;  
  END;
  
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------------------------
  
  PROCEDURE EXCLUI_ITEMVENDA ( I_CD_VENDA   IN ITEMVENDA_JLM.CD_VENDA%TYPE,
                               I_CD_PRODUTO IN ITEMVENDA_JLM.CD_PRODUTO%TYPE,
                               O_MENSAGEM   OUT VARCHAR2) IS
                               
  E_GERAL EXCEPTION;

  
  BEGIN
    
    -- DELETA CD_VENDA E CD_PRODUTO AMBOS
    BEGIN
      DELETE ITEMVENDA_JLM
      WHERE CD_VENDA   = I_CD_VENDA
        AND CD_PRODUTO = I_CD_PRODUTO;
    EXCEPTION
      WHEN OTHERS THEN
        O_MENSAGEM := 'ERRO AO EXCLUIR O ITEM '||I_CD_PRODUTO||'DA VENDA '||I_CD_VENDA||': '||SQLERRM;
        RAISE E_GERAL;
    END;
    COMMIT;
    
  EXCEPTION
    WHEN E_GERAL THEN
      ROLLBACK;
      O_MENSAGEM := '[EXCLUI_ITEMVENDA] '||O_MENSAGEM;
    WHEN OTHERS THEN
      ROLLBACK;
      O_MENSAGEM := '[EXCLUIR_ITEMVENDA] ERRO NO PROCEDIMENTO DE EXCLUSÃO DO ITEM VENDA'||SQLERRM;
  END;
   
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  PROCEDURE EXCLUI_VENDA ( I_CD_VENDA   IN VENDA_JLM.CD_VENDA%TYPE,
                           O_MENSAGEM   OUT VARCHAR2) IS
                           
   E_GERAL EXCEPTION;
   V_COUNT NUMBER;
   BEGIN
     BEGIN
     SELECT COUNT (*)
       INTO V_COUNT
       FROM ITEMVENDA_JLM
       WHERE CD_VENDA = I_CD_VENDA;
     EXCEPTION
       WHEN OTHERS THEN
         V_COUNT := 0;
     END;
     
     IF V_COUNT > 0 THEN
       O_MENSAGEM := 'NÃO É POSSIVEL EXCLUIR POIS EXISTEM ITENS CADASTRADOS A ESSA VENDA';
       RAISE E_GERAL;
     END IF;
     
     BEGIN
       DELETE VENDA_JLM
        WHERE CD_VENDA = I_CD_VENDA;
     EXCEPTION
       WHEN OTHERS THEN
         O_MENSAGEM :='ERRO AO EXCLUIR A VENDA '||I_CD_VENDA||': '||SQLERRM;
         RAISE E_GERAL;
     END;
     COMMIT;
     
   EXCEPTION
     WHEN E_GERAL THEN
       ROLLBACK;
       O_MENSAGEM := '[EXCLUI_VENDA] '||O_MENSAGEM;
     WHEN OTHERS THEN
       ROLLBACK;
       O_MENSAGEM := '[EXCLUI_VENDA] ERRO NO PROCEDIMENTO DE EXCLUSÃO DE VENDA'||SQLERRM;
   END;
   
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  PROCEDURE EXCLUI_PRODUTO ( I_CD_PRODUTO   IN PRODUTO_JLM.CD_PRODUTO%TYPE,
                             O_MENSAGEM     OUT VARCHAR2) IS
                           
    E_GERAL   EXCEPTION;
    V_COUNT  NUMBER;
    
    BEGIN
      BEGIN
        SELECT COUNT (*)
        INTO  V_COUNT
        FROM  ITEMVENDA_JLM
        WHERE CD_PRODUTO = I_CD_PRODUTO;
      EXCEPTION
        WHEN OTHERS THEN
          V_COUNT := 0;
      END;
      
      IF V_COUNT > 0 THEN
        O_MENSAGEM := 'NÃO É POSSIVEL REALIZAR A EXCLUSÃO, POIS EXISTEM PRODUTOS CADASTRADOS A VENDAS';
        RAISE E_GERAL;
      END IF;
      BEGIN
        DELETE PRODUTO_JLM
        WHERE CD_PRODUTO = I_CD_PRODUTO;
      EXCEPTION
        WHEN OTHERS THEN
          O_MENSAGEM := 'ERRO AO EXCLUIR O PRODUTO '||I_CD_PRODUTO||': '||SQLERRM;
          RAISE E_GERAL;
      END;
      COMMIT;
      
    EXCEPTION
      WHEN E_GERAL THEN
        ROLLBACK;
        O_MENSAGEM := '[EXCLUI_PRODUTO] '||O_MENSAGEM;
      WHEN OTHERS THEN
        ROLLBACK;
        O_MENSAGEM := '[EXCLUI_PRODUTO] ERRO NO PROCEDIMENTO DE EXCLUSÃO DE PRODUTO'||SQLERRM;
    END;
                           
                           
                           
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
  PROCEDURE EXCLUI_CLIENTE ( I_NR_CPF   IN CLIENTE_JLM.NR_CPF%TYPE,
                             O_MENSAGEM   OUT VARCHAR2) IS                           
  
    E_GERAL   EXCEPTION;
    V_COUNT  NUMBER;
    
    BEGIN
      BEGIN
        SELECT COUNT (*)
        INTO  V_COUNT
        FROM  VENDA_JLM
        WHERE NR_CPFCLIENTE = I_NR_CPF;
      EXCEPTION
        WHEN OTHERS THEN
          V_COUNT := 0;
      END;
      
      IF V_COUNT > 0 THEN
        O_MENSAGEM := 'NÃO É POSSIVEL REALIZAR A EXCLUSÃO, POIS EXISTEM VENDAS CADASTRADAS PARA ESSE CLIENTE';
        RAISE E_GERAL;
      END IF;
      BEGIN
        DELETE CLIENTE_JLM
        WHERE NR_CPF = I_NR_CPF;
      EXCEPTION
        WHEN OTHERS THEN
          O_MENSAGEM := 'ERRO AO EXCLUIR O CLIENTE '||I_NR_CPF||': '||SQLERRM;
          RAISE E_GERAL;
      END;
      COMMIT;
      
    EXCEPTION
      WHEN E_GERAL THEN
        ROLLBACK;
        O_MENSAGEM := '[EXCLUI_CLIENTE] '||O_MENSAGEM;
      WHEN OTHERS THEN
        ROLLBACK;
        O_MENSAGEM := '[EXCLUI_CLIENTE] ERRO NO PROCEDIMENTO DE EXCLUSÃO DE PRODUTO'||SQLERRM;
    END;
    
end PACK_REGISTRO_JLM;
/
