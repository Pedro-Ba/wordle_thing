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

  def gameloop(total_word_list, possible_word_list, alphabet_map, attempts, green_letters, word_letters) do
    frequency_map = WordleThing.position_frequency_of_given_letters(possible_word_list, Map.keys(alphabet_map));
  # IO.puts("Frequency map below");
  # IO.inspect(frequency_map);

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
        new_alphabet_map = prune_alphabet(guess_letter_index_feedback, alphabet_map);
        total_word_list = List.delete(total_word_list, elem(best_guess, 0));
        new_possible_word_list = prune_possible_word_list(guess_letter_index_feedback, possible_word_list);
        gameloop(total_word_list, new_possible_word_list, new_alphabet_map, attempts+1, green_letters, word_letters);
   end
  end

  def gameloop(total_word_list, possible_word_list, alphabet_map, attempts, green_letters) do
    frequency_map = WordleThing.position_frequency_of_given_letters(possible_word_list, Map.keys(alphabet_map));
    IO.puts("Frequency map below");
    IO.inspect(frequency_map);

    {best_guess, total_word_list} = guess_loop(total_word_list, frequency_map, attempts);
    IO.puts("Using the following guess: ");
    IO.inspect(best_guess);

    feedback = IO.gets("Enter colors (GYB): ") |> String.trim() |> String.upcase();
    if feedback == "GGGGG" do
        IO.puts("Guessed the word; game over")
    else 
        guess_letter_index_feedback = create_feedback_tuple(elem(best_guess, 0), feedback);
        green_letters = 
          guess_letter_index_feedback
          |> Enum.filter(fn {_letter, _index, feedback} -> feedback == "G" end)
          |> Enum.map(fn {letter, _index, _feedback} -> {letter} end);
        new_alphabet_map = prune_alphabet(guess_letter_index_feedback, alphabet_map);
        total_word_list = List.delete(total_word_list, elem(best_guess, 0));
        new_possible_word_list = prune_possible_word_list(guess_letter_index_feedback, possible_word_list);
        gameloop(total_word_list, new_possible_word_list, new_alphabet_map, attempts+1, green_letters);
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

  def prune_alphabet(guess_letter_index_feedback, alphabet_map) do
    new_alphabet_map =
      guess_letter_index_feedback
      |> Enum.filter(fn {_letter, _index, feedback} -> feedback == "B" end)
      |> Enum.reduce(alphabet_map, fn {letter, _index, _feedback}, acc ->
        Map.delete(acc, letter)
      end);
    new_alphabet_map
  end

  def prune_possible_word_list(guess_letter_index_feedback, possible_word_list) do
    letters_to_remove =
      guess_letter_index_feedback
      |> Enum.filter(fn {_letter, _index, feedback} -> feedback == "B" end)
      |> Enum.map(fn {letter, _index, _feedback} -> letter end);

    word_list_removed_blacks = Enum.reject(possible_word_list, fn word ->
      String.contains?(word, letters_to_remove)
    end)

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
    
    word_list_fixed_greens
  end
end
