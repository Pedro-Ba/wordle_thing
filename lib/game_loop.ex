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

  def gameloop(total_word_list, possible_word_list, alphabet_map) do
    alphabet_counted = WordleThing.count_letters(possible_word_list, alphabet_map);
    alphabet_sorted = WordleThing.sort_alphabet_descending(alphabet_counted);
    IO.inspect(alphabet_sorted);
    top_five_map = Enum.map(WordleThing.top_N_letters(alphabet_sorted, 5), fn {k, _v} -> k end);
    IO.inspect(top_five_map);

    possible_guesses = WordleThing.valid_words_from_top_letters(total_word_list, top_five_map);
    IO.inspect(possible_guesses);
    frequency_map = WordleThing.position_frequency_of_given_letters(possible_word_list, top_five_map);
    
    best_guess = WordleThing.get_best_word_from_frequency(total_word_list, possible_guesses, frequency_map);
    
    IO.inspect(best_guess);

    feedback = IO.gets("Enter colors (GYB): ") |> String.trim();
    if feedback == "GGGGG" do
      IO.puts("Guessed the word; game over")
    else 
      new_alphabet_map = prune_alphabet(elem(best_guess, 0), feedback, alphabet_map);
      new_possible_word_list = prune_possible_word_list(elem(best_guess, 0), feedback, possible_word_list);
      gameloop(total_word_list, new_possible_word_list, new_alphabet_map);
    end
  end

  def prune_alphabet(best_guess, feedback, alphabet_map) do
    black_positions = String.graphemes(feedback) |> Enum.with_index(0) |> Enum.filter(fn {k, v} -> 
      if k == "B" do
        v
      end
    end) 
    letters_best_guess = String.graphemes(best_guess);
    letters_to_remove = Enum.map(black_positions, fn {_k, v} ->
      Enum.at(letters_best_guess, v)
    end)
    new_alphabet_map = Enum.reduce(letters_to_remove, alphabet_map, fn letter, acc ->
      Map.delete(acc, letter);
    end)
    new_alphabet_map
  end

  def prune_possible_word_list(best_guess, feedback, possible_word_list) do
    black_positions = String.graphemes(feedback) |> Enum.with_index(0) |> Enum.filter(fn {k, v} -> 
      if k == "B" do
        v
      end
    end) 
    letters_best_guess = String.graphemes(best_guess);
    letters_to_remove = Enum.map(black_positions, fn {_k, v} ->
      Enum.at(letters_best_guess, v)
    end)
    new_word_list = Enum.reject(possible_word_list, fn word -> 
      String.contains?(word, letters_to_remove)
    end)
    new_word_list
  end
end
