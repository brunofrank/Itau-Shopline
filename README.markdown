Itau Shopline (itau_cripto)
------------

Gem para integração com Itau Shopline.

### Observação

O código desta gem é muito ruim pois foi "extraído" de uma classe Java fornecido pelo banco,
em breve estarei melhorando isso inclusive adicionando testes unitários, caso você possa
contribuir entre em contato comigo.

COMO USAR
---------


### Configuração

O primeiro passo é instalar a gem.

```ruby
  gem install itau_shopline
```

ou no Gemfile

```ruby
  gem itau_shopline
```

Depois de instalar, você precisará informar seus dados criando o arquivo:

### config/itau_shopline.yml

```yaml
development:
  codigo_empresa: CÓDIGO DA EMPRESA
  chave: CHAVE FORNECIDA PELO BANCO
    
test:
  codigo_empresa: CÓDIGO DA EMPRESA
  chave: CHAVE FORNECIDA PELO BANCO
      
production:
  codigo_empresa: CÓDIGO DA EMPRESA
  chave: CHAVE FORNECIDA PELO BANCO
  
staging:
  codigo_empresa: CÓDIGO DA EMPRESA
  chave: CHAVE FORNECIDA PELO BANCO

```

Efetuando uma transação
-----------------------

Para efetuar uma compra você pode usar a ```ItauCripto``` direto e seguir o manual do banco,
ou usar uma helper class chamada ```ItauShopline```, segue exemplo.

```ruby

  # gera_dados(invoice_id, total_price, full_name, city_name, state_uf, due_date=nil, return_url="")
  # Atenção: Você deve passar somente o path de retorno, 
  # pois o banco ira concatenar isso ao endereço principal do site cadastrado.
  
  @itau_dc = ItauShopline.new.gera_dados(1, 22.50, 'Fulano de Tal', 'Goiânia', 'GO', nil, 'faturamento/itau/aviso') 
  
```

Após isso vc deve chamar a tela para pagamentos.

```html
<script type="text/javascript" charset="utf-8">
  function carregaItauShopline() { 
    window.open('https://shopline.itau.com.br/shopline/shopline.aspx?DC=<%= @itau_dc %>', 'SHOPLINE', "toolbar=yes,menubar=yes,resizable=yes,status=no,scrollbars=yes,width=675,height=485");
  }        
  
  $(function(){      
    carregaItauShopline();
  });    
</script>
<div id="itau-shopline">
  <h1>Iniciando Itaú Shopline...</h1><br />
  <%= link_to 'Caso o Itau Shopline não inicie automaticamente, clique aqui...', '#', :onclick => 'carregaItauShopline();' %>    
</div>
```

### Recebendo retorno dos dados.

Após fazer o pagamento, o usuário vai ser direcionado para a URL de retorno informada, juntamente
com os dados da compra em um parâmetro chamado 'DC'

```ruby
class BillingController < ApplicationController
  
  def notify
    notification = ItauShopline.new.dcript_transaction_notify(params['DC'])  

    # Pesquiso a fatura usando o código do pedido.
    invoice = Invoice.find notification[:num_ped]

    # Muda o status do pedido de acordo com os dados fornecidos.
    invoice.update_by_itau_shopline
    
    # Redireciona para uma página de pós compra. 
    redirect_to payment_confirmation_url
  end
end

```

### Outras informação de retorno.

```ruby
  
  ItauShopline.new.dcript_transaction_notify(params['DC'])  
  => {"CodEmp"=>"NNNNNNNNNNNNNNN", "Pedido"=>"00010000", "Valor"=>"", "tipPag"=>:undefined, "sitPag"=>:pending, "dtPag"=>"", "codAut"=>"", "numId"=>"", "compVend"=>"", "tipCart"=>""}
  
```
## Pesquisando um pedido.

Caso seja necessário pesquisar por uma fatura:

```ruby
  shopline = ItauShopline.new
  shopline.get_invoice_details(1) # Número do pedido.
  => {"CodEmp"=>"NNNNNNNNNNNNNNN", "Pedido"=>"00000001", "Valor"=>"", "tipPag"=>:undefined, "sitPag"=>:pending, "dtPag"=>"", "codAut"=>"", "numId"=>"", "compVend"=>"", "tipCart"=>""} 
end
```

AUTOR:
------

Bruno Frank Silva Cordeiro bfscordeiro (at) gmail (dot) com

LICENÇA:
--------

(The MIT License)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.