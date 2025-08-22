{parsed, _args, _invalid} = OptionParser.parse(System.argv(), strict: [word: :string])

word_list = WordleThing.read_word_list();
alphabet_map = WordleThing.alphabet_map();

case Keyword.get(parsed, :word) do
  nil ->
    IO.puts("No word. Proceeding with normal execution...");
    GameLoop.gameloop(word_list, word_list, alphabet_map, 1, []);
  word ->
    IO.puts("Starting solver on word #{word}...");
    GameLoop.gameloop(word_list, word_list, alphabet_map, 1, [], String.graphemes(word));
end


