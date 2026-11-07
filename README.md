# Achados e Perdidos

Aplicativo móvel de achados e perdidos desenvolvido em **Flutter** e **Dart**, como parte da 2ª avaliação da disciplina de Programação para Dispositivos Móveis, do curso de Tecnologia em Sistemas de Computação da Universidade Estadual do Piauí (UESPI).

O projeto tem como objetivo facilitar a divulgação e a localização de objetos perdidos ou encontrados no campus universitário.

> **Status do projeto:** a versão disponibilizada ainda está na estrutura inicial gerada pelo Flutter. As funcionalidades específicas do aplicativo e a integração com armazenamento em nuvem ainda precisam ser implementadas.

## Equipe

- Felipe Martins dos Santos Silva
- Jordan Fernandes de Carvalho
- Henrique Veraz Cordeiro
- Antônio Ivo

## Objetivo

Permitir que membros da comunidade acadêmica publiquem informações sobre objetos perdidos ou encontrados e consultem os registros, contribuindo para que esses objetos sejam recuperados.

## Funcionalidades previstas

De acordo com os requisitos do trabalho, o aplicativo deverá oferecer:

- **Listagem de objetos:** exibir nome, descrição, local e situação (perdido ou encontrado), priorizando os registros mais recentes.
- **Cadastro de objetos:** formulário para informar nome, descrição, local e situação.
- **Validação:** verificar os campos obrigatórios e os limites de caracteres antes do envio.
- **Atualização da listagem:** permitir recarregar os registros armazenados na nuvem.
- **Operações assíncronas:** apresentar indicadores de carregamento, impedir envios duplicados e informar falhas de comunicação.
- **Armazenamento remoto:** manter os registros disponíveis mesmo após o encerramento do aplicativo e compartilhá-los entre diferentes instalações.

**Observação:** os itens acima descrevem os requisitos planejados. Eles não devem ser considerados funcionalidades já implementadas nesta versão.

## Tecnologias

| Tecnologia | Finalidade |
|---|---|
| Flutter | Desenvolvimento da interface e do aplicativo móvel |
| Dart | Linguagem de programação |
| Material Design 3 | Componentes e identidade visual da interface |

### Armazenamento em nuvem

**Serviço utilizado:** a definir.

O projeto deverá utilizar um serviço de armazenamento remoto com plano gratuito, capaz de persistir os registros e permitir sua recuperação por operações assíncronas.

Quando o serviço for definido e integrado, atualize esta seção com:

- Nome do serviço e link para sua documentação.
- Identificador do projeto ou banco de dados, quando aplicável.
- URL ou endpoint necessário para a conexão.
- Chaves e demais parâmetros de configuração necessários.
- Instruções para configurar a integração no ambiente de desenvolvimento.

Não publique credenciais privadas ou chaves secretas no repositório.

## Pré-requisitos

Antes de executar o projeto, instale:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) (incluído na instalação do Flutter)
- [Git](https://git-scm.com/downloads)
- Android Studio ou Visual Studio Code, com as extensões do Flutter e Dart.
- Um emulador Android ou dispositivo compatível para executar o aplicativo.

Para verificar a instalação do Flutter, execute:

```bash
flutter doctor
