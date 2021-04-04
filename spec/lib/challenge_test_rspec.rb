require "spec_helper"
require 'socket'
require_relative "funciones.rb"
include Funciones
require "commands.rb"
include Commands
socket = TCPSocket.new 'localhost', 2000

describe Claves do
    clave_i= Claves.new("clave", "1", "10","5","valor","1") #expectation
    it "nombre" do
        expect(clave_i.nombre ).to eq("clave")
    end
    it "1" do
        expect(clave_i.flag ).to eq("1")
    end
    it "ttl" do
        expect(clave_i.ttl ).to eq("10")
    end
    it "byte" do
        expect(clave_i.bytes ).to eq("5")
    end
    it "valor" do
        expect(clave_i.valor ).to eq("valor")
    end
    it "cas" do
        cas_tok =clave_i.cas_token  #expectation
        expect(cas_tok.to_s).to eq("1")
    end
end

#######################################################################
################       Test SET       #################################
#######################################################################
##    agregrego una clave no existente           ##"

describe "set" do
    set_1 = "set key_set 3 2591999 9\r\n"
    set_valor_1="clave_set\r"
    socket.puts set_1
    socket.puts set_valor_1
    resultado_set_0= socket.gets()
    it "veo si la calve se guardo" do
        expect(resultado_set_0).to eq("STORED\r\n")
    end
end
# veo si se guardo bien

describe "get" do
    get_set_0="get key_set"
    socket.puts get_set_0
    resultado_get_set_01= socket.gets()
    resultado_get_set_02= socket.gets()
    resultado_get_set_03= socket.gets()
    it "##    busco una clave existente      ##" do
        expect(resultado_get_set_01).to eq("VALUE key_set 3 9\n")
        expect(resultado_get_set_02).to eq("clave_set\r\n")
        expect(resultado_get_set_03).to eq("END\n")
    end
end
##    agregrego una clave existente           ##"

describe "set" do
    set_1="set key_set 2 77777 10\r\n"
    set_valor_1="clave_set2\r"
    socket.puts set_1
    socket.puts set_valor_1
    resultado_set_1= socket.gets()
    it "veo que quede guardada la clave" do
        expect(resultado_set_1).to eq("STORED\r\n")
    end
end
# veo si se guardo bien (si modifico a la anterior)

describe "get" do
    get_set="get key_set"
    socket.puts get_set
    resultado_get_set_1= socket.gets()
    resultado_get_set_2= socket.gets()
    resultado_get_set_3= socket.gets()
    it "##    busco una clave existente      ##" do
        expect(resultado_get_set_1).to eq("VALUE key_set 2 10\n")
        expect(resultado_get_set_2).to eq("clave_set2\r\n")
        expect(resultado_get_set_3).to eq("END\n")
    end
end


describe "set" do
    ##    agregrego una clave con bytes != valor.lenght()           ##
    set_2="set key_set 10 66655 8\r\n"
    set_valor_2 ="set\r"
    socket.puts set_2
    socket.puts set_valor_2
    resultado_set_2= socket.gets()
    it "uso get en una clave no existente" do
        expect(resultado_set_2).to eq("CLIENT_ERROR bad data chunk\n")
    end
end
##    agregrego una clave no existente   con no_reply       ##
set_3="set key_set_2 2 77777 4 noreply\r\n"
set_valor_3 ="set2\r"
socket.puts set_3
socket.puts set_valor_3



#######################################################################
################       Test ADD       #################################
#######################################################################

describe "add" do
    add_1="add key_add 1 25544755 3\r\n"
    add_valor_1 ="add\r"
    socket.puts add_1
    socket.puts add_valor_1
    resultado_add_0= socket.gets()
    it "uso add en una clave no existente" do
        expect(resultado_add_0).to eq("STORED\r\n")
    end
end
# veo si se guardo bien
describe "get" do
    get_add="get key_add"
    socket.puts get_add
    resultado_get_add_1= socket.gets()
    resultado_get_add_2= socket.gets()
    resultado_get_add_3= socket.gets()
    it "##    busco una clave existente      ##" do
        expect(resultado_get_add_1).to eq("VALUE key_add 1 3\n")
        expect(resultado_get_add_2).to eq("add\r\n")
        expect(resultado_get_add_3).to eq("END\n")
    end
end


describe "add" do
    add_1="add key_add 2 77777 2\r\n"
    add_valor_1 ="v2\r"
    socket.puts add_1
    socket.puts add_valor_1
    resultado_add_1= socket.gets()
    it "uso add en una clave existente" do
        expect(resultado_add_1).to eq("NOT_STORED\r\n")
    end
