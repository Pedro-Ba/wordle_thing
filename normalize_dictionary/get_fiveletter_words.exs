#file and list deprecated in favor of utilizing a list that contains all words that wordle itself accepts, so that I don't have to have a feedback loop deciding whether the word is or isn't valid.
#Took this decision because it makes the solving faster.
#Code file is kept just in case I need to look it up to remember something someday, I'm still learning elixir after all.

words_stream = File.stream!(".\\normalize_dictionary\\words_alpha.txt");
words_stream = words_stream |> Enum.filter(fn wordle -> String.length(wordle) == 6 end); #use 6 to consume newline I don't wanna trim and then re-add newline to pipe to yet another file

File.write(".\\normalize_dictionary\\wordle_word_list.txt", words_stream);
