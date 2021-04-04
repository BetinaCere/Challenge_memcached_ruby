require_relative "lib/commands.rb"
include Commands
require_relative "lib/funciones.rb"
include Funciones
require 'socket'

server = TCPServer.new 2000
cas_t_ultimo = 0
bytes_totales=0
#require_relative "tests.rb"
loop do
    Thread.start(server.accept) do |client|   ## uso Tread para poder tener varios clientes a la vez
        loop do
            comando = client.gets()
            declutter_claves()
            noreply_flag=0
            case comando[0..2]
            when "get"
                if comando[3] == " " #comando get
                    j=4
                    i = buscar(j,comando,"\n")
                    clave = comando[j..i].chomp()
                    get(clave,client)
                elsif comando[3] == "s" #comando gets
                    j=5
                    i = buscar(j,comando,"\n")
                    clave = comando[j..i].chomp()
                    gets(clave,client)
                else
                    client.puts "ERROR\r"
                end
                next   
            when"set"
                if comando[3] == " "
                    i=4
                    clave,flag,ttl,bytes,valor,noreply_flag = traducir(i,comando,client)
                    if verificar_bytes(bytes,valor)
                        cas_t_ultimo ,bytes_totales=set(clave.chomp,flag.chomp,ttl.chomp,bytes.chomp,valor,cas_t_ultimo.to_i ,bytes_totales,noreply_flag,client)
                    else
                        client.puts "CLIENT_ERROR bad data chunk"
                    end
                else
                    client.puts "ERROR\r"
                end  
                next
            when"add"
                if comando[3] == " "
                    i=4
                    clave,flag,ttl,bytes,valor,noreply_flag= traducir(i,comando,client)
                    if verificar_bytes(bytes,valor)
                        cas_t_ultimo ,bytes_totales= add(clave.chomp,flag.chomp,ttl.chomp,bytes.chomp,valor,cas_t_ultimo.to_i,bytes_totales,noreply_flag,client)
                    else
                        client.puts "CLIENT_ERROR bad data chunk\r"
                    end
                else
                    client.puts "ERROR\r"
                end
                next
            when "rep"
                if comando[3..7]=="lace "
                    i = 8
                    clave,flag,ttl,bytes,valor,noreply_flag= traducir(i,comando,client)
                    if verificar_bytes(bytes,valor)
                        cas_t_ultimo,bytes_totales= replace(clave, flag, ttl, bytes.chomp,valor,cas_t_ultimo.to_i, bytes_totales,noreply_flag,client)
                    else
                        client.puts "CLIENT_ERROR bad data chunk\r"
                    end
                else
                    client.puts "ERROR\r"
                end
                next
            when"app"
                if comando[3..5]=="end"
                    i=7
                    clave,flag,ttl,bytes,valor,noreply_flag= traducir(i,comando,client)
                    if verificar_bytes(bytes,valor)
                        cas_t_ultimo ,bytes_totales= append(clave.chomp,flag.chomp,ttl.chomp,bytes.chomp,valor,cas_t_ultimo.to_i,bytes_totales,noreply_flag,client)
                    else
                        client.puts "CLIENT_ERROR bad data chunk\r"
                    end
                else
                    client.puts "ERROR\r"
                end
                next
            when "pre"
                if comando[3..6]=="pend"
                    i=8
                    clave,flag,ttl,bytes,valor,noreply_flag= traducir(i,comando,client)                    
                    if verificar_bytes(bytes,valor)
                        cas_t_ultimo ,bytes_totales= prepend(clave.chomp,flag.chomp,ttl.chomp,bytes.chomp,valor,cas_t_ultimo.to_i,bytes_totales,noreply_flag,client)
                    else
                        client.puts "CLIENT_ERROR bad data chunk\r"
                    end
                else
                    client.puts "ERROR\r"
                end
                next
            when "cas" 
                if comando[3] == " "
                    i = 4
                    j = i
                    i, j , clave, flag, ttl, bytes, cas, comienza_bytes,termina_bytes= separar_variables_cas(i,j,comando)
                    if comando[j..i]==" noreply"
                        bytes = comando[comienza_bytes..termina_bytes] 
                        noreply_flag=1
                    end
                    valor = client.gets.chomp() 
                    if verificar_bytes(bytes,valor)
                        cas_t_ultimo ,bytes_totales= cas(clave, flag, ttl, bytes.chomp,valor,cas,cas_t_ultimo.to_i,bytes_totales,noreply_flag, client)
                    else
                        client.puts "CLIENT_ERROR bad data chunk\r"
                    end
                else
                    client.puts "ERROR\r"
                end
                next
            when "qui"
                if comando[3].to_s == "t" 
                    client.close
                else
                    client.puts "ERROR\r"
                end
                next
            else
                client.puts "ERROR\r"
            end
        end
    end
end