end


describe "add" do
    add_2="add key_add 10 66655 8\r\n"
    add_valor_2 ="v\r"
    socket.puts add_2
    socket.puts add_valor_2
    resultado_add_2= socket.gets()
    it " agregrego una clave con bytes != valor.lenght()" do
        expect(resultado_add_2).to eq("CLIENT_ERROR bad data chunk\r\n")
    end
end

#agrego una clave que no existe con no reply
add_1="add key_add_2 2 77777 2 noreply\r\n" ### noreply
add_valor_1 ="v2\r"
socket.puts add_1
socket.puts add_valor_1
# veo que se haya agregado bien por mas que no se imprima el resultado
describe "get" do
    get_add="get key_add_2"
    socket.puts get_add
    resultado_get_add_1= socket.gets()
    resultado_get_add_2= socket.gets()
    resultado_get_add_3= socket.gets()
    it "##    busco una clave existente      ##" do
        expect(resultado_get_add_1[0..18]).to eq("VALUE key_add_2 2 2")
        expect(resultado_get_add_2[0..1]).to eq("v2")
        expect(resultado_get_add_3[0..2]).to eq("END")
    end
end
#intento agregar una que existe con no reply
add_2="add key_add 2 77777 2 noreply\r\n"
add_valor_2 ="v2\r"
socket.puts add_2
socket.puts add_valor_2

describe "get_add" do
    get_add="get key_add"
    socket.puts get_add
    resultado_get_add_1= socket.gets()
    resultado_get_add_2= socket.gets()
    resultado_get_add_3= socket.gets()
    #me tiene que devolver el valor anterior sin la modificacion
    it "##    busco una clave existente      ##" do
       expect(resultado_get_add_1[0..16]).to eq("VALUE key_add 1 3")
       expect(resultado_get_add_2[0..2]).to eq("add")
       expect(resultado_get_add_3[0..2]).to eq("END")
    end
end
#######################################################################
################       Test GET       #################################
#######################################################################

describe "get" do
    get_1="get key_get"
    socket.puts get_1
    resultado_get_0= socket.gets()
    it "##    busco una clave no existente      ##" do
       expect(resultado_get_0[0..2]).to eq("END")
    end
end

describe "get" do
    get_2="get key_add"
    socket.puts get_2
    resultado_get_1= socket.gets()
    resultado_get_2= socket.gets()
    resultado_get_3= socket.gets()
    it "##    busco una clave existente      ##" do
        expect(resultado_get_1[0..16]).to eq("VALUE key_add 1 3")
        expect(resultado_get_2[0..2]).to eq("add")
        expect(resultado_get_3[0..2]).to eq("END")
    end
end

######################################################################
################       Test GETS       #################################
#######################################################################

describe "gets" do
    gets_1="gets key_get"
    socket.puts gets_1
    resultado_gets_0= socket.gets()
    it "##    busco una clave no existente      ##" do
        expect(resultado_gets_0[0..2]).to eq("END")
    end
end

describe "gets" do
    gets_2="gets key_add"
    socket.puts gets_2
    resultado_gets_1= socket.gets()
    resultado_gets_2= socket.gets()
    resultado_gets_3= socket.gets()
    it "##    busco una clave existente      ##" do
        expect(resultado_gets_1).to eq("VALUE key_add 1 3 3\n")
        expect(resultado_gets_2).to eq("add\r\n")
        expect(resultado_gets_3).to eq("END\r\n")
    end
end
#######################################################################
####################   TEST   REPLACE   ###############################
#######################################################################

describe "replace" do
    replace_1="replace key_replace 1 25555 1\r\n"
    replace_valor_1 ="r\r"
    socket.puts replace_1
    socket.puts replace_valor_1
    resultado_replace_0= socket.gets()
    it "##    remplazo informacion a una una clave no existente           ##" do
        expect(resultado_replace_0).to eq("NOT_STORED\r\n")
    end
end


describe "replace" do
    replace_2="replace key_add 7 44485444544 3\r\n"
    replace_valor_2 ="rep\r"
    socket.puts replace_2
    socket.puts replace_valor_2
    resultado_replace_1= socket.gets()
    it "##    remplazo informacion a una una clave  existente           ##" do
        expect(resultado_replace_1).to eq("STORED\r\n")
    end
end
#antes ya se le hizo un get a key_add, hay que ver si se cambiaron los valores

