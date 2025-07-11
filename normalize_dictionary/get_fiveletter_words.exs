words_stream = File.stream!(".\\normalize_dictionary\\words_alpha.txt");
words_stream = words_stream |> Enum.filter(fn wordle -> String.length(wordle) == 6 end); #use 6 to consume newline I don't wanna trim and then re-add newline to pipe to yet another file

File.write(".\\normalize_dictionary\\wordle_word_list.txt", words_stream);
