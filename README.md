# Challenge_memcached_ruby

#[Execute as server:] 
*On a command-line interface go to de directory where the program was downloaded 
**ex: C:Users/usuario/Downloads/Challenge_ruby_BC


write: "interactuar" to start the server

##Execute as clients:


Once the server has already started write on a command line: "Telnet localhost 2000" then you can start using all server functions.


Some examples to execute as client:


To add a key: you can use either set or add commands, then you shall give the server the name of the key, a flag, the time that you want that key to exist in the server, the amount of bytes of the key value and finally the value of the key

Ex: set/add [noreply] (noreply optional) add key_0 1 77777 5 value

To obtain a key: use commands get / gets Ex: get/gets get key_0

To modify a key use append/prepend/replace or cas Ex 2: append/prepend/replace [noreply] use append to modify the value of the key by adding information at the end of the previus key

append key 2 88888 9 new_value

Ex 2: cas [noreply] (noreply optional) use cas to modify a key by knowing the value of cas (unique to the key)

cas key 2 5555 3 cas


##Execute tests with rspec gem Once the server has already started write on a command line:


rspec spec/lib/challenge_test_rspec.rb
