# EveryDay

Leitura da Bíblia em comunidade — o dia começa na leitura.

App Flutter (Android / iOS / web) com papéis de **membro**, **líder** e **pastor**. O código do app fica em `every_day/`. Backend: Supabase.

## Contas de demonstração

Não altere as senhas.

| Papel  | E-mail                          | Senha         |
| ------ | ------------------------------- | ------------- |
| Pastor | `marcos@gmail.com`              | `123456`      |
| Membro | `igreja01.bbc72a@everyday.test` | `Leitura123!` |

- **Pastor (Marcos)** — Igreja Batista. Vê grupos, avisos, membros, métricas e direciona leitura.
- **Membro (Ana Souza)** — grupo Igreja Batista. Vê Home, Planos, Grupos e Perfil; faz o check-in de sentimento e o quiz ao encerrar um plano.

Código da igreja: `BBC72A`

## Como rodar

```bash
cd every_day
flutter pub get
flutter run
```

Depois de mudanças de navegação, autenticação ou injeção de dependências, use **hot restart** (não hot reload).

## APK de demo (Android)

```bash
cd every_day
flutter build apk --release
```

O arquivo sai em:

`every_day/build/app/outputs/flutter-apk/app-release.apk`

Para compartilhar: envie esse arquivo no Google Drive (ou WeTransfer), deixe o acesso como **qualquer pessoa com o link** e copie o link. Quem receber instala no Android (é preciso permitir fontes desconhecidas). iPhone não instala APK.
