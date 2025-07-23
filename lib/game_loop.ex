defmodule GameLoop do
@moduledoc """
  Documentation for `GameLoop`.
  """

@doc """
  Hello world.

  ## Examples

  iex> WordleThing.hello()
  :world

  """
  #long term definitely needs an "attempt" counter that kills it post 6
  def gameloop(total_word_list, possible_word_list, alphabet_map) do
    alphabet_counted = WordleThing.count_letters(possible_word_list, alphabet_map);
    alphabet_sorted = WordleThing.sort_alphabet_descending(alphabet_counted);
    IO.puts("Alphabet sorted below");
    IO.inspect(alphabet_sorted);
    top_five_map = Enum.map(WordleThing.top_N_letters(alphabet_sorted, 5), fn {k, _v} -> k end);
    IO.puts("Top five map below");
    IO.inspect(top_five_map);
    #actual mistake is here? Possible guesses utilizes top five map to return a list of "possible guesses", not a "pruned word list", which is an entire different thing. Possible guesses means a word that contains all five of the top letters, which may or may not be feasible; it doesn't especifically utilize the total word list nor does it utilize the possible_word_list. Weird. Does it make a difference when the alphabet count comes from possible word list tho? Potentially? Technically weird though - I don't even know if the word I'm choosing is actually in the possible word list. But that shouldn't be an issue because if the constraint is valid then it shouldn't be there... anyway.
    possible_guesses = WordleThing.valid_words_from_top_letters(total_word_list, top_five_map);
    IO.inspect("Possible guesses below");
    IO.inspect(possible_guesses);
    frequency_map = WordleThing.position_frequency_of_given_letters(possible_word_list, top_five_map);
    IO.puts("Frequency map below");
    IO.inspect(frequency_map);
    best_guess = WordleThing.get_best_pruned_word_from_frequency(total_word_list, possible_guesses, frequency_map);
    IO.puts("Best guess from pruned words below");
    IO.inspect(best_guess);
  # best_guess_not_pruned = WordleThing.get_best_all_word_from_frequency(total_word_list, possible_guesses, frequency_map);
  # IO.puts("Best guess from non-pruned list below");
  # IO.inspect(best_guess_not_pruned);

    feedback = IO.gets("Enter colors (GYB): ") |> String.trim();
    if feedback == "GGGGG" do
        IO.puts("Guessed the word; game over")
    else 
        guess_letter_index_feedback = create_feedback_tuple(elem(best_guess, 0), feedback);
        new_alphabet_map = prune_alphabet(guess_letter_index_feedback, alphabet_map);
        new_possible_word_list = prune_possible_word_list(guess_letter_index_feedback, possible_word_list);
        gameloop(total_word_list, new_possible_word_list, new_alphabet_map);
    end
  end

  def create_feedback_tuple(best_guess, feedback) do
    best_guess 
      |> String.graphemes() 
      |> Enum.with_index(0) 
      |> Enum.zip(String.graphemes(feedback)) 
      |> Enum.map(fn {{letter, index}, feedback} -> {letter, index, feedback} end)
  end

  def prune_alphabet(guess_letter_index_feedback, alphabet_map) do
    new_alphabet_map =
      guess_letter_index_feedback
      |> Enum.filter(fn {_letter, _index, feedback} -> feedback == "B" end)
      |> Enum.reduce(alphabet_map, fn {letter, _index, _feedback}, acc ->
        Map.delete(acc, letter)
      end);
    #You don't remove Yellow letters from the alphabet, you remove words that have them in that position from the possible word list. Either way, this should impact the frequency map. If we were not using the whole alphabet count, but a frequency map, then we would need to alter the frequency map. Keep in mind for later.
    new_alphabet_map
  end

  def prune_possible_word_list(guess_letter_index_feedback, possible_word_list) do
    letters_to_remove = 
      guess_letter_index_feedback
      |> Enum.filter(fn {_letter, _index, feedback} -> feedback == "B" end)
      |> Enum.map(fn {letter, _index, _fb} -> letter end);
      
    word_list_removed_blacks = Enum.reject(possible_word_list, fn word -> 
      String.contains?(word, letters_to_remove)
    end)
    #positions_to_remove = yellow_letters(best_guess, feedback);
  # IO.puts("----------------------------------------- wee woo wee woo");
  #IO.inspect(positions_to_remove);
     #word_list_removed_yellows = Enum.reject(word_list_removed_blacks, fn word ->
      # end)
  #new_word_list
    word_list_removed_blacks
  end
end
