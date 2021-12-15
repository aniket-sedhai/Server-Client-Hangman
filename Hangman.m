buffer_size = 55;
global rem = 0;
global attempts_so_far = '';
global myWordLength = 0;
global UserAnswers = [''];
warning('off','all')
warning
% Entering Server IP Address
fflush(stdout);
%IP_Address=input("Input Server IP Address (default [0]: 152.228.83.193)","s");
IP_Address= "10.1.151.41";

if IP_Address == "0"
    IP_Address= "152.228.83.193";
end
IP_Address

% Entering Server port number
fflush(stdout);
%port_nb=input("Input Server port number (default [0]: 10112)");
port_nb = 10112;
if port_nb==0
    port_nb = 10112;
end
port_nb

pkg load sockets


% Open a socket
client = socket(AF_INET, SOCK_STREAM, 0);
if client <0
    disp('socket() failed');fflush(stdout);
end

disp('socket() establised at');disp(client);fflush(stdout);

server_info = struct("addr",IP_Address,"port", port_nb);

function from_srvr = respond_progress(rcv_msg, client, buffer_size, wordLength)
  global rem;
  global attempts_so_far;
  global UserAnswers;
  NotaNewGuess = true;
  if (rcv_msg(1:3) == '*P*')
    prompt = strcat('Enter a letter (or a word) "',rcv_msg(6:length(rcv_msg)),'" (', rcv_msg(4), ' trials remaining) ');
    attempts_so_far = rcv_msg(6:length(rcv_msg));
    rem = str2num(rcv_msg(4));
    
    user_answer = input(prompt,'s');
    user_answer = lower(user_answer);
    
    if((length(user_answer) == 1) & ismember(user_answer, UserAnswers) )
      NotaNewGuess = true;
      
    else
      NotaNewGuess = false;
      if(length(user_answer) == 1)
          UserAnswers(end + 1) = user_answer;
      end
      fprintf('Your guesses so far: ');
      for i = 1:length(UserAnswers) - 1
          fprintf('%s, ', UserAnswers(i));
      endfor
      fprintf('%s. \n', UserAnswers(end));
    end
    
    while(NotaNewGuess == true)
      
      disp('You already tried this letter.');
      user_answer = input(prompt,'s');
      user_answer = lower(user_answer);
      if((length(user_answer) == 1) & ismember(user_answer, UserAnswers))
        disp('You already tried this letter.');
        user_answer = input(prompt,'s');
        user_answer = lower(user_answer);
        if((length(user_answer) == 1) & ismember(user_answer, UserAnswers))
          NotaNewGuess = true;
        end
      else
        NotaNewGuess = false;
        if(length(user_answer) == 1)
          UserAnswers(end + 1) = user_answer;
        end
        fprintf('Your guesses so far: ');
        for i = 1:length(UserAnswers) - 1
          fprintf('%s, ', UserAnswers(i));
        endfor
        fprintf('%s. \n', UserAnswers(end));
      end
    end
    NotaNewGuess = true;    
    user_answer = lower(user_answer);
    if(length(user_answer) >= wordLength);
      msg_to_send = strcat('*','G','*',user_answer); %HERE
    elseif(length(user_answer) < wordLength)
      msg_to_send = strcat('*','C','*',user_answer);  %HERE
    endif
    %disp(msg_to_send);fflush(stdout);
    send(client,msg_to_send);  
    [DATA, COUNT]=recv(client,buffer_size);
    rcv_msg= char(DATA);
    from_srvr = rcv_msg;
    if(rcv_msg(1:3) == '*P*')
      if(rem > str2num(rcv_msg(4)))
        disp('Sorry, this letter doesnt exist in the word to guess');fflush(stdout);
      else
        disp('This letter exists in the word to guess');
      end
    end
  elseif(rcv_msg(1:3) == '*W*')
    msglen = length(rcv_msg);
    rem = rem - 1;
    prompt = strcat('Enter a letter (or a word) "',attempts_so_far,'" (', num2str(rem), ' trials remaining) ');
    if(strcmp(rcv_msg(4:msglen),'InvalidMessage') == 1)
      disp('The received message was less than 3 characters.');fflush(stdout);
    elseif(strcmp(rcv_msg(4:msglen),'InvalidMessageT') == 1)
      disp('The data field of *T* was not empty.');fflush(stdout);
    elseif(strcmp(rcv_msg(4:msglen),'InvalidMessageR') == 1)
      disp('The data field of *R* was not empty.');fflush(stdout);
    elseif(strcmp(rcv_msg(4:msglen),'TooManyChar') == 1)
      disp('The data field of *C* had more than one character.');fflush(stdout);
    elseif(strcmp(rcv_msg(4:msglen), 'NoCharInserted') == 1)
      disp('The data field of *C* had no character.');fflush(stdout);
    elseif(strcmp(rcv_msg(4:msglen),':WrongSizeGuess') == 1)
      disp('The guess in *G* message had different size than the word to guess.');fflush(stdout);
    elseif(strcmp(rcv_msg(4:msglen),'HeaderNotFound') == 1)
      disp('The header field did not match with any of the acceptable headers.');fflush(stdout);
    endif
    
    while(NotaNewGuess == true)
    
      user_answer = input(prompt,'s');
      user_answer = lower(user_answer);
      if((length(user_answer) == 1) & ismember(user_answer, UserAnswers))
        disp('You already tried this letter.');
        user_answer = input(prompt,'s');
        user_answer = lower(user_answer);
        fprintf('Your guesses so far: ');
        for i = 1:length(UserAnswers) - 1
          fprintf('%s, ', UserAnswers(i));
        endfor
        fprintf('%s. \n', UserAnswers(end));
        if((length(user_answer) == 1) & ismember(user_answer, UserAnswers))
          NotaNewGuess = true;
        end
      else
        %disp('I AM HERE PART 5');
        fprintf('Your guesses so far: ');
        for i = 1:length(UserAnswers) - 1
          fprintf('%s, ', UserAnswers(i));
        endfor
        fprintf('%s. \n', UserAnswers(end));
        NotaNewGuess = false;
        if(length(user_answer) == 1)
          UserAnswers(end + 1) = user_answer;
        end
      end
    end
    NotaNewGuess = true;
    user_answer = lower(user_answer);
    if(length(user_answer) >= wordLength);
      msg_to_send = strcat('*','G','*',user_answer);  %HERE
    elseif(length(user_answer) < wordLength)
      msg_to_send = strcat('*','C','*',user_answer);   %HERE
    endif
    
    %disp(msg_to_send);fflush(stdout);
    send(client,msg_to_send);
    [DATA, COUNT]=recv(client,buffer_size);
    rcv_msg= char(DATA);
    from_srvr = rcv_msg;
  endif
