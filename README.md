# Achados e Perdidos

Aplicativo móvel de achados e perdidos desenvolvido em **Flutter** e **Dart**, como parte da 2ª avaliação da disciplina de Programação para Dispositivos Móveis, do curso de Tecnologia em Sistemas de Computação da Universidade Estadual do Piauí (UESPI).

O projeto tem como objetivo facilitar a divulgação e a localização de objetos perdidos ou encontrados no campus universitário.

## Equipe

- Felipe Martins dos Santos Silva
- Jordan Fernandes de Carvalho
- Henrique Veraz Cordeiro
- Antônio Ivo

## Objetivo

Permitir que membros da comunidade acadêmica publiquem informações sobre objetos perdidos ou encontrados e consultem os registros, contribuindo para que esses objetos sejam recuperados.

## Funcionalidades implementadas

- **Listagem de objetos:** exibe nome, descrição, local, situação e data de criação, com os registros mais recentes primeiro.
- **Cadastro de objetos:** formulário com nome, descrição, local e situação.
- **Validação:** verifica campos obrigatórios e os limites de caracteres antes do envio.
- **Edição:** permite alterar os dados de um registro existente.
- **Exclusão:** remove um registro após confirmação do usuário.
- **Atualização da listagem:** permite recarregar os registros por botão ou gesto de puxar para atualizar.
- **Estados de interface:** apresenta indicadores de carregamento, estado vazio e mensagens de erro.
- **Controle de envio:** impede envios duplicados enquanto uma operação está em andamento.
- **Persistência remota:** mantém os registros no Firebase Firestore, compartilhados entre diferentes instalações.

## Tecnologias

| Tecnologia | Finalidade |
|---|---|
| Flutter | Desenvolvimento da interface e do aplicativo móvel |
| Dart | Linguagem de programação |
| Material Design 3 | Componentes e identidade visual da interface |
| Firebase Core | Inicialização e configuração do Firebase |
| Cloud Firestore | Banco de dados remoto para persistência dos registros |

## Estrutura do projeto

```text
lib/
  main.dart
  firebase_options.dart
  models/
    item_model.dart
  screens/
    list_screen.dart
    form_screen.dart
  services/
    item_service.dart
    firestore_item_service.dart
  state/
    item_store.dart
test/
  item_model_test.dart
  item_store_test.dart
android/app/google-services.json
firebase.json
firestore.rules
pubspec.yaml
```

## Modelo de dados do Firestore

Os registros são armazenados na coleção `items`.

| Campo | Tipo | Regra |
|---|---|---|
| `name` | string | Obrigatório, entre 1 e 60 caracteres |
| `description` | string | Obrigatório, entre 1 e 200 caracteres |
| `location` | string | Obrigatório |
| `status` | string | `Perdido` ou `Encontrado` |
| `createdAt` | timestamp | Gerado pelo servidor no cadastro |

A listagem é ordenada por `createdAt` em ordem decrescente.

## Configuração do Firebase

O projeto utiliza o Firebase no projeto `lost-and-found1-b14e7`, com os seguintes arquivos de configuração:

- `lib/firebase_options.dart`: opções do Firebase por plataforma;
- `android/app/google-services.json`: configuração do app Android;
- `firebase.json`: configuração dos serviços Firebase;
- `firestore.rules`: regras de segurança do Firestore.

As chaves presentes nesses arquivos são configurações públicas de cliente. A proteção dos dados é feita pelas regras do Firestore.

Para publicar as regras:

```bash
firebase login
firebase deploy --only firestore:rules --project lost-and-found1-b14e7
```

## Como executar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Dart SDK, incluído na instalação do Flutter
- [Git](https://git-scm.com/downloads)
- Android Studio ou Visual Studio Code, com as extensões do Flutter e Dart
- Um emulador Android ou dispositivo compatível
- Google Chrome, para executar a versão web
- Firebase CLI, apenas para publicar as regras do Firestore

Verifique a instalação do Flutter:

```bash
flutter doctor
```

Instale as dependências:

```bash
flutter pub get
```

Execute no Chrome:

```bash
flutter run -d chrome
```

Ou em um dispositivo/emulador:

```bash
flutter run
```

Para gerar builds:

```bash
flutter build web --release
flutter build apk
```

## Testes e análise

```bash
flutter analyze
flutter test
```

O projeto possui testes unitários para o modelo de dados e para o estado da aplicação. Atualmente são 11 testes, todos passando.

## Regras de segurança

O projeto não utiliza autenticação. As regras atuais permitem:

- leitura pública dos registros;
- criação de registros com os campos válidos;
- edição de registros, sem alterar o `createdAt` original;
- exclusão pública de registros.

As regras validam os campos obrigatórios, os limites de caracteres e os valores permitidos para a situação. A edição e a exclusão são abertas porque o trabalho não exige autenticação.

Para uso em produção, seria necessário adicionar autenticação e restringir as operações de edição e exclusão a usuários autorizados.

## Limitações

- Não há autenticação de usuários.
- Não há upload de imagens.
- Não há busca, filtros ou paginação.
- Não há perfis ou níveis de permissão.
- A edição e a exclusão estão abertas a qualquer pessoa com acesso ao aplicativo.
- Não há moderação dos registros cadastrados.

## Requisitos da avaliação

Os requisitos principais da 2ª avaliação são atendidos:

- listagem dos registros;
- cadastro com validação;
- atualização da listagem;
- operações assíncronas com carregamento, bloqueio de envio duplicado e tratamento de erros;
- armazenamento remoto no Firebase Firestore.

Além dos requisitos, o projeto também implementa edição e exclusão de registros.
