# -*- encoding: utf-8 -*-

class ItauCripto
  
  attr_reader :codEmp, :tipPag, :numPed
  
  CHAVE_ITAU = "SEGUNDA12345ITAU"
  TAM_COD_EMP = 26
  TAM_CHAVE = 16 
  
  def initialize
    @sbox = []
    @key = []
    @numPed = ''
    @tipPag = ''
    @codEmp = ''
    @dados = nil
  end
  
  def gera_dados(param_string1, param_string2, param_string3, param_string4, param_string5, param_string6, param_string7, param_string8, param_string9, param_string10, param_string11, param_string12, param_string13, param_string14, param_string15, param_string16, param_string17, param_string18)
    param_string1 = param_string1.upcase
    param_string5 = param_string5.upcase

  
    return "Erro: tamanho do codigo da empresa diferente de 26 posições." if param_string1.size != TAM_COD_EMP
    return "Erro: tamanho da chave da chave diferente de 16 posições." if param_string5.size != TAM_CHAVE
    return "Erro: número do pedido inválido." if param_string2.size < 1 || param_string2.size > 8
    
    if is_numeric(param_string2)
      param_string2 = preenche_zero(param_string2, 8)
    else
      return "Erro: numero do pedido não é numérico."
    end
      
    return "Erro: valor da compra inválido." if param_string3.size < 1 || param_string3.size > 11

    i = param_string3 =~ /,/
    if i
      str3 = param_string3[(i + 1)..-1]
    
      return "Erro: valor decimal não é numérico." if !is_numeric(str3)
      return "Erro: valor decimal da compra deve possuir 2 posições após a virgula." if str3.size != 2
      
      param_string3 = param_string3[0, (param_string3.size - 3)] + str3
    else
      return "Erro: valor da compra não é numérico." if !is_numeric(param_string3)
      return "Erro: valor da compra deve possuir no máximo 8 posições antes da virgula." if param_string3.size > 8

      param_string3 = param_string3 + "00"
    end
    
    param_string3 = preenche_zero(param_string3, 10)

    param_string7 = param_string7.strip
      
      
    return "Erro: código de inscrição inválido." if param_string7 != "02" && param_string7 != "01" && param_string7 != ""
    return "Erro: número de inscrição inválido." if param_string8 != "" && !is_numeric(param_string8) && param_string8.size > 14
    return "Erro: cep inválido." if param_string11 != "" && ( !is_numeric(param_string11) || param_string11.size != 8 )
    return "Erro: data de vencimento inválida." if param_string14 != "" && ( !is_numeric(param_string14) || param_string14.size != 8 )
    return "Erro: observação adicional 1 inválida." if param_string16.size > 60
    return "Erro: observação adicional 2 inválida." if param_string17.size > 60
    return "Erro: observação adicional 3 inválida." if param_string18.size > 60

    param_string4  = preenche_branco(param_string4, 40)
    param_string6  = preenche_branco(param_string6, 30)
    param_string7  = preenche_branco(param_string7, 2)
    param_string8  = preenche_branco(param_string8, 14)
    param_string9  = preenche_branco(param_string9, 40)
    param_string10 = preenche_branco(param_string10, 15)
    param_string11 = preenche_branco(param_string11, 8)
    param_string12 = preenche_branco(param_string12, 15)
    param_string13 = preenche_branco(param_string13, 2)
    param_string14 = preenche_branco(param_string14, 8)
    param_string15 = preenche_branco(param_string15, 60)
    param_string16 = preenche_branco(param_string16, 60)
    param_string17 = preenche_branco(param_string17, 60)
    param_string18 = preenche_branco(param_string18, 60)

    str1 = algoritmo(param_string2 + param_string3 + param_string4 + param_string6 + param_string7 + param_string8 + param_string9 + param_string10 + param_string11 + param_string12 + param_string13 + param_string14 + param_string15 + param_string16 + param_string17 + param_string18, param_string5)
    str2 = algoritmo(param_string1 + str1, CHAVE_ITAU)
    
    converte(str2)
  end
  
  def gera_cripto(param_string1, param_string2, param_string3)
    return "Erro: tamanho do codigo da empresa diferente de 26 posições." if param_string1.size != TAM_COD_EMP
    return "Erro: tamanho da chave da chave diferente de 16 posições." if param_string3.size != TAM_CHAVE
    
    param_string2 = param_string2.strip
    
    return "Erro: código do sacado inválido." if param_string2 == ""

    str1 = algoritmo(param_string2, param_string3)
    str2 = algoritmo(param_string1 + str1, CHAVE_ITAU)

    converte(str2)
  end
  
  def gera_consulta(param_string1, param_string2, param_string3, param_string4)
    return "Erro: tamanho do codigo da empresa diferente de 26 posições." if param_string1.size != TAM_COD_EMP
    return "Erro: tamanho da chave da chave diferente de 16 posições." if param_string4.size != TAM_CHAVE
    return "Erro: número do pedido inválido." if param_string2.size < 1 || param_string2.size > 8

    if is_numeric(param_string2)
      param_string2 = preenche_zero(param_string2, 8)
    else
      return "Erro: numero do pedido não é numérico."
    end
    
    return "Erro: formato inválido." if param_string3 != "0" && param_string3 != "1"

    str1 = algoritmo(param_string2 + param_string3, param_string4)

    str2 = algoritmo(param_string1 + str1, CHAVE_ITAU)

    converte(str2)
  end
  
  def decripto(param_string1, param_string2)
    param_string1 = desconverte(param_string1)

    str = algoritmo(param_string1, param_string2)

    {:cod_emp => str[0, 26], :num_ped => str[26, 8], :tip_pag => str[34, 2]}
  end
  
  def gera_dados_generico(param_string1, param_string2, param_string3)
    param_string1 = param_string1.upcase
    param_string3 = param_string3.upcase

  
    return "Erro: tamanho do codigo da empresa diferente de 26 posições." if param_string1.size != TAM_COD_EMP
    return "Erro: tamanho da chave da chave diferente de 16 posições." if param_string3.size != TAM_CHAVE
    return "Erro: sem dados." if param_string2.size < 1

    str1 = algoritmo(param_string2, param_string3)

    str2 = algoritmo(param_string1 + str1, CHAVE_ITAU)

    converte(str2)
  end
  
  #private

    def algoritmo(param_string1, param_string2)
      k = 0
      m = 0

      str = ""
      inicializa(param_string2)
      for j in 1..param_string1.size do
        k = (k + 1) % 256
        m = (m + @sbox[k]) % 256
        i = @sbox[k]
        @sbox[k] = @sbox[m]
        @sbox[m] = i

        n = @sbox[((@sbox[k] + @sbox[m]) % 256)]

        i1 = param_string1[j - 1].ord ^ n

        str = str + i1.chr
      end
      
      str
    end
      
    def preenche_zero(param_string, param_int)
      "%0#{param_int}d" % param_string
    end

    def is_numeric(param_string)
      param_string =~ /^[0-9]+$/
    end    
    
    def inicializa(param_string)
      m = param_string.size
      for j in 0..255 do
        @key[j] = param_string[j % m].ord
        @sbox[j] = j
      end

      k = 0
      for j in 0..255 do
        k = (k + @sbox[j] + @key[j]) % 256
        i = @sbox[j]
        @sbox[j] = @sbox[k]
        @sbox[k] = i
      end
    end    
    
    def preenche_branco(param_string, param_int)
      "%-#{param_int}s" % param_string    
    end

    def converte(param_string)
      c = (26.00 * rand + 65.00).to_i.chr
      str = c

      for i in 0..(param_string.size - 1) do
        
        k = param_string[i].ord
        j = k

        str = str + j.to_s
        c = (26.00 * rand + 65.00).to_i.chr
        str = str + c
      end

      str
    end    
    
    def desconverte(param_string)
      str1 = ""
      i = 0
      while i < param_string.size do
        str2 = ""

        c = param_string[i]
        puts c
        while c =~ /[0-9]/ do
          str2 = str2 + param_string[i]
          i += 1
          c = param_string[i]
        end
        
        str1 += str2.to_i.chr if str2 != ""
        
        i += 1        
      end

      str1
    end    
end