describe "get_replace" do
    get_replace_0="get key_add"
    socket.puts get_replace_0
    resultado_get_r_1= socket.gets()
    resultado_get_r_2= socket.gets()
    resultado_get_r_3= socket.gets()
    it "##    busco una clave existente      ##" do
        expect(resultado_get_r_1).to eq("VALUE key_add 7 3\n")
        expect(resultado_get_r_2).to eq("rep\r\n")
        expect(resultado_get_r_3).to eq("END\n")
    end
end

describe "replace" do
    replace_3="replece key_add 1 25557445 6\r\n"
    socket.puts replace_3
    resultado_replace_2= socket.gets()
    it "##    error en la escritura comando replace          ##" do
        expect(resultado_replace_2).to eq("ERROR\r\n")
    end
end

describe "replace" do
    replace_3="replace key_add 1 25555 2\r\n"
    replace_valor_3 ="replace\r"
    socket.puts replace_3
    socket.puts replace_valor_3
    resultado_replace_3= socket.gets()
    it "##    error en la escritura bytes != valor.lenght()          ##" do
        expect(resultado_replace_3).to eq("CLIENT_ERROR bad data chunk\r\n")
    end
end

#intento reemplazar una clave que existe con no reply
describe "get_replace_noreply" do
    replace_4="replace key_set 1 44485444544 7 noreply\r\n"
    replace_valor_4 ="replace\r"
    socket.puts replace_4
    socket.puts replace_valor_4
    #ahora veo que se haya cambiado correctamente
    get_replace_0="get key_set"
    socket.puts get_replace_0
    resultado_get_rep_1= socket.gets()
    resultado_get_rep_2= socket.gets()
    resultado_get_rep_3= socket.gets()
    it "##    busco una clave existente      ##" do
        expect(resultado_get_rep_1[0...17]).to eq("VALUE key_set 1 7")
        expect(resultado_get_rep_2[0..6]).to eq("replace")
        expect(resultado_get_rep_3).to eq("END\n")
    end
end
#intento reemplazar una clave que no existe con no reply
describe "get_replace_noreply" do
    replace_4="replace key_rep 1 44485444544 7 noreply\r\n"
    replace_valor_4 ="replace\r"
    socket.puts replace_4
    socket.puts replace_valor_4
    #ahora veo que se haya cambiado correctamente
    get_replace_0="get key_rep"
    socket.puts get_replace_0
    resultado_get_rep_4= socket.gets()
    it "##    busco una clave no existente      ##" do
        expect(resultado_get_rep_4).to eq("END\n")
    end
end
#######################################################################
####################   TEST   APPEND    ###############################
#######################################################################

#ys se le hizo un get a key_append previo

describe "append" do
    append_1="append key_add 1 255485155 6\r\n"
    append_valor_1 ="append\r"
    socket.puts append_1
    socket.puts append_valor_1
    resultado_append_1= socket.gets()
    it "##    agregrego informacion a una una clave  existente           ##" do
        expect(resultado_append_1).to eq("STORED\r\n")
    end
end
describe "get_append" do
    get_append_0="get key_add"
    socket.puts get_append_0
    resultado_get_app_1= socket.gets()
    resultado_get_app_2= socket.gets()
    resultado_get_app_3= socket.gets()
    it "##    busco una clave existente      ##" do
        expect(resultado_get_app_1).to eq("VALUE key_add 7 9\n") #tienen que ser nueve bytes porque se le suman 6 a 3
        expect(resultado_get_app_2).to eq("repappend\r\n") # rep + append
        expect(resultado_get_app_3).to eq("END\n")
    end
end

describe "append" do
    append_1="append key_append 1 255558751 6\r\n"
    append_valor_1 ="append\r"
    socket.puts append_1
    socket.puts append_valor_1
    resultado_append_2= socket.gets()
    it "##    agregrego informacion a una una clave no existente           ##" do
        expect(resultado_append_2).to eq("NOT_STORED\r\n")
    end
end

describe "append" do
    append_1="apperd key_add 1 25555 6\r\n"
    socket.puts append_1
    resultado_append_3= socket.gets()
    it "##    error en la escritura comando append           ##"do
        expect(resultado_append_3).to eq("ERROR\r\n")
    end
