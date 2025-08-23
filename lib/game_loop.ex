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
  def feedback(guess, target_letters) do
    guess_letters = String.graphemes(guess)

    greens =
      Enum.zip(guess_letters, target_letters)
      |> Enum.map(fn
      {letter_guess, letter_target} when letter_guess == letter_target -> "G"
      _ -> nil
    end)
    #letters of the word that were not hit
    non_green_letters =
    Enum.zip(guess_letters, target_letters)
    |> Enum.reduce(%{}, fn
      {letter_guess, letter_target}, acc when letter_guess == letter_target ->
        acc 
      {_letter_guess, letter_target}, acc ->
        Map.update(acc, letter_target, 1, &(&1 + 1))
    end)
    
    feedback =
    Enum.zip(guess_letters, greens)
    |> Enum.map(fn
      {letter_guess, "G"} -> "G"
      {letter_guess, nil} ->
        case Map.get(non_green_letters, letter_guess, 0) do
          count when count > 0 ->
            non_green_letters = Map.update!(non_green_letters, letter_guess, &(&1 - 1))
            "Y"
          _ ->
            "B"
        end
    end)

    feedback |> Enum.join()
end

  def solveloop(total_word_list, possible_word_list, alphabet_map, attempts, green_letters, word_letters) do
    frequency_map = WordleThing.position_frequency_of_given_letters(possible_word_list, Map.keys(alphabet_map));
  # IO.puts("Frequency map below");
    IO.inspect(frequency_map);

    {best_guess, total_word_list} = guess_loop(total_word_list, frequency_map, attempts);
  # IO.puts("Using the following guess: ");
  # IO.inspect(best_guess);
    IO.puts("Using the guess ''#{elem(best_guess, 0)}''")
    feedback = feedback(elem(best_guess, 0), word_letters);
    IO.inspect(feedback);

    elem(best_guess, 0)
      |> String.graphemes()
      |> Enum.with_index(0)
      |> Enum.zip(String.graphemes(feedback))
      |> Enum.map(fn {{letter, index}, feedback} -> {letter, index, feedback} end)

    if feedback == "GGGGG" do
      IO.puts("Guessed the word; game over! Total amount of guesses: #{attempts}")
    else 
        guess_letter_index_feedback = create_feedback_tuple(elem(best_guess, 0), feedback);
        green_letters = 
          guess_letter_index_feedback
          |> Enum.filter(fn {_letter, _index, feedback} -> feedback == "G" end)
          |> Enum.map(fn {letter, _index, _feedback} -> {letter} end);
        total_word_list = List.delete(total_word_list, elem(best_guess, 0));
        new_possible_word_list = prune_possible_word_list(guess_letter_index_feedback, possible_word_list);
        IO.puts("New possible word list");
        IO.inspect(new_possible_word_list);
        solveloop(total_word_list, new_possible_word_list, alphabet_map, attempts+1, green_letters, word_letters);
   end
  end

  def gameloop(total_word_list, possible_word_list, alphabet_map, attempts, green_letters) do
    frequency_map = WordleThing.position_frequency_of_given_letters(possible_word_list, Map.keys(alphabet_map));
    IO.puts("Frequency map below");
  #IO.inspect(frequency_map);

    {best_guess, total_word_list} = guess_loop(total_word_list, frequency_map, attempts);
    IO.puts("Using the following guess: ");
  #IO.inspect(best_guess);

    feedback = IO.gets("Enter colors (GYB): ") |> String.trim() |> String.upcase();
    if feedback == "GGGGG" do
        IO.puts("Guessed the word; game over")
    else 
        guess_letter_index_feedback = create_feedback_tuple(elem(best_guess, 0), feedback);
        green_letters = 
          guess_letter_index_feedback
          |> Enum.filter(fn {_letter, _index, feedback} -> feedback == "G" end)
          |> Enum.map(fn {letter, _index, _feedback} -> {letter} end);
        total_word_list = List.delete(total_word_list, elem(best_guess, 0));
        new_possible_word_list = prune_possible_word_list(guess_letter_index_feedback, possible_word_list);
        gameloop(total_word_list, new_possible_word_list, alphabet_map, attempts+1, green_letters);
    end
  end

  def guess_loop(total_word_list, frequency_map, attempts) do
    best_guess = WordleThing.get_best_all_word_from_frequency(total_word_list, frequency_map, attempts);
    {best_guess, total_word_list}
  end

  def create_feedback_tuple(best_guess, feedback) do
    best_guess
      |> String.graphemes()
      |> Enum.with_index(0)
      |> Enum.zip(String.graphemes(feedback))
      |> Enum.map(fn {{letter, index}, feedback} -> {letter, index, feedback} end)
  end

  def prune_possible_word_list(guess_letter_index_feedback, possible_word_list) do
    green_letters =
      guess_letter_index_feedback
      |> Enum.filter(fn {_letter, _index, feedback} -> feedback == "G" end)

    yellow_letters =
      guess_letter_index_feedback
      |> Enum.filter(fn {_letter, _index, feedback} -> feedback == "Y" end)

    black_letters_remove_all =
      guess_letter_index_feedback
      |> Enum.filter(fn {_letter, _index, feedback} -> feedback == "B" end)
