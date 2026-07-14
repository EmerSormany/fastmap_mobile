# FastMap Mobile

Desenvolvido por Emerson Sormany, Rúdson Alisson e José Mamede

### 1. Visão Geral

O FastMap Mobile é um aplicativo voltado para a área de engenharia, topografia e agronegócio. Seu objetivo principal é permitir que profissionais realizem o levantamento perimetral de terrenos, sítios e fazendas utilizando apenas o smartphone. O aplicativo calcula automaticamente a área (em metros quadrados e hectares), o perímetro, realiza a conversão de coordenadas geográficas para UTM e gera um relatório técnico (croqui) em formato PDF.

### 2. Tecnologias e Arquitetura

Framework Frontend: Flutter / Dart

Backend as a Service (BaaS): Supabase (PostgreSQL, Autenticação, Storage)

Arquitetura: Baseada em componentes reativos com separação de responsabilidades (Controllers para lógica de negócios e persistência, Views para interface de usuário).

Bibliotecas Principais:

Geolocator: comunicação com os dados de GPS do dispositivo.

flutter_map e latlong2: Renderização de mapas e manipulação de coordenadas.

utm: Conversão de coordenadas esféricas (WGS 84) para o plano cartesiano (Universal Transversa de Mercator).

pdf e printing: Geração nativa e compartilhamento de relatórios em PDF.

supabase_flutter: Comunicação direta e reativa com o banco de dados em nuvem.

### 3. Funcionalidades Principais

#### 3.1. Autenticação e Sessão Reativa

O acesso ao aplicativo é restrito a usuários cadastrados.

Utiliza um AuthGate (Portão de Autenticação) que escuta o estado da sessão no Supabase em tempo real. Se o token de acesso (JWT) estiver salvo de forma segura no dispositivo, o usuário é direcionado automaticamente à tela inicial, dispensando novos logins.

#### 3.2. Gestão de Projetos (CRUD)

Meus Projetos (Home): Tela inicial que lista todos os levantamentos salvos na nuvem.

Permite criar novos projetos, visualizar os existentes, editá-los e excluí-los.

Sincronização em tempo real puxada (Pull-to-refresh) do banco de dados.

#### 3.3. Formulário de Dados do Terreno

Coleta de dados essenciais para o relatório: Nome do projeto, Proprietário, Telefone, Cidade, UF, Bairro e Número.

A lógica de salvamento ("Atualizar Dados") foi separada da lógica de mapeamento, permitindo que o usuário altere apenas erros de digitação sem perder as coordenadas já coletadas.

#### 3.4. Coleta Geoespacial no Mapa

Tela interativa que exibe a imagem de satélite da região.

Permite a marcação de vértices (pontos) que formam o polígono do terreno.

Retenção de estado: Ao editar um projeto, os vértices coletados anteriormente são automaticamente desenhados no mapa para continuação ou correção do trabalho.

#### 3.5. Cálculos de Engenharia e Conversão

Conversão UTM: O sistema converte cada ponto Latitude/Longitude capturado pelo GPS para coordenadas UTM (Easting/Northing).

Cálculo de Área Real: Utiliza a Fórmula de Shoelace (Área de Gauss) nos eixos X e Y do UTM para obter a área exata em metros quadrados planificados, mitigando a distorção da curvatura da Terra.

Cálculo de Distâncias: Calcula a distância geodésica exata entre cada vértice para compor o perímetro.

#### 3.6. Geração de Relatório e Croqui (PDF)

Captura silenciosa (RepaintBoundary) do mapa de satélite e do croqui geométrico.

Desenho matemático escalonado do croqui, incluindo bússola (Norte Verdadeiro) e escala gráfica dinâmica.

Consolidação de todos os dados em um documento A4 profissional, pronto para ser impresso ou compartilhado via WhatsApp/E-mail nativamente.

### 4. Acesso ao Hardware de GPS e Precisão

Uma das características mais críticas do FastMap Mobile é a sua dependência dos dados de localização do dispositivo. Compreender como essa comunicação ocorre é essencial para a operação técnica.

#### 4.1. Como a Aplicação Acessa o Hardware

O Flutter, por ser um framework multiplataforma, não conversa diretamente com as antenas de hardware do celular. Ele utiliza uma arquitetura de "ponte" chamada Platform Channels para solicitar que o sistema operacional faça esse trabalho pesado.

O fluxo de comunicação detalhado ocorre nas seguintes etapas:

Camada de Solicitação (Dart/Flutter): Quando o usuário entra na tela do mapa e solicita a coleta de um ponto, o código em Dart valida se a permissão de localização "Em Primeiro Plano" (Foreground) foi concedida. Em caso positivo, ele abre um EventChannel de comunicação.

A Ponte (Platform Channels): O pedido "cruza a ponte" saindo do ambiente Dart (Isolate) e entrando no código nativo do dispositivo. A comunicação é serializada e enviada para o host nativo:

No Android: O código em Kotlin/Java recebe o pedido.

Invocação das APIs Nativas (Processamento do OS):

No Android, o FastMap aciona a API FusedLocationProviderClient (parte do Google Play Services).

Neste momento, o sistema operacional liga fisicamente os sensores do dispositivo.

Fusão de Sensores (Fused Location): O sistema operacional não confia apenas na antena GNSS (GPS). Para entregar uma coordenada rápida e otimizar a bateria, ele cruza os dados ativamente de três fontes (Fusão de Sensores):

Redes Wi-Fi e Torres de Celular: Dão uma estimativa inicial rápida baseada no IP e força do sinal das antenas próximas (baixa precisão).

Antena GNSS (GPS/GLONASS/Galileo): Como o FastMap exige o perfil de Alta Precisão (High Accuracy), o OS liga a antena principal para buscar o sinal direto dos satélites (alta precisão, mas com um tempo de warm-up maior).

Sensores de Movimento: Acelerômetro e giroscópio ajudam o OS a saber se o usuário está se movendo, suavizando o deslocamento no mapa.

O Retorno Contínuo (Event Sink): O sistema operacional compila todos esses cálculos em um único pacote de dados e o envia de volta pela ponte (EventChannel) para o Flutter em formato de Stream (um fluxo contínuo). O Flutter recebe, decodifica e converte isso em um objeto de localização que contém a Latitude (Y), Longitude (X), Altitude (Z) e o Raio de Precisão Estimado em metros.

#### 4.2. Precisão e Acurácia (Limitações do Hardware Mobile)

É fundamental que os usuários do FastMap Mobile entendam a diferença entre um equipamento topográfico profissional (RTK) e um smartphone:

Equipamento RTK Profissional: Possui precisão milimétrica ou centimétrica, pois utiliza antenas de dupla frequência e correção de base terrestre em tempo real.

Smartphone Comercial: Utiliza antenas de frequência única (geralmente L1). A precisão natural do hardware de um smartphone moderno, em condições ideais de céu aberto, varia entre 3 a 5 metros de raio de erro.

Fatores que afetam a precisão da coleta no FastMap:

Efeito Multipath (Multicaminho): Se o mapeamento ocorrer perto de construções altas, montanhas de pedra ou copas de árvores muito densas, o sinal do satélite "bate" no obstáculo antes de chegar ao celular, atrasando o tempo do sinal e gerando falsas distâncias (jogando o ponto metros para o lado).

Céu Fechado (Nebulosidade): Nuvens muito densas ou chuvas fortes degradam a força do sinal.

Aquecimento do Chip: A coleta contínua sob o sol esquenta o dispositivo, o que pode causar thermal throttling e reduzir o desempenho da fusão de sensores do Android.

#### 4.3. Boas Práticas para o Usuário

Para garantir a melhor precisão possível no cálculo da área via FastMap:

Aguardar alguns segundos no local do vértice antes de registrar o ponto, permitindo que o hardware estabilize a conexão com mais satélites.

Evitar marcar pontos enquanto estiver em movimento rápido ou com o celular no bolso.

Realizar coletas preferencialmente em áreas de "céu aberto" para que o celular tenha linha de visada com pelo menos 4 satélites (mínimo necessário para triangular a posição em 3D).

### 5. Fluxo de Dados (Cloud / Supabase)

A estrutura de banco de dados foi modelada para ser leve e trafegar facilmente via redes móveis 3G/4G instáveis em áreas rurais:

Tabela projetos: Possui políticas de segurança RLS (Row Level Security) garantindo que um usuário (auth.uid()) só possa ler, alterar ou deletar os seus próprios projetos.

Coluna de Coordenadas (jsonb): Ao invés de criar tabelas relacionais complexas, toda a lista de coordenadas (List<LatLng>) gerada no mapa é empacotada em uma estrutura de dados leve (JSON Array) e salva na mesma linha do projeto, garantindo que o carregamento da tela Home consuma o mínimo de banda de internet possível.