end
#intento usar append una clave que existe con no reply
describe "get_append_noreply" do
    app_4="append key_set 1 44485444544 3 noreply\r\n"
    app_valor_4 ="app\r"
    socket.puts app_4
    socket.puts app_valor_4
    #ahora veo que se haya cambiado correctamente
    get_replace_0="get key_set"
    socket.puts get_replace_0
    resultado_get_app_1= socket.gets()
    resultado_get_app_2= socket.gets()
    resultado_get_app_3= socket.gets()
    it "##    busco una clave existente      ##" do
        expect(resultado_get_app_1[0...18]).to eq("VALUE key_set 1 10")
        expect(resultado_get_app_2[0..9]).to eq("replaceapp")
        expect(resultado_get_app_3).to eq("END\n")
    end
end
#intento append una clave que no existe con no reply
describe "get_append_noreply" do
    app_4="append key_app 1 44485444544 3 noreply\r\n"
    app_valor_4 ="app\r"
    socket.puts app_4
    socket.puts app_valor_4
    #ahora veo que se haya cambiado correctamente
    get_app_0="get key_app"
    socket.puts get_app_0
    resultado_get_app_4= socket.gets()
    it "##    busco una clave no existente      ##" do
       expect(resultado_get_app_4).to eq("END\n")
    end
end
#######################################################################
####################   TEST   PREPEND    ##############################
#######################################################################

describe "prepend" do
    prepend_1="prepend key_add 1 255485155 6\r\n"
    prepend_valor_1 ="prepen\r"
    socket.puts prepend_1
    socket.puts prepend_valor_1
    resultado_prepend_1= socket.gets()
    
    it "##    agregrego informacion a una una clave  existente           ##"do
        expect(resultado_prepend_1).to eq("STORED\r\n")
    end
end
describe "get_prep" do
    get_prepend_0="get key_add"
    socket.puts get_prepend_0
    resultado_get_pre_1= socket.gets()
    resultado_get_pre_2= socket.gets()
    resultado_get_pre_3= socket.gets()
    it "##    busco una clave existente      ##" do
        expect(resultado_get_pre_1).to eq("VALUE key_add 7 15\n") #tienen que ser 15 bytes porque se le suman 6 a 9
        expect(resultado_get_pre_2).to eq("prepenrepappend\r\n") # prepen + rep + append
        expect(resultado_get_pre_3).to eq("END\n")
    end
end


describe "prepend" do
    prepend_2="prepend key_prpend 1 48755 7\r\n"
    prepend_valor_2 ="prepend\r"
    socket.puts prepend_2
    socket.puts prepend_valor_2
    resultado_prepend_2= socket.gets()
    it "##    agregrego informacion a una una clave no existente       ##"do
        expect(resultado_prepend_2).to eq("NOT_STORED\r\n")
    end
end


describe "prepend" do
    prepend_3="preper key_add 1 3355 7\r\n"
    socket.puts prepend_3
    resultado_prepend_3= socket.gets()
    it "##    error en la escritura comando prepend           ##"do
        expect(resultado_prepend_3).to eq("ERROR\r\n")
    end
end


#intento usar prepend una clave que existe con no reply
describe "get_prep_noreply" do
    prep_4="prepend key_set 1 44485444544 3 noreply\r\n"
    prep_valor_4 ="pre\r"
    socket.puts prep_4
    socket.puts prep_valor_4
    #ahora veo que se haya cambiado correctamente
    get_prep_0="get key_set"
    socket.puts get_prep_0
    resultado_get_pre_1= socket.gets()
    resultado_get_pre_2= socket.gets()
    resultado_get_pre_3= socket.gets()
    it "##    busco una clave existente      ##" do
        expect(resultado_get_pre_1[0...18]).to eq("VALUE key_set 1 13")
        expect(resultado_get_pre_2[0..12]).to eq("prereplaceapp")
        expect(resultado_get_pre_3).to eq("END\n")
    end
end
#intento prepend una clave que no existe con no reply
describe "get_prep_noreply" do
    prep_4="prepend key_pre 1 44485444544 3 noreply\r\n"
    prep_valor_4 ="pre\r"
    socket.puts prep_4
    socket.puts prep_valor_4
    #ahora veo que se haya cambiado correctamente
    get_prep_0="get key_app"
    socket.puts get_prep_0
    resultado_get_pre_4= socket.gets()
    it "##    busco una clave no existente      ##" do
       expect(resultado_get_pre_4).to eq("END\n")
    end
end


#######################################################################
####################   TEST  CAS      #################################
#######################################################################