|> Enum.reject(fn {letter, _index, _feedback} -> letter in Enum.map(yellow_letters, fn {l, _i, _f} -> l end) or letter in Enum.map(green_letters, fn {l, _i, _f} -> l end) end)
    IO.puts("Black letters to fully remove from list");
    IO.inspect(black_letters_remove_all);

    black_letters_remove_pos =
      guess_letter_index_feedback
      |> Enum.filter(fn {_letter, _index, feedback} -> feedback == "B" end)
      |> Enum.filter(fn {letter, _index, _feedback} -> letter in Enum.map(yellow_letters, fn {l, _i, _f} -> l end) or letter in Enum.map(green_letters, fn {l, _i, _f} -> l end) end)
    IO.puts("Black letters to remove from spot (black letters that appear somewhere else in the word)");
    IO.inspect(black_letters_remove_pos);

    word_list_removed_blacks = Enum.reject(possible_word_list, fn word ->
      String.contains?(word, Enum.map(black_letters_remove_all, fn {letter, _index, _feedback} -> letter end))
    end)
    IO.inspect(word_list_removed_blacks);

    positions_to_remove = 
      guess_letter_index_feedback
      |> Enum.filter(fn {_letter, _index, feedback} -> feedback == "Y" end)
      |> Enum.map(fn {letter, index, _feedback} -> {letter, index} end);

    word_list_removed_yellows = Enum.reject(word_list_removed_blacks, fn word ->
      letters_in_word = String.graphemes(word);
      Enum.any?(positions_to_remove, fn {letter, index} -> 
        Enum.at(letters_in_word, index) == letter
      end)
    end)

    yellow_letters =
      guess_letter_index_feedback
      |> Enum.filter(fn {_letter, _index, feedback} -> feedback == "Y" end)
      |> Enum.map(fn {letter, _index, _feedback} -> letter end);

    word_list_guaranteed_yellows = Enum.filter(word_list_removed_yellows, fn word ->
      Enum.all?(yellow_letters, fn letter ->
        String.contains?(word, letter);
      end)
    end)

    positions_to_fix = 
      guess_letter_index_feedback
      |> Enum.filter(fn {_letter, _index, feedback} -> feedback == "G" end)
      |> Enum.map(fn {letter, index, _feedback} -> {letter, index} end);

    word_list_fixed_greens = Enum.filter(word_list_removed_yellows, fn word ->
      letters_in_word = String.graphemes(word);
      Enum.all?(positions_to_fix, fn {letter, index} -> 
        Enum.at(letters_in_word, index) == letter
      end)
    end)
    
    IO.inspect(word_list_fixed_greens)
    word_list_fixed_greens
  end
end
