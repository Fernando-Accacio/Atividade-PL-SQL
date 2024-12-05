-- Criação do pacote PKG_ALUNO
CREATE OR REPLACE PACKAGE PKG_ALUNO IS
    PROCEDURE excluir_aluno(p_id_aluno IN NUMBER);
    PROCEDURE listar_alunos_maiores_18;
    PROCEDURE listar_alunos_por_curso(p_id_curso IN NUMBER);
END PKG_ALUNO;
/
 
CREATE OR REPLACE PACKAGE BODY PKG_ALUNO IS
    -- Procedure para exclusão de aluno e suas matrículas
    PROCEDURE excluir_aluno(p_id_aluno IN NUMBER) IS
    BEGIN
        DELETE FROM matricula WHERE id_aluno = p_id_aluno;
        DELETE FROM aluno WHERE id_aluno = p_id_aluno;
        DBMS_OUTPUT.PUT_LINE('Aluno e matrículas excluídos com sucesso.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao excluir aluno: ' || SQLERRM);
    END excluir_aluno;

    -- Cursor para listar alunos maiores de 18 anos
    PROCEDURE listar_alunos_maiores_18 IS
        CURSOR c_maiores_18 IS
        SELECT nome, data_nascimento
        FROM aluno
        WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, data_nascimento) / 12) > 18;

        v_nome ALUNO.NOME%TYPE;
        v_data_nascimento ALUNO.DATA_NASCIMENTO%TYPE;
    BEGIN
        OPEN c_maiores_18;
        LOOP
            FETCH c_maiores_18 INTO v_nome, v_data_nascimento;
            EXIT WHEN c_maiores_18%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_nome || ', ' || TO_CHAR(v_data_nascimento, 'DD/MM/YYYY'));
        END LOOP;
        CLOSE c_maiores_18;
    END listar_alunos_maiores_18;

    -- Cursor para listar alunos por curso
    PROCEDURE listar_alunos_por_curso(p_id_curso IN NUMBER) IS
        CURSOR c_alunos_curso IS
        SELECT nome
        FROM aluno
        WHERE id_curso = p_id_curso;

        v_nome ALUNO.NOME%TYPE;
    BEGIN
        OPEN c_alunos_curso;
        LOOP
            FETCH c_alunos_curso INTO v_nome;
            EXIT WHEN c_alunos_curso%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_nome);
        END LOOP;
        CLOSE c_alunos_curso;
    END listar_alunos_por_curso;
END PKG_ALUNO;
/

-- Criação do pacote PKG_DISCIPLINA
CREATE OR REPLACE PACKAGE PKG_DISCIPLINA IS
    PROCEDURE cadastrar_disciplina(p_nome IN VARCHAR2, p_descricao IN VARCHAR2, p_carga_horaria IN NUMBER);
    PROCEDURE total_alunos_por_disciplina;
    PROCEDURE media_idade_por_disciplina(p_id_disciplina IN NUMBER);
    PROCEDURE listar_alunos_disciplina(p_id_disciplina IN NUMBER);
END PKG_DISCIPLINA;
/
 