describe "cas" do
    cas_1="cas key_cas 1 25555 1 1\r\n"
    valor_cas_1 ="r\r"
    socket.puts cas_1
    socket.puts valor_cas_1
    resultado_cas_0= socket.gets()
    it "##    remplazo informacion a una una clave no existente           ##" do
        expect(resultado_cas_0).to eq("NOT_FOUND\r\n")
    end
end



##    busco una clave existente a travex de gets para conseguir cas_token    ##"
gets_2="gets key_add"
socket.puts gets_2
resultado_1= socket.gets()
resultado= socket.gets()
resultado= socket.gets()
i=0
j=i
i , j, value,clave,flag = separar_3_variables(i, j, resultado_1, " ")
i,j, bytes = separar_variables(i, j, resultado_1, " ")
i, j , cas =separar_variables(i,j, resultado_1, "\n")

describe "cas" do
    cas_2="cas key_add 7 44485444544 3 #{cas} \r\n"
    cas_valor_2 ="cas\r"
    socket.puts cas_2
    socket.puts cas_valor_2
    resultado_cas_1= socket.gets()
    it "##    remplazo una clave existente la cual no ha sido reemplazada antes     ##" do
        expect(resultado_cas_1).to eq("STORED\r\n")
    end
end
describe "get_cas" do
    get_cas_0="get key_add"
    socket.puts get_cas_0
    resultado_get_cas_1= socket.gets()
    resultado_get_cas_2= socket.gets()
    resultado_get_cas_3= socket.gets()
    it "##    busco una clave existente      ##" do
        expect(resultado_get_cas_1).to eq("VALUE key_add 7 3\n") 
        expect(resultado_get_cas_2).to eq("cas\r\n") # recien se modifico a cas
        expect(resultado_get_cas_3).to eq("END\n")
    end
end


describe "cas" do
    cas_3="ces key_add 1 25557445 6\r\n"
    socket.puts cas_3
    resultado_cas_4_0= socket.gets()
    it "##    error en la escritura comando cas         ##" do
        expect(resultado_cas_4_0).to eq("ERROR\r\n")
    end
end

describe "cas" do
    cas_4="cas key_add 1 25555 2 #{cas}\r\n"
    cas_valor_4 ="replace\r"
    socket.puts cas_4
    socket.puts cas_valor_4
    resultado_cas_5_0= socket.gets()
    it "##    error en la escritura bytes != valor.lenght()          ##" do
        expect(resultado_cas_5_0).to eq("CLIENT_ERROR bad data chunk\r\n")
    end
end
#intento prepend una clave queexiste con no reply
describe "cas" do
    cas_5="cas key_add 1 25555 6 11 noreply\r\n"
    cas_valor_5 ="cas_nr\r"
    socket.puts cas_5
    socket.puts cas_valor_5
    #ahora veo que se haya cambiado correctamente
    get_cas_1="get key_add"
    socket.puts get_cas_1
    resultado_get_cas_4= socket.gets()
    resultado_get_cas_5= socket.gets()
    resultado_get_cas_6= socket.gets()
    it "##    busco una clave existente      ##" do
        expect(resultado_get_cas_4).to eq("VALUE key_add 1 6\n") 
        expect(resultado_get_cas_5).to eq("cas_nr\r\n") # recien se modifico a cas
        expect(resultado_get_cas_6).to eq("END\n")
    end
end
#intento prepend una clave que no existe con no reply
describe "get_cas_noreply" do
    cas_4="cas key_cas 1 44485444544 3 1 noreply\r\n"
    cas_valor_4 ="cas\r"
    socket.puts cas_4
    socket.puts cas_valor_4
    #ahora veo que se haya cambiado correctamente
    get_cas_0="get key_cas"
    socket.puts get_cas_0
    resultado_get_cas_7= socket.gets()
    it "##    busco una clave no existente      ##" do
      expect(resultado_get_cas_7[0..2]).to eq("END")
    end
end
#######################################################################
############   TEST  DECLUTTER KEYS (TTL)      ########################
#######################################################################

#agrego una clave con un ttl muy chico y veo si cuando uso get sigue ahi

d_keys_1="add d_key 2 1 2 noreply\r\n"
d_key_valor_1 ="v2\r"
socket.puts d_keys_1
socket.puts d_key_valor_1
# veo que se haya agregado bien por mas que no se imprima el resultado
describe "get" do
    get_d_keys="get d_key"
    socket.puts get_d_keys
    resultado_get_d_keys_3= socket.gets()
    it "##    busco una clave existente      ##" do
        expect(resultado_get_d_keys_3).to eq("END\n") # si la clave siguiera activa devoveria VALUE .....
    end
