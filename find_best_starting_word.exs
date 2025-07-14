word_list = WordleThing.read_word_list();
alphabet_map = WordleThing.alphabet_map();
alphabet_counted = WordleThing.count_letters(word_list, alphabet_map);
alphabet_sorted = WordleThing.sort_alphabet_descending(alphabet_counted);
top_five_map = WordleThing.top_N_letters(alphabet_sorted, 5)

WordleThing.print_alphabet_map(alphabet_sorted);

WordleThing.print_alphabet_map(top_five_map);
