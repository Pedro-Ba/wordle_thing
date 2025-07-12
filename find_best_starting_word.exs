{:ok, word_list} = File.read(".\\normalize_dictionary\\wordle_word_list.txt");
word_list = word_list |> String.split("\n", trim: true);

alphabet_map = %{
    "a" => 0,
    "b" => 0,
    "c" => 0,
    "d" => 0,
    "e" => 0,
    "f" => 0,
    "g" => 0,
    "h" => 0,
    "i" => 0,
    "j" => 0,
    "k" => 0,
    "l" => 0,
    "m" => 0,
    "n" => 0,
    "o" => 0,
    "p" => 0,
    "q" => 0,
    "r" => 0,
    "s" => 0,
    "t" => 0,
    "u" => 0,
    "v" => 0,
    "w" => 0,
    "x" => 0,
    "y" => 0,
    "z" => 0,
}

alphabet_map =
  Enum.reduce(word_list, alphabet_map, fn word, alphabet_map ->
    Enum.reduce(Map.keys(alphabet_map), alphabet_map, fn letter, alphabet_map ->
      if String.contains?(word, letter) do
        Map.update!(alphabet_map, letter, &(&1 + 1))
      else
        alphabet_map
      end
    end)
  end)

Enum.each(alphabet_map, fn x ->
    {letter, count} = x;
    IO.puts("The letter #{letter} has a count of #{count}") 
end);