end

get_socket= "getD key_socket"
#veo si puedo tener muchos clientes a la vez con el mismo servidor y que estos puedan interactuar con el mismo
# pongo un comando que de error de prueba
socket_1 = TCPSocket.new 'localhost', 2000
socket_1.puts get_socket
socket_2 = TCPSocket.new 'localhost', 2000
socket_2.puts get_socket
socket_3 = TCPSocket.new 'localhost', 2000
socket_3.puts get_socket
socket_4 = TCPSocket.new 'localhost', 2000
socket_4.puts get_socket
socket_5 = TCPSocket.new 'localhost', 2000
socket_5.puts get_socket
socket_6 = TCPSocket.new 'localhost', 2000
socket_6.puts get_socket
socket_7 = TCPSocket.new 'localhost', 2000
socket_7.puts get_socket
socket_8 = TCPSocket.new 'localhost', 2000
socket_8.puts get_socket
socket_9 = TCPSocket.new 'localhost', 2000
socket_9.puts get_socket
socket_10 = TCPSocket.new 'localhost', 2000
socket_10.puts get_socket
socket_11= TCPSocket.new 'localhost', 2000
socket_11.puts get_socket
socket_12= TCPSocket.new 'localhost', 2000
socket_12.puts get_socket
describe "sockets" do
    resultado_s_1= socket_1.gets()
    it "##    veo que el socket reciba bien la informacion ##" do
        expect(resultado_s_1[0..4]).to eq("ERROR") # si la clave siguiera activa devoveria VALUE .....
    end
    resultado_s_2= socket_2.gets()
    it "##    veo que el socket reciba bien la informacion ##" do
        expect(resultado_s_2[0..4]).to eq("ERROR") # si la clave siguiera activa devoveria VALUE .....
    end
    resultado_s_3= socket_3.gets()
    it "##    veo que el socket reciba bien la informacion ##" do
        expect(resultado_s_3[0..4]).to eq("ERROR") # si la clave siguiera activa devoveria VALUE .....
    end
    resultado_s_4= socket_4.gets()
    it "##    veo que el socket reciba bien la informacion ##" do
        expect(resultado_s_4[0..4]).to eq("ERROR") # si la clave siguiera activa devoveria VALUE .....
    end
    resultado_s_5= socket_5.gets()
    it "##    veo que el socket reciba bien la informacion ##" do
        expect(resultado_s_5[0..4]).to eq("ERROR") # si la clave siguiera activa devoveria VALUE .....
    end
    resultado_s_6= socket_6.gets()
    it "##    veo que el socket reciba bien la informacion ##" do
        expect(resultado_s_6[0..4]).to eq("ERROR") # si la clave siguiera activa devoveria VALUE .....
    end
    resultado_s_7= socket_7.gets()
    it "##    veo que el socket reciba bien la informacion ##" do
        expect(resultado_s_7[0..4]).to eq("ERROR") # si la clave siguiera activa devoveria VALUE .....
    end
    resultado_s_8= socket_8.gets()
    it "##    veo que el socket reciba bien la informacion ##" do
        expect(resultado_s_8[0..4]).to eq("ERROR") # si la clave siguiera activa devoveria VALUE .....
    end
    resultado_s_9= socket_9.gets()
    it "##    veo que el socket reciba bien la informacion ##" do
        expect(resultado_s_9[0..4]).to eq("ERROR") # si la clave siguiera activa devoveria VALUE .....
    end
    resultado_s_10= socket_10.gets()
    it "##    veo que el socket reciba bien la informacion ##" do
        expect(resultado_s_10[0..4]).to eq("ERROR") # si la clave siguiera activa devoveria VALUE .....
    end
    resultado_s_11= socket_11.gets()
    it "##    veo que el socket reciba bien la informacion ##" do
        expect(resultado_s_11[0..4]).to eq("ERROR") # si la clave siguiera activa devoveria VALUE .....
    end
    resultado_s_12= socket_12.gets()
    it "##    veo que el socket reciba bien la informacion ##" do
        expect(resultado_s_12[0..4]).to eq("ERROR") # si la clave siguiera activa devoveria VALUE .....
    end
end
socket.close()
socket_1.close()
socket_2.close()
socket_3.close()
socket_4.close()
socket_5.close()
socket_6.close()
socket_7.close()
socket_8.close()
socket_9.close()
socket_10.close()
socket_11.close()
socket_12.close()
