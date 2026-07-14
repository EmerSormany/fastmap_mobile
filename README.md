# **Documento de Especificação de Projeto Prático (Exemplo)**

**Disciplina:** Programação para Dispositivos Móveis

## **Identificação do Grupo (Máximo de 3 integrantes)**

* **Integrante 1:** José Mamede  
* **Integrante 2:** Rúdson Alisson  
* **Integrante 3:** Emerson Sormany

## **1\. Visão Geral do Projeto**

O **FastMap Mobile**, um aplicativo autoral focado nas áreas de engenharia, topografia e agronegócio. O problema resolvido é a dependência de equipamentos topográficos caros e complexos para levantamentos preliminares e medições de rotina. O aplicativo transforma o smartphone em uma ferramenta capaz de capturar coordenadas geográficas em campo, realizar cálculos complexos de área e perímetro, e gerar relatórios técnicos profissionais de forma imediata.

* **Nome do Aplicativo:** FastMap Mobile  
* **Objetivo Geral:** Permitir que profissionais realizem o levantamento perimetral de terrenos de forma digital, capturando vértices via GPS, calculando métricas exatas em UTM, metros quadrados e hectares e emitindo croquis em PDF integrados à nuvem.

## **2\. Requisitos de Funcionalidades (As Telas do Sistema)**

O aplicativo possui um fluxo de navegação protegido e estruturado em telas principais:

* **Tela 1: Autenticação e Painel de Projetos (Leitura em Nuvem)**

  * **Portão de Acesso (AuthGate):** A tela inicial gerencia a sessão de forma reativa. Usuários não logados veem o formulário de login; usuários logados acessam a Home automaticamente através da validação de token (JWT).

  * **Listagem de Dados:** Exibe os levantamentos previamente salvos no banco de dados (Supabase) em cartões visuais interativos.

  * **Sincronização:** Possui funcionalidade de atualização (*pull-to-refresh*) para buscar os dados mais recentes na nuvem.

* **Tela 2: Formulário de Dados do Terreno (Entrada de Dados)**

  * **Formulário Estruturado:** Coleta de dados descritivos essenciais como Nome do Projeto, Proprietário, Telefone, Cidade, UF, Bairro e Número.

  * **Validação de Dados e Regras de Negócio:** Garante o preenchimento dos campos obrigatórios. Implementa formatação inteligente para tratar campos em branco e formatação de strings consolidadas.

  * **Ação Dupla:** Permite que o usuário apenas *Atualize Dados*, salvando direto na nuvem, ou avance para *Editar Mapa* preservando a memória das coordenadas.

* **Tela 3: Coleta Geoespacial no Mapa (Integração de Hardware)**

  * **Renderização Cartográfica:** Exibe um mapa com imagens de satélite interativas.

  * **Coleta de Vértices:** Acessa o hardware de GPS nativo do celular para registrar marcadores, que são pontos de latitude e longitude, formando a geometria do terreno.

  * **Retenção de Estado:** Ao abrir um projeto existente, os pontos renderizam as marcações e polígonos perfeitamente como foram deixados na última edição.

* **Tela 4: Croqui e Relatório Técnico (Processamento e Saída)**

  * **Processamento Matemático:** Converte as coordenadas WGS 84 do GPS para o sistema plano cartesiano *UTM*. Aplica a *Fórmula de Shoelace* (Área de Gauss) para calcular com precisão a área e o perímetro.

  * **Representação Gráfica:** Desenha o croqui escalonado do terreno, incluindo indicativos precisos de Norte Verdadeiro (invertendo eixos Y do Canvas) e escala gráfica em metros.

  * **Persistência Final:** Botão para consolidar as edições e enviar o JSON final ao Supabase.

## **3\. Customizações e Melhorias Implementadas pelo Grupo**

* **Tarefa 1: Gestão de Sessão Reativa (AuthGate)**   
  Implementamos uma arquitetura de proteção de rotas ouvindo o *Stream* do *Supabase* em tempo real. O aplicativo detecta o token salvo no armazenamento seguro do dispositivo e redireciona os fluxos automaticamente sem depender de empilhamentos estáticos de tela, elevando a segurança e melhorando a UX.  
* **Tarefa 2: Modelagem Otimizada de Banco de Dados**  
  Para suportar o trabalho em áreas rurais com internet 3G/4G instável, otimizamos o tráfego de rede. Em vez de criar tabelas relacionais complexas para cada ponto do mapa, serializamos a lista inteira de coordenadas *List\<LatLng\>* em um único campo leve de matriz em campo do tipo *jsonb* diretamente na tabela do projeto.  
* **Tarefa 3: Integração Nativa de Hardware via Platform Channels**   
  O aplicativo não depende apenas de mocks. Configuramos as permissões nativas do Android usando *AndroidManifest.xml \- ACCESS\_FINE\_LOCATION*, *AndroidManifest.xml \- ACCESS\_COARSE\_LOCATION* para cruzar a ponte do Flutter até os serviços de "Fusão de Sensores" do aparelho, garantindo uma coleta mais exata das coordenadas *e AndroidManifest.xml \- INTERNET* para conseguir acessar internet.  
* **Tarefa 4: Geração de Relatório Profissional em PDF com Captura de Tela**    
  Adicionamos a biblioteca *pdf* e *printing*. Utilizamos a *RepaintBoundary* para tirar "prints" silenciosos da renderização do mapa e do croqui, embutindo as imagens geradas diretamente em um documento A4 vetorizado e formatado para ser exportado via WhatsApp ou E-mail ou baixado nativamente pelo sistema operacional.