CREATE OR REPLACE PACKAGE BODY PKG_DISCIPLINA IS
    -- Procedure para cadastrar nova disciplina
    PROCEDURE cadastrar_disciplina(p_nome IN VARCHAR2, p_descricao IN VARCHAR2, p_carga_horaria IN NUMBER) IS
    BEGIN
        INSERT INTO disciplina (nome, descricao, carga_horaria)
        VALUES (p_nome, p_descricao, p_carga_horaria);
        DBMS_OUTPUT.PUT_LINE('Disciplina cadastrada com sucesso.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao cadastrar disciplina: ' || SQLERRM);
    END cadastrar_disciplina;

    -- Cursor para total de alunos por disciplina
    PROCEDURE total_alunos_por_disciplina IS
        CURSOR c_total_alunos IS
        SELECT d.nome, COUNT(m.id_aluno) AS total_alunos
        FROM disciplina d
        JOIN turma t ON d.id_disciplina = t.id_disciplina
        JOIN matricula m ON t.id_turma = m.id_turma
        GROUP BY d.nome
        HAVING COUNT(m.id_aluno) > 10;

        v_nome DISCIPLINA.NOME%TYPE;
        v_total NUMBER;
    BEGIN
        OPEN c_total_alunos;
        LOOP
            FETCH c_total_alunos INTO v_nome, v_total;
            EXIT WHEN c_total_alunos%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_nome || ': ' || v_total || ' alunos');
        END LOOP;
        CLOSE c_total_alunos;
    END total_alunos_por_disciplina;

    -- Cursor para média de idade por disciplina
    PROCEDURE media_idade_por_disciplina(p_id_disciplina IN NUMBER) IS
        CURSOR c_media_idade IS
        SELECT ROUND(AVG(TRUNC(MONTHS_BETWEEN(SYSDATE, a.data_nascimento) / 12)), 2) AS media_idade
        FROM aluno a
        JOIN matricula m ON a.id_aluno = m.id_aluno
        JOIN turma t ON m.id_turma = t.id_turma
        WHERE t.id_disciplina = p_id_disciplina;

        v_media NUMBER;
    BEGIN
        OPEN c_media_idade;
        FETCH c_media_idade INTO v_media;
        CLOSE c_media_idade;

        DBMS_OUTPUT.PUT_LINE('Média de idade: ' || v_media);
    END media_idade_por_disciplina;

    -- Procedure para listar alunos de uma disciplina
    PROCEDURE listar_alunos_disciplina(p_id_disciplina IN NUMBER) IS
        CURSOR c_alunos IS
        SELECT a.nome
        FROM aluno a
        JOIN matricula m ON a.id_aluno = m.id_aluno
        JOIN turma t ON m.id_turma = t.id_turma
        WHERE t.id_disciplina = p_id_disciplina;

        v_nome ALUNO.NOME%TYPE;
    BEGIN
        OPEN c_alunos;
        LOOP
            FETCH c_alunos INTO v_nome;
            EXIT WHEN c_alunos%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_nome);
        END LOOP;
        CLOSE c_alunos;
    END listar_alunos_disciplina;
END PKG_DISCIPLINA;
/

-- Criação do pacote PKG_PROFESSOR
CREATE OR REPLACE PACKAGE PKG_PROFESSOR IS
    FUNCTION total_turmas_professor(p_id_professor IN NUMBER) RETURN NUMBER;
    FUNCTION professor_disciplina(p_id_disciplina IN NUMBER) RETURN VARCHAR2;
    PROCEDURE listar_turmas_professor;
END PKG_PROFESSOR;
/
 
CREATE OR REPLACE PACKAGE BODY PKG_PROFESSOR IS
    -- Function para total de turmas de um professor
    FUNCTION total_turmas_professor(p_id_professor IN NUMBER) RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_total
        FROM turma
        WHERE id_professor = p_id_professor;

        RETURN v_total;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao calcular total de turmas: ' || SQLERRM);
            RETURN -1;
    END total_turmas_professor;

    -- Function para professor de uma disciplina
    FUNCTION professor_disciplina(p_id_disciplina IN NUMBER) RETURN VARCHAR2 IS
        v_nome PROFESSOR.NOME%TYPE;
    BEGIN
        SELECT p.nome
        INTO v_nome
        FROM professor p
        JOIN turma t ON p.id_professor = t.id_professor
        WHERE t.id_disciplina = p_id_disciplina
        AND ROWNUM = 1;

        RETURN v_nome;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Nenhum professor encontrado para a disciplina.';
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao buscar professor: ' || SQLERRM);
            RETURN 'Erro ao buscar professor.';
    END professor_disciplina;

    -- Cursor para total de turmas por professor
    PROCEDURE listar_turmas_professor IS
        CURSOR c_turmas IS
        SELECT p.nome, COUNT(t.id_turma) AS total_turmas
        FROM professor p
        JOIN turma t ON p.id_professor = t.id_professor
        GROUP BY p.nome
        HAVING COUNT(t.id_turma) > 1;

        v_nome PROFESSOR.NOME%TYPE;
        v_total NUMBER;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Professores com mais de uma turma:');
        OPEN c_turmas;
        LOOP
            FETCH c_turmas INTO v_nome, v_total;
            EXIT WHEN c_turmas%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(v_nome || ': ' || v_total || ' turmas');
        END LOOP;
        CLOSE c_turmas;
    END listar_turmas_professor;
END PKG_PROFESSOR;
/
