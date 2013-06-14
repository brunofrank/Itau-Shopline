# -*- encoding: utf-8 -*-

require "net/https"
require "uri"
require "rexml/document"
require "open-uri"

class ItauShopline
  include ActionView::Helpers::NumberHelper

  STATUS_TRANSLATE = {
    :pending => 'Pendente',
    :paid => 'Pago'
  }
  
  PAYMENT_TRANSLATE = {
    :undefined => 'Não definido',
    :online_transfer => 'Transferência',
    :invoice => 'Boleto',
    :credit_card => 'Cartão de crédito'
  }

  STATUS = {
    :undefined => {
      '01' => :pending,
      '02' => :pending,
      '03' => :pending
    },
    :online_transfer => {
      '00' => :paid,
      '01' => :pending,
      '02' => :pending,
      '03' => :pending      
    },
    :invoice => {
      '00' => :paid,
      '01' => :pending,
      '02' => :pending,
      '03' => :pending,
      '04' => :pending,
      '05' => :paid,
      '06' => :pending   
    },
    :credit_card => {
      '00' => :paid,
      '01' => :pending,
      '02' => :pending,
      '03' => :pending      
    }
  }
  
  PAYMENT_METHODS = {
    '00' => :undefined,
    '01' => :online_transfer,
    '02' => :invoice,    
    '03' => :credit_card
  }
  
  def gera_dados(invoice_id, total_price, full_name, address1, address2, zipcode, city_name, state_uf, cod_inscricao, num_inscricao, due_date=nil, return_url="")
    cripto = ItauCripto.new
    due_date ||= (Date.today + 3.days).strftime('%d%m%Y')
    cripto.gera_dados(config['codigo_empresa'], invoice_id.to_s, number_to_currency(total_price, :unit => "", :separator => ",", :delimiter => ""), "",  config['chave'], full_name, cod_inscricao, num_inscricao, address1, address2, zipcode, city_name[0,15], state_uf[0,2], due_date, return_url[0,60], '', '', '')
  end

  def dcript_transaction_notify(dados)
    cripto = ItauCripto.new
    cripto.decripto(dados, config['chave'])    
  end
  
  def get_invoice_details(invoice_id)
    cripto = ItauCripto.new
    token = cripto.gera_consulta(config['codigo_empresa'], invoice_id.to_s, '1',config['chave'])
    xml = open("https://shopline.itau.com.br/shopline/consulta.aspx?DC=#{token}").read

    treat_itau_data xml    
  end
  
  private
    def treat_itau_data(dados)
      treated_data = {}

      response = REXML::Document.new(dados)
      params  = response.elements['consulta'].elements['PARAMETER']
      params.elements.each do |param|
        treated_data[param.attributes['ID']] = param.attributes['VALUE']
      end
      
      new_result = {}
      treated_data.each do |field, value|
        value = PAYMENT_METHODS[value] if field == 'tipPag'
        value = STATUS[PAYMENT_METHODS[treated_data['tipPag']]][value] if field == 'sitPag'        

        new_result[field] = value
      end
      
      new_result
    end
  
    def config
      # load file if is not loaded yet
      @@config ||= YAML.load_file(Rails.root.join("config/itau_shopline.yml"))

      # raise an exception if the environment hasn't been set
      # or if file is empty
      if @@config == false || !@@config[Rails.env]
        raise MissingEnvironmentError, ":#{Rails.env} environment not set on #{config_file.inspect}"
      end

      # retrieve the environment settings
      @@config[Rails.env]
    end # Load configuration file.
end
