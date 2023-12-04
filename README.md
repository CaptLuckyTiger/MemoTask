# **MemoTask**

Esse aplicativo foi pensando para o usuario que precise fazer uma anotação, ou lista de necessidades, ou afazeres
Ele conta com um sistema login para manter a privacidade e seguro.

Funcionalidade-> criar uma lista, ou uma simples anotação, marcar algum item da lista se já foi completo e riscar da lista
BUGS-> crash entre login e home 

Login e verificações usando Forms, como impedir login em branco com avisos, usuario incorreto, caracter minimo da senha não alcançado

-  Consertar o bug da navegação do login para tela inicial.
  
## Membros da equipe

**[Mizael Simão](https://github.com/CaptLuckyTiger)**: Login e verificações, calendario.

**[Antony de Paula](https://github.com/AntonydePS)**: Funções referentes as telas iniciais e de tarefas.

## Instruções de Instalação

-  Baixar o repositório.
-  Abrir a pasta no VScode.
-  Esperar o VScode sincronizar as dependências básicas (caso não sincronize, execute **flutter run** no terminal).
-  Executar o app.


## Atualizações

Atualização BUG consertado e resolvido.

-  Calendario ainda não implementado.
-  Menu no homem não implementado.

Atualização 

- Calendario implementado.
- Menu Lateral Implementado.

## Atualizações

Atualização BUG consertado e resolvido.

-  pesquisas com problema, firebase não salva as tarefas criadas, autenticação do usuario.
-  tema não salva.

Atualização 

 -Provider implementado, Firabse implementado, Pesquisa consertada, firebase sicronizado, novos usuarios são criados e registrados.
- tema aplica modo escuro.

 ## Atualizações

- tarefas agora podem ser editada, nome de usuario e email é compartilhado com o drawer após o registro ou login, o usuario pode enviar fotos dessa forma utulizando o recurso nativo, foi feito uso de API SharedPreferences para resolver problemas e compartilhar um valor chave para que o nome e email fosse mostrado no drawer.

- ## Problemas
 Usuario ainda continuam vendo tarefas um do outro, tema não foi aplicado para todo o app, problema de cache com foto, e usuario registrado ou logado o usuario tera que deslogar e relogar para que sua conta apareça no drawer com seu nome e email.
