defmodule WordleThing do
  @moduledoc """
  Documentation for `WordleThing`.
  """

  @doc """
  Hello world.

  ## Examples

  iex> WordleThing.hello()
  :world

  """
  def read_word_list do
    {:ok, word_list} = File.read(".\\normalize_dictionary\\wordle_word_list.txt");
    word_list = word_list |> String.split("\n", trim: true);
    word_list
  end

  def alphabet_map do
    %{
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
  end

  def count_letters(word_list, alphabet_map) do
      Enum.reduce(word_list, alphabet_map, fn word, alphabet_map ->
        Enum.reduce(Map.keys(alphabet_map), alphabet_map, fn letter, alphabet_map ->
          if String.contains?(word, letter) do
            Map.update!(alphabet_map, letter, &(&1 + 1))
          else
            alphabet_map
          end
        end)
      end)
  end

  def sort_alphabet_descending(alphabet_map) do
    Enum.sort_by(alphabet_map, fn {_k, v} -> v end, :desc);
  end

  def top_N_letters(alphabet_map, n) do #potential for other words later? need to think about this a bit more
    Enum.take(alphabet_map, n);
  end

  def composed_of_top_letters(word, top_letters) do
    word_letters = String.graphemes(word);
      Enum.all?(top_letters, fn letter ->
        letter in word_letters #need to check if the top letters are all in the word, not the opposite.
      end)
  end

  def valid_words_from_top_letters(word_list, top_letters_map) do
    #   new_word_list = [];
    #   Enum.reduce(word_list, new_word_list, fn word, new_word_list ->
    #     if composed_of_top_letters(word, letters_list) do
    #       [word | new_word_list]
    #     else
    #       new_word_list
    #     end
    #   end)
    Enum.filter(word_list, fn word ->
      composed_of_top_letters(word, top_letters_map)
    end) 
  end

  def position_frequency_of_given_letters(word_list, letter_map) do
    Enum.reduce(word_list, %{}, fn word, accumulator ->
      word_letters = String.graphemes(word) |> Enum.with_index();
      Enum.reduce(word_letters, accumulator, fn {letter, index}, accumulator ->
        if letter in letter_map do
          Map.update(accumulator, index, %{letter => 1}, fn inner_map ->
            Map.update(inner_map, letter, 1, &(&1 + 1))
          end)
        else
          accumulator
        end
      end)
    end)
  end

  def print_alphabet_map(alphabet_map) do
    Enum.each(alphabet_map, fn x ->
      {letter, count} = x;
      IO.puts("The letter #{letter} has a count of #{count}")
    end)

  end
end
