word_list = WordleThing.read_word_list();
alphabet_map = WordleThing.alphabet_map();
alphabet_counted = WordleThing.count_letters(word_list, alphabet_map);
alphabet_sorted = WordleThing.sort_alphabet_descending(alphabet_counted);
WordleThing.thing(alphabet_sorted);
