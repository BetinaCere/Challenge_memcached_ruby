
module Funciones
    def buscar(i,comando_str,letra_fin)
        while comando_str[i] != letra_fin do
            i = i + 1
        end
        return i
    end

    def separar_variables(i, j, comando, letra_fin)
        i = buscar(i,comando,letra_fin)
        i = i - 1
        variable =comando [j..i] 
        i = i + 2
        j = i
        return i, j, variable
    end 
    def separar_3_variables(i, j, comando, letra_fin)
        i, j , variable_1 = separar_variables(i, j, comando, letra_fin)
        i, j , variable_2 = separar_variables(i, j, comando, letra_fin)
        i, j , variable_3 = separar_variables(i, j, comando, letra_fin)
        return i, j, variable_1, variable_2, variable_3
    end
    def traducir(j,comando,client)
        i = j
        i,j ,clave,flag,ttl = separar_3_variables(i, j, comando, " ")
        comienza_bytes=i # guardo desde donde comienza bytes por si se activa la opcion noreply
        i, j , bytes =separar_variables(i,j, comando, "\n")
        i = i - 3
        j= i - 7
        if comando[j..i]==" noreply"
            bytes = comando[comienza_bytes..j] 
            noreply_flag=1
        end
        valor = client.gets.chomp() # por ultimo se pregunta el valor que guarda la clave
    return clave, flag, ttl, bytes, valor,noreply_flag
    end
    def verificar_bytes(bytes,valor)
        return bytes.to_i == valor.length()
    end
end
