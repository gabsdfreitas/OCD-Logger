# OCD Logger

## EN

OCD Logger is a cross-platform local-first application designed to help individuals track, manage, and reflect on their Obsessive-Compulsive Disorder (OCD) symptoms. Built with Flutter, the app borrows mechanics from Exposure and Response Prevention (ERP) therapy, providing tools to delay compulsions, track distress metrics, and log cognitive distortions.

## Core Features

* **Crisis Mode & Urge Timers:** A dedicated interface for high-anxiety moments. It provides an anchor phrase and a timer to help users resist and delay compulsive behaviors.
* **Intrusion & Trigger Logging:** Users can document specific triggers, environmental context, and break down intrusive thoughts by categorizing their underlying cognitive distortions (e.g., Catastrophizing, All-or-Nothing thinking).
* **Distress Metrics:** Tracks anxiety, urge to ritualize, and sense of control before, during, and after an episode.
* **ERP Reflection:** Encourages users to write down their predicted outcome (the core fear) and compare it against the actual outcome to measure surprise and build confidence over time.
* **Privacy-First Architecture:** No backend, no telemetry, and no cloud syncing. All sensitive data is stored strictly on the local device.
* **Universal Backups:** Users can export their entire registry as a self-contained `.json` file and restore it on any other device or OS.

## Technical Stack

* **Framework:** Flutter / Dart
* **UI/UX:** Custom glassmorphism interface with dynamic, distress-reactive background gradients. 
* **Data Persistence:** Local storage via `shared_preferences` and custom JSON serialization.
* **Supported Platforms:** Linux (Native & AppImage), macOS, Windows, iOS, and Android.

## PT-BR

# OCD Logger

O OCD Logger é um aplicativo multiplataforma e *local-first* projetado para ajudar indivíduos a rastrear, gerenciar e refletir sobre os sintomas do Transtorno Obsessivo-Compulsivo (TOC). Desenvolvido com Flutter, o app utiliza mecânicas da Terapia de Exposição e Prevenção de Respostas (EPR/ERP), fornecendo ferramentas para adiar compulsões, rastrear métricas de sofrimento e registrar distorções cognitivas.

## Recursos Principais

* **Modo Crise e Timers de Urgência:** Uma interface dedicada para momentos de alta ansiedade. Fornece uma frase de âncora e um cronômetro para ajudar os usuários a resistir e adiar comportamentos compulsivos.
* **Registro de Intrusões e Gatilhos:** Os usuários podem documentar gatilhos específicos, o contexto ambiental e detalhar pensamentos intrusivos categorizando suas distorções cognitivas subjacentes (ex: Catastrofização, pensamento Tudo ou Nada).
* **Métricas de Sofrimento:** Rastreia a ansiedade, a urgência de ritualizar e o senso de controle antes, durante e depois de um episódio.
* **Reflexão ERP:** Incentiva os usuários a anotar o resultado previsto (o medo central) e compará-lo com o resultado real para medir o nível de surpresa e construir confiança ao longo do tempo.
* **Privacidade em Primeiro Lugar:** Sem *backend*, sem telemetria e sem sincronização na nuvem. Todos os dados sensíveis são armazenados estritamente no dispositivo local.
* **Backups Universais:** Os usuários podem exportar todo o registro como um arquivo `.json` independente e restaurá-lo em qualquer outro dispositivo ou sistema operacional.

## Stack Tecnológica

* **Framework:** Flutter / Dart
* **UI/UX:** Interface *glassmorphism* customizada com gradientes de fundo dinâmicos que reagem ao nível de sofrimento. 
* **Persistência de Dados:** Armazenamento local via `shared_preferences` e serialização JSON customizada.
* **Plataformas Suportadas:** Linux (Nativo & AppImage), macOS, Windows, iOS e Android.

## Screenshots:

### Desktop:

<img width="1393" height="918" alt="image" src="https://github.com/user-attachments/assets/15a68af8-9f71-4a20-988b-f3ab9d356672" />

### Mobile:

<img width="585" height="1266" alt="image" src="https://github.com/user-attachments/assets/4f2291a2-b757-4f24-9ac3-c880e439451d" />
