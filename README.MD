# Projeto de Pacotes em PL/SQL - Sistema de Gestão Acadêmica

Este repositório contém pacotes em PL/SQL que implementam operações relacionadas às entidades **Aluno**, **Disciplina** e **Professor** em um banco de dados Oracle. O projeto inclui pacotes para cadastro de alunos, disciplinas e professores, além de operações para manipulação de dados e relatórios.

## Como Usar

### 1. Criação das Tabelas e Sequências

Para que os pacotes funcionem corretamente, você precisa primeiro criar as tabelas e sequências no banco de dados Oracle. Execute o seguinte código SQL para criar as tabelas e as sequências necessárias:

```sql
-- Criação das Tabelas
CREATE TABLE ALUNO (
    ID_ALUNO NUMBER PRIMARY KEY,
    NOME VARCHAR2(100),
    DATA_NASCIMENTO DATE,
    ID_CURSO NUMBER
);

CREATE TABLE DISCIPLINA (
    ID_DISCIPLINA NUMBER PRIMARY KEY,
    NOME VARCHAR2(100),
    DESCRICAO VARCHAR2(255),
    CARGA_HORARIA NUMBER
);

CREATE TABLE PROFESSOR (
    ID_PROFESSOR NUMBER PRIMARY KEY,
    NOME VARCHAR2(100)
);

CREATE TABLE MATRICULA (
    ID_MATRICULA NUMBER PRIMARY KEY,
    ID_ALUNO NUMBER,
    ID_DISCIPLINA NUMBER,
    CONSTRAINT FK_ALUNO FOREIGN KEY (ID_ALUNO) REFERENCES ALUNO(ID_ALUNO),
    CONSTRAINT FK_DISCIPLINA FOREIGN KEY (ID_DISCIPLINA) REFERENCES DISCIPLINA(ID_DISCIPLINA)
);

CREATE TABLE TURMA (
    ID_TURMA NUMBER PRIMARY KEY,
    ID_DISCIPLINA NUMBER,
    ID_PROFESSOR NUMBER,
    CONSTRAINT FK_DISCIPLINA_TURMA FOREIGN KEY (ID_DISCIPLINA) REFERENCES DISCIPLINA(ID_DISCIPLINA),
    CONSTRAINT FK_PROFESSOR_TURMA FOREIGN KEY (ID_PROFESSOR) REFERENCES PROFESSOR(ID_PROFESSOR)
);

-- Criação das Sequências
CREATE SEQUENCE SEQ_ALUNO START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_DISCIPLINA START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_PROFESSOR START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_TURMA START WITH 1 INCREMENT BY 1;
```

### 2. Criação dos Pacotes e Package Bodies

Após criar as tabelas e sequências, o próximo passo é criar os pacotes e os respectivos bodies. Execute os seguintes comandos do arquivo SQL para criar os pacotes e os bodies.

### 3. Executando os Testes

Após criar as tabelas, sequências e pacotes, você pode executar os testes para verificar se tudo está funcionando corretamente. Aqui estão alguns exemplos de testes que você pode executar:

#### 4. Testes

-- Teste de exclusão de aluno
EXEC PKG_ALUNO.excluir_aluno(1);

-- Teste de listar alunos maiores de 18 anos
EXEC PKG_ALUNO.listar_maiores_de_18;

-- Teste de listar alunos por curso
EXEC PKG_ALUNO.listar_alunos_por_curso(1);

-- Teste de cadastrar disciplina
EXEC PKG_DISCIPLINA.cadastrar_disciplina('Matemática', 'Disciplina de Cálculos', 60);

-- Teste de listar alunos de uma disciplina
EXEC PKG_DISCIPLINA.listar_alunos_de_disciplina(1);

-- Teste de total de turmas por professor
EXEC PKG_PROFESSOR.total_turmas_por_professor;

-- Teste de total de turmas de um professor específico
DECLARE
    v_total INT;
BEGIN
    v_total := PKG_PROFESSOR.total_turmas(1);
    DBMS_OUTPUT.PUT_LINE('Total de turmas: ' || v_total);
END;
/

-- Teste de professor de disciplina
DECLARE
    v_professor VARCHAR2(100);
BEGIN
    v_professor := PKG_PROFESSOR.professor_de_disciplina(1);
    DBMS_OUTPUT.PUT_LINE('Professor: ' || v_professor);
END;
/

##### 5. Funções dos Pacotes

### PKG_ALUNO

- **excluir_aluno(id_aluno IN NUMBER):** Exclui um aluno e suas matrículas associadas.
- **listar_alunos_maiores_18:** Retorna todos os alunos maiores de 18 anos.
- **listar_alunos_por_curso(id_curso IN NUMBER):** Retorna todos os alunos matriculados em um curso específico.

### PKG_DISCIPLINA

- **cadastrar_disciplina(nome IN VARCHAR2, descricao IN VARCHAR2, carga_horaria IN NUMBER):** Cadastra uma nova disciplina no banco de dados.
- **total_alunos_por_disciplina:** Retorna a disciplina e a quantidade de alunos matriculados que têm mais de 10 alunos.
- **media_idade_por_disciplina(id_disciplina IN NUMBER):** Retorna a média de idade dos alunos de uma disciplina.
- **listar_alunos_disciplina(id_disciplina IN NUMBER):** Exibe a lista de alunos matriculados em uma disciplina.

### PKG_PROFESSOR

- **total_turmas_por_professor:** Retorna o nome de um professor e a quantidade de turmas em que ele está envolvido.
- **total_turmas_por_professor(id_professor IN NUMBER):** Retorna o total de turmas associadas a um professor específico.
- **professor_de_disciplina(id_disciplina IN NUMBER):** Retorna o nome do professor associado a uma disciplina ou uma mensagem caso não haja nenhum.