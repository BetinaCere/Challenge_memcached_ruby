module Commands
    class Claves
        attr_accessor :flag, :nombre, :ttl,:bytes,:valor,:tse, :cas_token

        def initialize(nombre, flag, ttl,bytes,valor,cas_t_ultimo)
            @nombre = nombre
            @flag = flag
            #@flags = nill
            @last_edit = Time.new()
            @bytes= bytes
            @valor = valor
            @tse= @last_edit.hour*60 + @last_edit.min + @last_edit.sec#time since edited
            @cas_token = cas_t_ultimo.to_i  #falta ver si algun otro tiene este numero de cas y si llega rand a + de 64 
            comparacion = ttl.to_i > 2592000      
            if comparacion
                ttl_nuevo= ttl.to_i - @tse
                @ttl= ttl_nuevo
            else
                @ttl =ttl
            end
        end
        
    end
    
     #Guardo las claves en el diccionario claves (hash)
    Keys={}
    def variables_clase_claves(clave)
        key_nombre = Keys[clave].nombre
        key_flag = Keys[clave].flag
        key_bytes = Keys[clave].bytes
        key_valor = Keys[clave].valor
        return key_nombre, key_flag, key_bytes, key_valor
    end
    def cas_t_mas__uno(cas_t_ultimo)
        cas_t_ultimo = cas_t_ultimo.to_i + 1
        #digitos_cas = cas_t_ultimo.digits.count
        #if digitos_cas == 8
        #    cas_t_ultimo = 0
        #end
        return cas_t_ultimo
    end
    def actualizo_ttl(ttl,clave)
        if ttl.to_i < 2592000
            ttl = ttl # time to live
        elsif
            time_now=Time.new #tiempo desde el instante que se edita hasta 1 enero 1970
            time_now_sec= time_now.hour*60 + time_now.min + time_now.sec
            ttl_nuevo= ttl.to_i - time_now_sec
            ttl= ttl_nuevo
        end
        return ttl
    end
    #######################################################################
    ####################      GET        ##################################
    #######################################################################
    def get(clave,client)
        condicion = Keys.include? clave
            if condicion
                # guardo en variables internas de la clase Claves para imprimirlas
                key_nombre, key_flag, key_bytes, key_valor=variables_clase_claves(clave)
                client.puts "VALUE " + key_nombre + " " + key_flag.to_s + " " + key_bytes.to_s + "\n" + key_valor + "\r"
                client.puts "END" 
                return Keys[clave]             
            elsif 
                client.puts "END" #devuelvo end si no esta en el hash la clave
            end
        return 0 
    end
    #######################################################################
    ####################      GETS       ##################################
    #######################################################################
    def gets(clave,client)
       condicion = Keys.include? clave
        if condicion
            # guardo en variables internas de la clase Claves para imprimirlas
            key_nombre, key_flag, key_bytes, key_valor=variables_clase_claves(clave)
            key_cas_token = Keys[clave].cas_token
            # imprimo los datos requeridos
            client.puts "VALUE " + key_nombre + " " + key_flag.to_s + " " + key_bytes.to_s + " "+ key_cas_token.to_s + "\n" + key_valor + "\r"
            client.puts "END\r" 
            return Keys[clave]
        elsif 
           client.puts "END\r" #devuelvo end si no esta en el hash la clave
        end
        return 0 
    end
    #######################################################################
    ####################      SET        ##################################
    #######################################################################
    def set(clave_set, flag_set, ttl_set, bytes_set, valor_set,cas_t_ultimo, bytes_totales,noreply_flag,client)
    # agrego la clave aunque ya exista
        clave_i= Claves.new(clave_set.to_s, flag_set, ttl_set, bytes_set,valor_set,cas_t_ultimo) #creo la variable
        Keys[clave_set]= clave_i # se guarda dos veces?
        cas_t_ultimo= cas_t_mas__uno(cas_t_ultimo)
        bytes_totales = bytes_totales + bytes_set.to_i
        if noreply_flag.to_i != 1
            client.puts "STORED\r"
        end
        return cas_t_ultimo ,bytes_totales

    end
    #######################################################################
    ####################      ADD        ##################################
    #######################################################################
    def add(clave, flag,ttl,bytes,valor,cas_t_ultimo,bytes_totales,noreply_flag,client)
        condicion = Keys.include? clave
        if !condicion
            clave_i= Claves.new(clave.to_s, flag, ttl,bytes,valor,cas_t_ultimo) #creo la vari able
            Keys[clave]= clave_i 
            cas_t_ultimo= cas_t_mas__uno(cas_t_ultimo)
            bytes_totales = bytes_totales + bytes.to_i
            if noreply_flag.to_i != 1
                client.puts "STORED\r"
            end
            return cas_t_ultimo ,bytes_totales
        elsif
            if noreply_flag.to_i != 1
                client.puts "NOT_STORED\r"
            end 
        end
        return cas_t_ultimo  ,bytes_totales   
    end
    #######################################################################
    ####################      REPLACE    ##################################
    #######################################################################
    def replace(clave, flag, ttl, bytes, nuevovalor,cas_t_ultimo,bytes_totales,noreply_flag, client)
        condicion = Keys.include? clave
            if condicion
                bytes_antiguos=Keys[clave].bytes
                Keys[clave].flag= flag
                Keys[clave].bytes=bytes
                actualizo_ttl(ttl,clave)
                Keys[clave].ttl=ttl
                Keys[clave].valor = nuevovalor
                Keys[clave].cas_token = cas_t_ultimo
                cas_t_ultimo= cas_t_mas__uno(cas_t_ultimo)
                bytes_totales = bytes_totales.to_i + bytes.to_i - bytes_antiguos.to_i
                if noreply_flag.to_i != 1
                    client.puts "STORED\r"
                end     
            elsif 
                if noreply_flag.to_i != 1
                    client.puts "NOT_STORED\r"
                end  #devuelvo "NOT_STORED" si no esta en el hash la clave
            end
        return cas_t_ultimo ,bytes_totales
    end
    #######################################################################
    ####################      APPEND     ##################################
    #######################################################################
    def append(clave, flag, ttl,bytes,valor,cas_t_ultimo,bytes_totales,noreply_flag,client)
        condicion = Keys.include? clave
        if condicion
            key_valor = Keys[clave].valor
            # append no cambia ni flags ni ttl
            Keys[clave].valor = key_valor.to_s + valor.to_s # agrego informacion al final
            Keys[clave].cas_token = cas_t_ultimo
            Keys[clave].bytes = Keys[clave].bytes.to_i + bytes.to_i
            bytes_totales = bytes_totales.to_i + bytes.to_i
            cas_t_ultimo= cas_t_mas__uno(cas_t_ultimo)
            if noreply_flag.to_i != 1
                client.puts "STORED\r"
            end 
            return cas_t_ultimo ,bytes_totales
        end
        if noreply_flag.to_i != 1
            client.puts "NOT_STORED\r"
        end 
        return cas_t_ultimo ,bytes_totales
    end
    #######################################################################
    ####################   PREPEND       ##################################
    #######################################################################
    def prepend(clave_prep, flag,ttl,bytes,valor,cas_t_ultimo,bytes_totales,noreply_flag,client)
        condicion = Keys.include? clave_prep
        if condicion
            key_valor = Keys[clave_prep].valor
            # prepend no cambia ni flags ni ttl
            Keys[clave_prep].valor =  valor.to_s + key_valor.to_s # agrego informacion al principio
            Keys[clave_prep].cas_token = cas_t_ultimo
            Keys[clave_prep].bytes = Keys[clave_prep].bytes.to_i + bytes.to_i
            bytes_totales = bytes_totales.to_i + bytes.to_i
            cas_t_ultimo= cas_t_mas__uno(cas_t_ultimo)
            if noreply_flag.to_i != 1
                client.puts "STORED\r"
            end 
            return  cas_t_ultimo, bytes_totales
        end
        if noreply_flag.to_i != 1
            client.puts "NOT_STORED\r"
        end 
        return cas_t_ultimo, bytes_totales
    end
    #######################################################################
    ##################      CAS      ######################################
    #######################################################################
    def cas(clave, flag, ttl,bytes,valor,cas,cas_t_ultimo,bytes_totales,noreply_flag,client)
        condicion = Keys.include? clave
        if condicion
            if Keys[clave].cas_token == cas.to_i
                cas_t_ultimo,bytes_totales=replace(clave, flag, ttl, bytes, valor,cas_t_ultimo,bytes_totales,noreply_flag,client)
                return cas_t_ultimo, bytes_totales
            elsif
                if noreply_flag.to_i != 1
                    client.puts "EXISTS\r"
                end 
                return cas_t_ultimo ,bytes_totales
            end
        else
            if noreply_flag.to_i != 1
                client.puts "NOT_FOUND\r"
            end 
            return cas_t_ultimo ,bytes_totales
        end
    end
    
    def declutter_claves()
            Keys.each_key  do |clave| 
                ttl_c = Keys[clave].ttl
                tse_c = Keys[clave].tse
                if (ttl_c == 1) || (tse_c > ttl_c.to_i)
                    Keys.delete(clave)
                end
            end
        return 0
    end

end