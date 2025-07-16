word_list = WordleThing.read_word_list();
alphabet_map = WordleThing.alphabet_map();
alphabet_counted = WordleThing.count_letters(word_list, alphabet_map);
alphabet_sorted = WordleThing.sort_alphabet_descending(alphabet_counted);
top_five_map = Enum.map(WordleThing.top_N_letters(alphabet_sorted, 5), fn {k, _v} -> k end);



#WordleThing.print_alphabet_map(alphabet_sorted);

#WordleThing.print_alphabet_map(top_five_map);

valid_words = WordleThing.valid_words_from_top_letters(word_list, top_five_map);

#Enum.each(valid_words, &IO.puts/1)

frequency_map = WordleThing.position_frequency_of_given_letters(word_list, top_five_map);

IO.puts(frequency_map);