end

%Function that will help in closing 
function close_game(rcv_msg)
  if(rcv_msg(1:3) == '*C*')
    disp('CONGRATULATIONS! You guessed the right word!');fflush(stdout);
  elseif(rcv_msg(1:3) == '*L*')
    disp(strcat(('Game over! You lost. The correct word is "'),rcv_msg(4:length(rcv_msg)), ('" ')));fflush(stdout);
  else
    disp('Doing nothing here.');fflush(stdout);
  endif
end

% Connect to a socket
disp('Trying to connect...');fflush(stdout);
rc = connect(client, server_info);
disp('Connection Established!');fflush(stdout);

    % Start a new game
    clt_msg = strcat('*','R','*');
    disp(char(UserAnswers));
    clt_msg_Length = length(clt_msg);   % Determine input message length
    errorcheck = send(client,clt_msg);
    if errorcheck !=clt_msg_Length
        display('send() s0ent a different number of bytes than expected');fflush(stdout);
    end

    [DATA, COUNT]=recv(client,buffer_size);
    
    DATA_char= char(DATA);
    
    if (DATA_char(1:5)=='*P*9*')
      disp('*** Welcome to the Hangman Game ***!');fflush(stdout);
      myWordLength = length(DATA_char) - 5;
      lenStr = num2str(myWordLength);
      fprintf('PLEASE GUESS %s LETTER WORD. HINT: IT''S AN ANIMAL! \n\n', lenStr);
      gameInprogress = 1;
      while(gameInprogress == 1)
        DATA_char = respond_progress(DATA_char, client, buffer_size, myWordLength);
        if(DATA_char(1:3) == '*C*' | DATA_char(1:3) == '*L*')
          gameInprogress = 0;
        endif
      end
      close_game(DATA_char);
        
    else
      disp('Something is wrong. Contact:georges.el-howayek@valpo.edu for trouble shoot');fflush(stdout);
    endif
    
disconnect(client);


